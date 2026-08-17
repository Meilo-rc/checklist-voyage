class ImportReport {
  const ImportReport({
    required this.sourceKind,
    required this.sourceSha256,
    required this.alreadyImported,
    required this.owners,
    required this.categories,
    required this.libraryItems,
    required this.trips,
    required this.tripItems,
    required this.quickLists,
    required this.quickListItems,
    required this.personalOwners,
    required this.sharedDocuments,
    required this.localDocuments,
    required this.ignoredAggregateSnapshots,
    required this.warnings,
  });

  final String sourceKind;
  final String sourceSha256;
  final bool alreadyImported;
  final int owners;
  final int categories;
  final int libraryItems;
  final int trips;
  final int tripItems;
  final int quickLists;
  final int quickListItems;
  final int personalOwners;
  final int sharedDocuments;
  final int localDocuments;
  final int ignoredAggregateSnapshots;
  final List<String> warnings;

  ImportReport asAlreadyImported() => ImportReport(
    sourceKind: sourceKind,
    sourceSha256: sourceSha256,
    alreadyImported: true,
    owners: owners,
    categories: categories,
    libraryItems: libraryItems,
    trips: trips,
    tripItems: tripItems,
    quickLists: quickLists,
    quickListItems: quickListItems,
    personalOwners: personalOwners,
    sharedDocuments: sharedDocuments,
    localDocuments: localDocuments,
    ignoredAggregateSnapshots: ignoredAggregateSnapshots,
    warnings: warnings,
  );

  Map<String, Object?> toJson() => {
    'sourceKind': sourceKind,
    'sourceSha256': sourceSha256,
    'alreadyImported': alreadyImported,
    'owners': owners,
    'categories': categories,
    'libraryItems': libraryItems,
    'trips': trips,
    'tripItems': tripItems,
    'quickLists': quickLists,
    'quickListItems': quickListItems,
    'personalOwners': personalOwners,
    'sharedDocuments': sharedDocuments,
    'localDocuments': localDocuments,
    'ignoredAggregateSnapshots': ignoredAggregateSnapshots,
    'warnings': warnings,
  };

  factory ImportReport.fromJson(Map<String, Object?> json) => ImportReport(
    sourceKind: json['sourceKind'] as String? ?? 'unknown',
    sourceSha256: json['sourceSha256'] as String? ?? '',
    alreadyImported: json['alreadyImported'] as bool? ?? false,
    owners: json['owners'] as int? ?? 0,
    categories: json['categories'] as int? ?? 0,
    libraryItems: json['libraryItems'] as int? ?? 0,
    trips: json['trips'] as int? ?? 0,
    tripItems: json['tripItems'] as int? ?? 0,
    quickLists: json['quickLists'] as int? ?? 0,
    quickListItems: json['quickListItems'] as int? ?? 0,
    personalOwners: json['personalOwners'] as int? ?? 0,
    sharedDocuments: json['sharedDocuments'] as int? ?? 0,
    localDocuments: json['localDocuments'] as int? ?? 0,
    ignoredAggregateSnapshots: json['ignoredAggregateSnapshots'] as int? ?? 0,
    warnings: (json['warnings'] as List<Object?>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
  );
}
