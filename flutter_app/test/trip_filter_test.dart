import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/domain/models/progress.dart';
import 'package:checklist_voyage_v1/domain/models/trip_filters.dart';

import 'helpers/seed_reference_library.dart';

void main() {
  group('filtre d’état', () {
    for (final entry in <TripStateFilter, int>{
      TripStateFilter.all: 7,
      TripStateFilter.todo: 2,
      TripStateFilter.checked: 2,
      TripStateFilter.done: 3,
    }.entries) {
      test('${entry.key.name} conserve les bons items', () {
        final visible = TripFilterEngine.apply(
          _trip(),
          TripFilter(state: entry.key),
        );
        expect(_items(visible), hasLength(entry.value));
      });
    }
  });

  test('Tout trie strictement todo puis checked puis done', () {
    final trip = _trip(
      members: [
        _member('member-order', 'Jenna', TripMemberGroupKind.family, [
          _item('done-z', 'Zulu rangé', TripItemStatus.done),
          _item('todo-z', 'Zulu à préparer', TripItemStatus.todo),
          _item('checked-z', 'Zulu prêt', TripItemStatus.checked),
          _item('done-a', 'Alpha rangé', TripItemStatus.done),
          _item('todo-a', 'Alpha à préparer', TripItemStatus.todo),
          _item('checked-a', 'Alpha prêt', TripItemStatus.checked),
          _item('todo-m', 'Milieu à préparer', TripItemStatus.todo),
        ]),
      ],
    );

    expect(_itemNames(TripFilterEngine.apply(trip, const TripFilter())), [
      'Alpha à préparer',
      'Milieu à préparer',
      'Zulu à préparer',
      'Alpha prêt',
      'Zulu prêt',
      'Alpha rangé',
      'Zulu rangé',
    ]);
  });

  test('options personne ordonnées et fondées sur les UUID du voyage', () {
    final options = TripFilterEngine.personOptions(_trip());

    expect(options.map((option) => option.label), [
      'Tous',
      'Général',
      'Malone',
      'Milo',
    ]);
    expect(options[2].filter.memberId, 'member-malone');
    expect(options[3].filter.memberId, 'member-milo');
    expect(options.any((option) => option.label == 'Membre absent'), isFalse);
  });

  test('personnes, états et sections vides se combinent avec ET', () {
    final trip = _trip();

    expect(
      _itemNames(
        TripFilterEngine.apply(
          trip,
          const TripFilter(
            state: TripStateFilter.todo,
            person: TripPersonFilter.participant('member-malone'),
          ),
        ),
      ),
      ['Maillot'],
    );
    expect(
      _itemNames(
        TripFilterEngine.apply(
          trip,
          const TripFilter(
            state: TripStateFilter.checked,
            person: TripPersonFilter.participant('member-malone'),
          ),
        ),
      ),
      ['Veste'],
    );
    expect(
      _itemNames(
        TripFilterEngine.apply(
          trip,
          const TripFilter(
            state: TripStateFilter.done,
            person: TripPersonFilter.general(),
          ),
        ),
      ),
      ['Clés'],
    );
    expect(
      _itemNames(
        TripFilterEngine.apply(
          trip,
          const TripFilter(state: TripStateFilter.checked),
        ),
      ),
      ['Billet', 'Veste'],
    );
    expect(
      TripFilterEngine.apply(
        trip,
        const TripFilter(
          state: TripStateFilter.todo,
          person: TripPersonFilter.participant('member-milo'),
        ),
      ),
      isEmpty,
    );
  });

  test('le filtre ne modifie ni le modèle ni la progression globale', () {
    final trip = _trip();
    final before = ProgressCalculator.forTrip(trip);

    final visible = TripFilterEngine.apply(
      trip,
      const TripFilter(
        state: TripStateFilter.todo,
        person: TripPersonFilter.participant('member-malone'),
      ),
    );
    final after = ProgressCalculator.forTrip(trip);

    expect(_items(visible), hasLength(1));
    expect(before.total, 7);
    expect(before.completed, 3);
    expect(after.total, before.total);
    expect(after.completed, before.completed);
  });

  test('un item tombstoné reste absent de tous les filtres', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final library = DriftLibraryRepository(database);
    final trips = DriftTripRepository(database);
    final ids = await seedReferenceLibrary(library);
    final tripId = await trips.createTrip(
      CreateTripRequest(
        name: 'Tombstones',
        destination: '',
        startDate: null,
        endDate: null,
        participantOwnerIds: {ids.participantOwner},
        transportOwnerIds: const {},
        lodgingOwnerIds: const {},
      ),
    );
    final before = (await trips.loadTrip(tripId))!;
    final participant = before.members.singleWhere(
      (member) => member.groupKind == TripMemberGroupKind.family,
    );
    final removed = participant.categories.single.items.single;

    await trips.removeItem(removed.id);
    final reloaded = (await trips.loadTrip(tripId))!;

    for (final state in TripStateFilter.values) {
      expect(
        _items(
          TripFilterEngine.apply(
            reloaded,
            TripFilter(
              state: state,
              person: TripPersonFilter.participant(participant.id),
            ),
          ),
        ).any((item) => item.id == removed.id),
        isFalse,
      );
    }
  });

  test('un voyage familial de 140 items est filtré sans section vide', () {
    final members = <TripMemberModel>[];
    for (var memberIndex = 0; memberIndex < 7; memberIndex++) {
      final categories = <TripCategoryModel>[];
      for (var categoryIndex = 0; categoryIndex < 4; categoryIndex++) {
        final items = <TripItemModel>[];
        for (var itemIndex = 0; itemIndex < 5; itemIndex++) {
          final status = TripItemStatus
              .values[(memberIndex + categoryIndex + itemIndex) % 3];
          items.add(
            _item(
              'bulk-$memberIndex-$categoryIndex-$itemIndex',
              'Item $memberIndex-$categoryIndex-$itemIndex',
              status,
            ),
          );
        }
        categories.add(
          TripCategoryModel(
            id: 'bulk-category-$memberIndex-$categoryIndex',
            name: 'Catégorie $categoryIndex',
            items: items,
          ),
        );
      }
      members.add(
        TripMemberModel(
          id: 'bulk-member-$memberIndex',
          name: 'Membre $memberIndex',
          sourceOwnerId: 'owner-$memberIndex',
          groupKind: memberIndex == 0
              ? TripMemberGroupKind.general
              : TripMemberGroupKind.family,
          categories: categories,
        ),
      );
    }
    final trip = _trip(members: members);

    final visible = TripFilterEngine.apply(
      trip,
      const TripFilter(
        state: TripStateFilter.checked,
        person: TripPersonFilter.participant('bulk-member-3'),
      ),
    );

    expect(_items(trip.members), hasLength(140));
    expect(visible, hasLength(1));
    expect(visible.single.id, 'bulk-member-3');
    expect(
      visible.single.categories,
      everyElement(
        predicate((category) {
          return (category as TripCategoryModel).items.isNotEmpty;
        }),
      ),
    );
    expect(
      _items(visible),
      everyElement(
        predicate((item) {
          return (item as TripItemModel).status == TripItemStatus.checked;
        }),
      ),
    );
  });
}

