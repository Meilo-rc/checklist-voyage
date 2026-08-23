import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.dart';

AppDatabase openAppDatabase() => AppDatabase(
  driftDatabase(
    name: 'checklist_voyage_v1',
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  ),
);
