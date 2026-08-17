import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/repositories/quick_list_repository.dart';
import '../local/app_database.dart';

class DriftQuickListRepository implements QuickListRepository {
  DriftQuickListRepository(this._database, {this._uuid = const Uuid()});

  final AppDatabase _database;
  final Uuid _uuid;

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
  Future<void> renameQuickList(String listId, String name) async {
    await (_database.update(
      _database.quickLists,
    )..where((row) => row.id.equals(listId) & row.deletedAt.isNull())).write(
      QuickListsCompanion(
        name: Value(_requiredName(name)),
        updatedAtLocal: Value(DateTime.now().toUtc()),
      ),
    );
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
        await _trackTombstone('quick_list', listId, now);
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
    });
  }

  Future<void> _touchList(String listId, DateTime now) {
    return (_database.update(_database.quickLists)
          ..where((row) => row.id.equals(listId)))
        .write(QuickListsCompanion(updatedAtLocal: Value(now)));
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
