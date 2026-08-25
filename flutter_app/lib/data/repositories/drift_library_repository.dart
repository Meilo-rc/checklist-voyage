import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/repositories/library_repository.dart';
import '../local/app_database.dart';
import '../../sync/library_sync_store.dart';

class DriftLibraryRepository implements LibraryRepository {
  DriftLibraryRepository(
    this._database, {
    this._uuid = const Uuid(),
    LibrarySyncStore? syncStore,
  }) : _sync = syncStore ?? LibrarySyncStore(_database, enabled: false);

  final AppDatabase _database;
  final Uuid _uuid;
  final LibrarySyncStore _sync;

  @override
  Stream<List<LibraryOwnerSummary>> watchOwners() {
    final query = _database.select(_database.libraryOwners)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => LibraryOwnerSummary(
              id: row.id,
              name: row.name,
              personal: row.syncScope == 'personal_local',
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Stream<List<LibraryOwnerModel>> watchLibrary() {
    return _database
        .customSelect(
          '''
            SELECT 'owner:' || id AS entity_key, updated_at_local, deleted_at
            FROM library_owners
            UNION ALL
            SELECT 'category:' || id, updated_at_local, deleted_at
            FROM library_categories
            UNION ALL
            SELECT 'item:' || id, updated_at_local, deleted_at
            FROM library_items
          ''',
          readsFrom: {
            _database.libraryOwners,
            _database.libraryCategories,
            _database.libraryItems,
          },
        )
        .watch()
        .asyncMap((_) => loadLibrary());
  }

  @override
  Future<List<LibraryOwnerModel>> loadLibrary() async {
    final owners =
        await (_database.select(_database.libraryOwners)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    final categories =
        await (_database.select(_database.libraryCategories)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    final items =
        await (_database.select(_database.libraryItems)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();

    return owners
        .map(
          (owner) => LibraryOwnerModel(
            id: owner.id,
            name: owner.name,
            kind: _ownerKind(owner.kind),
            generationRole: _generationRole(owner.generationRole),
            linkedParticipantOwnerId: owner.linkedParticipantOwnerId,
            categories: categories
                .where((category) => category.ownerId == owner.id)
                .map(
                  (category) => LibraryCategoryModel(
                    id: category.id,
                    name: category.name,
                    icon: category.icon,
                    items: items
                        .where((item) => item.categoryId == category.id)
                        .map(
                          (item) => LibraryItemModel(
                            id: item.id,
                            name: item.name,
                            defaultQuantity: item.defaultQuantity,
                            logicalSourceId: item.logicalSourceId ?? item.id,
                          ),
                        )
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<String> createOwner({
    required String name,
    required LibraryOwnerKind kind,
    required GenerationRole generationRole,
    String? linkedParticipantOwnerId,
  }) async {
    final cleanName = _requiredName(name);
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      if (linkedParticipantOwnerId != null) {
        final linked =
            await (_database.select(_database.libraryOwners)..where(
                  (row) =>
                      row.id.equals(linkedParticipantOwnerId) &
                      row.kind.equals('family_member') &
                      row.deletedAt.isNull(),
                ))
                .getSingle();
        if (kind != LibraryOwnerKind.personal ||
            linked.kind != 'family_member') {
          throw ArgumentError('Le lien Personnel doit cibler un membre.');
        }
      }
      await _database
          .into(_database.libraryOwners)
          .insert(
            LibraryOwnersCompanion.insert(
              id: id,
              kind: _ownerKindValue(kind),
              syncScope: kind == LibraryOwnerKind.personal
                  ? 'personal_local'
                  : 'shared_library',
              generationRole: Value(_generationRoleValue(kind, generationRole)),
              name: cleanName,
              linkedParticipantOwnerId: Value(
                kind == LibraryOwnerKind.personal
                    ? linkedParticipantOwnerId
                    : null,
              ),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      await _sync.recordUpsert('library_owner', id, {
        'name': cleanName,
        'kind': _ownerKindValue(kind),
        'sync_scope': kind == LibraryOwnerKind.personal
            ? 'personal_local'
            : 'shared_library',
        'generation_role': _generationRoleValue(kind, generationRole),
        'icon': null,
      });
    });
    return id;
  }

  @override
  Future<void> renameOwner(String ownerId, String name) async {
    await _database.transaction(() async {
      await (_database.update(
        _database.libraryOwners,
      )..where((row) => row.id.equals(ownerId) & row.deletedAt.isNull())).write(
        LibraryOwnersCompanion(
          name: Value(_requiredName(name)),
          updatedAtLocal: Value(DateTime.now().toUtc()),
        ),
      );
      await _sync.recordUpsert(
        'library_owner',
        ownerId,
        await _sync.payloadFor('library_owner', ownerId),
      );
    });
  }

  @override
  Future<void> setLinkedParticipantOwner(
    String ownerId,
    String? participantOwnerId,
  ) async {
    await _database.transaction(() async {
      await (_database.select(_database.libraryOwners)..where(
            (row) =>
                row.id.equals(ownerId) &
                row.kind.equals('personal') &
                row.deletedAt.isNull(),
          ))
          .getSingle();
      if (participantOwnerId != null) {
        await (_database.select(_database.libraryOwners)..where(
              (row) =>
                  row.id.equals(participantOwnerId) &
                  row.kind.equals('family_member') &
                  row.deletedAt.isNull(),
            ))
            .getSingle();
      }
      await (_database.update(
        _database.libraryOwners,
      )..where((row) => row.id.equals(ownerId))).write(
        LibraryOwnersCompanion(
          linkedParticipantOwnerId: Value(participantOwnerId),
          updatedAtLocal: Value(DateTime.now().toUtc()),
        ),
      );
    });
  }

  @override
  Future<void> deleteOwner(String ownerId) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final owner = await (_database.select(
        _database.libraryOwners,
      )..where((row) => row.id.equals(ownerId))).getSingle();
      final categories = await (_database.select(
        _database.libraryCategories,
      )..where((row) => row.ownerId.equals(ownerId))).get();
      final categoryIds = categories.map((category) => category.id).toList();
      final items = categoryIds.isEmpty
          ? <LibraryItem>[]
          : await (_database.select(
              _database.libraryItems,
            )..where((row) => row.categoryId.isIn(categoryIds))).get();

      await (_database.update(
        _database.libraryOwners,
      )..where((row) => row.id.equals(ownerId))).write(
        LibraryOwnersCompanion(
          deletedAt: Value(now),
          updatedAtLocal: Value(now),
        ),
      );
      await (_database.update(
        _database.libraryCategories,
      )..where((row) => row.ownerId.equals(ownerId))).write(
        LibraryCategoriesCompanion(
          deletedAt: Value(now),
          updatedAtLocal: Value(now),
        ),
      );
      if (categoryIds.isNotEmpty) {
        await (_database.update(
          _database.libraryItems,
        )..where((row) => row.categoryId.isIn(categoryIds))).write(
          LibraryItemsCompanion(
            deletedAt: Value(now),
            updatedAtLocal: Value(now),
          ),
        );
      }
      await _softDeleteContextAssociations(items.map((item) => item.id), now);
      if (owner.syncScope == 'shared_library') {
        await _trackTombstone('library_owner', ownerId, now);
        for (final category in categories) {
          await _trackTombstone('library_category', category.id, now);
        }
        for (final item in items) {
          await _trackTombstone('library_item', item.id, now);
        }
        for (final item in items) {
          await _sync.recordDelete('library_item', item.id);
        }
        for (final category in categories) {
          await _sync.recordDelete('library_category', category.id);
        }
        await _sync.recordDelete('library_owner', ownerId);
      }
    });
  }

  @override
  Future<String> createCategory(String ownerId, String name) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await (_database.select(_database.libraryOwners)
            ..where((row) => row.id.equals(ownerId) & row.deletedAt.isNull()))
          .getSingle();
      await _database
          .into(_database.libraryCategories)
          .insert(
            LibraryCategoriesCompanion.insert(
              id: id,
              ownerId: ownerId,
              name: _requiredName(name),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      await _sync.recordUpsert('library_category', id, {
        'owner_id': ownerId,
        'name': _requiredName(name),
        'icon': null,
      });
    });
    return id;
  }

  @override
  Future<void> renameCategory(String categoryId, String name) async {
    await _database.transaction(() async {
      await (_database.update(
            _database.libraryCategories,
          )..where((row) => row.id.equals(categoryId) & row.deletedAt.isNull()))
          .write(
            LibraryCategoriesCompanion(
              name: Value(_requiredName(name)),
              updatedAtLocal: Value(DateTime.now().toUtc()),
            ),
          );
      await _sync.recordUpsert(
        'library_category',
        categoryId,
        await _sync.payloadFor('library_category', categoryId),
      );
    });
  }

  @override
  Future<void> setCategoryIcon(String categoryId, String? icon) async {
    await _database.transaction(() async {
      await (_database.update(
            _database.libraryCategories,
          )..where((row) => row.id.equals(categoryId) & row.deletedAt.isNull()))
          .write(
            LibraryCategoriesCompanion(
              icon: Value(icon),
              updatedAtLocal: Value(DateTime.now().toUtc()),
            ),
          );
      await _sync.recordUpsert(
        'library_category',
        categoryId,
        await _sync.payloadFor('library_category', categoryId),
      );
    });
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final category = await (_database.select(
        _database.libraryCategories,
      )..where((row) => row.id.equals(categoryId))).getSingle();
      final owner = await (_database.select(
        _database.libraryOwners,
      )..where((row) => row.id.equals(category.ownerId))).getSingle();
      final items = await (_database.select(
        _database.libraryItems,
      )..where((row) => row.categoryId.equals(categoryId))).get();
      await (_database.update(
        _database.libraryCategories,
      )..where((row) => row.id.equals(categoryId))).write(
        LibraryCategoriesCompanion(
          deletedAt: Value(now),
          updatedAtLocal: Value(now),
        ),
      );
      await (_database.update(
        _database.libraryItems,
      )..where((row) => row.categoryId.equals(categoryId))).write(
        LibraryItemsCompanion(
          deletedAt: Value(now),
          updatedAtLocal: Value(now),
        ),
      );
      await _softDeleteContextAssociations(items.map((item) => item.id), now);
      if (owner.syncScope == 'shared_library') {
        await _trackTombstone('library_category', categoryId, now);
        for (final item in items) {
          await _trackTombstone('library_item', item.id, now);
          await _sync.recordDelete('library_item', item.id);
        }
        await _sync.recordDelete('library_category', categoryId);
      }
    });
  }

  @override
  Future<String> createItem({
    required String categoryId,
    required String name,
    required int defaultQuantity,
    String? logicalSourceId,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await (_database.select(
            _database.libraryCategories,
          )..where((row) => row.id.equals(categoryId) & row.deletedAt.isNull()))
          .getSingle();
      await _database
          .into(_database.libraryItems)
          .insert(
            LibraryItemsCompanion.insert(
              id: id,
              categoryId: categoryId,
              name: _requiredName(name),
              defaultQuantity: Value(_quantity(defaultQuantity)),
              logicalSourceId: Value(logicalSourceId ?? id),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      await _sync.recordUpsert('library_item', id, {
        'category_id': categoryId,
        'name': _requiredName(name),
        'default_quantity': _quantity(defaultQuantity),
        'logical_source_id': logicalSourceId ?? id,
      });
    });
    return id;
  }

  @override
  Future<void> updateItem({
    required String itemId,
    required String name,
    required int defaultQuantity,
  }) async {
    await _database.transaction(() async {
      await (_database.update(
        _database.libraryItems,
      )..where((row) => row.id.equals(itemId) & row.deletedAt.isNull())).write(
        LibraryItemsCompanion(
          name: Value(_requiredName(name)),
          defaultQuantity: Value(_quantity(defaultQuantity)),
          updatedAtLocal: Value(DateTime.now().toUtc()),
        ),
      );
      await _sync.recordUpsert(
        'library_item',
        itemId,
        await _sync.payloadFor('library_item', itemId),
      );
    });
  }

  @override
  Future<void> deleteItem(String itemId) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final item = await (_database.select(
        _database.libraryItems,
      )..where((row) => row.id.equals(itemId))).getSingle();
      final category = await (_database.select(
        _database.libraryCategories,
      )..where((row) => row.id.equals(item.categoryId))).getSingle();
      final owner = await (_database.select(
        _database.libraryOwners,
      )..where((row) => row.id.equals(category.ownerId))).getSingle();
      await (_database.update(
        _database.libraryItems,
      )..where((row) => row.id.equals(itemId))).write(
        LibraryItemsCompanion(
          deletedAt: Value(now),
          updatedAtLocal: Value(now),
        ),
      );
      await _softDeleteContextAssociations([itemId], now);
      if (owner.syncScope == 'shared_library') {
        await _trackTombstone('library_item', itemId, now);
        await _sync.recordDelete('library_item', itemId);
      }
    });
  }

  Future<void> _softDeleteContextAssociations(
    Iterable<String> itemIds,
    DateTime now,
  ) async {
    final ids = itemIds.toSet();
    if (ids.isEmpty) return;
    final associations = await (_database.select(
      _database.libraryItemContexts,
    )..where((row) => row.itemId.isIn(ids) & row.deletedAt.isNull())).get();
    await (_database.update(
      _database.libraryItemContexts,
    )..where((row) => row.itemId.isIn(ids) & row.deletedAt.isNull())).write(
      LibraryItemContextsCompanion(
        deletedAt: Value(now),
        updatedAtLocal: Value(now),
      ),
    );
    for (final association in associations) {
      if (association.syncScope == 'shared_library' &&
          association.associationId != null) {
        await _trackTombstone(
          'context_association',
          association.associationId!,
          now,
        );
        await _sync.recordDelete(
          'context_association',
          association.associationId!,
        );
      }
    }
  }

  Future<void> _trackTombstone(
    String entityType,
    String entityId,
    DateTime deletedAt,
  ) {
    return _database
        .into(_database.syncTombstones)
        .insertOnConflictUpdate(
          SyncTombstonesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            deletedAt: deletedAt,
            purgeEligibleAt: deletedAt.add(const Duration(days: 90)),
          ),
        );
  }
}

String _requiredName(String value) {
  final clean = value.trim();
  if (clean.isEmpty) throw ArgumentError.value(value, 'name', 'Nom requis');
  return clean;
}

int _quantity(int value) => value.clamp(1, 99);

LibraryOwnerKind _ownerKind(String value) => switch (value) {
  'personal' => LibraryOwnerKind.personal,
  'family_member' => LibraryOwnerKind.familyMember,
  _ => LibraryOwnerKind.general,
};

String _ownerKindValue(LibraryOwnerKind value) => switch (value) {
  LibraryOwnerKind.general => 'general',
  LibraryOwnerKind.familyMember => 'family_member',
  LibraryOwnerKind.personal => 'personal',
};

GenerationRole _generationRole(String value) => switch (value) {
  'essential' => GenerationRole.essential,
  'participant' => GenerationRole.participant,
  'transport' => GenerationRole.transport,
  'lodging' => GenerationRole.lodging,
  _ => GenerationRole.general,
};

String _generationRoleValue(LibraryOwnerKind kind, GenerationRole role) {
  if (kind != LibraryOwnerKind.general) return 'participant';
  return switch (role) {
    GenerationRole.essential => 'essential',
    GenerationRole.transport => 'transport',
    GenerationRole.lodging => 'lodging',
    _ => 'general',
  };
}
