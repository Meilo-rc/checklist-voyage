import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SelectionChoice {
  const SelectionChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class SelectionChipGroup extends StatelessWidget {
  const SelectionChipGroup({
    super.key,
    required this.title,
    required this.choices,
    required this.selectedIds,
    required this.onChanged,
    this.emptyLabel = 'Aucun choix configuré',
    this.enabled = true,
  });

  final String title;
  final List<SelectionChoice> choices;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final String emptyLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        if (choices.isEmpty)
          Text(
            emptyLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: choices
                  .map((choice) {
                    final selected = selectedIds.contains(choice.id);
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: ChoiceChip(
                        key: Key('trip-choice-${choice.id}'),
                        label: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth - 48,
                          ),
                          child: Text(
                            choice.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        selected: selected,
                        showCheckmark: false,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(vertical: -1),
                        selectedColor: colors.primaryContainer,
                        backgroundColor: colors.surfaceContainerLowest,
                        side: BorderSide(
                          color: selected
                              ? colors.primary
                              : colors.outlineVariant,
                          width: selected ? 1.5 : 1,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        onSelected: enabled
                            ? (value) {
                                final next = Set<String>.of(selectedIds);
                                value
                                    ? next.add(choice.id)
                                    : next.remove(choice.id);
                                onChanged(next);
                              }
                            : null,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
      ],
    );
  }
}
