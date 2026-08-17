enum LibraryOwnerKind { general, familyMember, personal }

enum GenerationRole { general, essential, participant, transport, lodging }

enum TripItemStatus { todo, checked, done }

class LibraryItemModel {
  const LibraryItemModel({
    required this.id,
    required this.name,
    required this.defaultQuantity,
  });

  final String id;
  final String name;
  final int defaultQuantity;
}

class LibraryCategoryModel {
  const LibraryCategoryModel({
    required this.id,
    required this.name,
    required this.items,
  });

  final String id;
  final String name;
  final List<LibraryItemModel> items;
}

class LibraryOwnerModel {
  const LibraryOwnerModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.generationRole,
    required this.categories,
  });

  final String id;
  final String name;
  final LibraryOwnerKind kind;
  final GenerationRole generationRole;
  final List<LibraryCategoryModel> categories;

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
    this.includeEssentials = true,
  });

  final String name;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> participantOwnerIds;
  final Set<String> transportOwnerIds;
  final Set<String> lodgingOwnerIds;
  final bool includeEssentials;
}

class TripItemModel {
  const TripItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.status,
    required this.sourceLibraryItemIds,
  });

  final String id;
  final String name;
  final int quantity;
  final TripItemStatus status;
  final List<String> sourceLibraryItemIds;
}

class TripCategoryModel {
  const TripCategoryModel({
    required this.id,
    required this.name,
    required this.items,
  });

  final String id;
  final String name;
  final List<TripItemModel> items;
}

class TripMemberModel {
  const TripMemberModel({
    required this.id,
    required this.name,
    required this.sourceOwnerId,
    required this.categories,
  });

  final String id;
  final String name;
  final String? sourceOwnerId;
  final List<TripCategoryModel> categories;
}

class TripDetailModel {
  const TripDetailModel({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.members,
  });

  final String id;
  final String name;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TripMemberModel> members;
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
  });

  final String id;
  final String name;
  final List<QuickListItemModel> items;
}
