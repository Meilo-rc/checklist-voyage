import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_local_data_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_trip_repository.dart';
import 'package:checklist_voyage_v1/sync/in_memory_shared_document_remote.dart';
import 'package:checklist_voyage_v1/sync/shared_document_sync_coordinator.dart';
import 'package:checklist_voyage_v1/sync/shared_document_sync_store.dart';
import 'package:checklist_voyage_v1/sync/sync_models.dart';
import 'package:checklist_voyage_v1/sync/sync_remote_gateway.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('aucun envoi avant le commit de la mutation locale', () async {
    final remote = _ProbeRemote();
    final db = AppDatabase(NativeDatabase.memory());
    final app = await AppDependencies.create(
      database: db,
      documentRemote: remote,
      autoSync: false,
    );
    addTearDown(app.close);
    final fixture = await _seed(db);
    await app.sharedDocuments.shareTrip(fixture.tripId);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final initialPushes = remote.pushes;
    final changed = Completer<void>();
    final commit = Completer<void>();
    final transaction = db.transaction(() async {
      await app.trips.cycleItemStatus(fixture.itemId);
      changed.complete();
      await commit.future;
    });
    await changed.future;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final pushedBeforeCommit = remote.pushes != initialPushes;
    commit.complete();
    await transaction;
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(
      pushedBeforeCommit,
      isFalse,
      reason: 'Le réseau ne doit jamais utiliser la transaction Drift.',
    );
    final pending = await (db.select(
      db.syncOutbox,
    )..where((row) => row.documentId.equals(fixture.tripId))).get();
    expect(
      pending,
      isEmpty,
      reason: 'La mutation committée doit être envoyée automatiquement.',
    );
    expect(
      remote.entityPayload(
        fixture.tripId,
        'trip_item',
        fixture.itemId,
      )?['status'],
      'checked',
    );
  });

  test(
    'rollback : aucune opération ni modification ne part au serveur',
    () async {
      final remote = _ProbeRemote();
      final a = await _Installation.open(remote);
      addTearDown(a.close);
      final fixture = await _seed(a.db);
      await a.sync.shareTrip(fixture.tripId);
      final count = remote.operations(fixture.tripId).length;
      await expectLater(
        a.db.transaction(() async {
          await a.trips.cycleItemStatus(fixture.itemId);
          throw StateError('rollback simulé');
        }),
        throwsStateError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 180));
      expect(remote.operations(fixture.tripId), hasLength(count));
      expect(await a.store.pendingOperations(fixture.tripId), isEmpty);
      expect((await a.item(fixture.itemId)).status, 'todo');
    },
  );

  test(
    'rafale et demandes concurrentes : une seule exécution par voyage',
    () async {
      final remote = _ProbeRemote()
        ..pushDelay = const Duration(milliseconds: 3);
      final a = await _Installation.open(remote);
      addTearDown(a.close);
      final fixture = await _seed(a.db);
      await a.sync.shareTrip(fixture.tripId);
      final initial = remote.operations(fixture.tripId).length;
      final work = <Future<void>>[];
      for (var i = 0; i < 40; i++) {
        await a.trips.cycleItemStatus(fixture.itemId);
        if (i % 4 == 0) work.add(a.sync.syncDocument(fixture.tripId));
      }
      for (var i = 0; i < 20; i++) {
        await a.trips.changeItemQuantity(fixture.itemId, 1);
      }
      await Future.wait(work);
      await a.settled(fixture.tripId);
      expect(remote.maxConcurrentPushes, 1);
      expect(remote.operations(fixture.tripId), hasLength(initial + 60));
      final payload = remote.entityPayload(
        fixture.tripId,
        'trip_item',
        fixture.itemId,
      )!;
      expect(payload['quantity'], 21);
      expect(payload['status'], (await a.item(fixture.itemId)).status);
    },
  );

  test(
    'modification pendant le pull : pas d’écrasement local ni de curseur perdu',
    () async {
      final remote = _ProbeRemote();
      final a = await _Installation.open(remote);
      final b = await _Installation.open(remote);
      addTearDown(a.close);
      addTearDown(b.close);
      final fixture = await _seed(a.db);
      final access = await a.sync.shareTrip(fixture.tripId);
      await b.sync.join(access.shareCode);
      b.sync.setForeground(false);
      await b.trips.changeItemQuantity(fixture.itemId, 1);
      b.sync.setForeground(true);
      await b.settled(fixture.tripId);
      final pulling = Completer<void>();
      final release = Completer<void>();
      remote.afterPull = () async {
        remote.afterPull = null;
        pulling.complete();
        await release.future;
      };
      final work = a.sync.syncDocument(fixture.tripId);
      await pulling.future;
      await a.trips.cycleItemStatus(fixture.itemId);
      await a.trips.changeItemQuantity(fixture.itemId, 3);
      final pushing = Completer<void>();
      final accept = Completer<void>();
      remote.beforePush = () async {
        remote.beforePush = null;
        pushing.complete();
        await accept.future;
      };
      release.complete();
      await pushing.future;
      // Même avant l'acquittement, la page reçue ne doit pas afficher une
      // ancienne quantité à partir de laquelle le prochain tap serait calculé.
      final duringPush = await a.item(fixture.itemId);
      accept.complete();
      await work;
      await a.settled(fixture.tripId);
      expect(duringPush.quantity, 4);
      expect(duringPush.status, 'checked');
      expect((await a.item(fixture.itemId)).status, 'checked');
      expect((await a.item(fixture.itemId)).quantity, 4);
      expect(
        remote.entityPayload(
          fixture.tripId,
          'trip_item',
          fixture.itemId,
        )?['quantity'],
        4,
      );
      expect(
        (await a.store.document(fixture.tripId)).pullCursor,
        remote.operations(fixture.tripId).length,
      );
    },
  );

  test(
    'réseau perdu puis revenu : reprise automatique, UUID et données conservés',
    () async {
      final remote = _ProbeRemote();
      final a = await _Installation.open(remote);
      addTearDown(a.close);
      final fixture = await _seed(a.db);
      await a.sync.shareTrip(fixture.tripId);
      remote.online = false;
      await a.trips.cycleItemStatus(fixture.itemId);
      await _until(
        () async => (await a.store.document(fixture.tripId)).lastError != null,
      );
      final pending = (await a.store.pendingOperations(fixture.tripId)).single;
      expect((await a.item(fixture.itemId)).status, 'checked');
      remote.online = true;
      await a.settled(fixture.tripId);
      expect(
        remote
            .operations(fixture.tripId)
            .where((op) => op.operation.operationId == pending.operationId),
        hasLength(1),
      );
      expect((await a.store.document(fixture.tripId)).lastError, isNull);
      expect(
        remote.entityPayload(
          fixture.tripId,
          'trip_item',
          fixture.itemId,
        )?['status'],
        'checked',
      );
    },
  );

  test(
    'serveur temporairement indisponible : essais espacés, sans boucle serrée',
    () async {
      final remote = _ProbeRemote();
      final a = await _Installation.open(
        remote,
        retryDelays: const [Duration(milliseconds: 80)],
      );
      addTearDown(a.close);
      final fixture = await _seed(a.db);
      await a.sync.shareTrip(fixture.tripId);
      remote.failures = 3;
      remote.attemptTimes.clear();
      await a.trips.changeItemQuantity(fixture.itemId, 2);
      await a.settled(fixture.tripId);
      expect(remote.attemptTimes, hasLength(4));
      for (var i = 1; i < remote.attemptTimes.length; i++) {
        expect(
          remote.attemptTimes[i]
              .difference(remote.attemptTimes[i - 1])
              .inMilliseconds,
          greaterThanOrEqualTo(70),
        );
      }
      expect((await a.item(fixture.itemId)).quantity, 3);
    },
  );

  test(
    'réponse perdue après acceptation : même opération, aucun doublon',
    () async {
      final remote = _ProbeRemote();
      final a = await _Installation.open(remote);
      addTearDown(a.close);
      final fixture = await _seed(a.db);
      await a.sync.shareTrip(fixture.tripId);
      final initial = remote.operations(fixture.tripId).length;
      remote.loseNextResponse = true;
      await a.trips.renameItem(fixture.itemId, 'Batterie');
      await a.settled(fixture.tripId);
      expect(remote.operations(fixture.tripId), hasLength(initial + 1));
      final attempts = remote.attemptedIds;
      expect(attempts[attempts.length - 1], attempts[attempts.length - 2]);
      expect((await a.item(fixture.itemId)).name, 'Batterie');
    },
  );

  test(
    'arrière-plan : arrêt des retries ; reprise et réception sans ouvrir le voyage',
    () async {
      final remote = _ProbeRemote();
      final a = await _Installation.open(remote);
      final b = await _Installation.open(remote);
      addTearDown(a.close);
      addTearDown(b.close);
      final fixture = await _seed(a.db);
      final access = await a.sync.shareTrip(fixture.tripId);
      await b.sync.join(access.shareCode);
      remote.online = false;
      await a.trips.cycleItemStatus(fixture.itemId);
      await _until(
        () async => (await a.store.document(fixture.tripId)).lastError != null,
      );
      a.sync.setForeground(false);
      b.sync.setForeground(false);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final attempts = remote.pushes;
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(remote.pushes, attempts);
      remote.online = true;
      a.sync.setForeground(true);
      await a.settled(fixture.tripId);
      b.sync.setForeground(true);
      await _until(
        () async => (await b.item(fixture.itemId)).status == 'checked',
      );
      expect(
        (await b.store.document(fixture.tripId)).pullCursor,
        (await a.store.document(fixture.tripId)).pullCursor,
      );
    },
  );

  test(
    'interruption pendant un envoi : acquittement exact et reprise du reste',
    () async {
      final remote = _ProbeRemote();
      final a = await _Installation.open(remote);
      addTearDown(a.close);
      final fixture = await _seed(a.db);
      await a.sync.shareTrip(fixture.tripId);
      final initial = remote.operations(fixture.tripId).length;
      a.sync.setForeground(false);
      for (var i = 0; i < 20; i++) {
        await a.trips.cycleItemStatus(fixture.itemId);
      }
      final entered = Completer<void>();
      final release = Completer<void>();
      remote.beforePush = () async {
        remote.beforePush = null;
        entered.complete();
        await release.future;
      };
      a.sync.setForeground(true);
      await entered.future;
      a.sync.setForeground(false);
      release.complete();
      await _until(
        () async =>
            (await a.store.pendingOperations(fixture.tripId)).length == 19,
      );
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(remote.operations(fixture.tripId), hasLength(initial + 1));
      a.sync.setForeground(true);
      await a.settled(fixture.tripId);
      expect(remote.operations(fixture.tripId), hasLength(initial + 20));
      expect(
        remote
            .operations(fixture.tripId)
            .map((op) => op.operation.operationId)
            .toSet(),
        hasLength(initial + 20),
      );
      expect(
        (await a.item(fixture.itemId)).status,
        remote.entityPayload(
          fixture.tripId,
          'trip_item',
          fixture.itemId,
        )?['status'],
      );
    },
  );

  test('deux installations modifient le même voyage puis convergent', () async {
    final remote = _ProbeRemote();
    final a = await _Installation.open(remote);
    final b = await _Installation.open(remote);
    addTearDown(a.close);
    addTearDown(b.close);
    final fixture = await _seed(a.db);
    final category = (await a.item(fixture.itemId)).categoryId;
    final second = await a.trips.addItem(
      tripId: fixture.tripId,
      categoryId: category,
      name: 'Lunettes',
    );
    final access = await a.sync.shareTrip(fixture.tripId);
    await b.sync.join(access.shareCode);
    await Future.wait([
      a.trips.cycleItemStatus(fixture.itemId),
      b.trips.changeItemQuantity(second, 2),
    ]);
    await Future.wait([a.settled(fixture.tripId), b.settled(fixture.tripId)]);
    // Reprise normale côté réception, sans nouvelle jointure.
    a.sync.setForeground(false);
    b.sync.setForeground(false);
    a.sync.setForeground(true);
    b.sync.setForeground(true);
    await _until(
      () async =>
          (await a.item(second)).quantity == 3 &&
          (await b.item(fixture.itemId)).status == 'checked',
    );
    expect(await a.contents(fixture.tripId), await b.contents(fixture.tripId));
    // Deux éditions concurrentes du même item : résolution existante inchangée.
    a.sync.setForeground(false);
    b.sync.setForeground(false);
    await a.trips.renameItem(fixture.itemId, 'Nom A');
    await b.trips.renameItem(fixture.itemId, 'Nom B');
    a.sync.setForeground(true);
    b.sync.setForeground(true);
    await Future.wait([a.settled(fixture.tripId), b.settled(fixture.tripId)]);
    await Future.wait([a.sync.syncAll(), b.sync.syncAll()]);
    expect(await a.contents(fixture.tripId), await b.contents(fixture.tripId));
    expect((await a.item(fixture.itemId)).name, anyOf('Nom A', 'Nom B'));
  });

  test(
    '173 opérations persistées, redémarrage et réception de plusieurs pages',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'checklist-sync-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/synthetic.sqlite');
      final remote = _ProbeRemote();
      var a = await _Installation.open(remote, file: file);
      final fixture = await _seed(a.db);
      final category = (await a.item(fixture.itemId)).categoryId;
      final ids = [fixture.itemId];
      for (var i = 0; i < 39; i++) {
        ids.add(
          await a.trips.addItem(
            tripId: fixture.tripId,
            categoryId: category,
            name: 'Objet $i',
          ),
        );
      }
      final access = await a.sync.shareTrip(fixture.tripId);
      a.sync.setForeground(false);
      for (var i = 0; i < 173; i++) {
        if (i.isEven) {
          await a.trips.cycleItemStatus(ids[i % ids.length]);
        } else {
          await a.trips.changeItemQuantity(ids[i % ids.length], 1);
        }
      }
      final queued = await a.store.pendingOperations(fixture.tripId);
      final contents = await a.contents(fixture.tripId);
      expect(queued, hasLength(173));
      await a.close();
      a = await _Installation.open(remote, file: file);
      addTearDown(a.close);
      expect(
        (await a.store.pendingOperations(
          fixture.tripId,
        )).map((op) => op.toJson()),
        queued.map((op) => op.toJson()),
      );
      a.sync.setForeground(false);
      a.sync.setForeground(true);
      await a.settled(fixture.tripId);
      final b = await _Installation.open(remote);
      addTearDown(b.close);
      await b.sync.join(access.shareCode);
      expect(await a.contents(fixture.tripId), contents);
      expect(await b.contents(fixture.tripId), contents);
      final operations = remote.operations(fixture.tripId);
      expect(operations, hasLength(216));
      expect(
        operations.map((op) => op.operation.operationId).toSet(),
        hasLength(216),
      );
      expect(
        operations.map((op) => op.operation.operationId),
        containsAll(queued.map((op) => op.operationId)),
      );
      expect((await b.store.document(fixture.tripId)).pullCursor, 216);
    },
  );

  test('un voyage en échec ne bloque pas l’envoi d’un autre', () async {
    final remote = _ProbeRemote();
    final a = await _Installation.open(remote);
    addTearDown(a.close);
    final first = await _seed(a.db);
    final second = await _seed(a.db);
    await a.sync.shareTrip(first.tripId);
    await a.sync.shareTrip(second.tripId);
    a.sync.setForeground(false);
    await a.trips.cycleItemStatus(first.itemId);
    await a.trips.cycleItemStatus(second.itemId);
    remote.failedDocument = first.tripId;
    a.sync.setForeground(true);
    await a.settled(second.tripId);
    expect(await a.store.pendingOperations(first.tripId), hasLength(1));
    expect(
      remote.entityPayload(
        second.tripId,
        'trip_item',
        second.itemId,
      )?['status'],
      'checked',
    );
    remote.failedDocument = null;
    await a.settled(first.tripId);
  });
}

