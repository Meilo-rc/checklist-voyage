import 'package:uuid/uuid.dart';

import 'shared_document_remote.dart';
import 'sync_models.dart';
import 'sync_remote_gateway.dart';

class InMemorySharedDocumentRemote implements SharedDocumentRemoteGateway {
  InMemorySharedDocumentRemote({this.codeGenerator});

  final Uuid _uuid = const Uuid();
  final String Function()? codeGenerator;
  final Map<String, _RemoteDocument> _documents = {};
  final Map<String, String> _codes = {};
  final Map<String, String> _capabilities = {};
  bool online = true;
  int _nextCode = 0;

  int get documentCount => _documents.length;
  bool hasDocument(String id) => _documents.containsKey(id);

  Map<String, Object?>? entityPayload(
    String documentId,
    String entityType,
    String entityId,
  ) => _documents[documentId]?.entities['$entityType:$entityId']?.payload;

  List<RemoteOperation> operations(String documentId) =>
      List.unmodifiable(_documents[documentId]?.operations ?? const []);

  @override
  Future<RemoteDocumentAccess> share({
    required String documentId,
    required String documentType,
    required String deviceId,
  }) async {
    _requireOnline();
    final current = _documents[documentId];
    if (current != null && current.type != documentType) {
      throw StateError('Type de document incompatible.');
    }
    final document =
        current ?? _RemoteDocument(type: documentType, code: _uniqueCode());
    if (current == null) {
      _documents[documentId] = document;
      _codes[document.code] = documentId;
    }
    return _access(documentId, document, deviceId);
  }

  @override
  Future<RemoteDocumentAccess> join({
    required String shareCode,
    required String deviceId,
  }) async {
    _requireOnline();
    final documentId = _codes[shareCode.toUpperCase()];
    if (documentId == null) throw const InvalidShareCodeException();
    return _access(documentId, _documents[documentId]!, deviceId);
  }

  RemoteDocumentAccess _access(
    String documentId,
    _RemoteDocument document,
    String deviceId,
  ) {
    final key = '$documentId:$deviceId';
    final token = _capabilities[key] ??= '${_uuid.v4()}${_uuid.v4()}';
    return RemoteDocumentAccess(
      documentId: documentId,
      documentType: document.type,
      shareCode: document.code,
      capabilityToken: token,
      revision: document.revision,
    );
  }

  @override
  Future<SyncPushResult> pushDocument({
    required SyncOperation operation,
    required String capabilityToken,
  }) async {
    _requireOnline();
    final document = _authorized(
      operation.libraryId,
      operation.deviceId,
      capabilityToken,
    );
    final replay = document.byOperation[operation.operationId];
    if (replay != null) return SyncPushResult(remoteOperation: replay);
    document.revision++;
    final key = '${operation.entityType}:${operation.entityId}';
    final current = document.entities[key];
    var applied = current == null;
    String? reason;
    if (current != null) {
      if (current.deleted && !operation.isDelete) {
        reason = 'tombstone_wins';
      } else if (operation.clientCounter > current.clientCounter) {
        applied = true;
      } else if (operation.clientCounter == current.clientCounter) {
        if (operation.isDelete != current.deleted) {
          applied = operation.isDelete;
        } else {
          applied = operation.deviceId.compareTo(current.deviceId) > 0;
        }
        if (!applied) reason = 'deterministic_clock_lost';
      } else {
        reason = 'deterministic_clock_lost';
      }
    }
    if (applied) {
      document.entities[key] = _RemoteEntity(
        payload: Map<String, Object?>.from(operation.payload),
        clientCounter: operation.clientCounter,
        deviceId: operation.deviceId,
        deleted: operation.isDelete,
      );
    }
    final remote = RemoteOperation(
      operation: operation,
      serverRevision: document.revision,
      applied: applied,
      conflictReason: reason,
    );
    document.operations.add(remote);
    document.byOperation[operation.operationId] = remote;
    return SyncPushResult(remoteOperation: remote);
  }

  @override
  Future<SyncPullPage> pullDocument({
    required String documentId,
    required String deviceId,
    required String capabilityToken,
    required int afterRevision,
    int limit = 200,
  }) async {
    _requireOnline();
    final document = _authorized(documentId, deviceId, capabilityToken);
    final operations = document.operations
        .where((op) => op.serverRevision > afterRevision)
        .take(limit)
        .toList(growable: false);
    return SyncPullPage(
      operations: operations,
      cursor: operations.isEmpty
          ? afterRevision
          : operations.last.serverRevision,
    );
  }

  _RemoteDocument _authorized(
    String documentId,
    String deviceId,
    String token,
  ) {
    final document = _documents[documentId];
    if (document == null || _capabilities['$documentId:$deviceId'] != token) {
      throw StateError('Capacité refusée.');
    }
    return document;
  }

  String _uniqueCode() {
    for (var attempt = 0; attempt < 20; attempt++) {
      final code = (codeGenerator?.call() ?? _sequentialCode()).toUpperCase();
      if (RegExp(r'^[A-Z2-9]{8}$').hasMatch(code) &&
          !_codes.containsKey(code)) {
        return code;
      }
    }
    throw StateError('Impossible de générer un code unique.');
  }

  String _sequentialCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    var value = ++_nextCode;
    final buffer = StringBuffer();
    for (var i = 0; i < 8; i++) {
      buffer.write(alphabet[value % alphabet.length]);
      value ~/= alphabet.length;
    }
    return buffer.toString();
  }

  void _requireOnline() {
    if (!online) throw const SyncOfflineException();
  }
}

class _RemoteDocument {
  _RemoteDocument({required this.type, required this.code});

  final String type;
  final String code;
  int revision = 0;
  final Map<String, _RemoteEntity> entities = {};
  final List<RemoteOperation> operations = [];
  final Map<String, RemoteOperation> byOperation = {};
}

class _RemoteEntity {
  const _RemoteEntity({
    required this.payload,
    required this.clientCounter,
    required this.deviceId,
    required this.deleted,
  });

  final Map<String, Object?> payload;
  final int clientCounter;
  final String deviceId;
  final bool deleted;
}
