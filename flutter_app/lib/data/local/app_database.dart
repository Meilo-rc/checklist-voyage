import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class InstallationSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('current'))();
  TextColumn get installationId => text().unique()();
  TextColumn get futureUserId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAtLocal => dateTime()();

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
  DateTimeColumn get createdAt => dateTime()();
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

  @override
  Set<Column<Object>> get primaryKey => {
    tripItemId,
    sourceLibraryItemId,
    sourceKind,
  };
}

class QuickLists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
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
    QuickLists,
    QuickListItems,
    SyncDocuments,
    SyncOutbox,
    SyncConflicts,
    SyncTombstones,
    LegacyIdMaps,
    MigrationHistory,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() {
    return AppDatabase(
      driftDatabase(
        name: 'checklist_voyage_v1',
        native: const DriftNativeOptions(shareAcrossIsolates: true),
      ),
    );
  }

  @override
  int get schemaVersion => 3;

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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
