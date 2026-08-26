enum LibraryOwnerKind { general, familyMember, personal }

enum GenerationRole { general, essential, participant, transport, lodging }

enum TripItemStatus { todo, checked, done }

enum GenerationReasonKind {
  essential,
  participant,
  transport,
  lodging,
  context,
  personal,
  legacy,
}

class ContextModel {
  const ContextModel({required this.id, required this.name});

  final String id;
  final String name;
}

class LibraryItemModel {
  const LibraryItemModel({
    required this.id,
    required this.name,
    required this.defaultQuantity,
    required this.logicalSourceId,
  });

  final String id;
  final String name;
  final int defaultQuantity;
  final String logicalSourceId;
}

class LibraryCategoryModel {
  const LibraryCategoryModel({
    required this.id,
    required this.name,
    required this.items,
    this.icon,
  });

  final String id;
  final String name;
  final List<LibraryItemModel> items;
  final String? icon;
}

class LibraryOwnerModel {
  const LibraryOwnerModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.generationRole,
    required this.linkedParticipantOwnerId,
    required this.categories,
    this.icon,
  });

  final String id;
  final String name;
  final LibraryOwnerKind kind;
  final GenerationRole generationRole;
  final String? linkedParticipantOwnerId;
  final List<LibraryCategoryModel> categories;
  final String? icon;

  bool get isPersonal => kind == LibraryOwnerKind.personal;
}

class CreateTripRequest {
  const CreateTripRequest({
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.participantOwnerIds,
    required this.transportOwnerIds,
    required this.lodgingOwnerIds,
    this.contextIds = const {},
    this.personalCategoryIds = const {},
    this.includeEssentials = true,
  });

  final String name;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> participantOwnerIds;
  final Set<String> transportOwnerIds;
  final Set<String> lodgingOwnerIds;
  final Set<String> contextIds;
  final Set<String> personalCategoryIds;
  final bool includeEssentials;
}

class UpdateTripDetailsRequest {
  const UpdateTripDetailsRequest({
    required this.tripId,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
  });

  final String tripId;
  final String name;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
}

class DuplicateTripRequest {
  const DuplicateTripRequest({
    required this.sourceTripId,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
  });

  final String sourceTripId;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
}

class TripItemSourceModel {
  const TripItemSourceModel({
    required this.logicalSourceId,
    required this.reasonKind,
    required this.reasonId,
    required this.contributingLibraryItemId,
  });

  final String logicalSourceId;
  final GenerationReasonKind reasonKind;
  final String reasonId;
  final String? contributingLibraryItemId;
}

class TripItemModel {
  const TripItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.status,
    required this.sources,
  });

  final String id;
  final String name;
  final int quantity;
  final TripItemStatus status;
  final List<TripItemSourceModel> sources;

  List<String> get sourceLibraryItemIds => sources
      .map((source) => source.logicalSourceId)
      .toSet()
      .toList(growable: false);
}

class TripCategoryModel {
  const TripCategoryModel({
    required this.id,
    required this.name,
    required this.items,
    this.icon,
  });

  final String id;
  final String name;
  final List<TripItemModel> items;
  final String? icon;
}

class TripMemberModel {
  const TripMemberModel({
    required this.id,
    required this.name,
    required this.sourceOwnerId,
    required this.groupKind,
    required this.categories,
    this.icon,
  });

  final String id;
  final String name;
  final String? sourceOwnerId;
  final TripMemberGroupKind groupKind;
  final List<TripCategoryModel> categories;
  final String? icon;
}

enum TripMemberGroupKind { general, family, personal }

class TripDetailModel {
  const TripDetailModel({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.selectedContextIds,
    required this.members,
    this.selectedParticipantOwnerIds = const {},
    this.selectedTransportOwnerIds = const {},
    this.selectedLodgingOwnerIds = const {},
    this.selectedPersonalCategoryIds = const {},
    this.archivedAt,
    this.shared = false,
    this.v1ShareReady = false,
    this.shareCode,
  });

  final String id;
  final String name;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> selectedContextIds;
  final Set<String> selectedParticipantOwnerIds;
  final Set<String> selectedTransportOwnerIds;
  final Set<String> selectedLodgingOwnerIds;
  final Set<String> selectedPersonalCategoryIds;
  final List<TripMemberModel> members;
  final DateTime? archivedAt;
  final bool shared;
  final bool v1ShareReady;
  final String? shareCode;
}

class QuickListItemModel {
  const QuickListItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.isChecked,
  });

  final String id;
  final String name;
  final int quantity;
  final bool isChecked;
}

class QuickListDetailModel {
  const QuickListDetailModel({
    required this.id,
    required this.name,
    required this.items,
    this.archivedAt,
    this.shared = false,
    this.v1ShareReady = false,
    this.shareCode,
  });

  final String id;
  final String name;
  final List<QuickListItemModel> items;
  final DateTime? archivedAt;
  final bool shared;
  final bool v1ShareReady;
  final String? shareCode;
}

enum SharedDocumentType { trip, quickList }

class SharedDocumentAccess {
  const SharedDocumentAccess({
    required this.documentId,
    required this.documentType,
    required this.shareCode,
  });

  final String documentId;
  final SharedDocumentType documentType;
  final String shareCode;
}
