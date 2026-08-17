import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/app_snapshot.dart';
import '../../domain/repositories/local_data_repository.dart';
import '../local/app_database.dart';

class DriftLocalDataRepository implements LocalDataRepository {
  DriftLocalDataRepository(this._database, {this._uuid = const Uuid()});

  final AppDatabase _database;
  final Uuid _uuid;

  @override
  Future<String> ensureInstallationId() async {
    final existing = await (_database.select(
      _database.installationSettings,
    )..where((row) => row.id.equals('current'))).getSingleOrNull();
    if (existing != null) return existing.installationId;

    final now = DateTime.now().toUtc();
    final installationId = _uuid.v4();
    await _database
        .into(_database.installationSettings)
        .insert(
          InstallationSettingsCompanion.insert(
            installationId: installationId,
            createdAt: now,
            updatedAtLocal: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return getInstallationId();
  }

  @override
  Future<String> getInstallationId() async {
    final row = await (_database.select(
      _database.installationSettings,
    )..where((entry) => entry.id.equals('current'))).getSingle();
    return row.installationId;
  }

  @override
  Stream<AppSnapshot> watchSnapshot() {
    final query = _database.customSelect(
      '''
      SELECT
        (SELECT COUNT(*) FROM trips WHERE deleted_at IS NULL) AS trip_count,
        (SELECT COUNT(*) FROM library_owners WHERE deleted_at IS NULL) AS owner_count,
        (SELECT COUNT(*) FROM library_items WHERE deleted_at IS NULL) AS item_count,
        (SELECT COUNT(*) FROM quick_lists WHERE deleted_at IS NULL) AS quick_count
      ''',
      readsFrom: {
        _database.trips,
        _database.libraryOwners,
        _database.libraryItems,
        _database.quickLists,
      },
    );
    return query.watchSingle().map(
      (row) => AppSnapshot(
        tripCount: row.read<int>('trip_count'),
        libraryOwnerCount: row.read<int>('owner_count'),
        libraryItemCount: row.read<int>('item_count'),
        quickListCount: row.read<int>('quick_count'),
      ),
    );
  }
}
