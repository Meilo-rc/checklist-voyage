enum WeatherDataSource { forecast, historical }

enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
  unknown,
}

class WeatherCoordinates {
  const WeatherCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  Map<String, Object> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };

  factory WeatherCoordinates.fromJson(Map<String, Object?> json) =>
      WeatherCoordinates(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}

class WeatherLocation {
  const WeatherLocation({
    required this.name,
    required this.coordinates,
    this.country,
    this.timezone,
  });

  final String name;
  final WeatherCoordinates coordinates;
  final String? country;
  final String? timezone;

  Map<String, Object?> toJson() => {
    'name': name,
    'coordinates': coordinates.toJson(),
    'country': country,
    'timezone': timezone,
  };

  factory WeatherLocation.fromJson(Map<String, Object?> json) =>
      WeatherLocation(
        name: json['name'] as String,
        coordinates: WeatherCoordinates.fromJson(
          (json['coordinates'] as Map).cast<String, Object?>(),
        ),
        country: json['country'] as String?,
        timezone: json['timezone'] as String?,
      );
}

class WeatherDay {
  const WeatherDay({
    required this.date,
    required this.source,
    required this.condition,
    required this.weatherCode,
    required this.minTemperature,
    required this.maxTemperature,
    this.precipitationProbability,
    this.precipitationMillimeters,
    this.meanWindSpeed,
  });

  final DateTime date;
  final WeatherDataSource source;
  final WeatherCondition condition;
  final int weatherCode;
  final double minTemperature;
  final double maxTemperature;
  final int? precipitationProbability;
  final double? precipitationMillimeters;
  final double? meanWindSpeed;

  Map<String, Object?> toJson() => {
    'date': _dateKey(date),
    'source': source.name,
    'condition': condition.name,
    'weather_code': weatherCode,
    'min_temperature': minTemperature,
    'max_temperature': maxTemperature,
    'precipitation_probability': precipitationProbability,
    'precipitation_millimeters': precipitationMillimeters,
    'mean_wind_speed': meanWindSpeed,
  };

  factory WeatherDay.fromJson(Map<String, Object?> json) => WeatherDay(
    date: DateTime.parse(json['date'] as String),
    source: WeatherDataSource.values.byName(json['source'] as String),
    condition: WeatherCondition.values.byName(json['condition'] as String),
    weatherCode: (json['weather_code'] as num).toInt(),
    minTemperature: (json['min_temperature'] as num).toDouble(),
    maxTemperature: (json['max_temperature'] as num).toDouble(),
    precipitationProbability: (json['precipitation_probability'] as num?)
        ?.toInt(),
    precipitationMillimeters: (json['precipitation_millimeters'] as num?)
        ?.toDouble(),
    meanWindSpeed: (json['mean_wind_speed'] as num?)?.toDouble(),
  );
}

class TripWeatherSnapshot {
  const TripWeatherSnapshot({
    required this.cacheKey,
    required this.location,
    required this.days,
    required this.updatedAt,
    this.forecastUpdatedAt,
    this.historicalUpdatedAt,
    this.isStale = false,
    this.fromCache = false,
  });

  final String cacheKey;
  final WeatherLocation location;
  final List<WeatherDay> days;
  final DateTime updatedAt;
  final DateTime? forecastUpdatedAt;
  final DateTime? historicalUpdatedAt;
  final bool isStale;
  final bool fromCache;

  TripWeatherSnapshot copyWith({
    List<WeatherDay>? days,
    DateTime? updatedAt,
    DateTime? forecastUpdatedAt,
    DateTime? historicalUpdatedAt,
    bool? isStale,
    bool? fromCache,
  }) => TripWeatherSnapshot(
    cacheKey: cacheKey,
    location: location,
    days: days ?? this.days,
    updatedAt: updatedAt ?? this.updatedAt,
    forecastUpdatedAt: forecastUpdatedAt ?? this.forecastUpdatedAt,
    historicalUpdatedAt: historicalUpdatedAt ?? this.historicalUpdatedAt,
    isStale: isStale ?? this.isStale,
    fromCache: fromCache ?? this.fromCache,
  );

  Map<String, Object?> toJson() => {
    'cache_key': cacheKey,
    'location': location.toJson(),
    'days': days.map((day) => day.toJson()).toList(growable: false),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'forecast_updated_at': forecastUpdatedAt?.toUtc().toIso8601String(),
    'historical_updated_at': historicalUpdatedAt?.toUtc().toIso8601String(),
  };

  factory TripWeatherSnapshot.fromJson(Map<String, Object?> json) =>
      TripWeatherSnapshot(
        cacheKey: json['cache_key'] as String,
        location: WeatherLocation.fromJson(
          (json['location'] as Map).cast<String, Object?>(),
        ),
        days: (json['days'] as List)
            .map(
              (day) =>
                  WeatherDay.fromJson((day as Map).cast<String, Object?>()),
            )
            .toList(growable: false),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        forecastUpdatedAt: _optionalDate(json['forecast_updated_at']),
        historicalUpdatedAt: _optionalDate(json['historical_updated_at']),
        fromCache: true,
      );
}

class WeatherTripRequest {
  const WeatherTripRequest({
    required this.tripId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.coordinates,
  });

  final String tripId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final WeatherCoordinates? coordinates;
}

class WeatherUnavailable implements Exception {
  const WeatherUnavailable(this.message);

  final String message;

  @override
  String toString() => message;
}

DateTime? _optionalDate(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.parse(value) : null;

String weatherDateKey(DateTime date) => _dateKey(date);

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

WeatherCondition weatherConditionForWmo(int code) {
  if (code == 0) return WeatherCondition.clear;
  if (code == 1 || code == 2) return WeatherCondition.partlyCloudy;
  if (code == 3) return WeatherCondition.cloudy;
  if (code == 45 || code == 48) return WeatherCondition.fog;
  if (code >= 51 && code <= 57) return WeatherCondition.drizzle;
  if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
    return WeatherCondition.rain;
  }
  if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
    return WeatherCondition.snow;
  }
  if (code >= 95 && code <= 99) return WeatherCondition.thunderstorm;
  return WeatherCondition.unknown;
}
