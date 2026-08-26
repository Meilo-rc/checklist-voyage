import 'progress.dart';

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
    this.transportNames = const [],
    this.lodgingNames = const [],
    this.progress = const ChecklistProgress(total: 0, completed: 0),
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
  final List<String> transportNames;
  final List<String> lodgingNames;
  final ChecklistProgress progress;
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
    required this.icon,
    required this.archivedAt,
    required this.shared,
  });

  final String id;
  final String name;
  final String icon;
  final DateTime? archivedAt;
  final bool shared;
}
