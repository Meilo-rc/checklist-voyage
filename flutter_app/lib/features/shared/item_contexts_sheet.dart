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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.72,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Contextes — $itemName',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Flexible(
                    child: SingleChildScrollView(
                      key: const Key('item-contexts-scroll'),
                      child: Wrap(
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
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          key: const Key('context-cancel-item'),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          key: const Key('context-save-item'),
                          onPressed: () => Navigator.pop(context, draft),
                          child: const Text('Enregistrer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
