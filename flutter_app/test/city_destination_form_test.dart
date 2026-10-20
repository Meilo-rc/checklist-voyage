import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';
import 'package:checklist_voyage_v1/features/trips/city_destination_field.dart';
import 'package:checklist_voyage_v1/features/trips/trip_form.dart';

const frenchCity = WeatherLocation(
  name: 'Paris',
  region: 'Île-de-France',
  country: 'France',
  coordinates: WeatherCoordinates(latitude: 48.85, longitude: 2.35),
);
const americanCity = WeatherLocation(
  name: 'Paris',
  region: 'Texas',
  country: 'États-Unis',
  coordinates: WeatherCoordinates(latitude: 33.66, longitude: -95.55),
);

Future<void> openForm(
  WidgetTester tester,
  void Function(TripFormResult) saved, {
  TripFormInitialData initial = const TripFormInitialData(),
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<TripFormResult>(
                MaterialPageRoute(
                  builder: (_) => TripForm(
                    title: 'Voyage',
                    submitLabel: 'Enregistrer',
                    owners: const [],
                    contexts: const [],
                    initialData: initial,
                    searchCities: (_) async => [frenchCity, americanCity],
                  ),
                ),
              );
              if (result != null) saved(result);
            },
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Ouvrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'création exige une sélection et distingue les villes homonymes',
    (tester) async {
      TripFormResult? saved;
      await openForm(tester, (result) => saved = result);
      await tester.enterText(
        find.byKey(const Key('trip-destination')),
        'Paris',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Île-de-France, France'), findsOneWidget);
      expect(find.text('Texas, États-Unis'), findsOneWidget);
      await tester.tap(find.byKey(const Key('trip-submit')));
      await tester.pump();
      expect(saved, isNull);
      expect(
        find.text('Sélectionne une ville dans les suggestions.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('city-suggestion-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trip-submit')));
      await tester.pumpAndSettle();
      expect(saved!.destinationLocation!.coordinates.longitude, -95.55);
      expect(saved!.name, 'Paris');
    },
  );

  testWidgets(
    'édition ancienne inchangée sans coordonnées reste enregistrable',
    (tester) async {
      TripFormResult? saved;
      await openForm(
        tester,
        (result) => saved = result,
        initial: const TripFormInitialData(
          name: 'Vacances',
          destination: 'Lieu ancien',
        ),
      );
      await tester.tap(find.byKey(const Key('trip-submit')));
      await tester.pumpAndSettle();
      expect(saved!.destination, 'Lieu ancien');
      expect(saved!.destinationLocation, isNull);
    },
  );

  testWidgets('retaper après une sélection invalide ses coordonnées', (
    tester,
  ) async {
    TripFormResult? saved;
    await openForm(
      tester,
      (result) => saved = result,
      initial: const TripFormInitialData(destination: 'Lieu ancien'),
    );
    await tester.enterText(find.byKey(const Key('trip-destination')), 'Paris');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('city-suggestion-0')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('trip-destination')),
      'Paris modifié',
    );
    await tester.tap(find.byKey(const Key('trip-submit')));
    await tester.pump();
    expect(saved, isNull);
    expect(
      find.text('Sélectionne une ville dans les suggestions.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('city-suggestion-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trip-submit')));
    await tester.pumpAndSettle();
    expect(saved!.destinationLocation!.coordinates.latitude, 48.85);
  });

  testWidgets(
    'une réponse tardive ne remplace pas la recherche la plus récente',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final first = Completer<List<WeatherLocation>>();
      final second = Completer<List<WeatherLocation>>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CityDestinationField(
              controller: controller,
              onSelected: (_) {},
              search: (query) => query == 'Pa' ? first.future : second.future,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Pa');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(find.byType(TextField), 'Paris');
      await tester.pump(const Duration(milliseconds: 400));
      second.complete([americanCity]);
      await tester.pumpAndSettle();
      first.complete([frenchCity]);
      await tester.pumpAndSettle();
      expect(find.text('Texas, États-Unis'), findsOneWidget);
      expect(find.text('Île-de-France, France'), findsNothing);
    },
  );
}
