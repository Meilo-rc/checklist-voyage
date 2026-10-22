import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/presentation/user_message.dart';
import '../../core/sharing/share_invitation.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/models/progress.dart';
import '../../domain/models/trip_archive.dart';
import '../../domain/models/trip_filters.dart';
import '../../domain/usecases/trip_use_cases.dart';
import '../../domain/usecases/shared_document_use_cases.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../../domain/weather/trip_weather_service.dart';
import '../../domain/weather/weather_models.dart';
import '../shared/date_range_label.dart';
import '../shared/category_details_page.dart';
import '../shared/destination_scaffold.dart';
import '../shared/document_sync_notice.dart';
import '../shared/item_contexts_sheet.dart';
import '../shared/join_code_dialog.dart';
import 'trip_form.dart';
import 'city_destination_field.dart';
import 'weather_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({
    super.key,
    required this.watchTrips,
    required this.useCases,
    required this.weather,
    required this.shareInvitations,
    required this.pendingJoinRequest,
    required this.onJoinRequestHandled,
    this.sharedDocuments,
  });

  final WatchTrips watchTrips;
  final TripUseCases useCases;
  final TripWeatherService weather;
  final SharedDocumentUseCases? sharedDocuments;
  final ShareInvitationGateway shareInvitations;
  final ShareJoinRequest? pendingJoinRequest;
  final ValueChanged<ShareJoinRequest> onJoinRequestHandled;

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String? _selectedTripId;
  bool _showArchives = false;
  bool _handlingJoinRequest = false;

  @override
  void initState() {
    super.initState();
    _schedulePendingJoinRequest();
  }

  @override
  void didUpdateWidget(covariant TripsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pendingJoinRequest, widget.pendingJoinRequest)) {
      _schedulePendingJoinRequest();
    }
  }

  void _schedulePendingJoinRequest() {
    final request = widget.pendingJoinRequest;
    if (request == null || _handlingJoinRequest) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _handlingJoinRequest) return;
      _handlingJoinRequest = true;
      try {
        await _join(
          initialCode: request.code,
          dialogTitle: 'Rejoindre un voyage',
        );
      } finally {
        if (mounted) {
          _handlingJoinRequest = false;
          widget.onJoinRequestHandled(request);
        }
      }
    });
  }

  Future<void> _join({
    String initialCode = '',
    String dialogTitle = 'Rejoindre avec un code',
  }) async {
    final sharing = widget.sharedDocuments;
    if (sharing == null) return;
    final code = await _askCode(
      context,
      initialCode: initialCode,
      title: dialogTitle,
    );
    if (code == null) return;
    try {
      final access = await sharing.join(code);
      if (access.documentType != SharedDocumentType.trip) {
        throw StateError('Ce code correspond à une liste rapide.');
      }
      if (mounted) setState(() => _selectedTripId = access.documentId);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
    }
  }

  Future<void> _createTrip() async {
    final owners = await widget.useCases.loadGenerationChoices();
    final contexts = await widget.useCases.loadContexts();
    if (!mounted) return;
    final result = await Navigator.of(context).push<TripFormResult>(
      MaterialPageRoute(
        builder: (context) => TripForm(
          title: 'Nouveau voyage',
          searchCities: widget.weather.searchCities,
          submitLabel: 'Créer le voyage',
          owners: owners,
          contexts: contexts,
        ),
      ),
    );
    if (result == null) return;
    try {
      final id = await widget.useCases.createTrip(
        CreateTripRequest(
          name: result.name,
          destination: result.destination,
          destinationLocation: result.destinationLocation,
          startDate: result.startDate,
          endDate: result.endDate,
          participantOwnerIds: result.participantOwnerIds,
          transportOwnerIds: result.transportOwnerIds,
          lodgingOwnerIds: result.lodgingOwnerIds,
          contextIds: result.contextIds,
          personalCategoryIds: result.personalCategoryIds,
        ),
      );
      if (mounted) setState(() => _selectedTripId = id);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
    }
  }

  Future<void> _handleEntryAction(_TripEntryAction action) async {
    if (action == _TripEntryAction.create) {
      await _createTrip();
    } else {
      await _join();
    }
  }

  Future<void> _editTrip(TripDetailModel trip) async {
    final owners = await widget.useCases.loadGenerationChoices();
    final contexts = await widget.useCases.loadContexts();
    if (!mounted) return;
    final result = await Navigator.of(context).push<TripFormResult>(
      MaterialPageRoute(
        builder: (context) => TripForm(
          title: 'Modifier le voyage',
          searchCities: widget.weather.searchCities,
          submitLabel: 'Enregistrer',
          owners: owners,
          contexts: contexts,
          selectionsEditable: false,
          initialData: TripFormInitialData(
            name: trip.name,
            destination: trip.destination,
            destinationLocation: trip.destinationLocation,
            startDate: trip.startDate,
            endDate: trip.endDate,
            participantOwnerIds: trip.selectedParticipantOwnerIds,
            transportOwnerIds: trip.selectedTransportOwnerIds,
            lodgingOwnerIds: trip.selectedLodgingOwnerIds,
            contextIds: trip.selectedContextIds,
            personalCategoryIds: trip.selectedPersonalCategoryIds,
          ),
        ),
      ),
    );
    if (result == null) return;
    try {
      await widget.useCases.updateTripDetails(
        UpdateTripDetailsRequest(
          tripId: trip.id,
          name: result.name,
          destination: result.destination,
          destinationLocation: result.destinationLocation,
          startDate: result.startDate,
          endDate: result.endDate,
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
    }
  }

  Future<void> _duplicateTrip(TripDetailModel source) async {
    final request = await showDialog<DuplicateTripRequest>(
      context: context,
      builder: (context) => _DuplicateTripDialog(
        source: source,
        searchCities: widget.weather.searchCities,
      ),
    );
    if (request == null) return;
    try {
      final id = await widget.useCases.duplicateTrip(request);
      if (mounted) {
        setState(() {
          _showArchives = false;
          _selectedTripId = id;
        });
      }
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedTripId;
    if (selected != null) {
      return _TripDetail(
        tripId: selected,
        useCases: widget.useCases,
        onBack: () => setState(() => _selectedTripId = null),
        onEdit: _editTrip,
        onDuplicate: _duplicateTrip,
        sharedDocuments: widget.sharedDocuments,
        shareInvitations: widget.shareInvitations,
        weather: widget.weather,
      );
    }
    return PopScope(
      canPop: !_showArchives,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showArchives) {
          setState(() => _showArchives = false);
        }
      },
      child: Stack(
        children: [
          DestinationScaffold(
            title: 'Checklist Voyage',
            actions: [
              PopupMenuButton<String>(
                key: const Key('trip-root-menu'),
                tooltip: 'Plus d’options',
                position: PopupMenuPosition.under,
                onSelected: (_) =>
                    setState(() => _showArchives = !_showArchives),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    height: 44,
                    value: 'archives',
                    child: Row(
                      children: [
                        Icon(
                          _showArchives
                              ? Icons.luggage_outlined
                              : Icons.archive_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            _showArchives ? 'Voyages actifs' : 'Archives',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            child: StreamBuilder<List<TripSummary>>(
              stream: widget.watchTrips(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const EmptyDestination(
                    icon: Icons.error_outline,
                    title: 'Voyages indisponibles',
                    message: 'Impossible de charger les données locales.',
                  );
                }
                final trips = snapshot.data ?? const [];
                final now = DateTime.now();
                final upcoming = trips
                    .where(
                      (trip) =>
                          TripArchiveClassifier.classify(trip, now) ==
                          TripCollection.upcoming,
                    )
                    .toList(growable: false);
                final ongoing = trips
                    .where(
                      (trip) =>
                          TripArchiveClassifier.classify(trip, now) ==
                          TripCollection.ongoing,
                    )
                    .toList(growable: false);
                final archives =
                    trips
                        .where(
                          (trip) =>
                              TripArchiveClassifier.classify(trip, now) ==
                              TripCollection.archived,
                        )
                        .toList()
                      ..sort(
                        (a, b) => TripArchiveClassifier.archiveSortDate(
                          b,
                        ).compareTo(TripArchiveClassifier.archiveSortDate(a)),
                      );
                final hasActive = upcoming.isNotEmpty || ongoing.isNotEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_showArchives) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.field),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.asset(
                            'assets/images/checklist.webp',
                            key: const Key('trip-home-hero'),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (_showArchives) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.archive_outlined,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Archives',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (archives.isEmpty)
                        const EmptyDestination(
                          icon: Icons.archive_outlined,
                          title: 'Aucune archive',
                          message: 'Les voyages terminés apparaîtront ici.',
                        )
                      else
                        ...archives.map(
                          (trip) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _TripSummaryCard(
                              trip: trip,
                              archived: true,
                              onTap: () =>
                                  setState(() => _selectedTripId = trip.id),
                            ),
                          ),
                        ),
                    ] else if (!hasActive)
                      const EmptyDestination(
                        icon: Icons.luggage_outlined,
                        title: 'Aucun voyage actif',
                        message: 'Créez un voyage depuis votre bibliothèque.',
                      )
                    else ...[
                      if (ongoing.isNotEmpty) ...[
                        Text(
                          'En cours',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...ongoing.map(
                          (trip) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _TripSummaryCard(
                              trip: trip,
                              archived: false,
                              onTap: () =>
                                  setState(() => _selectedTripId = trip.id),
                            ),
                          ),
                        ),
                      ],
                      if (upcoming.isNotEmpty) ...[
                        if (ongoing.isNotEmpty)
                          const SizedBox(height: AppSpacing.md),
                        Text(
                          'À venir',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...upcoming.map(
                          (trip) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _TripSummaryCard(
                              trip: trip,
                              archived: false,
                              onTap: () =>
                                  setState(() => _selectedTripId = trip.id),
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 76),
                  ],
                );
              },
            ),
          ),
          if (!_showArchives)
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: _TripEntryFab(
                canJoin: widget.sharedDocuments != null,
                onSelected: _handleEntryAction,
              ),
            ),
        ],
      ),
    );
  }
}

enum _TripEntryAction { create, join }

class _TripEntryFab extends StatefulWidget {
  const _TripEntryFab({required this.canJoin, required this.onSelected});

  final bool canJoin;
  final ValueChanged<_TripEntryAction> onSelected;

  @override
  State<_TripEntryFab> createState() => _TripEntryFabState();
}

class _TripEntryFabState extends State<_TripEntryFab> {
  final _menuKey = GlobalKey<PopupMenuButtonState<_TripEntryAction>>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return KeyedSubtree(
      key: const Key('trip-fab-menu'),
      child: PopupMenuButton<_TripEntryAction>(
        key: _menuKey,
        tooltip: 'Ajouter ou rejoindre un voyage',
        position: PopupMenuPosition.over,
        onSelected: widget.onSelected,
        itemBuilder: (context) => [
          const PopupMenuItem(
            height: 44,
            value: _TripEntryAction.create,
            child: Row(
              children: [
                Icon(Icons.add_location_alt_outlined, size: 20),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Créer un voyage',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (widget.canJoin)
            const PopupMenuItem(
              height: 44,
              value: _TripEntryAction.join,
              child: Row(
                children: [
                  Icon(Icons.group_add_outlined, size: 20),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Rejoindre avec un code',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
        child: FloatingActionButton(
          heroTag: null,
          tooltip: 'Ajouter ou rejoindre un voyage',
          onPressed: () => _menuKey.currentState?.showButtonMenu(),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({
    required this.trip,
    required this.archived,
    required this.onTap,
  });

  final TripSummary trip;
  final bool archived;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = trip.destination.trim().isEmpty
        ? trip.name
        : trip.destination;
    return Card(
      key: Key('trip-summary-${trip.id}'),
      color: archived ? colors.surfaceContainerLowest : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (trip.startDate != null || trip.endDate != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  compactTripPeriodLabel(trip.startDate, trip.endDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (!archived) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: trip.progress.percent / 100,
                        semanticsLabel: 'Progression du voyage',
                        semanticsValue: '${trip.progress.percent} %',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${trip.progress.completed}/${trip.progress.total} · '
                      '${trip.progress.percent} %',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DuplicateTripDialog extends StatefulWidget {
  const _DuplicateTripDialog({
    required this.source,
    required this.searchCities,
  });

  final TripDetailModel source;
  final Future<List<WeatherLocation>> Function(String) searchCities;

  @override
  State<_DuplicateTripDialog> createState() => _DuplicateTripDialogState();
}

class _DuplicateTripDialogState extends State<_DuplicateTripDialog> {
  late final TextEditingController _destination;
  WeatherLocation? _selectedLocation;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    _destination = TextEditingController(text: widget.source.destination);
  }

  @override
  void dispose() {
    _destination.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _startDate ?? DateTime.now(),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
      context: context,
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
    );
    if (date != null) setState(() => _endDate = date);
  }

  void _submit() {
    final destination = _destination.text.trim();
    final keepsLocation =
        destination == widget.source.destination.trim() &&
        widget.source.destinationLocation != null;
    if (_selectedLocation == null && !keepsLocation) {
      setState(() => _error = 'Sélectionne une ville dans les suggestions.');
      return;
    }
    if (_startDate == null || _endDate == null) {
      setState(() => _error = 'Nouvelles dates requises.');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      setState(() => _error = 'La date de fin précède la date de début.');
      return;
    }
    Navigator.pop(
      context,
      DuplicateTripRequest(
        sourceTripId: widget.source.id,
        name: destination,
        destination: destination,
        destinationLocation: _selectedLocation,
        startDate: _startDate!,
        endDate: _endDate!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.source.members
        .map((member) => member.name)
        .join(', ');
    return AlertDialog(
      title: const Text('Dupliquer le voyage'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CityDestinationField(
                fieldKey: const Key('trip-duplicate-destination'),
                controller: _destination,
                initialLocation: widget.source.destinationLocation,
                search: widget.searchCities,
                onSelected: (location) => setState(() {
                  _selectedLocation = location;
                  _error = null;
                }),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    key: const Key('trip-duplicate-start'),
                    onPressed: _pickStart,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            _dateLabel(_startDate, 'Nouveau départ'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  OutlinedButton(
                    key: const Key('trip-duplicate-end'),
                    onPressed: _pickEnd,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_outlined),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            _dateLabel(_endDate, 'Nouveau retour'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Structure conservée : $sections'),
              if (widget.source.selectedContextIds.isNotEmpty)
                Text(
                  '${widget.source.selectedContextIds.length} activité(s) conservée(s)',
                ),
              const SizedBox(height: 4),
              const Text(
                'La checklist affinée et les quantités seront copiées. Tous les états repartiront à À préparer.',
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  key: const Key('trip-duplicate-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('trip-duplicate-submit'),
          onPressed: _submit,
          child: const Text('Créer la copie'),
        ),
      ],
    );
  }
}

class _TripDetail extends StatefulWidget {
  const _TripDetail({
    required this.tripId,
    required this.useCases,
    required this.onBack,
    required this.onEdit,
    required this.onDuplicate,
    required this.sharedDocuments,
    required this.shareInvitations,
    required this.weather,
  });

  final String tripId;
  final TripUseCases useCases;
  final VoidCallback onBack;
  final Future<void> Function(TripDetailModel) onEdit;
  final Future<void> Function(TripDetailModel) onDuplicate;
  final SharedDocumentUseCases? sharedDocuments;
  final ShareInvitationGateway shareInvitations;
  final TripWeatherService weather;

  @override
  State<_TripDetail> createState() => _TripDetailState();
}

class _TripDetailState extends State<_TripDetail> {
  TripFilter _filter = const TripFilter();
  String? _selectedMemberId;
  late final Stream<TripDetailModel?> _tripStream;
  late final Stream<String?> _syncErrors;
  Timer? _receiveTimer;

  @override
  void initState() {
    super.initState();
    _tripStream = widget.useCases.watchTrip(widget.tripId);
    _syncErrors =
        widget.sharedDocuments?.watchError(widget.tripId) ??
        Stream<String?>.value(null);
    unawaited(_syncDocument());
    // Réception pendant l'utilisation du voyage, sans service en arrière-plan.
    // Le coordinateur suspend aussi ces appels lorsque l'app n'est plus active.
    _receiveTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(_syncDocument());
    });
  }

  @override
  void dispose() {
    _receiveTimer?.cancel();
    super.dispose();
  }

  Future<void> _syncDocument() async {
    try {
      await widget.sharedDocuments?.syncDocument(widget.tripId);
    } on Object {
      // Le store conserve l'erreur. L'ouverture du voyage reste local-first.
    }
  }

  void _goBack() {
    if (_selectedMemberId != null) {
      setState(() => _selectedMemberId = null);
    } else {
      widget.onBack();
    }
  }

  Future<void> _share(TripDetailModel trip) async {
    final sharing = widget.sharedDocuments;
    if (sharing == null) return;
    try {
      final code = trip.v1ShareReady
          ? trip.shareCode
          : (await sharing.shareTrip(trip.id)).shareCode;
      if (code == null) return;
      await widget.shareInvitations.share(
        ShareInvitation(
          type: ShareableDocumentType.trip,
          displayName: _tripShareName(trip),
          code: code,
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
    }
  }

  List<Widget> _actions(TripDetailModel trip) => [
    if (widget.sharedDocuments != null)
      IconButton(
        key: Key(trip.v1ShareReady ? 'trip-show-code' : 'trip-share'),
        tooltip: 'Partager',
        icon: const Icon(Icons.share_outlined),
        onPressed: () => _share(trip),
      ),
    PopupMenuButton<String>(
      key: const Key('trip-actions'),
      position: PopupMenuPosition.under,
      onSelected: (action) async {
        if (action == 'edit') {
          await widget.onEdit(trip);
        } else if (action == 'duplicate') {
          await widget.onDuplicate(trip);
        } else if (action == 'archive') {
          await widget.useCases.archiveTrip(trip.id);
        } else if (action == 'restore') {
          await widget.useCases.restoreTrip(trip.id);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(height: 44, value: 'edit', child: Text('Modifier')),
        const PopupMenuItem(
          height: 44,
          value: 'duplicate',
          child: Text('Dupliquer'),
        ),
        if (trip.archivedAt != null)
          const PopupMenuItem(
            height: 44,
            value: 'restore',
            child: Text('Restaurer'),
          )
        else if (!TripArchiveClassifier.isFinished(
          trip.endDate,
          DateTime.now(),
        ))
          const PopupMenuItem(
            height: 44,
            value: 'archive',
            child: Text('Archiver'),
          ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TripDetailModel?>(
      stream: _tripStream,
      builder: (context, snapshot) {
        final trip = snapshot.data;
        if (trip == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final progress = ProgressCalculator.forTrip(trip);
        final personOptions = TripFilterEngine.personOptions(trip);
        final effectivePerson =
            personOptions.any((option) => option.filter == _filter.person)
            ? _filter.person
            : const TripPersonFilter.all();
        final effectiveFilter = _filter.copyWith(person: effectivePerson);
        final visibleMembers = TripFilterEngine.apply(trip, effectiveFilter);
        final member = visibleMembers
            .where((candidate) => candidate.id == _selectedMemberId)
            .firstOrNull;
        final completeMember = trip.members
            .where((candidate) => candidate.id == _selectedMemberId)
            .firstOrNull;
        final Widget page;
        if (_selectedMemberId != null &&
            member != null &&
            completeMember != null) {
          page = _TripMemberPage(
            tripId: trip.id,
            member: member,
            completeMember: completeMember,
            stateFilter: effectiveFilter.state,
            useCases: widget.useCases,
            onBack: _goBack,
          );
        } else if (_selectedMemberId != null) {
          page = _FilteredLevelEmpty(filter: effectiveFilter, onBack: _goBack);
        } else {
          page = _TripOverview(
            trip: trip,
            progress: progress,
            filter: effectiveFilter,
            visibleMembers: visibleMembers,
            useCases: widget.useCases,
            weather: widget.weather,
            onBack: _goBack,
            actions: _actions(trip),
            onStateChanged: (state) =>
                setState(() => _filter = _filter.copyWith(state: state)),
            onMemberSelected: (id) => setState(() {
              _selectedMemberId = id;
            }),
          );
        }
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _goBack();
          },
          child: Column(
            children: [
              Expanded(child: page),
              DocumentSyncNotice(
                errors: _syncErrors,
                onRetry: () => unawaited(_syncDocument()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TripOverview extends StatefulWidget {
  const _TripOverview({
    required this.trip,
    required this.progress,
    required this.filter,
    required this.visibleMembers,
    required this.useCases,
    required this.weather,
    required this.onBack,
    required this.actions,
    required this.onStateChanged,
    required this.onMemberSelected,
  });

  final TripDetailModel trip;
  final ChecklistProgress progress;
  final TripFilter filter;
  final List<TripMemberModel> visibleMembers;
  final TripUseCases useCases;
  final TripWeatherService weather;
  final VoidCallback onBack;
  final List<Widget> actions;
  final ValueChanged<TripStateFilter> onStateChanged;
  final ValueChanged<String> onMemberSelected;

  @override
  State<_TripOverview> createState() => _TripOverviewState();
}

class _TripOverviewState extends State<_TripOverview> {
  bool _generalExpanded = true;
  bool _membersExpanded = true;
  bool _personalExpanded = true;

  WeatherTripRequest? get _weatherRequest {
    final start = widget.trip.startDate;
    final end = widget.trip.endDate;
    if (start == null ||
        end == null ||
        widget.trip.destination.trim().isEmpty) {
      return null;
    }
    final latitude = widget.trip.destinationLatitude;
    final longitude = widget.trip.destinationLongitude;
    return WeatherTripRequest(
      tripId: widget.trip.id,
      destination: widget.trip.destination,
      startDate: start,
      endDate: end,
      coordinates: latitude != null && longitude != null
          ? WeatherCoordinates(latitude: latitude, longitude: longitude)
          : null,
    );
  }

  Future<void> _openWeather(WeatherTripRequest request) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) =>
            WeatherScreen(request: request, service: widget.weather),
      ),
    );
  }

  void _message(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
  }

  Future<void> _addGroup(TripMemberGroupKind groupKind, String name) async {
    try {
      await widget.useCases.addGroup(widget.trip.id, groupKind, name);
      widget.onStateChanged(TripStateFilter.all);
    } on Object catch (error) {
      _message(error);
      rethrow;
    }
  }

  Future<void> _openGroupActions(TripMemberModel group) async {
    if (group.id == 'general-${widget.trip.id}') return;
    await showHierarchyEntityActionsSheet(
      context,
      entityId: group.id,
      entityLabel: group.groupKind == TripMemberGroupKind.family
          ? 'Membre'
          : 'Groupe',
      initialName: group.name,
      initialIcon: group.icon,
      onRename: (name) => widget.useCases.renameGroup(group.id, name),
      onIconChanged: (icon) => widget.useCases.setGroupIcon(group.id, icon),
      onDelete: () => widget.useCases.removeGroup(group.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPersonal = widget.trip.members
        .where((member) => member.groupKind == TripMemberGroupKind.personal)
        .toList(growable: false);
    final allGeneral = widget.trip.members
        .where((member) => member.groupKind == TripMemberGroupKind.general)
        .toList(growable: false);
    final allFamily = widget.trip.members
        .where((member) => member.groupKind == TripMemberGroupKind.family)
        .toList(growable: false);
    final personal = widget.visibleMembers
        .where((member) => member.groupKind == TripMemberGroupKind.personal)
        .toList(growable: false);
    final general = widget.visibleMembers
        .where((member) => member.groupKind == TripMemberGroupKind.general)
        .toList(growable: false);
    final family = widget.visibleMembers
        .where((member) => member.groupKind == TripMemberGroupKind.family)
        .toList(growable: false);
    return CustomScrollView(
      key: const Key('trip-overview'),
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            widget.trip.destination.isEmpty
                ? widget.trip.name
                : widget.trip.destination,
          ),
          actions: widget.actions,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          sliver: SliverList.list(
            children: [
              if (widget.trip.startDate != null ||
                  widget.trip.endDate != null ||
                  widget.trip.v1ShareReady) ...[
                Row(
                  children: [
                    if (widget.trip.startDate != null ||
                        widget.trip.endDate != null)
                      Expanded(
                        child: Text(
                          compactTripPeriodLabel(
                            widget.trip.startDate,
                            widget.trip.endDate,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      )
                    else
                      const Spacer(),
                    if (widget.trip.v1ShareReady)
                      Text(
                        'Partagé',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              _CompactProgress(progress: widget.progress),
              if (_weatherRequest case final request?) ...[
                const SizedBox(height: AppSpacing.sm),
                TripWeatherSummary(
                  request: request,
                  service: widget.weather,
                  onOpen: () => _openWeather(request),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _TripFilters(
                filter: widget.filter,
                onStateChanged: widget.onStateChanged,
              ),
              const SizedBox(height: AppSpacing.md),
              if (widget.visibleMembers.isEmpty &&
                  widget.filter.state != TripStateFilter.all)
                _EmptyTripFilter(filter: widget.filter),
              if (widget.visibleMembers.isEmpty &&
                  widget.filter.state != TripStateFilter.all)
                const SizedBox(height: AppSpacing.sm),
              _TripLevelBlock(
                key: const Key('trip-level-general'),
                title: 'Général',
                groupKind: TripMemberGroupKind.general,
                members: general,
                completeMembers: allGeneral,
                expanded: _generalExpanded,
                addLabel: 'Ajouter un groupe',
                onAdd: (name) => _addGroup(TripMemberGroupKind.general, name),
                onToggle: () =>
                    setState(() => _generalExpanded = !_generalExpanded),
                onSelected: widget.onMemberSelected,
                onManage: _openGroupActions,
              ),
              const SizedBox(height: AppSpacing.sm),
              _TripLevelBlock(
                key: const Key('trip-level-members'),
                title: 'Membres',
                groupKind: TripMemberGroupKind.family,
                members: family,
                completeMembers: allFamily,
                expanded: _membersExpanded,
                addLabel: 'Ajouter un membre',
                onAdd: (name) => _addGroup(TripMemberGroupKind.family, name),
                onToggle: () =>
                    setState(() => _membersExpanded = !_membersExpanded),
                onSelected: widget.onMemberSelected,
                onManage: _openGroupActions,
              ),
              if (allPersonal.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _TripLevelBlock(
                  key: const Key('trip-level-personal'),
                  title: 'Personnel',
                  groupKind: TripMemberGroupKind.personal,
                  members: personal,
                  completeMembers: allPersonal,
                  expanded: _personalExpanded,
                  addLabel: 'Ajouter un groupe',
                  onAdd: (name) =>
                      _addGroup(TripMemberGroupKind.personal, name),
                  onToggle: () =>
                      setState(() => _personalExpanded = !_personalExpanded),
                  onSelected: widget.onMemberSelected,
                  onManage: _openGroupActions,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TripLevelBlock extends StatelessWidget {
  const _TripLevelBlock({
    super.key,
    required this.title,
    required this.groupKind,
    required this.members,
    required this.completeMembers,
    required this.expanded,
    required this.addLabel,
    required this.onAdd,
    required this.onToggle,
    required this.onSelected,
    required this.onManage,
  });

  final String title;
  final TripMemberGroupKind groupKind;
  final List<TripMemberModel> members;
  final List<TripMemberModel> completeMembers;
  final bool expanded;
  final String addLabel;
  final Future<void> Function(String) onAdd;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelected;
  final ValueChanged<TripMemberModel> onManage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final progress = ChecklistProgress(
      total: completeMembers
          .map(ProgressCalculator.forMember)
          .fold(0, (sum, value) => sum + value.total),
      completed: completeMembers
          .map(ProgressCalculator.forMember)
          .fold(0, (sum, value) => sum + value.completed),
    );
    final headerColor = Color.alphaBlend(
      colors.primary.withValues(alpha: dark ? 0.18 : 0.13),
      colors.surfaceContainerLow,
    );
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: headerColor,
            child: InkWell(
              key: Key('trip-level-${title.toLowerCase()}-toggle'),
              onTap: onToggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextScale.of(context).sectionTitle,
                        ),
                      ),
                      Text(
                        '${progress.completed}/${progress.total}',
                        style: AppTextScale.of(
                          context,
                        ).metadata.copyWith(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (expanded)
            ...members.indexed.expand((entry) {
              final (index, member) = entry;
              final complete = completeMembers.singleWhere(
                (candidate) => candidate.id == member.id,
              );
              final memberProgress = ProgressCalculator.forMember(complete);
              return [
                if (index > 0) const Divider(height: 1, indent: 48),
                _TripNavigationRow(
                  key: Key('trip-member-${member.id}'),
                  memberId: member.id,
                  title: member.name,
                  icon: member.icon,
                  groupKind: groupKind,
                  progress: memberProgress,
                  onTap: () => onSelected(member.id),
                  onLongPress: () => onManage(member),
                ),
              ];
            }),
          if (expanded)
            _InlineTripGroupAdder(
              key: Key('trip-add-group-${groupKind.name}'),
              sectionKey: groupKind.name,
              label: addLabel,
              onSubmit: onAdd,
            ),
        ],
      ),
    );
  }
}

class _TripNavigationRow extends StatelessWidget {
  const _TripNavigationRow({
    super.key,
    required this.memberId,
    required this.title,
    required this.icon,
    required this.groupKind,
    required this.progress,
    required this.onTap,
    required this.onLongPress,
  });

  final String memberId;
  final String title;
  final String? icon;
  final TripMemberGroupKind groupKind;
  final ChecklistProgress progress;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      leading: SizedBox.square(
        key: Key(
          groupKind == TripMemberGroupKind.family
              ? 'trip-member-icon-$memberId'
              : 'trip-group-icon-$memberId',
        ),
        dimension: 32,
        child: Center(
          child: CategoryIconView(
            icon: icon,
            size: 22,
            fallbackIcon: groupKind == TripMemberGroupKind.family
                ? Icons.person_outline
                : Icons.folder_outlined,
          ),
        ),
      ),
      minLeadingWidth: 32,
      horizontalTitleGap: AppSpacing.sm,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextScale.of(context).hierarchyTitle,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${progress.completed}/${progress.total}',
            style: AppTextScale.of(context).metadata,
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class _CompactProgress extends StatelessWidget {
  const _CompactProgress({required this.progress});

  final ChecklistProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: LinearProgressIndicator(value: progress.percent / 100)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${progress.completed}/${progress.total} · ${progress.percent} %',
          style: AppTextScale.of(
            context,
          ).metadata.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _FilteredLevelEmpty extends StatelessWidget {
  const _FilteredLevelEmpty({required this.filter, required this.onBack});

  final TripFilter filter;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter.state) {
      TripStateFilter.all => 'Aucun élément.',
      TripStateFilter.todo => 'Aucun élément à préparer.',
      TripStateFilter.checked => 'Aucun élément prêt.',
      TripStateFilter.done => 'Aucun élément rangé.',
    };
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Voyage'),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(message, key: const Key('trip-level-filter-empty')),
          ),
        ),
      ],
    );
  }
}

class _TripFilters extends StatelessWidget {
  const _TripFilters({required this.filter, required this.onStateChanged});

  final TripFilter filter;
  final ValueChanged<TripStateFilter> onStateChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filtrer par état',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TripStateFilter.values
              .map(
                (state) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: FilterChip(
                    key: Key('trip-state-${state.name}'),
                    label: Text(
                      _stateFilterLabel(state),
                      style: AppTextScale.of(context).filter,
                    ),
                    selected: filter.state == state,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(
                      horizontal: -3,
                      vertical: -3,
                    ),
                    labelPadding: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    onSelected: (_) => onStateChanged(state),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _EmptyTripFilter extends StatelessWidget {
  const _EmptyTripFilter({required this.filter});

  final TripFilter filter;

  @override
  Widget build(BuildContext context) {
    final state = switch (filter.state) {
      TripStateFilter.all => 'élément',
      TripStateFilter.todo => 'élément à préparer',
      TripStateFilter.checked => 'élément prêt',
      TripStateFilter.done => 'élément rangé',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'Aucun $state.',
        key: const Key('trip-filter-empty'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

Future<String?> _askCode(
  BuildContext context, {
  String initialCode = '',
  String title = 'Rejoindre avec un code',
}) {
  return showJoinCodeDialog(
    context,
    title: title,
    initialCode: initialCode,
    inputKey: const Key('share-code-input'),
    submitKey: const Key('share-code-submit'),
  );
}

String _tripShareName(TripDetailModel trip) {
  final destination = trip.destination.trim();
  if (destination.isNotEmpty) return destination;
  final name = trip.name.trim();
  return name.isEmpty ? 'Voyage' : name;
}

class _TripMemberPage extends StatefulWidget {
  const _TripMemberPage({
    required this.tripId,
    required this.member,
    required this.completeMember,
    required this.stateFilter,
    required this.useCases,
    required this.onBack,
  });

  final String tripId;
  final TripMemberModel member;
  final TripMemberModel completeMember;
  final TripStateFilter stateFilter;
  final TripUseCases useCases;
  final VoidCallback onBack;

  @override
  State<_TripMemberPage> createState() => _TripMemberPageState();
}

class _TripMemberPageState extends State<_TripMemberPage> {
  static const _reorderDelay = Duration(milliseconds: 450);

  final _addController = TextEditingController();
  final _addFocus = FocusNode();
  final _categoryController = TextEditingController();
  final _categoryFocus = FocusNode();
  final _editController = TextEditingController();
  final Map<String, List<String>> _heldItemOrderByCategory = {};
  final Map<String, String> _pendingTodoItemByCategory = {};
  final Map<String, Timer> _reorderTimers = {};
  final Map<String, Future<void>> _cycleTails = {};
  String? _expandedCategoryId;
  String? _editingItemId;
  bool _adding = false;
  bool _addingCategory = false;

  @override
  void didUpdateWidget(covariant _TripMemberPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateFilter != widget.stateFilter) {
      _clearAllReorderHolds();
    }
    if (_expandedCategoryId != null &&
        !widget.member.categories.any(
          (category) => category.id == _expandedCategoryId,
        )) {
      _expandedCategoryId = null;
      _editingItemId = null;
    }
  }

  @override
  void dispose() {
    for (final timer in _reorderTimers.values) {
      timer.cancel();
    }
    _reorderTimers.clear();
    _addController.dispose();
    _addFocus.dispose();
    _categoryController.dispose();
    _categoryFocus.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _clearAllReorderHolds() {
    for (final timer in _reorderTimers.values) {
      timer.cancel();
    }
    _reorderTimers.clear();
    _pendingTodoItemByCategory.clear();
    _heldItemOrderByCategory.clear();
  }

  void _releaseReorderHold(String categoryId) {
    _reorderTimers.remove(categoryId)?.cancel();
    _pendingTodoItemByCategory.remove(categoryId);
    final changed = _heldItemOrderByCategory.remove(categoryId) != null;
    if (changed && mounted) setState(() {});
  }

  List<TripItemModel> _visualItems(TripCategoryModel category) {
    if (widget.stateFilter != TripStateFilter.all) return category.items;
    final heldOrder = _heldItemOrderByCategory[category.id];
    if (heldOrder == null) return category.items;
    final byId = {for (final item in category.items) item.id: item};
    return [
      ...heldOrder.map((id) => byId.remove(id)).whereType<TripItemModel>(),
      ...byId.values,
    ];
  }

  Future<void> _enqueueCycle(String itemId) {
    final previous = _cycleTails[itemId] ?? Future<void>.value();
    Future<void> run() async {
      try {
        await previous;
      } on Object {
        // Une tentative échouée ne doit pas bloquer les taps suivants.
      }
      await widget.useCases.cycleItemStatus(itemId);
    }

    final next = run();
    _cycleTails[itemId] = next;
    unawaited(
      next.then<void>(
        (_) {
          if (identical(_cycleTails[itemId], next)) {
            _cycleTails.remove(itemId);
          }
        },
        onError: (Object _, StackTrace _) {
          if (identical(_cycleTails[itemId], next)) {
            _cycleTails.remove(itemId);
          }
        },
      ),
    );
    return next;
  }

  Future<void> _cycleItem(
    TripCategoryModel category,
    TripItemModel item,
  ) async {
    final categoryId = category.id;
    final pendingItemId = _pendingTodoItemByCategory[categoryId];

    if (pendingItemId == item.id) {
      _reorderTimers.remove(categoryId)?.cancel();
      try {
        await _enqueueCycle(item.id);
      } on Object catch (error) {
        _message(userMessageFor(error));
      } finally {
        _releaseReorderHold(categoryId);
      }
      return;
    }

    if (widget.stateFilter == TripStateFilter.all &&
        item.status == TripItemStatus.todo &&
        pendingItemId == null) {
      setState(() {
        _heldItemOrderByCategory[categoryId] = category.items
            .map((candidate) => candidate.id)
            .toList(growable: false);
        _pendingTodoItemByCategory[categoryId] = item.id;
      });
      _reorderTimers[categoryId] = Timer(
        _reorderDelay,
        () => _releaseReorderHold(categoryId),
      );
      try {
        await _enqueueCycle(item.id);
      } on Object catch (error) {
        _message(userMessageFor(error));
        _releaseReorderHold(categoryId);
      }
      return;
    }

    try {
      await _enqueueCycle(item.id);
    } on Object catch (error) {
      _message(userMessageFor(error));
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      _expandedCategoryId = _expandedCategoryId == categoryId
          ? null
          : categoryId;
      _editingItemId = null;
      _addController.clear();
      _addFocus.unfocus();
    });
  }

  Future<void> _addItem(TripCategoryModel category) async {
    final name = _addController.text.trim();
    if (name.isEmpty || _adding) return;
    setState(() => _adding = true);
    try {
      await widget.useCases.addItem(widget.tripId, category.id, name);
      _addController.clear();
    } on Object catch (error) {
      _message(userMessageFor(error));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty || _addingCategory) return;
    setState(() => _addingCategory = true);
    try {
      await widget.useCases.addCategory(
        widget.tripId,
        widget.member.id == 'general-${widget.tripId}'
            ? null
            : widget.member.id,
        name,
      );
      _categoryController.clear();
    } on Object catch (error) {
      _message(userMessageFor(error));
    } finally {
      if (mounted) setState(() => _addingCategory = false);
    }
  }

  Future<void> _openCategoryDetails(TripCategoryModel category) async {
    await showHierarchyEntityActionsSheet(
      context,
      entityId: category.id,
      entityLabel: 'Catégorie',
      initialName: category.name,
      initialIcon: category.icon,
      onRename: (name) => widget.useCases.renameCategory(category.id, name),
      onIconChanged: (icon) =>
          widget.useCases.setCategoryIcon(category.id, icon),
      onDelete: () async {
        await widget.useCases.removeCategory(category.id);
        if (_expandedCategoryId == category.id && mounted) {
          setState(() => _expandedCategoryId = null);
        }
      },
    );
  }

  Widget _buildCategoryHeader(
    TripCategoryModel category,
    TripCategoryModel completeCategory,
  ) {
    return _TripCategoryHeader(
      key: Key('trip-category-${category.id}'),
      category: category,
      progress: ProgressCalculator.forCategory(completeCategory),
      expanded: _expandedCategoryId == category.id,
      onTap: () => _toggleCategory(category.id),
      onLongPress: () => _openCategoryDetails(category),
      onIconTap: () => _openCategoryDetails(category),
    );
  }

  Widget _buildCategoryBlock(
    TripCategoryModel category,
    TripCategoryModel completeCategory,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      key: ValueKey('category-block:${category.id}'),
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        key: Key('trip-category-items-surface-${category.id}'),
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCategoryHeader(category, completeCategory),
            if (_expandedCategoryId == category.id) ...[
              ..._visualItems(category).map(
                (item) => _TripItemRow(
                  key: Key('trip-item-${item.id}'),
                  item: item,
                  editing: _editingItemId == item.id,
                  editController: _editController,
                  onCycle: () => _cycleItem(category, item),
                  onDecrease: item.quantity <= 1
                      ? null
                      : () => widget.useCases.changeItemQuantity(item.id, -1),
                  onIncrease: item.quantity >= 99
                      ? null
                      : () => widget.useCases.changeItemQuantity(item.id, 1),
                  onRename: () => _saveEditing(item.id),
                  onCancelRename: () => setState(() => _editingItemId = null),
                  onLongPress: () => _manageContexts(item),
                  confirmDismiss: (direction) => _handleSwipe(item, direction),
                ),
              ),
              _InlineTripItemAdder(
                key: Key('trip-inline-adder-${category.id}'),
                categoryId: category.id,
                controller: _addController,
                focusNode: _addFocus,
                adding: _adding,
                onAdd: () => _addItem(category),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startEditing(TripItemModel item) {
    setState(() {
      _editingItemId = item.id;
      _editController.text = item.name;
      _editController.selection = TextSelection.collapsed(
        offset: _editController.text.length,
      );
    });
  }

  Future<void> _saveEditing(String itemId) async {
    final name = _editController.text.trim();
    if (name.isEmpty) return;
    try {
      await widget.useCases.renameItem(itemId, name);
      if (mounted) setState(() => _editingItemId = null);
    } on Object catch (error) {
      _message(userMessageFor(error));
    }
  }

  Future<bool> _handleSwipe(
    TripItemModel item,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      _startEditing(item);
      return false;
    }
    try {
      await widget.useCases.removeItem(item.id);
      return true;
    } on Object catch (error) {
      _message(userMessageFor(error));
      return false;
    }
  }

  Future<void> _manageContexts(TripItemModel item) async {
    final sourceIds = item.sources
        .map((source) => source.contributingLibraryItemId)
        .whereType<String>()
        .toSet();
    if (sourceIds.length != 1) {
      _message(
        sourceIds.isEmpty
            ? 'Cet item n’a pas de source dans la bibliothèque.'
            : 'Cet item a plusieurs sources. Gérez ses contextes dans la bibliothèque.',
      );
      return;
    }
    final contexts = await widget.useCases.loadContexts();
    if (!mounted) return;
    if (contexts.isEmpty) {
      _message('Créez d’abord un contexte dans la bibliothèque.');
      return;
    }
    final sourceId = sourceIds.single;
    final initial = await widget.useCases.loadContextIdsForLibraryItem(
      sourceId,
    );
    if (!mounted) return;
    final selected = await showItemContextsSheet(
      context,
      itemName: item.name,
      contexts: contexts,
      initialSelection: initial,
    );
    if (selected != null) {
      await widget.useCases.saveContextIdsForLibraryItem(sourceId, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressCalculator.forMember(widget.completeMember);
    return CustomScrollView(
      key: Key('trip-member-page-${widget.member.id}'),
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Row(
            children: [
              CategoryIconView(
                key: Key('trip-group-page-icon-${widget.member.id}'),
                icon: widget.member.icon,
                size: 23,
                fallbackIcon:
                    widget.member.groupKind == TripMemberGroupKind.family
                    ? Icons.person_outline
                    : Icons.folder_outlined,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.member.name,
                  style: AppTextScale.of(context).pageTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          sliver: SliverToBoxAdapter(
            child: _CompactProgress(progress: progress),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverList.builder(
            itemCount: widget.member.categories.length,
            itemBuilder: (context, index) {
              final category = widget.member.categories[index];
              final completeCategory = widget.completeMember.categories
                  .singleWhere((candidate) => candidate.id == category.id);
              return _buildCategoryBlock(category, completeCategory);
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _InlineTripCategoryAdder(
              key: Key('trip-add-category-${widget.member.id}'),
              controller: _categoryController,
              focusNode: _categoryFocus,
              adding: _addingCategory,
              onAdd: _addCategory,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
          ),
        ),
      ],
    );
  }
}

class _TripCategoryHeader extends StatelessWidget {
  const _TripCategoryHeader({
    super.key,
    required this.category,
    required this.progress,
    required this.expanded,
    required this.onTap,
    required this.onLongPress,
    required this.onIconTap,
  });

  final TripCategoryModel category;
  final ChecklistProgress progress;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onIconTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = Color.alphaBlend(
      AppColors.primary.withValues(alpha: dark ? 0.24 : 0.20),
      colors.surfaceContainer,
    );
    return Material(
      key: Key('trip-category-header-surface-${category.id}'),
      color: headerColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                InkWell(
                  key: Key('trip-category-icon-${category.id}'),
                  onTap: onIconTap,
                  borderRadius: BorderRadius.circular(AppRadius.field),
                  child: SizedBox.square(
                    dimension: 32,
                    child: Center(
                      child: CategoryIconView(
                        icon: category.icon,
                        size: 22,
                        fallbackIcon: Icons.folder_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextScale.of(context).sectionTitle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${progress.completed}/${progress.total}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  key: Key('trip-category-toggle-${category.id}'),
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TripItemRow extends StatelessWidget {
  const _TripItemRow({
    super.key,
    required this.item,
    required this.editing,
    required this.editController,
    required this.onCycle,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRename,
    required this.onCancelRename,
    required this.onLongPress,
    required this.confirmDismiss,
  });

  final TripItemModel item;
  final bool editing;
  final TextEditingController editController;
  final VoidCallback onCycle;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback onRename;
  final VoidCallback onCancelRename;
  final VoidCallback onLongPress;
  final ConfirmDismissCallback confirmDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final done = item.status == TripItemStatus.done;
    final checked = item.status == TripItemStatus.checked;
    final textColor = switch (item.status) {
      TripItemStatus.todo => colors.onSurface,
      TripItemStatus.checked => colors.onSurfaceVariant,
      TripItemStatus.done => colors.onSurfaceVariant.withValues(alpha: 0.78),
    };
    return Dismissible(
      key: ValueKey('trip-item-dismiss-${item.id}'),
      direction: editing ? DismissDirection.none : DismissDirection.horizontal,
      confirmDismiss: confirmDismiss,
      background: const _TripSwipeAction(
        alignment: Alignment.centerLeft,
        icon: Icons.edit_outlined,
        label: 'Modifier',
      ),
      secondaryBackground: const _TripSwipeAction(
        alignment: Alignment.centerRight,
        icon: Icons.delete_outline,
        label: 'Supprimer',
        destructive: true,
      ),
      child: InkWell(
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                _TripStatusControl(
                  key: Key('trip-item-status-${item.id}'),
                  status: item.status,
                  onPressed: onCycle,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: editing
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                key: Key('trip-item-edit-${item.id}'),
                                controller: editController,
                                autofocus: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => onRename(),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.sm,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              key: Key('trip-item-edit-save-${item.id}'),
                              tooltip: 'Enregistrer',
                              onPressed: onRename,
                              icon: const Icon(Icons.check, size: 20),
                            ),
                            IconButton(
                              tooltip: 'Annuler',
                              onPressed: onCancelRename,
                              icon: const Icon(Icons.close, size: 20),
                            ),
                          ],
                        )
                      : Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: textColor,
                                decoration: done
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontStyle: checked
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                        ),
                ),
                if (!editing)
                  if (item.quantity <= 1)
                    _QuantityButton(
                      key: Key('trip-item-increase-${item.id}'),
                      tooltip: 'Passer à 2',
                      icon: Icons.add,
                      onPressed: onIncrease,
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QuantityButton(
                          key: Key('trip-item-decrease-${item.id}'),
                          tooltip: 'Diminuer',
                          icon: Icons.remove,
                          onPressed: onDecrease,
                        ),
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        _QuantityButton(
                          key: Key('trip-item-increase-${item.id}'),
                          tooltip: 'Augmenter',
                          icon: Icons.add,
                          onPressed: onIncrease,
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TripStatusControl extends StatelessWidget {
  const _TripStatusControl({
    super.key,
    required this.status,
    required this.onPressed,
  });

  final TripItemStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (status) {
      TripItemStatus.todo => colors.onSurfaceVariant,
      TripItemStatus.checked => colors.onSurfaceVariant,
      TripItemStatus.done => colors.primary,
    };
    return Semantics(
      button: true,
      label: _statusLabel(status),
      child: InkResponse(
        onTap: onPressed,
        radius: 22,
        containedInkWell: true,
        child: SizedBox.square(
          dimension: 40,
          child: Center(
            child: CustomPaint(
              key: ValueKey('trip-status-shape-${status.name}'),
              size: const Size.square(20),
              painter: _TripStatusPainter(status: status, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _TripStatusPainter extends CustomPainter {
  const _TripStatusPainter({required this.status, required this.color});

  final TripItemStatus status;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    canvas.drawRect(rect, paint);
    if (status == TripItemStatus.checked || status == TripItemStatus.done) {
      canvas.drawLine(
        Offset(size.width * 0.28, size.height / 2),
        Offset(size.width * 0.72, size.height / 2),
        paint,
      );
    }
    if (status == TripItemStatus.done) {
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.28),
        Offset(size.width / 2, size.height * 0.72),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TripStatusPainter oldDelegate) =>
      oldDelegate.status != status || oldDelegate.color != color;
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
    );
  }
}

class _InlineTripGroupAdder extends StatefulWidget {
  const _InlineTripGroupAdder({
    super.key,
    required this.sectionKey,
    required this.label,
    required this.onSubmit,
  });

  final String sectionKey;
  final String label;
  final Future<void> Function(String) onSubmit;

  @override
  State<_InlineTripGroupAdder> createState() => _InlineTripGroupAdderState();
}

class _InlineTripGroupAdderState extends State<_InlineTripGroupAdder> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_collapseWhenEmpty);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_collapseWhenEmpty);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _collapseWhenEmpty() {
    if (!_focusNode.hasFocus && _editing && _controller.text.trim().isEmpty) {
      setState(() => _editing = false);
    }
  }

  void _activate() {
    if (_editing) return;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(name);
      _controller.clear();
    } on Object {
      // Le niveau appelant affiche le message métier.
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextScale.of(
      context,
    ).body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    if (!_editing) {
      return InkWell(
        key: Key('trip-add-group-${widget.sectionKey}-collapsed'),
        onTap: _activate,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Row(
              children: [
                Expanded(child: Text(widget.label, style: textStyle)),
                IconButton.filledTonal(
                  tooltip: widget.label,
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _activate,
                  icon: const Icon(Icons.add, size: 19),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: Key('trip-add-group-${widget.sectionKey}-field'),
                controller: _controller,
                focusNode: _focusNode,
                style: AppTextScale.of(context).body,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onTapOutside: (_) => _focusNode.unfocus(),
                decoration: InputDecoration(
                  hintText: '${widget.label}…',
                  hintStyle: textStyle,
                  isDense: true,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            IconButton.filledTonal(
              key: Key('trip-add-group-${widget.sectionKey}-submit'),
              tooltip: 'Ajouter',
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineTripCategoryAdder extends StatefulWidget {
  const _InlineTripCategoryAdder({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.adding,
    required this.onAdd,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool adding;
  final Future<void> Function() onAdd;

  @override
  State<_InlineTripCategoryAdder> createState() =>
      _InlineTripCategoryAdderState();
}

class _InlineTripCategoryAdderState extends State<_InlineTripCategoryAdder> {
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_collapseWhenEmpty);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_collapseWhenEmpty);
    super.dispose();
  }

  void _collapseWhenEmpty() {
    if (!widget.focusNode.hasFocus &&
        _editing &&
        widget.controller.text.trim().isEmpty) {
      setState(() => _editing = false);
    }
  }

  void _activate() {
    if (_editing) return;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.focusNode.requestFocus();
    });
  }

  Future<void> _submit() async {
    if (widget.controller.text.trim().isEmpty || widget.adding) return;
    await widget.onAdd();
    if (mounted && widget.controller.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      return InkWell(
        key: const Key('trip-add-category-collapsed'),
        onTap: _activate,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ajouter une catégorie',
                    style: AppTextScale.of(context).body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Ajouter une catégorie',
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _activate,
                  icon: const Icon(Icons.add, size: 19),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('trip-add-category-field'),
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: AppTextScale.of(context).body,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onTapOutside: (_) => widget.focusNode.unfocus(),
              decoration: InputDecoration(
                hintText: 'Ajouter une catégorie…',
                hintStyle: AppTextScale.of(context).body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton.filledTonal(
            key: const Key('trip-add-category-submit'),
            tooltip: 'Ajouter',
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            padding: EdgeInsets.zero,
            onPressed: widget.adding ? null : _submit,
            icon: widget.adding
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _InlineTripItemAdder extends StatefulWidget {
  const _InlineTripItemAdder({
    super.key,
    required this.categoryId,
    required this.controller,
    required this.focusNode,
    required this.adding,
    required this.onAdd,
  });

  final String categoryId;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool adding;
  final Future<void> Function() onAdd;

  @override
  State<_InlineTripItemAdder> createState() => _InlineTripItemAdderState();
}

class _InlineTripItemAdderState extends State<_InlineTripItemAdder> {
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_collapseWhenEmpty);
  }

  @override
  void didUpdateWidget(covariant _InlineTripItemAdder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_collapseWhenEmpty);
      widget.focusNode.addListener(_collapseWhenEmpty);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_collapseWhenEmpty);
    super.dispose();
  }

  void _collapseWhenEmpty() {
    if (!widget.focusNode.hasFocus &&
        _editing &&
        widget.controller.text.trim().isEmpty) {
      setState(() => _editing = false);
    }
  }

  void _activate() {
    if (_editing) return;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.focusNode.requestFocus();
    });
  }

  Future<void> _submit() async {
    if (widget.controller.text.trim().isEmpty || widget.adding) return;
    await widget.onAdd();
    if (mounted && widget.controller.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      return InkWell(
        key: Key('trip-add-item-collapsed-${widget.categoryId}'),
        onTap: _activate,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.only(left: 52, right: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ajouter un item',
                    style: AppTextScale.of(context).body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  key: Key('trip-add-item-submit-${widget.categoryId}'),
                  tooltip: 'Ajouter un item',
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _activate,
                  icon: const Icon(Icons.add, size: 19),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        52,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: Key('trip-add-item-${widget.categoryId}'),
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: AppTextScale.of(context).body,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onTapOutside: (_) => widget.focusNode.unfocus(),
              decoration: InputDecoration(
                hintText: 'Ajouter un item…',
                hintStyle: AppTextScale.of(context).body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton.filledTonal(
            key: Key('trip-add-item-submit-${widget.categoryId}'),
            tooltip: 'Ajouter',
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            padding: EdgeInsets.zero,
            onPressed: widget.adding ? null : _submit,
            icon: widget.adding
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _TripSwipeAction extends StatelessWidget {
  const _TripSwipeAction({
    required this.alignment,
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = destructive
        ? colors.onErrorContainer
        : colors.onPrimaryContainer;
    return Container(
      alignment: alignment,
      color: destructive ? colors.errorContainer : colors.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(TripItemStatus status) => switch (status) {
  TripItemStatus.todo => 'À préparer',
  TripItemStatus.checked => 'Prêt',
  TripItemStatus.done => 'Rangé',
};

String _stateFilterLabel(TripStateFilter filter) => switch (filter) {
  TripStateFilter.all => 'Tout',
  TripStateFilter.todo => 'À préparer',
  TripStateFilter.checked => 'Prêt',
  TripStateFilter.done => 'Rangé',
};

String _dateLabel(DateTime? value, String fallback) {
  if (value == null) return fallback;
  return '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}
