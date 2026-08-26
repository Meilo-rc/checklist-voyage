import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/presentation/user_message.dart';
import '../../core/theme/app_theme.dart';

const categoryIconNames = <String>[
  'add-invoice-stroke-rounded',
  'add',
  'airpod',
  'baby',
  'bathtub',
  'beach',
  'bed',
  'boat',
  'boy',
  'bus',
  'calendar',
  'camera',
  'car',
  'categorie',
  'child',
  'clothes',
  'cocktail',
  'diaper',
  'document',
  'dress',
  'eyeglass',
  'female',
  'first-aid',
  'gamepad',
  'games',
  'hiking',
  'home',
  'hotel',
  'key',
  'liste',
  'luggage',
  'male',
  'manager',
  'money',
  'music',
  'passport',
  'plane',
  'plug',
  'restaurant',
  'setting',
  'shopping',
  'ski',
  'snow',
  'sport',
  'stretching',
  'suit',
  'suitcase',
  'sun',
  'swimming',
  'tag',
  'tent',
  'toiletries',
  'tools',
  'train',
  'umbrella',
  'video',
  'walking',
  'water',
  'workout',
  'writing',
];

class CategoryIconView extends StatelessWidget {
  const CategoryIconView({
    super.key,
    required this.icon,
    this.size = 22,
    this.color,
    this.fallbackIcon = Icons.folder_outlined,
  });

  final String? icon;
  final double size;
  final Color? color;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final name = icon?.replaceAll('.svg', '');
    final foreground = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    if (name == null || !categoryIconNames.contains(name)) {
      return Icon(fallbackIcon, size: size, color: foreground);
    }
    return SvgPicture.asset(
      'assets/category-icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
    );
  }
}

class HierarchyEntityAction {
  const HierarchyEntityAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;
}

