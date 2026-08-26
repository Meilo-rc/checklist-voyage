import 'dart:math' as math;

import 'weather_models.dart';

typedef WeatherClock = DateTime Function();

class WeatherWindowPolicy {
  const WeatherWindowPolicy({required this.clock});

  final WeatherClock clock;

  WeatherDataSource sourceFor(DateTime date) {
    final today = _day(clock());
    final target = _day(date);
    final lastForecastDay = today.add(const Duration(days: 16));
    return !target.isBefore(today) && !target.isAfter(lastForecastDay)
        ? WeatherDataSource.forecast
        : WeatherDataSource.historical;
  }

  Map<WeatherDataSource, List<DateTime>> split(DateTime start, DateTime end) {
    final result = <WeatherDataSource, List<DateTime>>{
      WeatherDataSource.forecast: [],
      WeatherDataSource.historical: [],
    };
    for (
      var day = _day(start);
      !day.isAfter(_day(end));
      day = day.add(const Duration(days: 1))
    ) {
      result[sourceFor(day)]!.add(day);
    }
    return result;
  }
}

class WeatherGrid {
  const WeatherGrid({required this.points, required this.zoom});

  final List<WeatherCoordinates> points;
  final double zoom;
}

class WeatherGridCalculator {
  const WeatherGridCalculator();

  /// A 3 × 3 regional grid: nine representative points, including destination.
  WeatherGrid around(WeatherCoordinates center) {
    const latitudeSpan = 3.0;
    final cosine = math.cos(center.latitude * math.pi / 180).abs();
    final longitudeSpan = (3.8 / math.max(cosine, 0.35)).clamp(3.8, 8.0);
    final points = <WeatherCoordinates>[];
    for (final latOffset in const [-latitudeSpan, 0.0, latitudeSpan]) {
      for (final lonOffset in [-longitudeSpan, 0.0, longitudeSpan]) {
        points.add(
          WeatherCoordinates(
            latitude: (center.latitude + latOffset).clamp(-85.0, 85.0),
            longitude: _wrapLongitude(center.longitude + lonOffset),
          ),
        );
      }
    }
    return WeatherGrid(points: points, zoom: 4.6);
  }
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

double _wrapLongitude(double value) {
  var result = value;
  while (result > 180) {
    result -= 360;
  }
  while (result < -180) {
    result += 360;
  }
  return result;
}
