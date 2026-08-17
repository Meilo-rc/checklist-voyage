import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/import_report.dart';
import '../../domain/repositories/web_import_repository.dart';
import '../local/app_database.dart';

const _webSchema = 'checklist-voyage-backup-v1';
const _pocketBaseSchema = 'checklist-voyage-pocketbase-full-v1';
const _uuidNamespace = 'f928e2e0-0d9b-5cc7-a55e-81f30ca2f231';

class WebV263Importer implements WebImportRepository {
  WebV263Importer(this._database, {this._uuid = const Uuid()});

  final AppDatabase _database;
  final Uuid _uuid;

  @override
  Future<ImportReport> importBytes(Uint8List bytes) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on Object catch (error) {
      throw FormatException('Sauvegarde JSON invalide.', error);
    }
    if (decoded is! Map<String, Object?>) {
      throw const FormatException(
        'La racine de la sauvegarde doit être un objet.',
      );
    }

    final schema = _string(decoded['schema']);
    final sourceKind = schema == _pocketBaseSchema ? 'pocketbase' : 'web_local';
    if (schema.isNotEmpty &&
        schema != _webSchema &&
        schema != _pocketBaseSchema) {
      throw FormatException(
        'Schéma de sauvegarde non pris en charge : $schema',
      );
    }
    final sourceSha = sha256.convert(bytes).toString();

    final existing =
        await (_database.select(_database.migrationHistory)..where(
              (row) =>
                  row.sourceKind.equals(sourceKind) &
                  row.sourceSha256.equals(sourceSha),
            ))
            .getSingleOrNull();
    if (existing != null) {
      final reportJson = jsonDecode(existing.reportJson);
      return ImportReport.fromJson(
        (reportJson as Map).cast<String, Object?>(),
      ).asAlreadyImported();
    }

    final input = schema == _pocketBaseSchema
        ? _canonicalPocketBaseInput(decoded)
        : _canonicalWebInput(decoded);
    final importedAt = DateTime.now().toUtc();
    late ImportReport report;

