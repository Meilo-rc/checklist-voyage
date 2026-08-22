import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/in_memory_sync_remote.dart';

void main() {
  testWidgets(
    'liste dense : état binaire, quantités, ajout inline, swipe et reset',
    (tester) async {
      await _narrowScreen(tester, Brightness.light);
      final database = AppDatabase(NativeDatabase.memory());
      final dependencies = await AppDependencies.create(
        database: database,
        syncRemote: InMemorySyncRemote(),
        documentRemote: InMemorySharedDocumentRemote(),
        autoSync: false,
      );
      final listId = await dependencies.quickLists.create(
        'Liste au nom volontairement très long pour le contrôle à 360 px',
      );
      final checkedId = await dependencies.quickLists.addItem(
        listId,
        'Premier item au nom volontairement très long',
      );
      await dependencies.quickLists.toggleItem(checkedId);
      final quantityId = await dependencies.quickLists.addItem(
        listId,
        'Gourdes',
        quantity: 12,
      );
      for (var index = 3; index <= 20; index++) {
        await dependencies.quickLists.addItem(listId, 'Item numéro $index');
      }
      final secondList = await dependencies.quickLists.create('Piscine Milo');
      await dependencies.quickLists.addItem(secondList, 'Maillot');

      await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
      await _pumpData(tester);
      await tester.tap(find.text('Listes rapides').last);
      await _pumpData(tester);

      expect(find.byType(Card), findsNothing);
      expect(find.text('1/20'), findsOneWidget);
      expect(find.text('0/1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(Key('quick-summary-$listId')));
      await _pumpData(tester);

      await tester.scrollUntilVisible(
        find.byKey(Key('quick-item-toggle-$checkedId')),
        160,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byKey(Key('quick-item-toggle-$checkedId')), findsOneWidget);
      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byKey(Key('quick-item-minus-$checkedId')), findsNothing);
      expect(find.byKey(Key('quick-item-plus-$checkedId')), findsOneWidget);
      await tester.tap(find.byKey(Key('quick-item-plus-$checkedId')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('quick-item-minus-$checkedId')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.byKey(Key('quick-item-minus-$checkedId')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('quick-item-minus-$checkedId')), findsNothing);

      await tester.tap(find.byKey(Key('quick-item-toggle-$checkedId')));
      await tester.pumpAndSettle();
      expect(
        (await dependencies.quickLists.watchQuickList(listId).first)!.items
            .singleWhere((item) => item.id == checkedId)
            .isChecked,
        isFalse,
      );
      await tester.scrollUntilVisible(
        find.byKey(Key('quick-item-toggle-$checkedId')),
        160,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(Key('quick-item-toggle-$checkedId')));
      await tester.pumpAndSettle();
      expect(
        (await dependencies.quickLists.watchQuickList(listId).first)!.items
            .singleWhere((item) => item.id == checkedId)
            .isChecked,
        isTrue,
      );
      await tester.drag(find.byType(Scrollable).last, const Offset(0, 2000));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quick-reset')));
      await tester.pumpAndSettle();
      expect(
        (await dependencies.quickLists.watchQuickList(listId).first)!.items
            .every((item) => !item.isChecked),
        isTrue,
      );

      await tester.scrollUntilVisible(
        find.byKey(Key('quick-item-minus-$quantityId')),
        160,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byKey(Key('quick-item-minus-$quantityId')), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('quick-add-item')),
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -100));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quick-add-item')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(
        find.byKey(const Key('quick-add-item-input')),
        'ITEM TEST LOT 13',
      );
      await tester.tap(find.byKey(const Key('quick-add-item-submit')));
      await tester.pumpAndSettle();
      final testItem = (await database.select(database.quickListItems).get())
          .singleWhere((item) => item.name == 'ITEM TEST LOT 13');
      await tester.tapAt(const Offset(8, 180));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(Key('quick-item-${testItem.id}')),
        -180,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.drag(
        find.byKey(Key('quick-item-${testItem.id}')),
        const Offset(280, 0),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('quick-inline-rename-field')),
        'ITEM TEST LOT 13 renommé',
      );
      await tester.tap(find.byTooltip('Valider'));
      await tester.pumpAndSettle();
      expect(find.text('ITEM TEST LOT 13 renommé'), findsOneWidget);
      await tester.drag(
        find.byKey(Key('quick-item-${testItem.id}')),
        const Offset(-320, 0),
      );
      await tester.pumpAndSettle();
      expect(
        (await database.select(database.quickListItems).get())
            .singleWhere((item) => item.id == testItem.id)
            .deletedAt,
        isNotNull,
      );
      expect(tester.takeException(), isNull);

      await _dispose(tester, dependencies);
    },
  );

  testWidgets('partage, archives et duplication restent compacts en sombre', (
    tester,
  ) async {
    await _narrowScreen(tester, Brightness.dark);
    final database = AppDatabase(NativeDatabase.memory());
    final dependencies = await AppDependencies.create(
      database: database,
      syncRemote: InMemorySyncRemote(),
      documentRemote: InMemorySharedDocumentRemote(),
      autoSync: false,
    );
    final sharedId = await dependencies.quickLists.create('Liste partagée');
    await dependencies.quickLists.addItem(sharedId, 'Item partagé');
    await dependencies.sharedDocuments.shareQuickList(sharedId);
    final archivedId = await dependencies.quickLists.create('Liste archivée');
    await dependencies.quickLists.addItem(
      archivedId,
      'Item archivé',
      quantity: 4,
    );
    await dependencies.quickLists.archive(archivedId);

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await tester.tap(find.text('Listes rapides').last);
    await _pumpData(tester);
    expect(find.text('Partagé'), findsOneWidget);
    expect(find.byKey(const Key('quick-join')), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Liste partagée'))).brightness,
      Brightness.dark,
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('quick-archive-tabs')),
        matching: find.text('Archives'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(Key('quick-summary-$archivedId')), findsOneWidget);
    await tester.tap(find.byKey(Key('quick-summary-$archivedId')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick-actions')));
    await tester.pumpAndSettle();
    expect(find.text('Restaurer'), findsOneWidget);
    await tester.tap(find.text('Dupliquer'));
    await _pumpData(tester);

    final lists = await database.select(database.quickLists).get();
    final duplicate = lists.singleWhere(
      (list) => list.id != sharedId && list.id != archivedId,
    );
    expect(duplicate.shareState, 'local');
    expect(duplicate.shareCode, isNull);
    final duplicateItems = await (database.select(
      database.quickListItems,
    )..where((item) => item.quickListId.equals(duplicate.id))).get();
    expect(duplicateItems.single.quantity, 4);
    expect(duplicateItems.single.isChecked, isFalse);
    expect(find.text('Liste archivée — copie'), findsWidgets);
    expect(tester.takeException(), isNull);

    await _dispose(tester, dependencies);
  });
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
