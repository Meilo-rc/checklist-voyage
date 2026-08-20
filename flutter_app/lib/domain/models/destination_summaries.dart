class TripSummary {
  const TripSummary({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.archivedAt,
    required this.updatedAt,
    required this.participantNames,
    required this.shared,
  });

  final String id;
  final String name;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? archivedAt;
  final DateTime updatedAt;
  final List<String> participantNames;
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
    required this.archivedAt,
    required this.shared,
  });

  final String id;
  final String name;
  final DateTime? archivedAt;
  final bool shared;
}
