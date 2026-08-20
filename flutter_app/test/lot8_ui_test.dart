import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/in_memory_sync_remote.dart';

import 'helpers/seed_reference_library.dart';

void main() {
  testWidgets(
    'filtres combinés restent locaux sur un voyage partagé et dans la hiérarchie',
    (tester) async {
      await _narrowScreen(tester);
      final databaseA = AppDatabase(NativeDatabase.memory());
      final library = DriftLibraryRepository(databaseA);
      final ids = await seedReferenceLibrary(library);
      final remote = InMemorySharedDocumentRemote();
      final dependenciesA = await AppDependencies.create(
        database: databaseA,
        syncRemote: InMemorySyncRemote(),
        documentRemote: remote,
        autoSync: false,
      );
      final tripId = await dependenciesA.trips.createTrip(
        CreateTripRequest(
          name: 'Voyage filtré',
          destination: 'Nice',
          startDate: null,
          endDate: null,
          participantOwnerIds: {ids.participantOwner},
          transportOwnerIds: const {},
          lodgingOwnerIds: const {},
        ),
      );
      final access = await dependenciesA.sharedDocuments.shareTrip(tripId);
      expect(await databaseA.select(databaseA.syncOutbox).get(), isEmpty);
      await dependenciesA.close();
      final databaseB = AppDatabase(NativeDatabase.memory());
      final dependenciesB = await AppDependencies.create(
        database: databaseB,
        syncRemote: InMemorySyncRemote(),
        documentRemote: remote,
        autoSync: false,
      );
      await dependenciesB.sharedDocuments.join(access.shareCode);
      final trip = (await dependenciesB.trips.watchTrip(tripId).first)!;
      final alex = trip.members.singleWhere(
        (member) => member.groupKind == TripMemberGroupKind.family,
      );
      final essential = trip.members.singleWhere(
        (member) => member.name == 'Essentiel',
      );
      final alexCategory = alex.categories.single;
      final remoteOperationsBefore = remote.operations(tripId).length;
      expect(await databaseB.select(databaseB.syncOutbox).get(), isEmpty);

      await tester.pumpWidget(ChecklistApp(dependencies: dependenciesB));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byKey(Key('trip-summary-$tripId')));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -280));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('trip-state-all')), findsOneWidget);
      expect(find.byKey(const Key('trip-state-todo')), findsOneWidget);
      expect(find.byKey(const Key('trip-state-checked')), findsOneWidget);
      expect(find.byKey(const Key('trip-state-done')), findsOneWidget);
      expect(find.byKey(const Key('trip-person-all')), findsOneWidget);
      expect(find.byKey(const Key('trip-person-general')), findsOneWidget);
      expect(find.byKey(Key('trip-person-${alex.id}')), findsOneWidget);
      expect(find.text('0/2 · 0 %'), findsOneWidget);

      await tester.tap(find.byKey(Key('trip-person-${alex.id}')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(Key('trip-member-${alex.id}')), findsOneWidget);
      expect(find.byKey(Key('trip-member-${essential.id}')), findsNothing);

      await tester.tap(find.byKey(Key('trip-member-${alex.id}')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('trip-member-page-${alex.id}')), findsOneWidget);
      await tester.tap(find.byKey(Key('trip-category-${alexCategory.id}')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(Key('trip-category-page-${alexCategory.id}')),
        findsOneWidget,
      );
      expect(find.text('T-shirt'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('trip-state-all')),
        const Offset(-180, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trip-state-done')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const Key('trip-filter-empty')), findsOneWidget);
      expect(find.text('Aucun élément rangé pour Alex.'), findsOneWidget);
      expect(find.text('0/2 · 0 %'), findsOneWidget);

      await tester.tap(find.byKey(const Key('trip-person-general')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const Key('trip-filter-empty')), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('trip-state-done')),
        const Offset(180, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trip-state-todo')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(Key('trip-member-${essential.id}')), findsOneWidget);

      expect(await databaseB.select(databaseB.syncOutbox).get(), isEmpty);
      expect(remote.operations(tripId), hasLength(remoteOperationsBefore));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      await dependenciesB.close();
    },
  );

  testWidgets('rendu stable avec 120 items sur un écran étroit', (
    tester,
  ) async {
    await _narrowScreen(tester);
    final database = AppDatabase(NativeDatabase.memory());
    final library = DriftLibraryRepository(database);
    final owner = await library.createOwner(
      name: 'Famille nombreuse',
      kind: LibraryOwnerKind.familyMember,
      generationRole: GenerationRole.participant,
    );
    final category = await library.createCategory(owner, 'Grande catégorie');
    for (var index = 0; index < 120; index++) {
      await library.createItem(
        categoryId: category,
        name: 'Objet ${index.toString().padLeft(3, '0')}',
        defaultQuantity: 1,
      );
    }
    final dependencies = await AppDependencies.create(
      database: database,
      syncRemote: InMemorySyncRemote(),
      documentRemote: InMemorySharedDocumentRemote(),
      autoSync: false,
    );
    await dependencies.trips.createTrip(
      CreateTripRequest(
        name: 'Grand voyage',
        destination: '',
        startDate: null,
        endDate: null,
        participantOwnerIds: {owner},
        transportOwnerIds: const {},
        lodgingOwnerIds: const {},
        includeEssentials: false,
      ),
    );

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Grand voyage'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -280));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('0/120 · 0 %'), findsOneWidget);
    expect(find.byKey(const Key('trip-state-todo')), findsOneWidget);
    expect(find.byKey(const Key('trip-person-filters')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await dependencies.close();
  });
}

Future<void> _narrowScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
