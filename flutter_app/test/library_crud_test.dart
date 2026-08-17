import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/data/local/app_database.dart';
import 'package:checklist_voyage_v1/data/repositories/drift_library_repository.dart';
import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';

void main() {
  test('CRUD Général, Membres et Personnel respecte les portées', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftLibraryRepository(database);

    final general = await repository.createOwner(
      name: 'Essentiel',
      kind: LibraryOwnerKind.general,
      generationRole: GenerationRole.essential,
    );
    final member = await repository.createOwner(
      name: 'Alex',
      kind: LibraryOwnerKind.familyMember,
      generationRole: GenerationRole.participant,
    );
    final personal = await repository.createOwner(
      name: 'Privé',
      kind: LibraryOwnerKind.personal,
      generationRole: GenerationRole.participant,
    );
    final category = await repository.createCategory(personal, 'Personnel');
    final item = await repository.createItem(
      categoryId: category,
      name: 'Objet privé',
      defaultQuantity: 150,
    );
    await repository.updateItem(
      itemId: item,
      name: 'Objet privé renommé',
      defaultQuantity: 0,
    );
    await repository.setLinkedParticipantOwner(personal, member);

    final rows = await database.select(database.libraryOwners).get();
    expect(
      rows.singleWhere((row) => row.id == general).syncScope,
      'shared_library',
    );
    expect(rows.singleWhere((row) => row.id == member).kind, 'family_member');
    expect(
      rows.singleWhere((row) => row.id == personal).syncScope,
      'personal_local',
    );
    expect(
      rows.singleWhere((row) => row.id == personal).linkedParticipantOwnerId,
      member,
    );
    expect(
      rows.singleWhere((row) => row.id == general).generationRole,
      'essential',
    );
    expect(
      (await database.select(database.libraryItems).getSingle())
          .defaultQuantity,
      1,
    );

    await repository.deleteItem(item);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
    expect(await database.select(database.syncDocuments).get(), isEmpty);
    expect(await database.select(database.syncTombstones).get(), isEmpty);
    expect(
      (await database.select(database.libraryItems).getSingle()).deletedAt,
      isNotNull,
    );
  });

  test(
    'suppression partagée crée des tombstones sans opération réseau',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftLibraryRepository(database);
      final owner = await repository.createOwner(
        name: 'Essentiel',
        kind: LibraryOwnerKind.general,
        generationRole: GenerationRole.essential,
      );
      final category = await repository.createCategory(owner, 'Documents');
      await repository.createItem(
        categoryId: category,
        name: 'Passeport',
        defaultQuantity: 1,
      );

      await repository.deleteOwner(owner);

      expect(await repository.loadLibrary(), isEmpty);
      expect(
        await database.select(database.syncTombstones).get(),
        hasLength(3),
      );
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
  );

  test(
    'une transaction refuse une catégorie orpheline sans écriture partielle',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftLibraryRepository(database);

      await expectLater(
        repository.createCategory('owner-absent', 'Orpheline'),
        throwsA(anything),
      );
      expect(await database.select(database.libraryCategories).get(), isEmpty);
    },
  );
}
