import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/in_memory_sync_remote.dart';

void main() {
  testWidgets('voyages actifs, archives et préparation de duplication', (
    tester,
  ) async {
    await _narrowScreen(tester);
    final database = AppDatabase(NativeDatabase.memory());
    final dependencies = await AppDependencies.create(
      database: database,
      syncRemote: InMemorySyncRemote(),
      documentRemote: InMemorySharedDocumentRemote(),
      autoSync: false,
    );
    final futureId = await dependencies.trips.createTrip(
      CreateTripRequest(
        name: 'Voyage futur',
        destination: 'Annecy',
        startDate: DateTime(2027, 6, 1),
        endDate: DateTime(2027, 6, 8),
        participantOwnerIds: const {},
        transportOwnerIds: const {},
        lodgingOwnerIds: const {},
        includeEssentials: false,
      ),
    );
    final pastId = await dependencies.trips.createTrip(
      CreateTripRequest(
        name: 'Voyage terminé',
        destination: 'Nice',
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 6, 8),
        participantOwnerIds: const {},
        transportOwnerIds: const {},
        lodgingOwnerIds: const {},
        includeEssentials: false,
      ),
    );

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await _showListBody(tester);
    expect(find.byKey(Key('trip-summary-$futureId')), findsOneWidget);
    expect(find.byKey(Key('trip-summary-$pastId')), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('trip-archive-tabs')),
        matching: find.text('Archives'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(Key('trip-summary-$futureId')), findsNothing);
    expect(find.byKey(Key('trip-summary-$pastId')), findsOneWidget);

    await tester.tap(find.byKey(Key('trip-summary-$pastId')));
    await _pumpData(tester);
    await tester.tap(find.byKey(const Key('trip-actions')));
    await tester.pumpAndSettle();
    expect(find.text('Archiver'), findsNothing);
    expect(find.text('Restaurer'), findsNothing);
    await tester.tap(find.text('Dupliquer'));
    await tester.pump(const Duration(milliseconds: 300));
    final destination = tester.widget<TextField>(
      find.byKey(const Key('trip-duplicate-destination')),
    );
    expect(destination.controller!.text, 'Nice');
    expect(find.textContaining('Structure conservée'), findsOneWidget);
    await tester.tap(find.byKey(const Key('trip-duplicate-submit')));
    await tester.pump();
    expect(find.byKey(const Key('trip-duplicate-error')), findsOneWidget);
    expect(await database.select(database.trips).get(), hasLength(2));
    await tester.tap(find.text('Annuler'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(milliseconds: 300));
    await _showListBody(tester);
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('trip-archive-tabs')),
        matching: find.text('Voyages'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(Key('trip-summary-$futureId')));
    await _pumpData(tester);
    await tester.tap(find.byKey(const Key('trip-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archiver'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      (await dependencies.trips.watchTrip(futureId).first)!.archivedAt,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('trip-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurer'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      (await dependencies.trips.watchTrip(futureId).first)!.archivedAt,
      isNull,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await dependencies.close();
  });

  testWidgets('archiver, restaurer et dupliquer une liste rapide', (
    tester,
  ) async {
    await _narrowScreen(tester);
    final database = AppDatabase(NativeDatabase.memory());
    final dependencies = await AppDependencies.create(
      database: database,
      syncRemote: InMemorySyncRemote(),
      documentRemote: InMemorySharedDocumentRemote(),
      autoSync: false,
    );
    final listId = await dependencies.quickLists.create('Liste saisonnière');
    await dependencies.quickLists.addItem(listId, 'Parapluie', quantity: 2);

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await tester.tap(find.text('Listes rapides').last);
    await _pumpData(tester);
    await _showListBody(tester);
    expect(find.byKey(Key('quick-summary-$listId')), findsOneWidget);
    await tester.tap(find.byKey(Key('quick-summary-$listId')));
    await _pumpData(tester);
    await tester.tap(find.byKey(const Key('quick-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archiver'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      (await dependencies.quickLists.watchQuickList(listId).first)!.archivedAt,
      isNotNull,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(milliseconds: 300));
    await _showListBody(tester);
    expect(find.byKey(Key('quick-summary-$listId')), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('quick-archive-tabs')),
        matching: find.text('Archives'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(Key('quick-summary-$listId')), findsOneWidget);
    await tester.tap(find.byKey(Key('quick-summary-$listId')));
    await _pumpData(tester);
    await tester.tap(find.byKey(const Key('quick-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurer'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      (await dependencies.quickLists.watchQuickList(listId).first)!.archivedAt,
      isNull,
    );

    await tester.tap(find.byKey(const Key('quick-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dupliquer'));
    await _pumpData(tester);
    expect(find.text('Liste saisonnière — copie'), findsWidgets);
    final rows = await database.select(database.quickLists).get();
    expect(rows, hasLength(2));
    final duplicate = rows.singleWhere((row) => row.id != listId);
    expect(duplicate.shareState, 'local');
    expect(duplicate.shareCode, isNull);
    expect(duplicate.remoteRecordId, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await dependencies.close();
  });
}

Future<void> _pumpData(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _showListBody(WidgetTester tester) async {
  final scroll = find.byType(CustomScrollView).first;
  await tester.drag(scroll, const Offset(0, -280));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _narrowScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
