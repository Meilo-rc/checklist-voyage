import 'checklist_models.dart';

class ChecklistProgress {
  const ChecklistProgress({required this.total, required this.completed});

  final int total;
  final int completed;

  int get percent => total == 0 ? 0 : ((completed / total) * 100).round();
}

abstract final class ProgressCalculator {
  static ChecklistProgress forTripItems(Iterable<TripItemModel> items) {
    final visible = items.toList(growable: false);
    return ChecklistProgress(
      total: visible.length,
      completed: visible
          .where((item) => item.status == TripItemStatus.done)
          .length,
    );
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
