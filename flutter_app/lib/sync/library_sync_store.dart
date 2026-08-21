import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import 'sync_models.dart';

const defaultV1LibraryId = '6d0f0d44-54f8-4f6a-b535-0a58d6efac11';

class LibrarySyncStore {
  LibrarySyncStore(
    this.database, {
    this.enabled = true,
    this._uuid = const Uuid(),
  });

  final AppDatabase database;
  final bool enabled;
  final Uuid _uuid;

  Future<bool> recordUpsert(
    String entityType,
    String entityId,
    Map<String, Object?> payload,
  ) => _record(entityType, entityId, 'upsert', payload);

  Future<bool> recordDelete(
    String entityType,
    String entityId, [
    Map<String, Object?> payload = const {},
  ]) => _record(entityType, entityId, 'delete', payload);

  Future<bool> _record(
    String entityType,
    String entityId,
    String operationType,
    Map<String, Object?> payload,
  ) async {
    if (!enabled) return false;
    if (!await _isShareable(entityType, entityId)) return false;
    await _ensureSettings();
    final settings = await database
        .select(database.installationSettings)
        .getSingle();
    final state =
        await (database.select(database.syncEntityStates)..where(
              (row) =>
                  row.entityType.equals(entityType) &
                  row.entityId.equals(entityId),
            ))
            .getSingleOrNull();
    final counter = (state?.clientCounter ?? 0) + 1;
    final now = DateTime.now().toUtc();
    final operationId = _uuid.v4();
    await database
        .into(database.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            operationId: operationId,
            documentId: settings.libraryId,
            entityType: entityType,
            entityId: entityId,
            operationType: operationType,
            payloadJson: jsonEncode(payload),
            libraryId: Value(settings.libraryId),
            installationId: Value(settings.installationId),
            clientSequence: Value(settings.nextOperationSequence),
            clientCounter: Value(counter),
            baseRevision: Value(settings.pullCursor),
            createdAt: now,
          ),
        );
    await database
        .into(database.syncEntityStates)
        .insertOnConflictUpdate(
          SyncEntityStatesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            clientCounter: Value(counter),
            serverRevision: Value(state?.serverRevision ?? 0),
            winningDeviceId: Value(state?.winningDeviceId),
            remotelyDeleted: Value(operationType == 'delete'),
          ),
        );
    await (database.update(
      database.installationSettings,
    )..where((row) => row.id.equals('current'))).write(
      InstallationSettingsCompanion(
        nextOperationSequence: Value(settings.nextOperationSequence + 1),
        syncStatus: const Value('pending'),
        syncError: const Value(null),
        updatedAtLocal: Value(now),
      ),
    );
    return true;
  }

  Future<bool> _isShareable(String entityType, String entityId) async {
    final result = await database
        .customSelect(
          switch (entityType) {
            'library_owner' =>
              '''
          SELECT COUNT(*) AS count FROM library_owners
          WHERE id = ? AND sync_scope = 'shared_library'
        ''',
            'library_category' =>
              '''
          SELECT COUNT(*) AS count FROM library_categories c
          JOIN library_owners o ON o.id = c.owner_id
          WHERE c.id = ? AND o.sync_scope = 'shared_library'
        ''',
            'library_item' =>
              '''
          SELECT COUNT(*) AS count FROM library_items i
          JOIN library_categories c ON c.id = i.category_id
          JOIN library_owners o ON o.id = c.owner_id
          WHERE i.id = ? AND o.sync_scope = 'shared_library'
        ''',
            'context' =>
              '''
          SELECT COUNT(*) AS count FROM contexts
          WHERE id = ? AND sync_scope = 'shared_library'
        ''',
            'context_association' =>
              '''
          SELECT COUNT(*) AS count FROM library_item_contexts a
          JOIN library_items i ON i.id = a.item_id
          JOIN library_categories c ON c.id = i.category_id
          JOIN library_owners o ON o.id = c.owner_id
          WHERE a.association_id = ?
            AND a.sync_scope = 'shared_library'
            AND o.sync_scope = 'shared_library'
        ''',
            _ => 'SELECT 0 AS count',
          },
          variables: [Variable.withString(entityId)],
          readsFrom: {
            database.libraryOwners,
            database.libraryCategories,
            database.libraryItems,
            database.contexts,
            database.libraryItemContexts,
          },
        )
        .getSingle();
    return result.read<int>('count') == 1;
  }

  Future<void> ensureBootstrapQueued() async {
    if (!enabled) return;
    await _ensureSettings();
    await _pruneInvalidBootstrapUpserts();
    final entities = await database
        .customSelect(
          '''
      SELECT 'library_owner' AS entity_type, id AS entity_id
      FROM library_owners WHERE sync_scope = 'shared_library' AND deleted_at IS NULL
      UNION ALL
      SELECT 'library_category', c.id FROM library_categories c
      JOIN library_owners o ON o.id = c.owner_id
      WHERE o.sync_scope = 'shared_library'
        AND o.deleted_at IS NULL
        AND c.deleted_at IS NULL
      UNION ALL
      SELECT 'library_item', i.id FROM library_items i
      JOIN library_categories c ON c.id = i.category_id
      JOIN library_owners o ON o.id = c.owner_id
      WHERE o.sync_scope = 'shared_library'
        AND o.deleted_at IS NULL
        AND c.deleted_at IS NULL
        AND i.deleted_at IS NULL
      UNION ALL
      SELECT 'context', id FROM contexts
      WHERE sync_scope = 'shared_library' AND deleted_at IS NULL
      UNION ALL
      SELECT 'context_association', a.association_id
      FROM library_item_contexts a
      JOIN library_items i ON i.id = a.item_id
      JOIN library_categories c ON c.id = i.category_id
      JOIN library_owners o ON o.id = c.owner_id
      JOIN contexts x ON x.id = a.context_id
      WHERE a.sync_scope = 'shared_library'
        AND o.sync_scope = 'shared_library'
        AND x.sync_scope = 'shared_library'
        AND o.deleted_at IS NULL
        AND c.deleted_at IS NULL
        AND i.deleted_at IS NULL
        AND x.deleted_at IS NULL
        AND a.deleted_at IS NULL
        AND a.association_id IS NOT NULL
    ''',
          readsFrom: {
            database.libraryOwners,
            database.libraryCategories,
            database.libraryItems,
            database.contexts,
            database.libraryItemContexts,
          },
        )
        .get();
    for (final row in entities) {
      final type = row.read<String>('entity_type');
      final id = row.read<String>('entity_id');
      final known =
          await (database.select(database.syncEntityStates)..where(
                (entry) =>
                    entry.entityType.equals(type) & entry.entityId.equals(id),
              ))
              .getSingleOrNull();
      if (known == null) {
        await recordUpsert(type, id, await payloadFor(type, id));
      }
    }
  }

  Future<void> _pruneInvalidBootstrapUpserts() async {
    final invalid = await database
        .customSelect(
          '''
      SELECT operation_id, entity_type, entity_id
      FROM sync_outbox outbox
      WHERE operation_type = 'upsert'
        AND (
          (entity_type = 'library_category' AND NOT EXISTS (
            SELECT 1 FROM library_categories c
            JOIN library_owners o ON o.id = c.owner_id
            WHERE c.id = outbox.entity_id
              AND c.deleted_at IS NULL
              AND o.deleted_at IS NULL
              AND o.sync_scope = 'shared_library'
          ))
          OR
          (entity_type = 'library_item' AND NOT EXISTS (
            SELECT 1 FROM library_items i
            JOIN library_categories c ON c.id = i.category_id
            JOIN library_owners o ON o.id = c.owner_id
            WHERE i.id = outbox.entity_id
              AND i.deleted_at IS NULL
              AND c.deleted_at IS NULL
              AND o.deleted_at IS NULL
              AND o.sync_scope = 'shared_library'
          ))
          OR
          (entity_type = 'context_association' AND NOT EXISTS (
            SELECT 1 FROM library_item_contexts a
            JOIN library_items i ON i.id = a.item_id
            JOIN library_categories c ON c.id = i.category_id
            JOIN library_owners o ON o.id = c.owner_id
            JOIN contexts x ON x.id = a.context_id
            WHERE a.association_id = outbox.entity_id
              AND a.deleted_at IS NULL
              AND i.deleted_at IS NULL
              AND c.deleted_at IS NULL
              AND o.deleted_at IS NULL
              AND x.deleted_at IS NULL
              AND a.sync_scope = 'shared_library'
              AND o.sync_scope = 'shared_library'
              AND x.sync_scope = 'shared_library'
          ))
        )
      ''',
          readsFrom: {
            database.syncOutbox,
            database.libraryOwners,
            database.libraryCategories,
            database.libraryItems,
            database.contexts,
            database.libraryItemContexts,
          },
        )
        .get();
    if (invalid.isEmpty) return;

    await database.transaction(() async {
      for (final row in invalid) {
        final operationId = row.read<String>('operation_id');
        final entityType = row.read<String>('entity_type');
        final entityId = row.read<String>('entity_id');
        await (database.delete(
          database.syncOutbox,
        )..where((entry) => entry.operationId.equals(operationId))).go();

        final remaining =
            await (database.select(database.syncOutbox)..where(
                  (entry) =>
                      entry.entityType.equals(entityType) &
                      entry.entityId.equals(entityId),
                ))
                .get();
        final state =
            await (database.select(database.syncEntityStates)..where(
                  (entry) =>
                      entry.entityType.equals(entityType) &
                      entry.entityId.equals(entityId),
                ))
                .getSingleOrNull();
        if (remaining.isEmpty &&
            state != null &&
            state.serverRevision == 0 &&
            state.winningDeviceId == null) {
          await (database.delete(database.syncEntityStates)..where(
                (entry) =>
                    entry.entityType.equals(entityType) &
                    entry.entityId.equals(entityId),
              ))
              .go();
        }
      }
    });
  }

  Future<Map<String, Object?>> payloadFor(
    String entityType,
    String entityId,
  ) async {
    switch (entityType) {
      case 'library_owner':
        final row = await (database.select(
          database.libraryOwners,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        return {
          'name': row.name,
          'kind': row.kind,
          'sync_scope': row.syncScope,
          'generation_role': row.generationRole,
          'icon': row.icon,
        };
      case 'library_category':
        final row = await (database.select(
          database.libraryCategories,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        return {'owner_id': row.ownerId, 'name': row.name, 'icon': row.icon};
      case 'library_item':
        final row = await (database.select(
          database.libraryItems,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        return {
          'category_id': row.categoryId,
          'name': row.name,
          'default_quantity': row.defaultQuantity,
          'logical_source_id': row.logicalSourceId ?? row.id,
        };
      case 'context':
        final row = await (database.select(
          database.contexts,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        return {'name': row.name, 'sync_scope': row.syncScope};
      case 'context_association':
        final row = await (database.select(
          database.libraryItemContexts,
        )..where((entry) => entry.associationId.equals(entityId))).getSingle();
        return {
          'item_id': row.itemId,
          'context_id': row.contextId,
          'sync_scope': row.syncScope,
        };
      default:
        throw ArgumentError.value(entityType, 'entityType');
    }
  }

  Future<List<SyncOperation>> pendingOperations() async {
    final settings = await this.settings();
    final rows =
        await (database.select(database.syncOutbox)
              ..where((row) => row.documentId.equals(settings.libraryId))
              ..orderBy([(row) => OrderingTerm.asc(row.clientSequence)]))
            .get();
    final operations = <SyncOperation>[];
    for (final row in rows) {
      operations.add(
        SyncOperation(
          operationId: row.operationId,
          libraryId: row.libraryId,
          deviceId: row.installationId,
          clientSequence: row.clientSequence,
          clientCounter: row.clientCounter,
          baseRevision: row.baseRevision ?? 0,
          entityType: row.entityType,
          entityId: row.entityId,
          operationType: row.operationType,
          payload: Map<String, Object?>.from(
            jsonDecode(row.payloadJson) as Map,
          ),
        ),
      );
    }
    return operations;
  }

  Future<void> markPushConfirmed(RemoteOperation remote) async {
    final op = remote.operation;
    await database.transaction(() async {
      await (database.delete(
        database.syncOutbox,
      )..where((row) => row.operationId.equals(op.operationId))).go();
      await _recordRemoteMetadata(remote);
      if (op.isDelete) {
        await (database.update(database.syncTombstones)..where(
              (row) =>
                  row.entityType.equals(op.entityType) &
                  row.entityId.equals(op.entityId),
            ))
            .write(
              SyncTombstonesCompanion(
                propagatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    });
  }

  Future<void> applyPullPage(SyncPullPage page) async {
    await database.transaction(() async {
      for (final remote in page.operations) {
        if (remote.applied) await _apply(remote.operation);
        await _recordRemoteMetadata(remote);
        if (!remote.applied) await _recordConflict(remote);
      }
      await (database.update(database.installationSettings)
            ..where((row) => row.id.equals('current')))
          .write(InstallationSettingsCompanion(pullCursor: Value(page.cursor)));
    });
  }

  Future<void> _recordRemoteMetadata(RemoteOperation remote) async {
    final op = remote.operation;
    final current =
        await (database.select(database.syncEntityStates)..where(
              (row) =>
                  row.entityType.equals(op.entityType) &
                  row.entityId.equals(op.entityId),
            ))
            .getSingleOrNull();
    await database
        .into(database.syncEntityStates)
        .insertOnConflictUpdate(
          SyncEntityStatesCompanion.insert(
            entityType: op.entityType,
            entityId: op.entityId,
            clientCounter: Value(
              current == null
                  ? op.clientCounter
                  : current.clientCounter > op.clientCounter
                  ? current.clientCounter
                  : op.clientCounter,
            ),
            serverRevision: Value(remote.serverRevision),
            winningDeviceId: Value(
              remote.applied ? op.deviceId : current?.winningDeviceId,
            ),
            remotelyDeleted: Value(
              remote.applied ? op.isDelete : current?.remotelyDeleted ?? false,
            ),
          ),
        );
  }

  Future<void> _recordConflict(RemoteOperation remote) async {
    await database
        .into(database.syncConflicts)
        .insertOnConflictUpdate(
          SyncConflictsCompanion.insert(
            id: remote.operation.operationId,
            documentId: remote.operation.libraryId,
            entityType: remote.operation.entityType,
            entityId: remote.operation.entityId,
            localJson: Value(jsonEncode(remote.operation.payload)),
            remoteJson: Value(
              jsonEncode({
                'reason': remote.conflictReason,
                'revision': remote.serverRevision,
              }),
            ),
            detectedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> _apply(SyncOperation op) async {
    final now = DateTime.now().toUtc();
    if (op.isDelete) {
      await _softDelete(op.entityType, op.entityId, now);
      return;
    }
    final p = op.payload;
    switch (op.entityType) {
      case 'library_owner':
        if (p['sync_scope'] != 'shared_library' || p['kind'] == 'personal') {
          return;
        }
        await database
            .into(database.libraryOwners)
            .insertOnConflictUpdate(
              LibraryOwnersCompanion.insert(
                id: op.entityId,
                kind: p['kind']! as String,
                syncScope: 'shared_library',
                generationRole: Value(p['generation_role']! as String),
                name: p['name']! as String,
                icon: Value(p['icon'] as String?),
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
      case 'library_category':
        await database
            .into(database.libraryCategories)
            .insertOnConflictUpdate(
              LibraryCategoriesCompanion.insert(
                id: op.entityId,
                ownerId: p['owner_id']! as String,
                name: p['name']! as String,
                icon: Value(p['icon'] as String?),
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
      case 'library_item':
        await database
            .into(database.libraryItems)
            .insertOnConflictUpdate(
              LibraryItemsCompanion.insert(
                id: op.entityId,
                categoryId: p['category_id']! as String,
                name: p['name']! as String,
                defaultQuantity: Value((p['default_quantity'] as num).toInt()),
                logicalSourceId: Value(p['logical_source_id'] as String?),
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
      case 'context':
        if (p['sync_scope'] != 'shared_library') return;
        await database
            .into(database.contexts)
            .insertOnConflictUpdate(
              ContextsCompanion.insert(
                id: op.entityId,
                name: p['name']! as String,
                syncScope: 'shared_library',
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
      case 'context_association':
        if (p['sync_scope'] != 'shared_library') return;
        await database
            .into(database.libraryItemContexts)
            .insertOnConflictUpdate(
              LibraryItemContextsCompanion.insert(
                itemId: p['item_id']! as String,
                contextId: p['context_id']! as String,
                associationId: Value(op.entityId),
                syncScope: const Value('shared_library'),
                createdAt: now,
                updatedAtLocal: Value(now),
                deletedAt: const Value(null),
              ),
            );
    }
  }

  Future<void> _softDelete(String type, String id, DateTime now) async {
    switch (type) {
      case 'library_owner':
        await (database.update(
          database.libraryOwners,
        )..where((row) => row.id.equals(id))).write(
          LibraryOwnersCompanion(
            deletedAt: Value(now),
            updatedAtLocal: Value(now),
          ),
        );
      case 'library_category':
        await (database.update(
          database.libraryCategories,
        )..where((row) => row.id.equals(id))).write(
          LibraryCategoriesCompanion(
            deletedAt: Value(now),
            updatedAtLocal: Value(now),
          ),
        );
      case 'library_item':
        await (database.update(
          database.libraryItems,
        )..where((row) => row.id.equals(id))).write(
          LibraryItemsCompanion(
            deletedAt: Value(now),
            updatedAtLocal: Value(now),
          ),
        );
      case 'context':
        await (database.update(
          database.contexts,
        )..where((row) => row.id.equals(id))).write(
          ContextsCompanion(deletedAt: Value(now), updatedAtLocal: Value(now)),
        );
      case 'context_association':
        await (database.update(
          database.libraryItemContexts,
        )..where((row) => row.associationId.equals(id))).write(
          LibraryItemContextsCompanion(
            deletedAt: Value(now),
            updatedAtLocal: Value(now),
          ),
        );
    }
    await database
        .into(database.syncTombstones)
        .insertOnConflictUpdate(
          SyncTombstonesCompanion.insert(
            entityType: type,
            entityId: id,
            deletedAt: now,
            propagatedAt: Value(now),
            purgeEligibleAt: now.add(const Duration(days: 90)),
          ),
        );
  }

  Stream<SyncStatusModel> watchStatus() => database
      .customSelect(
        '''
    SELECT s.sync_status, s.sync_error, s.last_sync_at,
      (SELECT COUNT(*) FROM sync_outbox) AS pending
    FROM installation_settings s WHERE s.id = 'current'
  ''',
        readsFrom: {database.installationSettings, database.syncOutbox},
      )
      .watchSingle()
      .map(
        (row) => SyncStatusModel(
          state: _status(row.read<String>('sync_status')),
          pendingOperations: row.read<int>('pending'),
          lastSyncAt: row.readNullable<DateTime>('last_sync_at'),
          error: row.readNullable<String>('sync_error'),
        ),
      );

  Future<InstallationSetting> settings() async {
    await _ensureSettings();
    return database.select(database.installationSettings).getSingle();
  }

  Future<void> setStatus(
    String status, {
    String? error,
    bool success = false,
  }) async {
    await _ensureSettings();
    await database
        .update(database.installationSettings)
        .write(
          InstallationSettingsCompanion(
            syncStatus: Value(status),
            syncError: Value(error),
            lastSyncAt: success
                ? Value(DateTime.now().toUtc())
                : const Value.absent(),
          ),
        );
  }

  Future<void> markAttemptFailed(String operationId, Object error) async {
    await (database.update(
      database.syncOutbox,
    )..where((row) => row.operationId.equals(operationId))).write(
      SyncOutboxCompanion(
        attempts: const Value.absent(),
        lastError: Value(error.toString()),
        nextAttemptAt: Value(
          DateTime.now().toUtc().add(const Duration(seconds: 15)),
        ),
      ),
    );
    await database.customStatement(
      'UPDATE sync_outbox SET attempts = attempts + 1 WHERE operation_id = ?',
      [operationId],
    );
  }

  Future<void> _ensureSettings() async {
    final existing = await database
        .select(database.installationSettings)
        .getSingleOrNull();
    if (existing != null) return;
    final now = DateTime.now().toUtc();
    await database
        .into(database.installationSettings)
        .insert(
          InstallationSettingsCompanion.insert(
            installationId: _uuid.v4(),
            createdAt: now,
            updatedAtLocal: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
}

SyncConnectionState _status(String value) => switch (value) {
  'synced' => SyncConnectionState.synced,
  'syncing' => SyncConnectionState.syncing,
  'pending' => SyncConnectionState.pending,
  'error' => SyncConnectionState.error,
  _ => SyncConnectionState.offline,
};
