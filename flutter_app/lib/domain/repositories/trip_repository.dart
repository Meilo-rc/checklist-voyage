import '../models/destination_summaries.dart';
import '../models/checklist_models.dart';

abstract interface class TripRepository {
  Stream<List<TripSummary>> watchTrips();

  Stream<TripDetailModel?> watchTrip(String tripId);

  Future<TripDetailModel?> loadTrip(String tripId);

  Future<String> createTrip(CreateTripRequest request);

  Future<void> updateTripDetails(UpdateTripDetailsRequest request);

  Future<String> duplicateTrip(DuplicateTripRequest request);

  Future<void> archiveTrip(String tripId);

  Future<void> restoreTrip(String tripId);

  Future<void> cycleItemStatus(String itemId);

  Future<void> changeItemQuantity(String itemId, int delta);

  Future<void> renameItem(String itemId, String name);

  Future<void> removeItem(String itemId);

  Future<String> addItem({
    required String tripId,
    required String categoryId,
    required String name,
    int quantity = 1,
  });

  Future<void> renameCategory(String categoryId, String name);

  Future<String> addCategory({
    required String tripId,
    required String? memberId,
    required String name,
    String? icon,
  });

  Future<void> setCategoryIcon(String categoryId, String? icon);

  Future<void> removeCategory(String categoryId);
}
