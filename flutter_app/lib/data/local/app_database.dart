import 'package:drift/drift.dart';

part 'app_database.g.dart';

class InstallationSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('current'))();
  TextColumn get installationId => text().unique()();
  TextColumn get futureUserId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  TextColumn get libraryId => text().withDefault(
    const Constant('6d0f0d44-54f8-4f6a-b535-0a58d6efac11'),
  )();
  IntColumn get nextOperationSequence =>
      integer().withDefault(const Constant(1))();
  IntColumn get pullCursor => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('offline'))();
  TextColumn get syncError => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LibraryOwners extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get syncScope => text()();
  TextColumn get generationRole =>
      text().withDefault(const Constant('general'))();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get linkedParticipantOwnerId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LibraryCategories extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().references(LibraryOwners, #id)();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LibraryItems extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(LibraryCategories, #id)();
  TextColumn get name => text()();
  IntColumn get defaultQuantity => integer().withDefault(const Constant(1))();
  TextColumn get logicalSourceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Contexts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get syncScope => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LibraryItemContexts extends Table {
  TextColumn get itemId => text().references(LibraryItems, #id)();
  TextColumn get contextId => text().references(Contexts, #id)();
  TextColumn get associationId => text().nullable()();
  TextColumn get syncScope =>
      text().withDefault(const Constant('shared_library'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {itemId, contextId};
}

class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get destinationJson => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  TextColumn get shareState => text().withDefault(const Constant('local'))();
  TextColumn get remoteRecordId => text().nullable().unique()();
  TextColumn get shareCode => text().nullable().unique()();
  IntColumn get remoteRevision => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TripMembers extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)();
  TextColumn get sourceOwnerId => text().nullable()();
  TextColumn get groupKind => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TripCategories extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)();
  TextColumn get memberId => text().nullable().references(TripMembers, #id)();
  TextColumn get sourceCategoryId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TripItems extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)();
  TextColumn get categoryId => text().references(TripCategories, #id)();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(const Constant('todo'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TripItemSources extends Table {
  TextColumn get tripItemId => text().references(TripItems, #id)();
  TextColumn get sourceLibraryItemId => text()();
  TextColumn get sourceKind => text()();
  TextColumn get reasonKind => text().withDefault(const Constant('legacy'))();
  TextColumn get reasonId => text().withDefault(const Constant(''))();
  TextColumn get contributingLibraryItemId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {
    tripItemId,
    sourceLibraryItemId,
    sourceKind,
  };
}

class TripGenerationChoices extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)();
  TextColumn get choiceKind => text()();
  TextColumn get choiceId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {tripId, choiceKind, choiceId},
  ];
}

class QuickLists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get shareState => text().withDefault(const Constant('local'))();
  TextColumn get remoteRecordId => text().nullable().unique()();
  TextColumn get shareCode => text().nullable().unique()();
  IntColumn get remoteRevision => integer().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class QuickListItems extends Table {
  TextColumn get id => text()();
  TextColumn get quickListId => text().references(QuickLists, #id)();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncDocuments extends Table {
  TextColumn get documentId => text()();
  TextColumn get documentType => text()();
  TextColumn get remoteRecordId => text().nullable()();
  TextColumn get shareCode => text().nullable()();
  TextColumn get capabilityToken => text().nullable()();
  IntColumn get pullCursor => integer().withDefault(const Constant(0))();
  IntColumn get confirmedRevision => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {documentId};
}

class SyncOutbox extends Table {
  TextColumn get operationId => text()();
  TextColumn get documentId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operationType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get libraryId => text().withDefault(
    const Constant('6d0f0d44-54f8-4f6a-b535-0a58d6efac11'),
  )();
  TextColumn get installationId => text().withDefault(const Constant(''))();
  IntColumn get clientSequence => integer().withDefault(const Constant(0))();
  IntColumn get clientCounter => integer().withDefault(const Constant(0))();
  IntColumn get baseRevision => integer().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {operationId};
}

class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get localJson => text().nullable()();
  TextColumn get remoteJson => text().nullable()();
  DateTimeColumn get detectedAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get resolution => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncTombstones extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  DateTimeColumn get deletedAt => dateTime()();
  DateTimeColumn get propagatedAt => dateTime().nullable()();
  DateTimeColumn get purgeEligibleAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {entityType, entityId};
}

class SyncEntityStates extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get clientCounter => integer().withDefault(const Constant(0))();
  IntColumn get serverRevision => integer().withDefault(const Constant(0))();
  TextColumn get winningDeviceId => text().nullable()();
  BoolColumn get remotelyDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {entityType, entityId};
}

class LegacyIdMaps extends Table {
  TextColumn get sourceKind => text()();
  TextColumn get sourceRecordId => text().withDefault(const Constant(''))();
  TextColumn get entityType => text()();
  TextColumn get legacyId => text()();
  TextColumn get v1Uuid => text().unique()();
  TextColumn get jsonPath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {
    sourceKind,
    sourceRecordId,
    entityType,
    legacyId,
  };
}

