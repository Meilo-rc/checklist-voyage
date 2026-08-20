import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/checklist_models.dart';
import '../shared/selection_chip_group.dart';

class TripFormInitialData {
  const TripFormInitialData({
    this.name = '',
    this.destination = '',
    this.startDate,
    this.endDate,
    this.participantOwnerIds = const {},
    this.transportOwnerIds = const {},
    this.lodgingOwnerIds = const {},
    this.contextIds = const {},
  });

  final String name;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> participantOwnerIds;
  final Set<String> transportOwnerIds;
  final Set<String> lodgingOwnerIds;
  final Set<String> contextIds;
}

class TripFormResult {
  const TripFormResult({
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.participantOwnerIds,
    required this.transportOwnerIds,
    required this.lodgingOwnerIds,
    required this.contextIds,
  });

  final String name;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> participantOwnerIds;
  final Set<String> transportOwnerIds;
  final Set<String> lodgingOwnerIds;
  final Set<String> contextIds;
}

class TripForm extends StatefulWidget {
  const TripForm({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.owners,
    required this.contexts,
    this.initialData = const TripFormInitialData(),
    this.selectionsEditable = true,
  });

  final String title;
  final String submitLabel;
  final List<LibraryOwnerModel> owners;
  final List<ContextModel> contexts;
  final TripFormInitialData initialData;
  final bool selectionsEditable;

  @override
  State<TripForm> createState() => _TripFormState();
}

class _TripFormState extends State<TripForm> {
  late final TextEditingController _destination;
  late Set<String> _participants;
  late Set<String> _transports;
  late Set<String> _lodgings;
  late Set<String> _contexts;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;
    _destination = TextEditingController(text: initial.destination);
    _startDate = initial.startDate;
    _endDate = initial.endDate;
    _participants = Set.of(initial.participantOwnerIds);
    _transports = Set.of(initial.transportOwnerIds);
    _lodgings = Set.of(initial.lodgingOwnerIds);
    _contexts = Set.of(initial.contextIds);
  }

  @override
  void dispose() {
    _destination.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final initialRange = _startDate != null && _endDate != null
        ? DateTimeRange(start: _startDate!, end: _endDate!)
        : null;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initialRange,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Dates du voyage',
      saveText: 'Valider',
      confirmText: 'Valider',
      cancelText: 'Annuler',
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
        _error = null;
      });
    }
  }

  void _submit() {
    final destination = _destination.text.trim();
    if (destination.isEmpty) {
      setState(() => _error = 'Indiquez une destination.');
      return;
    }
    Navigator.pop(
      context,
      TripFormResult(
        name: widget.initialData.name.trim().isEmpty
            ? destination
            : widget.initialData.name,
        destination: destination,
        startDate: _startDate,
        endDate: _endDate,
        participantOwnerIds: Set.unmodifiable(_participants),
        transportOwnerIds: Set.unmodifiable(_transports),
        lodgingOwnerIds: Set.unmodifiable(_lodgings),
        contextIds: Set.unmodifiable(_contexts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participants = widget.owners
        .where(
          (owner) =>
              owner.kind == LibraryOwnerKind.familyMember &&
              owner.generationRole == GenerationRole.participant,
        )
        .map(_choice)
        .toList(growable: false);
    final transports = widget.owners
        .where((owner) => owner.generationRole == GenerationRole.transport)
        .map(_choice)
        .toList(growable: false);
    final lodgings = widget.owners
        .where((owner) => owner.generationRole == GenerationRole.lodging)
        .map(_choice)
        .toList(growable: false);
    final contexts = widget.contexts
        .map((context) => SelectionChoice(id: context.id, label: context.name))
        .toList(growable: false);
    final essentialCount = widget.owners
        .where((owner) => owner.generationRole == GenerationRole.essential)
        .length;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(
        heightFactor: 0.94,
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fermer',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('trip-form-scroll'),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        key: const Key('trip-destination'),
                        controller: _destination,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Destination',
                          hintText: 'Ex. Annecy',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        key: const Key('trip-date-range'),
                        onPressed: _pickDates,
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 14,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _startDate == null || _endDate == null
                                    ? 'Dates aller et retour'
                                    : _dateRangeLabel(_startDate!, _endDate!),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (essentialCount > 0) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Les essentiels seront ajoutés automatiquement.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      SelectionChipGroup(
                        title: 'Participants',
                        choices: participants,
                        selectedIds: _participants,
                        enabled: widget.selectionsEditable,
                        onChanged: (value) =>
                            setState(() => _participants = value),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SelectionChipGroup(
                        title: 'Transport',
                        choices: transports,
                        selectedIds: _transports,
                        enabled: widget.selectionsEditable,
                        onChanged: (value) =>
                            setState(() => _transports = value),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SelectionChipGroup(
                        title: 'Logement',
                        choices: lodgings,
                        selectedIds: _lodgings,
                        enabled: widget.selectionsEditable,
                        onChanged: (value) => setState(() => _lodgings = value),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SelectionChipGroup(
                        title: 'Activités',
                        choices: contexts,
                        selectedIds: _contexts,
                        enabled: widget.selectionsEditable,
                        onChanged: (value) => setState(() => _contexts = value),
                      ),
                      if (!widget.selectionsEditable) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Les choix ayant généré la checklist sont affichés '
                          'sans être régénérés.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _error!,
                          key: const Key('trip-form-error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: FilledButton(
                  key: const Key('trip-submit'),
                  onPressed: _submit,
                  child: Text(widget.submitLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SelectionChoice _choice(LibraryOwnerModel owner) =>
      SelectionChoice(id: owner.id, label: owner.name);
}

String _dateRangeLabel(DateTime start, DateTime end) =>
    '${_dateLabel(start)} – ${_dateLabel(end)}';

String _dateLabel(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';
