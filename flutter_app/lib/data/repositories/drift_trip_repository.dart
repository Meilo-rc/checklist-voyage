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
              tis.source_library_item_id, 0, NULL
            FROM trip_item_sources tis
            INNER JOIN trip_items ti ON ti.id = tis.trip_item_id
            WHERE ti.trip_id = ?
          ''',
          variables: List.generate(5, (_) => Variable.withString(tripId)),
          readsFrom: {
            _database.trips,
            _database.tripMembers,
            _database.tripCategories,
            _database.tripItems,
            _database.tripItemSources,
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
                sourceLibraryItemIds: sources
                    .where((source) => source.tripItemId == item.id)
                    .map((source) => source.sourceLibraryItemId)
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

      final owners = await (_database.select(
        _database.libraryOwners,
      )..where((row) => row.deletedAt.isNull())).get();
      final selected =
          owners.where((owner) {
            if (request.includeEssentials &&
                owner.generationRole == 'essential') {
              return true;
            }
            if (owner.generationRole == 'participant') {
              return request.participantOwnerIds.contains(owner.id) &&
                  owner.kind == 'family_member';
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

      for (final owner in selected) {
        await _copyOwnerIntoTrip(tripId, owner, now);
      }
    });
    return tripId;
  }

  Future<void> _copyOwnerIntoTrip(
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
    final categories =
        await (_database.select(_database.libraryCategories)
              ..where(
                (row) => row.ownerId.equals(owner.id) & row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    for (final sourceCategory in categories) {
      final categoryId = _uuid.v4();
      await _database
          .into(_database.tripCategories)
          .insert(
            TripCategoriesCompanion.insert(
              id: categoryId,
              tripId: tripId,
              memberId: Value(memberId),
              sourceCategoryId: Value(sourceCategory.id),
              name: sourceCategory.name,
              icon: Value(sourceCategory.icon),
              createdAt: now,
              updatedAtLocal: now,
            ),
          );
      final sourceItems =
          await (_database.select(_database.libraryItems)
                ..where(
                  (row) =>
                      row.categoryId.equals(sourceCategory.id) &
                      row.deletedAt.isNull(),
                )
                ..orderBy([(row) => OrderingTerm.asc(row.name)]))
              .get();
      for (final sourceItem in sourceItems) {
        final itemId = _uuid.v4();
        await _database
            .into(_database.tripItems)
            .insert(
              TripItemsCompanion.insert(
                id: itemId,
                tripId: tripId,
                categoryId: categoryId,
                name: sourceItem.name,
                quantity: Value(sourceItem.defaultQuantity.clamp(1, 99)),
                status: const Value('todo'),
                createdAt: now,
                updatedAtLocal: now,
              ),
            );
        await _database
            .into(_database.tripItemSources)
            .insert(
              TripItemSourcesCompanion.insert(
                tripItemId: itemId,
                sourceLibraryItemId: sourceItem.id,
                sourceKind: _sourceKind(owner.generationRole),
              ),
            );
      }
    }
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

TripItemStatus _tripStatus(String value) => switch (value) {
  'checked' => TripItemStatus.checked,
  'done' => TripItemStatus.done,
  _ => TripItemStatus.todo,
};

String _sourceKind(String role) => switch (role) {
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
