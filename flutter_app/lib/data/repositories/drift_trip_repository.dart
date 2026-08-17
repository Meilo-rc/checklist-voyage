import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/checklist_models.dart';
import '../../domain/models/destination_summaries.dart';
import '../../domain/repositories/trip_repository.dart';
import '../local/app_database.dart';

class DriftTripRepository implements TripRepository {
  DriftTripRepository(this._database, {this._uuid = const Uuid()});

  final AppDatabase _database;
  final Uuid _uuid;

  @override
  Stream<List<TripSummary>> watchTrips() {
    final query = _database.select(_database.trips)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAtLocal)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => TripSummary(
              id: row.id,
              name: row.name,
              shared: row.shareState == 'shared',
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Stream<TripDetailModel?> watchTrip(String tripId) {
    return _database
        .customSelect(
          '''
            SELECT 'trip:' || id AS entity_key, updated_at_local, deleted_at
            FROM trips
            WHERE id = ?
            UNION ALL
            SELECT 'member:' || id, updated_at_local, deleted_at
            FROM trip_members
            WHERE trip_id = ?
            UNION ALL
            SELECT 'category:' || id, updated_at_local, deleted_at
            FROM trip_categories
            WHERE trip_id = ?
            UNION ALL
            SELECT 'item:' || id, updated_at_local, deleted_at
            FROM trip_items
            WHERE trip_id = ?
            UNION ALL
            SELECT 'source:' || tis.trip_item_id || ':' ||
              tis.source_library_item_id || ':' || tis.source_kind, 0, NULL
            FROM trip_item_sources tis
            INNER JOIN trip_items ti ON ti.id = tis.trip_item_id
            WHERE ti.trip_id = ?
            UNION ALL
            SELECT 'choice:' || id, created_at, deleted_at
            FROM trip_generation_choices
            WHERE trip_id = ?
          ''',
          variables: List.generate(6, (_) => Variable.withString(tripId)),
          readsFrom: {
            _database.trips,
            _database.tripMembers,
            _database.tripCategories,
            _database.tripItems,
            _database.tripItemSources,
            _database.tripGenerationChoices,
          },
        )
        .watch()
        .asyncMap((_) => loadTrip(tripId));
  }

  @override
  Future<TripDetailModel?> loadTrip(String tripId) async {
    final trip =
        await (_database.select(_database.trips)
              ..where((row) => row.id.equals(tripId) & row.deletedAt.isNull()))
            .getSingleOrNull();
    if (trip == null) return null;
    final members =
        await (_database.select(_database.tripMembers)
              ..where(
                (row) => row.tripId.equals(tripId) & row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    final categories =
        await (_database.select(_database.tripCategories)
              ..where(
                (row) => row.tripId.equals(tripId) & row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    final items =
        await (_database.select(_database.tripItems)
              ..where(
                (row) => row.tripId.equals(tripId) & row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    final itemIds = items.map((item) => item.id).toList(growable: false);
    final sources = itemIds.isEmpty
        ? <TripItemSource>[]
        : await (_database.select(
            _database.tripItemSources,
          )..where((row) => row.tripItemId.isIn(itemIds))).get();
    final choices =
        await (_database.select(_database.tripGenerationChoices)..where(
              (row) => row.tripId.equals(tripId) & row.deletedAt.isNull(),
            ))
            .get();

    TripCategoryModel mapCategory(TripCategory category) {
      return TripCategoryModel(
        id: category.id,
        name: category.name,
        items: items
            .where((item) => item.categoryId == category.id)
            .map(
              (item) => TripItemModel(
                id: item.id,
                name: item.name,
                quantity: item.quantity,
                status: _tripStatus(item.status),
                sources: sources
                    .where((source) => source.tripItemId == item.id)
                    .map(_sourceModel)
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
      );
    }

    final mappedMembers = members
        .map(
          (member) => TripMemberModel(
            id: member.id,
            name: member.name,
            sourceOwnerId: member.sourceOwnerId,
            categories: categories
                .where((category) => category.memberId == member.id)
                .map(mapCategory)
                .toList(growable: false),
          ),
        )
        .toList();
    final generalCategories = categories
        .where((category) => category.memberId == null)
        .map(mapCategory)
        .toList(growable: false);
    if (generalCategories.isNotEmpty) {
      mappedMembers.insert(
        0,
        TripMemberModel(
          id: 'general-$tripId',
          name: 'Général',
          sourceOwnerId: null,
          categories: generalCategories,
        ),
      );
    }

    return TripDetailModel(
      id: trip.id,
      name: trip.name,
      destination: _destinationName(trip.destinationJson),
      startDate: trip.startDate,
      endDate: trip.endDate,
      selectedContextIds: choices
          .where((choice) => choice.choiceKind == 'context')
          .map((choice) => choice.choiceId)
          .toSet(),
      members: mappedMembers,
    );
  }

  @override
  Future<String> createTrip(CreateTripRequest request) async {
    if (request.endDate != null &&
        request.startDate != null &&
        request.endDate!.isBefore(request.startDate!)) {
      throw ArgumentError('La date de fin précède la date de début.');
    }
    final tripId = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final snapshot = await _loadLibrarySnapshot();
      _validateOwnerChoices(snapshot.owners, request);
      await _validateContexts(request.contextIds);

      await _database
          .into(_database.trips)
          .insert(
            TripsCompanion.insert(
              id: tripId,
              name: _tripName(request),
              destinationJson: Value(
                request.destination.trim().isEmpty
                    ? null
                    : jsonEncode({'name': request.destination.trim()}),
              ),
              startDate: Value(request.startDate?.toUtc()),
              endDate: Value(request.endDate?.toUtc()),
              shareState: const Value('local'),
              remoteRecordId: const Value(null),
              shareCode: const Value(null),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      await _storeChoices(tripId, request, now);

      final contributions = _buildContributions(snapshot, request);
      final compacted = <String, _CompactedItem>{};
      for (final contribution in contributions) {
        compacted
            .putIfAbsent(
              contribution.logicalSourceId,
              () => _CompactedItem(contribution),
            )
            .addReason(contribution.reason);
      }
      await _writeCompactedItems(tripId, compacted.values, now);
    });
    return tripId;
  }

  Future<_LibrarySnapshot> _loadLibrarySnapshot() async {
    final owners = await (_database.select(
      _database.libraryOwners,
    )..where((row) => row.deletedAt.isNull())).get();
    final categories = await (_database.select(
      _database.libraryCategories,
    )..where((row) => row.deletedAt.isNull())).get();
    final items = await (_database.select(
      _database.libraryItems,
    )..where((row) => row.deletedAt.isNull())).get();
    final associations = await (_database.select(
      _database.libraryItemContexts,
    )..where((row) => row.deletedAt.isNull())).get();
    return _LibrarySnapshot(owners, categories, items, associations);
  }

  void _validateOwnerChoices(
    List<LibraryOwner> owners,
    CreateTripRequest request,
  ) {
    final byId = {for (final owner in owners) owner.id: owner};

    bool valid(Set<String> ids, bool Function(LibraryOwner) accepts) =>
        ids.every((id) => byId[id] != null && accepts(byId[id]!));

    if (!valid(
      request.participantOwnerIds,
      (owner) =>
          owner.kind == 'family_member' &&
          owner.generationRole == 'participant',
    )) {
      throw ArgumentError('Participant invalide.');
    }
    if (!valid(
      request.transportOwnerIds,
      (owner) => owner.generationRole == 'transport',
    )) {
      throw ArgumentError('Transport invalide.');
    }
    if (!valid(
      request.lodgingOwnerIds,
      (owner) => owner.generationRole == 'lodging',
    )) {
      throw ArgumentError('Logement invalide.');
    }
  }

  Future<void> _validateContexts(Set<String> contextIds) async {
    if (contextIds.isEmpty) return;
    final contexts = await (_database.select(
      _database.contexts,
    )..where((row) => row.id.isIn(contextIds) & row.deletedAt.isNull())).get();
    if (contexts.length != contextIds.length) {
      throw ArgumentError('Contexte invalide.');
    }
  }

  Future<void> _storeChoices(
    String tripId,
    CreateTripRequest request,
    DateTime now,
  ) async {
    for (final entry in <MapEntry<String, Set<String>>>[
      MapEntry('participant', request.participantOwnerIds),
      MapEntry('transport', request.transportOwnerIds),
      MapEntry('lodging', request.lodgingOwnerIds),
      MapEntry('context', request.contextIds),
    ]) {
      for (final choiceId in entry.value.toList()..sort()) {
        await _database
            .into(_database.tripGenerationChoices)
            .insert(
              TripGenerationChoicesCompanion.insert(
                id: _uuid.v4(),
                tripId: tripId,
                choiceKind: entry.key,
                choiceId: choiceId,
                createdAt: now,
              ),
            );
      }
    }
  }

  List<_Contribution> _buildContributions(
    _LibrarySnapshot snapshot,
    CreateTripRequest request,
  ) {
    final result = <_Contribution>[];
    final owners =
        snapshot.owners.where((owner) {
          if (request.includeEssentials &&
              owner.generationRole == 'essential') {
            return true;
          }
          if (owner.generationRole == 'participant') {
            return owner.kind == 'family_member' &&
                request.participantOwnerIds.contains(owner.id);
          }
          if (owner.generationRole == 'transport') {
            return request.transportOwnerIds.contains(owner.id);
          }
          if (owner.generationRole == 'lodging') {
            return request.lodgingOwnerIds.contains(owner.id);
          }
          return false;
        }).toList()..sort((a, b) {
          final role = _roleRank(
            a.generationRole,
          ).compareTo(_roleRank(b.generationRole));
          return role != 0 ? role : a.name.compareTo(b.name);
        });

    for (final owner in owners) {
      final reasonKind = _reasonKindForRole(owner.generationRole);
      for (final item in snapshot.itemsForOwner(owner.id)) {
        result.add(
          snapshot.contribution(
            item: item,
            targetOwner: owner,
            reason: _Reason(reasonKind, owner.id, item.id),
          ),
        );
      }
    }

    if (request.contextIds.isEmpty) return result;
    final contextAssociations =
        snapshot.associations
            .where(
              (association) =>
                  request.contextIds.contains(association.contextId),
            )
            .toList()
          ..sort((a, b) {
            final context = a.contextId.compareTo(b.contextId);
            return context != 0 ? context : a.itemId.compareTo(b.itemId);
          });
    for (final association in contextAssociations) {
      final item = snapshot.itemById[association.itemId];
      if (item == null) continue;
      final category = snapshot.categoryById[item.categoryId];
      if (category == null) continue;
      final owner = snapshot.ownerById[category.ownerId];
      if (owner == null) continue;

      LibraryOwner? targetOwner;
      if (owner.kind == 'family_member') {
        if (request.participantOwnerIds.contains(owner.id)) {
          targetOwner = owner;
        }
      } else if (owner.kind == 'personal') {
        final linkedId = owner.linkedParticipantOwnerId;
        if (linkedId != null &&
            request.participantOwnerIds.contains(linkedId)) {
          targetOwner = snapshot.ownerById[linkedId];
        }
      } else {
        targetOwner = owner;
      }
      if (targetOwner == null) continue;

      result.add(
        snapshot.contribution(
          item: item,
          targetOwner: targetOwner,
          reason: _Reason('context', association.contextId, item.id),
        ),
      );
    }
    return result;
  }

  Future<void> _writeCompactedItems(
    String tripId,
    Iterable<_CompactedItem> compacted,
    DateTime now,
  ) async {
    final memberIds = <String, String>{};
    final categoryIds = <String, String>{};
    for (final compactedItem in compacted) {
      final contribution = compactedItem.first;
      final owner = contribution.targetOwner;
      final memberId = memberIds[owner.id] ??= await _insertMember(
        tripId,
        owner,
        now,
      );
      final categoryKey = '${owner.id}:${contribution.category.id}';
      final categoryId = categoryIds[categoryKey] ??= await _insertCategory(
        tripId,
        memberId,
        contribution.category,
        now,
      );
      final tripItemId = _uuid.v4();
      await _database
          .into(_database.tripItems)
          .insert(
            TripItemsCompanion.insert(
              id: tripItemId,
              tripId: tripId,
              categoryId: categoryId,
              name: contribution.item.name,
              quantity: Value(contribution.item.defaultQuantity.clamp(1, 99)),
              status: const Value('todo'),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      for (final reason in compactedItem.reasons) {
        await _database
            .into(_database.tripItemSources)
            .insert(
              TripItemSourcesCompanion.insert(
                tripItemId: tripItemId,
                sourceLibraryItemId: contribution.logicalSourceId,
                sourceKind: '${reason.kind}:${reason.id}',
                reasonKind: Value(reason.kind),
                reasonId: Value(reason.id),
                contributingLibraryItemId: Value(
                  reason.contributingLibraryItemId,
                ),
              ),
            );
      }
    }
  }

  Future<String> _insertMember(
    String tripId,
    LibraryOwner owner,
    DateTime now,
  ) async {
    final memberId = _uuid.v4();
    await _database
        .into(_database.tripMembers)
        .insert(
          TripMembersCompanion.insert(
            id: memberId,
            tripId: tripId,
            sourceOwnerId: Value(owner.id),
            groupKind: owner.kind == 'family_member' ? 'family' : 'general',
            name: owner.name,
            icon: Value(owner.icon),
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    return memberId;
  }

  Future<String> _insertCategory(
    String tripId,
    String memberId,
    LibraryCategory category,
    DateTime now,
  ) async {
    final categoryId = _uuid.v4();
    await _database
        .into(_database.tripCategories)
        .insert(
          TripCategoriesCompanion.insert(
            id: categoryId,
            tripId: tripId,
            memberId: Value(memberId),
            sourceCategoryId: Value(category.id),
            name: category.name,
            icon: Value(category.icon),
            createdAt: now,
            updatedAtLocal: now,
          ),
        );
    return categoryId;
  }

  @override
  Future<void> cycleItemStatus(String itemId) async {
    await _database.transaction(() async {
      final item =
          await (_database.select(
                _database.tripItems,
              )..where((row) => row.id.equals(itemId) & row.deletedAt.isNull()))
              .getSingle();
      final next = switch (item.status) {
        'todo' => 'checked',
        'checked' => 'done',
        _ => 'todo',
      };
      final now = DateTime.now().toUtc();
      await (_database.update(
        _database.tripItems,
      )..where((row) => row.id.equals(itemId))).write(
        TripItemsCompanion(status: Value(next), updatedAtLocal: Value(now)),
      );
      await _touchTrip(item.tripId, now);
    });
  }

  @override
  Future<void> changeItemQuantity(String itemId, int delta) async {
    await _database.transaction(() async {
      final item =
          await (_database.select(
                _database.tripItems,
              )..where((row) => row.id.equals(itemId) & row.deletedAt.isNull()))
              .getSingle();
      final now = DateTime.now().toUtc();
      await (_database.update(
        _database.tripItems,
      )..where((row) => row.id.equals(itemId))).write(
        TripItemsCompanion(
          quantity: Value((item.quantity + delta).clamp(1, 99)),
          updatedAtLocal: Value(now),
        ),
      );
      await _touchTrip(item.tripId, now);
    });
  }

  @override
  Future<void> removeItem(String itemId) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      final item =
          await (_database.select(
                _database.tripItems,
              )..where((row) => row.id.equals(itemId) & row.deletedAt.isNull()))
              .getSingle();
      final trip = await (_database.select(
        _database.trips,
      )..where((row) => row.id.equals(item.tripId))).getSingle();
      await (_database.update(
        _database.tripItems,
      )..where((row) => row.id.equals(itemId))).write(
        TripItemsCompanion(deletedAt: Value(now), updatedAtLocal: Value(now)),
      );
      await _touchTrip(item.tripId, now);
      if (trip.shareState == 'shared') {
        await _database
            .into(_database.syncTombstones)
            .insertOnConflictUpdate(
              SyncTombstonesCompanion.insert(
                entityType: 'trip_item',
                entityId: itemId,
                deletedAt: now,
                purgeEligibleAt: now.add(const Duration(days: 90)),
              ),
            );
      }
    });
  }

  Future<void> _touchTrip(String tripId, DateTime now) {
    return (_database.update(_database.trips)
          ..where((row) => row.id.equals(tripId)))
        .write(TripsCompanion(updatedAtLocal: Value(now)));
  }
}

class _LibrarySnapshot {
  _LibrarySnapshot(this.owners, this.categories, this.items, this.associations)
    : ownerById = {for (final owner in owners) owner.id: owner},
      categoryById = {for (final category in categories) category.id: category},
      itemById = {for (final item in items) item.id: item};

  final List<LibraryOwner> owners;
  final List<LibraryCategory> categories;
  final List<LibraryItem> items;
  final List<LibraryItemContext> associations;
  final Map<String, LibraryOwner> ownerById;
  final Map<String, LibraryCategory> categoryById;
  final Map<String, LibraryItem> itemById;

  Iterable<LibraryItem> itemsForOwner(String ownerId) {
    final categoryIds = categories
        .where((category) => category.ownerId == ownerId)
        .map((category) => category.id)
        .toSet();
    return items.where((item) => categoryIds.contains(item.categoryId));
  }

  _Contribution contribution({
    required LibraryItem item,
    required LibraryOwner targetOwner,
    required _Reason reason,
  }) {
    return _Contribution(
      item: item,
      category: categoryById[item.categoryId]!,
      targetOwner: targetOwner,
      logicalSourceId: item.logicalSourceId ?? item.id,
      reason: reason,
    );
  }
}

class _Contribution {
  const _Contribution({
    required this.item,
    required this.category,
    required this.targetOwner,
    required this.logicalSourceId,
    required this.reason,
  });

  final LibraryItem item;
  final LibraryCategory category;
  final LibraryOwner targetOwner;
  final String logicalSourceId;
  final _Reason reason;
}

class _CompactedItem {
  _CompactedItem(this.first);

  final _Contribution first;
  final List<_Reason> reasons = [];

  void addReason(_Reason reason) {
    if (reasons.any(
      (existing) => existing.kind == reason.kind && existing.id == reason.id,
    )) {
      return;
    }
    reasons.add(reason);
  }
}

class _Reason {
  const _Reason(this.kind, this.id, this.contributingLibraryItemId);

  final String kind;
  final String id;
  final String contributingLibraryItemId;
}

TripItemSourceModel _sourceModel(TripItemSource source) {
  final legacyKind = source.reasonKind == 'legacy'
      ? _legacyReasonKind(source.sourceKind)
      : source.reasonKind;
  return TripItemSourceModel(
    logicalSourceId: source.sourceLibraryItemId,
    reasonKind: _reasonKind(legacyKind),
    reasonId: source.reasonId,
    contributingLibraryItemId: source.contributingLibraryItemId,
  );
}

GenerationReasonKind _reasonKind(String value) => switch (value) {
  'essential' => GenerationReasonKind.essential,
  'participant' => GenerationReasonKind.participant,
  'transport' => GenerationReasonKind.transport,
  'lodging' => GenerationReasonKind.lodging,
  'context' => GenerationReasonKind.context,
  _ => GenerationReasonKind.legacy,
};

String _legacyReasonKind(String value) => value.split(':').first;

TripItemStatus _tripStatus(String value) => switch (value) {
  'checked' => TripItemStatus.checked,
  'done' => TripItemStatus.done,
  _ => TripItemStatus.todo,
};

String _reasonKindForRole(String role) => switch (role) {
  'essential' => 'essential',
  'transport' => 'transport',
  'lodging' => 'lodging',
  _ => 'participant',
};

int _roleRank(String role) => switch (role) {
  'essential' => 0,
  'participant' => 1,
  'transport' => 2,
  'lodging' => 3,
  _ => 4,
};

String _tripName(CreateTripRequest request) {
  final name = request.name.trim();
  if (name.isNotEmpty) return name;
  final destination = request.destination.trim();
  return destination.isEmpty ? 'Nouveau voyage' : destination;
}

String _destinationName(String? destinationJson) {
  if (destinationJson == null || destinationJson.isEmpty) return '';
  try {
    final value = jsonDecode(destinationJson);
    if (value is Map) return value['name']?.toString() ?? '';
  } on FormatException {
    return destinationJson;
  }
  return '';
}