Future<void> showHierarchyEntityActionsSheet(
  BuildContext context, {
  required String entityId,
  required String entityLabel,
  required String initialName,
  required String? initialIcon,
  required Future<void> Function(String) onRename,
  required Future<void> Function(String?) onIconChanged,
  required Future<void> Function() onDelete,
  List<HierarchyEntityAction> extraActions = const [],
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _HierarchyEntityActionsSheet(
    entityId: entityId,
    entityLabel: entityLabel,
    initialName: initialName,
    initialIcon: initialIcon,
    onRename: onRename,
    onIconChanged: onIconChanged,
    onDelete: onDelete,
    extraActions: extraActions,
  ),
);

class _HierarchyEntityActionsSheet extends StatefulWidget {
  const _HierarchyEntityActionsSheet({
    required this.entityId,
    required this.entityLabel,
    required this.initialName,
    required this.initialIcon,
    required this.onRename,
    required this.onIconChanged,
    required this.onDelete,
    required this.extraActions,
  });

  final String entityId;
  final String entityLabel;
  final String initialName;
  final String? initialIcon;
  final Future<void> Function(String) onRename;
  final Future<void> Function(String?) onIconChanged;
  final Future<void> Function() onDelete;
  final List<HierarchyEntityAction> extraActions;

  @override
  State<_HierarchyEntityActionsSheet> createState() =>
      _HierarchyEntityActionsSheetState();
}

class _HierarchyEntityActionsSheetState
    extends State<_HierarchyEntityActionsSheet> {
  late final TextEditingController _controller;
  late String? _icon;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _icon = widget.initialIcon?.replaceAll('.svg', '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _message(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
  }

  Future<void> _saveName() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.onRename(name);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (mounted) _message(error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeIcon() async {
    final selection = await _showCategoryIconPicker(context, _icon);
    if (selection == null || !mounted) return;
    try {
      await widget.onIconChanged(selection.icon);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (mounted) _message(error);
    }
  }

  Future<void> _delete() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    try {
      await widget.onDelete();
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (mounted) {
        _message(error);
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            key: Key('hierarchy-actions-${widget.entityId}'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.entityLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: Key('hierarchy-name-${widget.entityId}'),
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _saveName(),
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filledTonal(
                    key: Key('hierarchy-save-${widget.entityId}'),
                    tooltip: 'Enregistrer le nom',
                    onPressed: _saving ? null : _saveName,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ListTile(
                key: Key('hierarchy-icon-${widget.entityId}'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CategoryIconView(
                  icon: _icon,
                  size: 24,
                  fallbackIcon: Icons.folder_outlined,
                ),
                title: const Text('Changer l’icône'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _changeIcon,
              ),
              ...widget.extraActions.map(
                (action) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(action.icon),
                  title: Text(action.label),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await action.onPressed();
                  },
                ),
              ),
              ListTile(
                key: Key('hierarchy-delete-${widget.entityId}'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                textColor: colors.error,
                iconColor: colors.error,
                leading: const Icon(Icons.delete_outline),
                title: Text('Supprimer ${widget.entityLabel.toLowerCase()}'),
                trailing: _deleting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _deleting ? null : _delete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconSelection {
  const _IconSelection(this.icon);

  final String? icon;
}

Future<_IconSelection?> _showCategoryIconPicker(
  BuildContext context,
  String? selectedIcon,
) => showModalBottomSheet<_IconSelection>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => SafeArea(
    top: false,
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.66,
      minChildSize: 0.38,
      maxChildSize: 0.92,
      builder: (context, controller) {
        final colors = Theme.of(context).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'Choisir une icône',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: GridView.builder(
                key: const Key('hierarchy-icon-grid'),
                controller: controller,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  MediaQuery.paddingOf(context).bottom + AppSpacing.md,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                ),
                itemCount: categoryIconNames.length + 1,
                itemBuilder: (context, index) {
                  final icon = index == 0
                      ? null
                      : categoryIconNames[index - 1];
                  final selected = selectedIcon == icon;
                  return InkWell(
                    key: Key('hierarchy-icon-choice-${icon ?? 'none'}'),
                    borderRadius: BorderRadius.circular(AppRadius.field),
                    onTap: () => Navigator.of(
                      context,
                    ).pop(_IconSelection(icon)),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected
                            ? colors.primaryContainer
                            : colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.field),
                        border: Border.all(
                          color: selected
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                      ),
                      child: Center(
                        child: icon == null
                            ? Icon(
                                Icons.block_outlined,
                                size: 22,
                                color: colors.onSurfaceVariant,
                              )
                            : CategoryIconView(
                                icon: icon,
                                size: 24,
                                color: selected
                                    ? colors.onPrimaryContainer
                                    : colors.onSurfaceVariant,
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

class CategoryDetailsPage extends StatefulWidget {
  const CategoryDetailsPage({
    super.key,
    required this.categoryId,
    required this.initialName,
    required this.initialIcon,
    required this.onRename,
    required this.onIconChanged,
    required this.onDelete,
  });

  final String categoryId;
  final String initialName;
  final String? initialIcon;
  final Future<void> Function(String) onRename;
  final Future<void> Function(String?) onIconChanged;
  final Future<void> Function() onDelete;

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  late final TextEditingController _nameController;
  late String? _icon;
  late String _displayName;
  bool _savingName = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _displayName = widget.initialName;
    _icon = widget.initialIcon?.replaceAll('.svg', '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _message(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _savingName) return;
    setState(() => _savingName = true);
    try {
      await widget.onRename(name);
      if (mounted) {
        setState(() => _displayName = name);
        FocusScope.of(context).unfocus();
      }
    } on Object catch (error) {
      if (mounted) _message(error);
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _selectIcon(String? icon) async {
    if (_icon == icon) return;
    try {
      await widget.onIconChanged(icon);
      if (mounted) setState(() => _icon = icon);
    } on Object catch (error) {
      if (mounted) _message(error);
    }
  }

  Future<void> _delete() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    try {
      await widget.onDelete();
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (mounted) {
        _message(error);
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      key: Key('category-details-${widget.categoryId}'),
      appBar: AppBar(
        title: Text(
          _displayName,
          style: AppTextScale.of(context).pageTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('category-details-name'),
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveName(),
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filledTonal(
                key: const Key('category-details-save'),
                tooltip: 'Enregistrer le nom',
                onPressed: _savingName ? null : _saveName,
                icon: _savingName
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Icône', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            key: const Key('category-icon-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemCount: categoryIconNames.length + 1,
            itemBuilder: (context, index) {
              final icon = index == 0 ? null : categoryIconNames[index - 1];
              final selected = _icon == icon;
              return Semantics(
                button: true,
                selected: selected,
                label: icon == null ? 'Aucune icône' : 'Icône $icon',
                child: InkWell(
                  key: Key('category-icon-${icon ?? 'none'}'),
                  borderRadius: BorderRadius.circular(AppRadius.field),
                  onTap: () => _selectIcon(icon),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primaryContainer
                          : colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      border: Border.all(
                        color: selected
                            ? colors.primary
                            : colors.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: icon == null
                          ? Icon(
                              Icons.block_outlined,
                              size: 22,
                              color: colors.onSurfaceVariant,
                            )
                          : CategoryIconView(
                              icon: icon,
                              size: 24,
                              color: selected
                                  ? colors.onPrimaryContainer
                                  : colors.onSurfaceVariant,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            key: const Key('category-details-delete'),
            onPressed: _deleting ? null : _delete,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer la catégorie'),
          ),
          ],
        ),
      ),
    );
  }
}
