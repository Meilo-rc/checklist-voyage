part of 'quick_lists_screen.dart';

class _QuickListSummaryRow extends StatelessWidget {
  const _QuickListSummaryRow({
    super.key,
    required this.summary,
    required this.useCases,
    required this.onTap,
  });

  final QuickListSummary summary;
  final QuickListUseCases useCases;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuickListDetailModel?>(
      stream: useCases.watchQuickList(summary.id),
      builder: (context, snapshot) {
        final detail = snapshot.data;
        final progress = detail == null
            ? null
            : ProgressCalculator.forQuickList(detail);
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          summary.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (summary.shared)
                          Text(
                            'Partagé',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    progress == null
                        ? '—'
                        : '${progress.completed}/${progress.total}',
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 20),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickProgressHeader extends StatelessWidget {
  const _QuickProgressHeader({
    required this.shared,
    required this.progress,
    required this.onReset,
  });

  final bool shared;
  final ChecklistProgress progress;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 8, 4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 42),
        child: Row(
          children: [
            if (shared) ...[
              Text(
                'Partagé',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: LinearProgressIndicator(
                value: progress.percent / 100,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('${progress.completed}/${progress.total}'),
            if (onReset != null)
              IconButton(
                key: const Key('quick-reset'),
                tooltip: 'Tout décocher',
                onPressed: onReset,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.restart_alt, size: 20),
              )
            else
              const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _QuickItemRow extends StatelessWidget {
  const _QuickItemRow({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onQuantityChanged,
  });

  final QuickListItemModel item;
  final VoidCallback onToggle;
  final Future<void> Function(int) onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            IconButton(
              key: Key('quick-item-toggle-${item.id}'),
              tooltip: item.isChecked ? 'Décocher' : 'Cocher',
              onPressed: onToggle,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              icon: Icon(
                item.isChecked
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 22,
                color: item.isChecked
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: item.isChecked
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            if (item.quantity > 1) ...[
              _QuickQuantityButton(
                key: Key('quick-item-minus-${item.id}'),
                icon: Icons.remove,
                tooltip: 'Diminuer la quantité',
                onPressed: () => onQuantityChanged(-1),
              ),
              SizedBox(
                width: item.quantity > 9 ? 28 : 22,
                child: Text('${item.quantity}', textAlign: TextAlign.center),
              ),
            ],
            _QuickQuantityButton(
              key: Key('quick-item-plus-${item.id}'),
              icon: Icons.add,
              tooltip: 'Augmenter la quantité',
              onPressed: item.quantity >= 99
                  ? null
                  : () => onQuantityChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickQuantityButton extends StatelessWidget {
  const _QuickQuantityButton({
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
      icon: Icon(icon, size: 19),
    );
  }
}

class _InlineQuickAdder extends StatefulWidget {
  const _InlineQuickAdder({
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
  State<_InlineQuickAdder> createState() => _InlineQuickAdderState();
}

class _InlineQuickAdderState extends State<_InlineQuickAdder> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _controller.text.trim();
    if (value.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(value);
      _controller.clear();
      if (mounted) setState(() => _editing = false);
    } on Object catch (error) {
      widget.onError(error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _open() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
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

class _InlineQuickRename extends StatefulWidget {
  const _InlineQuickRename({
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
  State<_InlineQuickRename> createState() => _InlineQuickRenameState();
}

class _InlineQuickRenameState extends State<_InlineQuickRename> {
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
      widget.onError(error.toString());
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

class _QuickSwipeAction extends StatelessWidget {
  const _QuickSwipeAction({
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
