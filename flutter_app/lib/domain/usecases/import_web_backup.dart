import 'dart:typed_data';

import '../models/import_report.dart';
import '../repositories/web_import_repository.dart';

class ImportWebBackup {
  const ImportWebBackup(this._repository);

  final WebImportRepository _repository;

  Future<ImportReport> call(Uint8List bytes) => _repository.importBytes(bytes);
}
