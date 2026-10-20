import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/core/sharing/share_invitation.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/in_memory_sync_remote.dart';

import 'helpers/city_test_weather.dart';

void main() {
  testWidgets('Dupliquer un ancien voyage exige une ville sans champ Nom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final database = AppDatabase(NativeDatabase.memory());
    final app = await AppDependencies.create(
      database: database,
      autoSync: false,
      weather: cityTestWeather(),
      syncRemote: InMemorySyncRemote(),
      documentRemote: InMemorySharedDocumentRemote(),
    );
    addTearDown(app.close);
    final id = await app.trips.createTrip(_legacyRequest());
    await tester.pumpWidget(ChecklistApp(dependencies: app));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annecy').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trip-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dupliquer'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trip-duplicate-name')), findsNothing);
    await tester.tap(find.byKey(const Key('trip-duplicate-submit')));
    await tester.pump();
    expect(
      find.text('Sélectionne une ville dans les suggestions.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('trip-duplicate-destination')),
      'Rome',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('city-suggestion-0')));
    await tester.tap(find.byKey(const Key('city-suggestion-0')));
    await tester.pumpAndSettle();
    for (final key in ['trip-duplicate-start', 'trip-duplicate-end']) {
      final button = find.byKey(Key(key));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      final confirm = find
          .descendant(
            of: find.byType(DatePickerDialog),
            matching: find.byType(TextButton),
          )
          .last;
      await tester.tap(confirm);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const Key('trip-duplicate-submit')));
    await tester.pumpAndSettle();
    final rows = await database.select(database.trips).get();
    expect(rows, hasLength(2));
    final copy = rows.singleWhere((row) => row.id != id);
    expect(copy.name, 'Rome');
    expect(
      (await app.trips.watchTrip(copy.id).first)!.destinationLatitude,
      45.9,
    );
    expect((await app.trips.watchTrip(id).first)!.destination, 'Annecy');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'le partage utilise la destination courante et garde le même code',
    (tester) async {
      final share = _CapturingShare();
      final app = await AppDependencies.create(
        database: AppDatabase(NativeDatabase.memory()),
        autoSync: false,
        syncRemote: InMemorySyncRemote(),
        documentRemote: InMemorySharedDocumentRemote(),
        shareInvitations: share,
      );
      addTearDown(app.close);
      final id = await app.trips.createTrip(_legacyRequest());
      final access = await app.sharedDocuments.shareTrip(id);
      await app.trips.updateTripDetails(
        UpdateTripDetailsRequest(
          tripId: id,
          name: 'Ancien nom',
          destination: 'Rome',
          destinationLocation: const WeatherLocation(
            name: 'Rome',
            coordinates: WeatherCoordinates(latitude: 41.9, longitude: 12.5),
          ),
          startDate: null,
          endDate: null,
        ),
      );
      await tester.pumpWidget(ChecklistApp(dependencies: app));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Rome').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rome').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trip-show-code')));
      await tester.pumpAndSettle();
      expect(share.invitation!.displayName, 'Rome');
      expect(share.invitation!.code, access.shareCode);
      expect((await app.trips.watchTrip(id).first)!.name, 'Ancien nom');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    },
  );
}

CreateTripRequest _legacyRequest() => const CreateTripRequest(
  name: 'Ancien nom',
  destination: 'Annecy',
  startDate: null,
  endDate: null,
  participantOwnerIds: {},
  transportOwnerIds: {},
  lodgingOwnerIds: {},
  includeEssentials: false,
);

class _CapturingShare extends UnavailableShareInvitationGateway {
  ShareInvitation? invitation;
  @override
  Future<void> share(ShareInvitation invitation) async =>
      this.invitation = invitation;
}
