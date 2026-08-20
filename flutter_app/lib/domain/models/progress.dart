import 'checklist_models.dart';

class ChecklistProgress {
  const ChecklistProgress({required this.total, required this.completed});

  final int total;
  final int completed;

  int get percent => total == 0 ? 0 : ((completed / total) * 100).round();
}

abstract final class ProgressCalculator {
  static ChecklistProgress forTripStatuses(Iterable<TripItemStatus> statuses) {
    final values = statuses.toList(growable: false);
    return ChecklistProgress(
      total: values.length,
      completed: values.where((status) => status == TripItemStatus.done).length,
    );
  }

  static ChecklistProgress forTripItems(Iterable<TripItemModel> items) {
    return forTripStatuses(items.map((item) => item.status));
  }

  static ChecklistProgress forCategory(TripCategoryModel category) =>
      forTripItems(category.items);

  static ChecklistProgress forMember(TripMemberModel member) =>
      forTripItems(member.categories.expand((category) => category.items));

  static ChecklistProgress forTrip(TripDetailModel trip) => forTripItems(
    trip.members.expand(
      (member) => member.categories.expand((category) => category.items),
    ),
  );

  static ChecklistProgress forQuickList(QuickListDetailModel list) {
    return ChecklistProgress(
      total: list.items.length,
      completed: list.items.where((item) => item.isChecked).length,
    );
  }
}
