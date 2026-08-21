import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/import/web_v263_importer.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_local_data_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/sync/library_sync_store.dart';

void main() {
  test(
    'un import idempotent préserve UUID et données manuelles sur base non vide',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'checklist-lot11c-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');
      final database = AppDatabase(NativeDatabase(file));
      final localData = DriftLocalDataRepository(database);
      final installationId = await localData.ensureInstallationId();
      final library = DriftLibraryRepository(database);
      final manualOwnerId = await library.createOwner(
        name: 'Groupe manuel distinct',
        kind: LibraryOwnerKind.general,
        generationRole: GenerationRole.general,
      );
      final manualCategoryId = await library.createCategory(
        manualOwnerId,
        'Catégorie manuelle',
      );
      final manualItemId = await library.createItem(
        categoryId: manualCategoryId,
        name: 'Item manuel',
        defaultQuantity: 3,
      );
      final payload = utf8.encode(
        jsonEncode({
          'schema': 'checklist-voyage-backup-v1',
          'data': {
            'customCategoryMembers': ['Général', 'Moi'],
            'customMemberGroups': {'Général': 'general', 'Moi': 'personal'},
            'customCategories': [
              {
                'id': 'legacy-general-category',
                'member': 'Général',
                'name': 'Documents',
                'items': [
                  {'id': 'legacy-passport', 'name': 'Passeport', 'qty': 2},
                ],
              },
              {
                'id': 'legacy-personal-category',
                'member': 'Moi',
                'name': 'Privé',
                'items': [
                  {'id': 'legacy-private-item', 'name': 'Item privé', 'qty': 1},
                ],
              },
            ],
          },
        }),
      );
      final importer = WebV263Importer(database);

      final first = await importer.importBytes(payload);
      final second = await importer.importBytes(payload);

      expect(first.alreadyImported, isFalse);
      expect(second.alreadyImported, isTrue);
      expect(await localData.getInstallationId(), installationId);
      expect(
        await (database.select(
          database.libraryOwners,
        )..where((row) => row.id.equals(manualOwnerId))).getSingle(),
        isNotNull,
      );
      expect(
        await (database.select(
          database.libraryCategories,
        )..where((row) => row.id.equals(manualCategoryId))).getSingle(),
        isNotNull,
      );
      final manualItem = await (database.select(
        database.libraryItems,
      )..where((row) => row.id.equals(manualItemId))).getSingle();
      expect(manualItem.defaultQuantity, 3);
      expect(
        await database.select(database.migrationHistory).get(),
        hasLength(1),
      );
      expect(await database.select(database.syncOutbox).get(), isEmpty);

      await LibrarySyncStore(database).ensureBootstrapQueued();
      final personalIds = await database.customSelect('''
        SELECT o.id FROM library_owners o
        WHERE o.sync_scope = 'personal_local'
        UNION ALL
        SELECT c.id FROM library_categories c
        JOIN library_owners o ON o.id = c.owner_id
        WHERE o.sync_scope = 'personal_local'
        UNION ALL
        SELECT i.id FROM library_items i
        JOIN library_categories c ON c.id = i.category_id
        JOIN library_owners o ON o.id = c.owner_id
        WHERE o.sync_scope = 'personal_local'
      ''').get();
      final personalIdSet = personalIds
          .map((row) => row.read<String>('id'))
          .toSet();
      final queuedIds = (await database.select(database.syncOutbox).get())
          .map((row) => row.entityId)
          .toSet();
      expect(queuedIds, isNotEmpty);
      expect(queuedIds.intersection(personalIdSet), isEmpty);

      await database.close();
      final reopened = AppDatabase(NativeDatabase(file));
      expect(
        await DriftLocalDataRepository(reopened).getInstallationId(),
        installationId,
      );
      expect(
        await (reopened.select(
          reopened.libraryItems,
        )..where((row) => row.id.equals(manualItemId))).getSingle(),
        isNotNull,
      );
      expect(
        await reopened.select(reopened.migrationHistory).get(),
        hasLength(1),
      );
      await reopened.close();
    },
  );

  test(
    'le bootstrap ignore et purge les descendants de parents tombstones',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await DriftLocalDataRepository(database).ensureInstallationId();
      final now = DateTime.now().toUtc();
      final deletedAt = now.subtract(const Duration(days: 1));

      Future<int> insertOwner(String id, {DateTime? deleted}) => database
          .into(database.libraryOwners)
          .insert(
            LibraryOwnersCompanion.insert(
              id: id,
              kind: 'general',
              syncScope: 'shared_library',
              generationRole: const Value('general'),
              name: id,
              createdAt: now,
              updatedAtLocal: now,
              deletedAt: Value(deleted),
            ),
          );
      Future<int> insertCategory(
        String id,
        String ownerId, {
        DateTime? deleted,
      }) => database
          .into(database.libraryCategories)
          .insert(
            LibraryCategoriesCompanion.insert(
              id: id,
              ownerId: ownerId,
              name: id,
              createdAt: now,
              updatedAtLocal: now,
              deletedAt: Value(deleted),
            ),
          );
      Future<int> insertItem(String id, String categoryId) => database
          .into(database.libraryItems)
          .insert(
            LibraryItemsCompanion.insert(
              id: id,
              categoryId: categoryId,
              name: id,
              createdAt: now,
              updatedAtLocal: now,
            ),
          );

      await insertOwner('owner-active');
      await insertCategory('category-active', 'owner-active');
      await insertItem('item-active', 'category-active');
      await insertOwner('owner-deleted', deleted: deletedAt);
      await insertCategory('category-orphaned', 'owner-deleted');
      await insertItem('item-orphaned', 'category-orphaned');
      await insertCategory(
        'category-deleted',
        'owner-active',
        deleted: deletedAt,
      );
      await insertItem('item-under-deleted-category', 'category-deleted');

      final store = LibrarySyncStore(database);
      await store.recordUpsert('library_category', 'category-orphaned', {
        'owner_id': 'owner-deleted',
        'name': 'category-orphaned',
      });
      await store.recordUpsert('library_item', 'item-orphaned', {
        'category_id': 'category-orphaned',
        'name': 'item-orphaned',
        'default_quantity': 1,
      });
      await store.recordUpsert('library_item', 'item-under-deleted-category', {
        'category_id': 'category-deleted',
        'name': 'item-under-deleted-category',
        'default_quantity': 1,
      });

      await store.ensureBootstrapQueued();
      final queuedIds = (await database.select(database.syncOutbox).get())
          .map((row) => row.entityId)
          .toSet();
      expect(
        queuedIds,
        containsAll(<String>{'owner-active', 'category-active', 'item-active'}),
      );
      expect(
        queuedIds.intersection(<String>{
          'owner-deleted',
          'category-orphaned',
          'item-orphaned',
          'category-deleted',
          'item-under-deleted-category',
        }),
        isEmpty,
      );
    },
  );

  final realLibraryPath =
      Platform.environment['CHECKLIST_V1_REAL_LIBRARY_BACKUP'];
  test(
    'l export réel de bibliothèque est importable à blanc',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final report = await WebV263Importer(
        database,
      ).importBytes(await File(realLibraryPath!).readAsBytes());

      expect(report.sourceKind, 'web_local');
      expect(report.categories, greaterThan(0));
      expect(report.libraryItems, greaterThan(0));
      expect(report.trips, 0);
      expect(report.quickLists, 0);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
    skip: realLibraryPath == null
        ? 'Définir CHECKLIST_V1_REAL_LIBRARY_BACKUP pour ce contrôle ponctuel.'
        : false,
  );
}
