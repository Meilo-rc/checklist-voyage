import 'package:drift/drift.dart';

import '../../domain/models/destination_summaries.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/repositories/quick_list_repository.dart';
import '../../domain/repositories/trip_repository.dart';
import '../local/app_database.dart';

class DriftTripRepository implements TripRepository {
  const DriftTripRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<TripSummary>> watchTrips() {
    final query = _database.select(_database.trips)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAtLocal)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => TripSummary(
              id: row.id,
              name: row.name,
              shared: row.shareState == 'shared',
            ),
          )
          .toList(growable: false),
    );
  }
}

class DriftLibraryRepository implements LibraryRepository {
  const DriftLibraryRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<LibraryOwnerSummary>> watchOwners() {
    final query = _database.select(_database.libraryOwners)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => LibraryOwnerSummary(
              id: row.id,
              name: row.name,
              personal: row.syncScope == 'personal_local',
            ),
          )
          .toList(growable: false),
    );
  }
}

class DriftQuickListRepository implements QuickListRepository {
  const DriftQuickListRepository(this._database);

  final AppDatabase _database;

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
}
