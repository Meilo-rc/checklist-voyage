import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/domain/models/progress.dart';

import 'helpers/seed_reference_library.dart';

void main() {
  test(
    'génère Essentiels, participant, multi-transport et multi-logement',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final trips = DriftTripRepository(database);
      final ids = await seedReferenceLibrary(library);

      final tripId = await trips.createTrip(
        CreateTripRequest(
          name: 'Paris',
          destination: 'Paris, France',
          startDate: DateTime.utc(2026, 9),
          endDate: DateTime.utc(2026, 9, 5),
          participantOwnerIds: {ids.participantOwner},
          transportOwnerIds: {ids.flightOwner, ids.trainOwner},
          lodgingOwnerIds: {ids.hotelOwner, ids.campingOwner},
        ),
      );
      final trip = (await trips.loadTrip(tripId))!;

      expect(
        trip.members.map((member) => member.name),
        containsAll(<String>{
          'Essentiel',
          'Alex',
          'Trajet - Avion',
          'Trajet - Train',
          'Logement - Hôtel',
          'Logement - Camping',
        }),
      );
      expect(trip.members, hasLength(6));
      expect(trip.members.any((member) => member.name == 'Privé'), isFalse);
      final passport = trip.members
          .singleWhere((member) => member.name == 'Essentiel')
          .categories
          .single
          .items
          .single;
      expect(passport.quantity, 2);
      expect(passport.id, isNot(ids.passportItem));
      expect(passport.sourceLibraryItemIds, [ids.passportItem]);

      final row = await (database.select(
        database.trips,
      )..where((value) => value.id.equals(tripId))).getSingle();
      expect(row.shareState, 'local');
      expect(row.shareCode, isNull);
      expect(row.remoteRecordId, isNull);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
  );

  test(
    'cycle todo checked done todo et quantité indépendante bornée',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final trips = DriftTripRepository(database);
      final ids = await seedReferenceLibrary(library);
      final tripId = await trips.createTrip(_request(ids));
      var item = (await trips.loadTrip(tripId))!.members
          .singleWhere((member) => member.name == 'Essentiel')
          .categories
          .single
          .items
          .single;

      expect(item.status, TripItemStatus.todo);
      await trips.cycleItemStatus(item.id);
      item = await _loadItem(trips, tripId, item.id);
      expect(item.status, TripItemStatus.checked);
      await trips.changeItemQuantity(item.id, 1);
      item = await _loadItem(trips, tripId, item.id);
      expect(item.quantity, 3);
      expect(item.status, TripItemStatus.checked);
      await trips.cycleItemStatus(item.id);
      expect(
        (await _loadItem(trips, tripId, item.id)).status,
        TripItemStatus.done,
      );
      await trips.cycleItemStatus(item.id);
      expect(
        (await _loadItem(trips, tripId, item.id)).status,
        TripItemStatus.todo,
      );
      await trips.changeItemQuantity(item.id, -500);
      expect((await _loadItem(trips, tripId, item.id)).quantity, 1);
      await trips.changeItemQuantity(item.id, 500);
      expect((await _loadItem(trips, tripId, item.id)).quantity, 99);
    },
  );

  test(
    'retirer un item voyage ne modifie jamais sa source bibliothèque',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final trips = DriftTripRepository(database);
      final ids = await seedReferenceLibrary(library);
      final tripId = await trips.createTrip(_request(ids));
      final item = (await trips.loadTrip(tripId))!.members
          .singleWhere((member) => member.name == 'Essentiel')
          .categories
          .single
          .items
          .single;

      await trips.removeItem(item.id);

      expect(
        (await (database.select(
          database.tripItems,
        )..where((row) => row.id.equals(item.id))).getSingle()).deletedAt,
        isNotNull,
      );
      expect(
        (await (database.select(
              database.libraryItems,
            )..where((row) => row.id.equals(ids.passportItem))).getSingle())
            .deletedAt,
        isNull,
      );
      expect(
        (await trips.loadTrip(tripId))!.members
            .expand((member) => member.categories)
            .expand((category) => category.items)
            .any((candidate) => candidate.id == item.id),
        isFalse,
      );
    },
  );

  test(
    'progressions voyage membre catégorie excluent les tombstones',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final trips = DriftTripRepository(database);
      final ids = await seedReferenceLibrary(library);
      final tripId = await trips.createTrip(_request(ids));
      var trip = (await trips.loadTrip(tripId))!;
      final essential = trip.members.singleWhere(
        (member) => member.name == 'Essentiel',
      );
      final passport = essential.categories.single.items.single;
      final participantItem = trip.members
          .singleWhere((member) => member.name == 'Alex')
          .categories
          .single
          .items
          .single;

      await trips.cycleItemStatus(passport.id);
      await trips.cycleItemStatus(passport.id);
      await trips.removeItem(participantItem.id);
      trip = (await trips.loadTrip(tripId))!;
      final overall = ProgressCalculator.forTrip(trip);
      final essentialProgress = ProgressCalculator.forMember(
        trip.members.singleWhere((member) => member.name == 'Essentiel'),
      );
      final categoryProgress = ProgressCalculator.forCategory(
        trip.members
            .singleWhere((member) => member.name == 'Essentiel')
            .categories
            .single,
      );

      expect(overall.total, 1);
      expect(overall.completed, 1);
      expect(overall.percent, 100);
      expect(essentialProgress.percent, 100);
      expect(categoryProgress.percent, 100);
    },
  );

  test('échec de validation ne crée aucune structure partielle', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final trips = DriftTripRepository(database);

    await expectLater(
      trips.createTrip(
        CreateTripRequest(
          name: 'Dates invalides',
          destination: '',
          startDate: DateTime.utc(2026, 9, 10),
          endDate: DateTime.utc(2026, 9, 1),
          participantOwnerIds: const {},
          transportOwnerIds: const {},
          lodgingOwnerIds: const {},
        ),
      ),
      throwsArgumentError,
    );
    expect(await database.select(database.trips).get(), isEmpty);
    expect(await database.select(database.tripMembers).get(), isEmpty);
  });
}

CreateTripRequest _request(ReferenceLibraryIds ids) => CreateTripRequest(
  name: 'Paris',
  destination: 'Paris',
  startDate: null,
  endDate: null,
  participantOwnerIds: {ids.participantOwner},
  transportOwnerIds: const {},
  lodgingOwnerIds: const {},
);

Future<TripItemModel> _loadItem(
  DriftTripRepository repository,
  String tripId,
  String itemId,
) async {
  return (await repository.loadTrip(tripId))!.members
      .expand((member) => member.categories)
      .expand((category) => category.items)
      .singleWhere((item) => item.id == itemId);
}
