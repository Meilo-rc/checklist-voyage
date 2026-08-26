import 'package:flutter/material.dart';

import '../../core/presentation/user_message.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/checklist_models.dart';
import '../../domain/usecases/library_use_cases.dart';
import '../shared/category_details_page.dart';

class LibraryBrowser extends StatefulWidget {
  const LibraryBrowser({
    super.key,
    required this.useCases,
    required this.onManageContexts,
    required this.onLinkPersonalOwner,
    required this.onMessage,
  });

  final LibraryUseCases useCases;
  final Future<void> Function(BuildContext, LibraryItemModel) onManageContexts;
  final Future<void> Function(LibraryOwnerModel) onLinkPersonalOwner;
  final void Function(String) onMessage;

  @override
  State<LibraryBrowser> createState() => _LibraryBrowserState();
}

class _LibraryBrowserState extends State<LibraryBrowser> {
  bool _generalExpanded = true;
  bool _membersExpanded = true;
  bool _personalExpanded = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LibraryOwnerModel>>(
      stream: widget.useCases.watchLibrary(),
      builder: (context, snapshot) {
        final owners = snapshot.data ?? const <LibraryOwnerModel>[];
        final general = owners
            .where((owner) => owner.kind == LibraryOwnerKind.general)
            .toList(growable: false);
        final members = owners
            .where((owner) => owner.kind == LibraryOwnerKind.familyMember)
            .toList(growable: false);
        final personal = owners
            .where((owner) => owner.kind == LibraryOwnerKind.personal)
            .toList(growable: false);
        return Column(
          key: const Key('library-root'),
          children: [
              _LibraryLevelBlock(
                key: const Key('library-root-general'),
                title: 'Général',
                subtitle: _categoryItemSummary(general, scope: 'Partagée'),
                expanded: _generalExpanded,
                onToggle: () =>
                    setState(() => _generalExpanded = !_generalExpanded),
                children: [
                  ...general.map(_buildOwner),
                  _ownerAdder(
                    kind: LibraryOwnerKind.general,
                    label: 'Ajouter un groupe',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _LibraryLevelBlock(
                key: const Key('library-root-members'),
                title: 'Membres',
                subtitle:
                    '${members.length} membre${members.length > 1 ? 's' : ''} · '
                    '${_itemCount(members)} items · Partagée',
                expanded: _membersExpanded,
                onToggle: () =>
                    setState(() => _membersExpanded = !_membersExpanded),
                children: [
                  ...members.map(_buildOwner),
                  _ownerAdder(
                    kind: LibraryOwnerKind.familyMember,
                    label: 'Ajouter un membre',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _LibraryLevelBlock(
                key: const Key('library-root-personal'),
                title: 'Personnel',
                subtitle: _categoryItemSummary(personal, scope: 'Locale'),
                expanded: _personalExpanded,
                onToggle: () =>
                    setState(() => _personalExpanded = !_personalExpanded),
                children: [
                  ...personal.map(_buildOwner),
                  _ownerAdder(
                    kind: LibraryOwnerKind.personal,
                    label: 'Ajouter un groupe',
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _ownerAdder({required LibraryOwnerKind kind, required String label}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: _InlineLibraryAdder(
          key: Key('library-add-${kind.name}-owner'),
          label: label,
          fieldKey: Key('library-add-${kind.name}-owner-field'),
          submitKey: Key('library-add-${kind.name}-owner-submit'),
          onSubmit: (name) => widget.useCases.createOwner(
            name: name,
            kind: kind,
            generationRole: kind == LibraryOwnerKind.general
                ? GenerationRole.general
                : GenerationRole.participant,
          ),
          onError: widget.onMessage,
        ),
      );

  Widget _buildOwner(LibraryOwnerModel owner) {
    return _LibraryOwnerRow(
      key: Key('library-member-${owner.id}'),
      owner: owner,
      onTap: () => _openOwner(owner),
      onLongPress: () => _openGroupActions(owner),
    );
  }

  Future<void> _openGroupActions(LibraryOwnerModel owner) =>
      showHierarchyEntityActionsSheet(
        context,
        entityId: owner.id,
        entityLabel: owner.kind == LibraryOwnerKind.familyMember
            ? 'Membre'
            : 'Groupe',
        initialName: owner.name,
        initialIcon: owner.icon,
        onRename: (name) => widget.useCases.renameOwner(owner.id, name),
        onIconChanged: (icon) => widget.useCases.setOwnerIcon(owner.id, icon),
        onDelete: () => widget.useCases.deleteOwner(owner.id),
        extraActions: owner.isPersonal
            ? [
                HierarchyEntityAction(
                  label: 'Associer à un membre',
                  icon: Icons.link_outlined,
                  onPressed: () => widget.onLinkPersonalOwner(owner),
                ),
              ]
            : const [],
      );

  void _openOwner(LibraryOwnerModel owner) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LibraryUniversePage(
          title: owner.name,
          kind: owner.kind,
          ownerId: owner.id,
          useCases: widget.useCases,
          onManageContexts: widget.onManageContexts,
          onLinkPersonalOwner: widget.onLinkPersonalOwner,
          onMessage: widget.onMessage,
        ),
      ),
    );
  }
}

class _LibraryLevelBlock extends StatelessWidget {
  const _LibraryLevelBlock({
    super.key,
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = Color.alphaBlend(
      colors.primary.withValues(alpha: dark ? 0.18 : 0.13),
      colors.surfaceContainerLowest,
    );
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: headerColor,
            child: InkWell(
              key: Key('library-level-${title.toLowerCase()}-toggle'),
              onTap: onToggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextScale.of(context).sectionTitle,
                            ),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextScale.of(context).metadata.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (expanded) ...children,
        ],
      ),
    );
  }
}

class _LibraryOwnerRow extends StatelessWidget {
  const _LibraryOwnerRow({
    super.key,
    required this.owner,
    required this.onTap,
    this.onLongPress,
  });

  final LibraryOwnerModel owner;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 46),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                SizedBox.square(
                  key: Key(
                    owner.kind == LibraryOwnerKind.familyMember
                        ? 'library-member-icon-${owner.id}'
                        : 'library-group-icon-${owner.id}',
                  ),
                  dimension: 32,
                  child: Center(
                    child: CategoryIconView(
                      icon: owner.icon,
                      size: 22,
                      fallbackIcon:
                          owner.kind == LibraryOwnerKind.familyMember
                          ? Icons.person_outline
                          : Icons.folder_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    owner.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextScale.of(context).hierarchyTitle,
                  ),
                ),
                Text(
                  '${owner.categories.length} cat. · '
                  '${_itemCount([owner])} items',
                  style: AppTextScale.of(
                    context,
                  ).metadata.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryUniversePage extends StatefulWidget {
  const _LibraryUniversePage({
    required this.title,
    required this.kind,
    required this.useCases,
    required this.onManageContexts,
    required this.onLinkPersonalOwner,
    required this.onMessage,
    this.ownerId,
  });

  final String title;
  final LibraryOwnerKind kind;
  final String? ownerId;
  final LibraryUseCases useCases;
  final Future<void> Function(BuildContext, LibraryItemModel) onManageContexts;
  final Future<void> Function(LibraryOwnerModel) onLinkPersonalOwner;
  final void Function(String) onMessage;

  @override
  State<_LibraryUniversePage> createState() => _LibraryUniversePageState();
}

class _LibraryUniversePageState extends State<_LibraryUniversePage> {
  String? _expandedCategoryId;
  String? _editingItemId;

  Future<void> _openCategoryDetails(LibraryCategoryModel category) async {
    await showHierarchyEntityActionsSheet(
      context,
      entityId: category.id,
      entityLabel: 'Catégorie',
      initialName: category.name,
      initialIcon: category.icon,
      onRename: (name) => widget.useCases.renameCategory(category.id, name),
      onIconChanged: (icon) =>
          widget.useCases.setCategoryIcon(category.id, icon),
      onDelete: () async {
        await widget.useCases.deleteCategory(category.id);
        if (_expandedCategoryId == category.id && mounted) {
          setState(() => _expandedCategoryId = null);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = _editingItemId != null;
    return PopScope(
      canPop: !editing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && editing) {
          setState(() {
            _editingItemId = null;
          });
        }
      },
      child: Scaffold(
        key: Key('library-${widget.kind.name}-page'),
        body: SafeArea(
          child: StreamBuilder<List<LibraryOwnerModel>>(
            stream: widget.useCases.watchLibrary(),
            builder: (context, snapshot) {
              final owners = (snapshot.data ?? const <LibraryOwnerModel>[])
                  .where(
                    (owner) =>
                        owner.kind == widget.kind &&
                        (widget.ownerId == null || owner.id == widget.ownerId),
                  )
                  .toList(growable: false);
              final currentOwner = owners.isEmpty ? null : owners.first;
              final rows = _buildRows(owners);
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: Row(
                      children: [
                        CategoryIconView(
                          key: Key('library-group-page-icon-${widget.ownerId}'),
                          icon: currentOwner?.icon,
                          size: 23,
                          fallbackIcon:
                              widget.kind == LibraryOwnerKind.familyMember
                              ? Icons.person_outline
                              : Icons.folder_outlined,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            currentOwner?.name ?? widget.title,
                            style: AppTextScale.of(context).pageTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    sliver: SliverList.list(children: rows),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRows(List<LibraryOwnerModel> owners) {
    if (owners.isEmpty) {
      return [
        _EmptyUniverse(
          kind: widget.kind,
          onSubmit: (name) => widget.useCases.createOwner(
            name: name,
            kind: widget.kind,
            generationRole: widget.kind == LibraryOwnerKind.general
                ? GenerationRole.general
                : GenerationRole.participant,
          ),
          onError: widget.onMessage,
        ),
      ];
    }
    final rows = <Widget>[];
    for (final owner in owners) {
      for (final category in owner.categories) {
        rows.add(
          KeyedSubtree(
            key: ValueKey('category:${category.id}'),
            child: _buildCategory(category),
          ),
        );
      }
      rows.add(
        Padding(
          key: ValueKey('category-adder:${owner.id}'),
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _InlineLibraryAdder(
            key: Key('library-add-category-${owner.id}'),
            label: 'Ajouter une catégorie',
            fieldKey: Key('library-add-category-field-${owner.id}'),
            submitKey: Key('library-add-category-submit-${owner.id}'),
            contentIndent: 52,
            onSubmit: (name) => widget.useCases.createCategory(owner.id, name),
            onError: widget.onMessage,
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildCategory(LibraryCategoryModel category) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        key: Key('library-category-items-surface-${category.id}'),
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CategoryHeader(
              key: Key('library-category-${category.id}'),
              category: category,
              expanded: _expandedCategoryId == category.id,
              onTap: () => setState(() {
                _expandedCategoryId = _expandedCategoryId == category.id
                    ? null
                    : category.id;
                _editingItemId = null;
              }),
              onLongPress: () => _openCategoryDetails(category),
              onIconTap: () => _openCategoryDetails(category),
            ),
            if (_expandedCategoryId == category.id) ...[
              ...category.items.map(_buildItem),
              _InlineLibraryAdder(
                key: Key('library-add-item-collapsed-${category.id}'),
                label: 'Ajouter un item',
                fieldKey: Key('library-add-item-${category.id}'),
                submitKey: Key('library-add-item-submit-${category.id}'),
                contentIndent: 40,
                onSubmit: (name) => widget.useCases.createItem(
                  categoryId: category.id,
                  name: name,
                  defaultQuantity: 1,
                ),
                onError: widget.onMessage,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(LibraryItemModel item) {
    if (_editingItemId == item.id) {
      return _InlineRenameRow(
        initialValue: item.name,
        onCancel: () => setState(() => _editingItemId = null),
        onSubmit: (name) async {
          await widget.useCases.updateItem(
            itemId: item.id,
            name: name,
            defaultQuantity: item.defaultQuantity,
          );
          if (mounted) setState(() => _editingItemId = null);
        },
        onError: widget.onMessage,
      );
    }
    return Dismissible(
      key: Key('library-item-dismiss-${item.id}'),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          setState(() => _editingItemId = item.id);
          return false;
        }
        try {
          await widget.useCases.deleteItem(item.id);
          return true;
        } on Object catch (error) {
          widget.onMessage(userMessageFor(error));
          return false;
        }
      },
      background: const _LibrarySwipeAction(
        alignment: Alignment.centerLeft,
        icon: Icons.edit_outlined,
        label: 'Modifier',
      ),
      secondaryBackground: const _LibrarySwipeAction(
        alignment: Alignment.centerRight,
        icon: Icons.delete_outline,
        label: 'Supprimer',
        destructive: true,
      ),
      child: _LibraryItemRow(
        key: Key('library-item-${item.id}'),
        item: item,
        onLongPress: () => widget.onManageContexts(context, item),
        onQuantityChanged: (quantity) => widget.useCases.updateItem(
          itemId: item.id,
          name: item.name,
          defaultQuantity: quantity,
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    super.key,
    required this.category,
    required this.expanded,
    required this.onTap,
    required this.onLongPress,
    required this.onIconTap,
  });

  final LibraryCategoryModel category;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onIconTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = Color.alphaBlend(
      AppColors.primary.withValues(alpha: dark ? 0.24 : 0.20),
      colors.surfaceContainer,
    );
    return Material(
      key: Key('library-category-header-surface-${category.id}'),
      color: headerColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                InkWell(
                  key: Key('library-category-icon-${category.id}'),
                  onTap: onIconTap,
                  borderRadius: BorderRadius.circular(AppRadius.field),
                  child: SizedBox.square(
                    dimension: 32,
                    child: Center(
                      child: CategoryIconView(
                        icon: category.icon,
                        size: 22,
                        fallbackIcon: Icons.folder_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextScale.of(context).sectionTitle,
                  ),
                ),
                Text(
                  '${category.items.length}',
                  style: AppTextScale.of(
                    context,
                  ).metadata.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(width: 4),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryItemRow extends StatelessWidget {
  const _LibraryItemRow({
    super.key,
    required this.item,
    required this.onLongPress,
    required this.onQuantityChanged,
  });

  final LibraryItemModel item;
  final VoidCallback onLongPress;
  final Future<void> Function(int) onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final quantity = item.defaultQuantity;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: InkWell(
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                SizedBox(
                  key: Key('library-item-bullet-${item.id}'),
                  width: 24,
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextScale.of(context).body,
                  ),
                ),
                if (quantity > 1) ...[
                  _QuantityButton(
                    key: Key('library-item-minus-${item.id}'),
                    icon: Icons.remove,
                    tooltip: 'Diminuer la quantité',
                    onPressed: () => onQuantityChanged(quantity - 1),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text('$quantity', textAlign: TextAlign.center),
                  ),
                ],
                _QuantityButton(
                  key: Key('library-item-plus-${item.id}'),
                  icon: Icons.add,
                  tooltip: 'Augmenter la quantité',
                  onPressed: quantity >= 99
                      ? null
                      : () => onQuantityChanged(quantity + 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 20),
    );
  }
}

class _InlineLibraryAdder extends StatefulWidget {
  const _InlineLibraryAdder({
    super.key,
    required this.label,
    required this.fieldKey,
    required this.submitKey,
    required this.onSubmit,
    required this.onError,
    this.contentIndent = 0,
  });

  final String label;
  final Key fieldKey;
  final Key submitKey;
  final Future<void> Function(String) onSubmit;
  final void Function(String) onError;
  final double contentIndent;

  @override
  State<_InlineLibraryAdder> createState() => _InlineLibraryAdderState();
}

class _InlineLibraryAdderState extends State<_InlineLibraryAdder> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_collapseWhenEmpty);
  }

  @override
  void dispose() {
    _focus.removeListener(_collapseWhenEmpty);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _collapseWhenEmpty() {
    if (!_focus.hasFocus && _editing && _controller.text.trim().isEmpty) {
      setState(() => _editing = false);
    }
  }

  void _open() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  Future<void> _submit() async {
    final value = _controller.text.trim();
    if (value.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(value);
      _controller.clear();
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focus.requestFocus();
        });
      }
    } on Object catch (error) {
      widget.onError(userMessageFor(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _open,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: EdgeInsets.only(left: widget.contentIndent),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: AppTextScale.of(context).body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox.square(
                    dimension: 40,
                    child: Icon(Icons.add, size: 19),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: widget.contentIndent),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: widget.fieldKey,
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                style: AppTextScale.of(context).body,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onTapOutside: (_) => _focus.unfocus(),
                decoration: InputDecoration(
                  hintText: widget.label,
                  hintStyle: AppTextScale.of(context).body.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            IconButton.filledTonal(
              key: widget.submitKey,
              tooltip: 'Ajouter',
              onPressed: _saving ? null : _submit,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineRenameRow extends StatefulWidget {
  const _InlineRenameRow({
    required this.initialValue,
    required this.onCancel,
    required this.onSubmit,
    required this.onError,
  });

  final String initialValue;
  final VoidCallback onCancel;
  final Future<void> Function(String) onSubmit;
  final void Function(String) onError;

  @override
  State<_InlineRenameRow> createState() => _InlineRenameRowState();
}

class _InlineRenameRowState extends State<_InlineRenameRow> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.initialValue.length,
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _controller.text.trim();
    if (value.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(value);
    } on Object catch (error) {
      widget.onError(userMessageFor(error));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('library-inline-rename-field'),
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Annuler',
            onPressed: widget.onCancel,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close, size: 19),
          ),
          IconButton(
            tooltip: 'Valider',
            onPressed: _saving ? null : _submit,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.check, size: 19),
          ),
        ],
      ),
    );
  }
}

class _LibrarySwipeAction extends StatelessWidget {
  const _LibrarySwipeAction({
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 19),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: foreground)),
        ],
      ),
    );
  }
}

class _EmptyUniverse extends StatelessWidget {
  const _EmptyUniverse({
    required this.kind,
    required this.onSubmit,
    required this.onError,
  });

  final LibraryOwnerKind kind;
  final Future<void> Function(String) onSubmit;
  final void Function(String) onError;

  @override
  Widget build(BuildContext context) {
    final label = kind == LibraryOwnerKind.familyMember
        ? 'Ajouter un membre'
        : 'Ajouter un groupe';
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text('Aucune catégorie pour le moment.'),
        ),
        _InlineLibraryAdder(
          label: label,
          fieldKey: const Key('library-add-empty-owner-field'),
          submitKey: const Key('library-add-empty-owner-submit'),
          onSubmit: onSubmit,
          onError: onError,
        ),
      ],
    );
  }
}

int _itemCount(Iterable<LibraryOwnerModel> owners) => owners.fold(
  0,
  (total, owner) =>
      total +
      owner.categories.fold(0, (sum, category) => sum + category.items.length),
);

String _categoryItemSummary(
  Iterable<LibraryOwnerModel> owners, {
  required String scope,
}) {
  final categories = owners.fold(
    0,
    (total, owner) => total + owner.categories.length,
  );
  return '$categories cat. · ${_itemCount(owners)} items · $scope';
}
