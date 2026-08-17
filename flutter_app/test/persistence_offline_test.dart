import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_quick_list_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';

import 'helpers/seed_reference_library.dart';

void main() {
  test(
    'un redémarrage conserve voyage, participants, états, quantités et listes',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'checklist-lot4-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');

      var database = AppDatabase(NativeDatabase(file));
      var library = DriftLibraryRepository(database);
      var trips = DriftTripRepository(database);
      var quickLists = DriftQuickListRepository(database);
      final ids = await seedReferenceLibrary(library);
      final tripId = await trips.createTrip(
        CreateTripRequest(
          name: 'Persistant',
          destination: 'Lyon',
          startDate: DateTime.utc(2026, 10, 1),
          endDate: DateTime.utc(2026, 10, 3),
          participantOwnerIds: {ids.participantOwner},
          transportOwnerIds: {ids.trainOwner},
          lodgingOwnerIds: {ids.hotelOwner},
        ),
      );
      final initialTrip = (await trips.loadTrip(tripId))!;
      final passport = initialTrip.members
          .singleWhere((member) => member.name == 'Essentiel')
          .categories
          .single
          .items
          .single;
      final participantItem = initialTrip.members
          .singleWhere((member) => member.name == 'Alex')
          .categories
          .single
          .items
          .single;
      await trips.cycleItemStatus(passport.id);
      await trips.changeItemQuantity(passport.id, 3);
      await trips.removeItem(participantItem.id);
      final listId = await quickLists.createQuickList('Persistante');
      final quickItemId = await quickLists.addItem(
        listId: listId,
        name: 'Chargeur',
        quantity: 2,
      );
      await quickLists.toggleItem(quickItemId);
      await database.close();

      database = AppDatabase(NativeDatabase(file));
      library = DriftLibraryRepository(database);
      trips = DriftTripRepository(database);
      quickLists = DriftQuickListRepository(database);
      addTearDown(database.close);

      final restoredTrip = (await trips.loadTrip(tripId))!;
      final restoredPassport = restoredTrip.members
          .singleWhere((member) => member.name == 'Essentiel')
          .categories
          .single
          .items
          .single;
      expect(restoredTrip.destination, 'Lyon');
      expect(
        restoredTrip.members.map((member) => member.name),
        containsAll(<String>[
          'Essentiel',
          'Alex',
          'Trajet - Train',
          'Logement - Hôtel',
        ]),
      );
      expect(restoredPassport.status, TripItemStatus.checked);
      expect(restoredPassport.quantity, 5);
      expect(restoredPassport.sourceLibraryItemIds, [ids.passportItem]);
      expect(
        restoredTrip.members
            .expand((member) => member.categories)
            .expand((category) => category.items)
            .any((item) => item.id == participantItem.id),
        isFalse,
      );
      expect(
        (await library.loadLibrary())
            .expand((owner) => owner.categories)
            .expand((category) => category.items)
            .any((item) => item.id == ids.shirtItem),
        isTrue,
      );
      final restoredList = (await quickLists.loadQuickList(listId))!;
      expect(restoredList.items.single.isChecked, isTrue);
      expect(restoredList.items.single.quantity, 2);
    },
  );

  test(
    'tous les parcours du moteur réussissent avec le réseau interdit',
    () async {
      await HttpOverrides.runZoned(() async {
        final database = AppDatabase(NativeDatabase.memory());
        addTearDown(database.close);
        final library = DriftLibraryRepository(database);
        final trips = DriftTripRepository(database);
        final quickLists = DriftQuickListRepository(database);
        final ids = await seedReferenceLibrary(library);

        final tripId = await trips.createTrip(
          CreateTripRequest(
            name: 'Hors ligne',
            destination: 'Nantes',
            startDate: null,
            endDate: null,
            participantOwnerIds: {ids.participantOwner},
            transportOwnerIds: {ids.flightOwner},
            lodgingOwnerIds: {ids.campingOwner},
          ),
        );
        final trip = (await trips.loadTrip(tripId))!;
        await trips.cycleItemStatus(
          trip.members.first.categories.first.items.first.id,
        );
        final listId = await quickLists.createQuickList('Sans réseau');
        final itemId = await quickLists.addItem(
          listId: listId,
          name: 'Billet',
          quantity: 1,
        );
        await quickLists.toggleItem(itemId);

        expect(await trips.loadTrip(tripId), isNotNull);
        expect(await quickLists.loadQuickList(listId), isNotNull);
        expect(await database.select(database.syncOutbox).get(), isEmpty);
      }, createHttpClient: (_) => throw StateError('Accès réseau interdit'));
    },
  );
}
