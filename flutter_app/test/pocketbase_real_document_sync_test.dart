import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_quick_list_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/sync/pocketbase_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/shared_document_sync_coordinator.dart';
import 'package:checklist_voyage_v1/sync/shared_document_sync_store.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final baseUrl = Platform.environment['CHECKLIST_V1_PB_URL'];
  final skip = baseUrl == null
      ? 'Définir CHECKLIST_V1_PB_URL pour le test documentaire réel.'
      : false;

  test('voyage et liste réels convergent entre deux installations', () async {
    const uuid = Uuid();
    final remote = PocketBaseSharedDocumentRemote(baseUrl: baseUrl!);
    final a = await _RealInstallation.create(remote, uuid.v4());
    final b = await _RealInstallation.create(remote, uuid.v4());
    addTearDown(a.close);
    addTearDown(b.close);

    final trip = await _seedTrip(a.database);
    expect(await a.database.select(a.database.syncOutbox).get(), isEmpty);
    final tripAccess = await a.sync.shareTrip(trip.$1);
    await b.sync.join(tripAccess.shareCode);
    var copy = await b.trips.loadTrip(trip.$1);
    expect(
      copy!.members.single.categories.single.items.single.name,
      startsWith('Test réel'),
    );

    await a.trips.cycleItemStatus(trip.$2);
    await b.trips.changeItemQuantity(trip.$2, 2);
    await a.sync.syncAll();
    await b.sync.syncAll();
    await a.sync.syncAll();
    copy = await b.trips.loadTrip(trip.$1);
    expect(
      copy!.members.single.categories.single.items.single.quantity,
      greaterThanOrEqualTo(1),
    );

    await a.trips.removeItem(trip.$2);
    await a.sync.syncAll();
    await b.sync.syncAll();
    expect(
      (await b.trips.loadTrip(trip.$1))!.members.single.categories.single.items,
      isEmpty,
    );

    final listId = await a.quickLists.createQuickList('Test réel ${uuid.v4()}');
    final listItem = await a.quickLists.addItem(
      listId: listId,
      name: 'Élément réel',
      quantity: 2,
    );
    final listAccess = await a.sync.shareQuickList(listId);
    await b.sync.join(listAccess.shareCode);
    await b.quickLists.toggleItem(listItem);
    await b.sync.syncAll();
    await a.sync.syncAll();
    expect(
      (await a.quickLists.loadQuickList(listId))!.items.single.isChecked,
      isTrue,
    );

    final token = (await b.store.document(trip.$1)).capabilityToken!;
    final device = (await b.store.installation()).installationId;
    expect(
      remote.pullDocument(
        documentId: listId,
        deviceId: device,
        capabilityToken: token,
        afterRevision: 0,
      ),
      throwsA(anything),
    );
  }, skip: skip);
}

class _RealInstallation {
  _RealInstallation(
    this.database,
    this.store,
    this.sync,
    this.trips,
    this.quickLists,
  );

  final AppDatabase database;
  final SharedDocumentSyncStore store;
  final SharedDocumentSyncCoordinator sync;
  final DriftTripRepository trips;
  final DriftQuickListRepository quickLists;

  static Future<_RealInstallation> create(
    PocketBaseSharedDocumentRemote remote,
    String deviceId,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final now = DateTime.now().toUtc();
    await database
        .into(database.installationSettings)
        .insert(
          InstallationSettingsCompanion.insert(
            installationId: deviceId,
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    final store = SharedDocumentSyncStore(database);
    return _RealInstallation(
      database,
      store,
      SharedDocumentSyncCoordinator(store, remote),
      DriftTripRepository(database, syncStore: store),
      DriftQuickListRepository(database, syncStore: store),
    );
  }

  Future<void> close() => database.close();
}

Future<(String, String)> _seedTrip(AppDatabase db) async {
  const uuid = Uuid();
  final now = DateTime.now().toUtc();
  final tripId = uuid.v4();
  final memberId = uuid.v4();
  final categoryId = uuid.v4();
  final itemId = uuid.v4();
  await db.transaction(() async {
    await db
        .into(db.trips)
        .insert(
          TripsCompanion.insert(
            id: tripId,
            name: 'Test réel ${uuid.v4()}',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await db
        .into(db.tripMembers)
        .insert(
          TripMembersCompanion.insert(
            id: memberId,
            tripId: tripId,
            groupKind: 'family',
            name: 'Testeur',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await db
        .into(db.tripCategories)
        .insert(
          TripCategoriesCompanion.insert(
            id: categoryId,
            tripId: tripId,
            memberId: Value(memberId),
            name: 'Divers',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await db
        .into(db.tripItems)
        .insert(
          TripItemsCompanion.insert(
            id: itemId,
            tripId: tripId,
            categoryId: categoryId,
            name: 'Test réel item',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
  });
  return (tripId, itemId);
}
