import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_context_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';

void main() {
  test(
    'plusieurs contextes gardent catégories naturelles et participants choisis',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final contexts = DriftContextRepository(database);
      final trips = DriftTripRepository(database);
      final fixture = await _seedContextGeneration(library, contexts);

      final tripId = await trips.createTrip(
        _request(
          participants: {fixture.maloneOwner},
          contexts: {fixture.beach, fixture.pool},
        ),
      );
      final trip = (await trips.loadTrip(tripId))!;

      expect(trip.selectedContextIds, {fixture.beach, fixture.pool});
      expect(
        trip.members.map((member) => member.name),
        containsAll(<String>['Essentiel', 'Général', 'Malone']),
      );
      expect(trip.members.any((member) => member.name == 'Milo'), isFalse);
      expect(_item(trip, 'Parasol').category.name, 'Accessoires');
      expect(_item(trip, 'Maillot').category.name, 'Vêtements');
      expect(_item(trip, 'Objet personnel').category.name, 'Personnel');
      expect(_item(trip, 'Objet personnel').member.name, 'Malone');

      final passport = _item(trip, 'Passeport').item;
      expect(passport.sourceLibraryItemIds, [fixture.passportItem]);
      expect(
        passport.sources.map((source) => source.reasonKind),
        containsAll(<GenerationReasonKind>[
          GenerationReasonKind.essential,
          GenerationReasonKind.context,
        ]),
      );
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
  );

  test(
    'même source via deux transports produit un item et deux raisons',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final trips = DriftTripRepository(database);
      final flight = await _ownerWithItem(
        library,
        ownerName: 'Avion',
        role: GenerationRole.transport,
        itemName: 'Chargeur téléphone',
        quantity: 1,
      );
      final car = await _ownerWithItem(
        library,
        ownerName: 'Voiture',
        role: GenerationRole.transport,
        itemName: 'Chargeur téléphone',
        quantity: 8,
        logicalSourceId: flight.item,
      );

      final trip = (await trips.loadTrip(
        await trips.createTrip(
          _request(transports: {flight.owner, car.owner}, essentials: false),
        ),
      ))!;
      final item = _allItems(trip).single;

      expect(item.quantity, 1);
      expect(item.sourceLibraryItemIds, [flight.item]);
      expect(item.sources, hasLength(2));
      expect(
        item.sources.map((source) => source.reasonId),
        containsAll(<String>[flight.owner, car.owner]),
      );
    },
  );

  test('même source via transport et logement reste unique', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final library = DriftLibraryRepository(database);
    final trips = DriftTripRepository(database);
    final transport = await _ownerWithItem(
      library,
      ownerName: 'Train',
      role: GenerationRole.transport,
      itemName: 'Adaptateur',
      quantity: 2,
    );
    final lodging = await _ownerWithItem(
      library,
      ownerName: 'Hôtel',
      role: GenerationRole.lodging,
      itemName: 'Adaptateur',
      quantity: 6,
      logicalSourceId: transport.item,
    );

    final trip = (await trips.loadTrip(
      await trips.createTrip(
        _request(
          transports: {transport.owner},
          lodgings: {lodging.owner},
          essentials: false,
        ),
      ),
    ))!;
    final item = _allItems(trip).single;

    expect(item.quantity, 2);
    expect(item.sources, hasLength(2));
    expect(
      item.sources.map((source) => source.reasonKind),
      containsAll(<GenerationReasonKind>[
        GenerationReasonKind.transport,
        GenerationReasonKind.lodging,
      ]),
    );
  });

  test('même source via contexte et transport conserve deux sources', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final library = DriftLibraryRepository(database);
    final contexts = DriftContextRepository(database);
    final trips = DriftTripRepository(database);
    final flight = await _ownerWithItem(
      library,
      ownerName: 'Avion',
      role: GenerationRole.transport,
      itemName: 'Casque',
      quantity: 1,
    );
    final beach = await contexts.createContext('Plage');
    await contexts.setItemContexts(flight.item, {beach});

    final tripId = await trips.createTrip(
      _request(
        transports: {flight.owner},
        contexts: {beach},
        essentials: false,
      ),
    );
    final trip = (await trips.loadTrip(tripId))!;
    final item = _allItems(trip).single;

    expect(item.sources, hasLength(2));
    expect(
      item.sources.map((source) => source.reasonKind),
      containsAll(<GenerationReasonKind>[
        GenerationReasonKind.transport,
        GenerationReasonKind.context,
      ]),
    );

    await trips.removeItem(item.id);
    expect(await trips.loadTrip(tripId), isNotNull);
    expect(_allItems((await trips.loadTrip(tripId))!), isEmpty);
    expect(
      (await database.select(database.libraryItems).getSingle()).deletedAt,
      isNull,
    );
    expect(
      (await database.select(database.libraryItemContexts).getSingle())
          .deletedAt,
      isNull,
    );
    expect(await database.select(database.tripItemSources).get(), hasLength(2));
  });

  test(
    'même source via plusieurs contextes ne multiplie pas la quantité',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final contexts = DriftContextRepository(database);
      final trips = DriftTripRepository(database);
      final general = await _ownerWithItem(
        library,
        ownerName: 'Général',
        role: GenerationRole.general,
        itemName: 'Serviette',
        quantity: 3,
      );
      final beach = await contexts.createContext('Plage');
      final pool = await contexts.createContext('Piscine');
      await contexts.setItemContexts(general.item, {beach, pool});

      final trip = (await trips.loadTrip(
        await trips.createTrip(
          _request(contexts: {beach, pool}, essentials: false),
        ),
      ))!;
      final item = _allItems(trip).single;

      expect(item.quantity, 3);
      expect(item.sources, hasLength(2));
      expect(
        item.sources.every(
          (source) => source.reasonKind == GenerationReasonKind.context,
        ),
        isTrue,
      );
    },
  );

  test('deux homonymes avec UUID distincts ne sont jamais compactés', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final library = DriftLibraryRepository(database);
    final contexts = DriftContextRepository(database);
    final trips = DriftTripRepository(database);
    final first = await _ownerWithItem(
      library,
      ownerName: 'Général A',
      role: GenerationRole.general,
      itemName: 'Chargeur',
      quantity: 1,
    );
    final second = await _ownerWithItem(
      library,
      ownerName: 'Général B',
      role: GenerationRole.general,
      itemName: 'Chargeur',
      quantity: 1,
    );
    final context = await contexts.createContext('Travail');
    await contexts.setItemContexts(first.item, {context});
    await contexts.setItemContexts(second.item, {context});

    final trip = (await trips.loadTrip(
      await trips.createTrip(_request(contexts: {context}, essentials: false)),
    ))!;
    final items = _allItems(trip);

    expect(items, hasLength(2));
    expect(items.map((item) => item.name), everyElement('Chargeur'));
    expect(items.expand((item) => item.sourceLibraryItemIds).toSet(), {
      first.item,
      second.item,
    });
  });

  test(
    'choix et sources compactées persistent et fonctionnent sans réseau',
    () async {
      final directory = await Directory.systemTemp.createTemp('compaction-v1-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');
      String tripId = '';
      String beach = '';

      await HttpOverrides.runZoned(() async {
        var database = AppDatabase(NativeDatabase(file));
        var library = DriftLibraryRepository(database);
        var contexts = DriftContextRepository(database);
        var trips = DriftTripRepository(database);
        final transport = await _ownerWithItem(
          library,
          ownerName: 'Avion',
          role: GenerationRole.transport,
          itemName: 'Casque',
          quantity: 1,
        );
        beach = await contexts.createContext('Plage');
        await contexts.setItemContexts(transport.item, {beach});
        tripId = await trips.createTrip(
          _request(
            transports: {transport.owner},
            contexts: {beach},
            essentials: false,
          ),
        );
        await database.close();

        database = AppDatabase(NativeDatabase(file));
        trips = DriftTripRepository(database);
        final restored = (await trips.loadTrip(tripId))!;
        expect(restored.selectedContextIds, {beach});
        expect(_allItems(restored).single.sources, hasLength(2));
        expect(await database.select(database.syncOutbox).get(), isEmpty);
        await database.close();
      }, createHttpClient: (_) => throw StateError('Réseau interdit'));
    },
  );
}

