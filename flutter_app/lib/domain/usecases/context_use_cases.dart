import '../models/checklist_models.dart';
import '../repositories/context_repository.dart';

class ContextUseCases {
  const ContextUseCases(this._repository);

  final ContextRepository _repository;

  Stream<List<ContextModel>> watchContexts() => _repository.watchContexts();

  Future<List<ContextModel>> loadContexts() => _repository.loadContexts();

  Future<String> create(String name) => _repository.createContext(name);

  Future<void> rename(String id, String name) =>
      _repository.renameContext(id, name);

  Future<void> delete(String id) => _repository.deleteContext(id);

  Future<Set<String>> loadForItem(String itemId) =>
      _repository.loadContextIdsForItem(itemId);

  Future<void> saveForItem(String itemId, Set<String> contextIds) =>
      _repository.setItemContexts(itemId, contextIds);
}
