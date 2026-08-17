import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/import/web_v263_importer.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_local_data_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Uint8List fixture;

  setUpAll(() async {
    fixture = await File('test/fixtures/web_backup_v263.json').readAsBytes();
  });

  test('importe une sauvegarde Web complète dans le modèle local', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final report = await WebV263Importer(database).importBytes(fixture);

    expect(report.sourceKind, 'web_local');
    expect(report.trips, 2);
    expect(report.quickLists, 2);
    expect(report.libraryItems, 3);
    expect(report.personalOwners, 1);

    final trips = await database.select(database.trips).get();
    expect(trips, hasLength(2));
    expect(
      trips.singleWhere((trip) => trip.name == 'Voyage local').shareState,
      'local',
    );
    expect(
      trips.singleWhere((trip) => trip.name.contains('partagé')).shareState,
      'shared',
    );
    expect(
      trips.singleWhere((trip) => trip.name == 'Voyage local').shareCode,
      null,
    );

    final personal = await (database.select(
      database.libraryOwners,
    )..where((row) => row.name.equals('Moi'))).getSingle();
    expect(personal.kind, 'personal');
    expect(personal.syncScope, 'personal_local');
    expect(await database.select(database.syncOutbox).get(), isEmpty);

    final tripItems = await database.select(database.tripItems).get();
    expect(tripItems, hasLength(2));
    expect(
      tripItems.singleWhere((item) => item.name == 'Passeport').status,
      'checked',
    );
    expect(tripItems.singleWhere((item) => item.name == 'T-shirt').quantity, 4);
    expect(await database.select(database.tripItemSources).get(), hasLength(2));
  });

  test('réimporter exactement la même sauvegarde est idempotent', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final importer = WebV263Importer(database);

    final first = await importer.importBytes(fixture);
    final mapCount = await database
        .select(database.legacyIdMaps)
        .get()
        .then((rows) => rows.length);
    final second = await importer.importBytes(fixture);

    expect(first.alreadyImported, isFalse);
    expect(second.alreadyImported, isTrue);
    expect(await database.select(database.trips).get(), hasLength(2));
    expect(await database.select(database.quickLists).get(), hasLength(2));
    expect(
      await database.select(database.migrationHistory).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.legacyIdMaps).get(),
      hasLength(mapCount),
    );
  });

  test(
    'conserve les correspondances historiques sans utiliser les noms',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await WebV263Importer(database).importBytes(fixture);

      final tripMap =
          await (database.select(database.legacyIdMaps)..where(
                (row) =>
                    row.entityType.equals('trip') &
                    row.legacyId.equals('trip-local'),
              ))
              .getSingle();
      final itemMap =
          await (database.select(database.legacyIdMaps)..where(
                (row) =>
                    row.entityType.equals('library_item') &
                    row.legacyId.equals('item-passport'),
              ))
              .getSingle();

      expect(tripMap.v1Uuid, isNot('trip-local'));
      expect(itemMap.v1Uuid, isNot('item-passport'));
      expect(tripMap.jsonPath, contains('trips[0]'));
    },
  );

  test('retrouve l import et les données après redémarrage complet', () async {
    final directory = await Directory.systemTemp.createTemp(
      'checklist-v1-import-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');

    final firstDatabase = AppDatabase(NativeDatabase(file));
    final firstLocal = DriftLocalDataRepository(firstDatabase);
    final installationId = await firstLocal.ensureInstallationId();
    await WebV263Importer(firstDatabase).importBytes(fixture);
    await firstDatabase.close();

    final secondDatabase = AppDatabase(NativeDatabase(file));
    final secondLocal = DriftLocalDataRepository(secondDatabase);
    expect(await secondLocal.ensureInstallationId(), installationId);
    expect(
      await secondDatabase.select(secondDatabase.trips).get(),
      hasLength(2),
    );
    expect(
      await secondDatabase.select(secondDatabase.migrationHistory).get(),
      hasLength(1),
    );
    await secondDatabase.close();
  });

  test(
    'l import fonctionne quand toute tentative réseau est interdite',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final report = await HttpOverrides.runZoned(
        () => WebV263Importer(database).importBytes(fixture),
        createHttpClient: (_) => throw StateError('Accès réseau interdit'),
      );

      expect(report.trips, 2);
      expect(await database.select(database.trips).get(), hasLength(2));
    },
  );

  test(
    'PocketBase sélectionne les records directs et un seul agrégat canonique',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final payload = <String, Object?>{
        'schema': 'checklist-voyage-pocketbase-full-v1',
        'records': [
          {
            'id': 'settings-record',
            'code': 'PARAMS',
            'updated': '2026-08-10T00:00:00Z',
            'data': {
              'type': 'settings',
              'customCategories': [],
              'customCategoryMembers': <Object?>[],
              'customMemberGroups': <String, Object?>{},
            },
          },
          {
            'id': 'direct-trip-record',
            'code': 'DIRECT',
            'updated': '2026-08-10T00:00:00Z',
            'data': {
              'id': 'direct-trip',
              'name': 'Voyage direct',
              'members': <Object?>[],
              'categories': <Object?>[],
            },
          },
          {
            'id': 'snapshot-old',
            'code': 'STATE1',
            'updated': '2026-08-01T00:00:00Z',
            'data': {
              'voyages': [
                {
                  'id': 'obsolete-trip',
                  'name': 'Ancien',
                  'members': [],
                  'categories': [],
                },
              ],
              'quickLists': <Object?>[],
            },
          },
          {
            'id': 'snapshot-new',
            'code': 'STATE2',
            'updated': '2026-08-12T00:00:00Z',
            'data': {
              'voyages': [
                {
                  'id': 'direct-trip',
                  'name': 'Copie agrégée',
                  'members': [],
                  'categories': [],
                },
                {
                  'id': 'fallback-trip',
                  'code': 'FALLBK',
                  'name': 'Voyage canonique',
                  'members': [],
                  'categories': [],
                },
              ],
              'quickLists': [
                {
                  'id': 'fallback-list',
                  'code': 'QLIST1',
                  'name': 'Liste canonique',
                  'items': [],
                },
              ],
            },
          },
        ],
      };

      final report = await WebV263Importer(
        database,
      ).importBytes(Uint8List.fromList(utf8.encode(jsonEncode(payload))));

      expect(report.ignoredAggregateSnapshots, 1);
      expect(report.trips, 2);
      expect(report.quickLists, 1);
      expect(
        (await database.select(database.trips).get()).map((trip) => trip.name),
        containsAll(['Voyage direct', 'Voyage canonique']),
      );
      expect(
        (await database.select(database.trips).get()).every(
          (trip) => trip.shareState == 'shared',
        ),
        isTrue,
      );
    },
  );
}