class _ProbeRemote extends InMemorySharedDocumentRemote {
  int pushes = 0;
  int failures = 0;
  int concurrentPushes = 0;
  int maxConcurrentPushes = 0;
  bool loseNextResponse = false;
  String? failedDocument;
  Duration pushDelay = Duration.zero;
  Future<void> Function()? afterPull;
  Future<void> Function()? beforePush;
  final attemptedIds = <String>[];
  final attemptTimes = <DateTime>[];

  @override
  Future<SyncPushResult> pushDocument({
    required SyncOperation operation,
    required String capabilityToken,
  }) async {
    pushes++;
    attemptedIds.add(operation.operationId);
    attemptTimes.add(DateTime.now());
    concurrentPushes++;
    if (concurrentPushes > maxConcurrentPushes) {
      maxConcurrentPushes = concurrentPushes;
    }
    try {
      await beforePush?.call();
      if (pushDelay != Duration.zero) await Future<void>.delayed(pushDelay);
      if (failures > 0 || failedDocument == operation.libraryId) {
        if (failures > 0) failures--;
        throw const HttpException(
          'Serveur temporairement indisponible (503 simulé)',
        );
      }
      final result = await super.pushDocument(
        operation: operation,
        capabilityToken: capabilityToken,
      );
      if (loseNextResponse) {
        loseNextResponse = false;
        throw const SyncOfflineException('Réponse perdue simulée');
      }
      return result;
    } finally {
      concurrentPushes--;
    }
  }

