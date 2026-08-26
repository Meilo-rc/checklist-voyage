import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/weather/trip_weather_service.dart';
import '../../domain/weather/weather_models.dart';

enum WeatherView { map, forecast }

typedef WeatherMapBuilder =
    Widget Function(
      BuildContext context,
      TripWeatherSnapshot snapshot,
      WeatherDay selectedDay,
    );

typedef WeatherMapBackgroundBuilder = Widget Function();

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
    required this.request,
    required this.service,
    this.mapBuilder,
  });

  final WeatherTripRequest request;
  final TripWeatherService service;
  final WeatherMapBuilder? mapBuilder;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherView _view = WeatherView.map;
  int _selectedDay = 0;
  late Future<TripWeatherSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.load(widget.request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Météo — ${widget.request.destination}')),
      body: FutureBuilder<TripWeatherSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _WeatherUnavailable(
              message: snapshot.error is WeatherUnavailable
                  ? (snapshot.error! as WeatherUnavailable).message
                  : 'Météo indisponible hors ligne.',
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
          final selectedIndex = _selectedDay.clamp(0, weather.days.length - 1);
          final selected = weather.days[selectedIndex];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<WeatherView>(
                        key: const Key('weather-view-selector'),
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: WeatherView.map,
                            label: Text('Carte'),
                          ),
                          ButtonSegment(
                            value: WeatherView.forecast,
                            label: Text('Prévisions'),
                          ),
                        ],
                        selected: {_view},
                        onSelectionChanged: (selection) =>
                            setState(() => _view = selection.single),
                      ),
                    ),
                    if (weather.isStale) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Tooltip(
                        message: 'Dernières données en cache',
                        child: Icon(
                          Icons.cloud_off_outlined,
                          key: const Key('weather-stale'),
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: _view == WeatherView.map
                    ? _WeatherMapPane(
                        snapshot: weather,
                        selectedDay: selected,
                        selectedIndex: selectedIndex,
                        onDaySelected: (index) =>
                            setState(() => _selectedDay = index),
                        mapBuilder: widget.mapBuilder,
                      )
                    : _WeatherForecastList(snapshot: weather),
              ),
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
        final weather = snapshot.data;
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
                          ? (snapshot.hasError
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
                                ? (snapshot.hasError
                                      ? 'Météo indisponible hors ligne'
                                      : 'Chargement…')
                                : '${day.minTemperature.round()}–'
                                      '${day.maxTemperature.round()} °C · '
                                      '${weatherSourceLabel(day.source)}',
                            maxLines: 1,
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

class _WeatherMapPane extends StatelessWidget {
  const _WeatherMapPane({
    required this.snapshot,
    required this.selectedDay,
    required this.selectedIndex,
    required this.onDaySelected,
    required this.mapBuilder,
  });

  final TripWeatherSnapshot snapshot;
  final WeatherDay selectedDay;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;
  final WeatherMapBuilder? mapBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SelectedDaySummary(day: selectedDay),
        const SizedBox(height: AppSpacing.xs),
        Expanded(
          child:
              mapBuilder?.call(context, snapshot, selectedDay) ??
              WeatherMapView(snapshot: snapshot, selectedDay: selectedDay),
        ),
        _DayStrip(
          days: snapshot.days,
          selectedIndex: selectedIndex,
          onSelected: onDaySelected,
        ),
      ],
    );
  }
}

class WeatherMapView extends StatefulWidget {
  const WeatherMapView({
    super.key,
    required this.snapshot,
    required this.selectedDay,
    this.backgroundBuilder,
  });

  final TripWeatherSnapshot snapshot;
  final WeatherDay selectedDay;
  final WeatherMapBackgroundBuilder? backgroundBuilder;

  @override
  State<WeatherMapView> createState() => _WeatherMapViewState();
}

class _WeatherMapViewState extends State<WeatherMapView> {
  final MapController _controller = MapController();

