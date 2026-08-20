import '../models/checklist_models.dart';
import '../repositories/shared_document_repository.dart';

class SharedDocumentUseCases {
  const SharedDocumentUseCases(this._repository);

  final SharedDocumentRepository _repository;

  Future<SharedDocumentAccess> shareTrip(String tripId) =>
      _repository.shareTrip(tripId);

  Future<SharedDocumentAccess> shareQuickList(String listId) =>
      _repository.shareQuickList(listId);

  Future<SharedDocumentAccess> join(String code) => _repository.join(code);

  Future<void> syncAll() => _repository.syncAll();
}
