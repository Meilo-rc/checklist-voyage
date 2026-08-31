import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_quick_list_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/shared_document_sync_coordinator.dart';
import 'package:checklist_voyage_v1/sync/shared_document_sync_store.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  const uuid = Uuid();

  test(
    'voyage et liste restent locaux tant que Partager n’est pas appelé',
    () async {
      final remote = InMemorySharedDocumentRemote();
      final a = await _Installation.memory(remote, uuid.v4());
      addTearDown(a.close);

      final tripId = await a.trips.createTrip(_emptyTrip('Local'));
      final listId = await a.quickLists.createQuickList('Locale');
      await a.quickLists.setQuickListIcon(listId, 'beach');
      await a.quickLists.addItem(listId: listId, name: 'Pain', quantity: 1);

      expect(remote.documentCount, 0);
      expect(await a.database.select(a.database.syncDocuments).get(), isEmpty);
      expect(await a.database.select(a.database.syncOutbox).get(), isEmpty);
      expect((await a.trips.loadTrip(tripId))!.shared, isFalse);
      expect((await a.quickLists.loadQuickList(listId))!.shared, isFalse);
      expect((await a.quickLists.loadQuickList(listId))!.icon, 'beach');
    },
  );

  test(
    'partage et jointure d’un voyage autonome sans fuite Personnel',
    () async {
      final remote = InMemorySharedDocumentRemote();
      final a = await _Installation.memory(
        remote,
        '10000000-0000-4000-8000-000000000001',
      );
      final b = await _Installation.memory(
        remote,
        '20000000-0000-4000-8000-000000000002',
      );
      addTearDown(a.close);
      addTearDown(b.close);

      final fixture = await _seedPersonalTrip(a.database);
      final access = await a.sync.shareTrip(fixture.tripId);
      final joined = await b.sync.join(access.shareCode);

      expect(joined.documentId, fixture.tripId);
      expect(joined.documentType, SharedDocumentType.trip);
      final copy = await b.trips.loadTrip(fixture.tripId);
      expect(copy, isNotNull);
      expect(copy!.shared, isTrue);
      expect(copy.shareCode, access.shareCode);
      expect(
        copy.members.single.categories.single.items.single.name,
        'Secret utile',
      );
      expect(copy.members.single.sourceOwnerId, isNull);
      expect(copy.members.single.categories.single.name, 'Divers');
      expect(
        copy.members.single.categories.single.items.single.sources,
        isEmpty,
      );

      final sent = jsonEncode(
        remote
            .operations(fixture.tripId)
            .map((op) => op.operation.toJson())
            .toList(),
      );
      expect(sent, isNot(contains(fixture.personalOwnerId)));
      expect(sent, isNot(contains(fixture.personalCategoryId)));
      expect(sent, isNot(contains(fixture.personalItemId)));
      expect(sent, isNot(contains(fixture.personalContextId)));
      expect(sent, isNot(contains('Catégorie secrète')));
    },
  );

  test(
    'un choix Personnel génère puis partage uniquement une copie autonome',
    () async {
      final remote = InMemorySharedDocumentRemote();
      final a = await _Installation.memory(
        remote,
        '10000000-0000-4000-8000-000000000011',
      );
      final b = await _Installation.memory(
        remote,
        '20000000-0000-4000-8000-000000000012',
      );
      addTearDown(a.close);
      addTearDown(b.close);
      final library = DriftLibraryRepository(a.database);
      final participantId = await library.createOwner(
        name: 'Malone',
        kind: LibraryOwnerKind.familyMember,
        generationRole: GenerationRole.participant,
      );
      final personalOwnerId = await library.createOwner(
        name: 'Personnel Malone',
        kind: LibraryOwnerKind.personal,
        generationRole: GenerationRole.participant,
        linkedParticipantOwnerId: participantId,
      );
      final personalCategoryId = await library.createCategory(
        personalOwnerId,
        'Documents privés',
      );
      final personalItemId = await library.createItem(
        categoryId: personalCategoryId,
        name: 'Carte privée utile',
        defaultQuantity: 1,
      );
      final tripId = await a.trips.createTrip(
        CreateTripRequest(
          name: 'Séjour',
          destination: 'Nice',
          startDate: null,
          endDate: null,
          participantOwnerIds: {participantId},
          transportOwnerIds: const {},
          lodgingOwnerIds: const {},
          personalCategoryIds: {personalCategoryId},
          includeEssentials: false,
        ),
      );

      final access = await a.sync.shareTrip(tripId);
      await b.sync.join(access.shareCode);
      final copy = (await b.trips.loadTrip(tripId))!;

      expect(copy.selectedPersonalCategoryIds, isEmpty);
      expect(copy.members.single.groupKind, TripMemberGroupKind.personal);
      expect(copy.members.single.name, 'Personnel');
      expect(copy.members.single.categories.single.name, 'Divers');
      expect(
        copy.members.single.categories.single.items.single.name,
        'Carte privée utile',
      );
      expect(
        copy.members.single.categories.single.items.single.sources,
        isEmpty,
      );
      final sent = jsonEncode(
        remote.operations(tripId).map((op) => op.operation.toJson()).toList(),
      );
      expect(sent, isNot(contains(personalOwnerId)));
      expect(sent, isNot(contains(personalCategoryId)));
      expect(sent, isNot(contains(personalItemId)));
      expect(sent, isNot(contains('Documents privés')));
      expect(sent, isNot(contains('personal_category')));
    },
  );

  test(
    'deux installations hors ligne convergent et consignent le conflit',
    () async {
      final remote = InMemorySharedDocumentRemote();
      final a = await _Installation.memory(
        remote,
        '10000000-0000-4000-8000-000000000001',
      );
      final b = await _Installation.memory(
        remote,
        '20000000-0000-4000-8000-000000000002',
      );
      addTearDown(a.close);
      addTearDown(b.close);

      final fixture = await _seedSimpleTrip(a.database);
      final access = await a.sync.shareTrip(fixture.tripId);
      await b.sync.join(access.shareCode);

      remote.online = false;
      await a.trips.cycleItemStatus(fixture.itemId);
      await a.trips.cycleItemStatus(fixture.itemId);
      await b.trips.changeItemQuantity(fixture.itemId, 2);
      expect(await a.store.pendingOperations(fixture.tripId), hasLength(2));
      expect(await b.store.pendingOperations(fixture.tripId), hasLength(1));

      final restartedA = SharedDocumentSyncCoordinator(a.store, remote);
      final restartedB = SharedDocumentSyncCoordinator(b.store, remote);
      remote.online = true;
      await restartedA.syncAll();
      await restartedB.syncAll();
      await restartedA.syncAll();
      await restartedB.syncAll();

      final itemA = (await a.trips.loadTrip(
        fixture.tripId,
      ))!.members.single.categories.single.items.single;
      final itemB = (await b.trips.loadTrip(
        fixture.tripId,
      ))!.members.single.categories.single.items.single;
      expect(itemA.status, itemB.status);
      expect(itemA.quantity, itemB.quantity);
      expect(
        await a.database.select(a.database.syncConflicts).get(),
        isNotEmpty,
      );

      remote.online = false;
      await a.trips.removeItem(fixture.itemId);
      await b.trips.changeItemQuantity(fixture.itemId, 1);
      remote.online = true;
      await restartedB.syncAll();
      await restartedA.syncAll();
      await restartedB.syncAll();
      expect(
        (await b.trips.loadTrip(
          fixture.tripId,
        ))!.members.single.categories.single.items,
        isEmpty,
      );
      final tombstone = await (b.database.select(
        b.database.syncTombstones,
      )..where((row) => row.entityId.equals(fixture.itemId))).getSingle();
      expect(
        tombstone.purgeEligibleAt.difference(tombstone.deletedAt).inDays,
        90,
      );
    },
  );

  test(
    'voyage partagé converge dans les deux sens sur les trois états',
    () async {
      final remote = InMemorySharedDocumentRemote();
      final a = await _Installation.memory(
        remote,
        '10000000-0000-4000-8000-000000000101',
      );
      final b = await _Installation.memory(
        remote,
        '20000000-0000-4000-8000-000000000202',
      );
      addTearDown(a.close);
      addTearDown(b.close);

      final fixture = await _seedSimpleTrip(a.database);
      final access = await a.sync.shareTrip(fixture.tripId);
      await b.sync.join(access.shareCode);
      expect(await _status(a, fixture), TripItemStatus.todo);
      expect(await _status(b, fixture), TripItemStatus.todo);

      await a.trips.cycleItemStatus(fixture.itemId);
      expect(await a.store.pendingOperations(fixture.tripId), hasLength(1));
      await a.sync.syncAll();
      expect(await a.store.pendingOperations(fixture.tripId), isEmpty);
      await b.sync.syncAll();
      expect(await _status(b, fixture), TripItemStatus.checked);
      await _expectSameRevision(a, b, fixture.tripId);

      await b.trips.cycleItemStatus(fixture.itemId);
      expect(await b.store.pendingOperations(fixture.tripId), hasLength(1));
      await b.sync.syncAll();
      expect(await b.store.pendingOperations(fixture.tripId), isEmpty);
      await a.sync.syncAll();
      expect(await _status(a, fixture), TripItemStatus.done);
      await _expectSameRevision(a, b, fixture.tripId);

      await a.trips.cycleItemStatus(fixture.itemId);
      await a.sync.syncAll();
      await b.sync.syncAll();
      expect(await _status(a, fixture), TripItemStatus.todo);
      expect(await _status(b, fixture), TripItemStatus.todo);
      await _expectSameRevision(a, b, fixture.tripId);

      remote.online = false;
      await b.trips.cycleItemStatus(fixture.itemId);
      expect(await _status(b, fixture), TripItemStatus.checked);
      expect(await b.store.pendingOperations(fixture.tripId), hasLength(1));
      remote.online = true;
      await b.sync.syncAll();
      await a.sync.syncAll();
      expect(await _status(a, fixture), TripItemStatus.checked);
      expect(await _status(b, fixture), TripItemStatus.checked);
      expect(await b.store.pendingOperations(fixture.tripId), isEmpty);
      await _expectSameRevision(a, b, fixture.tripId);
    },
  );

  test('une mutation de voyage partagé déclenche son envoi', () async {
    final remote = InMemorySharedDocumentRemote();
    final database = AppDatabase(NativeDatabase.memory());
    final app = await AppDependencies.create(
      database: database,
      documentRemote: remote,
      autoSync: false,
    );
    addTearDown(app.close);

    final fixture = await _seedSimpleTrip(database);
    await app.sharedDocuments.shareTrip(fixture.tripId);
    await app.trips.cycleItemStatus(fixture.itemId);

    await _waitForOutboxToDrain(database, fixture.tripId);
    final lastItemOperation = remote
        .operations(fixture.tripId)
        .where((entry) => entry.operation.entityId == fixture.itemId)
        .last;
    expect(lastItemOperation.operation.payload['status'], 'checked');
  });

  test('liste rapide partagée synchronise états, quantités et reset', () async {
    final remote = InMemorySharedDocumentRemote();
    final a = await _Installation.memory(remote, uuid.v4());
    final b = await _Installation.memory(remote, uuid.v4());
    addTearDown(a.close);
    addTearDown(b.close);

    final listId = await a.quickLists.createQuickList('Courses');
    await a.quickLists.setQuickListIcon(listId, 'shopping');
    final itemId = await a.quickLists.addItem(
      listId: listId,
      name: 'Eau',
      quantity: 2,
    );
    final access = await a.sync.shareQuickList(listId);
    await b.sync.join(access.shareCode);
    expect((await b.quickLists.loadQuickList(listId))!.icon, 'shopping');
    expect(
      (await b.quickLists.loadQuickList(listId))!.items.single.quantity,
      2,
    );

    remote.online = false;
    await b.quickLists.toggleItem(itemId);
    await b.quickLists.changeItemQuantity(itemId, 1);
    remote.online = true;
    await b.sync.syncAll();
    await a.sync.syncAll();
    var item = (await a.quickLists.loadQuickList(listId))!.items.single;
    expect(item.isChecked, isTrue);
    expect(item.quantity, 3);

    remote.online = false;
    await b.quickLists.setQuickListIcon(listId, 'beach');
    expect((await a.quickLists.loadQuickList(listId))!.icon, 'shopping');
    remote.online = true;
    await b.sync.syncAll();
    await a.sync.syncAll();
    expect((await a.quickLists.loadQuickList(listId))!.icon, 'beach');
    expect((await b.quickLists.loadQuickList(listId))!.icon, 'beach');

    await a.quickLists.reset(listId);
    await a.sync.syncAll();
    await b.sync.syncAll();
    item = (await b.quickLists.loadQuickList(listId))!.items.single;
    expect(item.isChecked, isFalse);
  });

  test('codes, capacités et documents sont isolés', () async {
    final remote = InMemorySharedDocumentRemote();
    final a = await _Installation.memory(remote, uuid.v4());
    final b = await _Installation.memory(remote, uuid.v4());
    addTearDown(a.close);
    addTearDown(b.close);

    final x = await a.trips.createTrip(_emptyTrip('X'));
    final y = await a.trips.createTrip(_emptyTrip('Y'));
    final accessX = await a.sync.shareTrip(x);
    await a.sync.shareTrip(y);
    final joined1 = await b.sync.join(accessX.shareCode);
    final joined2 = await b.sync.join(accessX.shareCode);
    expect(joined2.documentId, joined1.documentId);
    expect(await b.store.sharedDocuments(), hasLength(1));
    expect(await b.trips.loadTrip(y), isNull);

    final tokenX = (await b.store.document(x)).capabilityToken!;
    final deviceB = (await b.store.installation()).installationId;
    expect(
      () => remote.pullDocument(
        documentId: y,
        deviceId: deviceB,
        capabilityToken: tokenX,
        afterRevision: 0,
      ),
      throwsA(isA<StateError>()),
    );
    expect(
      () => b.sync.join('INVALIDE'),
      throwsA(isA<InvalidShareCodeException>()),
    );
    expect(
      () => b.sync.join('ABCDEFGH'),
      throwsA(isA<InvalidShareCodeException>()),
    );
  });

  test('une collision de code est détectée puis régénérée', () async {
    var calls = 0;
    final remote = InMemorySharedDocumentRemote(
      codeGenerator: () => ++calls < 3 ? 'AAAAAAAA' : 'BBBBBBBB',
    );
    final a = await _Installation.memory(remote, uuid.v4());
    addTearDown(a.close);
    final first = await a.trips.createTrip(_emptyTrip('Premier'));
    final second = await a.trips.createTrip(_emptyTrip('Second'));
    final firstAccess = await a.sync.shareTrip(first);
    final secondAccess = await a.sync.shareTrip(second);
    expect(firstAccess.shareCode, 'AAAAAAAA');
    expect(secondAccess.shareCode, 'BBBBBBBB');
    expect(calls, 3);
  });

  test(
    'un document historique partagé est copié vers V1 à la demande',
    () async {
      final remote = InMemorySharedDocumentRemote();
      final a = await _Installation.memory(remote, uuid.v4());
      addTearDown(a.close);
      final now = DateTime.now().toUtc();
      final tripId = uuid.v4();
      await a.database
          .into(a.database.trips)
          .insert(
            TripsCompanion.insert(
              id: tripId,
              name: 'Historique 2.63',
              shareState: const Value('shared'),
              remoteRecordId: const Value('legacy-record'),
              shareCode: const Value('ABC123'),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      var trip = await a.trips.loadTrip(tripId);
      expect(trip!.shared, isTrue);
      expect(trip.v1ShareReady, isFalse);
      expect(trip.shareCode, isNull);

      final access = await a.sync.shareTrip(tripId);
      trip = await a.trips.loadTrip(tripId);
      expect(access.shareCode, hasLength(8));
      expect(trip!.v1ShareReady, isTrue);
      expect(trip.shareCode, access.shareCode);
    },
  );

  test('outbox et capacité survivent à un redémarrage de la base', () async {
    final remote = InMemorySharedDocumentRemote();
    final directory = await Directory.systemTemp.createTemp('cv1-doc-sync-');
    final file = File('${directory.path}${Platform.pathSeparator}db.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    var a = await _Installation.file(remote, uuid.v4(), file);
    final listId = await a.quickLists.createQuickList('Persistante');
    final access = await a.sync.shareQuickList(listId);
    remote.online = false;
    await a.quickLists.addItem(listId: listId, name: 'Hors ligne', quantity: 1);
    expect(await a.store.pendingOperations(listId), hasLength(1));
    await a.close();

    a = await _Installation.file(remote, null, file, initialize: false);
    addTearDown(a.close);
    expect((await a.store.document(listId)).capabilityToken, isNotEmpty);
    expect(await a.store.pendingOperations(listId), hasLength(1));
    remote.online = true;
    await a.sync.syncAll();

    final b = await _Installation.memory(remote, uuid.v4());
    addTearDown(b.close);
    await b.sync.join(access.shareCode);
    expect(
      (await b.quickLists.loadQuickList(listId))!.items.single.name,
      'Hors ligne',
    );
  });
}

class _Installation {
  _Installation._(
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

  static Future<_Installation> memory(
    InMemorySharedDocumentRemote remote,
    String deviceId,
  ) => _create(AppDatabase(NativeDatabase.memory()), remote, deviceId, true);

  static Future<_Installation> file(
    InMemorySharedDocumentRemote remote,
    String? deviceId,
    File file, {
    bool initialize = true,
  }) =>
      _create(AppDatabase(NativeDatabase(file)), remote, deviceId, initialize);

  static Future<_Installation> _create(
    AppDatabase database,
    InMemorySharedDocumentRemote remote,
    String? deviceId,
    bool initialize,
  ) async {
    if (initialize) {
      final now = DateTime.now().toUtc();
      await database
          .into(database.installationSettings)
          .insert(
            InstallationSettingsCompanion.insert(
              installationId: deviceId!,
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
    }
    final store = SharedDocumentSyncStore(database);
    return _Installation._(
      database,
      store,
      SharedDocumentSyncCoordinator(store, remote),
      DriftTripRepository(database, syncStore: store),
      DriftQuickListRepository(database, syncStore: store),
    );
  }

  Future<void> close() => database.close();
}

CreateTripRequest _emptyTrip(String name) => CreateTripRequest(
  name: name,
  destination: name,
  startDate: null,
  endDate: null,
  participantOwnerIds: const {},
  transportOwnerIds: const {},
  lodgingOwnerIds: const {},
  includeEssentials: false,
);

Future<_TripFixture> _seedSimpleTrip(AppDatabase db) async {
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
            name: 'Voyage test',
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
            name: 'Membre',
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
            name: 'Chargeur',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
  });
  return _TripFixture(tripId: tripId, itemId: itemId);
}

Future<TripItemStatus> _status(
  _Installation installation,
  _TripFixture fixture,
) async => (await installation.trips.loadTrip(
  fixture.tripId,
))!.members.single.categories.single.items.single.status;

Future<void> _expectSameRevision(
  _Installation a,
  _Installation b,
  String tripId,
) async {
  final documentA = await a.store.document(tripId);
  final documentB = await b.store.document(tripId);
  expect(documentA.pullCursor, documentA.confirmedRevision);
  expect(documentB.pullCursor, documentB.confirmedRevision);
  expect(documentB.pullCursor, documentA.pullCursor);
}

Future<void> _waitForOutboxToDrain(
  AppDatabase database,
  String documentId,
) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    final pending = await (database.select(
      database.syncOutbox,
    )..where((row) => row.documentId.equals(documentId))).get();
    if (pending.isEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('La file d’envoi du voyage n’a pas été vidée.');
}

Future<_PersonalTripFixture> _seedPersonalTrip(AppDatabase db) async {
  const uuid = Uuid();
  final base = await _seedSimpleTrip(db);
  final now = DateTime.now().toUtc();
  final ownerId = uuid.v4();
  final categoryId = uuid.v4();
  final itemId = uuid.v4();
  final contextId = uuid.v4();
  final tripItem = await (db.select(
    db.tripItems,
  )..where((row) => row.tripId.equals(base.tripId))).getSingle();
  await db.transaction(() async {
    await db
        .into(db.libraryOwners)
        .insert(
          LibraryOwnersCompanion.insert(
            id: ownerId,
            kind: 'personal',
            syncScope: 'personal_local',
            name: 'Personnel secret',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await db
        .into(db.libraryCategories)
        .insert(
          LibraryCategoriesCompanion.insert(
            id: categoryId,
            ownerId: ownerId,
            name: 'Catégorie secrète',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await db
        .into(db.libraryItems)
        .insert(
          LibraryItemsCompanion.insert(
            id: itemId,
            categoryId: categoryId,
            name: 'Secret utile',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await db
        .into(db.contexts)
        .insert(
          ContextsCompanion.insert(
            id: contextId,
            name: 'Contexte personnel',
            syncScope: 'shared_library',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await (db.update(
      db.tripCategories,
    )..where((row) => row.tripId.equals(base.tripId))).write(
      TripCategoriesCompanion(
        sourceCategoryId: Value(categoryId),
        name: const Value('Catégorie secrète'),
      ),
    );
    await (db.update(db.tripItems)..where((row) => row.id.equals(tripItem.id)))
        .write(TripItemsCompanion(name: const Value('Secret utile')));
    await db
        .into(db.tripItemSources)
        .insert(
          TripItemSourcesCompanion.insert(
            tripItemId: tripItem.id,
            sourceLibraryItemId: itemId,
            sourceKind: 'context:$contextId',
            reasonKind: const Value('context'),
            reasonId: Value(contextId),
            contributingLibraryItemId: Value(itemId),
          ),
        );
  });
  return _PersonalTripFixture(
    tripId: base.tripId,
    itemId: base.itemId,
    personalOwnerId: ownerId,
    personalCategoryId: categoryId,
    personalItemId: itemId,
    personalContextId: contextId,
  );
}

class _TripFixture {
  const _TripFixture({required this.tripId, required this.itemId});

  final String tripId;
  final String itemId;
}

class _PersonalTripFixture extends _TripFixture {
  const _PersonalTripFixture({
    required super.tripId,
    required super.itemId,
    required this.personalOwnerId,
    required this.personalCategoryId,
    required this.personalItemId,
    required this.personalContextId,
  });

  final String personalOwnerId;
  final String personalCategoryId;
  final String personalItemId;
  final String personalContextId;
}
