import 'sync_models.dart';

class RemoteDocumentAccess {
  const RemoteDocumentAccess({
    required this.documentId,
    required this.documentType,
    required this.shareCode,
    required this.capabilityToken,
    required this.revision,
  });

  final String documentId;
  final String documentType;
  final String shareCode;
  final String capabilityToken;
  final int revision;

  factory RemoteDocumentAccess.fromJson(Map<String, Object?> json) =>
      RemoteDocumentAccess(
        documentId: json['document_uuid']! as String,
        documentType: json['document_type']! as String,
        shareCode: json['share_code']! as String,
        capabilityToken: json['capability_token']! as String,
        revision: (json['revision'] as num?)?.toInt() ?? 0,
      );
}

abstract interface class SharedDocumentRemoteGateway {
  Future<RemoteDocumentAccess> share({
    required String documentId,
    required String documentType,
    required String deviceId,
  });

  Future<RemoteDocumentAccess> join({
    required String shareCode,
    required String deviceId,
  });

  Future<SyncPushResult> pushDocument({
    required SyncOperation operation,
    required String capabilityToken,
  });

  Future<SyncPullPage> pullDocument({
    required String documentId,
    required String deviceId,
    required String capabilityToken,
    required int afterRevision,
    int limit = 200,
  });
}

class InvalidShareCodeException implements Exception {
  const InvalidShareCodeException([this.message = 'Code de partage invalide.']);

  final String message;

  @override
  String toString() => message;
}
