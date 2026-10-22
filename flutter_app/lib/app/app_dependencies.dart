import 'dart:async';

import '../core/sharing/share_invitation.dart';
import '../data/backup/safety_backup_file_gateway.dart';
import '../data/backup/v1_safety_backup_service.dart';
import '../data/import/web_v263_importer.dart';
import '../data/local/app_database.dart';
import '../data/local/open_app_database.dart';
import '../data/repositories/drift_library_repository.dart';
import '../data/repositories/drift_local_data_repository.dart';
import '../data/repositories/drift_context_repository.dart';
import '../data/repositories/drift_quick_list_repository.dart';
import '../data/repositories/drift_trip_repository.dart';
import '../data/weather/open_meteo_remote.dart';
import '../data/weather/weather_cache_store.dart';
import '../domain/repositories/local_data_repository.dart';
import '../domain/usecases/import_web_backup.dart';
import '../domain/usecases/context_use_cases.dart';
import '../domain/usecases/library_use_cases.dart';
import '../domain/usecases/quick_list_use_cases.dart';
import '../domain/usecases/trip_use_cases.dart';
import '../domain/usecases/watch_destinations.dart';
import '../domain/weather/trip_weather_service.dart';
import '../domain/usecases/shared_document_use_cases.dart';
import '../sync/library_sync_coordinator.dart';
import '../sync/library_sync_store.dart';
import '../sync/pocketbase_sync_remote.dart';
import '../sync/sync_remote_gateway.dart';
import '../sync/pocketbase_shared_document_remote.dart';
import '../sync/shared_document_remote.dart';
import '../sync/shared_document_sync_coordinator.dart';
import '../sync/shared_document_sync_store.dart';

class AppDependencies {
  AppDependencies._(
    this._documentSync, {
    required this.database,
    required this.localData,
    required this.importWebBackup,
    required this.watchTrips,
    required this.watchLibraryOwners,
    required this.watchQuickLists,
    required this.library,
    required this.trips,
    required this.quickLists,
    required this.contexts,
    required this.librarySync,
    required this.sharedDocuments,
    required this.shareInvitations,
    required this.safetyBackup,
    required this.safetyBackupFiles,
    required this.weather,
  });

  final AppDatabase database;
  final LocalDataRepository localData;
  final ImportWebBackup importWebBackup;
  final WatchTrips watchTrips;
  final WatchLibraryOwners watchLibraryOwners;
  final WatchQuickLists watchQuickLists;
  final LibraryUseCases library;
  final TripUseCases trips;
  final QuickListUseCases quickLists;
  final ContextUseCases contexts;
  final LibrarySyncCoordinator librarySync;
  final SharedDocumentUseCases sharedDocuments;
  final ShareInvitationGateway shareInvitations;
  final V1SafetyBackupService safetyBackup;
  final SafetyBackupFileGateway safetyBackupFiles;
  final TripWeatherService weather;
  final SharedDocumentSyncCoordinator _documentSync;

  void setDocumentSyncForeground(bool foreground) =>
      _documentSync.setForeground(foreground);

  static Future<AppDependencies> create({
    AppDatabase? database,
    SyncRemoteGateway? syncRemote,
    SharedDocumentRemoteGateway? documentRemote,
    ShareInvitationGateway? shareInvitations,
    bool? autoSync,
    TripWeatherService? weather,
  }) async {
    final db = database ?? openAppDatabase();
    final localData = DriftLocalDataRepository(db);
    await localData.ensureInstallationId();
    final syncStore = LibrarySyncStore(db);
    final documentStore = SharedDocumentSyncStore(db);
    final librarySync = LibrarySyncCoordinator(
      syncStore,
      syncRemote ?? PocketBaseSyncRemote(),
    );
    final documentSync = SharedDocumentSyncCoordinator(
      documentStore,
      documentRemote ?? PocketBaseSharedDocumentRemote(),
    );
    documentStore.onTripOperationQueued = documentSync.scheduleDocumentSync;
    final tripRepository = DriftTripRepository(db, syncStore: documentStore);
    final libraryRepository = DriftLibraryRepository(db, syncStore: syncStore);
    final contextRepository = DriftContextRepository(db, syncStore: syncStore);
    final quickListRepository = DriftQuickListRepository(
      db,
      syncStore: documentStore,
    );
    final weatherService =
        weather ??
        (database == null
            ? TripWeatherService(OpenMeteoRemote(), JsonFileWeatherCacheStore())
            : TripWeatherService(
                const UnavailableWeatherRemote(),
                MemoryWeatherCacheStore(),
              ));
    final dependencies = AppDependencies._(
      documentSync,
      database: db,
      localData: localData,
      importWebBackup: ImportWebBackup(WebV263Importer(db)),
      watchTrips: WatchTrips(tripRepository),
      watchLibraryOwners: WatchLibraryOwners(libraryRepository),
      watchQuickLists: WatchQuickLists(quickListRepository),
      library: LibraryUseCases(libraryRepository),
      trips: TripUseCases(tripRepository, libraryRepository, contextRepository),
      quickLists: QuickListUseCases(quickListRepository),
      contexts: ContextUseCases(contextRepository),
      librarySync: librarySync,
      sharedDocuments: SharedDocumentUseCases(documentSync),
      shareInvitations:
          shareInvitations ??
          (database == null
              ? AndroidShareInvitationGateway()
              : const UnavailableShareInvitationGateway()),
      safetyBackup: V1SafetyBackupService(db),
      safetyBackupFiles: const SafetyBackupFileGateway(),
      weather: weatherService,
    );
    if (autoSync ?? database == null) {
      unawaited(librarySync.syncNow());
      unawaited(documentSync.syncAll().catchError((Object _) {}));
    }
    return dependencies;
  }

  Future<void> close() async {
    await _documentSync.close();
    weather.close();
    await shareInvitations.close();
    await database.close();
  }
}
