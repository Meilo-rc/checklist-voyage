import '../data/import/web_v263_importer.dart';
import '../data/local/app_database.dart';
import '../data/repositories/drift_library_repository.dart';
import '../data/repositories/drift_local_data_repository.dart';
import '../data/repositories/drift_quick_list_repository.dart';
import '../data/repositories/drift_trip_repository.dart';
import '../domain/repositories/local_data_repository.dart';
import '../domain/usecases/import_web_backup.dart';
import '../domain/usecases/library_use_cases.dart';
import '../domain/usecases/quick_list_use_cases.dart';
import '../domain/usecases/trip_use_cases.dart';
import '../domain/usecases/watch_destinations.dart';

class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.localData,
    required this.importWebBackup,
    required this.watchTrips,
    required this.watchLibraryOwners,
    required this.watchQuickLists,
    required this.library,
    required this.trips,
    required this.quickLists,
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

  static Future<AppDependencies> create({AppDatabase? database}) async {
    final db = database ?? AppDatabase.open();
    final localData = DriftLocalDataRepository(db);
    await localData.ensureInstallationId();
    final tripRepository = DriftTripRepository(db);
    final libraryRepository = DriftLibraryRepository(db);
    final quickListRepository = DriftQuickListRepository(db);
    return AppDependencies._(
      database: db,
      localData: localData,
      importWebBackup: ImportWebBackup(WebV263Importer(db)),
      watchTrips: WatchTrips(tripRepository),
      watchLibraryOwners: WatchLibraryOwners(libraryRepository),
      watchQuickLists: WatchQuickLists(quickListRepository),
      library: LibraryUseCases(libraryRepository),
      trips: TripUseCases(tripRepository, libraryRepository),
      quickLists: QuickListUseCases(quickListRepository),
    );
  }

  Future<void> close() => database.close();
}
