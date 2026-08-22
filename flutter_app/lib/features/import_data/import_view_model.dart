import 'package:flutter/foundation.dart';

import '../../core/presentation/user_message.dart';
import '../../domain/models/import_report.dart';
import '../../domain/usecases/import_web_backup.dart';

class ImportViewModel extends ChangeNotifier {
  ImportViewModel(this._importWebBackup);

  final ImportWebBackup _importWebBackup;

  bool _loading = false;
  ImportReport? _report;
  String? _error;

  bool get loading => _loading;
  ImportReport? get report => _report;
  String? get error => _error;

  Future<void> import(Uint8List bytes) async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _report = await _importWebBackup(bytes);
    } on Object catch (error) {
      _error = userMessageFor(error, fallback: 'Import impossible.');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
