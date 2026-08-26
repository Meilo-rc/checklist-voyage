import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import 'shared_document_remote.dart';
import 'sync_models.dart';

class SharedDocumentSyncStore {
  SharedDocumentSyncStore(this.database, {this.enabled = true});

  final AppDatabase database;
  final bool enabled;
  final Uuid _uuid = const Uuid();

  Future<InstallationSetting> installation() =>
      database.select(database.installationSettings).getSingle();

  Future<void> registerCreator(RemoteDocumentAccess access) async {
    await database.transaction(() async {
      if (access.documentType == 'trip') {
        final trip = await (database.select(
          database.trips,
        )..where((row) => row.id.equals(access.documentId))).getSingle();
        if (trip.shareState != 'local' && trip.shareState != 'shared') {
          throw StateError('État de voyage incompatible.');
        }
        await (database.update(
          database.trips,
        )..where((row) => row.id.equals(access.documentId))).write(
          TripsCompanion(
            shareState: const Value('shared'),
            remoteRecordId: Value(access.documentId),
            shareCode: Value(access.shareCode),
            remoteRevision: Value(access.revision),
          ),
        );
      } else if (access.documentType == 'quick_list') {
        final list = await (database.select(
          database.quickLists,
        )..where((row) => row.id.equals(access.documentId))).getSingle();
        if (list.shareState != 'local' && list.shareState != 'shared') {
          throw StateError('État de liste incompatible.');
        }
        await (database.update(
          database.quickLists,
        )..where((row) => row.id.equals(access.documentId))).write(
          QuickListsCompanion(
            shareState: const Value('shared'),
            remoteRecordId: Value(access.documentId),
            shareCode: Value(access.shareCode),
            remoteRevision: Value(access.revision),
          ),
        );
      } else {
        throw ArgumentError.value(access.documentType, 'documentType');
      }
      await _storeAccess(access);
    });
  }

  Future<void> registerJoin(RemoteDocumentAccess access) async {
    await database.transaction(() async {
      if (access.documentType == 'trip') {
        final existing = await (database.select(
          database.trips,
        )..where((row) => row.id.equals(access.documentId))).getSingleOrNull();
        if (existing != null && existing.shareState == 'local') {
          throw StateError('Collision avec un voyage local.');
        }
      } else if (access.documentType == 'quick_list') {
        final existing = await (database.select(
          database.quickLists,
        )..where((row) => row.id.equals(access.documentId))).getSingleOrNull();
        if (existing != null && existing.shareState == 'local') {
          throw StateError('Collision avec une liste locale.');
        }
      } else {
        throw ArgumentError.value(access.documentType, 'documentType');
      }
      await _storeAccess(access);
    });
  }

  Future<void> _storeAccess(RemoteDocumentAccess access) async {
    await database
        .into(database.syncDocuments)
        .insertOnConflictUpdate(
          SyncDocumentsCompanion.insert(
            documentId: access.documentId,
            documentType: access.documentType,
            remoteRecordId: Value(access.documentId),
            shareCode: Value(access.shareCode),
            capabilityToken: Value(access.capabilityToken),
            confirmedRevision: Value(access.revision),
            pullCursor: const Value(0),
          ),
        );
  }

  Future<List<SyncDocument>> sharedDocuments() =>
      database.select(database.syncDocuments).get();

  Future<SyncDocument> document(String documentId) => (database.select(
    database.syncDocuments,
  )..where((row) => row.documentId.equals(documentId))).getSingle();

  Future<void> ensureBootstrapQueued(String documentId) async {
    if (!enabled) return;
    final document = await this.document(documentId);
    final entities = document.documentType == 'trip'
        ? await _tripEntities(documentId)
        : await _quickListEntities(documentId);
    for (final entity in entities) {
      final known =
          await (database.select(database.syncEntityStates)..where(
                (row) =>
                    row.entityType.equals(entity.$1) &
                    row.entityId.equals(entity.$2),
              ))
              .getSingleOrNull();
      if (known == null) await recordUpsert(documentId, entity.$1, entity.$2);
    }
  }

