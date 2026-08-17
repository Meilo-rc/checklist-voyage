import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_local_data_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('une base vierge crée le schéma Drift v2 complet', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final names = tables.map((row) => row.read<String>('name')).toSet();

    expect(database.schemaVersion, 2);
    expect(
      names,
      containsAll(<String>{
        'installation_settings',
        'library_owners',
        'library_categories',
        'library_items',
        'trips',
        'trip_items',
        'quick_lists',
        'legacy_id_maps',
        'migration_history',
        'sync_tombstones',
      }),
    );
  });

  test('la migration Drift v1 vers v2 ajoute identité et tombstones', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        raw.execute('''
          CREATE TABLE library_owners (
            id TEXT PRIMARY KEY NOT NULL,
            kind TEXT NOT NULL,
            sync_scope TEXT NOT NULL,
            name TEXT NOT NULL,
            icon TEXT,
            created_at INTEGER NOT NULL,
            updated_at_local INTEGER NOT NULL,
            deleted_at INTEGER
          )
        ''');
        raw.execute('PRAGMA user_version = 1');
      },
    );
    final database = AppDatabase(executor);
    addTearDown(database.close);

    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    final tables = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = tables.map((row) => row.read<String>('name')).toSet();

    expect(version.read<int>('user_version'), 2);
    expect(names, contains('installation_settings'));
    expect(names, contains('sync_tombstones'));
    expect(names, contains('library_owners'));
  });

  test('l UUID installation reste stable dans une base persistante', () async {
    final directory = await Directory.systemTemp.createTemp('checklist-v1-db-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');

    final firstDatabase = AppDatabase(NativeDatabase(file));
    final firstRepository = DriftLocalDataRepository(firstDatabase);
    final firstId = await firstRepository.ensureInstallationId();
    await firstDatabase.close();

    final secondDatabase = AppDatabase(NativeDatabase(file));
    final secondRepository = DriftLocalDataRepository(secondDatabase);
    final secondId = await secondRepository.ensureInstallationId();
    await secondDatabase.close();

    expect(secondId, firstId);
    expect(firstId, matches(RegExp(r'^[0-9a-f-]{36}$')));
  });
}
