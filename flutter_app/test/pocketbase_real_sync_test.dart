import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_context_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/sync/library_sync_coordinator.dart';
import 'package:checklist_voyage_v1/sync/library_sync_store.dart';
import 'package:checklist_voyage_v1/sync/pocketbase_sync_remote.dart';
import 'package:checklist_voyage_v1/sync/sync_models.dart';
import 'package:checklist_voyage_v1/sync/sync_remote_gateway.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final baseUrl = Platform.environment['CHECKLIST_V1_PB_URL'];
  test(
    'parcours réel PocketBase à deux installations isolées',
    () async {
      const uuid = Uuid();
      final libraryId = uuid.v4();
      final remote = _ToggleRemote(PocketBaseSyncRemote(baseUrl: baseUrl!));
      final a = await _RealInstallation.create(uuid.v4(), libraryId, remote);
      final b = await _RealInstallation.create(uuid.v4(), libraryId, remote);
      addTearDown(a.close);
      addTearDown(b.close);

      final owner = await a.library.createOwner(
        name: 'Test Général ${libraryId.substring(0, 8)}',
        kind: LibraryOwnerKind.general,
        generationRole: GenerationRole.general,
      );
      final category = await a.library.createCategory(owner, 'Test catégorie');
      final item = await a.library.createItem(
        categoryId: category,
        name: 'Test item',
        defaultQuantity: 2,
      );
      final context = await a.contexts.createContext('Test plage');
      await a.contexts.setItemContexts(item, {context});
      await a.sync.syncNow();
      await b.sync.syncNow();
      expect(
        (await b.library.loadLibrary()).single.categories.single.items,
        hasLength(1),
      );

      remote.online = false;
      await a.library.updateItem(
        itemId: item,
        name: 'Version A',
        defaultQuantity: 3,
      );
      await b.library.updateItem(
        itemId: item,
        name: 'Version B',
        defaultQuantity: 4,
      );
      await a.sync.syncNow();
      await b.sync.syncNow();
      expect(await a.database.select(a.database.syncOutbox).get(), isNotEmpty);
      remote.online = true;
      await b.sync.syncNow();
      await a.sync.syncNow();
      await b.sync.syncNow();
      expect(
        (await a.library.loadLibrary())
            .single
            .categories
            .single
            .items
            .single
            .name,
        (await b.library.loadLibrary())
            .single
            .categories
            .single
            .items
            .single
            .name,
      );

      final personal = await a.library.createOwner(
        name: 'Personnel test',
        kind: LibraryOwnerKind.personal,
        generationRole: GenerationRole.participant,
      );
      final personalCategory = await a.library.createCategory(
        personal,
        'Privé',
      );
      final personalItem = await a.library.createItem(
        categoryId: personalCategory,
        name: 'Ne doit pas sortir',
        defaultQuantity: 1,
      );
      await a.contexts.setItemContexts(personalItem, {context});
      await a.sync.syncNow();
      final allRemote = await remote.delegate.pull(
        libraryId: libraryId,
        afterRevision: 0,
      );
      expect(
        allRemote.operations.any((op) => op.operation.entityId == personal),
        isFalse,
      );
      expect(
        allRemote.operations.any((op) => op.operation.entityId == personalItem),
        isFalse,
      );
      expect(
        allRemote.operations.any(
          (op) => op.operation.payload['sync_scope'] == 'personal_local',
        ),
        isFalse,
      );

      await a.library.deleteItem(item);
      await a.sync.syncNow();
      await b.sync.syncNow();
      expect(
        (await b.library.loadLibrary()).single.categories.single.items,
        isEmpty,
      );
    },
    skip: baseUrl == null
        ? 'Définir CHECKLIST_V1_PB_URL pour le test réel isolé.'
        : false,
  );
}

class _ToggleRemote implements SyncRemoteGateway {
  _ToggleRemote(this.delegate);
  final PocketBaseSyncRemote delegate;
  bool online = true;

  @override
  Future<SyncPullPage> pull({
    required String libraryId,
    required int afterRevision,
    int limit = 200,
  }) {
    if (!online) throw const SyncOfflineException();
    return delegate.pull(
      libraryId: libraryId,
      afterRevision: afterRevision,
      limit: limit,
    );
  }

  @override
  Future<SyncPushResult> push(SyncOperation operation) {
    if (!online) throw const SyncOfflineException();
    return delegate.push(operation);
  }
}

class _RealInstallation {
  _RealInstallation(this.database, this.library, this.contexts, this.sync);
  final AppDatabase database;
  final DriftLibraryRepository library;
  final DriftContextRepository contexts;
  final LibrarySyncCoordinator sync;

  static Future<_RealInstallation> create(
    String deviceId,
    String libraryId,
    SyncRemoteGateway remote,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final now = DateTime.now().toUtc();
    await database
        .into(database.installationSettings)
        .insert(
          InstallationSettingsCompanion.insert(
            installationId: deviceId,
            libraryId: Value(libraryId),
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    final store = LibrarySyncStore(database);
    return _RealInstallation(
      database,
      DriftLibraryRepository(database, syncStore: store),
      DriftContextRepository(database, syncStore: store),
      LibrarySyncCoordinator(store, remote),
    );
  }

  Future<void> close() => database.close();
}
