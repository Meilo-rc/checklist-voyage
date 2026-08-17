import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../domain/models/destination_summaries.dart';
import '../../domain/repositories/local_data_repository.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../import_data/import_view_model.dart';
import '../shared/destination_scaffold.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.watchOwners,
    required this.localData,
    required this.importViewModel,
  });

  final WatchLibraryOwners watchOwners;
  final LocalDataRepository localData;
  final ImportViewModel importViewModel;

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
    final error = widget.importViewModel.error;
    final report = widget.importViewModel.report;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (report?.alreadyImported == true
                  ? 'Cette sauvegarde avait déjà été importée.'
                  : 'Import local terminé.'),
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
          onPressed: widget.importViewModel.loading ? null : _pickBackup,
          tooltip: 'Importer une sauvegarde Web',
          icon: widget.importViewModel.loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.file_download_outlined),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InstallationCard(localData: widget.localData),
          const SizedBox(height: 12),
          if (widget.importViewModel.report case final report?) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.verified_outlined),
                title: Text(
                  report.alreadyImported
                      ? 'Import déjà appliqué'
                      : 'Dernier import terminé',
                ),
                subtitle: Text(
                  '${report.trips} voyage(s), ${report.quickLists} liste(s), '
                  '${report.libraryItems} item(s) de bibliothèque',
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          StreamBuilder<List<LibraryOwnerSummary>>(
            stream: widget.watchOwners(),
            builder: (context, snapshot) {
              final owners = snapshot.data ?? const [];
              if (owners.isEmpty) {
                return const EmptyDestination(
                  icon: Icons.menu_book_outlined,
                  title: 'Bibliothèque locale vide',
                  message:
                      'Utilisez l’action d’import pour charger une sauvegarde Web 2.63.',
                );
              }
              return Column(
                children: owners
                    .map(
                      (owner) => Card(
                        child: ListTile(
                          leading: Icon(
                            owner.personal
                                ? Icons.person_outline
                                : Icons.group_outlined,
                          ),
                          title: Text(owner.name),
                          subtitle: Text(
                            owner.personal
                                ? 'Personnel · local uniquement'
                                : 'Bibliothèque familiale',
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
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
