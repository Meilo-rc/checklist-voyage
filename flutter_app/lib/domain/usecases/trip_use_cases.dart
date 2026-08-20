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

  Future<void> updateTripDetails(UpdateTripDetailsRequest request) =>
      _trips.updateTripDetails(request);

  Future<String> duplicateTrip(DuplicateTripRequest request) =>
      _trips.duplicateTrip(request);

  Future<void> archiveTrip(String tripId) => _trips.archiveTrip(tripId);

  Future<void> restoreTrip(String tripId) => _trips.restoreTrip(tripId);

  Future<void> cycleItemStatus(String itemId) => _trips.cycleItemStatus(itemId);

  Future<void> changeItemQuantity(String itemId, int delta) =>
      _trips.changeItemQuantity(itemId, delta);

  Future<void> renameItem(String itemId, String name) =>
      _trips.renameItem(itemId, name);

  Future<void> removeItem(String itemId) => _trips.removeItem(itemId);

  Future<Set<String>> loadContextIdsForLibraryItem(String itemId) =>
      _contexts.loadContextIdsForItem(itemId);

  Future<void> saveContextIdsForLibraryItem(
    String itemId,
    Set<String> contextIds,
  ) => _contexts.setItemContexts(itemId, contextIds);

  Future<String> addItem(
    String tripId,
    String categoryId,
    String name, {
    int quantity = 1,
  }) => _trips.addItem(
    tripId: tripId,
    categoryId: categoryId,
    name: name,
    quantity: quantity,
  );

  Future<void> renameCategory(String categoryId, String name) =>
      _trips.renameCategory(categoryId, name);

  Future<void> removeCategory(String categoryId) =>
      _trips.removeCategory(categoryId);
}
