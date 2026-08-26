import 'package:checklist_voyage_v1/core/theme/app_theme.dart';
import 'package:checklist_voyage_v1/data/weather/open_meteo_remote.dart';
import 'package:checklist_voyage_v1/data/weather/weather_cache_store.dart';
import 'package:checklist_voyage_v1/domain/weather/trip_weather_service.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';
import 'package:checklist_voyage_v1/features/trips/weather_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 26);

  testWidgets('affiche directement trois jours sans carte à 360 px', (
    tester,
  ) async {
    _setPhoneSize(tester);
    await _pumpWeather(
      tester,
      now,
      days: 3,
      destination: 'Saint-Rémy-de-Provence et ses environs',
    );

    expect(find.byKey(const Key('weather-forecast-list')), findsOneWidget);
    expect(find.text('Carte'), findsNothing);
    expect(find.byKey(const Key('weather-view-selector')), findsNothing);
    expect(find.byKey(const Key('weather-map-background')), findsNothing);
    expect(find.text('Prévision'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('affiche dix jours en clair à 360 px', (tester) async {
    _setPhoneSize(tester);
    await _pumpWeather(tester, now, days: 10);

    expect(find.byKey(const Key('weather-forecast-list')), findsOneWidget);
    expect(find.text('Prévision'), findsNWidgets(10));
    expect(tester.takeException(), isNull);
  });

  testWidgets('un séjour mixte de vingt jours tient en sombre à 360 px', (
    tester,
  ) async {
    _setPhoneSize(tester);
    await _pumpWeather(tester, now, days: 20, brightness: Brightness.dark);

    expect(find.byKey(const Key('weather-forecast-list')), findsOneWidget);
    expect(find.text('Prévision'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(
        Key(
          'weather-forecast-${weatherDateKey(now.add(const Duration(days: 20)))}',
        ),
      ),
      300,
      scrollable: find.descendant(
        of: find.byKey(const Key('weather-forecast-list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tendance habituelle'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _pumpWeather(
  WidgetTester tester,
  DateTime now, {
  required int days,
  String destination = 'Djerba',
  Brightness brightness = Brightness.light,
}) async {
  final service = TripWeatherService(
    _UiWeatherRemote(),
    MemoryWeatherCacheStore(),
    clock: () => now,
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: WeatherScreen(
        request: WeatherTripRequest(
          tripId: 'trip-ui-$days',
          destination: destination,
          startDate: now.add(const Duration(days: 1)),
          endDate: now.add(Duration(days: days)),
        ),
        service: service,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _UiWeatherRemote implements WeatherRemoteGateway {
  @override
  Future<WeatherLocation> geocode(String destination) async => WeatherLocation(
    name: destination,
    coordinates: const WeatherCoordinates(latitude: 33.8, longitude: 10.8),
  );

  @override
  Future<Map<String, WeatherDay>> forecast({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
  }) async => _values(dates, WeatherDataSource.forecast);

  @override
  Future<Map<String, WeatherDay>> historicalTrend({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
    required DateTime referenceDate,
  }) async => _values(dates, WeatherDataSource.historical);

  Map<String, WeatherDay> _values(
    List<DateTime> dates,
    WeatherDataSource source,
  ) => {
    for (var index = 0; index < dates.length; index++)
      weatherDateKey(dates[index]): WeatherDay(
        date: dates[index],
        source: source,
        condition: index.isEven
            ? WeatherCondition.clear
            : WeatherCondition.rain,
        weatherCode: index,
        minTemperature: 18,
        maxTemperature: 25,
        precipitationProbability: 10,
        meanWindSpeed: 17,
      ),
  };

  @override
  void close() {}
}
