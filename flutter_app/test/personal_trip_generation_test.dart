import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/features/trips/trip_form.dart';

void main() {
  test(
    'seules les catégories Personnel choisies alimentent le voyage local',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _seedPersonalLibrary(database);
      final trips = DriftTripRepository(database);

      final tripId = await trips.createTrip(
        CreateTripRequest(
          name: 'Voyage personnel',
          destination: 'Annecy',
          startDate: null,
          endDate: null,
          participantOwnerIds: {fixture.participantId},
          transportOwnerIds: const {},
          lodgingOwnerIds: const {},
          personalCategoryIds: {fixture.selectedCategoryId},
          includeEssentials: false,
        ),
      );
      final trip = (await trips.loadTrip(tripId))!;

      expect(trip.selectedPersonalCategoryIds, {fixture.selectedCategoryId});
      final personal = trip.members.singleWhere(
        (member) => member.groupKind == TripMemberGroupKind.personal,
      );
      expect(personal.groupKind, TripMemberGroupKind.personal);
      expect(personal.categories.single.items.single.name, 'Lunettes privées');
      expect(
        personal.categories
            .expand((category) => category.items)
            .map((item) => item.name),
        isNot(contains('Clés')),
      );
      expect(
        personal.categories.single.items.single.sources.single.reasonKind,
        GenerationReasonKind.personal,
      );
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
  );

  test(
    'une catégorie Personnel est refusée si son propriétaire ne participe pas',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _seedPersonalLibrary(database);

      expect(
        () => DriftTripRepository(database).createTrip(
          CreateTripRequest(
            name: 'Invalide',
            destination: 'Lyon',
            startDate: null,
            endDate: null,
            participantOwnerIds: const {},
            transportOwnerIds: const {},
            lodgingOwnerIds: const {},
            personalCategoryIds: {fixture.selectedCategoryId},
            includeEssentials: false,
          ),
        ),
        throwsArgumentError,
      );
    },
  );

  testWidgets(
    'la section Personnel apparaît et disparaît avec le participant local',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _seedPersonalLibrary(database);
      final owners = await DriftLibraryRepository(database).loadLibrary();

      await tester.pumpWidget(
        MaterialApp(
          home: TripForm(
            searchCities: (query) async => const [],
            title: 'Nouveau voyage',
            submitLabel: 'Créer',
            owners: owners,
            contexts: const [],
          ),
        ),
      );

      expect(find.text('Personnel'), findsNothing);
      await tester.tap(find.byKey(Key('trip-choice-${fixture.participantId}')));
      await tester.pump();
      expect(find.text('Personnel'), findsOneWidget);
      expect(
        find.byKey(Key('trip-choice-${fixture.selectedCategoryId}')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(Key('trip-choice-${fixture.selectedCategoryId}')),
      );
      await tester.tap(find.byKey(Key('trip-choice-${fixture.participantId}')));
      await tester.pump();
      expect(find.text('Personnel'), findsNothing);
      await tester.tap(find.byKey(Key('trip-choice-${fixture.participantId}')));
      await tester.pump();
      final personalChip = tester.widget<ChoiceChip>(
        find.byKey(Key('trip-choice-${fixture.selectedCategoryId}')),
      );
      expect(personalChip.selected, isFalse);
    },
  );

  testWidgets('le contenu Personnel forme un vrai bloc accordéon à 360 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final database = AppDatabase(NativeDatabase.memory());
    final fixture = await _seedPersonalLibrary(database);
    final dependencies = await AppDependencies.create(
      database: database,
      autoSync: false,
    );
    final tripId = await dependencies.trips.createTrip(
      CreateTripRequest(
        name: 'Personnel UI',
        destination: 'Annecy',
        startDate: null,
        endDate: null,
        participantOwnerIds: {fixture.participantId},
        transportOwnerIds: const {},
        lodgingOwnerIds: const {},
        personalCategoryIds: {fixture.selectedCategoryId},
        includeEssentials: false,
      ),
    );
    final generatedTrip = (await dependencies.trips.watchTrip(tripId).first)!;
    final personalMember = generatedTrip.members.singleWhere(
      (member) => member.groupKind == TripMemberGroupKind.personal,
    );
    final personalCategory = personalMember.categories.single;

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    final summary = find.byKey(Key('trip-summary-$tripId'));
    await tester.ensureVisible(summary);
    await tester.tap(summary);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('trip-level-personal')), findsOneWidget);
    expect(find.text('Personnel Malone'), findsOneWidget);
    await tester.tap(find.byKey(const Key('trip-level-personnel-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Personnel Malone'), findsNothing);
    await tester.tap(find.byKey(const Key('trip-level-personnel-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('trip-member-${personalMember.id}')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('trip-category-icon-${personalCategory.id}')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await dependencies.close();
  });
}

Future<_PersonalFixture> _seedPersonalLibrary(AppDatabase database) async {
  final library = DriftLibraryRepository(database);
  final participantId = await library.createOwner(
    name: 'Malone',
    kind: LibraryOwnerKind.familyMember,
    generationRole: GenerationRole.participant,
  );
  final personalOwnerId = await library.createOwner(
    name: 'Personnel Malone',
    kind: LibraryOwnerKind.personal,
    generationRole: GenerationRole.participant,
    linkedParticipantOwnerId: participantId,
  );
  final selectedCategoryId = await library.createCategory(
    personalOwnerId,
    'Plage privée',
  );
  await library.createItem(
    categoryId: selectedCategoryId,
    name: 'Lunettes privées',
    defaultQuantity: 1,
  );
  final unselectedCategoryId = await library.createCategory(
    personalOwnerId,
    'Maison',
  );
  await library.createItem(
    categoryId: unselectedCategoryId,
    name: 'Clés',
    defaultQuantity: 1,
  );
  return _PersonalFixture(
    participantId: participantId,
    selectedCategoryId: selectedCategoryId,
  );
}

class _PersonalFixture {
  const _PersonalFixture({
    required this.participantId,
    required this.selectedCategoryId,
  });

  final String participantId;
  final String selectedCategoryId;
}
