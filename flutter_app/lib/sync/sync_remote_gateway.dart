import 'sync_models.dart';

abstract interface class SyncRemoteGateway {
  Future<SyncPushResult> push(SyncOperation operation);

  Future<SyncPullPage> pull({
    required String libraryId,
    required int afterRevision,
    int limit = 200,
  });
}

class SyncOfflineException implements Exception {
  const SyncOfflineException([this.message = 'Réseau indisponible.']);

  final String message;

  @override
  String toString() => message;
}