  Future<List<(String, String)>> _tripEntities(String tripId) async {
    final rows = await database
        .customSelect(
          '''
          SELECT 0 AS rank, 'trip' AS entity_type, id AS entity_id
          FROM trips WHERE id = ? AND deleted_at IS NULL
          UNION ALL
          SELECT 1, 'trip_member', id FROM trip_members
          WHERE trip_id = ? AND deleted_at IS NULL
          UNION ALL
          SELECT 2, 'trip_category', id FROM trip_categories
          WHERE trip_id = ? AND deleted_at IS NULL
          UNION ALL
          SELECT 3, 'trip_item', id FROM trip_items
          WHERE trip_id = ? AND deleted_at IS NULL
          UNION ALL
          SELECT 4, 'trip_choice', id FROM trip_generation_choices
          WHERE trip_id = ? AND deleted_at IS NULL
            AND choice_kind <> 'personal_category'
          ORDER BY rank, entity_id
        ''',
          variables: List.generate(5, (_) => Variable.withString(tripId)),
          readsFrom: {
            database.trips,
            database.tripMembers,
            database.tripCategories,
            database.tripItems,
            database.tripGenerationChoices,
          },
        )
        .get();
    return rows
        .map(
          (row) =>
              (row.read<String>('entity_type'), row.read<String>('entity_id')),
        )
        .toList(growable: false);
  }

  Future<List<(String, String)>> _quickListEntities(String listId) async {
    final rows = await database
        .customSelect(
          '''
          SELECT 0 AS rank, 'quick_list' AS entity_type, id AS entity_id
          FROM quick_lists WHERE id = ? AND deleted_at IS NULL
          UNION ALL
          SELECT 1, 'quick_list_item', id FROM quick_list_items
          WHERE quick_list_id = ? AND deleted_at IS NULL
          ORDER BY rank, entity_id
        ''',
          variables: [Variable.withString(listId), Variable.withString(listId)],
          readsFrom: {database.quickLists, database.quickListItems},
        )
        .get();
    return rows
        .map(
          (row) =>
              (row.read<String>('entity_type'), row.read<String>('entity_id')),
        )
        .toList(growable: false);
  }

  Future<bool> recordUpsert(
    String documentId,
    String entityType,
    String entityId,
  ) async {
    if (!enabled || !await _belongsTo(documentId, entityType, entityId)) {
      return false;
    }
    return _record(
      documentId,
      entityType,
      entityId,
      'upsert',
      await payloadFor(entityType, entityId),
    );
  }

  Future<bool> recordDelete(
    String documentId,
    String entityType,
    String entityId, [
    Map<String, Object?> payload = const {},
  ]) async {
    if (!enabled || !await _hasSharedDocument(documentId)) return false;
    return _record(documentId, entityType, entityId, 'delete', payload);
  }

