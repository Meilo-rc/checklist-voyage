import '../models/checklist_models.dart';
import '../repositories/context_repository.dart';
import '../repositories/library_repository.dart';
import '../repositories/trip_repository.dart';

class TripUseCases {
  const TripUseCases(this._trips, this._library, this._contexts);

  final TripRepository _trips;
  final LibraryRepository _library;
  final ContextRepository _contexts;

  Stream<TripDetailModel?> watchTrip(String tripId) => _trips.watchTrip(tripId);

  Future<List<LibraryOwnerModel>> loadGenerationChoices() =>
      _library.loadLibrary();

  Future<List<ContextModel>> loadContexts() => _contexts.loadContexts();

  Future<String> createTrip(CreateTripRequest request) =>
      _trips.createTrip(request);

  Future<void> cycleItemStatus(String itemId) => _trips.cycleItemStatus(itemId);

  Future<void> changeItemQuantity(String itemId, int delta) =>
      _trips.changeItemQuantity(itemId, delta);

  Future<void> removeItem(String itemId) => _trips.removeItem(itemId);
}
