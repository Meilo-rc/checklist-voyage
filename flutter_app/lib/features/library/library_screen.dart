import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/checklist_models.dart';
import '../../domain/repositories/local_data_repository.dart';
import '../../domain/usecases/context_use_cases.dart';
import '../../domain/usecases/library_use_cases.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../import_data/import_view_model.dart';
import '../shared/destination_scaffold.dart';
import '../shared/item_contexts_sheet.dart';
import '../../sync/library_sync_coordinator.dart';
import '../../sync/sync_models.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.watchOwners,
    required this.localData,
    required this.importViewModel,
    required this.useCases,
    required this.contextUseCases,
    required this.syncCoordinator,
  });

  final WatchLibraryOwners watchOwners;
  final LocalDataRepository localData;
  final ImportViewModel importViewModel;
  final LibraryUseCases useCases;
  final ContextUseCases contextUseCases;
  final LibrarySyncCoordinator syncCoordinator;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    widget.importViewModel.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant LibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.importViewModel != widget.importViewModel) {
      oldWidget.importViewModel.removeListener(_refresh);
      widget.importViewModel.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.importViewModel.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _pickBackup() async {
    const jsonGroup = XTypeGroup(
      label: 'Sauvegarde JSON',
      extensions: ['json'],
    );
    final file = await openFile(acceptedTypeGroups: const [jsonGroup]);
    if (file == null) return;
    await widget.importViewModel.import(await file.readAsBytes());
    if (!mounted) return;
    _message(
      widget.importViewModel.error ??
          (widget.importViewModel.report?.alreadyImported == true
              ? 'Cette sauvegarde avait déjà été importée.'
              : 'Import local terminé.'),
    );
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _createOwner() async {
    final library = await widget.useCases.loadLibrary();
    if (!mounted) return;
    final members = library
        .where((owner) => owner.kind == LibraryOwnerKind.familyMember)
        .toList(growable: false);
    final nameController = TextEditingController();
    var kind = LibraryOwnerKind.familyMember;
    var role = GenerationRole.participant;
    String? linkedParticipantOwnerId;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau groupe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LibraryOwnerKind>(
                initialValue: kind,
                decoration: const InputDecoration(labelText: 'Section'),
                items: const [
                  DropdownMenuItem(
                    value: LibraryOwnerKind.general,
                    child: Text('Général'),
                  ),
                  DropdownMenuItem(
                    value: LibraryOwnerKind.familyMember,
                    child: Text('Membre'),
                  ),
                  DropdownMenuItem(
                    value: LibraryOwnerKind.personal,
                    child: Text('Personnel'),
                  ),
                ],
                onChanged: (value) => setDialogState(() {
                  kind = value ?? kind;
                  role = kind == LibraryOwnerKind.general
                      ? GenerationRole.general
                      : GenerationRole.participant;
                  if (kind != LibraryOwnerKind.personal) {
                    linkedParticipantOwnerId = null;
                  }
                }),
              ),
              if (kind == LibraryOwnerKind.general) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<GenerationRole>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Usage voyage'),
                  items: const [
                    DropdownMenuItem(
                      value: GenerationRole.general,
                      child: Text('Général'),
                    ),
                    DropdownMenuItem(
                      value: GenerationRole.essential,
                      child: Text('Essentiels'),
                    ),
                    DropdownMenuItem(
                      value: GenerationRole.transport,
                      child: Text('Transport'),
                    ),
                    DropdownMenuItem(
                      value: GenerationRole.lodging,
                      child: Text('Logement'),
                    ),
                  ],
                  onChanged: (value) => setDialogState(() {
                    role = value ?? role;
                  }),
                ),
              ],
              if (kind == LibraryOwnerKind.personal) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  key: const ValueKey('personal-linked-participant'),
                  initialValue: linkedParticipantOwnerId,
                  decoration: const InputDecoration(
                    labelText: 'Participant associé',
                    helperText: 'Nécessaire pour inclure Personnel au voyage',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Aucun'),
                    ),
                    ...members.map(
                      (member) => DropdownMenuItem<String?>(
                        value: member.id,
                        child: Text(member.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setDialogState(() {
                    linkedParticipantOwnerId = value;
                  }),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true) return;
    try {
      await widget.useCases.createOwner(
        name: nameController.text,
        kind: kind,
        generationRole: role,
        linkedParticipantOwnerId: linkedParticipantOwnerId,
      );
    } on Object catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _openContextCatalog() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _ContextCatalogSheet(useCases: widget.contextUseCases),
    );
  }

  Future<void> _linkPersonalOwner(LibraryOwnerModel owner) async {
    final library = await widget.useCases.loadLibrary();
    if (!mounted) return;
    final members = library
        .where((candidate) => candidate.kind == LibraryOwnerKind.familyMember)
        .toList(growable: false);
    final choice = await showDialog<_LinkChoice>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Participant associé'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, const _LinkChoice(null)),
            child: const Text('Aucun'),
          ),
          ...members.map(
            (member) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, _LinkChoice(member.id)),
              child: Text(member.name),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
    if (choice != null) {
      await widget.useCases.setLinkedParticipantOwner(
        owner.id,
        choice.participantOwnerId,
      );
    }
  }

  Future<void> _manageContexts(LibraryItemModel item) async {
    final contexts = await widget.contextUseCases.loadContexts();
    if (!mounted) return;
    if (contexts.isEmpty) {
      _message('Créez d’abord un contexte dans la bibliothèque.');
      return;
    }
    final initial = await widget.contextUseCases.loadForItem(item.id);
    if (!mounted) return;
    final selected = await showItemContextsSheet(
      context,
      itemName: item.name,
      contexts: contexts,
      initialSelection: initial,
    );
    if (selected != null) {
      await widget.contextUseCases.saveForItem(item.id, selected);
    }
  }

  Future<String?> _askName(String title, {String initialValue = ''}) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
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
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<_ItemDraft?> _askItem({LibraryItemModel? item}) async {
    final controller = TextEditingController(text: item?.name ?? '');
    var quantity = item?.defaultQuantity ?? 1;
    return showDialog<_ItemDraft>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Nouvel item' : 'Modifier l’item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setDialogState(() {
                      quantity = (quantity - 1).clamp(1, 99);
                    }),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$quantity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => setDialogState(() {
                      quantity = (quantity + 1).clamp(1, 99);
                    }),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _ItemDraft(controller.text, quantity)),
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DestinationScaffold(
      title: 'Bibliothèque',
      actions: [
        IconButton(
          key: const Key('library-contexts'),
          onPressed: _openContextCatalog,
          tooltip: 'Gérer les contextes',
          icon: const Icon(Icons.interests_outlined),
        ),
        IconButton(
          key: const Key('library-import'),
          onPressed: widget.importViewModel.loading ? null : _pickBackup,
          tooltip: 'Importer une sauvegarde Web',
          icon: widget.importViewModel.loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.file_download_outlined),
        ),
        IconButton(
          key: const Key('library-add-owner'),
          onPressed: _createOwner,
          tooltip: 'Ajouter un groupe',
          icon: const Icon(Icons.add),
        ),
      ],
      child: StreamBuilder<List<LibraryOwnerModel>>(
        stream: widget.useCases.watchLibrary(),
        builder: (context, snapshot) {
          final owners = snapshot.data ?? const [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InstallationCard(
                localData: widget.localData,
                syncCoordinator: widget.syncCoordinator,
              ),
              const SizedBox(height: 12),
              if (owners.isEmpty)
                const EmptyDestination(
                  icon: Icons.menu_book_outlined,
                  title: 'Bibliothèque locale vide',
                  message:
                      'Ajoutez un groupe ou importez une sauvegarde Web 2.63.',
                )
              else ...[
                _OwnerSection(
                  title: 'Général',
                  owners: owners
                      .where((owner) => owner.kind == LibraryOwnerKind.general)
                      .toList(),
                  screen: this,
                ),
                _OwnerSection(
                  title: 'Membres',
                  owners: owners
                      .where(
                        (owner) => owner.kind == LibraryOwnerKind.familyMember,
                      )
                      .toList(),
                  screen: this,
                ),
                _OwnerSection(
                  title: 'Personnel',
                  owners: owners
                      .where((owner) => owner.kind == LibraryOwnerKind.personal)
                      .toList(),
                  screen: this,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OwnerSection extends StatelessWidget {
  const _OwnerSection({
    required this.title,
    required this.owners,
    required this.screen,
  });

  final String title;
  final List<LibraryOwnerModel> owners;
  final _LibraryScreenState screen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (owners.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Aucun groupe'),
          )
        else
          ...owners.map((owner) => _OwnerCard(owner: owner, screen: screen)),
      ],
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.owner, required this.screen});

  final LibraryOwnerModel owner;
  final _LibraryScreenState screen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(
          owner.isPersonal ? Icons.person_outline : Icons.group_outlined,
        ),
        title: Text(owner.name),
        subtitle: Text(_roleLabel(owner)),
        trailing: PopupMenuButton<String>(
          onSelected: (action) async {
            if (action == 'category') {
              final name = await screen._askName('Nouvelle catégorie');
              if (name != null) {
                await screen.widget.useCases.createCategory(owner.id, name);
              }
            } else if (action == 'rename') {
              final name = await screen._askName(
                'Renommer le groupe',
                initialValue: owner.name,
              );
              if (name != null) {
                await screen.widget.useCases.renameOwner(owner.id, name);
              }
            } else if (action == 'delete') {
              await screen.widget.useCases.deleteOwner(owner.id);
            } else if (action == 'link') {
              await screen._linkPersonalOwner(owner);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'category',
              child: Text('Ajouter une catégorie'),
            ),
            const PopupMenuItem(value: 'rename', child: Text('Renommer')),
            if (owner.isPersonal)
              const PopupMenuItem(
                value: 'link',
                child: Text('Associer à un membre'),
              ),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
        children: [
          if (owner.categories.isEmpty)
            const ListTile(title: Text('Aucune catégorie')),
          ...owner.categories.map(
            (category) => _CategoryTile(
              key: ValueKey('library-category-${category.id}'),
              category: category,
              screen: screen,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  const _CategoryTile({
    super.key,
    required this.category,
    required this.screen,
  });

  final LibraryCategoryModel category;
  final _LibraryScreenState screen;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  final _itemController = TextEditingController();
  final _itemFocus = FocusNode();
  bool _adding = false;

  LibraryCategoryModel get category => widget.category;
  _LibraryScreenState get screen => widget.screen;

  @override
  void dispose() {
    _itemController.dispose();
    _itemFocus.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final name = _itemController.text.trim();
    if (name.isEmpty || _adding) return;
    setState(() => _adding = true);
    try {
      await screen.widget.useCases.createItem(
        categoryId: category.id,
        name: name,
        defaultQuantity: 1,
      );
      _itemController.clear();
      _itemFocus.requestFocus();
    } on Object catch (error) {
      screen._message(error.toString());
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _editItem(LibraryItemModel item) async {
    final draft = await screen._askItem(item: item);
    if (draft == null) return;
    await screen.widget.useCases.updateItem(
      itemId: item.id,
      name: draft.name,
      defaultQuantity: draft.quantity,
    );
  }

  Future<bool> _handleSwipe(
    LibraryItemModel item,
    DismissDirection direction,
  ) async {
    try {
      if (direction == DismissDirection.startToEnd) {
        await _editItem(item);
        return false;
      }
      await screen.widget.useCases.deleteItem(item.id);
      return true;
    } on Object catch (error) {
      screen._message(error.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(category.name),
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          if (action == 'rename') {
            final name = await screen._askName(
              'Renommer la catégorie',
              initialValue: category.name,
            );
            if (name != null) {
              await screen.widget.useCases.renameCategory(category.id, name);
            }
          } else if (action == 'delete') {
            await screen.widget.useCases.deleteCategory(category.id);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(height: 44, value: 'rename', child: Text('Renommer')),
          PopupMenuItem(height: 44, value: 'delete', child: Text('Supprimer')),
        ],
      ),
      children: [
        ...category.items.map(
          (item) => Dismissible(
            key: ValueKey('library-item-dismiss-${item.id}'),
            confirmDismiss: (direction) => _handleSwipe(item, direction),
            background: const _SwipeAction(
              alignment: Alignment.centerLeft,
              icon: Icons.edit_outlined,
              label: 'Modifier',
            ),
            secondaryBackground: _SwipeAction(
              alignment: Alignment.centerRight,
              icon: Icons.delete_outline,
              label: 'Supprimer',
              destructive: true,
            ),
            child: ListTile(
              key: Key('library-item-${item.id}'),
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              onLongPress: () => screen._manageContexts(item),
              title: Text(item.name),
              trailing: item.defaultQuantity == 1
                  ? null
                  : Text('×${item.defaultQuantity}'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: Key('library-add-item-${category.id}'),
                  controller: _itemController,
                  focusNode: _itemFocus,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addItem(),
                  decoration: const InputDecoration(
                    hintText: 'Ajouter un item…',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton.filledTonal(
                key: Key('library-add-item-submit-${category.id}'),
                tooltip: 'Ajouter',
                onPressed: _adding ? null : _addItem,
                icon: _adding
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.alignment,
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = destructive
        ? colors.onErrorContainer
        : colors.onPrimaryContainer;
    return Container(
      alignment: alignment,
      color: destructive ? colors.errorContainer : colors.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ContextCatalogSheet extends StatelessWidget {
  const _ContextCatalogSheet({required this.useCases});

  final ContextUseCases useCases;

  Future<String?> _askName(
    BuildContext context,
    String title, {
    String initial = '',
  }) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          key: const Key('context-name-input'),
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
            key: const Key('context-name-submit'),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Contextes / activités',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    key: const Key('context-create'),
                    tooltip: 'Créer',
                    onPressed: () async {
                      final name = await _askName(context, 'Nouveau contexte');
                      if (name != null) await useCases.create(name);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<ContextModel>>(
                  stream: useCases.watchContexts(),
                  builder: (context, snapshot) {
                    final contexts = snapshot.data ?? const [];
                    if (contexts.isEmpty) {
                      return const Center(
                        child: Text('Aucun contexte pour le moment.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: contexts.length,
                      itemBuilder: (context, index) {
                        final activity = contexts[index];
                        return ListTile(
                          key: Key('context-row-${activity.id}'),
                          leading: const Icon(Icons.interests_outlined),
                          title: Text(activity.name),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                tooltip: 'Renommer',
                                onPressed: () async {
                                  final name = await _askName(
                                    context,
                                    'Renommer le contexte',
                                    initial: activity.name,
                                  );
                                  if (name != null) {
                                    await useCases.rename(activity.id, name);
                                  }
                                },
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Supprimer',
                                onPressed: () => useCases.delete(activity.id),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstallationCard extends StatelessWidget {
  const _InstallationCard({
    required this.localData,
    required this.syncCoordinator,
  });

  final LocalDataRepository localData;
  final LibrarySyncCoordinator syncCoordinator;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: localData.getInstallationId(),
      builder: (context, snapshot) {
        final id = snapshot.data;
        return Card(
          child: ListTile(
            leading: const Icon(Icons.offline_bolt_outlined),
            trailing: _SyncControl(syncCoordinator: syncCoordinator),
            title: const Text('Mode local-first actif'),
            subtitle: Text(
              id == null
                  ? 'Initialisation de l’installation…'
                  : 'Installation ${id.substring(0, 8)}…',
            ),
          ),
        );
      },
    );
  }
}

class _SyncControl extends StatelessWidget {
  const _SyncControl({required this.syncCoordinator});

  final LibrarySyncCoordinator syncCoordinator;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatusModel>(
      stream: syncCoordinator.watchStatus(),
      builder: (context, snapshot) {
        final status = snapshot.data;
        final syncing = status?.state == SyncConnectionState.syncing;
        final tooltip = switch (status?.state) {
          SyncConnectionState.synced => 'Bibliothèque synchronisée',
          SyncConnectionState.syncing => 'Synchronisation en cours',
          SyncConnectionState.pending =>
            '${status?.pendingOperations ?? 0} modification(s) en attente',
          SyncConnectionState.offline => 'Hors ligne',
          SyncConnectionState.error => 'Erreur de synchronisation',
          _ => 'Synchroniser',
        };
        return IconButton(
          key: const Key('library-sync-now'),
          tooltip: tooltip,
          onPressed: syncing ? null : syncCoordinator.syncNow,
          icon: syncing
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  status?.state == SyncConnectionState.synced
                      ? Icons.cloud_done_outlined
                      : status?.state == SyncConnectionState.error
                      ? Icons.cloud_off_outlined
                      : Icons.sync,
                ),
        );
      },
    );
  }
}

class _ItemDraft {
  const _ItemDraft(this.name, this.quantity);
  final String name;
  final int quantity;
}

class _LinkChoice {
  const _LinkChoice(this.participantOwnerId);

  final String? participantOwnerId;
}

String _roleLabel(LibraryOwnerModel owner) {
  if (owner.isPersonal) return 'Local uniquement';
  return switch (owner.generationRole) {
    GenerationRole.essential => 'Essentiels',
    GenerationRole.transport => 'Transport',
    GenerationRole.lodging => 'Logement',
    GenerationRole.participant => 'Participant',
    _ => 'Bibliothèque générale',
  };
}
