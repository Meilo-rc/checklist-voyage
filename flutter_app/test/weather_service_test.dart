import 'dart:io';

import 'package:checklist_voyage_v1/data/weather/open_meteo_remote.dart';
import 'package:checklist_voyage_v1/data/weather/weather_cache_store.dart';
import 'package:checklist_voyage_v1/domain/weather/trip_weather_service.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late MemoryWeatherCacheStore cache;
  late _FakeWeatherRemote remote;
  late TripWeatherService service;

  setUp(() {
    now = DateTime(2026, 8, 26, 8);
    cache = MemoryWeatherCacheStore();
    remote = _FakeWeatherRemote();
    service = TripWeatherService(remote, cache, clock: () => now);
  });

  test(
    'utilise les coordonnées enregistrées et conserve la source de chaque jour',
    () async {
      final result = await service.load(
        _request(
          start: now.add(const Duration(days: 14)),
          end: now.add(const Duration(days: 18)),
        ),
      );

      expect(remote.geocodeCalls, 0);
      expect(remote.forecastCalls, 1);
      expect(remote.historicalCalls, 1);
      expect(result.days.map((day) => day.source), [
        WeatherDataSource.forecast,
        WeatherDataSource.forecast,
        WeatherDataSource.historical,
        WeatherDataSource.historical,
        WeatherDataSource.historical,
      ]);
    },
  );

  test('un second chargement frais utilise uniquement le cache', () async {
    final request = _request(
      start: now.add(const Duration(days: 2)),
      end: now.add(const Duration(days: 5)),
    );
    await service.load(request);
    final forecastCalls = remote.forecastCalls;

    final result = await service.load(request);

    expect(result.fromCache, isTrue);
    expect(result.isStale, isFalse);
    expect(remote.forecastCalls, forecastCalls);
    expect(remote.geocodeCalls, 0);
  });

  test('hors ligne, le cache expiré reste disponible et est signalé', () async {
    final request = _request(
      start: now.add(const Duration(days: 2)),
      end: now.add(const Duration(days: 4)),
    );
    await service.load(request);
    now = now.add(const Duration(hours: 7));
    remote.offline = true;

    final result = await service.load(request);

    expect(result.fromCache, isTrue);
    expect(result.isStale, isTrue);
    expect(result.days, hasLength(3));
  });

  test('hors ligne sans cache donne le message attendu', () async {
    remote.offline = true;

    await expectLater(
      service.load(
        _request(
          start: now.add(const Duration(days: 2)),
          end: now.add(const Duration(days: 3)),
        ),
      ),
      throwsA(
        isA<WeatherUnavailable>().having(
          (error) => error.message,
          'message',
          'Connexion au service météo impossible.',
        ),
      ),
    );
  });

  test(
    'changer destination ou dates ne montre jamais un ancien cache',
    () async {
      final first = _request(
        start: now.add(const Duration(days: 2)),
        end: now.add(const Duration(days: 3)),
      );
      await service.load(first);
      remote.offline = true;

      await expectLater(
        service.load(
          WeatherTripRequest(
            tripId: first.tripId,
            destination: 'Rome',
            coordinates: const WeatherCoordinates(
              latitude: 41.9,
              longitude: 12.5,
            ),
            startDate: first.startDate,
            endDate: first.endDate,
          ),
        ),
        throwsA(isA<WeatherUnavailable>()),
      );
      await expectLater(
        service.load(
          WeatherTripRequest(
            tripId: first.tripId,
            destination: first.destination,
            coordinates: first.coordinates,
            startDate: first.startDate.add(const Duration(days: 1)),
            endDate: first.endDate.add(const Duration(days: 1)),
          ),
        ),
        throwsA(isA<WeatherUnavailable>()),
      );
    },
  );

  test('des coordonnées existantes évitent le géocodage', () async {
    final request = WeatherTripRequest(
      tripId: 'trip-1',
      destination: 'Djerba',
      startDate: now.add(const Duration(days: 2)),
      endDate: now.add(const Duration(days: 3)),
      coordinates: const WeatherCoordinates(
        latitude: 33.8076,
        longitude: 10.8451,
      ),
    );

    final result = await service.load(request);

    expect(remote.geocodeCalls, 0);
    expect(result.location.coordinates.latitude, 33.8076);
  });

  test(
    'ancien voyage sans coordonnées demande une sélection sans appel réseau',
    () async {
      await cache.writeGeocoding(
        'djerba',
        const WeatherLocation(
          name: 'Ancien premier résultat',
          coordinates: WeatherCoordinates(latitude: 1, longitude: 2),
        ),
      );
      await expectLater(
        service.load(
          WeatherTripRequest(
            tripId: 'legacy',
            destination: 'Djerba',
            startDate: now,
            endDate: now,
          ),
        ),
        throwsA(
          isA<WeatherUnavailable>().having(
            (error) => error.message,
            'message',
            contains('Sélectionne une ville'),
          ),
        ),
      );
      expect(remote.geocodeCalls, 0);
      expect(remote.forecastCalls, 0);
      expect(remote.historicalCalls, 0);
    },
  );
}

WeatherTripRequest _request({required DateTime start, required DateTime end}) =>
    WeatherTripRequest(
      tripId: 'trip-1',
      destination: 'Djerba',
      coordinates: const WeatherCoordinates(
        latitude: 33.8076,
        longitude: 10.8451,
      ),
      startDate: start,
      endDate: end,
    );

class _FakeWeatherRemote implements WeatherRemoteGateway {
  @override
  Future<List<WeatherLocation>> searchCities(String query) async => [
    await _location(query),
  ];

  int geocodeCalls = 0;
  int forecastCalls = 0;
  int historicalCalls = 0;
  bool offline = false;

  Future<WeatherLocation> _location(String destination) async {
    _checkOnline();
    geocodeCalls++;
    return WeatherLocation(
      name: destination,
      coordinates: const WeatherCoordinates(
        latitude: 33.8076,
        longitude: 10.8451,
      ),
    );
  }

  @override
  Future<Map<String, WeatherDay>> forecast({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
  }) async {
    _checkOnline();
    forecastCalls++;
    return _values(dates, WeatherDataSource.forecast, 1);
  }

  @override
  Future<Map<String, WeatherDay>> historicalTrend({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
    required DateTime referenceDate,
  }) async {
    _checkOnline();
    historicalCalls++;
    return _values(dates, WeatherDataSource.historical, 3);
  }

  Map<String, WeatherDay> _values(
    List<DateTime> dates,
    WeatherDataSource source,
    int code,
  ) => {
    for (final date in dates)
      weatherDateKey(date): WeatherDay(
        date: date,
        source: source,
        condition: weatherConditionForWmo(code),
        weatherCode: code,
        minTemperature: 17,
        maxTemperature: 24,
        precipitationProbability: 10,
        meanWindSpeed: 16,
      ),
  };

  void _checkOnline() {
    if (offline) throw const SocketException('offline');
  }

  @override
  void close() {}
}
