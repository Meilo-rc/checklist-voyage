import '../models/checklist_models.dart';

abstract interface class ContextRepository {
  Stream<List<ContextModel>> watchContexts();

  Future<List<ContextModel>> loadContexts();

  Future<String> createContext(String name);

  Future<void> renameContext(String contextId, String name);

  Future<void> deleteContext(String contextId);

  Future<Set<String>> loadContextIdsForItem(String itemId);

  Future<void> setItemContexts(String itemId, Set<String> contextIds);
}
