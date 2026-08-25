import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/core/theme/app_theme.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/features/shared/category_details_page.dart';

void main() {
  test(
    'les icônes de la Bibliothèque restent dans le modèle réutilisable',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final ownerId = await library.createOwner(
        name: 'Malone',
        kind: LibraryOwnerKind.familyMember,
        generationRole: GenerationRole.participant,
      );
      final categoryId = await library.createCategory(ownerId, 'Vêtements');

      await library.setCategoryIcon(categoryId, 'clothes');

      final owner = (await library.loadLibrary()).single;
      expect(owner.categories.single.icon, 'clothes');
    },
  );

  test(
    'ajouter et personnaliser une catégorie de voyage ne modifie pas la Bibliothèque',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final participantId = await library.createOwner(
        name: 'Malone',
        kind: LibraryOwnerKind.familyMember,
        generationRole: GenerationRole.participant,
      );
      final sourceCategoryId = await library.createCategory(
        participantId,
        'Vêtements',
      );
      await library.setCategoryIcon(sourceCategoryId, 'clothes');
      await library.createItem(
        categoryId: sourceCategoryId,
        name: 'T-shirt',
        defaultQuantity: 1,
      );
      final trips = DriftTripRepository(database);
      final tripId = await trips.createTrip(
        CreateTripRequest(
          name: 'Test RC4',
          destination: 'Annecy',
          startDate: null,
          endDate: null,
          participantOwnerIds: {participantId},
          transportOwnerIds: const {},
          lodgingOwnerIds: const {},
          includeEssentials: false,
        ),
      );
      final participant = (await trips.loadTrip(tripId))!.members.single;

      final addedId = await trips.addCategory(
        tripId: tripId,
        memberId: participant.id,
        name: 'Santé',
      );
      await trips.setCategoryIcon(addedId, 'first-aid');

      final updatedTrip = (await trips.loadTrip(tripId))!;
      final added = updatedTrip.members.single.categories.singleWhere(
        (category) => category.id == addedId,
      );
      expect(added.name, 'Santé');
      expect(added.icon, 'first-aid');
      expect(added.items, isEmpty);
      final sourceOwner = (await library.loadLibrary()).single;
      expect(sourceOwner.categories, hasLength(1));
      expect(sourceOwner.categories.single.name, 'Vêtements');
      expect(sourceOwner.categories.single.icon, 'clothes');
    },
  );

  testWidgets(
    'Détails catégorie permet nom, icône et suppression à 360 px sombre',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? renamed;
      String? selectedIcon;
      var deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: CategoryDetailsPage(
            categoryId: 'category-1',
            initialName: 'Vêtements',
            initialIcon: 'clothes',
            onRename: (name) async => renamed = name,
            onIconChanged: (icon) async => selectedIcon = icon,
            onDelete: () async => deleted = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Détails catégorie'), findsOneWidget);
      expect(find.byKey(const Key('category-icon-grid')), findsOneWidget);
      await tester.tap(find.byKey(const Key('category-icon-beach')));
      await tester.pumpAndSettle();
      expect(selectedIcon, 'beach');
      await tester.enterText(
        find.byKey(const Key('category-details-name')),
        'Tenues',
      );
      await tester.tap(find.byKey(const Key('category-details-save')));
      await tester.pumpAndSettle();
      expect(renamed, 'Tenues');
      await tester.scrollUntilVisible(
        find.byKey(const Key('category-details-delete')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('category-details-delete')));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  test('le contenu est agrandi sans grossir les titres et la navigation', () {
    final theme = AppTheme.light;
    expect(theme.textTheme.bodyMedium!.fontSize, closeTo(16.8, 0.01));
    expect(theme.appBarTheme.titleTextStyle!.fontSize, 22);
    expect(theme.navigationBarTheme.labelTextStyle!.resolve({})!.fontSize, 12);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF0F2F4));
    expect(theme.cardTheme.color, Colors.white);
  });
}
