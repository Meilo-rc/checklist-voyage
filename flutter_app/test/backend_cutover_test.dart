import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_context_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/sync/library_sync_coordinator.dart';
import 'package:checklist_voyage_v1/sync/library_sync_store.dart';
import 'package:checklist_voyage_v1/sync/pocketbase_sync_remote.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final oldUrl = Platform.environment['CHECKLIST_V1_OLD_PB_URL'];
  final newUrl = Platform.environment['CHECKLIST_V1_PB_URL'];
  final skip = oldUrl == null || newUrl == null
      ? 'Définir les URL PocketBase ancienne et dédiée pour ce test réel.'
      : false;

  test(
    'une outbox refusée par psyco survit au redémarrage puis passe sur le backend dédié',
    () async {
      expect(Uri.parse(oldUrl!).host, 'psyco.fly.dev');
      expect(Uri.parse(newUrl!).host, 'checklist-voyage-pb.fly.dev');

      final probe = await http.post(
        Uri.parse('$oldUrl/api/cv1/sync/push'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode(const <String, Object?>{}),
      );
      expect(
        probe.statusCode,
        503,
        reason: 'Le gel psyco doit précéder le test.',
      );

      const uuid = Uuid();
      final directory = await Directory.systemTemp.createTemp('cv1-cutover-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}cutover.sqlite',
      );
      final deviceId = uuid.v4();
      final libraryId = uuid.v4();

      var installation = await _Installation.open(
        file,
        deviceId,
        libraryId,
        PocketBaseSyncRemote(baseUrl: oldUrl),
      );
      final owner = await installation.library.createOwner(
        name: 'Bascule Général',
        kind: LibraryOwnerKind.general,
        generationRole: GenerationRole.general,
      );
      final category = await installation.library.createCategory(
        owner,
        'Bascule catégorie',
      );
      final item = await installation.library.createItem(
        categoryId: category,
        name: 'Bascule item',
        defaultQuantity: 2,
      );
      final context = await installation.contexts.createContext(
        'Bascule contexte',
      );
      await installation.contexts.setItemContexts(item, {context});

      await installation.sync.syncNow();
      final retained = await installation.store.pendingOperations();
      expect(retained, hasLength(5));
      await installation.close();

      installation = await _Installation.open(
        file,
        deviceId,
        libraryId,
        PocketBaseSyncRemote(baseUrl: newUrl),
      );
      addTearDown(installation.close);
      expect(await installation.store.pendingOperations(), hasLength(5));
      await installation.sync.syncNow();
      expect(await installation.store.pendingOperations(), isEmpty);

      final pulled = await PocketBaseSyncRemote(
        baseUrl: newUrl,
      ).pull(libraryId: libraryId, afterRevision: 0);
      expect(pulled.operations, hasLength(5));
      expect(
        pulled.operations.map((entry) => entry.operation.entityId),
        containsAll(<String>[owner, category, item, context]),
      );
    },
    skip: skip,
  );
}

class _Installation {
  _Installation(
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

  static Future<_Installation> open(
    File file,
    String deviceId,
    String libraryId,
    PocketBaseSyncRemote remote,
  ) async {
    final database = AppDatabase(NativeDatabase(file));
    final current = await database
        .select(database.installationSettings)
        .getSingleOrNull();
    if (current == null) {
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
    }
    final store = LibrarySyncStore(database);
    return _Installation(
      database,
      store,
      DriftLibraryRepository(database, syncStore: store),
      DriftContextRepository(database, syncStore: store),
      LibrarySyncCoordinator(store, remote),
    );
  }

  Future<void> close() => database.close();
}
