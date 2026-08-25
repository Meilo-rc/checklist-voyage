import 'package:flutter/material.dart';

import '../../core/presentation/user_message.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/checklist_models.dart';
import '../../domain/usecases/library_use_cases.dart';
import '../shared/category_details_page.dart';

class LibraryBrowser extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return StreamBuilder<List<LibraryOwnerModel>>(
      stream: useCases.watchLibrary(),
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
            _UniverseRow(
              key: const Key('library-root-general'),
              title: 'Général',
              subtitle: _categoryItemSummary(general, scope: 'Partagée'),
              onTap: () => _openUniverse(
                context,
                title: 'Général',
                kind: LibraryOwnerKind.general,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _UniverseRow(
              key: const Key('library-root-members'),
              title: 'Membres',
              subtitle:
                  '${members.length} membre${members.length > 1 ? 's' : ''} · '
                  '${_itemCount(members)} items · Partagée',
              onTap: () => _openMembers(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _UniverseRow(
              key: const Key('library-root-personal'),
              title: 'Personnel',
              subtitle: _categoryItemSummary(personal, scope: 'Locale'),
              onTap: () => _openUniverse(
                context,
                title: 'Personnel',
                kind: LibraryOwnerKind.personal,
              ),
            ),
          ],
        );
      },
    );
  }

  void _openUniverse(
    BuildContext context, {
    required String title,
    required LibraryOwnerKind kind,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LibraryUniversePage(
          title: title,
          kind: kind,
          useCases: useCases,
          onManageContexts: onManageContexts,
          onLinkPersonalOwner: onLinkPersonalOwner,
          onMessage: onMessage,
        ),
      ),
    );
  }

  void _openMembers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _MembersPage(
          useCases: useCases,
          onManageContexts: onManageContexts,
          onLinkPersonalOwner: onLinkPersonalOwner,
          onMessage: onMessage,
        ),
      ),
    );
  }
}

