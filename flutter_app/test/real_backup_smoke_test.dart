import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/import/web_v263_importer.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';

void main() {
  final backupPath = Platform.environment['CHECKLIST_V1_REAL_BACKUP'];

  test(
    'importe à blanc une sauvegarde réelle fournie par environnement',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final report = await WebV263Importer(
        database,
      ).importBytes(await File(backupPath!).readAsBytes());

      expect(report.sourceKind, 'pocketbase');
      expect(report.trips, greaterThan(0));
      expect(report.sharedDocuments, report.trips + report.quickLists);
      expect(report.localDocuments, 0);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
      expect(
        (await database.select(database.trips).get()).every(
          (trip) => trip.shareState == 'shared',
        ),
        isTrue,
      );
    },
    skip: backupPath == null
        ? 'Définir CHECKLIST_V1_REAL_BACKUP pour le contrôle ponctuel.'
        : false,
  );
}
