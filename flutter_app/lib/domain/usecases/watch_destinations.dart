import '../models/destination_summaries.dart';
import '../repositories/library_repository.dart';
import '../repositories/quick_list_repository.dart';
import '../repositories/trip_repository.dart';

class WatchTrips {
  const WatchTrips(this._repository);
  final TripRepository _repository;
  Stream<List<TripSummary>> call() => _repository.watchTrips();
}

class WatchLibraryOwners {
  const WatchLibraryOwners(this._repository);
  final LibraryRepository _repository;
  Stream<List<LibraryOwnerSummary>> call() => _repository.watchOwners();
}

class WatchQuickLists {
  const WatchQuickLists(this._repository);
  final QuickListRepository _repository;
  Stream<List<QuickListSummary>> call() => _repository.watchQuickLists();
}
