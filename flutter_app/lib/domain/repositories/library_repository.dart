import '../models/destination_summaries.dart';

abstract interface class LibraryRepository {
  Stream<List<LibraryOwnerSummary>> watchOwners();
}