class MigrationHistory extends Table {
  TextColumn get id => text()();
  TextColumn get sourceKind => text()();
  TextColumn get sourceSha256 => text()();
  TextColumn get sourceSchema => text().nullable()();
  DateTimeColumn get importedAt => dateTime()();
  TextColumn get reportJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sourceKind, sourceSha256},
  ];
}

@DriftDatabase(
  tables: [
    InstallationSettings,
    LibraryOwners,
    LibraryCategories,
    LibraryItems,
    Contexts,
    LibraryItemContexts,
    Trips,
    TripMembers,
    TripCategories,
    TripItems,
    TripItemSources,
    TripGenerationChoices,
    QuickLists,
    QuickListItems,
    SyncDocuments,
    SyncOutbox,
    SyncConflicts,
    SyncTombstones,
    SyncEntityStates,
    LegacyIdMaps,
    MigrationHistory,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(installationSettings);
        await migrator.createTable(syncTombstones);
      }
      if (from < 3) {
        await migrator.addColumn(libraryOwners, libraryOwners.generationRole);
      }
      if (from < 4) {
        await migrator.addColumn(
          libraryOwners,
          libraryOwners.linkedParticipantOwnerId,
        );
        await migrator.addColumn(libraryItems, libraryItems.logicalSourceId);
        await migrator.addColumn(
          libraryItemContexts,
          libraryItemContexts.associationId,
        );
        await migrator.addColumn(
          libraryItemContexts,
          libraryItemContexts.syncScope,
        );
        await migrator.addColumn(
          libraryItemContexts,
          libraryItemContexts.updatedAtLocal,
        );
        await migrator.addColumn(tripItemSources, tripItemSources.reasonKind);
        await migrator.addColumn(tripItemSources, tripItemSources.reasonId);
        await migrator.addColumn(
          tripItemSources,
          tripItemSources.contributingLibraryItemId,
        );
        await migrator.createTable(tripGenerationChoices);
      }
      if (from < 5) {
        if (!await _tableExists('installation_settings')) {
          await migrator.createTable(installationSettings);
        } else {
          await _addColumnIfMissing(
            migrator,
            installationSettings,
            installationSettings.libraryId,
          );
          await _addColumnIfMissing(
            migrator,
            installationSettings,
            installationSettings.nextOperationSequence,
          );
          await _addColumnIfMissing(
            migrator,
            installationSettings,
            installationSettings.pullCursor,
          );
          await _addColumnIfMissing(
            migrator,
            installationSettings,
            installationSettings.syncStatus,
          );
          await _addColumnIfMissing(
            migrator,
            installationSettings,
            installationSettings.syncError,
          );
          await _addColumnIfMissing(
            migrator,
            installationSettings,
            installationSettings.lastSyncAt,
          );
        }
        if (!await _tableExists('sync_outbox')) {
          await migrator.createTable(syncOutbox);
        } else {
          await _addColumnIfMissing(migrator, syncOutbox, syncOutbox.libraryId);
          await _addColumnIfMissing(
            migrator,
            syncOutbox,
            syncOutbox.installationId,
          );
          await _addColumnIfMissing(
            migrator,
            syncOutbox,
            syncOutbox.clientSequence,
          );
          await _addColumnIfMissing(
            migrator,
            syncOutbox,
            syncOutbox.clientCounter,
          );
        }
        if (!await _tableExists('sync_entity_states')) {
          await migrator.createTable(syncEntityStates);
        }
      }
      if (from < 6) {
        if (!await _tableExists('sync_documents')) {
          await migrator.createTable(syncDocuments);
        } else {
          await _addColumnIfMissing(
            migrator,
            syncDocuments,
            syncDocuments.shareCode,
          );
          await _addColumnIfMissing(
            migrator,
            syncDocuments,
            syncDocuments.capabilityToken,
          );
          await _addColumnIfMissing(
            migrator,
            syncDocuments,
            syncDocuments.pullCursor,
          );
        }
      }
      if (from < 7) {
        if (await _tableExists('trips')) {
          await _addColumnIfMissing(migrator, trips, trips.archivedAt);
        }
        if (await _tableExists('quick_lists')) {
          await _addColumnIfMissing(
            migrator,
            quickLists,
            quickLists.archivedAt,
          );
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<bool> _tableExists(String name) async {
    final row = await customSelect(
      "SELECT COUNT(*) AS count FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(name)],
    ).getSingle();
    return row.read<int>('count') == 1;
  }

  Future<void> _addColumnIfMissing(
    Migrator migrator,
    TableInfo<Table, Object?> table,
    GeneratedColumn<Object> column,
  ) async {
    final rows = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    if (rows.any((row) => row.read<String>('name') == column.$name)) return;
    await migrator.addColumn(table, column);
  }
}
