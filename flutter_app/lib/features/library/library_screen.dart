import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/presentation/user_message.dart';
import '../../core/theme/app_theme.dart';
import '../../data/backup/safety_backup_file_gateway.dart';
import '../../data/backup/v1_safety_backup_service.dart';
import '../../domain/models/checklist_models.dart';
import '../../domain/repositories/local_data_repository.dart';
import '../../domain/usecases/context_use_cases.dart';
import '../../domain/usecases/library_use_cases.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../import_data/import_view_model.dart';
import '../shared/destination_scaffold.dart';
import '../shared/item_contexts_sheet.dart';
import 'library_browser.dart';
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
    required this.safetyBackup,
    required this.safetyBackupFiles,
  });

  final WatchLibraryOwners watchOwners;
  final LocalDataRepository localData;
  final ImportViewModel importViewModel;
  final LibraryUseCases useCases;
  final ContextUseCases contextUseCases;
  final LibrarySyncCoordinator syncCoordinator;
  final V1SafetyBackupService safetyBackup;
  final SafetyBackupFileGateway safetyBackupFiles;

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

  Future<void> _exportSafetyBackup() async {
    try {
      final now = DateTime.now().toUtc();
      final timestamp = now
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final bytes = await widget.safetyBackup.exportBytes(now: now);
      final saved = await widget.safetyBackupFiles.save(
        name: 'checklist-voyage-v1-$timestamp.cv1backup.json',
        bytes: bytes,
      );
      if (mounted && saved) {
        _message('Sauvegarde de sécurité exportée.');
      }
    } on Object catch (error) {
      if (mounted) {
        _message(userMessageFor(error, fallback: 'Export impossible.'));
      }
    }
  }

  Future<void> _restoreSafetyBackup() async {
    const backupGroup = XTypeGroup(
      label: 'Sauvegarde Checklist Voyage V1',
      extensions: ['json'],
      mimeTypes: ['application/json'],
    );
    final file = await openFile(acceptedTypeGroups: const [backupGroup]);
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      final info = widget.safetyBackup.inspect(bytes);
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restaurer la sauvegarde V1 ?'),
          content: Text(
            'Cette action remplace toutes les données locales. Utilise-la '
            'uniquement sur une installation neuve et hors ligne.\n\n'
            '${info.count('library_items')} items · '
            '${info.count('trips')} voyages · '
            '${info.count('quick_lists')} listes rapides\n'
            'Installation : ${info.installationId}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restaurer'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await widget.safetyBackup.restoreBytes(bytes);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Restauration terminée'),
          content: const Text(
            'L’application va se fermer. Rouvre-la avant de réactiver le réseau.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
      await SystemNavigator.pop();
    } on Object catch (error) {
      if (mounted) {
        _message(userMessageFor(error, fallback: 'Restauration impossible.'));
      }
    }
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
                    labelText: 'Membre associé',
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
      _message(userMessageFor(error));
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

  Future<void> _manageContexts(
    BuildContext pageContext,
    LibraryItemModel item,
  ) async {
    final contexts = await widget.contextUseCases.loadContexts();
    if (!mounted) return;
    if (contexts.isEmpty) {
      _message('Créez d’abord un contexte dans la bibliothèque.');
      return;
    }
    final initial = await widget.contextUseCases.loadForItem(item.id);
    if (!mounted || !pageContext.mounted) return;
    final selected = await showItemContextsSheet(
      pageContext,
      itemName: item.name,
      contexts: contexts,
      initialSelection: initial,
    );
    if (selected != null) {
      await widget.contextUseCases.saveForItem(item.id, selected);
    }
  }

  Future<void> _handleSecondaryAction(String action) async {
    if (action == 'contexts') {
      await _openContextCatalog();
    } else if (action == 'import') {
      await _pickBackup();
    } else if (action == 'export') {
      await _exportSafetyBackup();
    } else if (action == 'restore') {
      await _restoreSafetyBackup();
    } else if (action == 'add-owner') {
      await _createOwner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DestinationScaffold(
      title: 'Bibliothèque',
      actions: [
        _SyncControl(syncCoordinator: widget.syncCoordinator),
        PopupMenuButton<String>(
          key: const Key('library-menu'),
          tooltip: 'Plus d’options',
          position: PopupMenuPosition.under,
          onSelected: _handleSecondaryAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              key: Key('library-contexts'),
              height: 44,
              value: 'contexts',
              child: _LibraryMenuItem(
                icon: Icons.interests_outlined,
                label: 'Gérer les contextes',
              ),
            ),
            PopupMenuItem(
              key: const Key('library-import'),
              height: 44,
              value: 'import',
              enabled: !widget.importViewModel.loading,
              child: const _LibraryMenuItem(
                icon: Icons.file_download_outlined,
                label: 'Importer une sauvegarde Web',
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              key: Key('library-export-safety'),
              height: 44,
              value: 'export',
              child: _LibraryMenuItem(
                icon: Icons.upload_file_outlined,
                label: 'Exporter sécurité V1',
              ),
            ),
            PopupMenuItem(
              key: Key('library-restore-safety'),
              height: 44,
              value: 'restore',
              child: _LibraryMenuItem(
                icon: Icons.restore_outlined,
                label: 'Restaurer sécurité V1',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              key: Key('library-add-owner'),
              height: 44,
              value: 'add-owner',
              child: _LibraryMenuItem(
                icon: Icons.add,
                label: 'Ajouter un groupe',
              ),
            ),
          ],
        ),
      ],
      child: LibraryBrowser(
        useCases: widget.useCases,
        onManageContexts: _manageContexts,
        onLinkPersonalOwner: _linkPersonalOwner,
        onMessage: _message,
      ),
    );
  }
}

class _LibraryMenuItem extends StatelessWidget {
  const _LibraryMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.md),
        Flexible(child: Text(label)),
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

class _LinkChoice {
  const _LinkChoice(this.participantOwnerId);

  final String? participantOwnerId;
}
