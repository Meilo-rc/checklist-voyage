import 'package:flutter/material.dart';

import '../../core/presentation/user_message.dart';
import '../../core/sharing/share_invitation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/version/app_version.dart';
import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/models/progress.dart';
import '../../domain/usecases/quick_list_use_cases.dart';
import '../../domain/usecases/shared_document_use_cases.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../shared/category_details_page.dart';
import '../shared/join_code_dialog.dart';

part 'quick_list_widgets.dart';

class QuickListsScreen extends StatefulWidget {
  const QuickListsScreen({
    super.key,
    required this.watchQuickLists,
    required this.useCases,
    required this.shareInvitations,
    required this.pendingJoinRequest,
    required this.onJoinRequestHandled,
    this.sharedDocuments,
  });

  final WatchQuickLists watchQuickLists;
  final QuickListUseCases useCases;
  final SharedDocumentUseCases? sharedDocuments;
  final ShareInvitationGateway shareInvitations;
  final ShareJoinRequest? pendingJoinRequest;
  final ValueChanged<ShareJoinRequest> onJoinRequestHandled;

  @override
  State<QuickListsScreen> createState() => _QuickListsScreenState();
}

class _QuickListsScreenState extends State<QuickListsScreen> {
  String? _selectedListId;
  bool _showArchives = false;
  bool _handlingJoinRequest = false;

  @override
  void initState() {
    super.initState();
    _schedulePendingJoinRequest();
  }

