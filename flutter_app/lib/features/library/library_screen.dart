import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/repositories/local_data_repository.dart';
import '../../domain/usecases/context_use_cases.dart';
import '../../domain/usecases/library_use_cases.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../import_data/import_view_model.dart';
import '../shared/destination_scaffold.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.watchOwners,
    required this.localData,
    required this.importViewModel,
    required this.useCases,
    required this.contextUseCases,
  });

  final WatchLibraryOwners watchOwners;
  final LocalDataRepository localData;
  final ImportViewModel importViewModel;
  final LibraryUseCases useCases;
  final ContextUseCases contextUseCases;

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
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final draft = initial.toSet();
        return StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Contextes — ${item.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: contexts
                        .map(
                          (contextItem) => FilterChip(
                            key: Key('context-choice-${contextItem.id}'),
                            label: Text(contextItem.name),
                            selected: draft.contains(contextItem.id),
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            onSelected: (value) => setSheetState(() {
                              value
                                  ? draft.add(contextItem.id)
                                  : draft.remove(contextItem.id);
                            }),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 20),
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
              _InstallationCard(localData: widget.localData),
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
            (category) => _CategoryTile(category: category, screen: screen),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.screen});

  final LibraryCategoryModel category;
  final _LibraryScreenState screen;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(category.name),
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          if (action == 'item') {
            final draft = await screen._askItem();
            if (draft != null) {
              await screen.widget.useCases.createItem(
                categoryId: category.id,
                name: draft.name,
                defaultQuantity: draft.quantity,
              );
            }
          } else if (action == 'rename') {
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
          PopupMenuItem(value: 'item', child: Text('Ajouter un item')),
          PopupMenuItem(value: 'rename', child: Text('Renommer')),
          PopupMenuItem(value: 'delete', child: Text('Supprimer')),
        ],
      ),
      children: [
        ...category.items.map(
          (item) => ListTile(
            key: Key('library-item-${item.id}'),
            onLongPress: () => screen._manageContexts(item),
            title: Text(item.name),
            subtitle: Text('Quantité par défaut : ${item.defaultQuantity}'),
            trailing: Wrap(
              children: [
                IconButton(
                  tooltip: 'Modifier',
                  onPressed: () async {
                    final draft = await screen._askItem(item: item);
                    if (draft != null) {
                      await screen.widget.useCases.updateItem(
                        itemId: item.id,
                        name: draft.name,
                        defaultQuantity: draft.quantity,
                      );
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Supprimer',
                  onPressed: () => screen.widget.useCases.deleteItem(item.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ),
      ],
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
  const _InstallationCard({required this.localData});

  final LocalDataRepository localData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: localData.getInstallationId(),
      builder: (context, snapshot) {
        final id = snapshot.data;
        return Card(
          child: ListTile(
            leading: const Icon(Icons.offline_bolt_outlined),
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
