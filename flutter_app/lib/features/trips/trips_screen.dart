import 'package:flutter/material.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/models/progress.dart';
import '../../domain/models/trip_archive.dart';
import '../../domain/models/trip_filters.dart';
import '../../domain/usecases/trip_use_cases.dart';
import '../../domain/usecases/shared_document_use_cases.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../shared/destination_scaffold.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({
    super.key,
    required this.watchTrips,
    required this.useCases,
    this.sharedDocuments,
  });

  final WatchTrips watchTrips;
  final TripUseCases useCases;
  final SharedDocumentUseCases? sharedDocuments;

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String? _selectedTripId;
  bool _showArchives = false;

  Future<void> _join() async {
    final sharing = widget.sharedDocuments;
    if (sharing == null) return;
    final code = await _askCode(context);
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
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _createTrip() async {
    final owners = await widget.useCases.loadGenerationChoices();
    final contexts = await widget.useCases.loadContexts();
    if (!mounted) return;
    final request = await showDialog<CreateTripRequest>(
      context: context,
      builder: (context) =>
          _CreateTripDialog(owners: owners, contexts: contexts),
    );
    if (request == null) return;
    try {
      final id = await widget.useCases.createTrip(request);
      if (mounted) setState(() => _selectedTripId = id);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _duplicateTrip(TripDetailModel source) async {
    final request = await showDialog<DuplicateTripRequest>(
      context: context,
      builder: (context) => _DuplicateTripDialog(source: source),
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
      ).showSnackBar(SnackBar(content: Text(error.toString())));
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
        onDuplicate: _duplicateTrip,
        sharedDocuments: widget.sharedDocuments,
      );
    }
    return DestinationScaffold(
      title: 'Voyages',
      actions: [
        if (widget.sharedDocuments != null)
          IconButton(
            key: const Key('trip-join'),
            onPressed: _join,
            tooltip: 'Rejoindre avec un code',
            icon: const Icon(Icons.group_add_outlined),
          ),
        IconButton(
          key: const Key('trip-create'),
          onPressed: _createTrip,
          tooltip: 'Créer un voyage',
          icon: const Icon(Icons.add),
        ),
      ],
      child: StreamBuilder<List<TripSummary>>(
        stream: widget.watchTrips(),
        builder: (context, snapshot) {
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
              SegmentedButton<bool>(
                key: const Key('trip-archive-tabs'),
                segments: const [
                  ButtonSegment(value: false, label: Text('Voyages')),
                  ButtonSegment(value: true, label: Text('Archives')),
                ],
                selected: {_showArchives},
                onSelectionChanged: (selection) =>
                    setState(() => _showArchives = selection.single),
              ),
              const SizedBox(height: 16),
              if (_showArchives)
                if (archives.isEmpty)
                  const EmptyDestination(
                    icon: Icons.archive_outlined,
                    title: 'Aucune archive',
                    message: 'Les voyages terminés apparaîtront ici.',
                  )
                else
                  ...archives.map(
                    (trip) => _TripSummaryCard(
                      trip: trip,
                      archived: true,
                      onTap: () => setState(() => _selectedTripId = trip.id),
                    ),
                  )
              else if (!hasActive)
                const EmptyDestination(
                  icon: Icons.luggage_outlined,
                  title: 'Aucun voyage actif',
                  message: 'Créez un voyage depuis votre bibliothèque.',
                )
              else ...[
                if (upcoming.isNotEmpty) ...[
                  Text(
                    'À venir',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  ...upcoming.map(
                    (trip) => _TripSummaryCard(
                      trip: trip,
                      archived: false,
                      onTap: () => setState(() => _selectedTripId = trip.id),
                    ),
                  ),
                ],
                if (ongoing.isNotEmpty) ...[
                  if (upcoming.isNotEmpty) const SizedBox(height: 12),
                  Text(
                    'En cours',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  ...ongoing.map(
                    (trip) => _TripSummaryCard(
                      trip: trip,
                      archived: false,
                      onTap: () => setState(() => _selectedTripId = trip.id),
                    ),
                  ),
                ],
              ],
            ],
          );
        },
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
    final details = <String>[
      if (trip.destination.isNotEmpty) trip.destination,
      if (trip.startDate != null || trip.endDate != null)
        _dateRangeLabel(trip.startDate, trip.endDate),
      if (trip.participantNames.isNotEmpty) trip.participantNames.join(', '),
      if (trip.shared) 'Partagé',
    ];
    return Card(
      key: Key('trip-summary-${trip.id}'),
      child: ListTile(
        leading: Icon(
          archived ? Icons.archive_outlined : Icons.luggage_outlined,
        ),
        title: Text(trip.name),
        subtitle: details.isEmpty ? null : Text(details.join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _CreateTripDialog extends StatefulWidget {
  const _CreateTripDialog({required this.owners, required this.contexts});

  final List<LibraryOwnerModel> owners;
  final List<ContextModel> contexts;

  @override
  State<_CreateTripDialog> createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends State<_CreateTripDialog> {
  final _name = TextEditingController();
  final _destination = TextEditingController();
  final _participants = <String>{};
  final _transports = <String>{};
  final _lodgings = <String>{};
  final _contexts = <String>{};
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _name.dispose();
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

  @override
  Widget build(BuildContext context) {
    final participants = widget.owners
        .where(
          (owner) =>
              owner.kind == LibraryOwnerKind.familyMember &&
              owner.generationRole == GenerationRole.participant,
        )
        .toList();
    final transports = widget.owners
        .where((owner) => owner.generationRole == GenerationRole.transport)
        .toList();
    final lodgings = widget.owners
        .where((owner) => owner.generationRole == GenerationRole.lodging)
        .toList();
    final essentials = widget.owners
        .where((owner) => owner.generationRole == GenerationRole.essential)
        .length;
    return AlertDialog(
      title: const Text('Nouveau voyage'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('trip-name'),
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nom du voyage'),
              ),
              TextField(
                key: const Key('trip-destination'),
                controller: _destination,
                decoration: const InputDecoration(labelText: 'Destination'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickStart,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(_dateLabel(_startDate, 'Début')),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickEnd,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(_dateLabel(_endDate, 'Fin')),
                  ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.star_outline),
                title: const Text('Essentiels'),
                subtitle: Text(
                  '$essentials groupe(s) ajouté(s) automatiquement',
                ),
              ),
              _ChoiceGroup(
                title: 'Participants',
                owners: participants,
                selected: _participants,
                onChanged: _toggle,
              ),
              _ChoiceGroup(
                title: 'Transports',
                owners: transports,
                selected: _transports,
                onChanged: _toggle,
              ),
              _ChoiceGroup(
                title: 'Logements',
                owners: lodgings,
                selected: _lodgings,
                onChanged: _toggle,
              ),
              _ContextChoiceGroup(
                contexts: widget.contexts,
                selected: _contexts,
                onChanged: _toggle,
              ),
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
          key: const Key('trip-submit'),
          onPressed: () => Navigator.pop(
            context,
            CreateTripRequest(
              name: _name.text,
              destination: _destination.text,
              startDate: _startDate,
              endDate: _endDate,
              participantOwnerIds: _participants,
              transportOwnerIds: _transports,
              lodgingOwnerIds: _lodgings,
              contextIds: _contexts,
            ),
          ),
          child: const Text('Créer'),
        ),
      ],
    );
  }

  void _toggle(Set<String> selected, String id, bool value) {
    setState(() => value ? selected.add(id) : selected.remove(id));
  }
}

class _DuplicateTripDialog extends StatefulWidget {
  const _DuplicateTripDialog({required this.source});

  final TripDetailModel source;

  @override
  State<_DuplicateTripDialog> createState() => _DuplicateTripDialogState();
}

class _DuplicateTripDialogState extends State<_DuplicateTripDialog> {
  late final TextEditingController _name;
  late final TextEditingController _destination;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: 'Copie de ${widget.source.name}');
    _destination = TextEditingController(text: widget.source.destination);
  }

  @override
  void dispose() {
    _name.dispose();
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
    if (_name.text.trim().isEmpty || _startDate == null || _endDate == null) {
      setState(() => _error = 'Nom et nouvelles dates requis.');
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
        name: _name.text,
        destination: _destination.text,
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
              TextField(
                key: const Key('trip-duplicate-name'),
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                key: const Key('trip-duplicate-destination'),
                controller: _destination,
                decoration: const InputDecoration(labelText: 'Destination'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('trip-duplicate-start'),
                    onPressed: _pickStart,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(_dateLabel(_startDate, 'Nouveau départ')),
                  ),
                  OutlinedButton.icon(
                    key: const Key('trip-duplicate-end'),
                    onPressed: _pickEnd,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(_dateLabel(_endDate, 'Nouveau retour')),
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

class _ContextChoiceGroup extends StatelessWidget {
  const _ContextChoiceGroup({
    required this.contexts,
    required this.selected,
    required this.onChanged,
  });

  final List<ContextModel> contexts;
  final Set<String> selected;
  final void Function(Set<String>, String, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Contextes / activités',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (contexts.isEmpty)
          const Text('Aucun contexte dans la bibliothèque')
        else
          ...contexts.map(
            (activity) => CheckboxListTile(
              key: Key('trip-context-${activity.id}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: selected.contains(activity.id),
              title: Text(activity.name),
              onChanged: (value) =>
                  onChanged(selected, activity.id, value ?? false),
            ),
          ),
      ],
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup({
    required this.title,
    required this.owners,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<LibraryOwnerModel> owners;
  final Set<String> selected;
  final void Function(Set<String>, String, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        if (owners.isEmpty)
          const Text('Aucun choix dans la bibliothèque')
        else
          ...owners.map(
            (owner) => CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: selected.contains(owner.id),
              title: Text(owner.name),
              onChanged: (value) =>
                  onChanged(selected, owner.id, value ?? false),
            ),
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
    required this.onDuplicate,
    required this.sharedDocuments,
  });

  final String tripId;
  final TripUseCases useCases;
  final VoidCallback onBack;
  final Future<void> Function(TripDetailModel) onDuplicate;
  final SharedDocumentUseCases? sharedDocuments;

  @override
  State<_TripDetail> createState() => _TripDetailState();
}

class _TripDetailState extends State<_TripDetail> {
  TripFilter _filter = const TripFilter();
  late final Stream<TripDetailModel?> _tripStream;

  @override
  void initState() {
    super.initState();
    _tripStream = widget.useCases.watchTrip(widget.tripId);
  }

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
        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              leading: IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(trip.name),
              actions: [
                if (trip.shared)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Center(child: Chip(label: Text('Partagé'))),
                  ),
                if (widget.sharedDocuments != null)
                  IconButton(
                    key: Key(
                      trip.v1ShareReady ? 'trip-show-code' : 'trip-share',
                    ),
                    tooltip: trip.v1ShareReady
                        ? 'Afficher le code'
                        : 'Partager',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () async {
                      try {
                        final code = trip.v1ShareReady
                            ? trip.shareCode
                            : (await widget.sharedDocuments!.shareTrip(
                                trip.id,
                              )).shareCode;
                        if (context.mounted && code != null) {
                          await _showCode(context, code);
                        }
                      } on Object catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      }
                    },
                  ),
                PopupMenuButton<String>(
                  key: const Key('trip-actions'),
                  position: PopupMenuPosition.under,
                  onSelected: (action) async {
                    if (action == 'duplicate') {
                      await widget.onDuplicate(trip);
                    } else if (action == 'archive') {
                      await widget.useCases.archiveTrip(trip.id);
                    } else if (action == 'restore') {
                      await widget.useCases.restoreTrip(trip.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Dupliquer'),
                    ),
                    if (trip.archivedAt != null)
                      const PopupMenuItem(
                        value: 'restore',
                        child: Text('Restaurer'),
                      )
                    else if (!TripArchiveClassifier.isFinished(
                      trip.endDate,
                      DateTime.now(),
                    ))
                      const PopupMenuItem(
                        value: 'archive',
                        child: Text('Archiver'),
                      ),
                  ],
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(
                children: [
                  if (trip.destination.isNotEmpty)
                    Text(
                      trip.destination,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress.percent / 100),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.completed}/${progress.total} rangés · ${progress.percent}%',
                  ),
                  const SizedBox(height: 12),
                  _TripFilters(
                    filter: effectiveFilter,
                    personOptions: personOptions,
                    onStateChanged: (state) => setState(
                      () => _filter = _filter.copyWith(state: state),
                    ),
                    onPersonChanged: (person) => setState(
                      () => _filter = _filter.copyWith(person: person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (visibleMembers.isEmpty)
                    _EmptyTripFilter(
                      filter: effectiveFilter,
                      personOptions: personOptions,
                    )
                  else
                    ...visibleMembers.map((member) {
                      final completeMember = trip.members.singleWhere(
                        (candidate) => candidate.id == member.id,
                      );
                      return _TripMemberCard(
                        member: member,
                        completeMember: completeMember,
                        useCases: widget.useCases,
                      );
                    }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TripFilters extends StatelessWidget {
  const _TripFilters({
    required this.filter,
    required this.personOptions,
    required this.onStateChanged,
    required this.onPersonChanged,
  });

  final TripFilter filter;
  final List<TripPersonOption> personOptions;
  final ValueChanged<TripStateFilter> onStateChanged;
  final ValueChanged<TripPersonFilter> onPersonChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Filtrer par état',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TripStateFilter.values
                  .map(
                    (state) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: Key('trip-state-${state.name}'),
                        label: Text(_stateFilterLabel(state)),
                        selected: filter.state == state,
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
        ),
        const SizedBox(height: 4),
        Semantics(
          label: 'Filtrer par personne',
          child: SingleChildScrollView(
            key: const Key('trip-person-filters'),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: personOptions
                  .map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: Key(_personFilterKey(option.filter)),
                        label: Text(option.label),
                        selected: filter.person == option.filter,
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        onSelected: (_) => onPersonChanged(option.filter),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyTripFilter extends StatelessWidget {
  const _EmptyTripFilter({required this.filter, required this.personOptions});

  final TripFilter filter;
  final List<TripPersonOption> personOptions;

  @override
  Widget build(BuildContext context) {
    final person = personOptions
        .where((option) => option.filter == filter.person)
        .map((option) => option.label)
        .firstOrNull;
    final state = switch (filter.state) {
      TripStateFilter.all => 'élément',
      TripStateFilter.todo => 'élément à préparer',
      TripStateFilter.checked => 'élément prêt',
      TripStateFilter.done => 'élément rangé',
    };
    final suffix = filter.person.kind == TripPersonFilterKind.all
        ? ''
        : ' pour ${person ?? 'cette personne'}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'Aucun $state$suffix.',
        key: const Key('trip-filter-empty'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

Future<String?> _askCode(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rejoindre avec un code'),
      content: TextField(
        key: const Key('share-code-input'),
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(labelText: 'Code à 8 caractères'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('share-code-submit'),
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Rejoindre'),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

Future<void> _showCode(BuildContext context, String code) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Partager'),
    content: SelectableText(
      code,
      key: const Key('shared-code'),
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fermer'),
      ),
    ],
  ),
);

class _TripMemberCard extends StatelessWidget {
  const _TripMemberCard({
    required this.member,
    required this.completeMember,
    required this.useCases,
  });

  final TripMemberModel member;
  final TripMemberModel completeMember;
  final TripUseCases useCases;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressCalculator.forMember(completeMember);
    return Card(
      key: Key('trip-member-${member.id}'),
      child: ExpansionTile(
        key: PageStorageKey<String>('trip-member-tile-${member.id}'),
        maintainState: true,
        title: Text(member.name),
        subtitle: Text('${progress.completed}/${progress.total} rangés'),
        children: member.categories
            .map((category) {
              final completeCategory = completeMember.categories.singleWhere(
                (candidate) => candidate.id == category.id,
              );
              return _TripCategoryTile(
                category: category,
                completeCategory: completeCategory,
                useCases: useCases,
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _TripCategoryTile extends StatelessWidget {
  const _TripCategoryTile({
    required this.category,
    required this.completeCategory,
    required this.useCases,
  });

  final TripCategoryModel category;
  final TripCategoryModel completeCategory;
  final TripUseCases useCases;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressCalculator.forCategory(completeCategory);
    return ExpansionTile(
      key: PageStorageKey<String>('trip-category-${category.id}'),
      maintainState: true,
      title: Text(category.name),
      subtitle: Text('${progress.completed}/${progress.total} rangés'),
      children: category.items
          .map(
            (item) => Padding(
              key: Key('trip-item-${item.id}'),
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: _statusLabel(item.status),
                        onPressed: () => useCases.cycleItemStatus(item.id),
                        icon: Icon(_statusIcon(item.status)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name),
                            Text(
                              _statusLabel(item.status),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Retirer du voyage',
                        onPressed: () => useCases.removeItem(item.id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Quantité'),
                      IconButton(
                        tooltip: 'Diminuer',
                        onPressed: () =>
                            useCases.changeItemQuantity(item.id, -1),
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Augmenter',
                        onPressed: () =>
                            useCases.changeItemQuantity(item.id, 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
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

String _personFilterKey(TripPersonFilter filter) => switch (filter.kind) {
  TripPersonFilterKind.all => 'trip-person-all',
  TripPersonFilterKind.general => 'trip-person-general',
  TripPersonFilterKind.participant => 'trip-person-${filter.memberId}',
};

IconData _statusIcon(TripItemStatus status) => switch (status) {
  TripItemStatus.todo => Icons.radio_button_unchecked,
  TripItemStatus.checked => Icons.check_circle_outline,
  TripItemStatus.done => Icons.inventory_2_outlined,
};

String _dateLabel(DateTime? value, String fallback) {
  if (value == null) return fallback;
  return '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}

String _dateRangeLabel(DateTime? start, DateTime? end) {
  if (start == null && end == null) return '';
  if (start == null) return 'jusqu’au ${_dateLabel(end, '')}';
  if (end == null) return 'dès le ${_dateLabel(start, '')}';
  return '${_dateLabel(start, '')}–${_dateLabel(end, '')}';
}
