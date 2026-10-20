import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/core/theme/app_theme.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_context_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/features/shared/date_range_label.dart';
import 'package:checklist_voyage_v1/features/trips/trip_form.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/in_memory_sync_remote.dart';

import 'helpers/seed_reference_library.dart';
import 'helpers/city_test_weather.dart';

void main() {
  testWidgets('socle V1 et état Voyages vide restent compacts à 360 px', (
    tester,
  ) async {
    await _narrowScreen(tester);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final database = AppDatabase(NativeDatabase.memory());
    final dependencies = await AppDependencies.create(
      database: database,
      autoSync: false,
    );

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);

    expect(find.text('Voyages'), findsWidgets);
    expect(find.text('Aucun voyage actif'), findsOneWidget);
    expect(find.text('Checklist Voyage'), findsOneWidget);
    expect(find.byKey(const Key('trip-home-hero')), findsOneWidget);
    expect(find.byKey(const Key('trip-fab-menu')), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byKey(const Key('trip-root-menu')), findsOneWidget);
    expect(find.text('Bibliothèque'), findsOneWidget);
    expect(find.text('Listes rapides'), findsOneWidget);
    expect(AppColors.primary, const Color(0xFF44C3F8));
    expect(AppColors.pink, const Color(0xFFE71345));
    expect(AppColors.yellow, const Color(0xFFF8AC34));
    await tester.tap(find.byKey(const Key('trip-fab-menu')));
    await tester.pumpAndSettle();
    expect(find.text('Créer un voyage'), findsOneWidget);
    expect(find.text('Rejoindre avec un code'), findsOneWidget);
    await tester.tapAt(const Offset(8, 120));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Aucun voyage actif'))).brightness,
      Brightness.light,
    );
    expect(tester.takeException(), isNull);

    await _dispose(tester, dependencies);
  });

  testWidgets('le thème sombre global reste lisible et stable à 360 px', (
    tester,
  ) async {
    await _narrowScreen(tester);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final database = AppDatabase(NativeDatabase.memory());
    final dependencies = await AppDependencies.create(
      database: database,
      autoSync: false,
    );

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);

    final theme = Theme.of(tester.element(find.text('Aucun voyage actif')));
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.surface.computeLuminance(), lessThan(0.05));
    expect(find.text('Voyages'), findsWidgets);
    expect(find.byKey(const Key('trip-fab-menu')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _dispose(tester, dependencies);
  });

  testWidgets(
    'cartes actives, partagées et archives restent synthétiques et ouvrables',
    (tester) async {
      await _narrowScreen(tester);
      final database = AppDatabase(NativeDatabase.memory());
      final library = DriftLibraryRepository(database);
      final ids = await seedReferenceLibrary(library);
      final dependencies = await AppDependencies.create(
        database: database,
        syncRemote: InMemorySyncRemote(),
        documentRemote: InMemorySharedDocumentRemote(),
        autoSync: false,
      );
      final today = DateTime.now();
      final ongoingId = await dependencies.trips.createTrip(
        CreateTripRequest(
          name: 'Séjour familial',
          destination: 'Une destination au nom volontairement très long',
          startDate: today.subtract(const Duration(days: 1)),
          endDate: today.add(const Duration(days: 2)),
          participantOwnerIds: {ids.participantOwner},
          transportOwnerIds: {ids.flightOwner, ids.trainOwner},
          lodgingOwnerIds: {ids.hotelOwner, ids.campingOwner},
        ),
      );
      final futureId = await dependencies.trips.createTrip(
        CreateTripRequest(
          name: 'Prochain départ',
          destination: 'Annecy',
          startDate: today.add(const Duration(days: 5)),
          endDate: today.add(const Duration(days: 8)),
          participantOwnerIds: const {},
          transportOwnerIds: const {},
          lodgingOwnerIds: const {},
          includeEssentials: false,
        ),
      );
      final pastId = await dependencies.trips.createTrip(
        CreateTripRequest(
          name: 'Ancien séjour',
          destination: 'Nice',
          startDate: today.subtract(const Duration(days: 8)),
          endDate: today.subtract(const Duration(days: 4)),
          participantOwnerIds: const {},
          transportOwnerIds: const {},
          lodgingOwnerIds: const {},
          includeEssentials: false,
        ),
      );
      await dependencies.sharedDocuments.shareTrip(ongoingId);
      final ongoing = (await dependencies.trips.watchTrip(ongoingId).first)!;
      final items = ongoing.members
          .expand((member) => member.categories)
          .expand((category) => category.items)
          .toList(growable: false);
      for (final item in items) {
        await dependencies.trips.cycleItemStatus(item.id);
        await dependencies.trips.cycleItemStatus(item.id);
      }

      await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
      await _pumpData(tester);

      expect(find.byKey(Key('trip-summary-$ongoingId')), findsOneWidget);
      expect(find.byKey(Key('trip-summary-$futureId')), findsOneWidget);
      expect(find.byKey(Key('trip-summary-$pastId')), findsNothing);
      expect(
        find.text('Une destination au nom volontairement très long'),
        findsOneWidget,
      );
      expect(find.text('En cours'), findsOneWidget);
      expect(find.textContaining('Dans '), findsNothing);
      expect(
        find.text(
          compactTripPeriodLabel(
            today.subtract(const Duration(days: 1)),
            today.add(const Duration(days: 2)),
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Partagé'), findsNothing);
      expect(find.textContaining('Trajet - Avion'), findsNothing);
      expect(
        find.text('${items.length}/${items.length} · 100 %'),
        findsOneWidget,
      );
      expect(find.text('0/0 · 0 %'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('${items.length}/${items.length} · 100 %'),
            matching: find.byType(Row),
          ),
          matching: find.byType(LinearProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(find.byKey(Key('trip-summary-actions-$ongoingId')), findsNothing);
      expect(tester.takeException(), isNull);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(Key('trip-summary-$ongoingId')));
      await _pumpData(tester);
      expect(find.byKey(const Key('trip-overview')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await _pumpData(tester);

      await tester.tap(find.byKey(const Key('trip-root-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archives'));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('trip-summary-$pastId')), findsOneWidget);
      expect(find.text('Terminé'), findsNothing);
      expect(tester.takeException(), isNull);

      await _dispose(tester, dependencies);
    },
  );

  testWidgets(
    'formulaire unique : période, multisélections sans coche ni création annexe, puis édition',
    (tester) async {
      await _narrowScreen(tester);
      final database = AppDatabase(NativeDatabase.memory());
      final library = DriftLibraryRepository(database);
      final ids = await seedReferenceLibrary(library);
      final extraParticipants = <String>[];
      for (final name in [
        'Camille',
        'Dominique au prénom volontairement très long',
        'Noa',
      ]) {
        extraParticipants.add(
          await library.createOwner(
            name: name,
            kind: LibraryOwnerKind.familyMember,
            generationRole: GenerationRole.participant,
          ),
        );
      }
      final contexts = DriftContextRepository(database);
      final beach = await contexts.createContext('Plage');
      final hiking = await contexts.createContext('Randonnée');
      final longActivity = await contexts.createContext(
        'Découverte des sentiers côtiers au coucher du soleil',
      );
      final dependencies = await AppDependencies.create(
        weather: cityTestWeather(),
        database: database,
        autoSync: false,
      );
      final syncCountBefore =
          (await database.select(database.syncOutbox).get()).length;

      await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
      await _pumpData(tester);
      await tester.tap(find.byKey(const Key('trip-fab-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Créer un voyage'));
      await tester.pumpAndSettle();

      expect(find.byType(TripForm), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byKey(const Key('trip-destination')), findsOneWidget);
      expect(find.byKey(const Key('trip-date-range')), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNothing);
      expect(
        find.descendant(
          of: find.byType(TripForm),
          matching: find.byIcon(Icons.add),
        ),
        findsNothing,
      );

      await tester.enterText(
        find.byKey(const Key('trip-destination')),
        'La Rochelle',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('city-suggestion-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trip-date-range')));
      await tester.pumpAndSettle();
      expect(find.byType(DateRangePickerDialog), findsOneWidget);
      final today = DateTime.now();
      final startDay = today.day <= 26 ? today.day + 1 : today.day - 3;
      final endDay = today.day <= 26 ? today.day + 3 : today.day - 1;
      await tester.tap(
        find
            .descendant(
              of: find.byType(DateRangePickerDialog),
              matching: find.text('$startDay'),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(
              of: find.byType(DateRangePickerDialog),
              matching: find.text('$endDay'),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider').last);
      await tester.pumpAndSettle();
      final startDate = DateTime(today.year, today.month, startDay);
      final endDate = DateTime(today.year, today.month, endDay);
      expect(
        find.text(compactDateRangeLabel(startDate, endDate)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      final selections = <(String, String)>[
        (ids.participantOwner, 'Alex'),
        (ids.flightOwner, 'Trajet - Avion'),
        (ids.trainOwner, 'Trajet - Train'),
        (ids.hotelOwner, 'Logement - Hôtel'),
        (ids.campingOwner, 'Logement - Camping'),
        (beach, 'Plage'),
        (hiking, 'Randonnée'),
        (longActivity, 'Découverte des sentiers côtiers au coucher du soleil'),
        ...extraParticipants.map(
          (id) => (
            id,
            id == extraParticipants[1]
                ? 'Dominique au prénom volontairement très long'
                : id == extraParticipants[0]
                ? 'Camille'
                : 'Noa',
          ),
        ),
      ];
      for (final (id, label) in selections) {
        final chip = find.byKey(Key('trip-choice-$id'));
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        final selected = tester.widget<ChoiceChip>(chip);
        expect(selected.selected, isTrue);
        expect(selected.showCheckmark, isFalse);
      }
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('trip-submit')));
      await tester.tap(find.byKey(const Key('trip-submit')));
      await _pumpData(tester);

      final trips = await database.select(database.trips).get();
      expect(trips, hasLength(1));
      final tripId = trips.single.id;
      final storedChoices = await database
          .select(database.tripGenerationChoices)
          .get();
      expect(
        storedChoices.where((choice) => choice.choiceKind == 'transport'),
        hasLength(2),
      );
      expect(
        storedChoices.where((choice) => choice.choiceKind == 'lodging'),
        hasLength(2),
      );
      expect(
        storedChoices.where((choice) => choice.choiceKind == 'context'),
        hasLength(3),
      );
      expect(
        storedChoices.where((choice) => choice.choiceKind == 'participant'),
        hasLength(4),
      );

      await tester.tap(find.byKey(const Key('trip-actions')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Modifier le voyage'), findsOneWidget);
      final participantChip = tester.widget<ChoiceChip>(
        find.byKey(Key('trip-choice-${ids.participantOwner}')),
      );
      expect(participantChip.selected, isTrue);
      expect(participantChip.onSelected, isNull);
      final destinationField = tester.widget<TextField>(
        find.byKey(const Key('trip-destination')),
      );
      expect(destinationField.controller!.text, 'La Rochelle');
      await tester.enterText(
        find.byKey(const Key('trip-destination')),
        'Île de Ré',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('city-suggestion-0')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('trip-submit')));
      await tester.tap(find.byKey(const Key('trip-submit')));
      await _pumpData(tester);
      final edited = (await dependencies.trips.watchTrip(tripId).first)!;
      expect(edited.destination, 'Île de Ré');
      expect(
        await database.select(database.tripGenerationChoices).get(),
        hasLength(storedChoices.length),
      );
      expect(
        (await database.select(database.syncOutbox).get()).length,
        syncCountBefore,
      );
      expect(tester.takeException(), isNull);

      await _dispose(tester, dependencies);
    },
  );

  testWidgets('l’ajout d’item reste inline et les actions passent par swipe', (
    tester,
  ) async {
    await _narrowScreen(tester);
    final database = AppDatabase(NativeDatabase.memory());
    final library = DriftLibraryRepository(database);
    final ownerId = await library.createOwner(
      name: 'Général compact',
      kind: LibraryOwnerKind.general,
      generationRole: GenerationRole.general,
    );
    final categoryId = await library.createCategory(ownerId, 'Accessoires');
    final dependencies = await AppDependencies.create(
      database: database,
      autoSync: false,
    );

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await tester.tap(find.text('Bibliothèque'));
    await _pumpData(tester);
    await tester.tap(find.byKey(Key('library-member-$ownerId')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('library-category-$categoryId')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('library-add-item-collapsed-$categoryId')));
    await tester.pumpAndSettle();
    final field = find.byKey(Key('library-add-item-$categoryId'));
    expect(field, findsOneWidget);
    await tester.enterText(field, 'Lunettes de soleil');
    await tester.tap(find.byKey(Key('library-add-item-submit-$categoryId')));
    await tester.pumpAndSettle();

    final stored = await database.select(database.libraryItems).getSingle();
    expect(stored.name, 'Lunettes de soleil');
    expect(stored.defaultQuantity, 1);
    expect(find.byType(AlertDialog), findsNothing);
    final itemRow = find.byKey(Key('library-item-${stored.id}'));
    expect(itemRow, findsOneWidget);

    await tester.drag(itemRow, const Offset(260, 0));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    final editField = find.byKey(const Key('library-inline-rename-field'));
    await tester.enterText(editField, 'Lunettes polarisées');
    await tester.tap(find.byTooltip('Valider'));
    await tester.pumpAndSettle();
    expect(
      (await database.select(database.libraryItems).getSingle()).name,
      'Lunettes polarisées',
    );

    await tester.drag(
      find.byKey(Key('library-item-${stored.id}')),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();
    expect(
      (await database.select(database.libraryItems).getSingle()).deletedAt,
      isNotNull,
    );
    expect(tester.takeException(), isNull);

    await _dispose(tester, dependencies);
  });
}

Future<void> _pumpData(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _narrowScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _dispose(WidgetTester tester, AppDependencies dependencies) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await dependencies.close();
}
