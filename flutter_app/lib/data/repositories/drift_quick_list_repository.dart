import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/repositories/quick_list_repository.dart';
import '../local/app_database.dart';
import '../../sync/shared_document_sync_store.dart';

class DriftQuickListRepository implements QuickListRepository {
  DriftQuickListRepository(
    this._database, {
    SharedDocumentSyncStore? syncStore,
    this._uuid = const Uuid(),
  }) : _sync = syncStore ?? SharedDocumentSyncStore(_database, enabled: false);

  final AppDatabase _database;
  final Uuid _uuid;
  final SharedDocumentSyncStore _sync;

  @override
  Stream<List<QuickListSummary>> watchQuickLists() {
    final query = _database.select(_database.quickLists)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAtLocal)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => QuickListSummary(
              id: row.id,
              name: row.name,
              archivedAt: row.archivedAt,
              shared: row.shareState == 'shared',
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Stream<QuickListDetailModel?> watchQuickList(String listId) {
    return _database
        .customSelect(
          '''
            SELECT 'list:' || id AS entity_key, updated_at_local, deleted_at
            FROM quick_lists
            WHERE id = ?
            UNION ALL
            SELECT 'item:' || id, updated_at_local, deleted_at
            FROM quick_list_items
            WHERE quick_list_id = ?
          ''',
          variables: [Variable.withString(listId), Variable.withString(listId)],
          readsFrom: {_database.quickLists, _database.quickListItems},
        )
        .watch()
        .asyncMap((_) => loadQuickList(listId));
  }

  @override
  Future<QuickListDetailModel?> loadQuickList(String listId) async {
    final list =
        await (_database.select(_database.quickLists)
              ..where((row) => row.id.equals(listId) & row.deletedAt.isNull()))
            .getSingleOrNull();
    if (list == null) return null;
    final syncDocument = await (_database.select(
      _database.syncDocuments,
    )..where((row) => row.documentId.equals(listId))).getSingleOrNull();
    final items =
        await (_database.select(_database.quickListItems)
              ..where(
                (row) =>
                    row.quickListId.equals(listId) & row.deletedAt.isNull(),
              )
              ..orderBy([
                (row) => OrderingTerm.asc(row.isChecked),
                (row) => OrderingTerm.asc(row.name),
              ]))
            .get();
    return QuickListDetailModel(
      id: list.id,
      name: list.name,
      items: items
          .map(
            (item) => QuickListItemModel(
              id: item.id,
              name: item.name,
              quantity: item.quantity,
              isChecked: item.isChecked,
            ),
          )
          .toList(growable: false),
      archivedAt: list.archivedAt,
      shared: list.shareState == 'shared',
      v1ShareReady: syncDocument?.capabilityToken?.isNotEmpty ?? false,
      shareCode: syncDocument?.shareCode,
    );
  }

  @override
  Future<String> createQuickList(String name) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database
        .into(_database.quickLists)
        .insert(
          QuickListsCompanion.insert(
            id: id,
            name: _requiredName(name),
            shareState: const Value('local'),
            remoteRecordId: const Value(null),
            shareCode: const Value(null),
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    return id;
  }

  @override
  Future<String> duplicateQuickList(String listId) async {
    final duplicateId = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final source =
          await (_database.select(
                _database.quickLists,
              )..where((row) => row.id.equals(listId) & row.deletedAt.isNull()))
              .getSingle();
      final items =
          await (_database.select(_database.quickListItems)..where(
                (row) =>
                    row.quickListId.equals(listId) & row.deletedAt.isNull(),
              ))
              .get();
      await _database
          .into(_database.quickLists)
          .insert(
            QuickListsCompanion.insert(
              id: duplicateId,
              name: '${source.name} — copie',
              shareState: const Value('local'),
              remoteRecordId: const Value(null),
              shareCode: const Value(null),
              archivedAt: const Value(null),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      for (final item in items) {
        await _database
            .into(_database.quickListItems)
            .insert(
              QuickListItemsCompanion.insert(
                id: _uuid.v4(),
                quickListId: duplicateId,
                name: item.name,
                quantity: Value(item.quantity),
                isChecked: const Value(false),
                createdAt: now,
                updatedAtLocal: now,
              ),
            );
      }
    });
    return duplicateId;
  }

  @override
  Future<void> archiveQuickList(String listId) => _setArchived(listId, true);

  @override
  Future<void> restoreQuickList(String listId) => _setArchived(listId, false);

  Future<void> _setArchived(String listId, bool archived) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final list =
          await (_database.select(
                _database.quickLists,
              )..where((row) => row.id.equals(listId) & row.deletedAt.isNull()))
              .getSingle();
      await (_database.update(
        _database.quickLists,
      )..where((row) => row.id.equals(listId))).write(
        QuickListsCompanion(
          archivedAt: Value(archived ? now : null),
          updatedAtLocal: Value(now),
        ),
      );
      if (list.shareState == 'shared') {
        await _sync.recordUpsert(listId, 'quick_list', listId);
      }
    });
  }

  @override
  Future<void> renameQuickList(String listId, String name) async {
    await _database.transaction(() async {
      await (_database.update(
        _database.quickLists,
      )..where((row) => row.id.equals(listId) & row.deletedAt.isNull())).write(
        QuickListsCompanion(
          name: Value(_requiredName(name)),
          updatedAtLocal: Value(DateTime.now().toUtc()),
        ),
      );
      if (await _isShared(listId)) {
        await _sync.recordUpsert(listId, 'quick_list', listId);
      }
    });
  }

  @override
  Future<void> deleteQuickList(String listId) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final list = await (_database.select(
        _database.quickLists,
      )..where((row) => row.id.equals(listId))).getSingle();
      await (_database.update(
        _database.quickLists,
      )..where((row) => row.id.equals(listId))).write(
        QuickListsCompanion(deletedAt: Value(now), updatedAtLocal: Value(now)),
      );
      await (_database.update(
        _database.quickListItems,
      )..where((row) => row.quickListId.equals(listId))).write(
        QuickListItemsCompanion(
          deletedAt: Value(now),
          updatedAtLocal: Value(now),
        ),
      );
      if (list.shareState == 'shared') {
        final items = await (_database.select(
          _database.quickListItems,
        )..where((row) => row.quickListId.equals(listId))).get();
        for (final item in items) {
          await _trackTombstone('quick_list_item', item.id, now);
          await _sync.recordDelete(listId, 'quick_list_item', item.id);
        }
        await _trackTombstone('quick_list', listId, now);
        await _sync.recordDelete(listId, 'quick_list', listId);
      }
    });
  }

  @override
  Future<String> addItem({
    required String listId,
    required String name,
    required int quantity,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await (_database.select(_database.quickLists)
            ..where((row) => row.id.equals(listId) & row.deletedAt.isNull()))
          .getSingle();
      await _database
          .into(_database.quickListItems)
          .insert(
            QuickListItemsCompanion.insert(
              id: id,
              quickListId: listId,
              name: _requiredName(name),
              quantity: Value(quantity.clamp(1, 99)),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      await _touchList(listId, now);
      if (await _isShared(listId)) {
        await _sync.recordUpsert(listId, 'quick_list_item', id);
      }
    });
    return id;
  }

  @override
  Future<void> updateItem({
    required String itemId,
    required String name,
    required int quantity,
  }) async {
    await _database.transaction(() async {
      final item =
          await (_database.select(
                _database.quickListItems,
              )..where((row) => row.id.equals(itemId) & row.deletedAt.isNull()))
              .getSingle();
      final now = DateTime.now().toUtc();
      await (_database.update(
        _database.quickListItems,
      )..where((row) => row.id.equals(itemId))).write(
        QuickListItemsCompanion(
          name: Value(_requiredName(name)),
          quantity: Value(quantity.clamp(1, 99)),
          updatedAtLocal: Value(now),
        ),
      );
      await _touchList(item.quickListId, now);
      if (await _isShared(item.quickListId)) {
        await _sync.recordUpsert(item.quickListId, 'quick_list_item', item.id);
      }
    });
  }

  @override
  Future<void> toggleItem(String itemId) async {
    await _database.transaction(() async {
      final item =
          await (_database.select(
                _database.quickListItems,
              )..where((row) => row.id.equals(itemId) & row.deletedAt.isNull()))
              .getSingle();
      final now = DateTime.now().toUtc();
      await (_database.update(
        _database.quickListItems,
      )..where((row) => row.id.equals(itemId))).write(
        QuickListItemsCompanion(
          isChecked: Value(!item.isChecked),
          updatedAtLocal: Value(now),
        ),
      );
      await _touchList(item.quickListId, now);
      if (await _isShared(item.quickListId)) {
        await _sync.recordUpsert(item.quickListId, 'quick_list_item', item.id);
      }
    });
  }

  @override
  Future<void> changeItemQuantity(String itemId, int delta) async {
    await _database.transaction(() async {
      final item =
          await (_database.select(
                _database.quickListItems,
              )..where((row) => row.id.equals(itemId) & row.deletedAt.isNull()))
              .getSingle();
      final now = DateTime.now().toUtc();
      await (_database.update(
        _database.quickListItems,
      )..where((row) => row.id.equals(itemId))).write(
        QuickListItemsCompanion(
          quantity: Value((item.quantity + delta).clamp(1, 99)),
          updatedAtLocal: Value(now),
        ),
      );
      await _touchList(item.quickListId, now);
      if (await _isShared(item.quickListId)) {
        await _sync.recordUpsert(item.quickListId, 'quick_list_item', item.id);
      }
    });
  }

  @override
  Future<void> deleteItem(String itemId) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final item =
          await (_database.select(
                _database.quickListItems,
              )..where((row) => row.id.equals(itemId) & row.deletedAt.isNull()))
              .getSingle();
      final list = await (_database.select(
        _database.quickLists,
      )..where((row) => row.id.equals(item.quickListId))).getSingle();
      await (_database.update(
        _database.quickListItems,
      )..where((row) => row.id.equals(itemId))).write(
        QuickListItemsCompanion(
          deletedAt: Value(now),
          updatedAtLocal: Value(now),
        ),
      );
      await _touchList(item.quickListId, now);
      if (list.shareState == 'shared') {
        await _trackTombstone('quick_list_item', itemId, now);
        await _sync.recordDelete(item.quickListId, 'quick_list_item', itemId);
      }
    });
  }

  @override
  Future<void> reset(String listId) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await (_database.update(_database.quickListItems)..where(
            (row) => row.quickListId.equals(listId) & row.deletedAt.isNull(),
          ))
          .write(
            QuickListItemsCompanion(
              isChecked: const Value(false),
              updatedAtLocal: Value(now),
            ),
          );
      await _touchList(listId, now);
      if (await _isShared(listId)) {
        final items =
            await (_database.select(_database.quickListItems)..where(
                  (row) =>
                      row.quickListId.equals(listId) & row.deletedAt.isNull(),
                ))
                .get();
        for (final item in items) {
          await _sync.recordUpsert(listId, 'quick_list_item', item.id);
        }
      }
    });
  }

  Future<void> _touchList(String listId, DateTime now) {
    return (_database.update(_database.quickLists)
          ..where((row) => row.id.equals(listId)))
        .write(QuickListsCompanion(updatedAtLocal: Value(now)));
  }

  Future<bool> _isShared(String listId) async {
    final list = await (_database.select(
      _database.quickLists,
    )..where((row) => row.id.equals(listId))).getSingle();
    return list.shareState == 'shared';
  }

  Future<void> _trackTombstone(
    String entityType,
    String entityId,
    DateTime deletedAt,
  ) {
    return _database
        .into(_database.syncTombstones)
        .insertOnConflictUpdate(
          SyncTombstonesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            deletedAt: deletedAt,
            purgeEligibleAt: deletedAt.add(const Duration(days: 90)),
          ),
        );
  }
}

String _requiredName(String value) {
  final clean = value.trim();
  if (clean.isEmpty) throw ArgumentError.value(value, 'name', 'Nom requis');
  return clean;
}
