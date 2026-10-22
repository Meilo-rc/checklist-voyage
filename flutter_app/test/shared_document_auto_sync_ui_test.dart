import 'dart:async';

import 'package:drift/drift.dart' hide Column, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/core/theme/app_theme.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/features/shared/document_sync_notice.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  for (final dark in [false, true]) {
    testWidgets(
      'erreur discrète, sans détail privé, 360 px ${dark ? 'sombre' : 'clair'}',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final errors = StreamController<String?>.broadcast();
        var retries = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: Scaffold(
                body: Column(
                  children: [
                    DocumentSyncNotice(
                      errors: errors.stream,
                      onRetry: () => retries++,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(find.text('Réessayer'), findsNothing);
        errors.add('Détail technique privé / capacité sensible');
        await tester.pump();
        expect(find.textContaining('Modifications conservées'), findsOneWidget);
        expect(find.textContaining('capacité sensible'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Réessayer'));
        expect(retries, 1);
        errors.add(null);
        await tester.pump();
        expect(find.text('Réessayer'), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
        await errors.close();
      },
    );
  }

  testWidgets(
    'réception à la reprise depuis l’accueil puis pendant le voyage ouvert',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final remote = InMemorySharedDocumentRemote();
      final a = await AppDependencies.create(
        database: AppDatabase(NativeDatabase.memory()),
        documentRemote: remote,
        autoSync: false,
      );
      final b = await AppDependencies.create(
        database: AppDatabase(NativeDatabase.memory()),
        documentRemote: remote,
        autoSync: false,
      );
      final tripId = await a.trips.createTrip(
        CreateTripRequest(
          name: 'Voyage synthétique',
          destination: 'Test',
          startDate: null,
          endDate: null,
          participantOwnerIds: const {},
          transportOwnerIds: const {},
          lodgingOwnerIds: const {},
          includeEssentials: false,
        ),
      );
      final groupId = await a.trips.addGroup(
        tripId,
        TripMemberGroupKind.family,
        'Groupe test',
      );
      final categoryId = await a.trips.addCategory(tripId, groupId, 'Divers');
      final itemId = await a.trips.addItem(tripId, categoryId, 'Chargeur');
      final access = await a.sharedDocuments.shareTrip(tripId);
      await b.sharedDocuments.join(access.shareCode);
      await tester.pumpWidget(ChecklistApp(dependencies: b));
      await _pumpData(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await a.trips.changeItemQuantity(itemId, 1);
      await a.sharedDocuments.syncDocument(tripId);
      expect((await _item(b, itemId)).quantity, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await _pumpData(tester);
      expect((await _item(b, itemId)).quantity, 2);

      await tester.ensureVisible(find.byKey(Key('trip-summary-$tripId')));
      await tester.tap(find.byKey(Key('trip-summary-$tripId')));
      await _pumpData(tester);
      await a.trips.cycleItemStatus(itemId);
      await a.sharedDocuments.syncDocument(tripId);
      expect((await _item(b, itemId)).status, 'todo');
      await tester.pump(const Duration(seconds: 15));
      await _pumpData(tester);
      expect((await _item(b, itemId)).status, 'checked');

      remote.online = false;
      await b.trips.changeItemQuantity(itemId, 1);
      await tester.pump(const Duration(milliseconds: 150));
      await _pumpData(tester);
      expect(find.textContaining('Modifications conservées'), findsOneWidget);
      remote.online = true;
      await tester.pump(const Duration(seconds: 3));
      await _pumpData(tester);
      expect(find.textContaining('Modifications conservées'), findsNothing);
      expect(remote.entityPayload(tripId, 'trip_item', itemId)?['quantity'], 3);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpData(tester);
      await a.close();
      final close = b.close();
      await _pumpData(tester);
      await close;
      await tester.pump(const Duration(milliseconds: 10));
    },
  );
}

Future<TripItem> _item(AppDependencies app, String id) => (app.database.select(
  app.database.tripItems,
)..where((row) => row.id.equals(id))).getSingle();

Future<void> _pumpData(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