  @override
  Future<SyncPullPage> pullDocument({
    required String documentId,
    required String deviceId,
    required String capabilityToken,
    required int afterRevision,
    int limit = 200,
  }) async {
    final page = await super.pullDocument(
      documentId: documentId,
      deviceId: deviceId,
      capabilityToken: capabilityToken,
      afterRevision: afterRevision,
      limit: limit,
    );
    await afterPull?.call();
    return page;
  }
}

class _Installation {
  _Installation(this.db, this.store, this.sync, this.trips);

  final AppDatabase db;
  final SharedDocumentSyncStore store;
  final SharedDocumentSyncCoordinator sync;
  final DriftTripRepository trips;

  static Future<_Installation> open(
    _ProbeRemote remote, {
    File? file,
    List<Duration> retryDelays = const [
      Duration(milliseconds: 30),
      Duration(milliseconds: 60),
    ],
  }) async {
    final db = AppDatabase(
      file == null
          ? NativeDatabase.memory()
          : NativeDatabase.createInBackground(file),
    );
    await DriftLocalDataRepository(db).ensureInstallationId();
    final store = SharedDocumentSyncStore(db);
    final sync = SharedDocumentSyncCoordinator(
      store,
      remote,
      retryDelays: retryDelays,
    );
    store.onTripOperationQueued = sync.scheduleDocumentSync;
    return _Installation(
      db,
      store,
      sync,
      DriftTripRepository(db, syncStore: store),
    );
  }

