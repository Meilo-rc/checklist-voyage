class TripSummary {
  const TripSummary({
    required this.id,
    required this.name,
    required this.shared,
  });

  final String id;
  final String name;
  final bool shared;
}

class LibraryOwnerSummary {
  const LibraryOwnerSummary({
    required this.id,
    required this.name,
    required this.personal,
  });

  final String id;
  final String name;
  final bool personal;
}

class QuickListSummary {
  const QuickListSummary({
    required this.id,
    required this.name,
    required this.shared,
  });

  final String id;
  final String name;
  final bool shared;
}
