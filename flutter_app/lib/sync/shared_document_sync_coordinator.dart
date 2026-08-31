import 'dart:async';

import '../domain/models/checklist_models.dart';
import '../domain/repositories/shared_document_repository.dart';
import 'shared_document_remote.dart';
import 'shared_document_sync_store.dart';

class SharedDocumentSyncCoordinator implements SharedDocumentRepository {
  SharedDocumentSyncCoordinator(this._store, this._remote);

  final SharedDocumentSyncStore _store;
  final SharedDocumentRemoteGateway _remote;
  final Map<String, Future<void>> _syncTails = {};
  final Set<String> _scheduledDocuments = {};

  @override
  Future<SharedDocumentAccess> shareTrip(String tripId) =>
      _share(tripId, 'trip');

  @override
  Future<SharedDocumentAccess> shareQuickList(String listId) =>
      _share(listId, 'quick_list');

  Future<SharedDocumentAccess> _share(String id, String type) async {
    final installation = await _store.installation();
    final access = await _remote.share(
      documentId: id,
      documentType: type,
      deviceId: installation.installationId,
    );
    await _store.registerCreator(access);
    await _store.ensureBootstrapQueued(id);
    await syncDocument(id);
    return _access(access);
  }

  @override
  Future<SharedDocumentAccess> join(String code) async {
    final clean = code.trim().toUpperCase();
    if (!RegExp(r'^[A-Z2-9]{8}$').hasMatch(clean)) {
      throw const InvalidShareCodeException();
    }
    final installation = await _store.installation();
    final access = await _remote.join(
      shareCode: clean,
      deviceId: installation.installationId,
    );
    await _store.registerJoin(access);
    await syncDocument(access.documentId);
    return _access(access);
  }

  @override
  Future<void> syncAll() async {
    for (final document in await _store.sharedDocuments()) {
      await syncDocument(document.documentId);
    }
  }

  @override
  Future<void> syncDocument(String documentId) {
    final previous = _syncTails[documentId] ?? Future<void>.value();
    final next = previous
        .catchError((Object _) {})
        .then<void>((_) => _syncDocument(documentId));
    _syncTails[documentId] = next;
    return next.whenComplete(() {
      if (identical(_syncTails[documentId], next)) {
        _syncTails.remove(documentId);
      }
    });
  }

  /// Regroupe les mutations d'une même boucle d'événements, puis tente une
  /// synchronisation sans bloquer l'écriture locale ni propager l'erreur à l'UI.
  void scheduleDocumentSync(String documentId) {
    if (!_scheduledDocuments.add(documentId)) return;
    Timer.run(() {
      _scheduledDocuments.remove(documentId);
      unawaited(syncDocument(documentId).catchError((Object _) {}));
    });
  }

  Future<void> _syncDocument(String documentId) async {
    final document = await _store.documentOrNull(documentId);
    if (document == null) return;
    final token = document.capabilityToken;
    if (token == null || token.isEmpty) return;
    final installation = await _store.installation();
    try {
      for (final operation in await _store.pendingOperations(documentId)) {
        final result = await _remote.pushDocument(
          operation: operation,
          capabilityToken: token,
        );
        await _store.markPushConfirmed(result.remoteOperation);
      }
      var cursor = document.pullCursor;
      while (true) {
        final page = await _remote.pullDocument(
          documentId: documentId,
          deviceId: installation.installationId,
          capabilityToken: token,
          afterRevision: cursor,
        );
        await _store.applyPullPage(documentId, page);
        if (page.operations.isEmpty || page.cursor == cursor) break;
        cursor = page.cursor;
        if (page.operations.length < 200) break;
      }
    } on Object catch (error) {
      await _store.markError(documentId, error);
      rethrow;
    }
  }

  SharedDocumentAccess _access(RemoteDocumentAccess access) =>
      SharedDocumentAccess(
        documentId: access.documentId,
        documentType: access.documentType == 'trip'
            ? SharedDocumentType.trip
            : SharedDocumentType.quickList,
        shareCode: access.shareCode,
      );
}
