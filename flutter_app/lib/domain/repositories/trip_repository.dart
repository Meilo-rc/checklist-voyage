import '../models/destination_summaries.dart';
import '../models/checklist_models.dart';

abstract interface class TripRepository {
  Stream<List<TripSummary>> watchTrips();

  Stream<TripDetailModel?> watchTrip(String tripId);

  Future<TripDetailModel?> loadTrip(String tripId);

  Future<String> createTrip(CreateTripRequest request);

  Future<void> cycleItemStatus(String itemId);

  Future<void> changeItemQuantity(String itemId, int delta);

  Future<void> removeItem(String itemId);
}
