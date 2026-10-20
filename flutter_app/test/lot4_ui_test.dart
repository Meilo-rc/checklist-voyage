import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_context_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';

import 'helpers/seed_reference_library.dart';
import 'helpers/city_test_weather.dart';

void main() {
  testWidgets(
    'parcours voyage et liste rapide utilisables sur un écran Android étroit',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final database = AppDatabase(NativeDatabase.memory());
      final library = DriftLibraryRepository(database);
      final ids = await seedReferenceLibrary(library);
      final contexts = DriftContextRepository(database);
      final beach = await contexts.createContext('Plage');
      await contexts.setItemContexts(ids.passportItem, {beach});
      final dependencies = await AppDependencies.create(
        database: database,
        weather: cityTestWeather(),
      );

      await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trip-fab-menu')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Créer un voyage'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.byKey(const Key('trip-destination')),
        'Grenoble',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('city-suggestion-0')));
      await tester.pumpAndSettle();
      final choices = <String>[
        'Alex',
        'Trajet - Avion',
        'Trajet - Train',
        'Logement - Hôtel',
        'Logement - Camping',
        'Plage',
      ];
      for (final choice in choices) {
        final target = find.widgetWithText(ChoiceChip, choice);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(find.text(choice).last);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('trip-submit')));
      await tester.tap(find.byKey(const Key('trip-submit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      expect(find.text('Grenoble'), findsWidgets);
      expect(find.text('Essentiel'), findsOneWidget);
      expect(find.text('Alex'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Trajet - Train'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Trajet - Avion'), findsOneWidget);
      expect(find.text('Trajet - Train'), findsOneWidget);
      final contextChoices = await database
          .select(database.tripGenerationChoices)
          .get();
      expect(
        contextChoices.any(
          (choice) =>
              choice.choiceKind == 'context' && choice.choiceId == beach,
        ),
        isTrue,
      );

      await tester.tap(find.text('Listes rapides').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quick-create')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('quick-name-input')),
        'Liste UI',
      );
      await tester.tap(find.byKey(const Key('quick-name-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quick-add-item')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('quick-add-item-input')),
        'Maillot',
      );
      await tester.tap(find.byKey(const Key('quick-add-item-submit')));
      await tester.pumpAndSettle();
      expect(
        await database.select(database.quickListItems).get(),
        hasLength(1),
      );
      await tester.drag(
        find.byType(CustomScrollView).last,
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();

      expect(find.text('Liste UI'), findsWidgets);
      expect(find.text('Maillot'), findsOneWidget);
      final item = await database.select(database.quickListItems).getSingle();
      expect(find.byKey(Key('quick-item-plus-${item.id}')), findsOneWidget);
      expect(find.text('Quantité'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await dependencies.close();
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
