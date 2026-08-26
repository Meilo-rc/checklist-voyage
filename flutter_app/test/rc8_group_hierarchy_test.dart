import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/core/theme/app_theme.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/features/shared/category_details_page.dart';
import 'package:checklist_voyage_v1/sync/library_sync_store.dart';

void main() {
  test(
    'icônes Groupe et Membre sont partagées, Personnel reste strictement local',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(
        database,
        syncStore: LibrarySyncStore(database),
      );
      final generalId = await library.createOwner(
        name: 'Essentiels',
        kind: LibraryOwnerKind.general,
        generationRole: GenerationRole.essential,
      );
      final memberId = await library.createOwner(
        name: 'Jenna',
        kind: LibraryOwnerKind.familyMember,
        generationRole: GenerationRole.participant,
      );
      final personalId = await library.createOwner(
        name: 'Privé',
        kind: LibraryOwnerKind.personal,
        generationRole: GenerationRole.participant,
      );
      await database.delete(database.syncOutbox).go();

      await library.setOwnerIcon(generalId, 'suitcase');
      await library.setOwnerIcon(memberId, 'female');
      await library.setOwnerIcon(personalId, 'key');

      final owners = await library.loadLibrary();
      expect(
        owners.singleWhere((owner) => owner.id == generalId).icon,
        'suitcase',
      );
      expect(
        owners.singleWhere((owner) => owner.id == memberId).icon,
        'female',
      );
      expect(
        owners.singleWhere((owner) => owner.id == personalId).icon,
        'key',
      );
      final operations = await database.select(database.syncOutbox).get();
      expect(operations, hasLength(2));
      expect(
        operations.map((operation) => operation.entityId),
        containsAll(<String>[generalId, memberId]),
      );
      expect(
        operations.any((operation) => operation.entityId == personalId),
        isFalse,
      );
      expect(
        operations.map((operation) => jsonDecode(operation.payloadJson)),
        everyElement(containsPair('icon', isNotNull)),
      );
    },
  );

  test(
    'un Groupe ajouté au Voyage reste autonome et persiste après redémarrage',
    () async {
      final temp = await Directory.systemTemp.createTemp('cv-rc8-groups-');
      addTearDown(() => temp.delete(recursive: true));
      final file = File('${temp.path}${Platform.pathSeparator}checklist.sqlite');
      var database = AppDatabase(NativeDatabase(file));
      var trips = DriftTripRepository(database);
      final tripId = await trips.createTrip(
        const CreateTripRequest(
          name: 'Voyage local',
          destination: 'Lyon',
          startDate: null,
          endDate: null,
          participantOwnerIds: {},
          transportOwnerIds: {},
          lodgingOwnerIds: {},
          includeEssentials: false,
        ),
      );
      final groupId = await trips.addGroup(
        tripId: tripId,
        groupKind: TripMemberGroupKind.general,
        name: 'Matériel photo',
        icon: 'camera',
      );
      final memberId = await trips.addGroup(
        tripId: tripId,
        groupKind: TripMemberGroupKind.family,
        name: 'Jenna',
        icon: 'female',
      );
      final personalId = await trips.addGroup(
        tripId: tripId,
        groupKind: TripMemberGroupKind.personal,
        name: 'Privé',
        icon: 'key',
      );
      final categoryId = await trips.addCategory(
        tripId: tripId,
        memberId: groupId,
        name: 'Appareils',
        icon: 'camera',
      );
      final itemId = await trips.addItem(
        tripId: tripId,
        categoryId: categoryId,
        name: 'Objectif',
      );
      await trips.renameGroup(groupId, 'Photo');
      await trips.setGroupIcon(groupId, 'video');
      await database.close();

      database = AppDatabase(NativeDatabase(file));
      trips = DriftTripRepository(database);
      final trip = (await trips.loadTrip(tripId))!;
      final group = trip.members.singleWhere((entry) => entry.id == groupId);
      expect(group.sourceOwnerId, isNull);
      expect(group.name, 'Photo');
      expect(group.icon, 'video');
      expect(group.categories.single.icon, 'camera');
      expect(group.categories.single.items.single.name, 'Objectif');
      expect(
        trip.members.singleWhere((entry) => entry.id == memberId).groupKind,
        TripMemberGroupKind.family,
      );
      expect(
        trip.members.singleWhere((entry) => entry.id == personalId).groupKind,
        TripMemberGroupKind.personal,
      );
      expect(await database.select(database.libraryOwners).get(), isEmpty);
      expect(await database.select(database.syncOutbox).get(), isEmpty);

      await trips.removeGroup(groupId);
      expect(
        (await database.select(database.tripMembers).get())
            .singleWhere((entry) => entry.id == groupId)
            .deletedAt,
        isNotNull,
      );
      expect(
        (await database.select(database.tripCategories).get())
            .singleWhere((entry) => entry.id == categoryId)
            .deletedAt,
        isNotNull,
      );
      expect(
        (await database.select(database.tripItems).get())
            .singleWhere((entry) => entry.id == itemId)
            .deletedAt,
        isNotNull,
      );
      expect(await database.select(database.libraryOwners).get(), isEmpty);
      await database.close();
    },
  );

  testWidgets(
    'le menu hiérarchique et le sélecteur restent accessibles à 360 px sombre',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(
        tester.platformDispatcher.clearPlatformBrightnessTestValue,
      );
      String? renamed;
      String? selectedIcon;
      var deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  key: const Key('open-actions'),
                  onPressed: () => showHierarchyEntityActionsSheet(
                    context,
                    entityId: 'category-1',
                    entityLabel: 'Catégorie',
                    initialName: 'Vêtements',
                    initialIcon: 'clothes',
                    onRename: (name) async => renamed = name,
                    onIconChanged: (icon) async => selectedIcon = icon,
                    onDelete: () async => deleted = true,
                  ),
                  child: const Text('Ouvrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('open-actions')));
      await tester.pumpAndSettle();

      final delete = find.byKey(
        const Key('hierarchy-delete-category-1'),
      );
      expect(delete, findsOneWidget);
      expect(find.ancestor(of: delete, matching: find.byType(SafeArea)),
          findsWidgets);
      expect(tester.getBottomRight(delete).dy, lessThan(800));
      await tester.enterText(
        find.byKey(const Key('hierarchy-name-category-1')),
        'Tenues',
      );
      await tester.tap(find.byKey(const Key('hierarchy-save-category-1')));
      await tester.pumpAndSettle();
      expect(renamed, 'Tenues');
      expect(find.byKey(const Key('hierarchy-actions-category-1')), findsNothing);

      await tester.tap(find.byKey(const Key('open-actions')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hierarchy-icon-category-1')));
      await tester.pumpAndSettle();
      final grid = tester.widget<GridView>(
        find.byKey(const Key('hierarchy-icon-grid')),
      );
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        6,
      );
      await tester.tap(
        find.byKey(const Key('hierarchy-icon-choice-beach')),
      );
      await tester.pumpAndSettle();
      expect(selectedIcon, 'beach');
      expect(find.byKey(const Key('hierarchy-actions-category-1')), findsNothing);

      await tester.tap(find.byKey(const Key('open-actions')));
      await tester.pumpAndSettle();
      expect(delete, findsOneWidget);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('le tiroir reste ouvert si le nom ou l’icône échoue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              key: const Key('open-failing-actions'),
              onPressed: () => showHierarchyEntityActionsSheet(
                context,
                entityId: 'failure',
                entityLabel: 'Catégorie',
                initialName: 'Erreur',
                initialIcon: 'liste',
                onRename: (_) async => throw StateError('échec nom'),
                onIconChanged: (_) async => throw StateError('échec icône'),
                onDelete: () async {},
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open-failing-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hierarchy-save-failure')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hierarchy-actions-failure')), findsOneWidget);

    await tester.tap(find.byKey(const Key('hierarchy-icon-failure')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hierarchy-icon-choice-beach')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hierarchy-actions-failure')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
