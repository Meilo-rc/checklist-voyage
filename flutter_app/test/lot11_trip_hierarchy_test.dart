import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_context_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/features/shared/date_range_label.dart';

import 'helpers/seed_reference_library.dart';

void main() {
  testWidgets(
    'Voyage vers membre, catégorie et items conserve filtres et interactions',
    (tester) async {
      await _narrowScreen(tester);
      final database = AppDatabase(NativeDatabase.memory());
      final library = DriftLibraryRepository(database);
      final ids = await seedReferenceLibrary(library);
      final participant = (await library.loadLibrary()).singleWhere(
        (owner) => owner.id == ids.participantOwner,
      );
      final categoryId = participant.categories.single.id;
      final socksSource = await library.createItem(
        categoryId: categoryId,
        name: 'Chaussettes',
        defaultQuantity: 2,
      );
      final contexts = DriftContextRepository(database);
      final beach = await contexts.createContext('Plage');
      final dependencies = await AppDependencies.create(
        database: database,
        autoSync: false,
      );
      final start = DateTime(2026, 10, 26);
      final end = DateTime(2026, 11, 4);
      final tripId = await dependencies.trips.createTrip(
        CreateTripRequest(
          name: 'Vacances d’automne',
          destination: 'La Rochelle',
          startDate: start,
          endDate: end,
          participantOwnerIds: {ids.participantOwner},
          transportOwnerIds: {ids.flightOwner},
          lodgingOwnerIds: {ids.hotelOwner},
        ),
      );
      var trip = (await dependencies.trips.watchTrip(tripId).first)!;
      final member = trip.members.singleWhere(
        (candidate) => candidate.groupKind == TripMemberGroupKind.family,
      );
      final category = member.categories.single;
      final shirt = category.items.singleWhere(
        (item) => item.sources.any(
          (source) => source.contributingLibraryItemId == ids.shirtItem,
        ),
      );
      final socks = category.items.singleWhere(
        (item) => item.sources.any(
          (source) => source.contributingLibraryItemId == socksSource,
        ),
      );

      await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
      await _pumpData(tester);
      await tester.tap(find.byKey(Key('trip-summary-$tripId')));
      await _pumpData(tester);

      expect(find.byKey(const Key('trip-overview')), findsOneWidget);
      expect(find.text(compactTripPeriodLabel(start, end)), findsOneWidget);
      expect(find.text('Général'), findsWidgets);
      expect(find.text('Membres'), findsOneWidget);
      await tester.tap(find.byKey(Key('trip-member-${member.id}')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('trip-member-page-${member.id}')), findsOneWidget);
      await tester.tap(find.byKey(Key('trip-category-${category.id}')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('trip-member-page-${member.id}')), findsOneWidget);
      expect(
        find.byKey(Key('trip-category-page-${category.id}')),
        findsNothing,
      );
      expect(
        Theme.of(tester.element(find.text('Vêtements'))).brightness,
        Brightness.light,
      );

      final shirtRow = find.byKey(Key('trip-item-${shirt.id}'));
      expect(tester.getSize(shirtRow).height, lessThanOrEqualTo(48));
      await tester.longPress(shirtRow);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('context-choice-$beach')));
      await tester.tap(find.byKey(const Key('context-save-item')));
      await tester.pumpAndSettle();
      expect(await contexts.loadContextIdsForItem(ids.shirtItem), {beach});

      await tester.tap(find.byKey(Key('trip-item-status-${shirt.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('trip-item-status-${shirt.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('trip-item-increase-${shirt.id}')));
      await tester.pumpAndSettle();
      trip = (await dependencies.trips.watchTrip(tripId).first)!;
      var storedShirt = trip.members
          .expand((group) => group.categories)
          .expand((candidate) => candidate.items)
          .singleWhere((item) => item.id == shirt.id);
      expect(storedShirt.status, TripItemStatus.done);
      expect(storedShirt.quantity, shirt.quantity + 1);

      await tester.drag(shirtRow, const Offset(260, 0));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(Key('trip-item-edit-${shirt.id}')),
        'T-shirt léger',
      );
      await tester.tap(find.byKey(Key('trip-item-edit-save-${shirt.id}')));
      await tester.pumpAndSettle();
      storedShirt = (await dependencies.trips.watchTrip(tripId).first)!.members
          .expand((group) => group.categories)
          .expand((candidate) => candidate.items)
          .singleWhere((item) => item.id == shirt.id);
      expect(storedShirt.name, 'T-shirt léger');

      final collapsedAdder = find.byKey(
        Key('trip-add-item-collapsed-${category.id}'),
      );
      await tester.ensureVisible(collapsedAdder);
      expect(find.byKey(Key('trip-add-item-${category.id}')), findsNothing);
      await tester.tap(collapsedAdder);
      await tester.pumpAndSettle();
      final addField = find.byKey(Key('trip-add-item-${category.id}'));
      await tester.ensureVisible(addField);
      await tester.enterText(addField, 'Casquette');
      await tester.tap(find.byKey(Key('trip-add-item-submit-${category.id}')));
      await tester.pumpAndSettle();
      final added = (await database.select(database.tripItems).get())
          .singleWhere((item) => item.name == 'Casquette');
      await tester.ensureVisible(find.byKey(Key('trip-item-${added.id}')));
      await tester.drag(
        find.byKey(Key('trip-item-${added.id}')),
        const Offset(-320, 0),
      );
      await tester.pumpAndSettle();
      expect(
        (await database.select(database.tripItems).get())
            .singleWhere((item) => item.id == added.id)
            .deletedAt,
        isNotNull,
      );
      expect(
        (await database.select(database.libraryItems).get())
            .singleWhere((item) => item.id == ids.shirtItem)
            .deletedAt,
        isNull,
      );

      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trip-state-todo')));
      await tester.tap(find.byKey(Key('trip-person-${member.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('trip-member-${member.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('trip-category-${category.id}')));
      await tester.pumpAndSettle();
      expect(find.text('T-shirt léger'), findsNothing);
      expect(find.text('Chaussettes'), findsOneWidget);
      await tester.tap(find.byKey(Key('trip-item-status-${socks.id}')));
      await tester.pumpAndSettle();
      expect(find.text('Aucun élément à préparer.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _dispose(tester, dependencies);
    },
  );

  testWidgets('catégories inline et 120 items restent denses en sombre', (
    tester,
  ) async {
    await _narrowScreen(tester);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final database = AppDatabase(NativeDatabase.memory());
    final library = DriftLibraryRepository(database);
    final memberOwner = await library.createOwner(
      name: 'Malone',
      kind: LibraryOwnerKind.familyMember,
      generationRole: GenerationRole.participant,
    );
    final sourceCategory = await library.createCategory(
      memberOwner,
      'Vêtements',
    );
    final healthCategory = await library.createCategory(memberOwner, 'Santé');
    final papersCategory = await library.createCategory(
      memberOwner,
      'Documents',
    );
    for (var index = 0; index < 120; index += 1) {
      await library.createItem(
        categoryId: sourceCategory,
        name: index == 2
            ? 'Un nom d’item volontairement très long sur deux lignes'
            : 'Item ${index.toString().padLeft(3, '0')}',
        defaultQuantity: index == 0
            ? 12
            : index == 1
            ? 2
            : 1,
      );
    }
    await library.createItem(
      categoryId: healthCategory,
      name: 'Trousse de secours',
      defaultQuantity: 1,
    );
    await library.createItem(
      categoryId: healthCategory,
      name: 'Médicaments',
      defaultQuantity: 1,
    );
    await library.createItem(
      categoryId: papersCategory,
      name: 'Billets',
      defaultQuantity: 1,
    );
    final dependencies = await AppDependencies.create(
      database: database,
      autoSync: false,
    );
    final tripId = await dependencies.trips.createTrip(
      CreateTripRequest(
        name: 'Grand voyage',
        destination: 'Lyon',
        startDate: DateTime(2026, 12, 1),
        endDate: DateTime(2026, 12, 3),
        participantOwnerIds: {memberOwner},
        transportOwnerIds: const {},
        lodgingOwnerIds: const {},
        includeEssentials: false,
      ),
    );
    final trip = (await dependencies.trips.watchTrip(tripId).first)!;
    final member = trip.members.single;
    final category = member.categories.singleWhere(
      (candidate) => candidate.name == 'Vêtements',
    );
    final health = member.categories.singleWhere(
      (candidate) => candidate.name == 'Santé',
    );
    final healthItem = health.items.singleWhere(
      (item) => item.name == 'Trousse de secours',
    );
    final medicine = health.items.singleWhere(
      (item) => item.name == 'Médicaments',
    );
    final firstItem = category.items.singleWhere(
      (item) => item.name == 'Item 000',
    );
    final quantityOne = category.items.singleWhere(
      (item) => item.name == 'Item 003',
    );
    final longItem = category.items.singleWhere(
      (item) => item.name.startsWith('Un nom'),
    );

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await tester.tap(find.byKey(Key('trip-summary-$tripId')));
    await _pumpData(tester);
    await tester.tap(find.byKey(Key('trip-member-${member.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Vêtements'), findsOneWidget);
    expect(find.text('Santé'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.byKey(Key('trip-item-${firstItem.id}')), findsNothing);
    await tester.tap(find.byKey(Key('trip-category-${category.id}')));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Vêtements'))).brightness,
      Brightness.dark,
    );
    final firstRow = find.byKey(Key('trip-item-${firstItem.id}'));
    expect(tester.getSize(firstRow).height, lessThanOrEqualTo(48));
    expect(find.text('12'), findsOneWidget);
    expect(
      find.byKey(Key('trip-item-decrease-${firstItem.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(Key('trip-item-decrease-${quantityOne.id}')),
      findsNothing,
    );
    await tester.tap(find.byKey(Key('trip-item-increase-${quantityOne.id}')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('trip-item-decrease-${quantityOne.id}')),
      findsOneWidget,
    );
    expect(find.text('2'), findsWidgets);
    await tester.tap(find.byKey(Key('trip-item-decrease-${quantityOne.id}')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('trip-item-decrease-${quantityOne.id}')),
      findsNothing,
    );

    await tester.tap(find.byKey(Key('trip-category-${category.id}')));
    await tester.pumpAndSettle();
    expect(firstRow, findsNothing);
    await tester.tap(find.byKey(Key('trip-category-${health.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Trousse de secours'), findsOneWidget);
    expect(firstRow, findsNothing);
    expect(
      find.byKey(const ValueKey('trip-status-shape-todo')),
      findsNWidgets(2),
    );
    await tester.tap(find.byKey(Key('trip-item-status-${healthItem.id}')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('trip-status-shape-checked')),
      findsOneWidget,
    );
    var healthText = tester.widget<Text>(find.text(healthItem.name));
    expect(healthText.style?.decoration, isNot(TextDecoration.lineThrough));
    expect(
      tester.getTopLeft(find.text(healthItem.name)).dy,
      greaterThan(tester.getTopLeft(find.text(medicine.name)).dy),
    );
    await tester.tap(find.byKey(Key('trip-item-status-${healthItem.id}')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('trip-status-shape-done')),
      findsOneWidget,
    );
    healthText = tester.widget<Text>(find.text(healthItem.name));
    expect(healthText.style?.decoration, TextDecoration.lineThrough);
    await tester.tap(find.byKey(Key('trip-category-${health.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('trip-category-${category.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Item 119'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Item 119'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Item 119'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(longItem.name),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      tester.getSize(find.byKey(Key('trip-item-${longItem.id}'))).height,
      lessThanOrEqualTo(48),
    );
    await tester.scrollUntilVisible(
      find.byKey(Key('trip-add-item-collapsed-${category.id}')),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(Key('trip-add-item-collapsed-${category.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('trip-add-item-${category.id}')), findsOneWidget);
    await tester.enterText(
      find.byKey(Key('trip-add-item-${category.id}')),
      'Ajout inline',
    );
    await tester.tap(find.byKey(Key('trip-add-item-submit-${category.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('trip-add-item-${category.id}')), findsNothing);
    expect(
      find.byKey(Key('trip-add-item-collapsed-${category.id}')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await _dispose(tester, dependencies);
  });
}

Future<void> _pumpData(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _narrowScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _dispose(WidgetTester tester, AppDependencies dependencies) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await dependencies.close();
}
