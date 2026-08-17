import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_quick_list_repository.dart';
import 'package:checklist_voyage_v1/domain/models/progress.dart';

void main() {
  test(
    'liste rapide locale: CRUD, quantité, état, progression et reset',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftQuickListRepository(database);

      final listId = await repository.createQuickList('Courses cabine');
      final chargerId = await repository.addItem(
        listId: listId,
        name: 'Chargeur',
        quantity: 2,
      );
      final bookId = await repository.addItem(
        listId: listId,
        name: 'Livre',
        quantity: 1,
      );
      await repository.toggleItem(chargerId);
      await repository.changeItemQuantity(bookId, 500);
      await repository.updateItem(itemId: bookId, name: 'Guide', quantity: 0);

      var list = (await repository.loadQuickList(listId))!;
      expect(list.name, 'Courses cabine');
      expect(list.items, hasLength(2));
      expect(
        list.items.singleWhere((item) => item.id == chargerId).isChecked,
        isTrue,
      );
      expect(list.items.singleWhere((item) => item.id == bookId).quantity, 1);
      expect(list.items.singleWhere((item) => item.id == bookId).name, 'Guide');
      expect(ProgressCalculator.forQuickList(list).total, 2);
      expect(ProgressCalculator.forQuickList(list).completed, 1);
      expect(ProgressCalculator.forQuickList(list).percent, 50);

      await repository.reset(listId);
      list = (await repository.loadQuickList(listId))!;
      expect(list.items.every((item) => !item.isChecked), isTrue);
      expect(ProgressCalculator.forQuickList(list).percent, 0);

      await repository.renameQuickList(listId, 'Cabine');
      await repository.deleteItem(bookId);
      list = (await repository.loadQuickList(listId))!;
      expect(list.name, 'Cabine');
      expect(list.items.map((item) => item.id), [chargerId]);

      final row = await (database.select(
        database.quickLists,
      )..where((value) => value.id.equals(listId))).getSingle();
      expect(row.shareState, 'local');
      expect(row.shareCode, isNull);
      expect(row.remoteRecordId, isNull);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
      expect(await database.select(database.syncTombstones).get(), isEmpty);
    },
  );

  test(
    'suppression d une liste rapide est un tombstone local transactionnel',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftQuickListRepository(database);
      final listId = await repository.createQuickList('Week-end');
      await repository.addItem(listId: listId, name: 'Clés', quantity: 1);

      await repository.deleteQuickList(listId);

      expect(await repository.loadQuickList(listId), isNull);
      expect(
        (await database.select(database.quickLists).getSingle()).deletedAt,
        isNotNull,
      );
      expect(
        (await database.select(database.quickListItems).getSingle()).deletedAt,
        isNotNull,
      );
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
  );

  test('ajout sur une liste absente ne laisse aucun item orphelin', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftQuickListRepository(database);

    await expectLater(
      repository.addItem(listId: 'absente', name: 'Orphelin', quantity: 1),
      throwsA(anything),
    );

    expect(await database.select(database.quickListItems).get(), isEmpty);
  });
}