class _OwnerItem {
  const _OwnerItem(this.owner, this.item);

  final String owner;
  final String item;
}

class _ContextFixture {
  const _ContextFixture({
    required this.maloneOwner,
    required this.beach,
    required this.pool,
    required this.passportItem,
  });

  final String maloneOwner;
  final String beach;
  final String pool;
  final String passportItem;
}

Future<_ContextFixture> _seedContextGeneration(
  DriftLibraryRepository library,
  DriftContextRepository contexts,
) async {
  final essential = await _ownerWithItem(
    library,
    ownerName: 'Essentiel',
    role: GenerationRole.essential,
    itemName: 'Passeport',
    quantity: 1,
  );
  final general = await _ownerWithItem(
    library,
    ownerName: 'Général',
    role: GenerationRole.general,
    itemName: 'Parasol',
    quantity: 1,
    categoryName: 'Accessoires',
  );
  final malone = await _ownerWithItem(
    library,
    ownerName: 'Malone',
    role: GenerationRole.participant,
    kind: LibraryOwnerKind.familyMember,
    itemName: 'Maillot',
    quantity: 1,
    categoryName: 'Vêtements',
  );
  final milo = await _ownerWithItem(
    library,
    ownerName: 'Milo',
    role: GenerationRole.participant,
    kind: LibraryOwnerKind.familyMember,
    itemName: 'Casquette Milo',
    quantity: 1,
  );
  final personalOwner = await library.createOwner(
    name: 'Personnel Malone',
    kind: LibraryOwnerKind.personal,
    generationRole: GenerationRole.participant,
    linkedParticipantOwnerId: malone.owner,
  );
  final personalCategory = await library.createCategory(
    personalOwner,
    'Personnel',
  );
  final personalItem = await library.createItem(
    categoryId: personalCategory,
    name: 'Objet personnel',
    defaultQuantity: 1,
  );
  final beach = await contexts.createContext('Plage');
  final pool = await contexts.createContext('Piscine');
  await contexts.setItemContexts(essential.item, {beach});
  await contexts.setItemContexts(general.item, {beach});
  await contexts.setItemContexts(malone.item, {beach, pool});
  await contexts.setItemContexts(milo.item, {beach});
  await contexts.setItemContexts(personalItem, {beach});
  return _ContextFixture(
    maloneOwner: malone.owner,
    beach: beach,
    pool: pool,
    passportItem: essential.item,
  );
}

