import 'package:flutter/material.dart';

import '../../domain/models/destination_summaries.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../shared/destination_scaffold.dart';

class QuickListsScreen extends StatelessWidget {
  const QuickListsScreen({super.key, required this.watchQuickLists});

  final WatchQuickLists watchQuickLists;

  @override
  Widget build(BuildContext context) {
    return DestinationScaffold(
      title: 'Listes rapides',
      child: StreamBuilder<List<QuickListSummary>>(
        stream: watchQuickLists(),
        builder: (context, snapshot) {
          final lists = snapshot.data ?? const [];
          if (lists.isEmpty) {
            return const EmptyDestination(
              icon: Icons.checklist_outlined,
              title: 'Aucune liste rapide',
              message:
                  'Les listes importées seront conservées dans la base locale.',
            );
          }
          return Column(
            children: lists
                .map(
                  (list) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.checklist_outlined),
                      title: Text(list.name),
                      subtitle: Text(list.shared ? 'Partagée' : 'Locale'),
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
