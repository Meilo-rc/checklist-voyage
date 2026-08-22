String userMessageFor(
  Object error, {
  String fallback = 'Impossible d’effectuer cette action.',
}) {
  final Object? message = switch (error) {
    ArgumentError() => error.message,
    StateError() => error.message,
    FormatException() => error.message,
    _ => null,
  };
  if (message is String && message.trim().isNotEmpty) {
    return message.trim();
  }

  final text = error.toString().trim();
  if (text == 'Réseau indisponible.' ||
      text == 'Code de partage invalide.') {
    return text;
  }
  return fallback;
}
