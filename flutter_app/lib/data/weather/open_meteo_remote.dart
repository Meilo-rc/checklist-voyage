import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/weather/weather_models.dart';

abstract interface class WeatherRemoteGateway {
  Future<WeatherLocation> geocode(String destination);

  Future<Map<String, WeatherDay>> forecast({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
  });

  Future<Map<String, WeatherDay>> historicalTrend({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
    required DateTime referenceDate,
  });

  void close();
}

class UnavailableWeatherRemote implements WeatherRemoteGateway {
  const UnavailableWeatherRemote();

  Never _unavailable() {
    throw const WeatherUnavailable('Météo indisponible hors ligne.');
  }

  @override
  Future<WeatherLocation> geocode(String destination) async => _unavailable();

  @override
  Future<Map<String, WeatherDay>> forecast({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
  }) async => _unavailable();

  @override
  Future<Map<String, WeatherDay>> historicalTrend({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
    required DateTime referenceDate,
  }) async => _unavailable();

  @override
  void close() {}
}

class OpenMeteoRemote implements WeatherRemoteGateway {
  OpenMeteoRemote({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _dailyVariables =
      'weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_sum,wind_speed_10m_mean';

  @override
  Future<WeatherLocation> geocode(String destination) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': destination,
      'count': '1',
      'language': 'fr',
      'format': 'json',
    });
    final json = await _getJson(uri);
    final results = json['results'];
    if (results is! List || results.isEmpty || results.first is! Map) {
      throw const WeatherUnavailable('Destination météo introuvable.');
    }
    final result = (results.first as Map).cast<String, Object?>();
    return WeatherLocation(
      name: result['name']?.toString() ?? destination,
      country: result['country']?.toString(),
      timezone: result['timezone']?.toString(),
      coordinates: WeatherCoordinates(
        latitude: (result['latitude'] as num).toDouble(),
        longitude: (result['longitude'] as num).toDouble(),
      ),
    );
  }

  @override
  Future<Map<String, WeatherDay>> forecast({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
  }) async {
    if (dates.isEmpty) return {};
    final sorted = [...dates]..sort();
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': coordinates.latitude.toString(),
      'longitude': coordinates.longitude.toString(),
      'daily': '$_dailyVariables,precipitation_probability_max',
      'timezone': 'auto',
      'start_date': weatherDateKey(sorted.first),
      'end_date': weatherDateKey(sorted.last),
    });
    return _parseDaily(
      await _getJson(uri),
      source: WeatherDataSource.forecast,
      allowedDates: dates,
    );
  }

  @override
  Future<Map<String, WeatherDay>> historicalTrend({
    required WeatherCoordinates coordinates,
    required List<DateTime> dates,
    required DateTime referenceDate,
  }) async {
    if (dates.isEmpty) return {};
    final sortedDates = [...dates]..sort();
    final samples = <Map<String, Object?>>[];
    // Five representative years, restricted to the trip's calendar period.
    // This avoids downloading complete years for the destination.
    for (var offset = 5; offset >= 1; offset--) {
      final sampleYear = referenceDate.year - offset;
      final sampleStart = _historicalDate(
        sortedDates.first,
        sortedDates.first,
        sampleYear,
      );
      final sampleEnd = _historicalDate(
        sortedDates.last,
        sortedDates.first,
        sampleYear,
      );
      final uri = Uri.https('archive-api.open-meteo.com', '/v1/archive', {
        'latitude': coordinates.latitude.toString(),
        'longitude': coordinates.longitude.toString(),
        'daily': _dailyVariables,
        'timezone': 'auto',
        'start_date': weatherDateKey(sampleStart),
        'end_date': weatherDateKey(sampleEnd),
      });
      samples.add(await _getJson(uri));
    }
    return _aggregateHistorical(samples, dates);
  }

  Map<String, WeatherDay> _parseDaily(
    Map<String, Object?> payload, {
    required WeatherDataSource source,
    required List<DateTime> allowedDates,
  }) {
    final daily = (payload['daily'] as Map?)?.cast<String, Object?>();
    if (daily == null) return {};
    final allowed = allowedDates.map(weatherDateKey).toSet();
    final times = _list(daily['time']);
    final result = <String, WeatherDay>{};
    for (var index = 0; index < times.length; index++) {
      final key = times[index]?.toString();
      if (key == null || !allowed.contains(key)) continue;
      final code = _numberAt(daily['weather_code'], index)?.toInt() ?? -1;
      final min = _numberAt(daily['temperature_2m_min'], index);
      final max = _numberAt(daily['temperature_2m_max'], index);
      if (min == null || max == null) continue;
      result[key] = WeatherDay(
        date: DateTime.parse(key),
        source: source,
        condition: weatherConditionForWmo(code),
        weatherCode: code,
        minTemperature: min.toDouble(),
        maxTemperature: max.toDouble(),
        precipitationProbability: _numberAt(
          daily['precipitation_probability_max'],
          index,
        )?.round(),
        precipitationMillimeters: _numberAt(
          daily['precipitation_sum'],
          index,
        )?.toDouble(),
        meanWindSpeed: _numberAt(
          daily['wind_speed_10m_mean'],
          index,
        )?.toDouble(),
      );
    }
    return result;
  }

  Map<String, WeatherDay> _aggregateHistorical(
    List<Map<String, Object?>> payloads,
    List<DateTime> targetDates,
  ) {
    final samples = <String, List<_HistoricalSample>>{};
    for (final payload in payloads) {
      final daily = (payload['daily'] as Map?)?.cast<String, Object?>();
      if (daily == null) continue;
      final times = _list(daily['time']);
      for (var index = 0; index < times.length; index++) {
        final raw = times[index]?.toString();
        if (raw == null) continue;
        final date = DateTime.tryParse(raw);
        final min = _numberAt(daily['temperature_2m_min'], index);
        final max = _numberAt(daily['temperature_2m_max'], index);
        if (date == null || min == null || max == null) continue;
        final monthDay = _monthDay(date);
        samples
            .putIfAbsent(monthDay, () => [])
            .add(
              _HistoricalSample(
                code: _numberAt(daily['weather_code'], index)?.toInt() ?? -1,
                min: min.toDouble(),
                max: max.toDouble(),
                precipitation: _numberAt(
                  daily['precipitation_sum'],
                  index,
                )?.toDouble(),
                wind: _numberAt(
                  daily['wind_speed_10m_mean'],
                  index,
                )?.toDouble(),
              ),
            );
      }
    }
    final result = <String, WeatherDay>{};
    for (final target in targetDates) {
      final values = samples[_monthDay(target)] ?? const <_HistoricalSample>[];
      if (values.isEmpty) continue;
      final code = _mode(values.map((value) => value.code));
      final rainSamples = values
          .where((value) => value.precipitation != null)
          .toList(growable: false);
      result[weatherDateKey(target)] = WeatherDay(
        date: target,
        source: WeatherDataSource.historical,
        condition: weatherConditionForWmo(code),
        weatherCode: code,
        minTemperature: _mean(values.map((value) => value.min)),
        maxTemperature: _mean(values.map((value) => value.max)),
        precipitationProbability: rainSamples.isEmpty
            ? null
            : (rainSamples
                          .where((value) => value.precipitation! >= 0.1)
                          .length /
                      rainSamples.length *
                      100)
                  .round(),
        precipitationMillimeters: rainSamples.isEmpty
            ? null
            : _mean(rainSamples.map((value) => value.precipitation!)),
        meanWindSpeed: _nullableMean(values.map((value) => value.wind)),
      );
    }
    return result;
  }

  Future<Map<String, Object?>> _getJson(Uri uri) async {
    final value = await _getDynamicJson(uri);
    if (value is! Map) throw const FormatException('Réponse météo invalide.');
    return value.cast<String, Object?>();
  }

  Future<Object?> _getDynamicJson(Uri uri) async {
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WeatherUnavailable('Open-Meteo a répondu ${response.statusCode}.');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  @override
  void close() => _client.close();
}

