import 'package:flutter/material.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/models/progress.dart';
import '../../domain/usecases/quick_list_use_cases.dart';
import '../../domain/usecases/shared_document_use_cases.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../shared/destination_scaffold.dart';

class QuickListsScreen extends StatefulWidget {
  const QuickListsScreen({
    super.key,
    required this.watchQuickLists,
    required this.useCases,
    this.sharedDocuments,
  });

  final WatchQuickLists watchQuickLists;
  final QuickListUseCases useCases;
  final SharedDocumentUseCases? sharedDocuments;

  @override
  State<QuickListsScreen> createState() => _QuickListsScreenState();
}

class _QuickListsScreenState extends State<QuickListsScreen> {
  String? _selectedListId;

  Future<void> _join() async {
    final sharing = widget.sharedDocuments;
    if (sharing == null) return;
    final code = await _askQuickCode(context);
    if (code == null) return;
    try {
      final access = await sharing.join(code);
      if (access.documentType != SharedDocumentType.quickList) {
        throw StateError('Ce code correspond à un voyage.');
      }
      if (mounted) setState(() => _selectedListId = access.documentId);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<String?> _askName(String title, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          key: const Key('quick-name-input'),
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom'),
          onSubmitted: (_) => Navigator.pop(context, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('quick-name-submit'),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _create() async {
    final name = await _askName('Nouvelle liste rapide');
    if (name == null) return;
    try {
      final id = await widget.useCases.create(name);
      if (mounted) setState(() => _selectedListId = id);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedListId;
    if (selected != null) {
      return _QuickListDetail(
        listId: selected,
        useCases: widget.useCases,
        onBack: () => setState(() => _selectedListId = null),
        askName: _askName,
        sharedDocuments: widget.sharedDocuments,
      );
    }
    return DestinationScaffold(
      title: 'Listes rapides',
      actions: [
        if (widget.sharedDocuments != null)
          IconButton(
            key: const Key('quick-join'),
            onPressed: _join,
            tooltip: 'Rejoindre avec un code',
            icon: const Icon(Icons.group_add_outlined),
          ),
        IconButton(
          key: const Key('quick-create'),
          onPressed: _create,
          tooltip: 'Créer une liste rapide',
          icon: const Icon(Icons.add),
        ),
      ],
      child: StreamBuilder<List<QuickListSummary>>(
        stream: widget.watchQuickLists(),
        builder: (context, snapshot) {
          final lists = snapshot.data ?? const [];
          if (lists.isEmpty) {
            return const EmptyDestination(
              icon: Icons.checklist_outlined,
              title: 'Aucune liste rapide',
              message: 'Créez une liste utilisable entièrement hors ligne.',
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
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => setState(() => _selectedListId = list.id),
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

class _QuickListDetail extends StatelessWidget {
  const _QuickListDetail({
    required this.listId,
    required this.useCases,
    required this.onBack,
    required this.askName,
    required this.sharedDocuments,
  });

  final String listId;
  final QuickListUseCases useCases;
  final VoidCallback onBack;
  final Future<String?> Function(String, {String initial}) askName;
  final SharedDocumentUseCases? sharedDocuments;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuickListDetailModel?>(
      stream: useCases.watchQuickList(listId),
      builder: (context, snapshot) {
        final list = snapshot.data;
        if (list == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final progress = ProgressCalculator.forQuickList(list);
        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              leading: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(list.name),
              actions: [
                if (list.shared)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Center(child: Chip(label: Text('Partagé'))),
                  ),
                if (sharedDocuments != null)
                  IconButton(
                    key: Key(
                      list.v1ShareReady ? 'quick-show-code' : 'quick-share',
                    ),
                    tooltip: list.v1ShareReady
                        ? 'Afficher le code'
                        : 'Partager',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () async {
                      try {
                        final code = list.v1ShareReady
                            ? list.shareCode
                            : (await sharedDocuments!.shareQuickList(
                                list.id,
                              )).shareCode;
                        if (context.mounted && code != null) {
                          await _showQuickCode(context, code);
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
                  onSelected: (action) async {
                    if (action == 'rename') {
                      final name = await askName(
                        'Renommer la liste',
                        initial: list.name,
                      );
                      if (name != null) await useCases.rename(list.id, name);
                    } else if (action == 'reset') {
                      await useCases.reset(list.id);
                    } else if (action == 'delete') {
                      await useCases.delete(list.id);
                      onBack();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'rename', child: Text('Renommer')),
                    PopupMenuItem(value: 'reset', child: Text('Tout décocher')),
                    PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                  ],
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(
                children: [
                  LinearProgressIndicator(value: progress.percent / 100),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.completed}/${progress.total} cochés · ${progress.percent}%',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const Key('quick-add-item'),
                    onPressed: () async {
                      final name = await askName('Nouvel item');
                      if (name != null) await useCases.addItem(list.id, name);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un item'),
                  ),
                  const SizedBox(height: 8),
                  ...list.items.map(
                    (item) => Card(
                      child: Padding(
                        key: Key('quick-item-${item.id}'),
                        padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: item.isChecked,
                                  onChanged: (_) =>
                                      useCases.toggleItem(item.id),
                                ),
                                Expanded(child: Text(item.name)),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  onPressed: () => useCases.deleteItem(item.id),
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
                                      useCases.changeQuantity(item.id, -1),
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
                                      useCases.changeQuantity(item.id, 1),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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

Future<String?> _askQuickCode(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rejoindre avec un code'),
      content: TextField(
        key: const Key('quick-share-code-input'),
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
          key: const Key('quick-share-code-submit'),
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Rejoindre'),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

Future<void> _showQuickCode(BuildContext context, String code) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager'),
        content: SelectableText(
          code,
          key: const Key('quick-shared-code'),
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
