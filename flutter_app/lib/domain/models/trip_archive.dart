import 'destination_summaries.dart';

enum TripCollection { upcoming, ongoing, archived }

abstract final class TripArchiveClassifier {
  static TripCollection classify(TripSummary trip, DateTime now) {
    if (trip.archivedAt != null || isFinished(trip.endDate, now)) {
      return TripCollection.archived;
    }
    final start = trip.startDate;
    if (start != null && _day(start).isAfter(_day(now))) {
      return TripCollection.upcoming;
    }
    return TripCollection.ongoing;
  }

  static bool isFinished(DateTime? endDate, DateTime now) =>
      endDate != null && _day(endDate).isBefore(_day(now));

  static DateTime archiveSortDate(TripSummary trip) =>
      trip.archivedAt ?? trip.endDate ?? trip.updatedAt;

  static DateTime _day(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