  @override
  void didUpdateWidget(covariant QuickListsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pendingJoinRequest, widget.pendingJoinRequest)) {
      _schedulePendingJoinRequest();
    }
  }

  void _schedulePendingJoinRequest() {
    final request = widget.pendingJoinRequest;
    if (request == null || _handlingJoinRequest) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _handlingJoinRequest) return;
      _handlingJoinRequest = true;
      try {
        await _join(
          initialCode: request.code,
          dialogTitle: 'Rejoindre une liste rapide',
        );
      } finally {
        if (mounted) {
          _handlingJoinRequest = false;
          widget.onJoinRequestHandled(request);
        }
      }
    });
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _join({
    String initialCode = '',
    String dialogTitle = 'Rejoindre avec un code',
  }) async {
    final sharing = widget.sharedDocuments;
    if (sharing == null) return;
    final code = await _askQuickCode(
      context,
      initialCode: initialCode,
      title: dialogTitle,
    );
    if (code == null) return;
    try {
      final access = await sharing.join(code);
      if (access.documentType != SharedDocumentType.quickList) {
        throw StateError('Ce code correspond à un voyage.');
      }
      if (mounted) setState(() => _selectedListId = access.documentId);
    } on Object catch (error) {
      if (mounted) _message(userMessageFor(error));
    }
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
      if (mounted) _message(userMessageFor(error));
    }
  }

  Future<void> _shareSummary(QuickListSummary summary) async {
    final sharing = widget.sharedDocuments;
    if (sharing == null) return;
    try {
      final list = await widget.useCases.load(summary.id);
      if (list == null) return;
      final code = list.v1ShareReady
          ? list.shareCode
          : (await sharing.shareQuickList(list.id)).shareCode;
      if (code == null) return;
      await widget.shareInvitations.share(
        ShareInvitation(
          type: ShareableDocumentType.quickList,
          displayName: list.name,
          code: code,
        ),
      );
    } on Object catch (error) {
      if (mounted) _message(userMessageFor(error));
    }
  }

  Future<void> _openListActions(QuickListSummary list) =>
      showHierarchyEntityActionsSheet(
        context,
        entityId: list.id,
        entityLabel: 'Liste rapide',
        initialName: list.name,
        initialIcon: list.icon,
        onRename: (name) => widget.useCases.rename(list.id, name),
        onIconChanged: (icon) =>
            widget.useCases.setIcon(list.id, icon ?? 'liste'),
        onDelete: () => widget.useCases.delete(list.id),
        extraActions: [
          if (widget.sharedDocuments != null)
            HierarchyEntityAction(
              label: 'Partager',
              icon: Icons.share_outlined,
              onPressed: () => _shareSummary(list),
            ),
          HierarchyEntityAction(
            label: list.archivedAt == null ? 'Archiver' : 'Restaurer',
            icon: list.archivedAt == null
                ? Icons.archive_outlined
                : Icons.unarchive_outlined,
            onPressed: () => list.archivedAt == null
                ? widget.useCases.archive(list.id)
                : widget.useCases.restore(list.id),
          ),
          HierarchyEntityAction(
            label: 'Dupliquer',
            icon: Icons.copy_outlined,
            onPressed: () => _duplicate(list.id),
          ),
        ],
      );

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
        sharedDocuments: widget.sharedDocuments,
        shareInvitations: widget.shareInvitations,
      );
    }
    return PopScope(
      canPop: !_showArchives,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showArchives) {
          setState(() => _showArchives = false);
        }
      },
      child: StreamBuilder<List<QuickListSummary>>(
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
                title: const VersionedTitle('Listes rapides'),
                actions: [
                  if (widget.sharedDocuments != null)
                    IconButton(
                      key: const Key('quick-join'),
                      onPressed: _join,
                      tooltip: 'Rejoindre avec un code',
                      icon: const Icon(Icons.group_add_outlined),
                    ),
                  PopupMenuButton<String>(
                    key: const Key('quick-root-menu'),
                    tooltip: 'Plus d’options',
                    position: PopupMenuPosition.under,
                    onSelected: (_) =>
                        setState(() => _showArchives = !_showArchives),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        height: 44,
                        value: 'archives',
                        child: Row(
                          children: [
                            Icon(
                              _showArchives
                                  ? Icons.checklist_outlined
                                  : Icons.archive_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _showArchives ? 'Mes listes' : 'Archives',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_showArchives)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.archive_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Archives',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
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
                        onLongPress: () => _openListActions(list),
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
      ),
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
    required this.sharedDocuments,
    required this.shareInvitations,
  });

  final String listId;
  final QuickListUseCases useCases;
  final VoidCallback onBack;
  final Future<void> Function(String) onDuplicate;
  final SharedDocumentUseCases? sharedDocuments;
  final ShareInvitationGateway shareInvitations;

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
      if (code == null) return;
      await widget.shareInvitations.share(
        ShareInvitation(
          type: ShareableDocumentType.quickList,
          displayName: list.name,
          code: code,
        ),
      );
    } on Object catch (error) {
      if (mounted) _message(userMessageFor(error));
    }
  }

  Future<void> _openActions(QuickListDetailModel list) =>
      showHierarchyEntityActionsSheet(
        context,
        entityId: list.id,
        entityLabel: 'Liste rapide',
        initialName: list.name,
        initialIcon: list.icon,
        onRename: (name) => widget.useCases.rename(list.id, name),
        onIconChanged: (icon) =>
            widget.useCases.setIcon(list.id, icon ?? 'liste'),
        onDelete: () async {
          await widget.useCases.delete(list.id);
          widget.onBack();
        },
        extraActions: [
          if (widget.sharedDocuments != null)
            HierarchyEntityAction(
              label: 'Partager',
              icon: Icons.share_outlined,
              onPressed: () => _share(list),
            ),
          HierarchyEntityAction(
            label: list.archivedAt == null ? 'Archiver' : 'Restaurer',
            icon: list.archivedAt == null
                ? Icons.archive_outlined
                : Icons.unarchive_outlined,
            onPressed: () => list.archivedAt == null
                ? widget.useCases.archive(list.id)
                : widget.useCases.restore(list.id),
          ),
          HierarchyEntityAction(
            label: 'Dupliquer',
            icon: Icons.copy_outlined,
            onPressed: () => widget.onDuplicate(list.id),
          ),
        ],
      );

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
      _message(userMessageFor(error));
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
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (_editingItemId != null) {
              setState(() => _editingItemId = null);
            } else {
              widget.onBack();
            }
          },
          child: CustomScrollView(
            key: Key('quick-detail-scroll-${list.id}'),
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Row(
                  children: [
                    CategoryIconView(
                      key: Key('quick-detail-icon-${list.id}'),
                      icon: list.icon,
                      size: 23,
                      fallbackIcon: Icons.list_alt_outlined,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        list.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextScale.of(context).pageTitle,
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (widget.sharedDocuments != null)
                    IconButton(
                      key: Key(
                        list.v1ShareReady ? 'quick-show-code' : 'quick-share',
                      ),
                      tooltip: 'Partager',
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () => _share(list),
                    ),
                  IconButton(
                    key: const Key('quick-actions'),
                    tooltip: 'Administrer la liste',
                    onPressed: () => _openActions(list),
                    icon: const Icon(Icons.more_vert),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList.builder(
                  itemCount: list.items.length,
                  itemBuilder: (context, index) {
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                  child: _InlineQuickAdder(
                    key: const Key('quick-add-item'),
                    label: 'Ajouter un item',
                    fieldKey: const Key('quick-add-item-input'),
                    submitKey: const Key('quick-add-item-submit'),
                    onSubmit: (name) async {
                      await widget.useCases.addItem(list.id, name);
                    },
                    onError: _message,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<String?> _askQuickCode(
  BuildContext context, {
  String initialCode = '',
  String title = 'Rejoindre avec un code',
}) {
  return showJoinCodeDialog(
    context,
    title: title,
    initialCode: initialCode,
    inputKey: const Key('quick-share-code-input'),
    submitKey: const Key('quick-share-code-submit'),
  );
}