Future<_OwnerItem> _ownerWithItem(
  DriftLibraryRepository library, {
  required String ownerName,
  required GenerationRole role,
  required String itemName,
  required int quantity,
  LibraryOwnerKind kind = LibraryOwnerKind.general,
  String categoryName = 'Catégorie',
  String? logicalSourceId,
}) async {
  final owner = await library.createOwner(
    name: ownerName,
    kind: kind,
    generationRole: role,
  );
  final category = await library.createCategory(owner, categoryName);
  final item = await library.createItem(
    categoryId: category,
    name: itemName,
    defaultQuantity: quantity,
    logicalSourceId: logicalSourceId,
  );
  return _OwnerItem(owner, item);
}

CreateTripRequest _request({
  Set<String> participants = const {},
  Set<String> transports = const {},
  Set<String> lodgings = const {},
  Set<String> contexts = const {},
  bool essentials = true,
}) => CreateTripRequest(
  name: 'Test',
  destination: '',
  startDate: null,
  endDate: null,
  participantOwnerIds: participants,
  transportOwnerIds: transports,
  lodgingOwnerIds: lodgings,
  contextIds: contexts,
  includeEssentials: essentials,
);

List<TripItemModel> _allItems(TripDetailModel trip) => trip.members
    .expand((member) => member.categories)
    .expand((category) => category.items)
    .toList(growable: false);

({TripMemberModel member, TripCategoryModel category, TripItemModel item})
_item(TripDetailModel trip, String name) {
  for (final member in trip.members) {
    for (final category in member.categories) {
      for (final item in category.items) {
        if (item.name == name) {
          return (member: member, category: category, item: item);
        }
      }
    }
  }
  throw StateError('Item $name introuvable');
}
