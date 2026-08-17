import 'library_sync_store.dart';
import 'sync_models.dart';
import 'sync_remote_gateway.dart';

class LibrarySyncCoordinator {
  LibrarySyncCoordinator(this._store, this._remote);

  final LibrarySyncStore _store;
  final SyncRemoteGateway _remote;

  Stream<SyncStatusModel> watchStatus() => _store.watchStatus();

  Future<void> syncNow() async {
    await _store.setStatus('syncing');
    try {
      await _store.ensureBootstrapQueued();
      final pending = await _store.pendingOperations();
      for (final operation in pending) {
        try {
          final result = await _remote.push(operation);
          await _store.markPushConfirmed(result.remoteOperation);
        } on Object catch (error) {
          await _store.markAttemptFailed(operation.operationId, error);
          rethrow;
        }
      }

      final settings = await _store.settings();
      var cursor = settings.pullCursor;
      while (true) {
        final page = await _remote.pull(
          libraryId: settings.libraryId,
          afterRevision: cursor,
        );
        await _store.applyPullPage(page);
        if (page.operations.isEmpty || page.cursor == cursor) break;
        cursor = page.cursor;
        if (page.operations.length < 200) break;
      }
      final remaining = await _store.pendingOperations();
      await _store.setStatus(
        remaining.isEmpty ? 'synced' : 'pending',
        success: remaining.isEmpty,
      );
    } on SyncOfflineException catch (error) {
      await _store.setStatus('offline', error: error.toString());
    } on Object catch (error) {
      await _store.setStatus('error', error: error.toString());
    }
  }
}