  Future<bool> _record(
    String documentId,
    String entityType,
    String entityId,
    String operationType,
    Map<String, Object?> payload,
  ) async {
    final settings = await installation();
    final document = await this.document(documentId);
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
            documentId: documentId,
            entityType: entityType,
            entityId: entityId,
            operationType: operationType,
            payloadJson: jsonEncode(payload),
            libraryId: Value(documentId),
            installationId: Value(settings.installationId),
            clientSequence: Value(settings.nextOperationSequence),
            clientCounter: Value(counter),
            baseRevision: Value(document.pullCursor),
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

  Future<bool> _hasSharedDocument(String documentId) async {
    final row = await (database.select(
      database.syncDocuments,
    )..where((entry) => entry.documentId.equals(documentId))).getSingleOrNull();
    return row?.capabilityToken?.isNotEmpty ?? false;
  }

  Future<bool> _belongsTo(
    String documentId,
    String entityType,
    String entityId,
  ) async {
    if (!await _hasSharedDocument(documentId)) return false;
    final sql = switch (entityType) {
      'trip' => 'SELECT COUNT(*) AS count FROM trips WHERE id = ? AND id = ?',
      'trip_member' =>
        'SELECT COUNT(*) AS count FROM trip_members WHERE id = ? AND trip_id = ?',
      'trip_category' =>
        'SELECT COUNT(*) AS count FROM trip_categories WHERE id = ? AND trip_id = ?',
      'trip_item' =>
        'SELECT COUNT(*) AS count FROM trip_items WHERE id = ? AND trip_id = ?',
      'trip_choice' =>
        'SELECT COUNT(*) AS count FROM trip_generation_choices '
            "WHERE id = ? AND trip_id = ? AND choice_kind <> 'personal_category'",
      'quick_list' =>
        'SELECT COUNT(*) AS count FROM quick_lists WHERE id = ? AND id = ?',
      'quick_list_item' =>
        'SELECT COUNT(*) AS count FROM quick_list_items WHERE id = ? AND quick_list_id = ?',
      _ => 'SELECT 0 AS count',
    };
    final row = await database
        .customSelect(
          sql,
          variables: [
            Variable.withString(entityId),
            Variable.withString(documentId),
          ],
        )
        .getSingle();
    return row.read<int>('count') == 1;
  }

  Future<Map<String, Object?>> payloadFor(
    String entityType,
    String entityId,
  ) async {
    switch (entityType) {
      case 'trip':
        final row = await (database.select(
          database.trips,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        return {
          'name': row.name,
          'destination_json': row.destinationJson,
          'start_date': row.startDate?.toIso8601String(),
          'end_date': row.endDate?.toIso8601String(),
          'archived_at': row.archivedAt?.toIso8601String(),
        };
      case 'trip_member':
        final row = await (database.select(
          database.tripMembers,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        final personal = row.groupKind == 'personal';
        return {
          'trip_id': row.tripId,
          'group_kind': row.groupKind,
          'name': personal ? 'Personnel' : row.name,
          'icon': personal ? null : row.icon,
        };
      case 'trip_category':
        final row = await (database.select(
          database.tripCategories,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        final personalSource = await _isPersonalSourceCategory(
          row.sourceCategoryId,
        );
        return {
          'trip_id': row.tripId,
          'member_id': row.memberId,
          'name': personalSource ? 'Divers' : row.name,
          'icon': personalSource ? null : row.icon,
        };
      case 'trip_item':
        final row = await (database.select(
          database.tripItems,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        return {
          'trip_id': row.tripId,
          'category_id': row.categoryId,
          'name': row.name,
          'quantity': row.quantity,
          'status': row.status,
          'sources': await _shareableSources(entityId),
        };
      case 'trip_choice':
        final row = await (database.select(
          database.tripGenerationChoices,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        return {
          'trip_id': row.tripId,
          'choice_kind': row.choiceKind,
          'choice_id': row.choiceId,
        };
      case 'quick_list':
        final row = await (database.select(
          database.quickLists,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        return {
          'name': row.name,
          'icon': row.icon,
          'archived_at': row.archivedAt?.toIso8601String(),
        };
      case 'quick_list_item':
        final row = await (database.select(
          database.quickListItems,
        )..where((entry) => entry.id.equals(entityId))).getSingle();
        return {
          'quick_list_id': row.quickListId,
          'name': row.name,
          'quantity': row.quantity,
          'is_checked': row.isChecked,
        };
      default:
        throw ArgumentError.value(entityType, 'entityType');
    }
  }

  Future<List<Map<String, Object?>>> _shareableSources(
    String tripItemId,
  ) async {
    final rows = await database
        .customSelect(
          '''
          SELECT s.source_library_item_id, s.source_kind, s.reason_kind,
            s.reason_id, s.contributing_library_item_id
          FROM trip_item_sources s
          JOIN library_items i ON i.id = s.contributing_library_item_id
          JOIN library_categories c ON c.id = i.category_id
          JOIN library_owners o ON o.id = c.owner_id
          WHERE s.trip_item_id = ? AND o.sync_scope = 'shared_library'
        ''',
          variables: [Variable.withString(tripItemId)],
          readsFrom: {
            database.tripItemSources,
            database.libraryItems,
            database.libraryCategories,
            database.libraryOwners,
          },
        )
        .get();
    return rows
        .map(
          (row) => <String, Object?>{
            'source_scope': 'shared_library',
            'logical_source_id': row.read<String>('source_library_item_id'),
            'source_kind': row.read<String>('source_kind'),
            'reason_kind': row.read<String>('reason_kind'),
            'reason_id': row.read<String>('reason_id'),
            'contributing_library_item_id': row.readNullable<String>(
              'contributing_library_item_id',
            ),
          },
        )
        .toList(growable: false);
  }

  Future<bool> _isPersonalSourceCategory(String? categoryId) async {
    if (categoryId == null) return false;
    final row = await database
        .customSelect(
          '''
      SELECT COUNT(*) AS count
      FROM library_categories c
      JOIN library_owners o ON o.id = c.owner_id
      WHERE c.id = ? AND o.sync_scope = 'personal_local'
    ''',
          variables: [Variable.withString(categoryId)],
          readsFrom: {database.libraryCategories, database.libraryOwners},
        )
        .getSingle();
    return row.read<int>('count') == 1;
  }

  Future<List<SyncOperation>> pendingOperations(String documentId) async {
    final rows =
        await (database.select(database.syncOutbox)
              ..where((row) => row.documentId.equals(documentId))
              ..orderBy([(row) => OrderingTerm.asc(row.clientSequence)]))
            .get();
    return rows.map(_operationFromRow).toList(growable: false);
  }

  SyncOperation _operationFromRow(SyncOutboxData row) => SyncOperation(
    operationId: row.operationId,
    libraryId: row.documentId,
    deviceId: row.installationId,
    clientSequence: row.clientSequence,
    clientCounter: row.clientCounter,
    baseRevision: row.baseRevision ?? 0,
    entityType: row.entityType,
    entityId: row.entityId,
    operationType: row.operationType,
    payload: Map<String, Object?>.from(jsonDecode(row.payloadJson) as Map),
  );

  Future<void> markPushConfirmed(RemoteOperation remote) async {
    await database.transaction(() async {
      await (database.delete(database.syncOutbox)..where(
            (row) => row.operationId.equals(remote.operation.operationId),
          ))
          .go();
      await _recordRemoteMetadata(remote);
      if (remote.operation.isDelete) {
        await (database.update(database.syncTombstones)..where(
              (row) =>
                  row.entityType.equals(remote.operation.entityType) &
                  row.entityId.equals(remote.operation.entityId),
            ))
            .write(
              SyncTombstonesCompanion(
                propagatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    });
  }

  Future<void> applyPullPage(String documentId, SyncPullPage page) async {
    await database.transaction(() async {
      for (final remote in page.operations) {
        if (remote.applied) await _apply(remote.operation);
        await _recordRemoteMetadata(remote);
        if (!remote.applied) await _recordConflict(remote);
      }
      await (database.update(
        database.syncDocuments,
      )..where((row) => row.documentId.equals(documentId))).write(
        SyncDocumentsCompanion(
          pullCursor: Value(page.cursor),
          confirmedRevision: Value(page.cursor),
          lastSyncedAt: Value(DateTime.now().toUtc()),
          lastError: const Value(null),
        ),
      );
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
              current == null || op.clientCounter > current.clientCounter
                  ? op.clientCounter
                  : current.clientCounter,
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
      case 'trip':
        final document = await this.document(op.libraryId);
        await database
            .into(database.trips)
            .insertOnConflictUpdate(
              TripsCompanion.insert(
                id: op.entityId,
                name: p['name']! as String,
                destinationJson: Value(p['destination_json'] as String?),
                startDate: Value(_date(p['start_date'])),
                endDate: Value(_date(p['end_date'])),
                archivedAt: Value(_date(p['archived_at'])),
                shareState: const Value('shared'),
                remoteRecordId: Value(op.libraryId),
                shareCode: Value(document.shareCode),
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
      case 'trip_member':
        await database
            .into(database.tripMembers)
            .insertOnConflictUpdate(
              TripMembersCompanion.insert(
                id: op.entityId,
                tripId: p['trip_id']! as String,
                sourceOwnerId: const Value(null),
                groupKind: p['group_kind']! as String,
                name: p['name']! as String,
                icon: Value(p['icon'] as String?),
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
      case 'trip_category':
        await database
            .into(database.tripCategories)
            .insertOnConflictUpdate(
              TripCategoriesCompanion.insert(
                id: op.entityId,
                tripId: p['trip_id']! as String,
                memberId: Value(p['member_id'] as String?),
                sourceCategoryId: const Value(null),
                name: p['name']! as String,
                icon: Value(p['icon'] as String?),
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
      case 'trip_item':
        await database
            .into(database.tripItems)
            .insertOnConflictUpdate(
              TripItemsCompanion.insert(
                id: op.entityId,
                tripId: p['trip_id']! as String,
                categoryId: p['category_id']! as String,
                name: p['name']! as String,
                quantity: Value((p['quantity'] as num).toInt().clamp(1, 99)),
                status: Value(p['status']! as String),
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
        await (database.delete(
          database.tripItemSources,
        )..where((row) => row.tripItemId.equals(op.entityId))).go();
        for (final raw in (p['sources'] as List? ?? const [])) {
          final source = Map<String, Object?>.from(raw as Map);
          await database
              .into(database.tripItemSources)
              .insert(
                TripItemSourcesCompanion.insert(
                  tripItemId: op.entityId,
                  sourceLibraryItemId: source['logical_source_id']! as String,
                  sourceKind: source['source_kind']! as String,
                  reasonKind: Value(source['reason_kind']! as String),
                  reasonId: Value(source['reason_id']! as String),
                  contributingLibraryItemId: Value(
                    source['contributing_library_item_id'] as String?,
                  ),
                ),
              );
        }
      case 'trip_choice':
        await database
            .into(database.tripGenerationChoices)
            .insertOnConflictUpdate(
              TripGenerationChoicesCompanion.insert(
                id: op.entityId,
                tripId: p['trip_id']! as String,
                choiceKind: p['choice_kind']! as String,
                choiceId: p['choice_id']! as String,
                createdAt: now,
                deletedAt: const Value(null),
              ),
            );
      case 'quick_list':
        final document = await this.document(op.libraryId);
        final currentList = await (database.select(
          database.quickLists,
        )..where((row) => row.id.equals(op.entityId))).getSingleOrNull();
        await database
            .into(database.quickLists)
            .insertOnConflictUpdate(
              QuickListsCompanion.insert(
                id: op.entityId,
                name: p['name']! as String,
                icon: Value(
                  (p['icon'] as String?) ?? currentList?.icon ?? 'liste',
                ),
                archivedAt: Value(_date(p['archived_at'])),
                shareState: const Value('shared'),
                remoteRecordId: Value(op.libraryId),
                shareCode: Value(document.shareCode),
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
      case 'quick_list_item':
        await database
            .into(database.quickListItems)
            .insertOnConflictUpdate(
              QuickListItemsCompanion.insert(
                id: op.entityId,
                quickListId: p['quick_list_id']! as String,
                name: p['name']! as String,
                quantity: Value((p['quantity'] as num).toInt().clamp(1, 99)),
                isChecked: Value(p['is_checked']! as bool),
                createdAt: now,
                updatedAtLocal: now,
                deletedAt: const Value(null),
              ),
            );
    }
  }

  Future<void> _softDelete(String type, String id, DateTime now) async {
    switch (type) {
      case 'trip':
        await (database.update(
          database.trips,
        )..where((row) => row.id.equals(id))).write(
          TripsCompanion(deletedAt: Value(now), updatedAtLocal: Value(now)),
        );
      case 'trip_member':
        await (database.update(
          database.tripMembers,
        )..where((row) => row.id.equals(id))).write(
          TripMembersCompanion(
            deletedAt: Value(now),
            updatedAtLocal: Value(now),
          ),
        );
      case 'trip_category':
        await (database.update(
          database.tripCategories,
        )..where((row) => row.id.equals(id))).write(
          TripCategoriesCompanion(
            deletedAt: Value(now),
            updatedAtLocal: Value(now),
          ),
        );
      case 'trip_item':
        await (database.update(
          database.tripItems,
        )..where((row) => row.id.equals(id))).write(
          TripItemsCompanion(deletedAt: Value(now), updatedAtLocal: Value(now)),
        );
      case 'trip_choice':
        await (database.update(database.tripGenerationChoices)
              ..where((row) => row.id.equals(id)))
            .write(TripGenerationChoicesCompanion(deletedAt: Value(now)));
      case 'quick_list':
        await (database.update(
          database.quickLists,
        )..where((row) => row.id.equals(id))).write(
          QuickListsCompanion(
            deletedAt: Value(now),
            updatedAtLocal: Value(now),
          ),
        );
      case 'quick_list_item':
        await (database.update(
          database.quickListItems,
        )..where((row) => row.id.equals(id))).write(
          QuickListItemsCompanion(
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

  Future<void> markError(String documentId, Object error) =>
      (database.update(database.syncDocuments)
            ..where((row) => row.documentId.equals(documentId)))
          .write(SyncDocumentsCompanion(lastError: Value(error.toString())));
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString())?.toUtc();
