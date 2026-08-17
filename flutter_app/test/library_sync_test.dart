import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_context_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_quick_list_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/sync/in_memory_sync_remote.dart';
import 'package:checklist_voyage_v1/sync/library_sync_coordinator.dart';
import 'package:checklist_voyage_v1/sync/library_sync_store.dart';

const deviceA = '00000000-0000-4000-8000-000000000001';
const deviceB = '00000000-0000-4000-8000-000000000002';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'deux installations convergent pour Général, Famille et contextes',
    () async {
      final remote = InMemorySyncRemote();
      final a = await _Installation.memory(deviceA, remote);
      final b = await _Installation.memory(deviceB, remote);
      addTearDown(a.close);
      addTearDown(b.close);

      final owner = await a.library.createOwner(
        name: 'Famille',
        kind: LibraryOwnerKind.familyMember,
        generationRole: GenerationRole.participant,
      );
      final category = await a.library.createCategory(owner, 'Vêtements');
      final item = await a.library.createItem(
        categoryId: category,
        name: 'T-shirt',
        defaultQuantity: 3,
      );
      final beach = await a.contexts.createContext('Plage');
      await a.contexts.setItemContexts(item, {beach});

      await a.sync.syncNow();
      await b.sync.syncNow();
      var libraryB = await b.library.loadLibrary();
      expect(libraryB.single.name, 'Famille');
      expect(libraryB.single.categories.single.items.single.defaultQuantity, 3);
      expect((await b.contexts.loadContexts()).single.name, 'Plage');
      expect(await b.contexts.loadContextIdsForItem(item), {beach});

      await b.library.updateItem(
        itemId: item,
        name: 'T-shirt été',
        defaultQuantity: 5,
      );
      await b.sync.syncNow();
      await a.sync.syncNow();
      libraryB = await a.library.loadLibrary();
      expect(
        libraryB.single.categories.single.items.single.name,
        'T-shirt été',
      );
      expect(libraryB.single.categories.single.items.single.defaultQuantity, 5);
    },
  );

  test(
    'Personnel est bloqué dans le repository et absent du serveur',
    () async {
      final remote = InMemorySyncRemote();
      final a = await _Installation.memory(deviceA, remote);
      addTearDown(a.close);

      final sharedContext = await a.contexts.createContext('Plage');
      final personalOwner = await a.library.createOwner(
        name: 'Privé',
        kind: LibraryOwnerKind.personal,
        generationRole: GenerationRole.participant,
      );
      final personalCategory = await a.library.createCategory(
        personalOwner,
        'Secret',
      );
      final personalItem = await a.library.createItem(
        categoryId: personalCategory,
        name: 'Traitement privé',
        defaultQuantity: 1,
      );
      await a.contexts.setItemContexts(personalItem, {sharedContext});

      expect(
        await a.store.recordUpsert('library_item', personalItem, {
          'name': 'tentative malveillante',
        }),
        isFalse,
      );
      final queued = await a.database.select(a.database.syncOutbox).get();
      expect(queued.where((op) => op.entityId == personalOwner), isEmpty);
      expect(queued.where((op) => op.entityId == personalCategory), isEmpty);
      expect(queued.where((op) => op.entityId == personalItem), isEmpty);
      expect(
        queued.where((op) => op.payloadJson.contains('personal_local')),
        isEmpty,
      );

      await a.sync.syncNow();
      expect(
        remote.journal.any((op) => op.operation.entityId == personalOwner),
        isFalse,
      );
      expect(
        remote.journal.any((op) => op.operation.entityId == personalCategory),
        isFalse,
      );
      expect(
        remote.journal.any((op) => op.operation.entityId == personalItem),
        isFalse,
      );
      expect(
        remote.journal.any(
          (op) => op.operation.payload['sync_scope'] == 'personal_local',
        ),
        isFalse,
      );
    },
  );

  test(
    'outbox survit au redémarrage hors ligne puis reprend sans doublon',
    () async {
      final remote = InMemorySyncRemote()..online = false;
      final directory = await Directory.systemTemp.createTemp('cv1-sync-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}${Platform.pathSeparator}a.sqlite');

      var a = await _Installation.file(file, deviceA, remote);
      final owner = await a.library.createOwner(
        name: 'Général',
        kind: LibraryOwnerKind.general,
        generationRole: GenerationRole.general,
      );
      await a.library.renameOwner(owner, 'Général hors ligne');
      await a.sync.syncNow();
      expect(
        await a.database.select(a.database.syncOutbox).get(),
        hasLength(2),
      );
      await a.close();

      remote.online = true;
      a = await _Installation.file(file, deviceA, remote);
      addTearDown(a.close);
      await a.sync.syncNow();
      expect(await a.database.select(a.database.syncOutbox).get(), isEmpty);
      final uniqueOperationIds = remote.journal
          .map((op) => op.operation.operationId)
          .toSet();
      expect(uniqueOperationIds, hasLength(remote.journal.length));

      final b = await _Installation.memory(deviceB, remote);
      addTearDown(b.close);
      await b.sync.syncNow();
      expect((await b.library.loadLibrary()).single.name, 'Général hors ligne');
    },
  );

  test('push et pull répétés sont idempotents', () async {
    final remote = InMemorySyncRemote();
    final a = await _Installation.memory(deviceA, remote);
    final b = await _Installation.memory(deviceB, remote);
    addTearDown(a.close);
    addTearDown(b.close);
    await a.library.createOwner(
      name: 'Général',
      kind: LibraryOwnerKind.general,
      generationRole: GenerationRole.general,
    );
    final operation = (await a.store.pendingOperations()).single;
    final first = await remote.push(operation);
    final second = await remote.push(operation);
    expect(
      second.remoteOperation.serverRevision,
      first.remoteOperation.serverRevision,
    );
    expect(remote.duplicatePushes, 1);
    await b.sync.syncNow();
    await b.sync.syncNow();
    expect(await b.library.loadLibrary(), hasLength(1));
  });

  test('voyages et listes rapides ne produisent aucune opération V1', () async {
    final remote = InMemorySyncRemote();
    final a = await _Installation.memory(deviceA, remote);
    addTearDown(a.close);
    final trips = DriftTripRepository(a.database);
    final quickLists = DriftQuickListRepository(a.database);
    await trips.createTrip(
      const CreateTripRequest(
        name: 'Voyage local',
        destination: 'Paris',
        startDate: null,
        endDate: null,
        participantOwnerIds: {},
        transportOwnerIds: {},
        lodgingOwnerIds: {},
        includeEssentials: false,
      ),
    );
    final list = await quickLists.createQuickList('Liste locale');
    await quickLists.addItem(listId: list, name: 'Local', quantity: 1);
    expect(await a.database.select(a.database.syncOutbox).get(), isEmpty);
    await a.sync.syncNow();
    expect(remote.journal, isEmpty);
  });

  test(
    'conflit simultané déterministe et suppression gagnante sans résurrection',
    () async {
      final remote = InMemorySyncRemote();
      final a = await _Installation.memory(deviceA, remote);
      final b = await _Installation.memory(deviceB, remote);
      addTearDown(a.close);
      addTearDown(b.close);
      final owner = await a.library.createOwner(
        name: 'Alex',
        kind: LibraryOwnerKind.familyMember,
        generationRole: GenerationRole.participant,
      );
      final category = await a.library.createCategory(owner, 'Vêtements');
      final item = await a.library.createItem(
        categoryId: category,
        name: 'Pull',
        defaultQuantity: 1,
      );
      final context = await a.contexts.createContext('Randonnée');
      await a.contexts.setItemContexts(item, {context});
      await a.sync.syncNow();
      await b.sync.syncNow();

      await a.library.renameOwner(owner, 'Nom A');
      await b.library.renameOwner(owner, 'Nom B');
      await b.sync.syncNow();
      await a.sync.syncNow();
      expect((await a.library.loadLibrary()).single.name, 'Nom B');
      expect((await b.library.loadLibrary()).single.name, 'Nom B');
      expect(
        await a.database.select(a.database.syncConflicts).get(),
        isNotEmpty,
      );

      final association = await (a.database.select(
        a.database.libraryItemContexts,
      )..where((row) => row.itemId.equals(item))).getSingle();
      await a.contexts.setItemContexts(item, {});
      await b.store.recordUpsert(
        'context_association',
        association.associationId!,
        {
          'item_id': item,
          'context_id': context,
          'sync_scope': 'shared_library',
        },
      );
      await b.sync.syncNow();
      await a.sync.syncNow();
      await b.sync.syncNow();
      expect(await b.contexts.loadContextIdsForItem(item), isEmpty);

      await b.library.updateItem(
        itemId: item,
        name: 'Pull modifié',
        defaultQuantity: 2,
      );
      await a.library.deleteItem(item);
      await b.sync.syncNow();
      await a.sync.syncNow();
      await b.sync.syncNow();
      expect(
        (await b.library.loadLibrary()).single.categories.single.items,
        isEmpty,
      );
      final tombstones = await b.database
          .select(b.database.syncTombstones)
          .get();
      expect(
        tombstones
            .singleWhere((row) => row.entityId == item)
            .purgeEligibleAt
            .difference(
              tombstones.singleWhere((row) => row.entityId == item).deletedAt,
            )
            .inDays,
        90,
      );
    },
  );
}

