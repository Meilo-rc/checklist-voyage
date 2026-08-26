import '../models/destination_summaries.dart';
import '../models/checklist_models.dart';

abstract interface class QuickListRepository {
  Stream<List<QuickListSummary>> watchQuickLists();

  Stream<QuickListDetailModel?> watchQuickList(String listId);

  Future<QuickListDetailModel?> loadQuickList(String listId);

  Future<String> createQuickList(String name);

  Future<String> duplicateQuickList(String listId);

  Future<void> archiveQuickList(String listId);

  Future<void> restoreQuickList(String listId);

  Future<void> renameQuickList(String listId, String name);

  Future<void> setQuickListIcon(String listId, String icon);

  Future<void> deleteQuickList(String listId);

  Future<String> addItem({
    required String listId,
    required String name,
    required int quantity,
  });

  Future<void> updateItem({
    required String itemId,
    required String name,
    required int quantity,
  });

  Future<void> toggleItem(String itemId);

  Future<void> changeItemQuantity(String itemId, int delta);

  Future<void> deleteItem(String itemId);

  Future<void> reset(String listId);
}