  LatLng get _center => LatLng(
    widget.snapshot.location.coordinates.latitude,
    widget.snapshot.location.coordinates.longitude,
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateKey = weatherDateKey(widget.selectedDay.date);
    return Stack(
      children: [
        FlutterMap(
          key: ValueKey('weather-map-${widget.snapshot.cacheKey}'),
          mapController: _controller,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 4.6,
            minZoom: 2.5,
            maxZoom: 9,
          ),
          children: [
            widget.backgroundBuilder?.call() ??
                TileLayer(
                  key: const Key('weather-map-background'),
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'fr.checklistvoyage.app',
                  maxZoom: 19,
                ),
            MarkerLayer(
              key: ValueKey('weather-markers-$dateKey'),
              markers: widget.snapshot.mapPoints
                  .map((point) {
                    final day = point.days[dateKey];
                    if (day == null) {
                      return Marker(
                        point: LatLng(
                          point.coordinates.latitude,
                          point.coordinates.longitude,
                        ),
                        width: 1,
                        height: 1,
                        child: const SizedBox.shrink(),
                      );
                    }
                    return Marker(
                      point: LatLng(
                        point.coordinates.latitude,
                        point.coordinates.longitude,
                      ),
                      width: point.isDestination ? 52 : 42,
                      height: point.isDestination ? 52 : 42,
                      child: _MapWeatherMarker(
                        day: day,
                        destination: point.isDestination,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        Positioned(
          right: AppSpacing.sm,
          bottom: AppSpacing.sm,
          child: Column(
            children: [
              _MapButton(
                tooltip: 'Recentrer',
                icon: Icons.my_location,
                onPressed: () => _controller.move(_center, 4.6),
              ),
              const SizedBox(height: AppSpacing.xs),
              _MapButton(
                tooltip: 'Zoom avant',
                icon: Icons.add,
                onPressed: () => _controller.move(
                  _controller.camera.center,
                  (_controller.camera.zoom + 1).clamp(2.5, 9),
                ),
              ),
              const SizedBox(height: 2),
              _MapButton(
                tooltip: 'Zoom arrière',
                icon: Icons.remove,
                onPressed: () => _controller.move(
                  _controller.camera.center,
                  (_controller.camera.zoom - 1).clamp(2.5, 9),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppSpacing.sm,
          top: AppSpacing.sm,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                weatherSourceLabel(widget.selectedDay.source),
                style: AppTextScale.of(
                  context,
                ).metadata.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapWeatherMarker extends StatelessWidget {
  const _MapWeatherMarker({required this.day, required this.destination});

  final WeatherDay day;
  final bool destination;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.88),
        shape: BoxShape.circle,
        border: destination
            ? Border.all(color: colors.primary, width: 2)
            : null,
        boxShadow: const [BoxShadow(blurRadius: 3, color: Color(0x55000000))],
      ),
      child: Icon(
        weatherIcon(day.condition),
        size: destination ? 31 : 27,
        color: weatherIconColor(day.condition, colors),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    elevation: 2,
    borderRadius: BorderRadius.circular(AppRadius.field),
    child: IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
    ),
  );
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<WeatherDay> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 62,
    child: ListView.separated(
      key: const Key('weather-day-strip'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: days.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
      itemBuilder: (context, index) {
        final day = days[index];
        final selected = index == selectedIndex;
        return ChoiceChip(
          key: Key('weather-day-$index'),
          selected: selected,
          onSelected: (_) => onSelected(index),
          label: Text(
            '${shortWeekday(day.date)}\n${day.date.day} ${shortMonth(day.date)}',
          ),
          labelStyle: AppTextScale.of(context).metadata.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        );
      },
    ),
  );
}

class _SelectedDaySummary extends StatelessWidget {
  const _SelectedDaySummary({required this.day});

  final WeatherDay day;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        key: const Key('weather-selected-summary'),
        children: [
          Icon(
            weatherIcon(day.condition),
            color: weatherIconColor(day.condition, colors),
            size: 28,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${longWeekday(day.date)} ${day.date.day} ${shortMonth(day.date)} · '
                  '${day.minTemperature.round()}–${day.maxTemperature.round()} °C',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextScale.of(context).filter,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherForecastList extends StatelessWidget {
  const _WeatherForecastList({required this.snapshot});

  final TripWeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const Key('weather-forecast-list'),
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      0,
      AppSpacing.md,
      AppSpacing.lg,
    ),
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
    return SizedBox(
      key: Key('weather-forecast-${weatherDateKey(day.date)}'),
      height: 58,
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              '${shortWeekday(day.date)}\n${day.date.day}',
              style: AppTextScale.of(context).metadata,
            ),
          ),
          Icon(
            weatherIcon(day.condition),
            size: 28,
            color: weatherIconColor(day.condition, colors),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherConditionLabel(day.condition),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextScale.of(context).body,
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
          SizedBox(
            width: 105,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${day.minTemperature.round()}–${day.maxTemperature.round()} °C',
                  style: AppTextScale.of(context).filter,
                ),
                Text(
                  '${weatherRainLabel(day)} · ${weatherWindLabel(day)}',
                  maxLines: 1,
                  style: AppTextScale.of(
                    context,
                  ).metadata.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
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
const _longWeekdays = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
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
String longWeekday(DateTime date) => _longWeekdays[date.weekday - 1];
String shortMonth(DateTime date) => _shortMonths[date.month - 1];
