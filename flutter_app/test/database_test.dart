import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_local_data_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('une base vierge crée le schéma Drift v4 complet', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final names = tables.map((row) => row.read<String>('name')).toSet();

    expect(database.schemaVersion, 6);
    expect(
      names,
      containsAll(<String>{
        'installation_settings',
        'library_owners',
        'library_categories',
        'library_items',
        'trips',
        'trip_items',
        'trip_generation_choices',
        'quick_lists',
        'legacy_id_maps',
        'migration_history',
        'sync_tombstones',
        'sync_entity_states',
      }),
    );
  });

  test(
    'la migration Drift v1 vers v4 ajoute identité, contextes et sources',
    () async {
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
          _createLot4MigrationTables(raw);
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

      expect(version.read<int>('user_version'), 6);
      expect(names, contains('installation_settings'));
      expect(names, contains('sync_tombstones'));
      expect(names, contains('library_owners'));
      expect(names, contains('trip_generation_choices'));
      final columns = await database
          .customSelect('PRAGMA table_info(library_owners)')
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        contains('generation_role'),
      );
      final associationColumns = await database
          .customSelect('PRAGMA table_info(library_item_contexts)')
          .get();
      expect(
        associationColumns.map((row) => row.read<String>('name')),
        containsAll(<String>[
          'association_id',
          'sync_scope',
          'updated_at_local',
        ]),
      );
    },
  );

  test('la migration Drift v3 vers v4 conserve les propriétaires', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        raw.execute('''
          CREATE TABLE library_owners (
            id TEXT PRIMARY KEY NOT NULL,
            kind TEXT NOT NULL,
            sync_scope TEXT NOT NULL,
            generation_role TEXT NOT NULL DEFAULT 'general',
            name TEXT NOT NULL,
            icon TEXT,
            created_at INTEGER NOT NULL,
            updated_at_local INTEGER NOT NULL,
            deleted_at INTEGER
          )
        ''');
        _createLot4MigrationTables(raw);
        raw.execute('''
          INSERT INTO library_owners (
            id, kind, sync_scope, name, created_at, updated_at_local
          ) VALUES ('owner-1', 'general', 'shared_library', 'Général', 0, 0)
        ''');
        raw.execute('PRAGMA user_version = 3');
      },
    );
    final database = AppDatabase(executor);
    addTearDown(database.close);

    final owner = await database.select(database.libraryOwners).getSingle();

    expect(owner.name, 'Général');
    expect(owner.generationRole, 'general');
    expect(owner.linkedParticipantOwnerId, isNull);
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 6);
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

void _createLot4MigrationTables(dynamic raw) {
  raw.execute('''
    CREATE TABLE library_items (
      id TEXT PRIMARY KEY NOT NULL,
      category_id TEXT NOT NULL,
      name TEXT NOT NULL,
      default_quantity INTEGER NOT NULL DEFAULT 1,
      created_at INTEGER NOT NULL,
      updated_at_local INTEGER NOT NULL,
      deleted_at INTEGER
    )
  ''');
  raw.execute('''
    CREATE TABLE library_item_contexts (
      item_id TEXT NOT NULL,
      context_id TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      deleted_at INTEGER,
      PRIMARY KEY (item_id, context_id)
    )
  ''');
  raw.execute('''
    CREATE TABLE trip_item_sources (
      trip_item_id TEXT NOT NULL,
      source_library_item_id TEXT NOT NULL,
      source_kind TEXT NOT NULL,
      PRIMARY KEY (trip_item_id, source_library_item_id, source_kind)
    )
  ''');
}
