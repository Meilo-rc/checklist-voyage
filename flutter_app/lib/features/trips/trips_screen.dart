import 'package:flutter/material.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/models/progress.dart';
import '../../domain/usecases/trip_use_cases.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../shared/destination_scaffold.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({
    super.key,
    required this.watchTrips,
    required this.useCases,
  });

  final WatchTrips watchTrips;
  final TripUseCases useCases;

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String? _selectedTripId;

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

  @override
  Widget build(BuildContext context) {
    final selected = _selectedTripId;
    if (selected != null) {
      return _TripDetail(
        tripId: selected,
        useCases: widget.useCases,
        onBack: () => setState(() => _selectedTripId = null),
      );
    }
    return DestinationScaffold(
      title: 'Voyages',
      actions: [
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
          if (trips.isEmpty) {
            return const EmptyDestination(
              icon: Icons.luggage_outlined,
              title: 'Aucun voyage local',
              message: 'Créez un voyage depuis votre bibliothèque.',
            );
          }
          return Column(
            children: trips
                .map(
                  (trip) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.luggage_outlined),
                      title: Text(trip.name),
                      subtitle: Text(trip.shared ? 'Partagé' : 'Local'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => setState(() => _selectedTripId = trip.id),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
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

class _TripDetail extends StatelessWidget {
  const _TripDetail({
    required this.tripId,
    required this.useCases,
    required this.onBack,
  });

  final String tripId;
  final TripUseCases useCases;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TripDetailModel?>(
      stream: useCases.watchTrip(tripId),
      builder: (context, snapshot) {
        final trip = snapshot.data;
        if (trip == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final progress = ProgressCalculator.forTrip(trip);
        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              leading: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(trip.name),
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
                  ...trip.members.map(
                    (member) =>
                        _TripMemberCard(member: member, useCases: useCases),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TripMemberCard extends StatelessWidget {
  const _TripMemberCard({required this.member, required this.useCases});

  final TripMemberModel member;
  final TripUseCases useCases;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressCalculator.forMember(member);
    return Card(
      child: ExpansionTile(
        title: Text(member.name),
        subtitle: Text('${progress.completed}/${progress.total} rangés'),
        children: member.categories
            .map(
              (category) =>
                  _TripCategoryTile(category: category, useCases: useCases),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _TripCategoryTile extends StatelessWidget {
  const _TripCategoryTile({required this.category, required this.useCases});

  final TripCategoryModel category;
  final TripUseCases useCases;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressCalculator.forCategory(category);
    return ExpansionTile(
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
