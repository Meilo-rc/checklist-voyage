import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_context_repository.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';

void main() {
  test(
    'CRUD contextes et associations multiples respectent les portées',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final library = DriftLibraryRepository(database);
      final contexts = DriftContextRepository(database);
      final fixture = await _seedOwners(library);

      final beach = await contexts.createContext('Plage');
      final pool = await contexts.createContext('Bassin');
      await contexts.renameContext(pool, 'Piscine');
      await contexts.setItemContexts(fixture.generalItem, {beach, pool});
      await contexts.setItemContexts(fixture.memberItem, {beach});
      await contexts.setItemContexts(fixture.personalItem, {beach});

      expect((await contexts.loadContexts()).map((context) => context.name), [
        'Piscine',
        'Plage',
      ]);
      expect(await contexts.loadContextIdsForItem(fixture.generalItem), {
        beach,
        pool,
      });
      final associations = await database
          .select(database.libraryItemContexts)
          .get();
      expect(associations, hasLength(4));
      expect(
        associations
            .where((row) => row.itemId == fixture.personalItem)
            .single
            .syncScope,
        'personal_local',
      );
      expect(
        associations
            .where((row) => row.itemId != fixture.personalItem)
            .every((row) => row.syncScope == 'shared_library'),
        isTrue,
      );
      expect(
        associations.every(
          (row) => row.associationId != null && row.associationId!.length == 36,
        ),
        isTrue,
      );
      expect(await database.select(database.syncOutbox).get(), isEmpty);

      await contexts.setItemContexts(fixture.generalItem, {pool});
      expect(await contexts.loadContextIdsForItem(fixture.generalItem), {pool});

      final personalAssociationId = associations
          .where((row) => row.itemId == fixture.personalItem)
          .single
          .associationId;
      await contexts.deleteContext(beach);

      expect((await contexts.loadContexts()).single.name, 'Piscine');
      expect(await database.select(database.libraryItems).get(), hasLength(3));
      final beachAssociations = await (database.select(
        database.libraryItemContexts,
      )..where((row) => row.contextId.equals(beach))).get();
      expect(beachAssociations.every((row) => row.deletedAt != null), isTrue);
      final tombstones = await database.select(database.syncTombstones).get();
      expect(
        tombstones.where((row) => row.entityType == 'context'),
        hasLength(1),
      );
      expect(
        tombstones.where((row) => row.entityType == 'context_association'),
        hasLength(2),
      );
      expect(
        tombstones.any((row) => row.entityId == personalAssociationId),
        isFalse,
      );
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
  );

  test('contextes et associations persistent après redémarrage', () async {
    final directory = await Directory.systemTemp.createTemp('contexts-v1-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');

    var database = AppDatabase(NativeDatabase(file));
    var library = DriftLibraryRepository(database);
    var contexts = DriftContextRepository(database);
    final fixture = await _seedOwners(library);
    final hiking = await contexts.createContext('Randonnée');
    await contexts.setItemContexts(fixture.generalItem, {hiking});
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    contexts = DriftContextRepository(database);
    addTearDown(database.close);

    expect((await contexts.loadContexts()).single.id, hiking);
    expect(await contexts.loadContextIdsForItem(fixture.generalItem), {hiking});
  });
}

class _OwnerFixture {
  const _OwnerFixture({
    required this.generalItem,
    required this.memberItem,
    required this.personalItem,
  });

  final String generalItem;
  final String memberItem;
  final String personalItem;
}

Future<_OwnerFixture> _seedOwners(DriftLibraryRepository library) async {
  final general = await library.createOwner(
    name: 'Général',
    kind: LibraryOwnerKind.general,
    generationRole: GenerationRole.general,
  );
  final member = await library.createOwner(
    name: 'Malone',
    kind: LibraryOwnerKind.familyMember,
    generationRole: GenerationRole.participant,
  );
  final personal = await library.createOwner(
    name: 'Personnel Malone',
    kind: LibraryOwnerKind.personal,
    generationRole: GenerationRole.participant,
    linkedParticipantOwnerId: member,
  );
  final generalCategory = await library.createCategory(general, 'Accessoires');
  final memberCategory = await library.createCategory(member, 'Vêtements');
  final personalCategory = await library.createCategory(personal, 'Personnel');
  return _OwnerFixture(
    generalItem: await library.createItem(
      categoryId: generalCategory,
      name: 'Parasol',
      defaultQuantity: 1,
    ),
    memberItem: await library.createItem(
      categoryId: memberCategory,
      name: 'Maillot',
      defaultQuantity: 1,
    ),
    personalItem: await library.createItem(
      categoryId: personalCategory,
      name: 'Lunettes',
      defaultQuantity: 1,
    ),
  );
}
