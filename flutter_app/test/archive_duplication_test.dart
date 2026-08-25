import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_context_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_quick_list_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/domain/models/destination_summaries.dart';
import 'package:checklist_voyage_v1/domain/models/trip_archive.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/in_memory_sync_remote.dart';

import 'helpers/seed_reference_library.dart';

void main() {
  // Ce fichier ouvre volontairement deux installations isolées en parallèle.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('classe futur, en cours et terminé sans mutation', () {
    final today = DateTime(2026, 8, 20, 12);
    final future = _summary(
      start: DateTime(2026, 8, 21),
      end: DateTime(2026, 8, 24),
    );
    final ongoing = _summary(
      start: DateTime(2026, 8, 18),
      end: DateTime(2026, 8, 20),
    );
    final finished = _summary(
      start: DateTime(2026, 8, 18),
      end: DateTime(2026, 8, 19),
    );
    final manual = _summary(
      start: DateTime(2026, 8, 21),
      end: DateTime(2026, 8, 24),
      archivedAt: DateTime(2026, 8, 20),
    );

    expect(
      TripArchiveClassifier.classify(future, today),
      TripCollection.upcoming,
    );
    expect(
      TripArchiveClassifier.classify(ongoing, today),
      TripCollection.ongoing,
    );
    expect(
      TripArchiveClassifier.classify(finished, today),
      TripCollection.archived,
    );
    expect(
      TripArchiveClassifier.classify(manual, today),
      TripCollection.archived,
    );
    expect(ongoing.archivedAt, isNull);
    expect(finished.archivedAt, isNull);
  });

  test(
    'archiver et restaurer un voyage local conserve toutes ses données',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final ids = await seedReferenceLibrary(library);
      final trips = DriftTripRepository(database);
      final tripId = await trips.createTrip(
        _request(ids, name: 'Archive locale'),
      );
      final before = (await trips.loadTrip(tripId))!;

      await trips.archiveTrip(tripId);
      final archived = (await trips.loadTrip(tripId))!;
      await trips.restoreTrip(tripId);
      final restored = (await trips.loadTrip(tripId))!;

      expect(archived.archivedAt, isNotNull);
      expect(_itemNames(archived), _itemNames(before));
      expect(restored.archivedAt, isNull);
      expect(_itemNames(restored), _itemNames(before));
      expect(await database.select(database.syncOutbox).get(), isEmpty);
      expect(await database.select(database.syncTombstones).get(), isEmpty);
    },
  );

  test(
    'dupliquer reprend la checklist affinée avec nouveaux UUID et états todo',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      final library = DriftLibraryRepository(database);
      final ids = await seedReferenceLibrary(library);
      await library.setLinkedParticipantOwner(
        ids.personalOwner,
        ids.participantOwner,
      );
      final contexts = DriftContextRepository(database);
      final beach = await contexts.createContext('Plage');
      await contexts.setItemContexts(ids.passportItem, {beach});
      await contexts.setItemContexts(ids.personalItem, {beach});
      final remote = InMemorySharedDocumentRemote();
      final dependencies = await AppDependencies.create(
        database: database,
        syncRemote: InMemorySyncRemote(),
        documentRemote: remote,
        autoSync: false,
      );
      addTearDown(dependencies.close);
      final sourceId = await dependencies.trips.createTrip(
        CreateTripRequest(
          name: 'Source affinée',
          destination: 'Biarritz',
          startDate: DateTime(2025, 7, 1),
          endDate: DateTime(2025, 7, 8),
          participantOwnerIds: {ids.participantOwner},
          transportOwnerIds: {ids.flightOwner, ids.trainOwner},
          lodgingOwnerIds: {ids.hotelOwner, ids.campingOwner},
          contextIds: {beach},
          personalCategoryIds: {ids.personalCategory},
        ),
      );
      var source = (await dependencies.trips.watchTrip(sourceId).first)!;
      final passport = _itemByName(source, 'Passeport');
      final shirt = _itemByName(source, 'T-shirt');
      final train = _itemByName(source, 'Billet train');
      await dependencies.trips.cycleItemStatus(passport.id);
      await dependencies.trips.changeItemQuantity(passport.id, 3);
      await dependencies.trips.cycleItemStatus(shirt.id);
      await dependencies.trips.cycleItemStatus(shirt.id);
      await dependencies.trips.removeItem(train.id);
      source = (await dependencies.trips.watchTrip(sourceId).first)!;
      final participantCategory = source.members
          .singleWhere((member) => member.name == 'Alex')
          .categories
          .first;
      await dependencies.trips.addItem(
        source.id,
        participantCategory.id,
        'Ajout réellement utilisé',
        quantity: 7,
      );
      final access = await dependencies.sharedDocuments.shareTrip(sourceId);
      source = (await dependencies.trips.watchTrip(sourceId).first)!;
      final remoteOperations = remote.operations(sourceId).length;
      final libraryItemsBefore = await database
          .select(database.libraryItems)
          .get();
      final associationsBefore = await database
          .select(database.libraryItemContexts)
          .get();

      final duplicateId = await dependencies.trips.duplicateTrip(
        DuplicateTripRequest(
          sourceTripId: sourceId,
          name: 'Biarritz 2027',
          destination: source.destination,
          startDate: DateTime(2027, 8, 2),
          endDate: DateTime(2027, 8, 12),
        ),
      );
      final duplicate = (await dependencies.trips
          .watchTrip(duplicateId)
          .first)!;
      final sourceItems = _items(source);
      final duplicateItems = _items(duplicate);
      final sourceChoices = await (database.select(
        database.tripGenerationChoices,
      )..where((row) => row.tripId.equals(sourceId))).get();
      final duplicateChoices = await (database.select(
        database.tripGenerationChoices,
      )..where((row) => row.tripId.equals(duplicateId))).get();

      expect(duplicateId, isNot(sourceId));
      expect(duplicate.destination, 'Biarritz');
      expect(
        [
          duplicate.startDate?.toLocal().year,
          duplicate.startDate?.toLocal().month,
          duplicate.startDate?.toLocal().day,
        ],
        [2027, 8, 2],
      );
      expect(
        [
          duplicate.endDate?.toLocal().year,
          duplicate.endDate?.toLocal().month,
          duplicate.endDate?.toLocal().day,
        ],
        [2027, 8, 12],
      );
      expect(duplicate.selectedContextIds, source.selectedContextIds);
      expect(
        duplicate.members.map((member) => member.name).toSet(),
        source.members.map((member) => member.name).toSet(),
      );
      expect(
        duplicate.members
            .expand((member) => member.categories)
            .map((category) => '${category.name}:${category.items.length}')
            .toList()
          ..sort(),
        source.members
            .expand((member) => member.categories)
            .map((category) => '${category.name}:${category.items.length}')
            .toList()
          ..sort(),
      );
      expect(
        duplicateChoices
            .map((choice) => '${choice.choiceKind}:${choice.choiceId}')
            .toSet(),
        sourceChoices
            .map((choice) => '${choice.choiceKind}:${choice.choiceId}')
            .toSet(),
      );
      expect(
        duplicateChoices
            .map((choice) => choice.id)
            .toSet()
            .intersection(sourceChoices.map((choice) => choice.id).toSet()),
        isEmpty,
      );
      expect(_itemNames(duplicate), _itemNames(source));
      expect(_itemNames(duplicate), isNot(contains('Billet train')));
      expect(_itemNames(duplicate), contains('Ajout réellement utilisé'));
      expect(_itemNames(duplicate), contains('Objet privé'));
      expect(
        duplicateItems.every((item) => item.status == TripItemStatus.todo),
        isTrue,
      );
      expect(
        _itemByName(duplicate, 'Passeport').quantity,
        _itemByName(source, 'Passeport').quantity,
      );
      expect(_itemByName(duplicate, 'Ajout réellement utilisé').quantity, 7);
      expect(
        duplicate.members
            .map((member) => member.id)
            .toSet()
            .intersection(source.members.map((member) => member.id).toSet()),
        isEmpty,
      );
      expect(
        duplicateItems
            .map((item) => item.id)
            .toSet()
            .intersection(sourceItems.map((item) => item.id).toSet()),
        isEmpty,
      );
      expect(duplicate.shared, isFalse);
      expect(duplicate.v1ShareReady, isFalse);
      expect(duplicate.shareCode, isNull);
      expect(duplicate.archivedAt, isNull);
      expect(access.shareCode, isNotEmpty);
      expect(remote.operations(sourceId), hasLength(remoteOperations));
      expect(await database.select(database.syncOutbox).get(), isEmpty);
      expect(
        await (database.select(database.syncDocuments)
              ..where((row) => row.documentId.equals(duplicateId)))
            .getSingleOrNull(),
        isNull,
      );
      expect(
        await database.select(database.libraryItems).get(),
        hasLength(libraryItemsBefore.length),
      );
      expect(
        await database.select(database.libraryItemContexts).get(),
        hasLength(associationsBefore.length),
      );
    },
  );

  test('dupliquer une liste partagée crée une copie locale décochée', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final remote = InMemorySharedDocumentRemote();
    final dependencies = await AppDependencies.create(
      database: database,
      syncRemote: InMemorySyncRemote(),
      documentRemote: remote,
      autoSync: false,
    );
    addTearDown(dependencies.close);
    final sourceId = await dependencies.quickLists.create('Cabine');
    final charger = await dependencies.quickLists.addItem(
      sourceId,
      'Chargeur',
      quantity: 3,
    );
    await dependencies.quickLists.addItem(sourceId, 'Livre', quantity: 2);
    await dependencies.quickLists.toggleItem(charger);
    await dependencies.sharedDocuments.shareQuickList(sourceId);
    final remoteOperations = remote.operations(sourceId).length;

    final duplicateId = await dependencies.quickLists.duplicate(sourceId);
    final source = (await dependencies.quickLists
        .watchQuickList(sourceId)
        .first)!;
    final duplicate = (await dependencies.quickLists
        .watchQuickList(duplicateId)
        .first)!;

    expect(duplicateId, isNot(sourceId));
    expect(duplicate.name, 'Cabine — copie');
    expect(
      duplicate.items
          .map((item) => item.id)
          .toSet()
          .intersection(source.items.map((item) => item.id).toSet()),
      isEmpty,
    );
    expect(duplicate.items.map((item) => item.name).toSet(), {
      'Chargeur',
      'Livre',
    });
    expect(
      duplicate.items.singleWhere((item) => item.name == 'Chargeur').quantity,
      3,
    );
    expect(duplicate.items.every((item) => !item.isChecked), isTrue);
    expect(duplicate.shared, isFalse);
    expect(duplicate.v1ShareReady, isFalse);
    expect(duplicate.shareCode, isNull);
    expect(duplicate.archivedAt, isNull);
    expect(remote.operations(sourceId), hasLength(remoteOperations));
    expect(await database.select(database.syncOutbox).get(), isEmpty);
    expect(
      await (database.select(
        database.syncDocuments,
      )..where((row) => row.documentId.equals(duplicateId))).getSingleOrNull(),
      isNull,
    );
    await dependencies.quickLists.archive(sourceId);
    var archived = (await dependencies.quickLists
        .watchQuickList(sourceId)
        .first)!;
    expect(archived.archivedAt, isNotNull);
    expect(archived.items, hasLength(2));
    await dependencies.quickLists.restore(sourceId);
    archived = (await dependencies.quickLists.watchQuickList(sourceId).first)!;
    expect(archived.archivedAt, isNull);
    expect(archived.items, hasLength(2));
  });

  test(
    'archivage partagé converge et restauration conserve les capacités',
    () async {
      final remote = InMemorySharedDocumentRemote();
      final databaseA = AppDatabase(NativeDatabase.memory());
      final a = await AppDependencies.create(
        database: databaseA,
        syncRemote: InMemorySyncRemote(),
        documentRemote: remote,
        autoSync: false,
      );
      final tripId = await a.trips.createTrip(
        const CreateTripRequest(
          name: 'Partagé',
          destination: '',
          startDate: null,
          endDate: null,
          participantOwnerIds: {},
          transportOwnerIds: {},
          lodgingOwnerIds: {},
          includeEssentials: false,
        ),
      );
      final listId = await a.quickLists.create('Partagée');
      final tripAccess = await a.sharedDocuments.shareTrip(tripId);
      final listAccess = await a.sharedDocuments.shareQuickList(listId);

      final databaseB = AppDatabase(NativeDatabase.memory());
      final b = await AppDependencies.create(
        database: databaseB,
        syncRemote: InMemorySyncRemote(),
        documentRemote: remote,
        autoSync: false,
      );
      addTearDown(a.close);
      addTearDown(b.close);
      await b.sharedDocuments.join(tripAccess.shareCode);
      await b.sharedDocuments.join(listAccess.shareCode);
      final capabilityA =
          (await (databaseA.select(
                databaseA.syncDocuments,
              )..where((row) => row.documentId.equals(tripId))).getSingle())
              .capabilityToken;

      await a.trips.archiveTrip(tripId);
      await a.quickLists.archive(listId);
      expect(await databaseA.select(databaseA.syncOutbox).get(), hasLength(2));
      await a.sharedDocuments.syncAll();
      await b.sharedDocuments.syncAll();

      expect((await b.trips.watchTrip(tripId).first)!.archivedAt, isNotNull);
      expect(
        (await b.quickLists.watchQuickList(listId).first)!.archivedAt,
        isNotNull,
      );
      await b.trips.restoreTrip(tripId);
      await b.quickLists.restore(listId);
      await b.sharedDocuments.syncAll();
      await a.sharedDocuments.syncAll();

      expect((await a.trips.watchTrip(tripId).first)!.archivedAt, isNull);
      expect(
        (await a.quickLists.watchQuickList(listId).first)!.archivedAt,
        isNull,
      );
      expect(
        (await (databaseA.select(
              databaseA.syncDocuments,
            )..where((row) => row.documentId.equals(tripId))).getSingle())
            .capabilityToken,
        capabilityA,
      );
    },
  );

  test('archives et copies persistent après redémarrage hors ligne', () async {
    final directory = await Directory.systemTemp.createTemp('lot9-restart-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');

    var database = AppDatabase(NativeDatabase(file));
    var trips = DriftTripRepository(database);
    var lists = DriftQuickListRepository(database);
    final sourceTrip = await trips.createTrip(
      const CreateTripRequest(
        name: 'Persistant',
        destination: 'Lyon',
        startDate: null,
        endDate: null,
        participantOwnerIds: {},
        transportOwnerIds: {},
        lodgingOwnerIds: {},
        includeEssentials: false,
      ),
    );
    final duplicateTrip = await trips.duplicateTrip(
      DuplicateTripRequest(
        sourceTripId: sourceTrip,
        name: 'Copie persistante',
        destination: 'Lyon',
        startDate: DateTime(2027, 1, 1),
        endDate: DateTime(2027, 1, 2),
      ),
    );
    await trips.archiveTrip(sourceTrip);
    final sourceList = await lists.createQuickList('Persistante');
    await lists.addItem(listId: sourceList, name: 'Objet', quantity: 4);
    final duplicateList = await lists.duplicateQuickList(sourceList);
    await lists.archiveQuickList(sourceList);
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    trips = DriftTripRepository(database);
    lists = DriftQuickListRepository(database);
    expect((await trips.loadTrip(sourceTrip))!.archivedAt, isNotNull);
    expect(await trips.loadTrip(duplicateTrip), isNotNull);
    expect((await lists.loadQuickList(sourceList))!.archivedAt, isNotNull);
    expect((await lists.loadQuickList(sourceList))!.items.single.quantity, 4);
    expect(
      (await lists.loadQuickList(duplicateList))!.items.single.quantity,
      4,
    );
    await trips.restoreTrip(sourceTrip);
    await lists.restoreQuickList(sourceList);
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    expect(
      (await DriftTripRepository(database).loadTrip(sourceTrip))!.archivedAt,
      isNull,
    );
    expect(
      (await DriftQuickListRepository(
        database,
      ).loadQuickList(sourceList))!.archivedAt,
      isNull,
    );
  });
}

TripSummary _summary({DateTime? start, DateTime? end, DateTime? archivedAt}) =>
    TripSummary(
      id: 'trip',
      name: 'Voyage',
      destination: '',
      startDate: start,
      endDate: end,
      archivedAt: archivedAt,
      updatedAt: DateTime(2026),
      participantNames: const [],
      shared: false,
    );

CreateTripRequest _request(ReferenceLibraryIds ids, {required String name}) =>
    CreateTripRequest(
      name: name,
      destination: 'Paris',
      startDate: null,
      endDate: null,
      participantOwnerIds: {ids.participantOwner},
      transportOwnerIds: const {},
      lodgingOwnerIds: const {},
    );

List<TripItemModel> _items(TripDetailModel trip) => trip.members
    .expand((member) => member.categories)
    .expand((category) => category.items)
    .toList(growable: false);

List<String> _itemNames(TripDetailModel trip) =>
    _items(trip).map((item) => item.name).toList()..sort();

TripItemModel _itemByName(TripDetailModel trip, String name) =>
    _items(trip).singleWhere((item) => item.name == name);
