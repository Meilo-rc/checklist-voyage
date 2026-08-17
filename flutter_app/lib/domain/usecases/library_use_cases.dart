import '../models/checklist_models.dart';
import '../repositories/library_repository.dart';

class LibraryUseCases {
  const LibraryUseCases(this._repository);

  final LibraryRepository _repository;

  Stream<List<LibraryOwnerModel>> watchLibrary() => _repository.watchLibrary();

  Future<List<LibraryOwnerModel>> loadLibrary() => _repository.loadLibrary();

  Future<String> createOwner({
    required String name,
    required LibraryOwnerKind kind,
    required GenerationRole generationRole,
    String? linkedParticipantOwnerId,
  }) => _repository.createOwner(
    name: name,
    kind: kind,
    generationRole: generationRole,
    linkedParticipantOwnerId: linkedParticipantOwnerId,
  );

  Future<void> renameOwner(String ownerId, String name) =>
      _repository.renameOwner(ownerId, name);

  Future<void> setLinkedParticipantOwner(
    String ownerId,
    String? participantOwnerId,
  ) => _repository.setLinkedParticipantOwner(ownerId, participantOwnerId);

  Future<void> deleteOwner(String ownerId) => _repository.deleteOwner(ownerId);

  Future<String> createCategory(String ownerId, String name) =>
      _repository.createCategory(ownerId, name);

  Future<void> renameCategory(String categoryId, String name) =>
      _repository.renameCategory(categoryId, name);

  Future<void> deleteCategory(String categoryId) =>
      _repository.deleteCategory(categoryId);

  Future<String> createItem({
    required String categoryId,
    required String name,
    required int defaultQuantity,
    String? logicalSourceId,
  }) => _repository.createItem(
    categoryId: categoryId,
    name: name,
    defaultQuantity: defaultQuantity,
    logicalSourceId: logicalSourceId,
  );

  Future<void> updateItem({
    required String itemId,
    required String name,
    required int defaultQuantity,
  }) => _repository.updateItem(
    itemId: itemId,
    name: name,
    defaultQuantity: defaultQuantity,
  );

  Future<void> deleteItem(String itemId) => _repository.deleteItem(itemId);
}
