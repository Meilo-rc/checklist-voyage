import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets(
    'voyage rejoint en filtre Tout conserve et trie les trois états',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final remote = InMemorySharedDocumentRemote();
      final databaseA = AppDatabase(NativeDatabase.memory());
      final databaseB = AppDatabase(NativeDatabase.memory());
      final a = await AppDependencies.create(
        database: databaseA,
        documentRemote: remote,
        autoSync: false,
      );
      final b = await AppDependencies.create(
        database: databaseB,
        documentRemote: remote,
        autoSync: false,
      );
      final fixture = await _seedJoinedUiTrip(databaseA);
      final access = await a.sharedDocuments.shareTrip(fixture.tripId);
      await b.sharedDocuments.join(access.shareCode);

      await tester.pumpWidget(ChecklistApp(dependencies: b));
      await _pumpData(tester);
      await tester.tap(find.byKey(Key('trip-summary-${fixture.tripId}')));
      await _pumpData(tester);

      final allChip = tester.widget<FilterChip>(
        find.byKey(const Key('trip-state-all')),
      );
      expect(allChip.selected, isTrue);
      await tester.tap(find.byKey(Key('trip-member-${fixture.memberId}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('trip-category-${fixture.categoryId}')));
      await tester.pumpAndSettle();

      final todoRow = find.byKey(Key('trip-item-${fixture.todoId}'));
      final secondTodoRow = find.byKey(
        Key('trip-item-${fixture.secondTodoId}'),
      );
      final checkedRow = find.byKey(Key('trip-item-${fixture.checkedId}'));
      final doneRow = find.byKey(Key('trip-item-${fixture.doneId}'));
      expect(todoRow, findsOneWidget);
      expect(secondTodoRow, findsOneWidget);
      expect(checkedRow, findsOneWidget);
      expect(doneRow, findsOneWidget);

      await tester.tap(find.byKey(Key('trip-item-status-${fixture.todoId}')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(todoRow, findsOneWidget);
      expect(
        find.descendant(
          of: todoRow,
          matching: find.byKey(const ValueKey('trip-status-shape-checked')),
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        tester.getTopLeft(secondTodoRow).dy,
        lessThan(tester.getTopLeft(todoRow).dy),
      );
      expect(
        tester.getTopLeft(todoRow).dy,
        lessThan(tester.getTopLeft(doneRow).dy),
      );

      await tester.tap(find.byKey(Key('trip-item-status-${fixture.todoId}')));
      await tester.pump(const Duration(milliseconds: 180));
      expect(todoRow, findsOneWidget);
      expect(
        find.descendant(
          of: todoRow,
          matching: find.byKey(const ValueKey('trip-status-shape-done')),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(Key('trip-item-status-${fixture.todoId}')));
      await tester.pump(const Duration(milliseconds: 180));
      expect(todoRow, findsOneWidget);
      expect(
        find.descendant(
          of: todoRow,
          matching: find.byKey(const ValueKey('trip-status-shape-todo')),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(todoRow).dy,
        lessThan(tester.getTopLeft(checkedRow).dy),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      await a.close();
      await b.close();
      await tester.pump(const Duration(milliseconds: 10));
    },
  );
}

Future<_JoinedUiFixture> _seedJoinedUiTrip(AppDatabase database) async {
  const tripId = '30000000-0000-4000-8000-000000000001';
  const memberId = '30000000-0000-4000-8000-000000000002';
  const categoryId = '30000000-0000-4000-8000-000000000003';
  const todoId = '30000000-0000-4000-8000-000000000004';
  const checkedId = '30000000-0000-4000-8000-000000000005';
  const doneId = '30000000-0000-4000-8000-000000000006';
  const secondTodoId = '30000000-0000-4000-8000-000000000007';
  final now = DateTime.utc(2026, 8, 31);
  await database.transaction(() async {
    await database
        .into(database.trips)
        .insert(
          TripsCompanion.insert(
            id: tripId,
            name: 'Voyage rejoint',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await database
        .into(database.tripMembers)
        .insert(
          TripMembersCompanion.insert(
            id: memberId,
            tripId: tripId,
            groupKind: 'family',
            name: 'Jenna',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await database
        .into(database.tripCategories)
        .insert(
          TripCategoriesCompanion.insert(
            id: categoryId,
            tripId: tripId,
            memberId: const Value(memberId),
            name: 'Vêtements',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    for (final item in [
      (todoId, 'A à préparer', 'todo'),
      (secondTodoId, 'A2 à préparer', 'todo'),
      (checkedId, 'B prêt', 'checked'),
      (doneId, 'C rangé', 'done'),
    ]) {
      await database
          .into(database.tripItems)
          .insert(
            TripItemsCompanion.insert(
              id: item.$1,
              tripId: tripId,
              categoryId: categoryId,
              name: item.$2,
              status: Value(item.$3),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
    }
  });
  return const _JoinedUiFixture(
    tripId: tripId,
    memberId: memberId,
    categoryId: categoryId,
    todoId: todoId,
    secondTodoId: secondTodoId,
    checkedId: checkedId,
    doneId: doneId,
  );
}

Future<void> _pumpData(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 300));
}

class _JoinedUiFixture {
  const _JoinedUiFixture({
    required this.tripId,
    required this.memberId,
    required this.categoryId,
    required this.todoId,
    required this.secondTodoId,
    required this.checkedId,
    required this.doneId,
  });

  final String tripId;
  final String memberId;
  final String categoryId;
  final String todoId;
  final String secondTodoId;
  final String checkedId;
  final String doneId;
}
