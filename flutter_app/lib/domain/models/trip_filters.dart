import 'checklist_models.dart';

enum TripStateFilter { all, todo, checked, done }

enum TripPersonFilterKind { all, general, participant }

class TripPersonFilter {
  const TripPersonFilter._(this.kind, this.memberId);

  const TripPersonFilter.all() : this._(TripPersonFilterKind.all, null);

  const TripPersonFilter.general() : this._(TripPersonFilterKind.general, null);

  const TripPersonFilter.participant(String memberId)
    : this._(TripPersonFilterKind.participant, memberId);

  final TripPersonFilterKind kind;
  final String? memberId;

  bool selects(TripMemberModel member) => switch (kind) {
    TripPersonFilterKind.all => true,
    TripPersonFilterKind.general =>
      member.groupKind == TripMemberGroupKind.general,
    TripPersonFilterKind.participant => member.id == memberId,
  };

  @override
  bool operator ==(Object other) =>
      other is TripPersonFilter &&
      other.kind == kind &&
      other.memberId == memberId;

  @override
  int get hashCode => Object.hash(kind, memberId);
}

class TripPersonOption {
  const TripPersonOption({required this.filter, required this.label});

  final TripPersonFilter filter;
  final String label;
}

class TripFilter {
  const TripFilter({
    this.state = TripStateFilter.all,
    this.person = const TripPersonFilter.all(),
  });

  final TripStateFilter state;
  final TripPersonFilter person;

  TripFilter copyWith({TripStateFilter? state, TripPersonFilter? person}) =>
      TripFilter(state: state ?? this.state, person: person ?? this.person);
}

abstract final class TripFilterEngine {
  static List<TripPersonOption> personOptions(TripDetailModel trip) => [
    const TripPersonOption(filter: TripPersonFilter.all(), label: 'Tous'),
    const TripPersonOption(
      filter: TripPersonFilter.general(),
      label: 'Général',
    ),
    ...trip.members
        .where((member) => member.groupKind == TripMemberGroupKind.family)
        .map(
          (member) => TripPersonOption(
            filter: TripPersonFilter.participant(member.id),
            label: member.name,
          ),
        ),
  ];

  static List<TripMemberModel> apply(TripDetailModel trip, TripFilter filter) {
    final result = <TripMemberModel>[];
    for (final member in trip.members) {
      if (!filter.person.selects(member)) continue;
      final categories = <TripCategoryModel>[];
      for (final category in member.categories) {
        final items = category.items
            .where((item) => _matchesState(item.status, filter.state))
            .toList(growable: false);
        if (items.isEmpty) continue;
        categories.add(
          TripCategoryModel(id: category.id, name: category.name, items: items),
        );
      }
      if (categories.isEmpty) continue;
      result.add(
        TripMemberModel(
          id: member.id,
          name: member.name,
          sourceOwnerId: member.sourceOwnerId,
          groupKind: member.groupKind,
          categories: categories,
        ),
      );
    }
    return result;
  }

  static bool _matchesState(TripItemStatus status, TripStateFilter filter) =>
      switch (filter) {
        TripStateFilter.all => true,
        TripStateFilter.todo => status == TripItemStatus.todo,
        TripStateFilter.checked => status == TripItemStatus.checked,
        TripStateFilter.done => status == TripItemStatus.done,
      };
}