TripDetailModel _trip({List<TripMemberModel>? members}) => TripDetailModel(
  id: 'trip-1',
  name: 'Voyage',
  destination: 'Nice',
  startDate: null,
  endDate: null,
  selectedContextIds: const {},
  members:
      members ??
      [
        _member(
          'general-essential',
          'Essentiels',
          TripMemberGroupKind.general,
          [
            _item('passport', 'Passeport', TripItemStatus.todo),
            _item('keys', 'Clés', TripItemStatus.done),
          ],
        ),
        _member('general-flight', 'Avion', TripMemberGroupKind.general, [
          _item('ticket', 'Billet', TripItemStatus.checked),
        ]),
        _member('member-malone', 'Malone', TripMemberGroupKind.family, [
          _item('swimsuit', 'Maillot', TripItemStatus.todo),
          _item('jacket', 'Veste', TripItemStatus.checked),
          _item('shoes', 'Chaussures', TripItemStatus.done),
        ]),
        _member('member-milo', 'Milo', TripMemberGroupKind.family, [
          _item('cap', 'Casquette', TripItemStatus.done),
        ]),
      ],
);

TripMemberModel _member(
  String id,
  String name,
  TripMemberGroupKind groupKind,
  List<TripItemModel> items,
) => TripMemberModel(
  id: id,
  name: name,
  sourceOwnerId: 'source-$id',
  groupKind: groupKind,
  categories: [
    TripCategoryModel(id: 'category-$id', name: 'Catégorie', items: items),
  ],
);

TripItemModel _item(String id, String name, TripItemStatus status) =>
    TripItemModel(
      id: id,
      name: name,
      quantity: 1,
      status: status,
      sources: const [],
    );

List<TripItemModel> _items(List<TripMemberModel> members) => members
    .expand((member) => member.categories)
    .expand((category) => category.items)
    .toList(growable: false);

List<String> _itemNames(List<TripMemberModel> members) =>
    _items(members).map((item) => item.name).toList(growable: false);
