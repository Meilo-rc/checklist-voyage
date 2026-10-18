import 'package:flutter/material.dart';

Future<String?> showJoinCodeDialog(
  BuildContext context, {
  required String title,
  required String initialCode,
  required Key inputKey,
  required Key submitKey,
}) => showDialog<String>(
  context: context,
  builder: (context) => _JoinCodeDialog(
    title: title,
    initialCode: initialCode,
    inputKey: inputKey,
    submitKey: submitKey,
  ),
);

class _JoinCodeDialog extends StatefulWidget {
  const _JoinCodeDialog({
    required this.title,
    required this.initialCode,
    required this.inputKey,
    required this.submitKey,
  });

  final String title;
  final String initialCode;
  final Key inputKey;
  final Key submitKey;

  @override
  State<_JoinCodeDialog> createState() => _JoinCodeDialogState();
}

class _JoinCodeDialogState extends State<_JoinCodeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      key: widget.inputKey,
      controller: _controller,
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
        key: widget.submitKey,
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Rejoindre'),
      ),
    ],
  );
}
