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
      await database.customStatement(
        'UPDATE library_owners SET icon = ? WHERE id = ?',
        ['female', ids.participantOwner],
      );
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
      final generalGroup = trip.members.firstWhere(
        (candidate) => candidate.groupKind == TripMemberGroupKind.general,
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
      _expectNoFlutterError(tester, 'accueil');
      await tester.tap(find.byKey(Key('trip-summary-$tripId')));
      await _pumpData(tester);
      _expectNoFlutterError(tester, 'aperçu du voyage');

      expect(find.byKey(const Key('trip-overview')), findsOneWidget);
      expect(find.text(compactTripPeriodLabel(start, end)), findsOneWidget);
      expect(find.text('Général'), findsWidgets);
      expect(find.text('Membres'), findsOneWidget);
      expect(find.byKey(const Key('trip-level-general')), findsOneWidget);
      expect(find.byKey(const Key('trip-level-members')), findsOneWidget);
      expect(
        find.byKey(const Key('trip-add-group-general-collapsed')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('trip-add-group-family-collapsed')),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('trip-group-icon-${generalGroup.id}')),
        findsOneWidget,
      );
      final levelTitle = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('trip-level-members')),
          matching: find.text('Membres'),
        ),
      );
      expect(levelTitle.style?.fontSize, 18);
      expect(levelTitle.style?.fontWeight, FontWeight.w700);
      final memberRowText = tester.widget<Text>(
        find.descendant(
          of: find.byKey(Key('trip-member-${member.id}')),
          matching: find.text(member.name),
        ),
      );
      expect(memberRowText.style?.fontSize, 16);
      expect(memberRowText.style?.fontWeight, FontWeight.w700);
      expect(find.byKey(Key('trip-member-icon-${member.id}')), findsOneWidget);
      expect(find.byKey(const Key('trip-person-filters')), findsNothing);
      final filterText = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('trip-state-all')),
          matching: find.text('Tout'),
        ),
      );
      expect(filterText.style?.fontSize, 14);
      expect(filterText.style?.fontWeight, FontWeight.w700);
      await tester.tap(find.byKey(Key('trip-member-${member.id}')));
      await tester.pumpAndSettle();
      _expectNoFlutterError(tester, 'page membre');
      expect(find.byKey(Key('trip-member-page-${member.id}')), findsOneWidget);
      final memberPageTitle = tester.widget<Text>(
        find.descendant(
          of: find.byType(SliverAppBar),
          matching: find.text(member.name),
        ),
      );
      expect(memberPageTitle.style?.fontSize, 22);
      expect(memberPageTitle.style?.fontWeight, FontWeight.w700);
      await tester.tap(find.byKey(Key('trip-category-${category.id}')));
      await tester.pumpAndSettle();
      _expectNoFlutterError(tester, 'catégorie ouverte');
      expect(find.byKey(Key('trip-member-page-${member.id}')), findsOneWidget);
      expect(
        find.byKey(Key('trip-category-page-${category.id}')),
        findsNothing,
      );
      expect(
        Theme.of(tester.element(find.text('Vêtements'))).brightness,
        Brightness.light,
      );
      final categoryText = tester.widget<Text>(find.text(category.name));
      expect(categoryText.style?.fontSize, 18);
      expect(categoryText.style?.fontWeight, FontWeight.w700);
      final itemText = tester.widget<Text>(find.text(shirt.name));
      expect(itemText.style?.fontSize, 14);
      final colors = Theme.of(
        tester.element(find.text(category.name)),
      ).colorScheme;
      expect(
        tester
            .widget<Material>(
              find.byKey(Key('trip-category-header-surface-${category.id}')),
            )
            .color,
        isNot(colors.surfaceContainer),
      );
      expect(
        tester
            .widget<Material>(
              find.byKey(Key('trip-category-items-surface-${category.id}')),
            )
            .color,
        colors.surfaceContainerLowest,
      );

      final shirtRow = find.byKey(Key('trip-item-${shirt.id}'));
      expect(tester.getSize(shirtRow).height, lessThanOrEqualTo(48));
      await tester.longPress(shirtRow);
      await tester.pumpAndSettle();
      _expectNoFlutterError(tester, 'contextes');
      await tester.tap(find.byKey(Key('context-choice-$beach')));
      await tester.tap(find.byKey(const Key('context-save-item')));
      await tester.pumpAndSettle();
      _expectNoFlutterError(tester, 'contextes enregistrés');
      expect(await contexts.loadContextIdsForItem(ids.shirtItem), {beach});

      await tester.tap(find.byKey(Key('trip-item-status-${shirt.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('trip-item-status-${shirt.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('trip-item-increase-${shirt.id}')));
      await tester.pumpAndSettle();
      _expectNoFlutterError(tester, 'état et quantité');
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
      _expectNoFlutterError(tester, 'item renommé');
      storedShirt = (await dependencies.trips.watchTrip(tripId).first)!.members
          .expand((group) => group.categories)
          .expand((candidate) => candidate.items)
          .singleWhere((item) => item.id == shirt.id);
      expect(storedShirt.name, 'T-shirt léger');

      final collapsedAdder = find.byKey(
        Key('trip-add-item-collapsed-${category.id}'),
      );
      await tester.ensureVisible(collapsedAdder);
      expect(
        tester.getTopLeft(find.text('T-shirt léger')).dx,
        closeTo(tester.getTopLeft(find.text('Ajouter un item')).dx, 3),
      );
      expect(find.byKey(Key('trip-add-item-${category.id}')), findsNothing);
      await tester.tap(collapsedAdder);
      await tester.pumpAndSettle();
      final addField = find.byKey(Key('trip-add-item-${category.id}'));
      await tester.ensureVisible(addField);
      await tester.enterText(addField, 'Casquette');
      await tester.tap(find.byKey(Key('trip-add-item-submit-${category.id}')));
      await tester.pumpAndSettle();
      _expectNoFlutterError(tester, 'item ajouté');
      final added = (await database.select(database.tripItems).get())
          .singleWhere((item) => item.name == 'Casquette');
      await tester.ensureVisible(find.byKey(Key('trip-item-${added.id}')));
      await tester.drag(
        find.byKey(Key('trip-item-${added.id}')),
        const Offset(-320, 0),
      );
      await tester.pumpAndSettle();
      _expectNoFlutterError(tester, 'item supprimé');
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
      _expectNoFlutterError(tester, 'filtres appliqués');
      await tester.tap(find.byKey(const Key('trip-state-todo')));
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
      _expectNoFlutterError(tester, 'état vide');

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

    expect(find.text('Item 119'), findsOneWidget);
    await tester.ensureVisible(find.text('Item 119'));
    await tester.pumpAndSettle();
    expect(find.text('Item 119'), findsOneWidget);
    await tester.ensureVisible(find.text(longItem.name));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(Key('trip-item-${longItem.id}'))).height,
      lessThanOrEqualTo(48),
    );
    final addItem = find.byKey(Key('trip-add-item-collapsed-${category.id}'));
    await tester.ensureVisible(addItem);
    await tester.pumpAndSettle();
    await tester.tap(addItem);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('trip-add-item-${category.id}')), findsOneWidget);
    await tester.enterText(
      find.byKey(Key('trip-add-item-${category.id}')),
      'Ajout inline',
    );
    await tester.tap(find.byKey(Key('trip-add-item-submit-${category.id}')));
    await tester.pumpAndSettle();
    final successiveAddField = find.byKey(Key('trip-add-item-${category.id}'));
    expect(successiveAddField, findsOneWidget);
    expect(Focus.of(tester.element(successiveAddField)).hasFocus, isTrue);
    expect(tester.takeException(), isNull);

    await _dispose(tester, dependencies);
  });
}

Future<void> _pumpData(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 300));
}

void _expectNoFlutterError(WidgetTester tester, String stage) {
  expect(tester.takeException(), isNull, reason: stage);
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
