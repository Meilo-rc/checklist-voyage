import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/core/presentation/user_message.dart';
import 'package:checklist_voyage_v1/core/theme/app_theme.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/features/shared/item_contexts_sheet.dart';

import 'helpers/seed_reference_library.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('les erreurs techniques restent cachées', () {
    expect(userMessageFor(ArgumentError('Nom requis')), 'Nom requis');
    expect(userMessageFor(StateError('Code incorrect.')), 'Code incorrect.');
    expect(
      userMessageFor(Exception('SocketException: secret technique')),
      'Impossible d’effectuer cette action.',
    );
  });

  testWidgets('Retour Android remonte une liste puis quitte les archives', (
    tester,
  ) async {
    await _narrowScreen(tester);
    final dependencies = await AppDependencies.create(
      database: AppDatabase(NativeDatabase.memory()),
    );
    final listId = await dependencies.quickLists.create('Départ plage');
    await dependencies.quickLists.addItem(listId, 'Serviette');
    final archivedId = await dependencies.quickLists.create('Ancienne liste');
    await dependencies.quickLists.archive(archivedId);

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await tester.tap(find.text('Listes rapides').last);
    await _pumpData(tester);
    await tester.tap(find.byKey(Key('quick-summary-$listId')));
    await _pumpData(tester);
    expect(find.byKey(Key('quick-detail-$listId')), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick-lists-root')), findsOneWidget);
    expect(find.byKey(Key('quick-summary-$listId')), findsOneWidget);

    await tester.tap(find.byKey(const Key('quick-root-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archives'));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('quick-summary-$archivedId')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(Key('quick-summary-$listId')), findsOneWidget);
    expect(find.byKey(const Key('quick-create')), findsOneWidget);

    await _dispose(tester, dependencies);
  });

  testWidgets('Retour Android quitte les archives Voyages sans fermer', (
    tester,
  ) async {
    await _narrowScreen(tester);
    final dependencies = await AppDependencies.create(
      database: AppDatabase(NativeDatabase.memory()),
    );
    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);

    await tester.tap(find.byKey(const Key('trip-root-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archives'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune archive'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trip-fab-menu')), findsOneWidget);
    expect(find.text('Aucun voyage actif'), findsOneWidget);

    await _dispose(tester, dependencies);
  });

  testWidgets(
    'Retour Android respecte les hiérarchies Voyage et Bibliothèque',
    (tester) async {
      await _narrowScreen(tester);
      final database = AppDatabase(NativeDatabase.memory());
      final ids = await seedReferenceLibrary(DriftLibraryRepository(database));
      final dependencies = await AppDependencies.create(database: database);
      final tripId = await dependencies.trips.createTrip(
        CreateTripRequest(
          name: 'Navigation',
          destination: 'Lyon',
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 1)),
          participantOwnerIds: {ids.participantOwner},
          transportOwnerIds: {ids.flightOwner},
          lodgingOwnerIds: {ids.hotelOwner},
        ),
      );
      final alexTripMember = (await dependencies.trips.watchTrip(tripId).first)!
          .members
          .singleWhere((member) => member.name == 'Alex');

      await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
      await _pumpData(tester);
      await tester.tap(find.byKey(Key('trip-summary-$tripId')));
      await _pumpData(tester);
      await tester.tap(find.byKey(Key('trip-member-${alexTripMember.id}')));
      await tester.pumpAndSettle();
      expect(find.text('Vêtements'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('trip-overview')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(Key('trip-summary-$tripId')), findsOneWidget);

      await tester.tap(find.text('Bibliothèque'));
      await _pumpData(tester);
      await tester.tap(find.byKey(const Key('library-root-general')));
      await tester.pumpAndSettle();
      expect(find.text('Documents'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('library-root-members')), findsOneWidget);

      await tester.tap(find.byKey(const Key('library-root-members')));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(Key('library-member-${ids.participantOwner}')),
        const Offset(280, 0),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('library-inline-rename-field')),
        findsOneWidget,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('library-inline-rename-field')),
        findsNothing,
      );
      expect(find.byKey(const Key('library-members-page')), findsOneWidget);
      await tester.tap(find.text('Alex'));
      await tester.pumpAndSettle();
      expect(find.text('Vêtements'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('library-members-page')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('library-root-personal')), findsOneWidget);

      await tester.tap(find.byKey(const Key('library-root-personal')));
      await tester.pumpAndSettle();
      expect(find.text('Personnel'), findsWidgets);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('library-root-general')), findsOneWidget);

      await _dispose(tester, dependencies);
    },
  );

  testWidgets('les ajouts rapides successifs conservent le focus', (
    tester,
  ) async {
    await _narrowScreen(tester);
    final dependencies = await AppDependencies.create(
      database: AppDatabase(NativeDatabase.memory()),
    );
    final listId = await dependencies.quickLists.create('Courses');

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    await tester.tap(find.text('Listes rapides').last);
    await _pumpData(tester);
    await tester.tap(find.byKey(Key('quick-summary-$listId')));
    await _pumpData(tester);
    await tester.ensureVisible(find.byKey(const Key('quick-add-item')));
    await tester.tap(find.text('Ajouter un item'));
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('quick-add-item-input'));
    await tester.enterText(field, '  Pain  ');
    await tester.tap(find.byKey(const Key('quick-add-item-submit')));
    await _pumpData(tester);
    expect(field, findsOneWidget);
    expect(Focus.of(tester.element(field)).hasFocus, isTrue);

    await tester.enterText(field, 'Lait');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpData(tester);
    final list = await dependencies.quickLists.watchQuickList(listId).first;
    expect(
      list!.items.map((item) => item.name),
      unorderedEquals(['Pain', 'Lait']),
    );

    await _dispose(tester, dependencies);
  });

  testWidgets('la feuille Contextes défile et peut être annulée en sombre', (
    tester,
  ) async {
    await _narrowScreen(tester, brightness: Brightness.dark);
    Set<String>? result = const {'non modifié'};
    final contexts = List.generate(
      36,
      (index) => ContextModel(
        id: 'context-$index',
        name: 'Contexte très long numéro $index',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showItemContextsSheet(
                    context,
                    itemName: 'Lunettes de soleil au nom très long',
                    contexts: contexts,
                    initialSelection: const {},
                  );
                },
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-contexts-scroll')), findsOneWidget);
    expect(find.byKey(const Key('context-save-item')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('context-choice-context-35')),
      220,
      scrollable: find.descendant(
        of: find.byKey(const Key('item-contexts-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(const Key('context-choice-context-35')));
    await tester.tap(find.byKey(const Key('context-cancel-item')));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('l’écran racine supporte rotation et texte agrandi', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final dependencies = await AppDependencies.create(
      database: AppDatabase(NativeDatabase.memory()),
    );
    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await _pumpData(tester);
    expect(find.text('Voyages'), findsWidgets);
    expect(find.text('Bibliothèque'), findsOneWidget);
    expect(find.text('Listes rapides'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _dispose(tester, dependencies);
  });
}

Future<void> _narrowScreen(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
}) async {
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
  await tester.pump(const Duration(milliseconds: 1));
}
