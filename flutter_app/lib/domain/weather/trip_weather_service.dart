import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../data/weather/open_meteo_remote.dart';
import '../../data/weather/weather_cache_store.dart';
import 'weather_models.dart';
import 'weather_policy.dart';

class TripWeatherService {
  TripWeatherService(
    this._remote,
    this._cache, {
    WeatherClock? clock,
    this._gridCalculator = const WeatherGridCalculator(),
  }) : _clock = clock ?? DateTime.now;

  final WeatherRemoteGateway _remote;
  final WeatherCacheStore _cache;
  final WeatherClock _clock;
  final WeatherGridCalculator _gridCalculator;

  static const forecastTtl = Duration(hours: 6);
  static const historicalTtl = Duration(days: 90);

  Future<TripWeatherSnapshot> load(WeatherTripRequest request) async {
    _validate(request);
    final now = _clock();
    final cacheKey = weatherCacheKey(request);
    final cached = await _cache.readSnapshot(cacheKey);
    final policy = WeatherWindowPolicy(clock: _clock);
    final split = policy.split(request.startDate, request.endDate);
    final forecastDates = split[WeatherDataSource.forecast]!;
    final historicalDates = split[WeatherDataSource.historical]!;
    final forecastFresh = _sourceIsFresh(
      cached,
      forecastDates,
      WeatherDataSource.forecast,
      cached?.forecastUpdatedAt,
      forecastTtl,
      now,
    );
    final historicalFresh = _sourceIsFresh(
      cached,
      historicalDates,
      WeatherDataSource.historical,
      cached?.historicalUpdatedAt,
      historicalTtl,
      now,
    );
    if (cached != null && forecastFresh && historicalFresh) {
      return cached.copyWith(isStale: false, fromCache: true);
    }

    try {
      final location = await _resolveLocation(request, cached);
      final grid = _gridCalculator.around(location.coordinates);
      var points = _seedPoints(grid.points, cached);
      var forecastUpdatedAt = cached?.forecastUpdatedAt;
      var historicalUpdatedAt = cached?.historicalUpdatedAt;

      if (!forecastFresh && forecastDates.isNotEmpty) {
        final fetched = await _remote.forecast(
          points: grid.points,
          dates: forecastDates,
        );
        points = _merge(points, fetched, WeatherDataSource.forecast);
        forecastUpdatedAt = now;
      }
      if (!historicalFresh && historicalDates.isNotEmpty) {
        final fetched = await _remote.historicalTrend(
          points: grid.points,
          dates: historicalDates,
          referenceDate: now,
        );
        points = _merge(points, fetched, WeatherDataSource.historical);
        historicalUpdatedAt = now;
      }

      final destinationDays = _orderedDays(
        points[4].days,
        request.startDate,
        request.endDate,
      );
      if (destinationDays.length != _dayCount(request)) {
        throw const WeatherUnavailable(
          'Données météo journalières incomplètes.',
        );
      }
      final snapshot = TripWeatherSnapshot(
        cacheKey: cacheKey,
        location: location,
        days: destinationDays,
        mapPoints: points,
        updatedAt: now,
        forecastUpdatedAt: forecastUpdatedAt,
        historicalUpdatedAt: historicalUpdatedAt,
      );
      await _cache.writeSnapshot(snapshot);
      return snapshot;
    } on Object catch (error) {
      if (cached != null && _covers(cached, request)) {
        return cached.copyWith(isStale: true, fromCache: true);
      }
      if (error is WeatherUnavailable) rethrow;
      throw const WeatherUnavailable('Météo indisponible hors ligne.');
    }
  }

  Future<WeatherLocation> _resolveLocation(
    WeatherTripRequest request,
    TripWeatherSnapshot? cached,
  ) async {
    if (request.coordinates case final coordinates?) {
      return WeatherLocation(
        name: request.destination,
        coordinates: coordinates,
      );
    }
    if (cached != null) return cached.location;
    final destinationKey = normalizeWeatherDestination(request.destination);
    final geocoded = await _cache.readGeocoding(destinationKey);
    if (geocoded != null) return geocoded;
    final location = await _remote.geocode(request.destination);
    await _cache.writeGeocoding(destinationKey, location);
    return location;
  }