    await _database.transaction(() async {
      final counters = _Counters(
        ignoredAggregateSnapshots: input.ignoredAggregateSnapshots,
        warnings: [...input.warnings],
      );
      await _importLibrary(
        input,
        sourceKind: sourceKind,
        sourceSha: sourceSha,
        importedAt: importedAt,
        counters: counters,
      );
      for (var index = 0; index < input.trips.length; index++) {
        await _importTrip(
          input.trips[index],
          sourceKind: sourceKind,
          sourceSha: sourceSha,
          path: 'trips[$index]',
          importedAt: importedAt,
          counters: counters,
        );
      }
      for (var index = 0; index < input.quickLists.length; index++) {
        await _importQuickList(
          input.quickLists[index],
          sourceKind: sourceKind,
          sourceSha: sourceSha,
          path: 'quickLists[$index]',
          importedAt: importedAt,
          counters: counters,
        );
      }

      report = counters.toReport(sourceKind, sourceSha);
      await _database
          .into(_database.migrationHistory)
          .insert(
            MigrationHistoryCompanion.insert(
              id: _uuid.v4(),
              sourceKind: sourceKind,
              sourceSha256: sourceSha,
              sourceSchema: Value(schema.isEmpty ? null : schema),
              importedAt: importedAt,
              reportJson: jsonEncode(report.toJson()),
            ),
          );
    });
    return report;
  }

  _CanonicalInput _canonicalWebInput(Map<String, Object?> root) {
    final data = root['schema'] == _webSchema ? _map(root['data']) : root;
    if (data == null) {
      throw const FormatException('Objet data absent de la sauvegarde Web.');
    }
    return _CanonicalInput(
      library: data,
      trips: _mapList(data['voyages'])
          .map((value) => _Document(value, remoteRecordId: null, shared: false))
          .toList(),
      quickLists: _mapList(data['quickLists'])
          .map((value) => _Document(value, remoteRecordId: null, shared: false))
          .toList(),
      warnings: const [],
      ignoredAggregateSnapshots: 0,
    );
  }

  _CanonicalInput _canonicalPocketBaseInput(Map<String, Object?> root) {
    final records = _mapList(root['records']);
    if (records.isEmpty) {
      throw const FormatException(
        'La sauvegarde PocketBase ne contient aucun record.',
      );
    }
    final settings = records
        .where((record) => _string(record['code']) == 'PARAMS')
        .toList();
    if (settings.length != 1) {
      throw FormatException(
        'Un unique record PARAMS est requis, trouvé : ${settings.length}.',
      );
    }

    final directTrips = <_Document>[];
    final directQuickLists = <_Document>[];
    final snapshots = <Map<String, Object?>>[];
    for (final record in records) {
      if (_string(record['code']) == 'PARAMS') continue;
      final data = _map(record['data']);
      if (data == null) continue;
      if (data['voyages'] is List || data['currentVoyageId'] != null) {
        snapshots.add(record);
        continue;
      }
      final wrappedTrip = _map(data['voyage']);
      final wrappedQuickList = _map(data['quickList']);
      final type = _string(data['type']);
      final remoteId = _nullableString(record['id']);
      final code = _nullableString(record['code']);
      if (wrappedTrip != null ||
          type == 'voyage' ||
          data['members'] is List ||
          data['categories'] is List) {
        directTrips.add(
          _Document(
            wrappedTrip ?? data,
            remoteRecordId: remoteId,
            shareCode: code,
            shared: true,
          ),
        );
      } else if (wrappedQuickList != null ||
          type == 'quickList' ||
          data['items'] is List) {
        directQuickLists.add(
          _Document(
            wrappedQuickList ?? data,
            remoteRecordId: remoteId,
            shareCode: code,
            shared: true,
          ),
        );
      }
    }

    final warnings = <String>[];
    var ignoredSnapshots = 0;
    if (snapshots.isNotEmpty) {
      snapshots.sort(
        (a, b) => _dateValue(b['updated']).compareTo(_dateValue(a['updated'])),
      );
      final latest = _map(snapshots.first['data'])!;
      _appendMissingDocuments(
        directTrips,
        _mapList(latest['voyages']),
        shared: true,
      );
      _appendMissingDocuments(
        directQuickLists,
        _mapList(latest['quickLists']),
        shared: true,
      );
      ignoredSnapshots = snapshots.length - 1;
      if (ignoredSnapshots > 0) {
        warnings.add(
          '$ignoredSnapshots instantané(s) agrégé(s) historique(s) ignoré(s) au profit du plus récent.',
        );
      }
    }

    return _CanonicalInput(
      library: _map(settings.single['data']) ?? const {},
      trips: directTrips,
      quickLists: directQuickLists,
      warnings: warnings,
      ignoredAggregateSnapshots: ignoredSnapshots,
    );
  }

  void _appendMissingDocuments(
    List<_Document> canonical,
    List<Map<String, Object?>> candidates, {
    required bool shared,
  }) {
    final keys = canonical
        .map((item) => _documentKey(item.data))
        .whereType<String>()
        .toSet();
    for (final candidate in candidates) {
      final key = _documentKey(candidate);
      if (key == null || keys.add(key)) {
        canonical.add(
          _Document(candidate, remoteRecordId: null, shared: shared),
        );
      }
    }
  }

  Future<void> _importLibrary(
    _CanonicalInput input, {
    required String sourceKind,
    required String sourceSha,
    required DateTime importedAt,
    required _Counters counters,
  }) async {
    final data = input.library;
    final categories = _mapList(data['customCategories']);
    final groups = _stringMap(data['customMemberGroups']);
    final icons = _stringMap(data['customMemberIcons']);
    final members = <String>{
      ..._stringList(data['customCategoryMembers']),
      ...groups.keys,
      ...categories
          .map((category) => _string(category['member']))
          .where((name) => name.isNotEmpty),
    };
    if (categories.any(
      (category) =>
          _ownerKind(_string(category['member']), groups) == 'general',
    )) {
      members.add('Général');
    }

    final ownerIds = <String, String>{};
    for (final member in members) {
      final kind = _ownerKind(member, groups);
      final scope = kind == 'personal' ? 'personal_local' : 'shared_library';
      final ownerId = await _resolveId(
        sourceKind: sourceKind,
        sourceRecordId: '',
        entityType: 'library_owner',
        legacyId: 'member-key:${_normalized(member)}',
        jsonPath: 'library.members[$member]',
        sourceSha: sourceSha,
      );
      ownerIds[_normalized(member)] = ownerId;
      await _database
          .into(_database.libraryOwners)
          .insertOnConflictUpdate(
            LibraryOwnersCompanion.insert(
              id: ownerId,
              kind: kind,
              syncScope: scope,
              generationRole: Value(_generationRole(member, kind)),
              name: member,
              icon: Value(_nullableString(icons[member])),
              createdAt: importedAt,
              updatedAtLocal: importedAt,
              deletedAt: Value(
                _parseDate(_stringMap(data['customMemberDeletedAt'])[member]),
              ),
            ),
          );
      counters.owners++;
      if (kind == 'personal') counters.personalOwners++;
    }

    for (
      var categoryIndex = 0;
      categoryIndex < categories.length;
      categoryIndex++
    ) {
      final category = categories[categoryIndex];
      final member = _string(category['member']).isEmpty
          ? 'Général'
          : _string(category['member']);
      final memberKey = _normalized(member);
      var ownerId = ownerIds[memberKey];
      if (ownerId == null) {
        final kind = _ownerKind(member, groups);
        ownerId = await _resolveId(
          sourceKind: sourceKind,
          sourceRecordId: '',
          entityType: 'library_owner',
          legacyId: 'member-key:$memberKey',
          jsonPath: 'library.categories[$categoryIndex].member',
          sourceSha: sourceSha,
        );
        await _database
            .into(_database.libraryOwners)
            .insertOnConflictUpdate(
              LibraryOwnersCompanion.insert(
                id: ownerId,
                kind: kind,
                syncScope: kind == 'personal'
                    ? 'personal_local'
                    : 'shared_library',
                generationRole: Value(_generationRole(member, kind)),
                name: member,
                createdAt: importedAt,
                updatedAtLocal: importedAt,
              ),
            );
        ownerIds[memberKey] = ownerId;
        counters.owners++;
        if (kind == 'personal') counters.personalOwners++;
      }

      final categoryPath = 'library.categories[$categoryIndex]';
      final categoryId = await _resolveId(
        sourceKind: sourceKind,
        sourceRecordId: '',
        entityType: 'library_category',
        legacyId: _nullableString(category['id']),
        jsonPath: categoryPath,
        sourceSha: sourceSha,
      );
      final updated = _parseDate(category['updatedAt']) ?? importedAt;
      final deleted = _parseDate(category['deletedAt']);
      await _database
          .into(_database.libraryCategories)
          .insertOnConflictUpdate(
            LibraryCategoriesCompanion.insert(
              id: categoryId,
              ownerId: ownerId,
              name: _fallbackName(category['name'], 'Catégorie'),
              icon: Value(_nullableString(category['icon'])),
              createdAt: updated,
              updatedAtLocal: updated,
              deletedAt: Value(deleted),
            ),
          );
      counters.categories++;

      final items = _objectList(category['items']);
      for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
        final rawItem = items[itemIndex];
        final item = rawItem is Map
            ? rawItem.cast<String, Object?>()
            : <String, Object?>{'name': rawItem};
        final itemPath = '$categoryPath.items[$itemIndex]';
        final itemId = await _resolveId(
          sourceKind: sourceKind,
          sourceRecordId: '',
          entityType: 'library_item',
          legacyId: _nullableString(item['id']),
          jsonPath: itemPath,
          sourceSha: sourceSha,
        );
        final itemUpdated = _parseDate(item['updatedAt']) ?? updated;
        final itemDeleted = _parseDate(item['deletedAt']);
        await _database
            .into(_database.libraryItems)
            .insertOnConflictUpdate(
              LibraryItemsCompanion.insert(
                id: itemId,
                categoryId: categoryId,
                name: _fallbackName(item['name'], 'Élément'),
                defaultQuantity: Value(_quantity(item['qty'])),
                createdAt: itemUpdated,
                updatedAtLocal: itemUpdated,
                deletedAt: Value(itemDeleted),
              ),
            );
        counters.libraryItems++;
        final owner = await (_database.select(
          _database.libraryOwners,
        )..where((row) => row.id.equals(ownerId!))).getSingle();
        if (itemDeleted != null && owner.syncScope == 'shared_library') {
          await _trackHistoricalTombstone(
            'library_item',
            itemId,
            itemDeleted,
            importedAt,
          );
        }
      }
    }
  }

  Future<void> _importTrip(
    _Document document, {
    required String sourceKind,
    required String sourceSha,
    required String path,
    required DateTime importedAt,
    required _Counters counters,
  }) async {
    final trip = document.data;
    final legacyId = _nullableString(trip['id']);
    final tripId = await _resolveId(
      sourceKind: sourceKind,
      sourceRecordId: document.remoteRecordId ?? '',
      entityType: 'trip',
      legacyId: legacyId,
      jsonPath: path,
      sourceSha: sourceSha,
    );
    final existing = await (_database.select(
      _database.trips,
    )..where((row) => row.id.equals(tripId))).getSingleOrNull();
    final remoteId =
        document.remoteRecordId ?? _nullableString(trip['remoteRecordId']);
    final shared =
        document.shared || remoteId != null || existing?.shareState == 'shared';
    final shareCode = shared
        ? (document.shareCode ??
              _nullableString(trip['code']) ??
              existing?.shareCode)
        : null;
    if (!shared && _nullableString(trip['code']) != null) {
      counters.discardedLocalCodes++;
    }
    final created = _parseDate(trip['createdAt']) ?? importedAt;
    final updated = _parseDate(trip['updatedAt']) ?? created;
    final deleted = _parseDate(trip['deletedAt']);
    await _database
        .into(_database.trips)
        .insertOnConflictUpdate(
          TripsCompanion.insert(
            id: tripId,
            name: _fallbackName(trip['name'], 'Voyage'),
            destinationJson: Value(
              trip['destination'] == null
                  ? null
                  : jsonEncode(trip['destination']),
            ),
            startDate: Value(_parseDate(trip['startDate'])),
            endDate: Value(_parseDate(trip['endDate'])),
            shareState: Value(shared ? 'shared' : 'local'),
            remoteRecordId: Value(remoteId ?? existing?.remoteRecordId),
            shareCode: Value(shareCode),
            createdAt: created,
            updatedAtLocal: updated,
            deletedAt: Value(deleted),
          ),
        );
    counters.trips++;
    shared ? counters.sharedDocuments++ : counters.localDocuments++;
    if (deleted != null && shared) {
      await _trackHistoricalTombstone('trip', tripId, deleted, importedAt);
    }

    final generalCategories = _mapList(trip['categories']);
    await _importTripCategories(
      tripId: tripId,
      memberId: null,
      categories: generalCategories,
      sourceKindLabel: 'essential',
      sourceKind: sourceKind,
      sourceRecordId: document.remoteRecordId ?? '',
      sourceSha: sourceSha,
      path: '$path.categories',
      importedAt: importedAt,
      shared: shared,
      counters: counters,
    );

    final members = _mapList(trip['members']);
    for (var memberIndex = 0; memberIndex < members.length; memberIndex++) {
      final member = members[memberIndex];
      final memberPath = '$path.members[$memberIndex]';
      final memberId = await _resolveId(
        sourceKind: sourceKind,
        sourceRecordId: document.remoteRecordId ?? '',
        entityType: 'trip_member',
        legacyId: _nullableString(member['id']),
        jsonPath: memberPath,
        sourceSha: sourceSha,
      );
      final memberUpdated = _parseDate(member['updatedAt']) ?? updated;
      final memberDeleted = _parseDate(member['deletedAt']);
      await _database
          .into(_database.tripMembers)
          .insertOnConflictUpdate(
            TripMembersCompanion.insert(
              id: memberId,
              tripId: tripId,
              groupKind: _string(member['group']) == 'general'
                  ? 'general'
                  : 'family',
              name: _fallbackName(member['name'], 'Membre'),
              icon: Value(_nullableString(member['icon'])),
              createdAt: memberUpdated,
              updatedAtLocal: memberUpdated,
              deletedAt: Value(memberDeleted),
            ),
          );
      if (memberDeleted != null && shared) {
        await _trackHistoricalTombstone(
          'trip_member',
          memberId,
          memberDeleted,
          importedAt,
        );
      }
      await _importTripCategories(
        tripId: tripId,
        memberId: memberId,
        categories: _mapList(member['categories']),
        sourceKindLabel: 'participant',
        sourceKind: sourceKind,
        sourceRecordId: document.remoteRecordId ?? '',
        sourceSha: sourceSha,
        path: '$memberPath.categories',
        importedAt: importedAt,
        shared: shared,
        counters: counters,
      );
    }
  }

  Future<void> _importTripCategories({
    required String tripId,
    required String? memberId,
    required List<Map<String, Object?>> categories,
    required String sourceKindLabel,
    required String sourceKind,
    required String sourceRecordId,
    required String sourceSha,
    required String path,
    required DateTime importedAt,
    required bool shared,
    required _Counters counters,
  }) async {
    for (
      var categoryIndex = 0;
      categoryIndex < categories.length;
      categoryIndex++
    ) {
      final category = categories[categoryIndex];
      final categoryPath = '$path[$categoryIndex]';
      final categoryId = await _resolveId(
        sourceKind: sourceKind,
        sourceRecordId: sourceRecordId,
        entityType: 'trip_category',
        legacyId: _nullableString(category['id']),
        jsonPath: categoryPath,
        sourceSha: sourceSha,
      );
      final updated = _parseDate(category['updatedAt']) ?? importedAt;
      final deleted = _parseDate(category['deletedAt']);
      final sourceCategoryId = await _mappedV1Id(
        'library_category',
        _nullableString(category['sourceTemplateId']),
      );
      await _database
          .into(_database.tripCategories)
          .insertOnConflictUpdate(
            TripCategoriesCompanion.insert(
              id: categoryId,
              tripId: tripId,
              memberId: Value(memberId),
              sourceCategoryId: Value(sourceCategoryId),
              name: _fallbackName(category['name'], 'Catégorie'),
              icon: Value(_nullableString(category['icon'])),
              createdAt: updated,
              updatedAtLocal: updated,
              deletedAt: Value(deleted),
            ),
          );
      if (deleted != null && shared) {
        await _trackHistoricalTombstone(
          'trip_category',
          categoryId,
          deleted,
          importedAt,
        );
      }
      final items = _mapList(category['items']);
      for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
        final item = items[itemIndex];
        final itemPath = '$categoryPath.items[$itemIndex]';
        final itemId = await _resolveId(
          sourceKind: sourceKind,
          sourceRecordId: sourceRecordId,
          entityType: 'trip_item',
          legacyId: _nullableString(item['id']),
          jsonPath: itemPath,
          sourceSha: sourceSha,
        );
        final itemUpdated = _parseDate(item['updatedAt']) ?? updated;
        final itemDeleted = _parseDate(item['deletedAt']);
        await _database
            .into(_database.tripItems)
            .insertOnConflictUpdate(
              TripItemsCompanion.insert(
                id: itemId,
                tripId: tripId,
                categoryId: categoryId,
                name: _fallbackName(item['name'], 'Élément'),
                quantity: Value(_quantity(item['qty'])),
                status: Value(_status(item)),
                createdAt: itemUpdated,
                updatedAtLocal: itemUpdated,
                deletedAt: Value(itemDeleted),
              ),
            );
        counters.tripItems++;
        if (itemDeleted != null && shared) {
          await _trackHistoricalTombstone(
            'trip_item',
            itemId,
            itemDeleted,
            importedAt,
          );
        }
        final sourceLegacyId = _nullableString(item['sourceTemplateItemId']);
        if (sourceLegacyId != null) {
          final sourceId =
              await _mappedV1Id('library_item', sourceLegacyId) ??
              await _resolveId(
                sourceKind: sourceKind,
                sourceRecordId: sourceRecordId,
                entityType: 'library_item_reference',
                legacyId: sourceLegacyId,
                jsonPath: '$itemPath.sourceTemplateItemId',
                sourceSha: sourceSha,
              );
          await _database
              .into(_database.tripItemSources)
              .insert(
                TripItemSourcesCompanion.insert(
                  tripItemId: itemId,
                  sourceLibraryItemId: sourceId,
                  sourceKind: sourceKindLabel,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    }
  }

  Future<void> _importQuickList(
    _Document document, {
    required String sourceKind,
    required String sourceSha,
    required String path,
    required DateTime importedAt,
    required _Counters counters,
  }) async {
    final list = document.data;
    final listId = await _resolveId(
      sourceKind: sourceKind,
      sourceRecordId: document.remoteRecordId ?? '',
      entityType: 'quick_list',
      legacyId: _nullableString(list['id']),
      jsonPath: path,
      sourceSha: sourceSha,
    );
    final existing = await (_database.select(
      _database.quickLists,
    )..where((row) => row.id.equals(listId))).getSingleOrNull();
    final remoteId =
        document.remoteRecordId ?? _nullableString(list['remoteRecordId']);
    final shared =
        document.shared || remoteId != null || existing?.shareState == 'shared';
    final shareCode = shared
        ? (document.shareCode ??
              _nullableString(list['code']) ??
              existing?.shareCode)
        : null;
    if (!shared && _nullableString(list['code']) != null) {
      counters.discardedLocalCodes++;
    }
    final created = _parseDate(list['createdAt']) ?? importedAt;
    final updated = _parseDate(list['updatedAt']) ?? created;
    final deleted = _parseDate(list['deletedAt']);
    await _database
        .into(_database.quickLists)
        .insertOnConflictUpdate(
          QuickListsCompanion.insert(
            id: listId,
            name: _fallbackName(list['name'], 'Liste rapide'),
            shareState: Value(shared ? 'shared' : 'local'),
            remoteRecordId: Value(remoteId ?? existing?.remoteRecordId),
            shareCode: Value(shareCode),
            createdAt: created,
            updatedAtLocal: updated,
            deletedAt: Value(deleted),
          ),
        );
    counters.quickLists++;
    shared ? counters.sharedDocuments++ : counters.localDocuments++;
    if (deleted != null && shared) {
      await _trackHistoricalTombstone(
        'quick_list',
        listId,
        deleted,
        importedAt,
      );
    }

    final items = _mapList(list['items']);
    for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
      final item = items[itemIndex];
      final itemId = await _resolveId(
        sourceKind: sourceKind,
        sourceRecordId: document.remoteRecordId ?? '',
        entityType: 'quick_list_item',
        legacyId: _nullableString(item['id']),
        jsonPath: '$path.items[$itemIndex]',
        sourceSha: sourceSha,
      );
      final itemUpdated = _parseDate(item['updatedAt']) ?? updated;
      final itemDeleted = _parseDate(item['deletedAt']);
      await _database
          .into(_database.quickListItems)
          .insertOnConflictUpdate(
            QuickListItemsCompanion.insert(
              id: itemId,
              quickListId: listId,
              name: _fallbackName(item['name'], 'Élément'),
              quantity: Value(_quantity(item['qty'])),
              isChecked: Value(
                item['done'] == true || item['isChecked'] == true,
              ),
              createdAt: itemUpdated,
              updatedAtLocal: itemUpdated,
              deletedAt: Value(itemDeleted),
            ),
          );
      counters.quickListItems++;
      if (itemDeleted != null && shared) {
        await _trackHistoricalTombstone(
          'quick_list_item',
          itemId,
          itemDeleted,
          importedAt,
        );
      }
    }
  }

  Future<String> _resolveId({
    required String sourceKind,
    required String sourceRecordId,
    required String entityType,
    required String? legacyId,
    required String jsonPath,
    required String sourceSha,
  }) async {
    final stableLegacyId = legacyId ?? '@path:$sourceSha:$jsonPath';
    final exact =
        await (_database.select(_database.legacyIdMaps)..where(
              (row) =>
                  row.sourceKind.equals(sourceKind) &
                  row.sourceRecordId.equals(sourceRecordId) &
                  row.entityType.equals(entityType) &
                  row.legacyId.equals(stableLegacyId),
            ))
            .getSingleOrNull();
    if (exact != null) return exact.v1Uuid;

    if (legacyId != null) {
      final stableMatch =
          await (_database.select(_database.legacyIdMaps)
                ..where(
                  (row) =>
                      row.entityType.equals(entityType) &
                      row.legacyId.equals(legacyId),
                )
                ..limit(1))
              .getSingleOrNull();
      if (stableMatch != null) return stableMatch.v1Uuid;
    }

    final v1Id = _uuid.v5(
      _uuidNamespace,
      '$sourceKind|$sourceRecordId|$entityType|$stableLegacyId',
    );
    await _database
        .into(_database.legacyIdMaps)
        .insert(
          LegacyIdMapsCompanion.insert(
            sourceKind: sourceKind,
            sourceRecordId: Value(sourceRecordId),
            entityType: entityType,
            legacyId: stableLegacyId,
            v1Uuid: v1Id,
            jsonPath: Value(jsonPath),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return v1Id;
  }

  Future<String?> _mappedV1Id(String entityType, String? legacyId) async {
    if (legacyId == null) return null;
    final row =
        await (_database.select(_database.legacyIdMaps)
              ..where(
                (entry) =>
                    entry.entityType.equals(entityType) &
                    entry.legacyId.equals(legacyId),
              )
              ..limit(1))
            .getSingleOrNull();
    return row?.v1Uuid;
  }

  Future<void> _trackHistoricalTombstone(
    String entityType,
    String entityId,
    DateTime deletedAt,
    DateTime importedAt,
  ) async {
    await _database
        .into(_database.syncTombstones)
        .insertOnConflictUpdate(
          SyncTombstonesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            deletedAt: deletedAt,
            propagatedAt: Value(importedAt),
            purgeEligibleAt: deletedAt.add(const Duration(days: 90)),
          ),
        );
  }
}

class _CanonicalInput {
  const _CanonicalInput({
    required this.library,
    required this.trips,
    required this.quickLists,
    required this.warnings,
    required this.ignoredAggregateSnapshots,
  });

  final Map<String, Object?> library;
  final List<_Document> trips;
  final List<_Document> quickLists;
  final List<String> warnings;
  final int ignoredAggregateSnapshots;
}

class _Document {
  const _Document(
    this.data, {
    required this.remoteRecordId,
    required this.shared,
    this.shareCode,
  });

  final Map<String, Object?> data;
  final String? remoteRecordId;
  final String? shareCode;
  final bool shared;
}

class _Counters {
  _Counters({required this.ignoredAggregateSnapshots, required this.warnings});

  int owners = 0;
  int categories = 0;
  int libraryItems = 0;
  int trips = 0;
  int tripItems = 0;
  int quickLists = 0;
  int quickListItems = 0;
  int personalOwners = 0;
  int sharedDocuments = 0;
  int localDocuments = 0;
  int discardedLocalCodes = 0;
  final int ignoredAggregateSnapshots;
  final List<String> warnings;

  ImportReport toReport(String sourceKind, String sourceSha) {
    if (discardedLocalCodes > 0) {
      warnings.add(
        '$discardedLocalCodes code(s) Web local(aux) conservé(s) uniquement comme référence historique.',
      );
    }
    return ImportReport(
      sourceKind: sourceKind,
      sourceSha256: sourceSha,
      alreadyImported: false,
      owners: owners,
      categories: categories,
      libraryItems: libraryItems,
      trips: trips,
      tripItems: tripItems,
      quickLists: quickLists,
      quickListItems: quickListItems,
      personalOwners: personalOwners,
      sharedDocuments: sharedDocuments,
      localDocuments: localDocuments,
      ignoredAggregateSnapshots: ignoredAggregateSnapshots,
      warnings: List.unmodifiable(warnings),
    );
  }
}

Map<String, Object?>? _map(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.cast<String, Object?>();
  return null;
}

List<Map<String, Object?>> _mapList(Object? value) => _objectList(
  value,
).map(_map).whereType<Map<String, Object?>>().toList(growable: false);

List<Object?> _objectList(Object? value) => value is List ? value : const [];

List<String> _stringList(Object? value) =>
    _objectList(value).map(_string).where((item) => item.isNotEmpty).toList();

Map<String, String> _stringMap(Object? value) {
  final map = _map(value);
  if (map == null) return const {};
  return map.map((key, value) => MapEntry(key, _string(value)));
}

String _string(Object? value) => value?.toString().trim() ?? '';

String? _nullableString(Object? value) {
  final result = _string(value);
  return result.isEmpty ? null : result;
}

String _fallbackName(Object? value, String fallback) =>
    _nullableString(value) ?? fallback;

String _normalized(String value) => value.trim().toLowerCase();

String _ownerKind(String name, Map<String, String> groups) {
  final normalizedName = _normalized(name);
  final rawGroup =
      groups[name] ??
      groups.entries
          .where((entry) => _normalized(entry.key) == normalizedName)
          .map((entry) => entry.value)
          .firstOrNull;
  if (rawGroup == 'personal') return 'personal';
  if (rawGroup == 'general' ||
      normalizedName == 'général' ||
      normalizedName == 'general') {
    return 'general';
  }
  return 'family_member';
}

String _generationRole(String name, String kind) {
  if (kind == 'family_member' || kind == 'personal') return 'participant';
  final normalized = _normalized(name)
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ô', 'o');
  if (normalized == 'essentiel' || normalized == 'essentiels') {
    return 'essential';
  }
  if (normalized.startsWith('trajet') || normalized.startsWith('transport')) {
    return 'transport';
  }
  if (normalized.startsWith('logement')) return 'lodging';
  return 'general';
}

int _quantity(Object? value) {
  final parsed = value is num ? value.toInt() : int.tryParse(_string(value));
  return (parsed ?? 1).clamp(1, 99);
}

String _status(Map<String, Object?> item) {
  final status = _string(item['status']);
  if (status == 'checked' || status == 'done') return status;
  return item['done'] == true ? 'done' : 'todo';
}

DateTime? _parseDate(Object? value) {
  final raw = _nullableString(value);
  return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
}

int _dateValue(Object? value) => _parseDate(value)?.millisecondsSinceEpoch ?? 0;

String? _documentKey(Map<String, Object?> value) {
  final remote = _nullableString(value['remoteRecordId']);
  if (remote != null) return 'remote:$remote';
  final id = _nullableString(value['id']);
  if (id != null) return 'id:$id';
  final code = _nullableString(value['code']);
  if (code != null) return 'code:$code';
  return null;
}
