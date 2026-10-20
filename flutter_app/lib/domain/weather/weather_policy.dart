import 'weather_models.dart';

typedef WeatherClock = DateTime Function();

class WeatherWindowPolicy {
  const WeatherWindowPolicy({required this.clock});

  final WeatherClock clock;

  WeatherDataSource sourceFor(DateTime date) {
    final today = _day(clock());
    final target = _day(date);
    // Open-Meteo's 16-day range includes today and excludes today + 16.
    final lastForecastDay = today.add(const Duration(days: 15));
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

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
