import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';

const annecy = WeatherLocation(
  name: 'Annecy',
  region: 'Auvergne-Rhône-Alpes',
  country: 'France',
  timezone: 'Europe/Paris',
  coordinates: WeatherCoordinates(latitude: 45.899, longitude: 6.129),
);
const rome = WeatherLocation(
  name: 'Rome',
  region: 'Latium',
  country: 'Italie',
  coordinates: WeatherCoordinates(latitude: 41.9, longitude: 12.5),
);

CreateTripRequest locatedTrip() => const CreateTripRequest(
  name: 'Ancien nom',
  destination: 'Annecy',
  destinationLocation: annecy,
  startDate: null,
  endDate: null,
  participantOwnerIds: {},
  transportOwnerIds: {},
  lodgingOwnerIds: {},
  includeEssentials: false,
);

void main() {
  test(
    'création géolocalisée et édition des dates préservent le JSON complet',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftTripRepository(database);
      final id = await repository.createTrip(locatedTrip());
      final original =
          (await database.select(database.trips).getSingle()).destinationJson;
      expect(jsonDecode(original!)['latitude'], annecy.coordinates.latitude);
      final itemCategory = await repository.addCategory(
        tripId: id,
        memberId: null,
        name: 'Documents',
      );
      final itemId = await repository.addItem(
        tripId: id,
        categoryId: itemCategory,
        name: 'Passeport',
        quantity: 3,
      );
      await repository.cycleItemStatus(itemId);
      final itemsBefore = (await database.select(database.tripItems).get())
          .map((row) => row.toJson())
          .toList();
      await repository.updateTripDetails(
        UpdateTripDetailsRequest(
          tripId: id,
          name: 'Ancien nom',
          destination: 'Annecy',
          startDate: DateTime(2027, 3, 1),
          endDate: DateTime(2027, 3, 4),
        ),
      );
      final row = await database.select(database.trips).getSingle();
      expect(row.destinationJson, original);
      expect(row.name, 'Ancien nom');
      expect(
        (await database.select(database.tripItems).get())
            .map((row) => row.toJson())
            .toList(),
        itemsBefore,
      );
      final loaded = (await repository.loadTrip(id))!;
      expect(loaded.destinationLatitude, 45.899);
      expect(loaded.destinationLocation!.region, annecy.region);
    },
  );

  test(
    'remplacement sélectionné et duplication conservent les bonnes coordonnées',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftTripRepository(database);
      final id = await repository.createTrip(locatedTrip());
      await repository.updateTripDetails(
        UpdateTripDetailsRequest(
          tripId: id,
          name: 'Ancien nom',
          destination: rome.name,
          destinationLocation: rome,
          startDate: null,
          endDate: null,
        ),
      );
      final original =
          (await database.select(database.trips).getSingle()).destinationJson;
      final copy = await repository.duplicateTrip(
        DuplicateTripRequest(
          sourceTripId: id,
          name: 'Rome',
          destination: 'Rome',
          startDate: DateTime(2027, 4, 1),
          endDate: DateTime(2027, 4, 5),
        ),
      );
      expect((await repository.loadTrip(id))!.destinationLatitude, 41.9);
      expect((await repository.loadTrip(copy))!.destinationLongitude, 12.5);
      final copyRow = await (database.select(
        database.trips,
      )..where((row) => row.id.equals(copy))).getSingle();
      expect(copyRow.destinationJson, original);
      expect(copyRow.shareState, 'local');
      final changedCopy = await repository.duplicateTrip(
        DuplicateTripRequest(
          sourceTripId: id,
          name: annecy.name,
          destination: annecy.name,
          destinationLocation: annecy,
          startDate: DateTime(2027, 5, 1),
          endDate: DateTime(2027, 5, 5),
        ),
      );
      expect(
        (await repository.loadTrip(changedCopy))!.destinationLatitude,
        45.899,
      );
      expect((await repository.loadTrip(id))!.destinationLatitude, 41.9);
    },
  );

  test(
    'anciens voyages sans coordonnées ou avec alias gardent leur JSON intact',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftTripRepository(database);
      final id = await repository.createTrip(locatedTrip());
      for (final legacy in [
        '{"name":"Annecy","country":"France","custom":"préservé"}',
        '{"name":"Annecy","lat":"45.9","lon":6.1,"custom":true}',
        'Annecy',
      ]) {
        await (database.update(database.trips)
              ..where((row) => row.id.equals(id)))
            .write(TripsCompanion(destinationJson: Value(legacy)));
        await repository.updateTripDetails(
          UpdateTripDetailsRequest(
            tripId: id,
            name: 'Ancien nom',
            destination: 'Annecy',
            startDate: DateTime(2027, 3, 1),
            endDate: DateTime(2027, 3, 3),
          ),
        );
        expect(
          (await database.select(database.trips).getSingle()).destinationJson,
          legacy,
        );
        expect((await repository.loadTrip(id))!.destination, 'Annecy');
      }
    },
  );

  test(
    'localisation et copie persistent après fermeture et réouverture SQLite',
    () async {
      final directory = await Directory.systemTemp.createTemp('city-restart-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/app.sqlite');
      var database = AppDatabase(NativeDatabase(file));
      var repository = DriftTripRepository(database);
      final id = await repository.createTrip(locatedTrip());
      final copy = await repository.duplicateTrip(
        DuplicateTripRequest(
          sourceTripId: id,
          name: rome.name,
          destination: rome.name,
          destinationLocation: rome,
          startDate: DateTime(2027, 1, 1),
          endDate: DateTime(2027, 1, 3),
        ),
      );
      await database.close();
      database = AppDatabase(NativeDatabase(file));
      addTearDown(database.close);
      repository = DriftTripRepository(database);
      expect(database.schemaVersion, 8);
      expect((await repository.loadTrip(id))!.destinationLatitude, 45.899);
      expect((await repository.loadTrip(copy))!.destinationLongitude, 12.5);
    },
  );
}