  Future<TripItem> item(String id) =>
      (db.select(db.tripItems)..where((row) => row.id.equals(id))).getSingle();

  Future<List<List<Object?>>> contents(String tripId) async =>
      (await (db.select(db.tripItems)
                ..where((row) => row.tripId.equals(tripId))
                ..orderBy([(row) => OrderingTerm.asc(row.id)]))
              .get())
          .map(
            (row) => <Object?>[
              row.id,
              row.categoryId,
              row.name,
              row.status,
              row.quantity,
              row.deletedAt,
            ],
          )
          .toList();

  Future<void> settled(String id) => _until(() async {
    final document = await store.document(id);
    return (await store.pendingOperations(id)).isEmpty &&
        document.lastError == null &&
        document.pullCursor == document.confirmedRevision;
  });

  Future<void> close() async {
    await sync.close();
    await db.close();
  }
}

Future<void> _until(Future<bool> Function() ready) async {
  for (var i = 0; i < 500; i++) {
    if (await ready()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('La synchronisation automatique n’a pas convergé.');
}

Future<({String tripId, String itemId})> _seed(AppDatabase db) async {
  const uuid = Uuid();
  final tripId = uuid.v4();
  final memberId = uuid.v4();
  final categoryId = uuid.v4();
  final itemId = uuid.v4();
  final now = DateTime.now().toUtc();
  await db.transaction(() async {
    await db
        .into(db.trips)
        .insert(
          TripsCompanion.insert(
            id: tripId,
            name: 'Test',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await db
        .into(db.tripMembers)
        .insert(
          TripMembersCompanion.insert(
            id: memberId,
            tripId: tripId,
            groupKind: 'family',
            name: 'Membre',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await db
        .into(db.tripCategories)
        .insert(
          TripCategoriesCompanion.insert(
            id: categoryId,
            tripId: tripId,
            memberId: Value(memberId),
            name: 'Divers',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    await db
        .into(db.tripItems)
        .insert(
          TripItemsCompanion.insert(
            id: itemId,
            tripId: tripId,
            categoryId: categoryId,
            name: 'Chargeur',
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
  });
  return (tripId: tripId, itemId: itemId);
}
