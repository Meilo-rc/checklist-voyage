import 'dart:async';

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
  testWidgets('Partager ouvre le service natif avec le message commun', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final documents = InMemorySharedDocumentRemote();
    final invitations = _FakeShareInvitationGateway();
    final dependencies = await AppDependencies.create(
      database: database,
      syncRemote: InMemorySyncRemote(),
      documentRemote: documents,
      shareInvitations: invitations,
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
    expect(invitations.shared, hasLength(1));
    expect(invitations.shared.single.type, ShareableDocumentType.trip);
    expect(invitations.shared.single.displayName, 'Voyage partageable');
    expect(invitations.shared.single.message, contains('Code : '));
    expect(invitations.shared.single.message, contains('type=trip'));
    expect(documents.hasDocument(tripId), isTrue);
    expect(documents.operations(tripId), isNotEmpty);
    expect(find.text('Partagé'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listes rapides'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liste partageable'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick-share')));
    await tester.pumpAndSettle();
    expect(invitations.shared, hasLength(2));
    expect(invitations.shared.last.type, ShareableDocumentType.quickList);
    expect(invitations.shared.last.displayName, 'Liste partageable');
    expect(invitations.shared.last.message, contains('type=quick-list'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}

class _FakeShareInvitationGateway implements ShareInvitationGateway {
  final List<ShareInvitation> shared = [];
  final StreamController<ShareJoinRequest> _requests =
      StreamController<ShareJoinRequest>.broadcast();

  @override
  Stream<ShareJoinRequest> get incomingRequests => _requests.stream;

  @override
  Future<ShareJoinRequest?> takeInitialRequest() async => null;

  @override
  Future<void> share(ShareInvitation invitation) async {
    shared.add(invitation);
  }

  @override
  Future<void> close() => _requests.close();
}