class _UniverseRow extends StatelessWidget {
  const _UniverseRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = Color.alphaBlend(
      colors.primary.withValues(alpha: dark ? 0.18 : 0.13),
      colors.surfaceContainerLowest,
    );
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: ColoredBox(
            color: headerColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MembersPage extends StatefulWidget {
  const _MembersPage({
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
  State<_MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<_MembersPage> {
  String? _editingOwnerId;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _editingOwnerId == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _editingOwnerId != null) {
          setState(() => _editingOwnerId = null);
        }
      },
      child: Scaffold(
        key: const Key('library-members-page'),
        body: StreamBuilder<List<LibraryOwnerModel>>(
          stream: widget.useCases.watchLibrary(),
          builder: (context, snapshot) {
            final members = (snapshot.data ?? const <LibraryOwnerModel>[])
                .where((owner) => owner.kind == LibraryOwnerKind.familyMember)
                .toList(growable: false);
            return CustomScrollView(
              slivers: [
                const SliverAppBar(pinned: true, title: Text('Membres')),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  sliver: SliverList.builder(
                    itemCount: members.length + 1,
                    itemBuilder: (context, index) {
                      if (index == members.length) {
                        return _InlineLibraryAdder(
                          key: const Key('library-add-member'),
                          label: 'Ajouter un membre',
                          fieldKey: const Key('library-add-member-field'),
                          submitKey: const Key('library-add-member-submit'),
                          onSubmit: (name) async {
                            await widget.useCases.createOwner(
                              name: name,
                              kind: LibraryOwnerKind.familyMember,
                              generationRole: GenerationRole.participant,
                            );
                          },
                          onError: widget.onMessage,
                        );
                      }
                      final member = members[index];
                      if (_editingOwnerId == member.id) {
                        return _InlineRenameRow(
                          initialValue: member.name,
                          onCancel: () =>
                              setState(() => _editingOwnerId = null),
                          onSubmit: (name) async {
                            await widget.useCases.renameOwner(member.id, name);
                            if (mounted) {
                              setState(() => _editingOwnerId = null);
                            }
                          },
                          onError: widget.onMessage,
                        );
                      }
                      return Dismissible(
                        key: Key('library-member-dismiss-${member.id}'),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            setState(() => _editingOwnerId = member.id);
                            return false;
                          }
                          try {
                            await widget.useCases.deleteOwner(member.id);
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
                        child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          child: InkWell(
                            key: Key('library-member-${member.id}'),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => _LibraryUniversePage(
                                  title: member.name,
                                  kind: LibraryOwnerKind.familyMember,
                                  ownerId: member.id,
                                  useCases: widget.useCases,
                                  onManageContexts: widget.onManageContexts,
                                  onLinkPersonalOwner:
                                      widget.onLinkPersonalOwner,
                                  onMessage: widget.onMessage,
                                ),
                              ),
                            ),
                            onLongPress: () =>
                                setState(() => _editingOwnerId = member.id),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 48),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      member.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${member.categories.length} cat. · '
                                    '${_itemCount([member])} items',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
  String? _editingCategoryId;
  String? _editingItemId;

  Future<void> _openCategoryDetails(LibraryCategoryModel category) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CategoryDetailsPage(
          categoryId: category.id,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = _editingCategoryId != null || _editingItemId != null;
    return PopScope(
      canPop: !editing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && editing) {
          setState(() {
            _editingCategoryId = null;
            _editingItemId = null;
          });
        }
      },
      child: Scaffold(
        key: Key('library-${widget.kind.name}-page'),
        body: StreamBuilder<List<LibraryOwnerModel>>(
          stream: widget.useCases.watchLibrary(),
          builder: (context, snapshot) {
            final owners = (snapshot.data ?? const <LibraryOwnerModel>[])
                .where(
                  (owner) =>
                      owner.kind == widget.kind &&
                      (widget.ownerId == null || owner.id == widget.ownerId),
                )
                .toList(growable: false);
            final rows = _buildRows(owners);
            return CustomScrollView(
              slivers: [
                SliverAppBar(pinned: true, title: Text(widget.title)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  sliver: SliverList.builder(
                    itemCount: rows.length,
                    findChildIndexCallback: (key) {
                      final value = (key as ValueKey<String>).value;
                      final index = rows.indexWhere(
                        (row) => row.stableKey == value,
                      );
                      return index < 0 ? null : index;
                    },
                    itemBuilder: (context, index) => KeyedSubtree(
                      key: ValueKey(rows[index].stableKey),
                      child: _buildRow(rows[index]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_LibraryPageRow> _buildRows(List<LibraryOwnerModel> owners) {
    if (owners.isEmpty) return const [_LibraryPageRow.empty()];
    final rows = <_LibraryPageRow>[];
    for (final owner in owners) {
      if (widget.ownerId == null) rows.add(_LibraryPageRow.owner(owner));
      for (final category in owner.categories) {
        rows.add(_LibraryPageRow.category(category));
        if (_expandedCategoryId == category.id) {
          rows.addAll(category.items.map(_LibraryPageRow.item));
          rows.add(_LibraryPageRow.itemAdder(category));
        }
      }
      rows.add(_LibraryPageRow.categoryAdder(owner));
    }
    return rows;
  }

  Widget _buildRow(_LibraryPageRow row) {
    return switch (row.type) {
      _LibraryPageRowType.empty => _EmptyUniverse(
        kind: widget.kind,
        onSubmit: (name) async {
          await widget.useCases.createOwner(
            name: name,
            kind: widget.kind,
            generationRole: widget.kind == LibraryOwnerKind.general
                ? GenerationRole.general
                : GenerationRole.participant,
          );
        },
        onError: widget.onMessage,
      ),
      _LibraryPageRowType.owner => _OwnerHeader(
        owner: row.owner!,
        onLongPress: row.owner!.isPersonal
            ? () => widget.onLinkPersonalOwner(row.owner!)
            : null,
      ),
      _LibraryPageRowType.category => _buildCategory(row.category!),
      _LibraryPageRowType.item => _buildItem(row.item!),
      _LibraryPageRowType.itemAdder => Padding(
        padding: const EdgeInsets.only(left: 24),
        child: _InlineLibraryAdder(
          key: Key('library-add-item-collapsed-${row.category!.id}'),
          label: 'Ajouter un item',
          fieldKey: Key('library-add-item-${row.category!.id}'),
          submitKey: Key('library-add-item-submit-${row.category!.id}'),
          onSubmit: (name) async {
            await widget.useCases.createItem(
              categoryId: row.category!.id,
              name: name,
              defaultQuantity: 1,
            );
          },
          onError: widget.onMessage,
        ),
      ),
      _LibraryPageRowType.categoryAdder => Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 4),
        child: _InlineLibraryAdder(
          key: Key('library-add-category-${row.owner!.id}'),
          label: 'Ajouter une catégorie',
          fieldKey: Key('library-add-category-field-${row.owner!.id}'),
          submitKey: Key('library-add-category-submit-${row.owner!.id}'),
          onSubmit: (name) async {
            await widget.useCases.createCategory(row.owner!.id, name);
          },
          onError: widget.onMessage,
        ),
      ),
    };
  }

  Widget _buildCategory(LibraryCategoryModel category) {
    if (_editingCategoryId == category.id) {
      return _InlineRenameRow(
        initialValue: category.name,
        onCancel: () => setState(() => _editingCategoryId = null),
        onSubmit: (name) async {
          await widget.useCases.renameCategory(category.id, name);
          if (mounted) setState(() => _editingCategoryId = null);
        },
        onError: widget.onMessage,
      );
    }
    return Dismissible(
      key: Key('library-category-dismiss-${category.id}'),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          setState(() => _editingCategoryId = category.id);
          return false;
        }
        try {
          await widget.useCases.deleteCategory(category.id);
          if (_expandedCategoryId == category.id && mounted) {
            setState(() => _expandedCategoryId = null);
          }
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
      child: _CategoryHeader(
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
    );
  }

  Widget _buildItem(LibraryItemModel item) {
    if (_editingItemId == item.id) {
      return Padding(
        padding: const EdgeInsets.only(left: 24),
        child: _InlineRenameRow(
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
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Dismissible(
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
      ),
    );
  }
}

class _OwnerHeader extends StatelessWidget {
  const _OwnerHeader({required this.owner, this.onLongPress});

  final LibraryOwnerModel owner;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 3),
        child: Text(
          owner.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
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
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              InkWell(
                key: Key('library-category-icon-${category.id}'),
                onTap: onIconTap,
                borderRadius: BorderRadius.circular(AppRadius.field),
                child: SizedBox.square(
                  dimension: 40,
                  child: Center(
                    child: CategoryIconView(icon: category.icon, size: 22),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${category.items.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 20),
              const SizedBox(width: 4),
            ],
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
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
  });

  final String label;
  final Key fieldKey;
  final Key submitKey;
  final Future<void> Function(String) onSubmit;
  final void Function(String) onError;

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
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          onTap: _open,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
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
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: widget.fieldKey,
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onTapOutside: (_) => _focus.unfocus(),
              decoration: InputDecoration(
                hintText: widget.label,
                isDense: true,
                border: InputBorder.none,
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
    final label = kind == LibraryOwnerKind.personal
        ? 'Ajouter un espace personnel'
        : 'Ajouter un groupe général';
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

enum _LibraryPageRowType {
  empty,
  owner,
  category,
  item,
  itemAdder,
  categoryAdder,
}

class _LibraryPageRow {
  const _LibraryPageRow.empty()
    : type = _LibraryPageRowType.empty,
      owner = null,
      category = null,
      item = null;
  const _LibraryPageRow.owner(this.owner)
    : type = _LibraryPageRowType.owner,
      category = null,
      item = null;
  const _LibraryPageRow.category(this.category)
    : type = _LibraryPageRowType.category,
      owner = null,
      item = null;
  const _LibraryPageRow.item(this.item)
    : type = _LibraryPageRowType.item,
      owner = null,
      category = null;
  const _LibraryPageRow.itemAdder(this.category)
    : type = _LibraryPageRowType.itemAdder,
      owner = null,
      item = null;
  const _LibraryPageRow.categoryAdder(this.owner)
    : type = _LibraryPageRowType.categoryAdder,
      category = null,
      item = null;

  final _LibraryPageRowType type;
  final LibraryOwnerModel? owner;
  final LibraryCategoryModel? category;
  final LibraryItemModel? item;

  String get stableKey => switch (type) {
    _LibraryPageRowType.empty => 'empty',
    _LibraryPageRowType.owner => 'owner:${owner!.id}',
    _LibraryPageRowType.category => 'category:${category!.id}',
    _LibraryPageRowType.item => 'item:${item!.id}',
    _LibraryPageRowType.itemAdder => 'item-adder:${category!.id}',
    _LibraryPageRowType.categoryAdder => 'category-adder:${owner!.id}',
  };
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
