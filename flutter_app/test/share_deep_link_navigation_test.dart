import 'dart:async';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/core/sharing/share_invitation.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/in_memory_sync_remote.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets(
    'un lien initial puis un lien reçu à chaud préremplissent sans joindre',
    (tester) async {
      final remote = InMemorySharedDocumentRemote();
      final source = await AppDependencies.create(
        database: AppDatabase(NativeDatabase.memory()),
        syncRemote: InMemorySyncRemote(),
        documentRemote: remote,
        autoSync: false,
      );
      final tripId = await source.trips.createTrip(
        const CreateTripRequest(
          name: 'Voyage lien',
          destination: 'Nantes',
          startDate: null,
          endDate: null,
          participantOwnerIds: {},
          transportOwnerIds: {},
          lodgingOwnerIds: {},
          includeEssentials: false,
        ),
      );
      final listId = await source.quickLists.create('Liste lien');
      await source.quickLists.addItem(listId, 'Chargeur');
      final tripAccess = await source.sharedDocuments.shareTrip(tripId);
      final listAccess = await source.sharedDocuments.shareQuickList(listId);

      final links = _FakeShareInvitationGateway(
        initial: ShareJoinRequest(
          type: ShareableDocumentType.trip,
          code: tripAccess.shareCode,
        ),
      );
      final target = await AppDependencies.create(
        database: AppDatabase(NativeDatabase.memory()),
        syncRemote: InMemorySyncRemote(),
        documentRemote: remote,
        shareInvitations: links,
        autoSync: false,
      );
      addTearDown(source.close);
      addTearDown(target.close);

      await tester.pumpWidget(ChecklistApp(dependencies: target));
      await tester.pumpAndSettle();

      expect(find.text('Rejoindre un voyage'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('share-code-input')))
            .controller
            ?.text,
        tripAccess.shareCode,
      );
      expect(
        (await target.database.select(target.database.trips).get())
            .where((trip) => trip.id == tripId),
        isEmpty,
      );

      await tester.tap(find.byKey(const Key('share-code-submit')));
      await tester.pumpAndSettle();
      expect(
        (await target.database.select(target.database.trips).get())
            .where((trip) => trip.id == tripId),
        hasLength(1),
      );
      expect(find.byKey(const Key('trip-show-code')), findsOneWidget);

      links.emit(
        ShareJoinRequest(
          type: ShareableDocumentType.quickList,
          code: listAccess.shareCode,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rejoindre une liste rapide'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('quick-share-code-input')))
            .controller
            ?.text,
        listAccess.shareCode,
      );
      expect(await target.quickLists.load(listId), isNull);

      await tester.tap(find.byKey(const Key('quick-share-code-submit')));
      await tester.pumpAndSettle();
      expect(await target.quickLists.load(listId), isNotNull);
      expect(find.byKey(const Key('quick-show-code')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    },
  );
}

class _FakeShareInvitationGateway implements ShareInvitationGateway {
  _FakeShareInvitationGateway({this.initial});

  final ShareJoinRequest? initial;
  final _requests = StreamController<ShareJoinRequest>.broadcast();

  @override
  Stream<ShareJoinRequest> get incomingRequests => _requests.stream;

  void emit(ShareJoinRequest request) => _requests.add(request);

  @override
  Future<ShareJoinRequest?> takeInitialRequest() async => initial;

  @override
  Future<void> share(ShareInvitation invitation) async {}

  @override
  Future<void> close() => _requests.close();
}
