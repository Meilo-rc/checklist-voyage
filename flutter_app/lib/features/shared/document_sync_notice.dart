import 'package:flutter/material.dart';

/// Aucun détail serveur (ni capacité de partage) n'est affiché à l'écran.
class DocumentSyncNotice extends StatelessWidget {
  const DocumentSyncNotice({
    super.key,
    required this.errors,
    required this.onRetry,
  });

  final Stream<String?> errors;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => StreamBuilder<String?>(
    stream: errors,
    builder: (context, snapshot) {
      if (snapshot.data == null) return const SizedBox.shrink();
      final colors = Theme.of(context).colorScheme;
      return Material(
        color: colors.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                color: colors.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Partage en attente. Modifications conservées sur ce téléphone. '
                  'Nouvelle tentative automatique.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    },
  );
}
