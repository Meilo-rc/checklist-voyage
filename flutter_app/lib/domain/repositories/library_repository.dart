import '../models/destination_summaries.dart';
import '../models/checklist_models.dart';

abstract interface class LibraryRepository {
  Stream<List<LibraryOwnerSummary>> watchOwners();

  Stream<List<LibraryOwnerModel>> watchLibrary();

  Future<List<LibraryOwnerModel>> loadLibrary();

  Future<String> createOwner({
    required String name,
    required LibraryOwnerKind kind,
    required GenerationRole generationRole,
    String? linkedParticipantOwnerId,
  });

  Future<void> renameOwner(String ownerId, String name);

  Future<void> setLinkedParticipantOwner(
    String ownerId,
    String? participantOwnerId,
  );

  Future<void> deleteOwner(String ownerId);

  Future<String> createCategory(String ownerId, String name);

  Future<void> renameCategory(String categoryId, String name);

  Future<void> setCategoryIcon(String categoryId, String? icon);

  Future<void> deleteCategory(String categoryId);

  Future<String> createItem({
    required String categoryId,
    required String name,
    required int defaultQuantity,
    String? logicalSourceId,
  });

  Future<void> updateItem({
    required String itemId,
    required String name,
    required int defaultQuantity,
  });

  Future<void> deleteItem(String itemId);
}
