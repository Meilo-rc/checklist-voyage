import 'dart:convert';

import 'package:checklist_voyage_v1/data/weather/open_meteo_remote.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'utilise uniquement Open-Meteo et agrège cinq périodes ciblées',
    () async {
      final requested = <Uri>[];
      final client = MockClient((request) async {
        requested.add(request.url);
        if (request.url.host == 'geocoding-api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'name': 'Djerba',
                  'country': 'Tunisie',
                  'latitude': 33.8,
                  'longitude': 10.8,
                  'timezone': 'Africa/Tunis',
                },
              ],
            }),
            200,
          );
        }
        if (request.url.host == 'api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'daily': {
                'time': ['2026-09-01'],
                'weather_code': [1],
                'temperature_2m_min': [18.0],
                'temperature_2m_max': [26.0],
                'precipitation_probability_max': [10],
                'precipitation_sum': [0.0],
                'wind_speed_10m_mean': [14.0],
              },
            }),
            200,
          );
        }
        final year = int.parse(
          request.url.queryParameters['start_date']!.substring(0, 4),
        );
        final index = year - 2021;
        return http.Response(
          jsonEncode({
            'daily': {
              'time': ['$year-09-01'],
              'weather_code': [index == 0 || index == 4 ? 3 : 1],
              'temperature_2m_min': [16.0 + index],
              'temperature_2m_max': [24.0 + index],
              'precipitation_sum': [index.isOdd ? 1.0 : 0.0],
              'wind_speed_10m_mean': [10.0 + index * 2],
            },
          }),
          200,
        );
      });
      final remote = OpenMeteoRemote(client: client);

      final location = await remote.geocode('Djerba');
      final forecast = await remote.forecast(
        coordinates: location.coordinates,
        dates: [DateTime(2026, 9, 1)],
      );
      final historical = await remote.historicalTrend(
        coordinates: location.coordinates,
        dates: [DateTime(2026, 9, 1)],
        referenceDate: DateTime(2026, 8, 26),
      );

      expect(
        requested.map((uri) => uri.host),
        containsAll({
          'geocoding-api.open-meteo.com',
          'api.open-meteo.com',
          'archive-api.open-meteo.com',
        }),
      );
      expect(
        requested.expand((uri) => uri.queryParameters.keys),
        isNot(contains(anyOf('trip_id', 'installation_id', 'share_code'))),
      );
      expect(forecast.values.single.source, WeatherDataSource.forecast);
      final trend = historical.values.single;
      expect(trend.source, WeatherDataSource.historical);
      expect(trend.minTemperature, 18);
      expect(trend.maxTemperature, 26);
      expect(trend.precipitationProbability, 40);
      expect(trend.meanWindSpeed, 14);
      expect(trend.condition, WeatherCondition.partlyCloudy);
      final archiveRequests = requested
          .where((uri) => uri.host == 'archive-api.open-meteo.com')
          .toList(growable: false);
      expect(archiveRequests, hasLength(5));
      expect(
        archiveRequests.every(
          (uri) =>
              uri.queryParameters['start_date'] ==
              uri.queryParameters['end_date'],
        ),
        isTrue,
      );
    },
  );

  test('une erreur Open-Meteo est remontée sans masquer sa cause', () async {
    final remote = OpenMeteoRemote(
      client: MockClient((_) async => http.Response('indisponible', 503)),
    );

    await expectLater(
      remote.forecast(
        coordinates: const WeatherCoordinates(latitude: 33.8, longitude: 10.8),
        dates: [DateTime(2026, 9, 1)],
      ),
      throwsA(
        isA<WeatherUnavailable>().having(
          (error) => error.message,
          'message',
          'Open-Meteo a répondu 503.',
        ),
      ),
    );
  });
}
