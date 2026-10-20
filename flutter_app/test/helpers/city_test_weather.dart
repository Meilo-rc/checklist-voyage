import 'package:checklist_voyage_v1/data/weather/open_meteo_remote.dart';
import 'package:checklist_voyage_v1/data/weather/weather_cache_store.dart';
import 'package:checklist_voyage_v1/domain/weather/trip_weather_service.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';

TripWeatherService cityTestWeather() =>
    TripWeatherService(_CityRemote(), MemoryWeatherCacheStore());

class _CityRemote extends UnavailableWeatherRemote {
  @override
  Future<List<WeatherLocation>> searchCities(String query) async => [
    WeatherLocation(
      name: query,
      region: 'Région test',
      country: 'France',
      coordinates: const WeatherCoordinates(latitude: 45.9, longitude: 6.1),
    ),
  ];
}
