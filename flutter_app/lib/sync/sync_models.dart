enum SyncConnectionState { synced, syncing, pending, offline, error }

class SyncOperation {
  const SyncOperation({
    required this.operationId,
    required this.libraryId,
    required this.deviceId,
    required this.clientSequence,
    required this.clientCounter,
    required this.baseRevision,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
  });

  final String operationId;
  final String libraryId;
  final String deviceId;
  final int clientSequence;
  final int clientCounter;
  final int baseRevision;
  final String entityType;
  final String entityId;
  final String operationType;
  final Map<String, Object?> payload;

  bool get isDelete => operationType == 'delete';

  Map<String, Object?> toJson() => {
    'operation_uuid': operationId,
    'library_uuid': libraryId,
    'device_uuid': deviceId,
    'client_sequence': clientSequence,
    'client_counter': clientCounter,
    'base_revision': baseRevision,
    'entity_type': entityType,
    'entity_uuid': entityId,
    'operation_type': operationType,
    'payload': payload,
  };

  factory SyncOperation.fromJson(Map<String, Object?> json) => SyncOperation(
    operationId: json['operation_uuid']! as String,
    libraryId: json['library_uuid']! as String,
    deviceId: json['device_uuid']! as String,
    clientSequence: (json['client_sequence'] as num).toInt(),
    clientCounter: (json['client_counter'] as num).toInt(),
    baseRevision: (json['base_revision'] as num?)?.toInt() ?? 0,
    entityType: json['entity_type']! as String,
    entityId: json['entity_uuid']! as String,
    operationType: json['operation_type']! as String,
    payload: Map<String, Object?>.from(
      (json['payload'] as Map?)?.cast<String, Object?>() ?? const {},
    ),
  );
}

class RemoteOperation {
  const RemoteOperation({
    required this.operation,
    required this.serverRevision,
    required this.applied,
    this.conflictReason,
  });

  final SyncOperation operation;
  final int serverRevision;
  final bool applied;
  final String? conflictReason;

  factory RemoteOperation.fromJson(Map<String, Object?> json) =>
      RemoteOperation(
        operation: SyncOperation.fromJson(json),
        serverRevision: (json['server_revision'] as num).toInt(),
        applied: json['applied'] as bool? ?? true,
        conflictReason: json['conflict_reason'] as String?,
      );
}

class SyncPushResult {
  const SyncPushResult({required this.remoteOperation});

  final RemoteOperation remoteOperation;
}

class SyncPullPage {
  const SyncPullPage({required this.operations, required this.cursor});

  final List<RemoteOperation> operations;
  final int cursor;
}

class SyncStatusModel {
  const SyncStatusModel({
    required this.state,
    required this.pendingOperations,
    this.lastSyncAt,
    this.error,
  });

  final SyncConnectionState state;
  final int pendingOperations;
  final DateTime? lastSyncAt;
  final String? error;
}
