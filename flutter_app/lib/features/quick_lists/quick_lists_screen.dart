import 'package:flutter/material.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/models/progress.dart';
import '../../domain/usecases/quick_list_use_cases.dart';
import '../../domain/usecases/shared_document_use_cases.dart';
import '../../domain/usecases/watch_destinations.dart';

part 'quick_list_widgets.dart';

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
  bool _showArchives = false;

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

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
      if (mounted) _message(error.toString());
    }
  }

  Future<String?> _askName(String title, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          key: const Key('quick-rename-input'),
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
            key: const Key('quick-rename-submit'),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Valider'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _create(String name) async {
    final id = await widget.useCases.create(name);
    if (mounted) setState(() => _selectedListId = id);
  }

  Future<void> _duplicate(String sourceId) async {
    try {
      final id = await widget.useCases.duplicate(sourceId);
      if (mounted) {
        setState(() {
          _showArchives = false;
          _selectedListId = id;
        });
      }
    } on Object catch (error) {
      if (mounted) _message(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedListId;
    if (selected != null) {
      return _QuickListDetail(
        key: ValueKey('quick-detail-$selected'),
        listId: selected,
        useCases: widget.useCases,
        onBack: () => setState(() => _selectedListId = null),
        onDuplicate: _duplicate,
        askName: _askName,
        sharedDocuments: widget.sharedDocuments,
      );
    }
    return StreamBuilder<List<QuickListSummary>>(
      stream: widget.watchQuickLists(),
      builder: (context, snapshot) {
        final lists = snapshot.data ?? const <QuickListSummary>[];
        final visible = lists
            .where((list) => (list.archivedAt != null) == _showArchives)
            .toList(growable: false);
        return CustomScrollView(
          key: const Key('quick-lists-root'),
          slivers: [
            SliverAppBar(
              pinned: true,
              title: const Text('Listes rapides'),
              actions: [
                if (widget.sharedDocuments != null)
                  IconButton(
                    key: const Key('quick-join'),
                    onPressed: _join,
                    tooltip: 'Rejoindre avec un code',
                    icon: const Icon(Icons.group_add_outlined),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                child: SegmentedButton<bool>(
                  key: const Key('quick-archive-tabs'),
                  segments: const [
                    ButtonSegment(value: false, label: Text('Mes listes')),
                    ButtonSegment(value: true, label: Text('Archives')),
                  ],
                  selected: {_showArchives},
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  onSelectionChanged: (selection) =>
                      setState(() => _showArchives = selection.single),
                ),
              ),
            ),
            if (visible.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    _showArchives
                        ? 'Aucune liste archivée'
                        : 'Aucune liste rapide',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final list = visible[index];
                    return _QuickListSummaryRow(
                      key: Key('quick-summary-${list.id}'),
                      summary: list,
                      useCases: widget.useCases,
                      onTap: () => setState(() => _selectedListId = list.id),
                    );
                  },
                ),
              ),
            if (!_showArchives)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                  child: _InlineQuickAdder(
                    key: const Key('quick-create'),
                    label: 'Nouvelle liste',
                    fieldKey: const Key('quick-name-input'),
                    submitKey: const Key('quick-name-submit'),
                    onSubmit: _create,
                    onError: _message,
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        );
      },
    );
  }
}

class _QuickListDetail extends StatefulWidget {
  const _QuickListDetail({
    super.key,
    required this.listId,
    required this.useCases,
    required this.onBack,
    required this.onDuplicate,
    required this.askName,
    required this.sharedDocuments,
  });

  final String listId;
  final QuickListUseCases useCases;
  final VoidCallback onBack;
  final Future<void> Function(String) onDuplicate;
  final Future<String?> Function(String, {String initial}) askName;
  final SharedDocumentUseCases? sharedDocuments;

  @override
  State<_QuickListDetail> createState() => _QuickListDetailState();
}

class _QuickListDetailState extends State<_QuickListDetail> {
  String? _editingItemId;

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _share(QuickListDetailModel list) async {
    final sharing = widget.sharedDocuments;
    if (sharing == null) return;
    try {
      final code = list.v1ShareReady
          ? list.shareCode
          : (await sharing.shareQuickList(list.id)).shareCode;
      if (mounted && code != null) await _showQuickCode(context, code);
    } on Object catch (error) {
      if (mounted) _message(error.toString());
    }
  }

  Future<void> _handleAction(String action, QuickListDetailModel list) async {
    if (action == 'rename') {
      final name = await widget.askName(
        'Renommer la liste',
        initial: list.name,
      );
      if (name != null) await widget.useCases.rename(list.id, name);
    } else if (action == 'duplicate') {
      await widget.onDuplicate(list.id);
    } else if (action == 'archive') {
      await widget.useCases.archive(list.id);
    } else if (action == 'restore') {
      await widget.useCases.restore(list.id);
    } else if (action == 'delete') {
      await widget.useCases.delete(list.id);
      widget.onBack();
    }
  }

  Future<bool> _handleSwipe(
    QuickListItemModel item,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      setState(() => _editingItemId = item.id);
      return false;
    }
    try {
      await widget.useCases.deleteItem(item.id);
      return true;
    } on Object catch (error) {
      _message(error.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuickListDetailModel?>(
      stream: widget.useCases.watchQuickList(widget.listId),
      builder: (context, snapshot) {
        final list = snapshot.data;
        if (list == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final progress = ProgressCalculator.forQuickList(list);
        return CustomScrollView(
          key: Key('quick-detail-${list.id}'),
          slivers: [
            SliverAppBar(
              pinned: true,
              leading: IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                list.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (widget.sharedDocuments != null)
                  IconButton(
                    key: Key(
                      list.v1ShareReady ? 'quick-show-code' : 'quick-share',
                    ),
                    tooltip: list.v1ShareReady
                        ? 'Afficher le code'
                        : 'Partager',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => _share(list),
                  ),
                PopupMenuButton<String>(
                  key: const Key('quick-actions'),
                  position: PopupMenuPosition.under,
                  onSelected: (action) => _handleAction(action, list),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      height: 44,
                      value: 'rename',
                      child: Text('Renommer'),
                    ),
                    const PopupMenuItem(
                      height: 44,
                      value: 'duplicate',
                      child: Text('Dupliquer'),
                    ),
                    if (list.archivedAt == null)
                      const PopupMenuItem(
                        height: 44,
                        value: 'archive',
                        child: Text('Archiver'),
                      )
                    else
                      const PopupMenuItem(
                        height: 44,
                        value: 'restore',
                        child: Text('Restaurer'),
                      ),
                    const PopupMenuItem(
                      height: 44,
                      value: 'delete',
                      child: Text('Supprimer'),
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _QuickProgressHeader(
                shared: list.shared,
                progress: progress,
                onReset: progress.completed == 0
                    ? null
                    : () => widget.useCases.reset(list.id),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
              sliver: SliverList.builder(
                itemCount: list.items.length + 1,
                itemBuilder: (context, index) {
                  if (index == list.items.length) {
                    return _InlineQuickAdder(
                      key: const Key('quick-add-item'),
                      label: 'Ajouter un item',
                      fieldKey: const Key('quick-add-item-input'),
                      submitKey: const Key('quick-add-item-submit'),
                      onSubmit: (name) async {
                        await widget.useCases.addItem(list.id, name);
                      },
                      onError: _message,
                    );
                  }
                  final item = list.items[index];
                  if (_editingItemId == item.id) {
                    return _InlineQuickRename(
                      initialValue: item.name,
                      onCancel: () => setState(() => _editingItemId = null),
                      onSubmit: (name) async {
                        await widget.useCases.updateItem(
                          item.id,
                          name,
                          item.quantity,
                        );
                        if (mounted) setState(() => _editingItemId = null);
                      },
                      onError: _message,
                    );
                  }
                  return Dismissible(
                    key: Key('quick-item-dismiss-${item.id}'),
                    confirmDismiss: (direction) =>
                        _handleSwipe(item, direction),
                    background: const _QuickSwipeAction(
                      alignment: Alignment.centerLeft,
                      icon: Icons.edit_outlined,
                      label: 'Modifier',
                    ),
                    secondaryBackground: const _QuickSwipeAction(
                      alignment: Alignment.centerRight,
                      icon: Icons.delete_outline,
                      label: 'Supprimer',
                      destructive: true,
                    ),
                    child: _QuickItemRow(
                      key: Key('quick-item-${item.id}'),
                      item: item,
                      onToggle: () => widget.useCases.toggleItem(item.id),
                      onQuantityChanged: (delta) =>
                          widget.useCases.changeQuantity(item.id, delta),
                    ),
                  );
                },
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
