import 'dart:typed_data';

import '../models/import_report.dart';

abstract interface class WebImportRepository {
  Future<ImportReport> importBytes(Uint8List bytes);
}
