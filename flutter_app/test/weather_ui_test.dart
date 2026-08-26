import 'package:checklist_voyage_v1/data/weather/open_meteo_remote.dart';
import 'package:checklist_voyage_v1/data/weather/weather_cache_store.dart';
import 'package:checklist_voyage_v1/core/theme/app_theme.dart';
import 'package:checklist_voyage_v1/domain/weather/trip_weather_service.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';
import 'package:checklist_voyage_v1/features/trips/weather_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 26);

  testWidgets('changer de jour conserve le fond et met à jour les icônes', (
    tester,
  ) async {
    final service = TripWeatherService(
      _UiWeatherRemote(),
      MemoryWeatherCacheStore(),
      clock: () => now,
    );
    await _pumpWeather(tester, service, now, days: 10);

    final background = tester.element(
      find.byKey(const Key('fake-map-background')),
    );
    expect(find.text('code-0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('weather-day-1')));
    await tester.pump();

    expect(
      tester.element(find.byKey(const Key('fake-map-background'))),
      same(background),
    );
    expect(find.text('code-1'), findsOneWidget);
  });

  testWidgets('la vraie carte garde son fond FlutterMap entre deux jours', (
    tester,
  ) async {
    final first = _weatherDay(now.add(const Duration(days: 1)), 0);
    final second = _weatherDay(now.add(const Duration(days: 2)), 61);
    final snapshot = TripWeatherSnapshot(
      cacheKey: 'map-stability',
      location: const WeatherLocation(
        name: 'Djerba',
        coordinates: WeatherCoordinates(latitude: 33.8, longitude: 10.8),
      ),
      days: [first, second],
      mapPoints: List.generate(
        9,
        (index) => WeatherMapPoint(
          id: 'grid-$index',
          coordinates: WeatherCoordinates(
            latitude: 30.8 + (index ~/ 3) * 3,
            longitude: 6.8 + (index % 3) * 4,
          ),
          days: {
            weatherDateKey(first.date): first,
            weatherDateKey(second.date): second,
          },
          isDestination: index == 4,
        ),
      ),
      updatedAt: now,
    );
    final selected = ValueNotifier(first);
    addTearDown(selected.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ValueListenableBuilder<WeatherDay>(
            valueListenable: selected,
            builder: (context, day, _) => WeatherMapView(
              snapshot: snapshot,
              selectedDay: day,
              backgroundBuilder: () => const ColoredBox(
                key: Key('controlled-map-background'),
                color: Colors.blueGrey,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final background = tester.element(
      find.byKey(const Key('controlled-map-background')),
    );
    expect(
      find.byKey(Key('weather-markers-${weatherDateKey(first.date)}')),
      findsOneWidget,
    );

    selected.value = second;
    await tester.pump();

    expect(
      tester.element(find.byKey(const Key('controlled-map-background'))),
      same(background),
    );
    expect(
      find.byKey(Key('weather-markers-${weatherDateKey(second.date)}')),
      findsOneWidget,
    );
  });

  testWidgets('la liste de 20 jours tient à 360 px en clair et sombre', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final service = TripWeatherService(
      _UiWeatherRemote(),
      MemoryWeatherCacheStore(),
      clock: () => now,
    );

    await _pumpWeather(tester, service, now, days: 20);
    await tester.tap(find.text('Prévisions'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weather-forecast-list')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pumpWeather(
      tester,
      service,
      now,
      days: 20,
      brightness: Brightness.dark,
    );
    await tester.tap(find.text('Prévisions'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpWeather(
  WidgetTester tester,
  TripWeatherService service,
  DateTime now, {
  required int days,
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: WeatherScreen(
        request: WeatherTripRequest(
          tripId: 'trip-ui',
          destination: 'Djerba',
          startDate: now.add(const Duration(days: 1)),
          endDate: now.add(Duration(days: days)),
        ),
        service: service,
        mapBuilder: (context, snapshot, selectedDay) => ColoredBox(
          key: const Key('fake-map-background'),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Center(
            child: Text('code-${selectedDay.date.difference(now).inDays - 1}'),
          ),
        ),
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
  Future<List<Map<String, WeatherDay>>> forecast({
    required List<WeatherCoordinates> points,
    required List<DateTime> dates,
  }) async => _values(points, dates, WeatherDataSource.forecast);

  @override
  Future<List<Map<String, WeatherDay>>> historicalTrend({
    required List<WeatherCoordinates> points,
    required List<DateTime> dates,
    required DateTime referenceDate,
  }) async => _values(points, dates, WeatherDataSource.historical);

  List<Map<String, WeatherDay>> _values(
    List<WeatherCoordinates> points,
    List<DateTime> dates,
    WeatherDataSource source,
  ) => List.generate(
    points.length,
    (point) => {
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
    },
  );

  @override
  void close() {}
}

WeatherDay _weatherDay(DateTime date, int code) => WeatherDay(
  date: date,
  source: WeatherDataSource.forecast,
  condition: weatherConditionForWmo(code),
  weatherCode: code,
  minTemperature: 18,
  maxTemperature: 25,
  precipitationProbability: 10,
  meanWindSpeed: 17,
);
