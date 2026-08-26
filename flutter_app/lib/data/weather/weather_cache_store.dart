import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/weather/weather_models.dart';

abstract interface class WeatherCacheStore {
  Future<WeatherLocation?> readGeocoding(String destinationKey);

  Future<void> writeGeocoding(String destinationKey, WeatherLocation location);

  Future<TripWeatherSnapshot?> readSnapshot(String cacheKey);

  Future<void> writeSnapshot(TripWeatherSnapshot snapshot);
}

class JsonFileWeatherCacheStore implements WeatherCacheStore {
  JsonFileWeatherCacheStore({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directoryProvider;
  Future<void> _writeQueue = Future.value();

  @override
  Future<WeatherLocation?> readGeocoding(String destinationKey) async {
    final data = await _readAll();
    final raw = (data['geocoding'] as Map?)?[destinationKey];
    if (raw is! Map) return null;
    try {
      return WeatherLocation.fromJson(raw.cast<String, Object?>());
    } on Object {
      return null;
    }
  }

  @override
  Future<void> writeGeocoding(
    String destinationKey,
    WeatherLocation location,
  ) => _serializedWrite(() async {
    final data = await _readAll();
    final geocoding = Map<String, Object?>.from(
      data['geocoding'] as Map? ?? const {},
    );
    geocoding[destinationKey] = location.toJson();
    data['geocoding'] = geocoding;
    await _writeAll(data);
  });

  @override
  Future<TripWeatherSnapshot?> readSnapshot(String cacheKey) async {
    final data = await _readAll();
    final raw = (data['snapshots'] as Map?)?[cacheKey];
    if (raw is! Map) return null;
    try {
      return TripWeatherSnapshot.fromJson(raw.cast<String, Object?>());
    } on Object {
      return null;
    }
  }

  @override
  Future<void> writeSnapshot(TripWeatherSnapshot snapshot) =>
      _serializedWrite(() async {
        final data = await _readAll();
        final snapshots = Map<String, Object?>.from(
          data['snapshots'] as Map? ?? const {},
        );
        snapshots[snapshot.cacheKey] = snapshot.toJson();
        data['snapshots'] = snapshots;
        await _writeAll(data);
      });

  Future<void> _serializedWrite(Future<void> Function() action) {
    final result = _writeQueue.then((_) => action());
    _writeQueue = result.catchError((_) {});
    return result;
  }

  Future<Map<String, Object?>> _readAll() async {
    final file = await _file();
    if (!await file.exists()) return _emptyData();
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) return decoded.cast<String, Object?>();
    } on Object {
      // A corrupt optional cache must never block the checklist.
    }
    return _emptyData();
  }

  Future<void> _writeAll(Map<String, Object?> data) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(data), flush: true);
    await temporary.rename(file.path);
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File(p.join(directory.path, 'weather', 'weather-cache-v1.json'));
  }
}

Map<String, Object?> _emptyData() => {
  'version': 1,
  'geocoding': <String, Object?>{},
  'snapshots': <String, Object?>{},
};

class MemoryWeatherCacheStore implements WeatherCacheStore {
  final Map<String, WeatherLocation> geocoding = {};
  final Map<String, TripWeatherSnapshot> snapshots = {};

  @override
  Future<WeatherLocation?> readGeocoding(String destinationKey) async =>
      geocoding[destinationKey];

  @override
  Future<void> writeGeocoding(
    String destinationKey,
    WeatherLocation location,
  ) async => geocoding[destinationKey] = location;

  @override
  Future<TripWeatherSnapshot?> readSnapshot(String cacheKey) async =>
      snapshots[cacheKey]?.copyWith(fromCache: true);

  @override
  Future<void> writeSnapshot(TripWeatherSnapshot snapshot) async =>
      snapshots[snapshot.cacheKey] = snapshot;
}
