import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';

void main() {
  testWidgets('CRUD contexte et association par appui long', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    final database = AppDatabase(NativeDatabase.memory());
    final library = DriftLibraryRepository(database);
    final owner = await library.createOwner(
      name: 'Général UI',
      kind: LibraryOwnerKind.general,
      generationRole: GenerationRole.general,
    );
    final category = await library.createCategory(owner, 'Accessoires');
    final item = await library.createItem(
      categoryId: category,
      name: 'Lunettes',
      defaultQuantity: 1,
    );
    final dependencies = await AppDependencies.create(database: database);

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bibliothèque'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('library-contexts')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('context-create')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('context-name-input')),
      'Plage',
    );
    await tester.tap(find.byKey(const Key('context-name-submit')));
    await tester.pumpAndSettle();

    final contextId = (await database.select(database.contexts).getSingle()).id;
    final row = find.byKey(Key('context-row-$contextId'));
    await tester.tap(
      find.descendant(of: row, matching: find.byTooltip('Renommer')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('context-name-input')),
      'Plage et piscine',
    );
    await tester.tap(find.byKey(const Key('context-name-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Plage et piscine'), findsOneWidget);

    await tester.tapAt(const Offset(12, 100));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('library-root-general')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accessoires'));
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(Key('library-item-$item')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('context-save-item'))),
      ).brightness,
      Brightness.dark,
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Plage et piscine'));
    await tester.tap(find.byKey(const Key('context-save-item')));
    await tester.pumpAndSettle();

    final association = await database
        .select(database.libraryItemContexts)
        .getSingle();
    expect(association.itemId, item);
    expect(association.contextId, contextId);
    expect(association.deletedAt, isNull);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('library-contexts')));
    await tester.pumpAndSettle();
    final reopenedRow = find.byKey(Key('context-row-$contextId'));
    await tester.tap(
      find.descendant(of: reopenedRow, matching: find.byTooltip('Supprimer')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aucun contexte pour le moment.'), findsOneWidget);
    expect(
      (await database.select(database.libraryItems).getSingle()).deletedAt,
      isNull,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await dependencies.close();
    await tester.pump(const Duration(milliseconds: 1));
  });
}