class _HistoricalSample {
  const _HistoricalSample({
    required this.code,
    required this.min,
    required this.max,
    required this.precipitation,
    required this.wind,
  });

  final int code;
  final double min;
  final double max;
  final double? precipitation;
  final double? wind;
}

List<Object?> _list(Object? value) => value is List ? value : const [];

num? _numberAt(Object? value, int index) {
  final values = _list(value);
  if (index >= values.length) return null;
  return values[index] as num?;
}

String _monthDay(DateTime value) =>
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

double _mean(Iterable<double> values) {
  var total = 0.0;
  var count = 0;
  for (final value in values) {
    total += value;
    count++;
  }
  return count == 0 ? double.nan : total / count;
}

double? _nullableMean(Iterable<double?> values) {
  final present = values.whereType<double>().toList(growable: false);
  return present.isEmpty ? null : _mean(present);
}

int _mode(Iterable<int> values) {
  final counts = <int, int>{};
  for (final value in values) {
    counts[value] = (counts[value] ?? 0) + 1;
  }
  if (counts.isEmpty) return -1;
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

DateTime _historicalDate(
  DateTime target,
  DateTime targetStart,
  int sampleStartYear,
) {
  final year = sampleStartYear + target.year - targetStart.year;
  final candidate = DateTime(year, target.month, target.day);
  if (candidate.month == target.month) return candidate;
  return DateTime(year, target.month + 1, 0);
}
