import '../models/checklist_models.dart';

abstract interface class SharedDocumentRepository {
  Future<SharedDocumentAccess> shareTrip(String tripId);

  Future<SharedDocumentAccess> shareQuickList(String listId);

  Future<SharedDocumentAccess> join(String code);

  Future<void> syncDocument(String documentId);

  Future<void> syncAll();

  Stream<String?> watchError(String documentId);
}
