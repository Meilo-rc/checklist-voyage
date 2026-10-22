import 'dart:async';

import '../domain/models/checklist_models.dart';
import '../domain/repositories/shared_document_repository.dart';
import 'shared_document_remote.dart';
import 'shared_document_sync_store.dart';

class SharedDocumentSyncCoordinator implements SharedDocumentRepository {
  SharedDocumentSyncCoordinator(
    this._store,
    this._remote, {
    List<Duration> retryDelays = const [
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 15),
      Duration(seconds: 30),
      Duration(minutes: 1),
    ],
  }) : assert(retryDelays.isNotEmpty),
       _retryDelays = List.unmodifiable(retryDelays),
       _syncZone = Zone.current;

  final SharedDocumentSyncStore _store;
  final SharedDocumentRemoteGateway _remote;
  // Capturée à la création, en dehors des transactions des repositories.
  final Zone _syncZone;
  final List<Duration> _retryDelays;
  final Map<String, Future<void>> _syncTails = {};
  final Set<String> _requestedDocuments = {};
  final Map<String, Timer> _scheduledDocuments = {};
  final Map<String, Timer> _retryTimers = {};
  final Map<String, int> _retryAttempts = {};
  bool _foreground = true;
  bool _closed = false;

  @override
  Stream<String?> watchError(String documentId) =>
      _store.watchError(documentId);

  void setForeground(bool foreground) {
    if (_closed || _foreground == foreground) return;
    _foreground = foreground;
    if (!foreground) {
      _cancelTimers();
    } else {
      // Chaque document garde sa propre erreur et sa nouvelle tentative.
      _syncZone.run(() => unawaited(syncAll().catchError((Object _) {})));
    }
  }

  void _cancelTimers() {
    for (final timer in [
      ..._scheduledDocuments.values,
      ..._retryTimers.values,
    ]) {
      timer.cancel();
    }
    _scheduledDocuments.clear();
    _retryTimers.clear();
  }

  Future<void> close() async {
    _closed = true;
    _foreground = false;
    _cancelTimers();
    await Future.wait(
      _syncTails.values.map((work) => work.catchError((Object _) {})),
    );
  }

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
    if (_closed || !_foreground) return;
    await Future.wait(
      (await _store.sharedDocuments()).map(
        (document) => syncDocument(document.documentId),
      ),
    );
  }

  @override
  Future<void> syncDocument(String documentId) => _syncZone.run(() {
    if (_closed || !_foreground) return Future<void>.value();
    _scheduledDocuments.remove(documentId)?.cancel();
    final running = _syncTails[documentId];
    if (running != null) {
      _requestedDocuments.add(documentId);
      return running;
    }
    _retryTimers.remove(documentId)?.cancel();
    final completion = Completer<void>();
    _syncTails[documentId] = completion.future;
    unawaited(_runDocument(documentId, completion));
    return completion.future;
  });

  Future<void> _runDocument(
    String documentId,
    Completer<void> completion,
  ) async {
    try {
      do {
        _requestedDocuments.remove(documentId);
        await _syncDocument(documentId);
      } while (!_closed &&
          _foreground &&
          _requestedDocuments.contains(documentId));
      _retryAttempts.remove(documentId);
      completion.complete();
    } on Object catch (error, stack) {
      _scheduleRetry(documentId);
      completion.completeError(error, stack);
    } finally {
      _syncTails.remove(documentId);
    }
  }

  /// Regroupe les taps rapides et quitte le contexte transactionnel Drift.
  /// La première lecture attend ainsi le commit avant tout appel réseau.
  void scheduleDocumentSync(String documentId) {
    if (_closed ||
        !_foreground ||
        _scheduledDocuments.containsKey(documentId)) {
      return;
    }
    _syncZone.run(() {
      _scheduledDocuments[documentId] = Timer(
        const Duration(milliseconds: 100),
        () {
          _scheduledDocuments.remove(documentId);
          unawaited(syncDocument(documentId).catchError((Object _) {}));
        },
      );
    });
  }

  void _scheduleRetry(String documentId) {
    if (_closed || !_foreground || _retryTimers.containsKey(documentId)) return;
    final attempt = _retryAttempts[documentId] ?? 0;
    _retryAttempts[documentId] = attempt + 1;
    final delay = _retryDelays[attempt.clamp(0, _retryDelays.length - 1)];
    _retryTimers[documentId] = Timer(delay, () {
      _retryTimers.remove(documentId);
      unawaited(syncDocument(documentId).catchError((Object _) {}));
    });
  }

  Future<void> _syncDocument(String documentId) async {
    try {
      while (!_closed && _foreground) {
        final document = await _store.documentOrNull(documentId);
        if (document == null) return;
        final token = document.capabilityToken;
        if (token == null || token.isEmpty) return;
        final installation = await _store.installation();
        // Inclut les mutations arrivées pendant un envoi déjà en cours.
        while (!_closed && _foreground) {
          final pending = await _store.pendingOperations(documentId);
          if (pending.isEmpty) break;
          for (final operation in pending) {
            if (_closed || !_foreground) return;
            final result = await _remote.pushDocument(
              operation: operation,
              capabilityToken: token,
            );
            await _store.markPushConfirmed(result.remoteOperation);
          }
        }
        var cursor = (await _store.document(documentId)).pullCursor;
        var localChangesArrived = false;
        while (!_closed && _foreground) {
          final page = await _remote.pullDocument(
            documentId: documentId,
            deviceId: installation.installationId,
            capabilityToken: token,
            afterRevision: cursor,
          );
          if (_closed || !_foreground) return;
          if (!await _store.applyPullPage(documentId, page)) {
            localChangesArrived = true;
            break;
          }
          if (page.operations.isEmpty || page.cursor == cursor) return;
          cursor = page.cursor;
          if (page.operations.length < 200) return;
        }
        if (!localChangesArrived) return;
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
