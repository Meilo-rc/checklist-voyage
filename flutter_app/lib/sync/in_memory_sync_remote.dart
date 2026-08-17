import 'sync_models.dart';
import 'sync_remote_gateway.dart';

class InMemorySyncRemote implements SyncRemoteGateway {
  bool online = true;
  int duplicatePushes = 0;

  final Map<String, RemoteOperation> _operationsById = {};
  final Map<String, _RemoteEntity> _entities = {};
  final List<RemoteOperation> _journal = [];
  int _revision = 0;

  List<RemoteOperation> get journal => List.unmodifiable(_journal);

  Iterable<RemoteOperation> operationsForType(String entityType) =>
      _journal.where((entry) => entry.operation.entityType == entityType);

  @override
  Future<SyncPushResult> push(SyncOperation operation) async {
    if (!online) throw const SyncOfflineException();
    final existingOperation = _operationsById[operation.operationId];
    if (existingOperation != null) {
      duplicatePushes += 1;
      return SyncPushResult(remoteOperation: existingOperation);
    }

    final key =
        '${operation.libraryId}:${operation.entityType}:${operation.entityId}';
    final current = _entities[key];
    final wins = _wins(operation, current);
    final revision = ++_revision;
    final reason = wins
        ? null
        : current?.deleted == true && !operation.isDelete
        ? 'tombstone_wins'
        : 'deterministic_clock_lost';
    final remote = RemoteOperation(
      operation: operation,
      serverRevision: revision,
      applied: wins,
      conflictReason: reason,
    );
    _operationsById[operation.operationId] = remote;
    _journal.add(remote);
    if (wins) {
      _entities[key] = _RemoteEntity(
        counter: operation.clientCounter,
        deviceId: operation.deviceId,
        deleted: operation.isDelete,
      );
    }
    return SyncPushResult(remoteOperation: remote);
  }

  bool _wins(SyncOperation incoming, _RemoteEntity? current) {
    if (current == null) return true;
    if (current.deleted && !incoming.isDelete) return false;
    if (incoming.clientCounter != current.counter) {
      return incoming.clientCounter > current.counter;
    }
    if (incoming.isDelete != current.deleted) return incoming.isDelete;
    return incoming.deviceId.compareTo(current.deviceId) > 0;
  }

  @override
  Future<SyncPullPage> pull({
    required String libraryId,
    required int afterRevision,
    int limit = 200,
  }) async {
    if (!online) throw const SyncOfflineException();
    final result = _journal
        .where(
          (entry) =>
              entry.operation.libraryId == libraryId &&
              entry.serverRevision > afterRevision,
        )
        .take(limit)
        .toList(growable: false);
    return SyncPullPage(
      operations: result,
      cursor: result.isEmpty ? afterRevision : result.last.serverRevision,
    );
  }
}

class _RemoteEntity {
  const _RemoteEntity({
    required this.counter,
    required this.deviceId,
    required this.deleted,
  });

  final int counter;
  final String deviceId;
  final bool deleted;
}
