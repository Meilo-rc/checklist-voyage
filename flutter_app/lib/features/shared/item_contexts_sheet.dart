import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/checklist_models.dart';

Future<Set<String>?> showItemContextsSheet(
  BuildContext context, {
  required String itemName,
  required List<ContextModel> contexts,
  required Set<String> initialSelection,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final draft = initialSelection.toSet();
      return StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Contextes — $itemName',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: contexts
                      .map(
                        (activity) => FilterChip(
                          key: Key('context-choice-${activity.id}'),
                          label: Text(activity.name),
                          selected: draft.contains(activity.id),
                          showCheckmark: false,
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          onSelected: (value) => setSheetState(() {
                            value
                                ? draft.add(activity.id)
                                : draft.remove(activity.id);
                          }),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  key: const Key('context-save-item'),
                  onPressed: () => Navigator.pop(context, draft),
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
