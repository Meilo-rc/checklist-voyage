import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/repositories/context_repository.dart';
import '../local/app_database.dart';
import '../../sync/library_sync_store.dart';

class DriftContextRepository implements ContextRepository {
  DriftContextRepository(
    this._database, {
    this._uuid = const Uuid(),
    LibrarySyncStore? syncStore,
  }) : _sync = syncStore ?? LibrarySyncStore(_database, enabled: false);

  final AppDatabase _database;
  final Uuid _uuid;
  final LibrarySyncStore _sync;

  @override
  Stream<List<ContextModel>> watchContexts() {
    return _database
        .customSelect(
          '''
            SELECT 'context:' || id AS entity_key, updated_at_local, deleted_at
            FROM contexts
            UNION ALL
            SELECT 'association:' || item_id || ':' || context_id,
              updated_at_local, deleted_at
            FROM library_item_contexts
          ''',
          readsFrom: {_database.contexts, _database.libraryItemContexts},
        )
        .watch()
        .asyncMap((_) => loadContexts());
  }

  @override
  Future<List<ContextModel>> loadContexts() async {
    final rows =
        await (_database.select(_database.contexts)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    return rows
        .map((row) => ContextModel(id: row.id, name: row.name))
        .toList(growable: false);
  }

  @override
  Future<String> createContext(String name) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await _database
          .into(_database.contexts)
          .insert(
            ContextsCompanion.insert(
              id: id,
              name: _requiredName(name),
              syncScope: 'shared_library',
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      await _sync.recordUpsert('context', id, {
        'name': _requiredName(name),
        'sync_scope': 'shared_library',
      });
    });
    return id;
  }

  @override
  Future<void> renameContext(String contextId, String name) async {
    await _database.transaction(() async {
      final changed =
          await (_database.update(_database.contexts)..where(
                (row) => row.id.equals(contextId) & row.deletedAt.isNull(),
              ))
              .write(
                ContextsCompanion(
                  name: Value(_requiredName(name)),
                  updatedAtLocal: Value(DateTime.now().toUtc()),
                ),
              );
      if (changed != 1) throw StateError('Contexte introuvable.');
      await _sync.recordUpsert(
        'context',
        contextId,
        await _sync.payloadFor('context', contextId),
      );
    });
  }

  @override
  Future<void> deleteContext(String contextId) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await (_database.select(_database.contexts)
            ..where((row) => row.id.equals(contextId) & row.deletedAt.isNull()))
          .getSingle();
      final associations = await (_database.select(
        _database.libraryItemContexts,
      )..where((row) => row.contextId.equals(contextId))).get();
      await (_database.update(
        _database.contexts,
      )..where((row) => row.id.equals(contextId))).write(
        ContextsCompanion(deletedAt: Value(now), updatedAtLocal: Value(now)),
      );
      await (_database.update(
        _database.libraryItemContexts,
      )..where((row) => row.contextId.equals(contextId))).write(
        LibraryItemContextsCompanion(
          deletedAt: Value(now),
          updatedAtLocal: Value(now),
        ),
      );
      await _trackTombstone('context', contextId, now);
      for (final association in associations) {
        if (association.deletedAt == null &&
            association.syncScope == 'shared_library' &&
            association.associationId != null) {
          await _trackTombstone(
            'context_association',
            association.associationId!,
            now,
          );
          await _sync.recordDelete(
            'context_association',
            association.associationId!,
          );
        }
      }
      await _sync.recordDelete('context', contextId);
    });
  }

  @override
  Future<Set<String>> loadContextIdsForItem(String itemId) async {
    final rows =
        await (_database.select(_database.libraryItemContexts)..where(
              (row) => row.itemId.equals(itemId) & row.deletedAt.isNull(),
            ))
            .get();
    return rows.map((row) => row.contextId).toSet();
  }

  @override
  Future<void> setItemContexts(String itemId, Set<String> contextIds) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final item =
          await (_database.select(
                _database.libraryItems,
              )..where((row) => row.id.equals(itemId) & row.deletedAt.isNull()))
              .getSingle();
      final category = await (_database.select(
        _database.libraryCategories,
      )..where((row) => row.id.equals(item.categoryId))).getSingle();
      final owner = await (_database.select(
        _database.libraryOwners,
      )..where((row) => row.id.equals(category.ownerId))).getSingle();
      final scope = owner.kind == 'personal'
          ? 'personal_local'
          : 'shared_library';

      if (contextIds.isNotEmpty) {
        final contexts =
            await (_database.select(_database.contexts)..where(
                  (row) => row.id.isIn(contextIds) & row.deletedAt.isNull(),
                ))
                .get();
        if (contexts.length != contextIds.length) {
          throw ArgumentError('Un contexte sélectionné est introuvable.');
        }
      }

      final existing = await (_database.select(
        _database.libraryItemContexts,
      )..where((row) => row.itemId.equals(itemId))).get();
      for (final association in existing) {
        final selected = contextIds.contains(association.contextId);
        if (!selected && association.deletedAt == null) {
          await (_database.update(_database.libraryItemContexts)..where(
                (row) =>
                    row.itemId.equals(itemId) &
                    row.contextId.equals(association.contextId),
              ))
              .write(
                LibraryItemContextsCompanion(
                  deletedAt: Value(now),
                  updatedAtLocal: Value(now),
                ),
              );
          if (association.syncScope == 'shared_library' &&
              association.associationId != null) {
            await _trackTombstone(
              'context_association',
              association.associationId!,
              now,
            );
            await _sync.recordDelete(
              'context_association',
              association.associationId!,
            );
          }
        }
      }

      for (final contextId in contextIds) {
        final previous = existing
            .where((association) => association.contextId == contextId)
            .firstOrNull;
        if (previous?.deletedAt == null && previous != null) continue;
        final associationId = _uuid.v4();
        await _database
            .into(_database.libraryItemContexts)
            .insertOnConflictUpdate(
              LibraryItemContextsCompanion.insert(
                itemId: itemId,
                contextId: contextId,
                associationId: Value(associationId),
                syncScope: Value(scope),
                createdAt: now,
                updatedAtLocal: Value(now),
                deletedAt: const Value(null),
              ),
            );
        await _sync.recordUpsert('context_association', associationId, {
          'item_id': itemId,
          'context_id': contextId,
          'sync_scope': scope,
        });
      }
    });
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
