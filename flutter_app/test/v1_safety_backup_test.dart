import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/in_memory_sync_remote.dart';

void main() {
  // Ce fichier ouvre volontairement des bases isolées source et cible.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('exporte et restaure toutes les données V1 sans duplication', () async {
    final sourceDatabase = AppDatabase(NativeDatabase.memory());
    final documentRemote = InMemorySharedDocumentRemote();
    final source = await AppDependencies.create(
      database: sourceDatabase,
      syncRemote: InMemorySyncRemote(),
      documentRemote: documentRemote,
      autoSync: false,
    );
    addTearDown(source.close);

    final ids = await _seedLibrary(source);
    final beach = await source.contexts.create('Plage');
    await source.contexts.saveForItem(ids.personalItem, {beach});
    await source.contexts.saveForItem(ids.passportItem, {beach});

    final localTrip = await source.trips.createTrip(
      _tripRequest('Local', ids.participantOwner, ids.flightOwner),
    );
    final sharedTrip = await source.trips.createTrip(
      _tripRequest('Partagé', ids.participantOwner, ids.flightOwner),
    );
    await source.sharedDocuments.shareTrip(sharedTrip);
    documentRemote.online = false;
    final sharedDetail = await source.trips
        .watchTrip(sharedTrip)
        .firstWhere((trip) => trip != null);
    await source.trips.cycleItemStatus(
      sharedDetail!.members.first.categories.first.items.first.id,
    );
    final quickList = await source.quickLists.create('Locale');
    await source.quickLists.addItem(quickList, 'Crampons', quantity: 2);

    final sourceInstallation = await source.localData.getInstallationId();
    final backup = await source.safetyBackup.exportBytes(
      now: DateTime.utc(2026, 8, 23, 1, 2, 3),
    );
    final info = source.safetyBackup.inspect(backup);
    expect(info.installationId, sourceInstallation);
    expect(info.schemaVersion, 7);
    expect(info.count('trips'), 2);
    expect(info.count('quick_lists'), 1);
    expect(info.count('sync_documents'), 1);
    expect(info.count('sync_outbox'), greaterThan(0));

    final directory = await Directory.systemTemp.createTemp('cv1-restore-');
    final targetFile = File(
      '${directory.path}${Platform.pathSeparator}db.sqlite',
    );
    addTearDown(() => directory.delete(recursive: true));
    var targetDatabase = AppDatabase(NativeDatabase(targetFile));
    var target = await AppDependencies.create(
      database: targetDatabase,
      syncRemote: InMemorySyncRemote(),
      documentRemote: InMemorySharedDocumentRemote(),
      autoSync: false,
    );

    await target.safetyBackup.restoreBytes(backup);
    await target.safetyBackup.restoreBytes(backup);
    expect(await target.localData.getInstallationId(), sourceInstallation);
    var library = await target.library.loadLibrary();
    expect(
      library.singleWhere((owner) => owner.id == ids.personalOwner).isPersonal,
      isTrue,
    );
    expect(await target.contexts.loadForItem(ids.personalItem), {beach});
    var trips = await target.watchTrips().first;
    expect(trips.map((trip) => trip.id), containsAll([localTrip, sharedTrip]));
    expect(trips.singleWhere((trip) => trip.id == localTrip).shared, isFalse);
    expect(trips.singleWhere((trip) => trip.id == sharedTrip).shared, isTrue);
    expect(await target.watchQuickLists().first, hasLength(1));
    expect(
      await targetDatabase.customSelect('SELECT * FROM sync_documents').get(),
      hasLength(1),
    );
    final restoredOutbox = await targetDatabase
        .customSelect('SELECT * FROM sync_outbox')
        .get();
    expect(restoredOutbox, hasLength(info.count('sync_outbox')));

    await target.close();
    targetDatabase = AppDatabase(NativeDatabase(targetFile));
    target = await AppDependencies.create(
      database: targetDatabase,
      syncRemote: InMemorySyncRemote(),
      documentRemote: InMemorySharedDocumentRemote(),
      autoSync: false,
    );
    addTearDown(target.close);
    expect(await target.localData.getInstallationId(), sourceInstallation);
    library = await target.library.loadLibrary();
    expect(library.any((owner) => owner.id == ids.personalOwner), isTrue);
    trips = await target.watchTrips().first;
    expect(trips, hasLength(2));
    expect(await target.watchQuickLists().first, hasLength(1));
  });

  test('refuse une sauvegarde altérée avant toute écriture', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final dependencies = await AppDependencies.create(
      database: database,
      syncRemote: InMemorySyncRemote(),
      documentRemote: InMemorySharedDocumentRemote(),
      autoSync: false,
    );
    addTearDown(dependencies.close);
    final before = await dependencies.localData.getInstallationId();
    final backup = await dependencies.safetyBackup.exportBytes();
    final decoded = jsonDecode(utf8.decode(backup)) as Map<String, Object?>;
    decoded['installationId'] = 'altéré';
    final tampered = Uint8List.fromList(utf8.encode(jsonEncode(decoded)));

    expect(
      () => dependencies.safetyBackup.restoreBytes(tampered),
      throwsA(isA<FormatException>()),
    );
    expect(await dependencies.localData.getInstallationId(), before);
  });
}

