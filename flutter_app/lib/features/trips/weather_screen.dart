import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/weather/trip_weather_service.dart';
import '../../domain/weather/weather_models.dart';

String _weatherErrorMessage(Object? error) => error is WeatherUnavailable
    ? error.message
    : 'Données météo indisponibles. Réessaie plus tard.';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
    required this.request,
    required this.service,
  });

  final WeatherTripRequest request;
  final TripWeatherService service;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<TripWeatherSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.load(widget.request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Météo — ${widget.request.destination}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<TripWeatherSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _WeatherUnavailable(
              message: _weatherErrorMessage(snapshot.error),
              onRetry: () =>
                  setState(() => _future = widget.service.load(widget.request)),
            );
          }
          final weather = snapshot.data!;
          if (weather.days.isEmpty) {
            return const _WeatherUnavailable(
              message: 'Aucune donnée météo pour ce séjour.',
            );
          }
          return Column(
            children: [
              if (weather.isStale)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Row(
                    key: const Key('weather-stale'),
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Dernières données en cache',
                        style: AppTextScale.of(context).metadata.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: _WeatherForecastList(snapshot: weather)),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  1,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Données météo : Open-Meteo',
                    style: AppTextScale.of(context).metadata.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TripWeatherSummary extends StatefulWidget {
  const TripWeatherSummary({
    super.key,
    required this.request,
    required this.service,
    required this.onOpen,
  });

  final WeatherTripRequest request;
  final TripWeatherService service;
  final VoidCallback onOpen;

  @override
  State<TripWeatherSummary> createState() => _TripWeatherSummaryState();
}

class _TripWeatherSummaryState extends State<TripWeatherSummary> {
  late Future<TripWeatherSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.load(widget.request);
  }

  @override
  void didUpdateWidget(covariant TripWeatherSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (weatherCacheKey(oldWidget.request) != weatherCacheKey(widget.request)) {
      _future = widget.service.load(widget.request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<TripWeatherSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final weather = loading ? null : snapshot.data;
        final day = weather == null ? null : _summaryDay(weather.days);
        return Material(
          key: const Key('trip-weather-summary'),
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.card),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onOpen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      day == null
                          ? (!loading && snapshot.hasError
                                ? Icons.cloud_off_outlined
                                : Icons.cloud_sync_outlined)
                          : weatherIcon(day.condition),
                      size: 28,
                      color: day == null
                          ? colors.onSurfaceVariant
                          : weatherIconColor(day.condition, colors),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Météo', style: AppTextScale.of(context).filter),
                          const SizedBox(height: 2),
                          Text(
                            day == null
                                ? (!loading && snapshot.hasError
                                      ? _weatherErrorMessage(snapshot.error)
                                      : 'Chargement…')
                                : '${day.minTemperature.round()}–'
                                      '${day.maxTemperature.round()} °C · '
                                      '${weatherSourceLabel(day.source)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextScale.of(
                              context,
                            ).metadata.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (weather?.isStale ?? false)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: Icon(
                          Icons.cloud_off_outlined,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeatherForecastList extends StatelessWidget {
  const _WeatherForecastList({required this.snapshot});

  final TripWeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const Key('weather-forecast-list'),
    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 12),
    itemCount: snapshot.days.length,
    separatorBuilder: (_, _) => const Divider(height: 1),
    itemBuilder: (context, index) => _ForecastRow(day: snapshot.days[index]),
  );
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({required this.day});

  final WeatherDay day;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ConstrainedBox(
      key: Key('weather-forecast-${weatherDateKey(day.date)}'),
      constraints: const BoxConstraints(minHeight: 66),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              weatherIcon(day.condition),
              size: 26,
              color: weatherIconColor(day.condition, colors),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${shortWeekday(day.date)} ${day.date.day} '
                          '${shortMonth(day.date)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextScale.of(context).filter,
                        ),
                      ),
                      Text(
                        '${day.minTemperature.round()}–'
                        '${day.maxTemperature.round()} °C',
                        style: AppTextScale.of(context).filter,
                      ),
                    ],
                  ),
                  Text(
                    '${weatherConditionLabel(day.condition)} · '
                    '${weatherRainLabel(day)} · ${weatherWindLabel(day)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextScale.of(
                      context,
                    ).metadata.copyWith(color: colors.onSurfaceVariant),
                  ),
                  Text(
                    weatherSourceLabel(day.source),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextScale.of(context).metadata.copyWith(
                      color: day.source == WeatherDataSource.forecast
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherUnavailable extends StatelessWidget {
  const _WeatherUnavailable({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 42),
          const SizedBox(height: AppSpacing.md),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ],
      ),
    ),
  );
}

WeatherDay _summaryDay(List<WeatherDay> days) {
  final forecast = days.where(
    (day) => day.source == WeatherDataSource.forecast,
  );
  return forecast.isNotEmpty ? forecast.first : days.first;
}

String weatherSourceLabel(WeatherDataSource source) =>
    source == WeatherDataSource.forecast ? 'Prévision' : 'Tendance habituelle';

String weatherConditionLabel(WeatherCondition condition) => switch (condition) {
  WeatherCondition.clear => 'Ensoleillé',
  WeatherCondition.partlyCloudy => 'Peu nuageux',
  WeatherCondition.cloudy => 'Nuageux',
  WeatherCondition.fog => 'Brouillard',
  WeatherCondition.drizzle => 'Bruine',
  WeatherCondition.rain => 'Pluie',
  WeatherCondition.snow => 'Neige',
  WeatherCondition.thunderstorm => 'Orage',
  WeatherCondition.unknown => 'Variable',
};

IconData weatherIcon(WeatherCondition condition) => switch (condition) {
  WeatherCondition.clear => Icons.wb_sunny_outlined,
  WeatherCondition.partlyCloudy => Icons.wb_cloudy_outlined,
  WeatherCondition.cloudy => Icons.cloud_outlined,
  WeatherCondition.fog => Icons.foggy,
  WeatherCondition.drizzle => Icons.grain,
  WeatherCondition.rain => Icons.water_drop_outlined,
  WeatherCondition.snow => Icons.ac_unit,
  WeatherCondition.thunderstorm => Icons.thunderstorm_outlined,
  WeatherCondition.unknown => Icons.cloud_queue,
};

Color weatherIconColor(WeatherCondition condition, ColorScheme colors) =>
    switch (condition) {
      WeatherCondition.clear ||
      WeatherCondition.partlyCloudy => colors.tertiary,
      WeatherCondition.rain || WeatherCondition.drizzle => colors.primary,
      WeatherCondition.thunderstorm => colors.secondary,
      WeatherCondition.snow => colors.onSurface,
      _ => colors.onSurfaceVariant,
    };

String weatherRainLabel(WeatherDay day) {
  if (day.precipitationProbability != null) {
    return 'Pluie ${day.precipitationProbability} %';
  }
  if (day.precipitationMillimeters != null) {
    return '${day.precipitationMillimeters!.toStringAsFixed(1)} mm';
  }
  return 'Pluie —';
}

String weatherWindLabel(WeatherDay day) => day.meanWindSpeed == null
    ? 'Vent —'
    : 'Vent ${day.meanWindSpeed!.round()} km/h';

const _shortWeekdays = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
const _shortMonths = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

String shortWeekday(DateTime date) => _shortWeekdays[date.weekday - 1];
String shortMonth(DateTime date) => _shortMonths[date.month - 1];
