import '../models/checklist_models.dart';
import '../repositories/quick_list_repository.dart';

class QuickListUseCases {
  const QuickListUseCases(this._repository);

  final QuickListRepository _repository;

  Stream<QuickListDetailModel?> watchQuickList(String id) =>
      _repository.watchQuickList(id);

  Future<String> create(String name) => _repository.createQuickList(name);

  Future<String> duplicate(String id) => _repository.duplicateQuickList(id);

  Future<void> archive(String id) => _repository.archiveQuickList(id);

  Future<void> restore(String id) => _repository.restoreQuickList(id);

  Future<void> rename(String id, String name) =>
      _repository.renameQuickList(id, name);

  Future<void> delete(String id) => _repository.deleteQuickList(id);

  Future<String> addItem(String id, String name, {int quantity = 1}) =>
      _repository.addItem(listId: id, name: name, quantity: quantity);

  Future<void> updateItem(String id, String name, int quantity) =>
      _repository.updateItem(itemId: id, name: name, quantity: quantity);

  Future<void> toggleItem(String id) => _repository.toggleItem(id);

  Future<void> changeQuantity(String id, int delta) =>
      _repository.changeItemQuantity(id, delta);

  Future<void> deleteItem(String id) => _repository.deleteItem(id);

  Future<void> reset(String id) => _repository.reset(id);
}
