import '../models/destination_summaries.dart';

abstract interface class QuickListRepository {
  Stream<List<QuickListSummary>> watchQuickLists();
}
