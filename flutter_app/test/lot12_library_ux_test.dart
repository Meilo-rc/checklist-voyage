import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';

void main() {
  testWidgets('Général reste hiérarchique, compact et paresseux à 360 px', (
    tester,
  ) async {
    await _narrowScreen(tester, Brightness.light);
    final database = AppDatabase(NativeDatabase.memory());
    final library = DriftLibraryRepository(database);
    final ownerId = await library.createOwner(
      name: 'Groupe général au nom volontairement très long',
      kind: LibraryOwnerKind.general,
      generationRole: GenerationRole.general,
    );
    final firstCategory = await library.createCategory(
      ownerId,
      'Accessoires de voyage au nom volontairement très long',
    );
    final secondCategory = await library.createCategory(ownerId, 'Documents');
    final itemIds = <String>[];
    for (var index = 0; index < 22; index++) {
      itemIds.add(
        await library.createItem(
          categoryId: firstCategory,
          name: 'Item compact numéro ${index + 1}',
          defaultQuantity: 1,
        ),
      );
    }
    final documentItem = await library.createItem(
      categoryId: secondCategory,
      name: 'Passeport',
      defaultQuantity: 1,
    );
    final tombstoned = await library.createItem(
      categoryId: secondCategory,
      name: 'Ancien document',
      defaultQuantity: 1,
    );
    await library.deleteItem(tombstoned);
    final dependencies = await AppDependencies.create(
      database: database,
      autoSync: false,
    );

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await tester.tap(find.text('Bibliothèque'));
    await _pumpData(tester);

    expect(find.byKey(const Key('library-root-general')), findsOneWidget);
    expect(find.textContaining('23 items'), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    await tester.tap(find.byKey(const Key('library-root-general')));
    await tester.pumpAndSettle();
    expect(find.text('Ancien document'), findsNothing);

    await tester.tap(find.byKey(Key('library-category-$firstCategory')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('library-item-${itemIds.first}')), findsOneWidget);
    expect(
      find.byKey(Key('library-item-minus-${itemIds.first}')),
      findsNothing,
    );
    expect(
      find.byKey(Key('library-item-plus-${itemIds.first}')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(Key('library-item-plus-${itemIds.first}')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('library-item-minus-${itemIds.first}')),
      findsOneWidget,
    );
    expect(find.text('2'), findsWidgets);
    for (var quantity = 3; quantity <= 10; quantity++) {
      await tester.tap(find.byKey(Key('library-item-plus-${itemIds.first}')));
      await tester.pump();
    }
    expect(
      find.descendant(
        of: find.byKey(Key('library-item-${itemIds.first}')),
        matching: find.text('10'),
      ),
      findsOneWidget,
    );
    for (var quantity = 9; quantity >= 1; quantity--) {
      await tester.tap(find.byKey(Key('library-item-minus-${itemIds.first}')));
      await tester.pump();
    }
    expect(
      find.byKey(Key('library-item-minus-${itemIds.first}')),
      findsNothing,
    );

    await tester.scrollUntilVisible(
      find.byKey(Key('library-category-$secondCategory')),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(Key('library-category-$secondCategory')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('library-item-${itemIds.first}')), findsNothing);
    expect(find.byKey(Key('library-item-$documentItem')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _dispose(tester, dependencies);
  });

  testWidgets('Personnel ajoute inline sans produire d’opération distante', (
    tester,
  ) async {
    await _narrowScreen(tester, Brightness.dark);
    final database = AppDatabase(NativeDatabase.memory());
    final library = DriftLibraryRepository(database);
    final ownerId = await library.createOwner(
      name: 'Moi',
      kind: LibraryOwnerKind.personal,
      generationRole: GenerationRole.participant,
    );
    final categoryId = await library.createCategory(ownerId, 'Personnel');
    final dependencies = await AppDependencies.create(
      database: database,
      autoSync: false,
    );
    final outboxBefore =
        (await database.select(database.syncOutbox).get()).length;

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await tester.tap(find.text('Bibliothèque'));
    await _pumpData(tester);
    await tester.tap(find.byKey(const Key('library-root-personal')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Personnel').last)).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byKey(Key('library-category-$categoryId')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('library-add-item-collapsed-$categoryId')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(Key('library-add-item-$categoryId')),
      'Objet local',
    );
    await tester.tap(find.byKey(Key('library-add-item-submit-$categoryId')));
    await tester.pumpAndSettle();

    expect(find.text('Objet local'), findsOneWidget);
    expect(
      (await database.select(database.syncOutbox).get()).length,
      outboxBefore,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);

    await _dispose(tester, dependencies);
  });

  testWidgets('Membres ouvre directement les catégories du membre', (
    tester,
  ) async {
    await _narrowScreen(tester, Brightness.light);
    final database = AppDatabase(NativeDatabase.memory());
    final library = DriftLibraryRepository(database);
    final memberId = await library.createOwner(
      name: 'Malone',
      kind: LibraryOwnerKind.familyMember,
      generationRole: GenerationRole.participant,
    );
    await library.createCategory(memberId, 'Vêtements');
    final dependencies = await AppDependencies.create(
      database: database,
      autoSync: false,
    );

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await tester.tap(find.text('Bibliothèque'));
    await _pumpData(tester);
    await tester.tap(find.byKey(const Key('library-root-members')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('library-members-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('library-add-member')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('library-add-member-field')),
      'Milo test',
    );
    await tester.tap(find.byKey(const Key('library-add-member-submit')));
    await tester.pumpAndSettle();
    final addedMember = (await database.select(database.libraryOwners).get())
        .singleWhere((owner) => owner.name == 'Milo test');
    await tester.drag(
      find.byKey(Key('library-member-${addedMember.id}')),
      const Offset(280, 0),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Milo renommé');
    await tester.tap(find.byTooltip('Valider'));
    await tester.pumpAndSettle();
    expect(find.text('Milo renommé'), findsOneWidget);
    await tester.drag(
      find.byKey(Key('library-member-${addedMember.id}')),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();
    expect(
      (await database.select(database.libraryOwners).get())
          .singleWhere((owner) => owner.id == addedMember.id)
          .deletedAt,
      isNotNull,
    );

    await tester.tap(find.byKey(Key('library-member-$memberId')));
    await tester.pumpAndSettle();
    expect(find.text('Vêtements'), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);

    await tester.drag(
      find.byKey(findCategoryKey(await library.loadLibrary(), 'Vêtements')),
      const Offset(280, 0),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tenues');
    await tester.tap(find.byTooltip('Valider'));
    await tester.pumpAndSettle();
    expect(find.text('Tenues'), findsOneWidget);

    await tester.tap(find.byKey(Key('library-add-category-$memberId')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(Key('library-add-category-field-$memberId')),
      'Santé',
    );
    await tester.tap(find.byKey(Key('library-add-category-submit-$memberId')));
    await tester.pumpAndSettle();
    final addedCategory =
        (await database.select(database.libraryCategories).get()).singleWhere(
          (category) => category.name == 'Santé',
        );
    await tester.drag(
      find.byKey(Key('library-category-${addedCategory.id}')),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();
    expect(
      (await database.select(database.libraryCategories).get())
          .singleWhere((category) => category.id == addedCategory.id)
          .deletedAt,
      isNotNull,
    );
    expect(tester.takeException(), isNull);

    await _dispose(tester, dependencies);
  });
}

Key findCategoryKey(List<LibraryOwnerModel> owners, String name) {
  final category = owners
      .expand((owner) => owner.categories)
      .singleWhere((category) => category.name == name);
  return Key('library-category-${category.id}');
}

Future<void> _narrowScreen(WidgetTester tester, Brightness brightness) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
}

Future<void> _pumpData(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _dispose(WidgetTester tester, AppDependencies dependencies) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await dependencies.close();
}