class _Installation {
  _Installation._(
    this.database,
    this.store,
    this.library,
    this.contexts,
    this.sync,
  );

  final AppDatabase database;
  final LibrarySyncStore store;
  final DriftLibraryRepository library;
  final DriftContextRepository contexts;
  final LibrarySyncCoordinator sync;

  static Future<_Installation> memory(
    String device,
    InMemorySyncRemote remote,
  ) => _create(AppDatabase(NativeDatabase.memory()), device, remote);

  static Future<_Installation> file(
    File file,
    String device,
    InMemorySyncRemote remote,
  ) => _create(AppDatabase(NativeDatabase(file)), device, remote);

  static Future<_Installation> _create(
    AppDatabase database,
    String device,
    InMemorySyncRemote remote,
  ) async {
    final existing = await database
        .select(database.installationSettings)
        .getSingleOrNull();
    if (existing == null) {
      final now = DateTime.now().toUtc();
      await database
          .into(database.installationSettings)
          .insert(
            InstallationSettingsCompanion.insert(
              installationId: device,
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
    }
    final store = LibrarySyncStore(database);
    return _Installation._(
      database,
      store,
      DriftLibraryRepository(database, syncStore: store),
      DriftContextRepository(database, syncStore: store),
      LibrarySyncCoordinator(store, remote),
    );
  }

  Future<void> close() => database.close();
}