CreateTripRequest _tripRequest(
  String name,
  String participant,
  String transport,
) => CreateTripRequest(
  name: name,
  destination: 'Paris',
  startDate: DateTime.utc(2026, 9, 1),
  endDate: DateTime.utc(2026, 9, 3),
  participantOwnerIds: {participant},
  transportOwnerIds: {transport},
  lodgingOwnerIds: const {},
);

Future<
  ({
    String passportItem,
    String participantOwner,
    String flightOwner,
    String personalOwner,
    String personalItem,
  })
>
_seedLibrary(AppDependencies dependencies) async {
  final essentialOwner = await dependencies.library.createOwner(
    name: 'Essentiels',
    kind: LibraryOwnerKind.general,
    generationRole: GenerationRole.essential,
  );
  final essentialCategory = await dependencies.library.createCategory(
    essentialOwner,
    'Documents',
  );
  final passportItem = await dependencies.library.createItem(
    categoryId: essentialCategory,
    name: 'Passeport',
    defaultQuantity: 1,
  );
  final participantOwner = await dependencies.library.createOwner(
    name: 'Alex',
    kind: LibraryOwnerKind.familyMember,
    generationRole: GenerationRole.participant,
  );
  final participantCategory = await dependencies.library.createCategory(
    participantOwner,
    'Vêtements',
  );
  await dependencies.library.createItem(
    categoryId: participantCategory,
    name: 'T-shirt',
    defaultQuantity: 2,
  );
  final flightOwner = await dependencies.library.createOwner(
    name: 'Trajet - Avion',
    kind: LibraryOwnerKind.general,
    generationRole: GenerationRole.transport,
  );
  final flightCategory = await dependencies.library.createCategory(
    flightOwner,
    'Avion',
  );
  await dependencies.library.createItem(
    categoryId: flightCategory,
    name: 'Billet',
    defaultQuantity: 1,
  );
  final personalOwner = await dependencies.library.createOwner(
    name: 'Privé',
    kind: LibraryOwnerKind.personal,
    generationRole: GenerationRole.participant,
    linkedParticipantOwnerId: participantOwner,
  );
  final personalCategory = await dependencies.library.createCategory(
    personalOwner,
    'Personnel',
  );
  final personalItem = await dependencies.library.createItem(
    categoryId: personalCategory,
    name: 'Objet privé',
    defaultQuantity: 1,
  );
  return (
    passportItem: passportItem,
    participantOwner: participantOwner,
    flightOwner: flightOwner,
    personalOwner: personalOwner,
    personalItem: personalItem,
  );
}
