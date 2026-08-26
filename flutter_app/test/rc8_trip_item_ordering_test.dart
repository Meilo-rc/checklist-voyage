import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';

void main() {
  testWidgets(
    'tap simple, double tap, tri et dispose restent sûrs à 360 px sombre',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final database = AppDatabase(NativeDatabase.memory());
      final library = DriftLibraryRepository(database);
      final ownerId = await library.createOwner(
        name: 'Jenna',
        kind: LibraryOwnerKind.familyMember,
        generationRole: GenerationRole.participant,
      );
      await database.customStatement(
        'UPDATE library_owners SET icon = ? WHERE id = ?',
        ['female', ownerId],
      );
      final sourceCategoryId = await library.createCategory(
        ownerId,
        'Vêtements',
      );
      await library.setCategoryIcon(sourceCategoryId, 'clothes');
      for (final name in [
        'A simple',
        'B double',
        'C à préparer',
        'D à préparer',
        'E quitter',
        'F prêt',
        'G prêt',
        'H rangé',
        'I rangé',
      ]) {
        await library.createItem(
          categoryId: sourceCategoryId,
          name: name,
          defaultQuantity: 1,
        );
      }
      final dependencies = await AppDependencies.create(
        database: database,
        autoSync: false,
      );
      final tripId = await dependencies.trips.createTrip(
        CreateTripRequest(
          name: 'Tri RC8',
          destination: 'Test',
          startDate: null,
          endDate: null,
          participantOwnerIds: {ownerId},
          transportOwnerIds: const {},
          lodgingOwnerIds: const {},
          includeEssentials: false,
        ),
      );
      var trip = (await dependencies.trips.watchTrip(tripId).first)!;
      final member = trip.members.single;
      final category = member.categories.single;
      final byName = {for (final item in category.items) item.name: item.id};
      for (final name in ['F prêt', 'G prêt']) {
        await dependencies.trips.cycleItemStatus(byName[name]!);
      }
      for (final name in ['H rangé', 'I rangé']) {
        await dependencies.trips.cycleItemStatus(byName[name]!);
        await dependencies.trips.cycleItemStatus(byName[name]!);
      }

      await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
      await _pumpData(tester);
      await tester.tap(find.byKey(Key('trip-summary-$tripId')));
      await _pumpData(tester);
      expect(find.byKey(const Key('trip-person-filters')), findsNothing);
      expect(find.byKey(Key('trip-member-icon-${member.id}')), findsOneWidget);
      await tester.tap(find.byKey(Key('trip-member-${member.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('trip-category-${category.id}')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(Key('trip-category-icon-${category.id}')),
        findsOneWidget,
      );
      final block = find.byKey(
        Key('trip-category-items-surface-${category.id}'),
      );
      expect(
        find.descendant(
          of: block,
          matching: find.byKey(Key('trip-category-${category.id}')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: block,
          matching: find.byKey(Key('trip-add-item-collapsed-${category.id}')),
        ),
        findsOneWidget,
      );

      final simpleId = byName['A simple']!;
      final simpleRow = find.byKey(Key('trip-item-$simpleId'));
      final simpleStart = tester.getTopLeft(simpleRow).dy;
      await tester.tap(find.byKey(Key('trip-item-status-$simpleId')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(await _storedStatus(database, simpleId), 'checked');
      expect(tester.getTopLeft(simpleRow).dy, simpleStart);
      expect(
        find.descendant(
          of: simpleRow,
          matching: find.byKey(const ValueKey('trip-status-shape-checked')),
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 360));
      expect(
        tester.getTopLeft(simpleRow).dy,
        greaterThan(
          tester
              .getTopLeft(find.byKey(Key('trip-item-${byName['E quitter']}')))
              .dy,
        ),
      );
      expect(
        tester.getTopLeft(simpleRow).dy,
        lessThan(
          tester
              .getTopLeft(find.byKey(Key('trip-item-${byName['F prêt']}')))
              .dy,
        ),
      );

      final doubleId = byName['B double']!;
      final doubleRow = find.byKey(Key('trip-item-$doubleId'));
      final doubleStart = tester.getTopLeft(doubleRow).dy;
      await tester.tap(find.byKey(Key('trip-item-status-$doubleId')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(await _storedStatus(database, doubleId), 'checked');
      expect(tester.getTopLeft(doubleRow).dy, doubleStart);
      await tester.tap(find.byKey(Key('trip-item-status-$doubleId')));
      await tester.pump(const Duration(milliseconds: 180));
      expect(await _storedStatus(database, doubleId), 'done');
      expect(
        tester.getTopLeft(doubleRow).dy,
        greaterThan(
          tester
              .getTopLeft(find.byKey(Key('trip-item-${byName['G prêt']}')))
              .dy,
        ),
      );

      final checkedId = byName['F prêt']!;
      await tester.tap(find.byKey(Key('trip-item-status-$checkedId')));
      await tester.pump(const Duration(milliseconds: 180));
      expect(await _storedStatus(database, checkedId), 'done');

      final doneId = byName['H rangé']!;
      await tester.tap(find.byKey(Key('trip-item-status-$doneId')));
      await tester.pump(const Duration(milliseconds: 180));
      expect(await _storedStatus(database, doneId), 'todo');
      expect(
        tester.getTopLeft(find.byKey(Key('trip-item-$doneId'))).dy,
        lessThan(tester.getTopLeft(simpleRow).dy),
      );

      final leaveId = byName['E quitter']!;
      await tester.tap(find.byKey(Key('trip-item-status-$leaveId')));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(await _storedStatus(database, leaveId), 'checked');
      expect(tester.takeException(), isNull);

      trip = (await dependencies.trips.watchTrip(tripId).first)!;
      expect(
        trip.members.single.categories.single.items
            .singleWhere((item) => item.id == leaveId)
            .status,
        TripItemStatus.checked,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await dependencies.close();
    },
  );
}

Future<String> _storedStatus(AppDatabase database, String itemId) async =>
    (await database.select(database.tripItems).get())
        .singleWhere((item) => item.id == itemId)
        .status;

Future<void> _pumpData(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 300));
}
