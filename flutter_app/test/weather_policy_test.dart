import 'package:checklist_voyage_v1/domain/weather/weather_models.dart';
import 'package:checklist_voyage_v1/domain/weather/weather_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 26, 14);
  final policy = WeatherWindowPolicy(clock: () => now);

  test('la frontière J-16 est une prévision réelle', () {
    expect(
      policy.sourceFor(now.add(const Duration(days: 30))),
      WeatherDataSource.historical,
    );
    expect(
      policy.sourceFor(now.add(const Duration(days: 17))),
      WeatherDataSource.historical,
    );
    expect(
      policy.sourceFor(now.add(const Duration(days: 16))),
      WeatherDataSource.forecast,
    );
    expect(
      policy.sourceFor(now.add(const Duration(days: 10))),
      WeatherDataSource.forecast,
    );
  });

  test('un séjour partiellement couvert est découpé jour par jour', () {
    final split = policy.split(
      now.add(const Duration(days: 12)),
      now.add(const Duration(days: 20)),
    );

    expect(split[WeatherDataSource.forecast], hasLength(5));
    expect(split[WeatherDataSource.historical], hasLength(4));
  });

  test('un séjour entièrement couvert reste en prévision', () {
    final split = policy.split(
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 10)),
    );

    expect(split[WeatherDataSource.forecast], hasLength(10));
    expect(split[WeatherDataSource.historical], isEmpty);
  });

  test('un voyage passé utilise une tendance historique', () {
    expect(
      policy.sourceFor(now.subtract(const Duration(days: 1))),
      WeatherDataSource.historical,
    );
  });
}
