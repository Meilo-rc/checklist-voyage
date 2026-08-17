import '../models/destination_summaries.dart';

abstract interface class TripRepository {
  Stream<List<TripSummary>> watchTrips();
}