  List<WeatherMapPoint> _seedPoints(
    List<WeatherCoordinates> coordinates,
    TripWeatherSnapshot? cached,
  ) => List.generate(coordinates.length, (index) {
    final previous = cached?.mapPoints
        .where((point) => point.id == 'grid-$index')
        .firstOrNull;
    return WeatherMapPoint(
      id: 'grid-$index',
      coordinates: coordinates[index],
      days: Map<String, WeatherDay>.from(previous?.days ?? const {}),
      isDestination: index == 4,
    );
  });

  List<WeatherMapPoint> _merge(
    List<WeatherMapPoint> points,
    List<Map<String, WeatherDay>> fetched,
    WeatherDataSource source,
  ) {
    if (points.length != fetched.length) {
      throw const WeatherUnavailable('Grille météo incomplète.');
    }
    return List.generate(points.length, (index) {
      final merged = Map<String, WeatherDay>.from(points[index].days)
        ..removeWhere((_, day) => day.source == source)
        ..addAll(fetched[index]);
      return WeatherMapPoint(
        id: points[index].id,
        coordinates: points[index].coordinates,
        days: merged,
        isDestination: points[index].isDestination,
      );
    });
  }

  bool _sourceIsFresh(
    TripWeatherSnapshot? snapshot,
    List<DateTime> dates,
    WeatherDataSource source,
    DateTime? fetchedAt,
    Duration ttl,
    DateTime now,
  ) {
    if (dates.isEmpty) return true;
    if (snapshot == null || fetchedAt == null) return false;
    if (now.toUtc().difference(fetchedAt.toUtc()) > ttl) return false;
    final needed = dates.map(weatherDateKey).toSet();
    for (final point in snapshot.mapPoints) {
      if (!needed.every((key) => point.days[key]?.source == source)) {
        return false;
      }
    }
    return true;
  }

  bool _covers(TripWeatherSnapshot snapshot, WeatherTripRequest request) {
    if (snapshot.days.length != _dayCount(request)) return false;
    final keys = snapshot.days.map((day) => weatherDateKey(day.date)).toSet();
    for (
      var day = _day(request.startDate);
      !day.isAfter(_day(request.endDate));
      day = day.add(const Duration(days: 1))
    ) {
      if (!keys.contains(weatherDateKey(day))) {
        return false;
      }
    }
    return true;
  }

  List<WeatherDay> _orderedDays(
    Map<String, WeatherDay> values,
    DateTime start,
    DateTime end,
  ) {
    final result = <WeatherDay>[];
    for (
      var day = _day(start);
      !day.isAfter(_day(end));
      day = day.add(const Duration(days: 1))
    ) {
      final value = values[weatherDateKey(day)];
      if (value != null) result.add(value);
    }
    return result;
  }

  void close() => _remote.close();
}

String normalizeWeatherDestination(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String weatherCacheKey(WeatherTripRequest request) {
  final payload = jsonEncode({
    'destination': normalizeWeatherDestination(request.destination),
    'latitude': request.coordinates?.latitude,
    'longitude': request.coordinates?.longitude,
    'start': weatherDateKey(request.startDate),
    'end': weatherDateKey(request.endDate),
  });
  return sha256.convert(utf8.encode(payload)).toString();
}

void _validate(WeatherTripRequest request) {
  if (request.destination.trim().isEmpty) {
    throw const WeatherUnavailable('Destination requise pour la météo.');
  }
  if (request.endDate.isBefore(request.startDate)) {
    throw const WeatherUnavailable('Dates du voyage invalides.');
  }
}

int _dayCount(WeatherTripRequest request) =>
    _day(request.endDate).difference(_day(request.startDate)).inDays + 1;

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
