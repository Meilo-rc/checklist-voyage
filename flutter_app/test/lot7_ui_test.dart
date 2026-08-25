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
  testWidgets('Partager affiche le code uniquement dans le dialogue', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final documents = InMemorySharedDocumentRemote();
    final dependencies = await AppDependencies.create(
      database: database,
      syncRemote: InMemorySyncRemote(),
      documentRemote: documents,
      autoSync: false,
    );
    addTearDown(dependencies.close);
    final tripId = await dependencies.trips.createTrip(
      const CreateTripRequest(
        name: 'Voyage partageable',
        destination: 'Test',
        startDate: null,
        endDate: null,
        participantOwnerIds: {},
        transportOwnerIds: {},
        lodgingOwnerIds: {},
        includeEssentials: false,
      ),
    );
    await dependencies.quickLists.create('Liste partageable');

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(Key('trip-summary-$tripId')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('trip-summary-$tripId')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trip-share')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shared-code')), findsOneWidget);
    expect(documents.hasDocument(tripId), isTrue);
    expect(documents.operations(tripId), isNotEmpty);
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shared-code')), findsNothing);
    expect(find.text('Partagé'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listes rapides'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liste partageable'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick-share')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick-shared-code')), findsOneWidget);
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
