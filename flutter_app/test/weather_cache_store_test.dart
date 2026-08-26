import 'dart:io';

import 'package:checklist_voyage_v1/data/weather/weather_cache_store.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le cache JSON persiste géocodage, jours et timestamp', () async {
    final directory = await Directory.systemTemp.createTemp('cv-weather-');
    addTearDown(() => directory.delete(recursive: true));
    final first = JsonFileWeatherCacheStore(
      directoryProvider: () async => directory,
    );
    const location = WeatherLocation(
      name: 'Djerba',
      coordinates: WeatherCoordinates(latitude: 33.8, longitude: 10.8),
    );
    final day = WeatherDay(
      date: DateTime(2026, 9, 1),
      source: WeatherDataSource.forecast,
      condition: WeatherCondition.clear,
      weatherCode: 0,
      minTemperature: 18,
      maxTemperature: 26,
    );
    final snapshot = TripWeatherSnapshot(
      cacheKey: 'cache-key',
      location: location,
      days: [day],
      updatedAt: DateTime.utc(2026, 8, 26),
      forecastUpdatedAt: DateTime.utc(2026, 8, 26),
    );
    await first.writeGeocoding('djerba', location);
    await first.writeSnapshot(snapshot);

    final reopened = JsonFileWeatherCacheStore(
      directoryProvider: () async => directory,
    );
    final restoredLocation = await reopened.readGeocoding('djerba');
    final restored = await reopened.readSnapshot('cache-key');

    expect(restoredLocation?.coordinates.latitude, 33.8);
    expect(restored?.days.single.maxTemperature, 26);
    expect(restored?.forecastUpdatedAt, DateTime.utc(2026, 8, 26));
    expect(restored?.fromCache, isTrue);
  });

  test('un ancien cache RC10 ignore ses données cartographiques', () {
    final day = WeatherDay(
      date: DateTime(2026, 9, 1),
      source: WeatherDataSource.forecast,
      condition: WeatherCondition.clear,
      weatherCode: 0,
      minTemperature: 18,
      maxTemperature: 26,
    );
    final json = TripWeatherSnapshot(
      cacheKey: 'ancien-cache',
      location: const WeatherLocation(
        name: 'Djerba',
        coordinates: WeatherCoordinates(latitude: 33.8, longitude: 10.8),
      ),
      days: [day],
      updatedAt: DateTime.utc(2026, 8, 26),
    ).toJson();
    json['map_points'] = [
      {'id': 'ancienne-grille-devenue-inutile'},
    ];

    final restored = TripWeatherSnapshot.fromJson(json);

    expect(restored.days.single.maxTemperature, 26);
    expect(restored.cacheKey, 'ancien-cache');
  });
}
