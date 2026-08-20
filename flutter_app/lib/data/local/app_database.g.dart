// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InstallationSettingsTable extends InstallationSettings
    with TableInfo<$InstallationSettingsTable, InstallationSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('current'),
  );
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _futureUserIdMeta = const VerificationMeta(
    'futureUserId',
  );
  @override
  late final GeneratedColumn<String> futureUserId = GeneratedColumn<String>(
    'future_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _libraryIdMeta = const VerificationMeta(
    'libraryId',
  );
  @override
  late final GeneratedColumn<String> libraryId = GeneratedColumn<String>(
    'library_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('6d0f0d44-54f8-4f6a-b535-0a58d6efac11'),
  );
  static const VerificationMeta _nextOperationSequenceMeta =
      const VerificationMeta('nextOperationSequence');
  @override
  late final GeneratedColumn<int> nextOperationSequence = GeneratedColumn<int>(
    'next_operation_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _pullCursorMeta = const VerificationMeta(
    'pullCursor',
  );
  @override
  late final GeneratedColumn<int> pullCursor = GeneratedColumn<int>(
    'pull_cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('offline'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    installationId,
    futureUserId,
    createdAt,
    updatedAtLocal,
    libraryId,
    nextOperationSequence,
    pullCursor,
    syncStatus,
    syncError,
    lastSyncAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installation_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstallationSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installationIdMeta);
    }
    if (data.containsKey('future_user_id')) {
      context.handle(
        _futureUserIdMeta,
        futureUserId.isAcceptableOrUnknown(
          data['future_user_id']!,
          _futureUserIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('library_id')) {
      context.handle(
        _libraryIdMeta,
        libraryId.isAcceptableOrUnknown(data['library_id']!, _libraryIdMeta),
      );
    }
    if (data.containsKey('next_operation_sequence')) {
      context.handle(
        _nextOperationSequenceMeta,
        nextOperationSequence.isAcceptableOrUnknown(
          data['next_operation_sequence']!,
          _nextOperationSequenceMeta,
        ),
      );
    }
    if (data.containsKey('pull_cursor')) {
      context.handle(
        _pullCursorMeta,
        pullCursor.isAcceptableOrUnknown(data['pull_cursor']!, _pullCursorMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallationSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallationSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      )!,
      futureUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}future_user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      libraryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_id'],
      )!,
      nextOperationSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_operation_sequence'],
      )!,
      pullCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pull_cursor'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
    );
  }

  @override
  $InstallationSettingsTable createAlias(String alias) {
    return $InstallationSettingsTable(attachedDatabase, alias);
  }
}

class InstallationSetting extends DataClass
    implements Insertable<InstallationSetting> {
  final String id;
  final String installationId;
  final String? futureUserId;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final String libraryId;
  final int nextOperationSequence;
  final int pullCursor;
  final String syncStatus;
  final String? syncError;
  final DateTime? lastSyncAt;
  const InstallationSetting({
    required this.id,
    required this.installationId,
    this.futureUserId,
    required this.createdAt,
    required this.updatedAtLocal,
    required this.libraryId,
    required this.nextOperationSequence,
    required this.pullCursor,
    required this.syncStatus,
    this.syncError,
    this.lastSyncAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['installation_id'] = Variable<String>(installationId);
    if (!nullToAbsent || futureUserId != null) {
      map['future_user_id'] = Variable<String>(futureUserId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    map['library_id'] = Variable<String>(libraryId);
    map['next_operation_sequence'] = Variable<int>(nextOperationSequence);
    map['pull_cursor'] = Variable<int>(pullCursor);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    return map;
  }

  InstallationSettingsCompanion toCompanion(bool nullToAbsent) {
    return InstallationSettingsCompanion(
      id: Value(id),
      installationId: Value(installationId),
      futureUserId: futureUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(futureUserId),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      libraryId: Value(libraryId),
      nextOperationSequence: Value(nextOperationSequence),
      pullCursor: Value(pullCursor),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
    );
  }

  factory InstallationSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallationSetting(
      id: serializer.fromJson<String>(json['id']),
      installationId: serializer.fromJson<String>(json['installationId']),
      futureUserId: serializer.fromJson<String?>(json['futureUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      libraryId: serializer.fromJson<String>(json['libraryId']),
      nextOperationSequence: serializer.fromJson<int>(
        json['nextOperationSequence'],
      ),
      pullCursor: serializer.fromJson<int>(json['pullCursor']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'installationId': serializer.toJson<String>(installationId),
      'futureUserId': serializer.toJson<String?>(futureUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'libraryId': serializer.toJson<String>(libraryId),
      'nextOperationSequence': serializer.toJson<int>(nextOperationSequence),
      'pullCursor': serializer.toJson<int>(pullCursor),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
    };
  }

  InstallationSetting copyWith({
    String? id,
    String? installationId,
    Value<String?> futureUserId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    String? libraryId,
    int? nextOperationSequence,
    int? pullCursor,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
    Value<DateTime?> lastSyncAt = const Value.absent(),
  }) => InstallationSetting(
    id: id ?? this.id,
    installationId: installationId ?? this.installationId,
    futureUserId: futureUserId.present ? futureUserId.value : this.futureUserId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    libraryId: libraryId ?? this.libraryId,
    nextOperationSequence: nextOperationSequence ?? this.nextOperationSequence,
    pullCursor: pullCursor ?? this.pullCursor,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
  );
  InstallationSetting copyWithCompanion(InstallationSettingsCompanion data) {
    return InstallationSetting(
      id: data.id.present ? data.id.value : this.id,
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      futureUserId: data.futureUserId.present
          ? data.futureUserId.value
          : this.futureUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      nextOperationSequence: data.nextOperationSequence.present
          ? data.nextOperationSequence.value
          : this.nextOperationSequence,
      pullCursor: data.pullCursor.present
          ? data.pullCursor.value
          : this.pullCursor,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallationSetting(')
          ..write('id: $id, ')
          ..write('installationId: $installationId, ')
          ..write('futureUserId: $futureUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('libraryId: $libraryId, ')
          ..write('nextOperationSequence: $nextOperationSequence, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    installationId,
    futureUserId,
    createdAt,
    updatedAtLocal,
    libraryId,
    nextOperationSequence,
    pullCursor,
    syncStatus,
    syncError,
    lastSyncAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallationSetting &&
          other.id == this.id &&
          other.installationId == this.installationId &&
          other.futureUserId == this.futureUserId &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.libraryId == this.libraryId &&
          other.nextOperationSequence == this.nextOperationSequence &&
          other.pullCursor == this.pullCursor &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.lastSyncAt == this.lastSyncAt);
}

class InstallationSettingsCompanion
    extends UpdateCompanion<InstallationSetting> {
  final Value<String> id;
  final Value<String> installationId;
  final Value<String?> futureUserId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<String> libraryId;
  final Value<int> nextOperationSequence;
  final Value<int> pullCursor;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<DateTime?> lastSyncAt;
  final Value<int> rowid;
  const InstallationSettingsCompanion({
    this.id = const Value.absent(),
    this.installationId = const Value.absent(),
    this.futureUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.nextOperationSequence = const Value.absent(),
    this.pullCursor = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallationSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String installationId,
    this.futureUserId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.libraryId = const Value.absent(),
    this.nextOperationSequence = const Value.absent(),
    this.pullCursor = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : installationId = Value(installationId),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<InstallationSetting> custom({
    Expression<String>? id,
    Expression<String>? installationId,
    Expression<String>? futureUserId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<String>? libraryId,
    Expression<int>? nextOperationSequence,
    Expression<int>? pullCursor,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (installationId != null) 'installation_id': installationId,
      if (futureUserId != null) 'future_user_id': futureUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (libraryId != null) 'library_id': libraryId,
      if (nextOperationSequence != null)
        'next_operation_sequence': nextOperationSequence,
      if (pullCursor != null) 'pull_cursor': pullCursor,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallationSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? installationId,
    Value<String?>? futureUserId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<String>? libraryId,
    Value<int>? nextOperationSequence,
    Value<int>? pullCursor,
    Value<String>? syncStatus,
    Value<String?>? syncError,
    Value<DateTime?>? lastSyncAt,
    Value<int>? rowid,
  }) {
    return InstallationSettingsCompanion(
      id: id ?? this.id,
      installationId: installationId ?? this.installationId,
      futureUserId: futureUserId ?? this.futureUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      libraryId: libraryId ?? this.libraryId,
      nextOperationSequence:
          nextOperationSequence ?? this.nextOperationSequence,
      pullCursor: pullCursor ?? this.pullCursor,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (futureUserId.present) {
      map['future_user_id'] = Variable<String>(futureUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (nextOperationSequence.present) {
      map['next_operation_sequence'] = Variable<int>(
        nextOperationSequence.value,
      );
    }
    if (pullCursor.present) {
      map['pull_cursor'] = Variable<int>(pullCursor.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallationSettingsCompanion(')
          ..write('id: $id, ')
          ..write('installationId: $installationId, ')
          ..write('futureUserId: $futureUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('libraryId: $libraryId, ')
          ..write('nextOperationSequence: $nextOperationSequence, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryOwnersTable extends LibraryOwners
    with TableInfo<$LibraryOwnersTable, LibraryOwner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryOwnersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncScopeMeta = const VerificationMeta(
    'syncScope',
  );
  @override
  late final GeneratedColumn<String> syncScope = GeneratedColumn<String>(
    'sync_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generationRoleMeta = const VerificationMeta(
    'generationRole',
  );
  @override
  late final GeneratedColumn<String> generationRole = GeneratedColumn<String>(
    'generation_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedParticipantOwnerIdMeta =
      const VerificationMeta('linkedParticipantOwnerId');
  @override
  late final GeneratedColumn<String> linkedParticipantOwnerId =
      GeneratedColumn<String>(
        'linked_participant_owner_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    syncScope,
    generationRole,
    name,
    icon,
    linkedParticipantOwnerId,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_owners';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryOwner> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('sync_scope')) {
      context.handle(
        _syncScopeMeta,
        syncScope.isAcceptableOrUnknown(data['sync_scope']!, _syncScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_syncScopeMeta);
    }
    if (data.containsKey('generation_role')) {
      context.handle(
        _generationRoleMeta,
        generationRole.isAcceptableOrUnknown(
          data['generation_role']!,
          _generationRoleMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('linked_participant_owner_id')) {
      context.handle(
        _linkedParticipantOwnerIdMeta,
        linkedParticipantOwnerId.isAcceptableOrUnknown(
          data['linked_participant_owner_id']!,
          _linkedParticipantOwnerIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryOwner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryOwner(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      syncScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_scope'],
      )!,
      generationRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generation_role'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      linkedParticipantOwnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_participant_owner_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LibraryOwnersTable createAlias(String alias) {
    return $LibraryOwnersTable(attachedDatabase, alias);
  }
}

class LibraryOwner extends DataClass implements Insertable<LibraryOwner> {
  final String id;
  final String kind;
  final String syncScope;
  final String generationRole;
  final String name;
  final String? icon;
  final String? linkedParticipantOwnerId;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const LibraryOwner({
    required this.id,
    required this.kind,
    required this.syncScope,
    required this.generationRole,
    required this.name,
    this.icon,
    this.linkedParticipantOwnerId,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['sync_scope'] = Variable<String>(syncScope);
    map['generation_role'] = Variable<String>(generationRole);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || linkedParticipantOwnerId != null) {
      map['linked_participant_owner_id'] = Variable<String>(
        linkedParticipantOwnerId,
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LibraryOwnersCompanion toCompanion(bool nullToAbsent) {
    return LibraryOwnersCompanion(
      id: Value(id),
      kind: Value(kind),
      syncScope: Value(syncScope),
      generationRole: Value(generationRole),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      linkedParticipantOwnerId: linkedParticipantOwnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedParticipantOwnerId),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LibraryOwner.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryOwner(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      syncScope: serializer.fromJson<String>(json['syncScope']),
      generationRole: serializer.fromJson<String>(json['generationRole']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      linkedParticipantOwnerId: serializer.fromJson<String?>(
        json['linkedParticipantOwnerId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'syncScope': serializer.toJson<String>(syncScope),
      'generationRole': serializer.toJson<String>(generationRole),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'linkedParticipantOwnerId': serializer.toJson<String?>(
        linkedParticipantOwnerId,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LibraryOwner copyWith({
    String? id,
    String? kind,
    String? syncScope,
    String? generationRole,
    String? name,
    Value<String?> icon = const Value.absent(),
    Value<String?> linkedParticipantOwnerId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LibraryOwner(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    syncScope: syncScope ?? this.syncScope,
    generationRole: generationRole ?? this.generationRole,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    linkedParticipantOwnerId: linkedParticipantOwnerId.present
        ? linkedParticipantOwnerId.value
        : this.linkedParticipantOwnerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LibraryOwner copyWithCompanion(LibraryOwnersCompanion data) {
    return LibraryOwner(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      syncScope: data.syncScope.present ? data.syncScope.value : this.syncScope,
      generationRole: data.generationRole.present
          ? data.generationRole.value
          : this.generationRole,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      linkedParticipantOwnerId: data.linkedParticipantOwnerId.present
          ? data.linkedParticipantOwnerId.value
          : this.linkedParticipantOwnerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryOwner(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('syncScope: $syncScope, ')
          ..write('generationRole: $generationRole, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('linkedParticipantOwnerId: $linkedParticipantOwnerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    syncScope,
    generationRole,
    name,
    icon,
    linkedParticipantOwnerId,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryOwner &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.syncScope == this.syncScope &&
          other.generationRole == this.generationRole &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.linkedParticipantOwnerId == this.linkedParticipantOwnerId &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class LibraryOwnersCompanion extends UpdateCompanion<LibraryOwner> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> syncScope;
  final Value<String> generationRole;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> linkedParticipantOwnerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LibraryOwnersCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.syncScope = const Value.absent(),
    this.generationRole = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.linkedParticipantOwnerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryOwnersCompanion.insert({
    required String id,
    required String kind,
    required String syncScope,
    this.generationRole = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.linkedParticipantOwnerId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       syncScope = Value(syncScope),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<LibraryOwner> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? syncScope,
    Expression<String>? generationRole,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? linkedParticipantOwnerId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (syncScope != null) 'sync_scope': syncScope,
      if (generationRole != null) 'generation_role': generationRole,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (linkedParticipantOwnerId != null)
        'linked_participant_owner_id': linkedParticipantOwnerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryOwnersCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? syncScope,
    Value<String>? generationRole,
    Value<String>? name,
    Value<String?>? icon,
    Value<String?>? linkedParticipantOwnerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LibraryOwnersCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      syncScope: syncScope ?? this.syncScope,
      generationRole: generationRole ?? this.generationRole,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      linkedParticipantOwnerId:
          linkedParticipantOwnerId ?? this.linkedParticipantOwnerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (syncScope.present) {
      map['sync_scope'] = Variable<String>(syncScope.value);
    }
    if (generationRole.present) {
      map['generation_role'] = Variable<String>(generationRole.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (linkedParticipantOwnerId.present) {
      map['linked_participant_owner_id'] = Variable<String>(
        linkedParticipantOwnerId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryOwnersCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('syncScope: $syncScope, ')
          ..write('generationRole: $generationRole, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('linkedParticipantOwnerId: $linkedParticipantOwnerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryCategoriesTable extends LibraryCategories
    with TableInfo<$LibraryCategoriesTable, LibraryCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_owners (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    name,
    icon,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LibraryCategoriesTable createAlias(String alias) {
    return $LibraryCategoriesTable(attachedDatabase, alias);
  }
}

class LibraryCategory extends DataClass implements Insertable<LibraryCategory> {
  final String id;
  final String ownerId;
  final String name;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const LibraryCategory({
    required this.id,
    required this.ownerId,
    required this.name,
    this.icon,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LibraryCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LibraryCategoriesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LibraryCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryCategory(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LibraryCategory copyWith({
    String? id,
    String? ownerId,
    String? name,
    Value<String?> icon = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LibraryCategory(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LibraryCategory copyWithCompanion(LibraryCategoriesCompanion data) {
    return LibraryCategory(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryCategory(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    name,
    icon,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryCategory &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class LibraryCategoriesCompanion extends UpdateCompanion<LibraryCategory> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String?> icon;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LibraryCategoriesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryCategoriesCompanion.insert({
    required String id,
    required String ownerId,
    required String name,
    this.icon = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<LibraryCategory> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String?>? icon,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LibraryCategoriesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryItemsTable extends LibraryItems
    with TableInfo<$LibraryItemsTable, LibraryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_categories (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultQuantityMeta = const VerificationMeta(
    'defaultQuantity',
  );
  @override
  late final GeneratedColumn<int> defaultQuantity = GeneratedColumn<int>(
    'default_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _logicalSourceIdMeta = const VerificationMeta(
    'logicalSourceId',
  );
  @override
  late final GeneratedColumn<String> logicalSourceId = GeneratedColumn<String>(
    'logical_source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    defaultQuantity,
    logicalSourceId,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_quantity')) {
      context.handle(
        _defaultQuantityMeta,
        defaultQuantity.isAcceptableOrUnknown(
          data['default_quantity']!,
          _defaultQuantityMeta,
        ),
      );
    }
    if (data.containsKey('logical_source_id')) {
      context.handle(
        _logicalSourceIdMeta,
        logicalSourceId.isAcceptableOrUnknown(
          data['logical_source_id']!,
          _logicalSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      defaultQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_quantity'],
      )!,
      logicalSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logical_source_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LibraryItemsTable createAlias(String alias) {
    return $LibraryItemsTable(attachedDatabase, alias);
  }
}

class LibraryItem extends DataClass implements Insertable<LibraryItem> {
  final String id;
  final String categoryId;
  final String name;
  final int defaultQuantity;
  final String? logicalSourceId;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const LibraryItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.defaultQuantity,
    this.logicalSourceId,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    map['default_quantity'] = Variable<int>(defaultQuantity);
    if (!nullToAbsent || logicalSourceId != null) {
      map['logical_source_id'] = Variable<String>(logicalSourceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LibraryItemsCompanion toCompanion(bool nullToAbsent) {
    return LibraryItemsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      defaultQuantity: Value(defaultQuantity),
      logicalSourceId: logicalSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(logicalSourceId),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LibraryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryItem(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      defaultQuantity: serializer.fromJson<int>(json['defaultQuantity']),
      logicalSourceId: serializer.fromJson<String?>(json['logicalSourceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'defaultQuantity': serializer.toJson<int>(defaultQuantity),
      'logicalSourceId': serializer.toJson<String?>(logicalSourceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LibraryItem copyWith({
    String? id,
    String? categoryId,
    String? name,
    int? defaultQuantity,
    Value<String?> logicalSourceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LibraryItem(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    defaultQuantity: defaultQuantity ?? this.defaultQuantity,
    logicalSourceId: logicalSourceId.present
        ? logicalSourceId.value
        : this.logicalSourceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LibraryItem copyWithCompanion(LibraryItemsCompanion data) {
    return LibraryItem(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      defaultQuantity: data.defaultQuantity.present
          ? data.defaultQuantity.value
          : this.defaultQuantity,
      logicalSourceId: data.logicalSourceId.present
          ? data.logicalSourceId.value
          : this.logicalSourceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItem(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('defaultQuantity: $defaultQuantity, ')
          ..write('logicalSourceId: $logicalSourceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    name,
    defaultQuantity,
    logicalSourceId,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryItem &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.defaultQuantity == this.defaultQuantity &&
          other.logicalSourceId == this.logicalSourceId &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class LibraryItemsCompanion extends UpdateCompanion<LibraryItem> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<int> defaultQuantity;
  final Value<String?> logicalSourceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LibraryItemsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultQuantity = const Value.absent(),
    this.logicalSourceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryItemsCompanion.insert({
    required String id,
    required String categoryId,
    required String name,
    this.defaultQuantity = const Value.absent(),
    this.logicalSourceId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<LibraryItem> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<int>? defaultQuantity,
    Expression<String>? logicalSourceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (defaultQuantity != null) 'default_quantity': defaultQuantity,
      if (logicalSourceId != null) 'logical_source_id': logicalSourceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String>? name,
    Value<int>? defaultQuantity,
    Value<String?>? logicalSourceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LibraryItemsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      defaultQuantity: defaultQuantity ?? this.defaultQuantity,
      logicalSourceId: logicalSourceId ?? this.logicalSourceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultQuantity.present) {
      map['default_quantity'] = Variable<int>(defaultQuantity.value);
    }
    if (logicalSourceId.present) {
      map['logical_source_id'] = Variable<String>(logicalSourceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItemsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('defaultQuantity: $defaultQuantity, ')
          ..write('logicalSourceId: $logicalSourceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContextsTable extends Contexts with TableInfo<$ContextsTable, Context> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncScopeMeta = const VerificationMeta(
    'syncScope',
  );
  @override
  late final GeneratedColumn<String> syncScope = GeneratedColumn<String>(
    'sync_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    syncScope,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contexts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Context> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sync_scope')) {
      context.handle(
        _syncScopeMeta,
        syncScope.isAcceptableOrUnknown(data['sync_scope']!, _syncScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_syncScopeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Context map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Context(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      syncScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ContextsTable createAlias(String alias) {
    return $ContextsTable(attachedDatabase, alias);
  }
}

class Context extends DataClass implements Insertable<Context> {
  final String id;
  final String name;
  final String syncScope;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const Context({
    required this.id,
    required this.name,
    required this.syncScope,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sync_scope'] = Variable<String>(syncScope);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ContextsCompanion toCompanion(bool nullToAbsent) {
    return ContextsCompanion(
      id: Value(id),
      name: Value(name),
      syncScope: Value(syncScope),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Context.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Context(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      syncScope: serializer.fromJson<String>(json['syncScope']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'syncScope': serializer.toJson<String>(syncScope),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Context copyWith({
    String? id,
    String? name,
    String? syncScope,
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Context(
    id: id ?? this.id,
    name: name ?? this.name,
    syncScope: syncScope ?? this.syncScope,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Context copyWithCompanion(ContextsCompanion data) {
    return Context(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      syncScope: data.syncScope.present ? data.syncScope.value : this.syncScope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Context(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('syncScope: $syncScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, syncScope, createdAt, updatedAtLocal, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Context &&
          other.id == this.id &&
          other.name == this.name &&
          other.syncScope == this.syncScope &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class ContextsCompanion extends UpdateCompanion<Context> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> syncScope;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ContextsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.syncScope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContextsCompanion.insert({
    required String id,
    required String name,
    required String syncScope,
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       syncScope = Value(syncScope),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<Context> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? syncScope,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (syncScope != null) 'sync_scope': syncScope,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContextsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? syncScope,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ContextsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      syncScope: syncScope ?? this.syncScope,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (syncScope.present) {
      map['sync_scope'] = Variable<String>(syncScope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContextsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('syncScope: $syncScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryItemContextsTable extends LibraryItemContexts
    with TableInfo<$LibraryItemContextsTable, LibraryItemContext> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryItemContextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_items (id)',
    ),
  );
  static const VerificationMeta _contextIdMeta = const VerificationMeta(
    'contextId',
  );
  @override
  late final GeneratedColumn<String> contextId = GeneratedColumn<String>(
    'context_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contexts (id)',
    ),
  );
  static const VerificationMeta _associationIdMeta = const VerificationMeta(
    'associationId',
  );
  @override
  late final GeneratedColumn<String> associationId = GeneratedColumn<String>(
    'association_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncScopeMeta = const VerificationMeta(
    'syncScope',
  );
  @override
  late final GeneratedColumn<String> syncScope = GeneratedColumn<String>(
    'sync_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('shared_library'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    contextId,
    associationId,
    syncScope,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_item_contexts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryItemContext> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('context_id')) {
      context.handle(
        _contextIdMeta,
        contextId.isAcceptableOrUnknown(data['context_id']!, _contextIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contextIdMeta);
    }
    if (data.containsKey('association_id')) {
      context.handle(
        _associationIdMeta,
        associationId.isAcceptableOrUnknown(
          data['association_id']!,
          _associationIdMeta,
        ),
      );
    }
    if (data.containsKey('sync_scope')) {
      context.handle(
        _syncScopeMeta,
        syncScope.isAcceptableOrUnknown(data['sync_scope']!, _syncScopeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, contextId};
  @override
  LibraryItemContext map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryItemContext(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      contextId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_id'],
      )!,
      associationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}association_id'],
      ),
      syncScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LibraryItemContextsTable createAlias(String alias) {
    return $LibraryItemContextsTable(attachedDatabase, alias);
  }
}

class LibraryItemContext extends DataClass
    implements Insertable<LibraryItemContext> {
  final String itemId;
  final String contextId;
  final String? associationId;
  final String syncScope;
  final DateTime createdAt;
  final DateTime? updatedAtLocal;
  final DateTime? deletedAt;
  const LibraryItemContext({
    required this.itemId,
    required this.contextId,
    this.associationId,
    required this.syncScope,
    required this.createdAt,
    this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['context_id'] = Variable<String>(contextId);
    if (!nullToAbsent || associationId != null) {
      map['association_id'] = Variable<String>(associationId);
    }
    map['sync_scope'] = Variable<String>(syncScope);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAtLocal != null) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LibraryItemContextsCompanion toCompanion(bool nullToAbsent) {
    return LibraryItemContextsCompanion(
      itemId: Value(itemId),
      contextId: Value(contextId),
      associationId: associationId == null && nullToAbsent
          ? const Value.absent()
          : Value(associationId),
      syncScope: Value(syncScope),
      createdAt: Value(createdAt),
      updatedAtLocal: updatedAtLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LibraryItemContext.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryItemContext(
      itemId: serializer.fromJson<String>(json['itemId']),
      contextId: serializer.fromJson<String>(json['contextId']),
      associationId: serializer.fromJson<String?>(json['associationId']),
      syncScope: serializer.fromJson<String>(json['syncScope']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime?>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'contextId': serializer.toJson<String>(contextId),
      'associationId': serializer.toJson<String?>(associationId),
      'syncScope': serializer.toJson<String>(syncScope),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime?>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LibraryItemContext copyWith({
    String? itemId,
    String? contextId,
    Value<String?> associationId = const Value.absent(),
    String? syncScope,
    DateTime? createdAt,
    Value<DateTime?> updatedAtLocal = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LibraryItemContext(
    itemId: itemId ?? this.itemId,
    contextId: contextId ?? this.contextId,
    associationId: associationId.present
        ? associationId.value
        : this.associationId,
    syncScope: syncScope ?? this.syncScope,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal.present
        ? updatedAtLocal.value
        : this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LibraryItemContext copyWithCompanion(LibraryItemContextsCompanion data) {
    return LibraryItemContext(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      contextId: data.contextId.present ? data.contextId.value : this.contextId,
      associationId: data.associationId.present
          ? data.associationId.value
          : this.associationId,
      syncScope: data.syncScope.present ? data.syncScope.value : this.syncScope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItemContext(')
          ..write('itemId: $itemId, ')
          ..write('contextId: $contextId, ')
          ..write('associationId: $associationId, ')
          ..write('syncScope: $syncScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    contextId,
    associationId,
    syncScope,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryItemContext &&
          other.itemId == this.itemId &&
          other.contextId == this.contextId &&
          other.associationId == this.associationId &&
          other.syncScope == this.syncScope &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class LibraryItemContextsCompanion extends UpdateCompanion<LibraryItemContext> {
  final Value<String> itemId;
  final Value<String> contextId;
  final Value<String?> associationId;
  final Value<String> syncScope;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LibraryItemContextsCompanion({
    this.itemId = const Value.absent(),
    this.contextId = const Value.absent(),
    this.associationId = const Value.absent(),
    this.syncScope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryItemContextsCompanion.insert({
    required String itemId,
    required String contextId,
    this.associationId = const Value.absent(),
    this.syncScope = const Value.absent(),
    required DateTime createdAt,
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       contextId = Value(contextId),
       createdAt = Value(createdAt);
  static Insertable<LibraryItemContext> custom({
    Expression<String>? itemId,
    Expression<String>? contextId,
    Expression<String>? associationId,
    Expression<String>? syncScope,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (contextId != null) 'context_id': contextId,
      if (associationId != null) 'association_id': associationId,
      if (syncScope != null) 'sync_scope': syncScope,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryItemContextsCompanion copyWith({
    Value<String>? itemId,
    Value<String>? contextId,
    Value<String?>? associationId,
    Value<String>? syncScope,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LibraryItemContextsCompanion(
      itemId: itemId ?? this.itemId,
      contextId: contextId ?? this.contextId,
      associationId: associationId ?? this.associationId,
      syncScope: syncScope ?? this.syncScope,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (contextId.present) {
      map['context_id'] = Variable<String>(contextId.value);
    }
    if (associationId.present) {
      map['association_id'] = Variable<String>(associationId.value);
    }
    if (syncScope.present) {
      map['sync_scope'] = Variable<String>(syncScope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItemContextsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('contextId: $contextId, ')
          ..write('associationId: $associationId, ')
          ..write('syncScope: $syncScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationJsonMeta = const VerificationMeta(
    'destinationJson',
  );
  @override
  late final GeneratedColumn<String> destinationJson = GeneratedColumn<String>(
    'destination_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shareStateMeta = const VerificationMeta(
    'shareState',
  );
  @override
  late final GeneratedColumn<String> shareState = GeneratedColumn<String>(
    'share_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _remoteRecordIdMeta = const VerificationMeta(
    'remoteRecordId',
  );
  @override
  late final GeneratedColumn<String> remoteRecordId = GeneratedColumn<String>(
    'remote_record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _shareCodeMeta = const VerificationMeta(
    'shareCode',
  );
  @override
  late final GeneratedColumn<String> shareCode = GeneratedColumn<String>(
    'share_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<int> remoteRevision = GeneratedColumn<int>(
    'remote_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    destinationJson,
    startDate,
    endDate,
    shareState,
    remoteRecordId,
    shareCode,
    remoteRevision,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('destination_json')) {
      context.handle(
        _destinationJsonMeta,
        destinationJson.isAcceptableOrUnknown(
          data['destination_json']!,
          _destinationJsonMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('share_state')) {
      context.handle(
        _shareStateMeta,
        shareState.isAcceptableOrUnknown(data['share_state']!, _shareStateMeta),
      );
    }
    if (data.containsKey('remote_record_id')) {
      context.handle(
        _remoteRecordIdMeta,
        remoteRecordId.isAcceptableOrUnknown(
          data['remote_record_id']!,
          _remoteRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('share_code')) {
      context.handle(
        _shareCodeMeta,
        shareCode.isAcceptableOrUnknown(data['share_code']!, _shareCodeMeta),
      );
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      destinationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_json'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      shareState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_state'],
      )!,
      remoteRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_record_id'],
      ),
      shareCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_code'],
      ),
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_revision'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final String id;
  final String name;
  final String? destinationJson;
  final DateTime? startDate;
  final DateTime? endDate;
  final String shareState;
  final String? remoteRecordId;
  final String? shareCode;
  final int? remoteRevision;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const Trip({
    required this.id,
    required this.name,
    this.destinationJson,
    this.startDate,
    this.endDate,
    required this.shareState,
    this.remoteRecordId,
    this.shareCode,
    this.remoteRevision,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || destinationJson != null) {
      map['destination_json'] = Variable<String>(destinationJson);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['share_state'] = Variable<String>(shareState);
    if (!nullToAbsent || remoteRecordId != null) {
      map['remote_record_id'] = Variable<String>(remoteRecordId);
    }
    if (!nullToAbsent || shareCode != null) {
      map['share_code'] = Variable<String>(shareCode);
    }
    if (!nullToAbsent || remoteRevision != null) {
      map['remote_revision'] = Variable<int>(remoteRevision);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      name: Value(name),
      destinationJson: destinationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationJson),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      shareState: Value(shareState),
      remoteRecordId: remoteRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRecordId),
      shareCode: shareCode == null && nullToAbsent
          ? const Value.absent()
          : Value(shareCode),
      remoteRevision: remoteRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRevision),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Trip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      destinationJson: serializer.fromJson<String?>(json['destinationJson']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      shareState: serializer.fromJson<String>(json['shareState']),
      remoteRecordId: serializer.fromJson<String?>(json['remoteRecordId']),
      shareCode: serializer.fromJson<String?>(json['shareCode']),
      remoteRevision: serializer.fromJson<int?>(json['remoteRevision']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'destinationJson': serializer.toJson<String?>(destinationJson),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'shareState': serializer.toJson<String>(shareState),
      'remoteRecordId': serializer.toJson<String?>(remoteRecordId),
      'shareCode': serializer.toJson<String?>(shareCode),
      'remoteRevision': serializer.toJson<int?>(remoteRevision),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Trip copyWith({
    String? id,
    String? name,
    Value<String?> destinationJson = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    String? shareState,
    Value<String?> remoteRecordId = const Value.absent(),
    Value<String?> shareCode = const Value.absent(),
    Value<int?> remoteRevision = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Trip(
    id: id ?? this.id,
    name: name ?? this.name,
    destinationJson: destinationJson.present
        ? destinationJson.value
        : this.destinationJson,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    shareState: shareState ?? this.shareState,
    remoteRecordId: remoteRecordId.present
        ? remoteRecordId.value
        : this.remoteRecordId,
    shareCode: shareCode.present ? shareCode.value : this.shareCode,
    remoteRevision: remoteRevision.present
        ? remoteRevision.value
        : this.remoteRevision,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      destinationJson: data.destinationJson.present
          ? data.destinationJson.value
          : this.destinationJson,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      shareState: data.shareState.present
          ? data.shareState.value
          : this.shareState,
      remoteRecordId: data.remoteRecordId.present
          ? data.remoteRecordId.value
          : this.remoteRecordId,
      shareCode: data.shareCode.present ? data.shareCode.value : this.shareCode,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('destinationJson: $destinationJson, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('shareState: $shareState, ')
          ..write('remoteRecordId: $remoteRecordId, ')
          ..write('shareCode: $shareCode, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    destinationJson,
    startDate,
    endDate,
    shareState,
    remoteRecordId,
    shareCode,
    remoteRevision,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.name == this.name &&
          other.destinationJson == this.destinationJson &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.shareState == this.shareState &&
          other.remoteRecordId == this.remoteRecordId &&
          other.shareCode == this.shareCode &&
          other.remoteRevision == this.remoteRevision &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> destinationJson;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String> shareState;
  final Value<String?> remoteRecordId;
  final Value<String?> shareCode;
  final Value<int?> remoteRevision;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.destinationJson = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.shareState = const Value.absent(),
    this.remoteRecordId = const Value.absent(),
    this.shareCode = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String name,
    this.destinationJson = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.shareState = const Value.absent(),
    this.remoteRecordId = const Value.absent(),
    this.shareCode = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<Trip> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? destinationJson,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? shareState,
    Expression<String>? remoteRecordId,
    Expression<String>? shareCode,
    Expression<int>? remoteRevision,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (destinationJson != null) 'destination_json': destinationJson,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (shareState != null) 'share_state': shareState,
      if (remoteRecordId != null) 'remote_record_id': remoteRecordId,
      if (shareCode != null) 'share_code': shareCode,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? destinationJson,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String>? shareState,
    Value<String?>? remoteRecordId,
    Value<String?>? shareCode,
    Value<int?>? remoteRevision,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      destinationJson: destinationJson ?? this.destinationJson,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      shareState: shareState ?? this.shareState,
      remoteRecordId: remoteRecordId ?? this.remoteRecordId,
      shareCode: shareCode ?? this.shareCode,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (destinationJson.present) {
      map['destination_json'] = Variable<String>(destinationJson.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (shareState.present) {
      map['share_state'] = Variable<String>(shareState.value);
    }
    if (remoteRecordId.present) {
      map['remote_record_id'] = Variable<String>(remoteRecordId.value);
    }
    if (shareCode.present) {
      map['share_code'] = Variable<String>(shareCode.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<int>(remoteRevision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('destinationJson: $destinationJson, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('shareState: $shareState, ')
          ..write('remoteRecordId: $remoteRecordId, ')
          ..write('shareCode: $shareCode, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripMembersTable extends TripMembers
    with TableInfo<$TripMembersTable, TripMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _sourceOwnerIdMeta = const VerificationMeta(
    'sourceOwnerId',
  );
  @override
  late final GeneratedColumn<String> sourceOwnerId = GeneratedColumn<String>(
    'source_owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupKindMeta = const VerificationMeta(
    'groupKind',
  );
  @override
  late final GeneratedColumn<String> groupKind = GeneratedColumn<String>(
    'group_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    sourceOwnerId,
    groupKind,
    name,
    icon,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('source_owner_id')) {
      context.handle(
        _sourceOwnerIdMeta,
        sourceOwnerId.isAcceptableOrUnknown(
          data['source_owner_id']!,
          _sourceOwnerIdMeta,
        ),
      );
    }
    if (data.containsKey('group_kind')) {
      context.handle(
        _groupKindMeta,
        groupKind.isAcceptableOrUnknown(data['group_kind']!, _groupKindMeta),
      );
    } else if (isInserting) {
      context.missing(_groupKindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      sourceOwnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_owner_id'],
      ),
      groupKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TripMembersTable createAlias(String alias) {
    return $TripMembersTable(attachedDatabase, alias);
  }
}

class TripMember extends DataClass implements Insertable<TripMember> {
  final String id;
  final String tripId;
  final String? sourceOwnerId;
  final String groupKind;
  final String name;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const TripMember({
    required this.id,
    required this.tripId,
    this.sourceOwnerId,
    required this.groupKind,
    required this.name,
    this.icon,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || sourceOwnerId != null) {
      map['source_owner_id'] = Variable<String>(sourceOwnerId);
    }
    map['group_kind'] = Variable<String>(groupKind);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TripMembersCompanion toCompanion(bool nullToAbsent) {
    return TripMembersCompanion(
      id: Value(id),
      tripId: Value(tripId),
      sourceOwnerId: sourceOwnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceOwnerId),
      groupKind: Value(groupKind),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TripMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripMember(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      sourceOwnerId: serializer.fromJson<String?>(json['sourceOwnerId']),
      groupKind: serializer.fromJson<String>(json['groupKind']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'sourceOwnerId': serializer.toJson<String?>(sourceOwnerId),
      'groupKind': serializer.toJson<String>(groupKind),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TripMember copyWith({
    String? id,
    String? tripId,
    Value<String?> sourceOwnerId = const Value.absent(),
    String? groupKind,
    String? name,
    Value<String?> icon = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TripMember(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    sourceOwnerId: sourceOwnerId.present
        ? sourceOwnerId.value
        : this.sourceOwnerId,
    groupKind: groupKind ?? this.groupKind,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TripMember copyWithCompanion(TripMembersCompanion data) {
    return TripMember(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      sourceOwnerId: data.sourceOwnerId.present
          ? data.sourceOwnerId.value
          : this.sourceOwnerId,
      groupKind: data.groupKind.present ? data.groupKind.value : this.groupKind,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripMember(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sourceOwnerId: $sourceOwnerId, ')
          ..write('groupKind: $groupKind, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    sourceOwnerId,
    groupKind,
    name,
    icon,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripMember &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.sourceOwnerId == this.sourceOwnerId &&
          other.groupKind == this.groupKind &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class TripMembersCompanion extends UpdateCompanion<TripMember> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> sourceOwnerId;
  final Value<String> groupKind;
  final Value<String> name;
  final Value<String?> icon;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TripMembersCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.sourceOwnerId = const Value.absent(),
    this.groupKind = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripMembersCompanion.insert({
    required String id,
    required String tripId,
    this.sourceOwnerId = const Value.absent(),
    required String groupKind,
    required String name,
    this.icon = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       groupKind = Value(groupKind),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<TripMember> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? sourceOwnerId,
    Expression<String>? groupKind,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (sourceOwnerId != null) 'source_owner_id': sourceOwnerId,
      if (groupKind != null) 'group_kind': groupKind,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String?>? sourceOwnerId,
    Value<String>? groupKind,
    Value<String>? name,
    Value<String?>? icon,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TripMembersCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      sourceOwnerId: sourceOwnerId ?? this.sourceOwnerId,
      groupKind: groupKind ?? this.groupKind,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (sourceOwnerId.present) {
      map['source_owner_id'] = Variable<String>(sourceOwnerId.value);
    }
    if (groupKind.present) {
      map['group_kind'] = Variable<String>(groupKind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripMembersCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sourceOwnerId: $sourceOwnerId, ')
          ..write('groupKind: $groupKind, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripCategoriesTable extends TripCategories
    with TableInfo<$TripCategoriesTable, TripCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_members (id)',
    ),
  );
  static const VerificationMeta _sourceCategoryIdMeta = const VerificationMeta(
    'sourceCategoryId',
  );
  @override
  late final GeneratedColumn<String> sourceCategoryId = GeneratedColumn<String>(
    'source_category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    memberId,
    sourceCategoryId,
    name,
    icon,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    }
    if (data.containsKey('source_category_id')) {
      context.handle(
        _sourceCategoryIdMeta,
        sourceCategoryId.isAcceptableOrUnknown(
          data['source_category_id']!,
          _sourceCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      sourceCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_category_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TripCategoriesTable createAlias(String alias) {
    return $TripCategoriesTable(attachedDatabase, alias);
  }
}

class TripCategory extends DataClass implements Insertable<TripCategory> {
  final String id;
  final String tripId;
  final String? memberId;
  final String? sourceCategoryId;
  final String name;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const TripCategory({
    required this.id,
    required this.tripId,
    this.memberId,
    this.sourceCategoryId,
    required this.name,
    this.icon,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    if (!nullToAbsent || sourceCategoryId != null) {
      map['source_category_id'] = Variable<String>(sourceCategoryId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TripCategoriesCompanion toCompanion(bool nullToAbsent) {
    return TripCategoriesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      sourceCategoryId: sourceCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceCategoryId),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TripCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripCategory(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      sourceCategoryId: serializer.fromJson<String?>(json['sourceCategoryId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'memberId': serializer.toJson<String?>(memberId),
      'sourceCategoryId': serializer.toJson<String?>(sourceCategoryId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TripCategory copyWith({
    String? id,
    String? tripId,
    Value<String?> memberId = const Value.absent(),
    Value<String?> sourceCategoryId = const Value.absent(),
    String? name,
    Value<String?> icon = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TripCategory(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    memberId: memberId.present ? memberId.value : this.memberId,
    sourceCategoryId: sourceCategoryId.present
        ? sourceCategoryId.value
        : this.sourceCategoryId,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TripCategory copyWithCompanion(TripCategoriesCompanion data) {
    return TripCategory(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      sourceCategoryId: data.sourceCategoryId.present
          ? data.sourceCategoryId.value
          : this.sourceCategoryId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripCategory(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('memberId: $memberId, ')
          ..write('sourceCategoryId: $sourceCategoryId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    memberId,
    sourceCategoryId,
    name,
    icon,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripCategory &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.memberId == this.memberId &&
          other.sourceCategoryId == this.sourceCategoryId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class TripCategoriesCompanion extends UpdateCompanion<TripCategory> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> memberId;
  final Value<String?> sourceCategoryId;
  final Value<String> name;
  final Value<String?> icon;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TripCategoriesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.sourceCategoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripCategoriesCompanion.insert({
    required String id,
    required String tripId,
    this.memberId = const Value.absent(),
    this.sourceCategoryId = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<TripCategory> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? memberId,
    Expression<String>? sourceCategoryId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (memberId != null) 'member_id': memberId,
      if (sourceCategoryId != null) 'source_category_id': sourceCategoryId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String?>? memberId,
    Value<String?>? sourceCategoryId,
    Value<String>? name,
    Value<String?>? icon,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TripCategoriesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      memberId: memberId ?? this.memberId,
      sourceCategoryId: sourceCategoryId ?? this.sourceCategoryId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (sourceCategoryId.present) {
      map['source_category_id'] = Variable<String>(sourceCategoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('memberId: $memberId, ')
          ..write('sourceCategoryId: $sourceCategoryId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripItemsTable extends TripItems
    with TableInfo<$TripItemsTable, TripItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_categories (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('todo'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    categoryId,
    name,
    quantity,
    status,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TripItemsTable createAlias(String alias) {
    return $TripItemsTable(attachedDatabase, alias);
  }
}

class TripItem extends DataClass implements Insertable<TripItem> {
  final String id;
  final String tripId;
  final String categoryId;
  final String name;
  final int quantity;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const TripItem({
    required this.id,
    required this.tripId,
    required this.categoryId,
    required this.name,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TripItemsCompanion toCompanion(bool nullToAbsent) {
    return TripItemsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      categoryId: Value(categoryId),
      name: Value(name),
      quantity: Value(quantity),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TripItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripItem(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TripItem copyWith({
    String? id,
    String? tripId,
    String? categoryId,
    String? name,
    int? quantity,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TripItem(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TripItem copyWithCompanion(TripItemsCompanion data) {
    return TripItem(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripItem(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    categoryId,
    name,
    quantity,
    status,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripItem &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class TripItemsCompanion extends UpdateCompanion<TripItem> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<int> quantity;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TripItemsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripItemsCompanion.insert({
    required String id,
    required String tripId,
    required String categoryId,
    required String name,
    this.quantity = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       categoryId = Value(categoryId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<TripItem> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? categoryId,
    Value<String>? name,
    Value<int>? quantity,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TripItemsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripItemsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripItemSourcesTable extends TripItemSources
    with TableInfo<$TripItemSourcesTable, TripItemSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripItemSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tripItemIdMeta = const VerificationMeta(
    'tripItemId',
  );
  @override
  late final GeneratedColumn<String> tripItemId = GeneratedColumn<String>(
    'trip_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_items (id)',
    ),
  );
  static const VerificationMeta _sourceLibraryItemIdMeta =
      const VerificationMeta('sourceLibraryItemId');
  @override
  late final GeneratedColumn<String> sourceLibraryItemId =
      GeneratedColumn<String>(
        'source_library_item_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonKindMeta = const VerificationMeta(
    'reasonKind',
  );
  @override
  late final GeneratedColumn<String> reasonKind = GeneratedColumn<String>(
    'reason_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('legacy'),
  );
  static const VerificationMeta _reasonIdMeta = const VerificationMeta(
    'reasonId',
  );
  @override
  late final GeneratedColumn<String> reasonId = GeneratedColumn<String>(
    'reason_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contributingLibraryItemIdMeta =
      const VerificationMeta('contributingLibraryItemId');
  @override
  late final GeneratedColumn<String> contributingLibraryItemId =
      GeneratedColumn<String>(
        'contributing_library_item_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    tripItemId,
    sourceLibraryItemId,
    sourceKind,
    reasonKind,
    reasonId,
    contributingLibraryItemId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_item_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripItemSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('trip_item_id')) {
      context.handle(
        _tripItemIdMeta,
        tripItemId.isAcceptableOrUnknown(
          data['trip_item_id']!,
          _tripItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tripItemIdMeta);
    }
    if (data.containsKey('source_library_item_id')) {
      context.handle(
        _sourceLibraryItemIdMeta,
        sourceLibraryItemId.isAcceptableOrUnknown(
          data['source_library_item_id']!,
          _sourceLibraryItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLibraryItemIdMeta);
    }
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKindMeta);
    }
    if (data.containsKey('reason_kind')) {
      context.handle(
        _reasonKindMeta,
        reasonKind.isAcceptableOrUnknown(data['reason_kind']!, _reasonKindMeta),
      );
    }
    if (data.containsKey('reason_id')) {
      context.handle(
        _reasonIdMeta,
        reasonId.isAcceptableOrUnknown(data['reason_id']!, _reasonIdMeta),
      );
    }
    if (data.containsKey('contributing_library_item_id')) {
      context.handle(
        _contributingLibraryItemIdMeta,
        contributingLibraryItemId.isAcceptableOrUnknown(
          data['contributing_library_item_id']!,
          _contributingLibraryItemIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    tripItemId,
    sourceLibraryItemId,
    sourceKind,
  };
  @override
  TripItemSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripItemSource(
      tripItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_item_id'],
      )!,
      sourceLibraryItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_library_item_id'],
      )!,
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
      )!,
      reasonKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_kind'],
      )!,
      reasonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_id'],
      )!,
      contributingLibraryItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contributing_library_item_id'],
      ),
    );
  }

  @override
  $TripItemSourcesTable createAlias(String alias) {
    return $TripItemSourcesTable(attachedDatabase, alias);
  }
}

class TripItemSource extends DataClass implements Insertable<TripItemSource> {
  final String tripItemId;
  final String sourceLibraryItemId;
  final String sourceKind;
  final String reasonKind;
  final String reasonId;
  final String? contributingLibraryItemId;
  const TripItemSource({
    required this.tripItemId,
    required this.sourceLibraryItemId,
    required this.sourceKind,
    required this.reasonKind,
    required this.reasonId,
    this.contributingLibraryItemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trip_item_id'] = Variable<String>(tripItemId);
    map['source_library_item_id'] = Variable<String>(sourceLibraryItemId);
    map['source_kind'] = Variable<String>(sourceKind);
    map['reason_kind'] = Variable<String>(reasonKind);
    map['reason_id'] = Variable<String>(reasonId);
    if (!nullToAbsent || contributingLibraryItemId != null) {
      map['contributing_library_item_id'] = Variable<String>(
        contributingLibraryItemId,
      );
    }
    return map;
  }

  TripItemSourcesCompanion toCompanion(bool nullToAbsent) {
    return TripItemSourcesCompanion(
      tripItemId: Value(tripItemId),
      sourceLibraryItemId: Value(sourceLibraryItemId),
      sourceKind: Value(sourceKind),
      reasonKind: Value(reasonKind),
      reasonId: Value(reasonId),
      contributingLibraryItemId:
          contributingLibraryItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(contributingLibraryItemId),
    );
  }

  factory TripItemSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripItemSource(
      tripItemId: serializer.fromJson<String>(json['tripItemId']),
      sourceLibraryItemId: serializer.fromJson<String>(
        json['sourceLibraryItemId'],
      ),
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      reasonKind: serializer.fromJson<String>(json['reasonKind']),
      reasonId: serializer.fromJson<String>(json['reasonId']),
      contributingLibraryItemId: serializer.fromJson<String?>(
        json['contributingLibraryItemId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tripItemId': serializer.toJson<String>(tripItemId),
      'sourceLibraryItemId': serializer.toJson<String>(sourceLibraryItemId),
      'sourceKind': serializer.toJson<String>(sourceKind),
      'reasonKind': serializer.toJson<String>(reasonKind),
      'reasonId': serializer.toJson<String>(reasonId),
      'contributingLibraryItemId': serializer.toJson<String?>(
        contributingLibraryItemId,
      ),
    };
  }

  TripItemSource copyWith({
    String? tripItemId,
    String? sourceLibraryItemId,
    String? sourceKind,
    String? reasonKind,
    String? reasonId,
    Value<String?> contributingLibraryItemId = const Value.absent(),
  }) => TripItemSource(
    tripItemId: tripItemId ?? this.tripItemId,
    sourceLibraryItemId: sourceLibraryItemId ?? this.sourceLibraryItemId,
    sourceKind: sourceKind ?? this.sourceKind,
    reasonKind: reasonKind ?? this.reasonKind,
    reasonId: reasonId ?? this.reasonId,
    contributingLibraryItemId: contributingLibraryItemId.present
        ? contributingLibraryItemId.value
        : this.contributingLibraryItemId,
  );
  TripItemSource copyWithCompanion(TripItemSourcesCompanion data) {
    return TripItemSource(
      tripItemId: data.tripItemId.present
          ? data.tripItemId.value
          : this.tripItemId,
      sourceLibraryItemId: data.sourceLibraryItemId.present
          ? data.sourceLibraryItemId.value
          : this.sourceLibraryItemId,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      reasonKind: data.reasonKind.present
          ? data.reasonKind.value
          : this.reasonKind,
      reasonId: data.reasonId.present ? data.reasonId.value : this.reasonId,
      contributingLibraryItemId: data.contributingLibraryItemId.present
          ? data.contributingLibraryItemId.value
          : this.contributingLibraryItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripItemSource(')
          ..write('tripItemId: $tripItemId, ')
          ..write('sourceLibraryItemId: $sourceLibraryItemId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('reasonKind: $reasonKind, ')
          ..write('reasonId: $reasonId, ')
          ..write('contributingLibraryItemId: $contributingLibraryItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    tripItemId,
    sourceLibraryItemId,
    sourceKind,
    reasonKind,
    reasonId,
    contributingLibraryItemId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripItemSource &&
          other.tripItemId == this.tripItemId &&
          other.sourceLibraryItemId == this.sourceLibraryItemId &&
          other.sourceKind == this.sourceKind &&
          other.reasonKind == this.reasonKind &&
          other.reasonId == this.reasonId &&
          other.contributingLibraryItemId == this.contributingLibraryItemId);
}

class TripItemSourcesCompanion extends UpdateCompanion<TripItemSource> {
  final Value<String> tripItemId;
  final Value<String> sourceLibraryItemId;
  final Value<String> sourceKind;
  final Value<String> reasonKind;
  final Value<String> reasonId;
  final Value<String?> contributingLibraryItemId;
  final Value<int> rowid;
  const TripItemSourcesCompanion({
    this.tripItemId = const Value.absent(),
    this.sourceLibraryItemId = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.reasonKind = const Value.absent(),
    this.reasonId = const Value.absent(),
    this.contributingLibraryItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripItemSourcesCompanion.insert({
    required String tripItemId,
    required String sourceLibraryItemId,
    required String sourceKind,
    this.reasonKind = const Value.absent(),
    this.reasonId = const Value.absent(),
    this.contributingLibraryItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tripItemId = Value(tripItemId),
       sourceLibraryItemId = Value(sourceLibraryItemId),
       sourceKind = Value(sourceKind);
  static Insertable<TripItemSource> custom({
    Expression<String>? tripItemId,
    Expression<String>? sourceLibraryItemId,
    Expression<String>? sourceKind,
    Expression<String>? reasonKind,
    Expression<String>? reasonId,
    Expression<String>? contributingLibraryItemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tripItemId != null) 'trip_item_id': tripItemId,
      if (sourceLibraryItemId != null)
        'source_library_item_id': sourceLibraryItemId,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (reasonKind != null) 'reason_kind': reasonKind,
      if (reasonId != null) 'reason_id': reasonId,
      if (contributingLibraryItemId != null)
        'contributing_library_item_id': contributingLibraryItemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripItemSourcesCompanion copyWith({
    Value<String>? tripItemId,
    Value<String>? sourceLibraryItemId,
    Value<String>? sourceKind,
    Value<String>? reasonKind,
    Value<String>? reasonId,
    Value<String?>? contributingLibraryItemId,
    Value<int>? rowid,
  }) {
    return TripItemSourcesCompanion(
      tripItemId: tripItemId ?? this.tripItemId,
      sourceLibraryItemId: sourceLibraryItemId ?? this.sourceLibraryItemId,
      sourceKind: sourceKind ?? this.sourceKind,
      reasonKind: reasonKind ?? this.reasonKind,
      reasonId: reasonId ?? this.reasonId,
      contributingLibraryItemId:
          contributingLibraryItemId ?? this.contributingLibraryItemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tripItemId.present) {
      map['trip_item_id'] = Variable<String>(tripItemId.value);
    }
    if (sourceLibraryItemId.present) {
      map['source_library_item_id'] = Variable<String>(
        sourceLibraryItemId.value,
      );
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (reasonKind.present) {
      map['reason_kind'] = Variable<String>(reasonKind.value);
    }
    if (reasonId.present) {
      map['reason_id'] = Variable<String>(reasonId.value);
    }
    if (contributingLibraryItemId.present) {
      map['contributing_library_item_id'] = Variable<String>(
        contributingLibraryItemId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripItemSourcesCompanion(')
          ..write('tripItemId: $tripItemId, ')
          ..write('sourceLibraryItemId: $sourceLibraryItemId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('reasonKind: $reasonKind, ')
          ..write('reasonId: $reasonId, ')
          ..write('contributingLibraryItemId: $contributingLibraryItemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripGenerationChoicesTable extends TripGenerationChoices
    with TableInfo<$TripGenerationChoicesTable, TripGenerationChoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripGenerationChoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _choiceKindMeta = const VerificationMeta(
    'choiceKind',
  );
  @override
  late final GeneratedColumn<String> choiceKind = GeneratedColumn<String>(
    'choice_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _choiceIdMeta = const VerificationMeta(
    'choiceId',
  );
  @override
  late final GeneratedColumn<String> choiceId = GeneratedColumn<String>(
    'choice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    choiceKind,
    choiceId,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_generation_choices';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripGenerationChoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('choice_kind')) {
      context.handle(
        _choiceKindMeta,
        choiceKind.isAcceptableOrUnknown(data['choice_kind']!, _choiceKindMeta),
      );
    } else if (isInserting) {
      context.missing(_choiceKindMeta);
    }
    if (data.containsKey('choice_id')) {
      context.handle(
        _choiceIdMeta,
        choiceId.isAcceptableOrUnknown(data['choice_id']!, _choiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_choiceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tripId, choiceKind, choiceId},
  ];
  @override
  TripGenerationChoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripGenerationChoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      choiceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}choice_kind'],
      )!,
      choiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}choice_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TripGenerationChoicesTable createAlias(String alias) {
    return $TripGenerationChoicesTable(attachedDatabase, alias);
  }
}

class TripGenerationChoice extends DataClass
    implements Insertable<TripGenerationChoice> {
  final String id;
  final String tripId;
  final String choiceKind;
  final String choiceId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const TripGenerationChoice({
    required this.id,
    required this.tripId,
    required this.choiceKind,
    required this.choiceId,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['choice_kind'] = Variable<String>(choiceKind);
    map['choice_id'] = Variable<String>(choiceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TripGenerationChoicesCompanion toCompanion(bool nullToAbsent) {
    return TripGenerationChoicesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      choiceKind: Value(choiceKind),
      choiceId: Value(choiceId),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TripGenerationChoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripGenerationChoice(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      choiceKind: serializer.fromJson<String>(json['choiceKind']),
      choiceId: serializer.fromJson<String>(json['choiceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'choiceKind': serializer.toJson<String>(choiceKind),
      'choiceId': serializer.toJson<String>(choiceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TripGenerationChoice copyWith({
    String? id,
    String? tripId,
    String? choiceKind,
    String? choiceId,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TripGenerationChoice(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    choiceKind: choiceKind ?? this.choiceKind,
    choiceId: choiceId ?? this.choiceId,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TripGenerationChoice copyWithCompanion(TripGenerationChoicesCompanion data) {
    return TripGenerationChoice(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      choiceKind: data.choiceKind.present
          ? data.choiceKind.value
          : this.choiceKind,
      choiceId: data.choiceId.present ? data.choiceId.value : this.choiceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripGenerationChoice(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('choiceKind: $choiceKind, ')
          ..write('choiceId: $choiceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tripId, choiceKind, choiceId, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripGenerationChoice &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.choiceKind == this.choiceKind &&
          other.choiceId == this.choiceId &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class TripGenerationChoicesCompanion
    extends UpdateCompanion<TripGenerationChoice> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> choiceKind;
  final Value<String> choiceId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TripGenerationChoicesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.choiceKind = const Value.absent(),
    this.choiceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripGenerationChoicesCompanion.insert({
    required String id,
    required String tripId,
    required String choiceKind,
    required String choiceId,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       choiceKind = Value(choiceKind),
       choiceId = Value(choiceId),
       createdAt = Value(createdAt);
  static Insertable<TripGenerationChoice> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? choiceKind,
    Expression<String>? choiceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (choiceKind != null) 'choice_kind': choiceKind,
      if (choiceId != null) 'choice_id': choiceId,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripGenerationChoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? choiceKind,
    Value<String>? choiceId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TripGenerationChoicesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      choiceKind: choiceKind ?? this.choiceKind,
      choiceId: choiceId ?? this.choiceId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (choiceKind.present) {
      map['choice_kind'] = Variable<String>(choiceKind.value);
    }
    if (choiceId.present) {
      map['choice_id'] = Variable<String>(choiceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripGenerationChoicesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('choiceKind: $choiceKind, ')
          ..write('choiceId: $choiceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuickListsTable extends QuickLists
    with TableInfo<$QuickListsTable, QuickList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuickListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shareStateMeta = const VerificationMeta(
    'shareState',
  );
  @override
  late final GeneratedColumn<String> shareState = GeneratedColumn<String>(
    'share_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _remoteRecordIdMeta = const VerificationMeta(
    'remoteRecordId',
  );
  @override
  late final GeneratedColumn<String> remoteRecordId = GeneratedColumn<String>(
    'remote_record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _shareCodeMeta = const VerificationMeta(
    'shareCode',
  );
  @override
  late final GeneratedColumn<String> shareCode = GeneratedColumn<String>(
    'share_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<int> remoteRevision = GeneratedColumn<int>(
    'remote_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    shareState,
    remoteRecordId,
    shareCode,
    remoteRevision,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuickList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('share_state')) {
      context.handle(
        _shareStateMeta,
        shareState.isAcceptableOrUnknown(data['share_state']!, _shareStateMeta),
      );
    }
    if (data.containsKey('remote_record_id')) {
      context.handle(
        _remoteRecordIdMeta,
        remoteRecordId.isAcceptableOrUnknown(
          data['remote_record_id']!,
          _remoteRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('share_code')) {
      context.handle(
        _shareCodeMeta,
        shareCode.isAcceptableOrUnknown(data['share_code']!, _shareCodeMeta),
      );
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuickList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuickList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      shareState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_state'],
      )!,
      remoteRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_record_id'],
      ),
      shareCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_code'],
      ),
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_revision'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $QuickListsTable createAlias(String alias) {
    return $QuickListsTable(attachedDatabase, alias);
  }
}

class QuickList extends DataClass implements Insertable<QuickList> {
  final String id;
  final String name;
  final String shareState;
  final String? remoteRecordId;
  final String? shareCode;
  final int? remoteRevision;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const QuickList({
    required this.id,
    required this.name,
    required this.shareState,
    this.remoteRecordId,
    this.shareCode,
    this.remoteRevision,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['share_state'] = Variable<String>(shareState);
    if (!nullToAbsent || remoteRecordId != null) {
      map['remote_record_id'] = Variable<String>(remoteRecordId);
    }
    if (!nullToAbsent || shareCode != null) {
      map['share_code'] = Variable<String>(shareCode);
    }
    if (!nullToAbsent || remoteRevision != null) {
      map['remote_revision'] = Variable<int>(remoteRevision);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  QuickListsCompanion toCompanion(bool nullToAbsent) {
    return QuickListsCompanion(
      id: Value(id),
      name: Value(name),
      shareState: Value(shareState),
      remoteRecordId: remoteRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRecordId),
      shareCode: shareCode == null && nullToAbsent
          ? const Value.absent()
          : Value(shareCode),
      remoteRevision: remoteRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRevision),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory QuickList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuickList(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shareState: serializer.fromJson<String>(json['shareState']),
      remoteRecordId: serializer.fromJson<String?>(json['remoteRecordId']),
      shareCode: serializer.fromJson<String?>(json['shareCode']),
      remoteRevision: serializer.fromJson<int?>(json['remoteRevision']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'shareState': serializer.toJson<String>(shareState),
      'remoteRecordId': serializer.toJson<String?>(remoteRecordId),
      'shareCode': serializer.toJson<String?>(shareCode),
      'remoteRevision': serializer.toJson<int?>(remoteRevision),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  QuickList copyWith({
    String? id,
    String? name,
    String? shareState,
    Value<String?> remoteRecordId = const Value.absent(),
    Value<String?> shareCode = const Value.absent(),
    Value<int?> remoteRevision = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => QuickList(
    id: id ?? this.id,
    name: name ?? this.name,
    shareState: shareState ?? this.shareState,
    remoteRecordId: remoteRecordId.present
        ? remoteRecordId.value
        : this.remoteRecordId,
    shareCode: shareCode.present ? shareCode.value : this.shareCode,
    remoteRevision: remoteRevision.present
        ? remoteRevision.value
        : this.remoteRevision,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  QuickList copyWithCompanion(QuickListsCompanion data) {
    return QuickList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shareState: data.shareState.present
          ? data.shareState.value
          : this.shareState,
      remoteRecordId: data.remoteRecordId.present
          ? data.remoteRecordId.value
          : this.remoteRecordId,
      shareCode: data.shareCode.present ? data.shareCode.value : this.shareCode,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuickList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shareState: $shareState, ')
          ..write('remoteRecordId: $remoteRecordId, ')
          ..write('shareCode: $shareCode, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    shareState,
    remoteRecordId,
    shareCode,
    remoteRevision,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickList &&
          other.id == this.id &&
          other.name == this.name &&
          other.shareState == this.shareState &&
          other.remoteRecordId == this.remoteRecordId &&
          other.shareCode == this.shareCode &&
          other.remoteRevision == this.remoteRevision &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class QuickListsCompanion extends UpdateCompanion<QuickList> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> shareState;
  final Value<String?> remoteRecordId;
  final Value<String?> shareCode;
  final Value<int?> remoteRevision;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const QuickListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shareState = const Value.absent(),
    this.remoteRecordId = const Value.absent(),
    this.shareCode = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuickListsCompanion.insert({
    required String id,
    required String name,
    this.shareState = const Value.absent(),
    this.remoteRecordId = const Value.absent(),
    this.shareCode = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<QuickList> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? shareState,
    Expression<String>? remoteRecordId,
    Expression<String>? shareCode,
    Expression<int>? remoteRevision,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shareState != null) 'share_state': shareState,
      if (remoteRecordId != null) 'remote_record_id': remoteRecordId,
      if (shareCode != null) 'share_code': shareCode,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuickListsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? shareState,
    Value<String?>? remoteRecordId,
    Value<String?>? shareCode,
    Value<int?>? remoteRevision,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return QuickListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shareState: shareState ?? this.shareState,
      remoteRecordId: remoteRecordId ?? this.remoteRecordId,
      shareCode: shareCode ?? this.shareCode,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shareState.present) {
      map['share_state'] = Variable<String>(shareState.value);
    }
    if (remoteRecordId.present) {
      map['remote_record_id'] = Variable<String>(remoteRecordId.value);
    }
    if (shareCode.present) {
      map['share_code'] = Variable<String>(shareCode.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<int>(remoteRevision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuickListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shareState: $shareState, ')
          ..write('remoteRecordId: $remoteRecordId, ')
          ..write('shareCode: $shareCode, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuickListItemsTable extends QuickListItems
    with TableInfo<$QuickListItemsTable, QuickListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuickListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quickListIdMeta = const VerificationMeta(
    'quickListId',
  );
  @override
  late final GeneratedColumn<String> quickListId = GeneratedColumn<String>(
    'quick_list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quick_lists (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isCheckedMeta = const VerificationMeta(
    'isChecked',
  );
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
    'is_checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtLocalMeta = const VerificationMeta(
    'updatedAtLocal',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtLocal =
      GeneratedColumn<DateTime>(
        'updated_at_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quickListId,
    name,
    quantity,
    isChecked,
    createdAt,
    updatedAtLocal,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_list_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuickListItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quick_list_id')) {
      context.handle(
        _quickListIdMeta,
        quickListId.isAcceptableOrUnknown(
          data['quick_list_id']!,
          _quickListIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quickListIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('is_checked')) {
      context.handle(
        _isCheckedMeta,
        isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at_local')) {
      context.handle(
        _updatedAtLocalMeta,
        updatedAtLocal.isAcceptableOrUnknown(
          data['updated_at_local']!,
          _updatedAtLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtLocalMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuickListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuickListItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      quickListId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quick_list_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      isChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_checked'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAtLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_local'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $QuickListItemsTable createAlias(String alias) {
    return $QuickListItemsTable(attachedDatabase, alias);
  }
}

class QuickListItem extends DataClass implements Insertable<QuickListItem> {
  final String id;
  final String quickListId;
  final String name;
  final int quantity;
  final bool isChecked;
  final DateTime createdAt;
  final DateTime updatedAtLocal;
  final DateTime? deletedAt;
  const QuickListItem({
    required this.id,
    required this.quickListId,
    required this.name,
    required this.quantity,
    required this.isChecked,
    required this.createdAt,
    required this.updatedAtLocal,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quick_list_id'] = Variable<String>(quickListId);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    map['is_checked'] = Variable<bool>(isChecked);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at_local'] = Variable<DateTime>(updatedAtLocal);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  QuickListItemsCompanion toCompanion(bool nullToAbsent) {
    return QuickListItemsCompanion(
      id: Value(id),
      quickListId: Value(quickListId),
      name: Value(name),
      quantity: Value(quantity),
      isChecked: Value(isChecked),
      createdAt: Value(createdAt),
      updatedAtLocal: Value(updatedAtLocal),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory QuickListItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuickListItem(
      id: serializer.fromJson<String>(json['id']),
      quickListId: serializer.fromJson<String>(json['quickListId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAtLocal: serializer.fromJson<DateTime>(json['updatedAtLocal']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quickListId': serializer.toJson<String>(quickListId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'isChecked': serializer.toJson<bool>(isChecked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAtLocal': serializer.toJson<DateTime>(updatedAtLocal),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  QuickListItem copyWith({
    String? id,
    String? quickListId,
    String? name,
    int? quantity,
    bool? isChecked,
    DateTime? createdAt,
    DateTime? updatedAtLocal,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => QuickListItem(
    id: id ?? this.id,
    quickListId: quickListId ?? this.quickListId,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    isChecked: isChecked ?? this.isChecked,
    createdAt: createdAt ?? this.createdAt,
    updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  QuickListItem copyWithCompanion(QuickListItemsCompanion data) {
    return QuickListItem(
      id: data.id.present ? data.id.value : this.id,
      quickListId: data.quickListId.present
          ? data.quickListId.value
          : this.quickListId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtLocal: data.updatedAtLocal.present
          ? data.updatedAtLocal.value
          : this.updatedAtLocal,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuickListItem(')
          ..write('id: $id, ')
          ..write('quickListId: $quickListId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('isChecked: $isChecked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    quickListId,
    name,
    quantity,
    isChecked,
    createdAt,
    updatedAtLocal,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickListItem &&
          other.id == this.id &&
          other.quickListId == this.quickListId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.isChecked == this.isChecked &&
          other.createdAt == this.createdAt &&
          other.updatedAtLocal == this.updatedAtLocal &&
          other.deletedAt == this.deletedAt);
}

class QuickListItemsCompanion extends UpdateCompanion<QuickListItem> {
  final Value<String> id;
  final Value<String> quickListId;
  final Value<String> name;
  final Value<int> quantity;
  final Value<bool> isChecked;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAtLocal;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const QuickListItemsCompanion({
    this.id = const Value.absent(),
    this.quickListId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAtLocal = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuickListItemsCompanion.insert({
    required String id,
    required String quickListId,
    required String name,
    this.quantity = const Value.absent(),
    this.isChecked = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAtLocal,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       quickListId = Value(quickListId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAtLocal = Value(updatedAtLocal);
  static Insertable<QuickListItem> custom({
    Expression<String>? id,
    Expression<String>? quickListId,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<bool>? isChecked,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAtLocal,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quickListId != null) 'quick_list_id': quickListId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (isChecked != null) 'is_checked': isChecked,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAtLocal != null) 'updated_at_local': updatedAtLocal,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuickListItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? quickListId,
    Value<String>? name,
    Value<int>? quantity,
    Value<bool>? isChecked,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAtLocal,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return QuickListItemsCompanion(
      id: id ?? this.id,
      quickListId: quickListId ?? this.quickListId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      updatedAtLocal: updatedAtLocal ?? this.updatedAtLocal,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quickListId.present) {
      map['quick_list_id'] = Variable<String>(quickListId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAtLocal.present) {
      map['updated_at_local'] = Variable<DateTime>(updatedAtLocal.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuickListItemsCompanion(')
          ..write('id: $id, ')
          ..write('quickListId: $quickListId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('isChecked: $isChecked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtLocal: $updatedAtLocal, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncDocumentsTable extends SyncDocuments
    with TableInfo<$SyncDocumentsTable, SyncDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentTypeMeta = const VerificationMeta(
    'documentType',
  );
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
    'document_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteRecordIdMeta = const VerificationMeta(
    'remoteRecordId',
  );
  @override
  late final GeneratedColumn<String> remoteRecordId = GeneratedColumn<String>(
    'remote_record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shareCodeMeta = const VerificationMeta(
    'shareCode',
  );
  @override
  late final GeneratedColumn<String> shareCode = GeneratedColumn<String>(
    'share_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capabilityTokenMeta = const VerificationMeta(
    'capabilityToken',
  );
  @override
  late final GeneratedColumn<String> capabilityToken = GeneratedColumn<String>(
    'capability_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pullCursorMeta = const VerificationMeta(
    'pullCursor',
  );
  @override
  late final GeneratedColumn<int> pullCursor = GeneratedColumn<int>(
    'pull_cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _confirmedRevisionMeta = const VerificationMeta(
    'confirmedRevision',
  );
  @override
  late final GeneratedColumn<int> confirmedRevision = GeneratedColumn<int>(
    'confirmed_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    documentId,
    documentType,
    remoteRecordId,
    shareCode,
    capabilityToken,
    pullCursor,
    confirmedRevision,
    lastSyncedAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('document_type')) {
      context.handle(
        _documentTypeMeta,
        documentType.isAcceptableOrUnknown(
          data['document_type']!,
          _documentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentTypeMeta);
    }
    if (data.containsKey('remote_record_id')) {
      context.handle(
        _remoteRecordIdMeta,
        remoteRecordId.isAcceptableOrUnknown(
          data['remote_record_id']!,
          _remoteRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('share_code')) {
      context.handle(
        _shareCodeMeta,
        shareCode.isAcceptableOrUnknown(data['share_code']!, _shareCodeMeta),
      );
    }
    if (data.containsKey('capability_token')) {
      context.handle(
        _capabilityTokenMeta,
        capabilityToken.isAcceptableOrUnknown(
          data['capability_token']!,
          _capabilityTokenMeta,
        ),
      );
    }
    if (data.containsKey('pull_cursor')) {
      context.handle(
        _pullCursorMeta,
        pullCursor.isAcceptableOrUnknown(data['pull_cursor']!, _pullCursorMeta),
      );
    }
    if (data.containsKey('confirmed_revision')) {
      context.handle(
        _confirmedRevisionMeta,
        confirmedRevision.isAcceptableOrUnknown(
          data['confirmed_revision']!,
          _confirmedRevisionMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentId};
  @override
  SyncDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncDocument(
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      documentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_type'],
      )!,
      remoteRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_record_id'],
      ),
      shareCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_code'],
      ),
      capabilityToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capability_token'],
      ),
      pullCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pull_cursor'],
      )!,
      confirmedRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirmed_revision'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncDocumentsTable createAlias(String alias) {
    return $SyncDocumentsTable(attachedDatabase, alias);
  }
}

class SyncDocument extends DataClass implements Insertable<SyncDocument> {
  final String documentId;
  final String documentType;
  final String? remoteRecordId;
  final String? shareCode;
  final String? capabilityToken;
  final int pullCursor;
  final int confirmedRevision;
  final DateTime? lastSyncedAt;
  final String? lastError;
  const SyncDocument({
    required this.documentId,
    required this.documentType,
    this.remoteRecordId,
    this.shareCode,
    this.capabilityToken,
    required this.pullCursor,
    required this.confirmedRevision,
    this.lastSyncedAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['document_id'] = Variable<String>(documentId);
    map['document_type'] = Variable<String>(documentType);
    if (!nullToAbsent || remoteRecordId != null) {
      map['remote_record_id'] = Variable<String>(remoteRecordId);
    }
    if (!nullToAbsent || shareCode != null) {
      map['share_code'] = Variable<String>(shareCode);
    }
    if (!nullToAbsent || capabilityToken != null) {
      map['capability_token'] = Variable<String>(capabilityToken);
    }
    map['pull_cursor'] = Variable<int>(pullCursor);
    map['confirmed_revision'] = Variable<int>(confirmedRevision);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncDocumentsCompanion toCompanion(bool nullToAbsent) {
    return SyncDocumentsCompanion(
      documentId: Value(documentId),
      documentType: Value(documentType),
      remoteRecordId: remoteRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRecordId),
      shareCode: shareCode == null && nullToAbsent
          ? const Value.absent()
          : Value(shareCode),
      capabilityToken: capabilityToken == null && nullToAbsent
          ? const Value.absent()
          : Value(capabilityToken),
      pullCursor: Value(pullCursor),
      confirmedRevision: Value(confirmedRevision),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncDocument(
      documentId: serializer.fromJson<String>(json['documentId']),
      documentType: serializer.fromJson<String>(json['documentType']),
      remoteRecordId: serializer.fromJson<String?>(json['remoteRecordId']),
      shareCode: serializer.fromJson<String?>(json['shareCode']),
      capabilityToken: serializer.fromJson<String?>(json['capabilityToken']),
      pullCursor: serializer.fromJson<int>(json['pullCursor']),
      confirmedRevision: serializer.fromJson<int>(json['confirmedRevision']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentId': serializer.toJson<String>(documentId),
      'documentType': serializer.toJson<String>(documentType),
      'remoteRecordId': serializer.toJson<String?>(remoteRecordId),
      'shareCode': serializer.toJson<String?>(shareCode),
      'capabilityToken': serializer.toJson<String?>(capabilityToken),
      'pullCursor': serializer.toJson<int>(pullCursor),
      'confirmedRevision': serializer.toJson<int>(confirmedRevision),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncDocument copyWith({
    String? documentId,
    String? documentType,
    Value<String?> remoteRecordId = const Value.absent(),
    Value<String?> shareCode = const Value.absent(),
    Value<String?> capabilityToken = const Value.absent(),
    int? pullCursor,
    int? confirmedRevision,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncDocument(
    documentId: documentId ?? this.documentId,
    documentType: documentType ?? this.documentType,
    remoteRecordId: remoteRecordId.present
        ? remoteRecordId.value
        : this.remoteRecordId,
    shareCode: shareCode.present ? shareCode.value : this.shareCode,
    capabilityToken: capabilityToken.present
        ? capabilityToken.value
        : this.capabilityToken,
    pullCursor: pullCursor ?? this.pullCursor,
    confirmedRevision: confirmedRevision ?? this.confirmedRevision,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncDocument copyWithCompanion(SyncDocumentsCompanion data) {
    return SyncDocument(
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      remoteRecordId: data.remoteRecordId.present
          ? data.remoteRecordId.value
          : this.remoteRecordId,
      shareCode: data.shareCode.present ? data.shareCode.value : this.shareCode,
      capabilityToken: data.capabilityToken.present
          ? data.capabilityToken.value
          : this.capabilityToken,
      pullCursor: data.pullCursor.present
          ? data.pullCursor.value
          : this.pullCursor,
      confirmedRevision: data.confirmedRevision.present
          ? data.confirmedRevision.value
          : this.confirmedRevision,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncDocument(')
          ..write('documentId: $documentId, ')
          ..write('documentType: $documentType, ')
          ..write('remoteRecordId: $remoteRecordId, ')
          ..write('shareCode: $shareCode, ')
          ..write('capabilityToken: $capabilityToken, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('confirmedRevision: $confirmedRevision, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    documentId,
    documentType,
    remoteRecordId,
    shareCode,
    capabilityToken,
    pullCursor,
    confirmedRevision,
    lastSyncedAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncDocument &&
          other.documentId == this.documentId &&
          other.documentType == this.documentType &&
          other.remoteRecordId == this.remoteRecordId &&
          other.shareCode == this.shareCode &&
          other.capabilityToken == this.capabilityToken &&
          other.pullCursor == this.pullCursor &&
          other.confirmedRevision == this.confirmedRevision &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastError == this.lastError);
}

class SyncDocumentsCompanion extends UpdateCompanion<SyncDocument> {
  final Value<String> documentId;
  final Value<String> documentType;
  final Value<String?> remoteRecordId;
  final Value<String?> shareCode;
  final Value<String?> capabilityToken;
  final Value<int> pullCursor;
  final Value<int> confirmedRevision;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncDocumentsCompanion({
    this.documentId = const Value.absent(),
    this.documentType = const Value.absent(),
    this.remoteRecordId = const Value.absent(),
    this.shareCode = const Value.absent(),
    this.capabilityToken = const Value.absent(),
    this.pullCursor = const Value.absent(),
    this.confirmedRevision = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncDocumentsCompanion.insert({
    required String documentId,
    required String documentType,
    this.remoteRecordId = const Value.absent(),
    this.shareCode = const Value.absent(),
    this.capabilityToken = const Value.absent(),
    this.pullCursor = const Value.absent(),
    this.confirmedRevision = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : documentId = Value(documentId),
       documentType = Value(documentType);
  static Insertable<SyncDocument> custom({
    Expression<String>? documentId,
    Expression<String>? documentType,
    Expression<String>? remoteRecordId,
    Expression<String>? shareCode,
    Expression<String>? capabilityToken,
    Expression<int>? pullCursor,
    Expression<int>? confirmedRevision,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentId != null) 'document_id': documentId,
      if (documentType != null) 'document_type': documentType,
      if (remoteRecordId != null) 'remote_record_id': remoteRecordId,
      if (shareCode != null) 'share_code': shareCode,
      if (capabilityToken != null) 'capability_token': capabilityToken,
      if (pullCursor != null) 'pull_cursor': pullCursor,
      if (confirmedRevision != null) 'confirmed_revision': confirmedRevision,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncDocumentsCompanion copyWith({
    Value<String>? documentId,
    Value<String>? documentType,
    Value<String?>? remoteRecordId,
    Value<String?>? shareCode,
    Value<String?>? capabilityToken,
    Value<int>? pullCursor,
    Value<int>? confirmedRevision,
    Value<DateTime?>? lastSyncedAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncDocumentsCompanion(
      documentId: documentId ?? this.documentId,
      documentType: documentType ?? this.documentType,
      remoteRecordId: remoteRecordId ?? this.remoteRecordId,
      shareCode: shareCode ?? this.shareCode,
      capabilityToken: capabilityToken ?? this.capabilityToken,
      pullCursor: pullCursor ?? this.pullCursor,
      confirmedRevision: confirmedRevision ?? this.confirmedRevision,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (remoteRecordId.present) {
      map['remote_record_id'] = Variable<String>(remoteRecordId.value);
    }
    if (shareCode.present) {
      map['share_code'] = Variable<String>(shareCode.value);
    }
    if (capabilityToken.present) {
      map['capability_token'] = Variable<String>(capabilityToken.value);
    }
    if (pullCursor.present) {
      map['pull_cursor'] = Variable<int>(pullCursor.value);
    }
    if (confirmedRevision.present) {
      map['confirmed_revision'] = Variable<int>(confirmedRevision.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncDocumentsCompanion(')
          ..write('documentId: $documentId, ')
          ..write('documentType: $documentType, ')
          ..write('remoteRecordId: $remoteRecordId, ')
          ..write('shareCode: $shareCode, ')
          ..write('capabilityToken: $capabilityToken, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('confirmedRevision: $confirmedRevision, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryIdMeta = const VerificationMeta(
    'libraryId',
  );
  @override
  late final GeneratedColumn<String> libraryId = GeneratedColumn<String>(
    'library_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('6d0f0d44-54f8-4f6a-b535-0a58d6efac11'),
  );
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _clientSequenceMeta = const VerificationMeta(
    'clientSequence',
  );
  @override
  late final GeneratedColumn<int> clientSequence = GeneratedColumn<int>(
    'client_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _clientCounterMeta = const VerificationMeta(
    'clientCounter',
  );
  @override
  late final GeneratedColumn<int> clientCounter = GeneratedColumn<int>(
    'client_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    documentId,
    entityType,
    entityId,
    operationType,
    payloadJson,
    libraryId,
    installationId,
    clientSequence,
    clientCounter,
    baseRevision,
    attempts,
    createdAt,
    nextAttemptAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('library_id')) {
      context.handle(
        _libraryIdMeta,
        libraryId.isAcceptableOrUnknown(data['library_id']!, _libraryIdMeta),
      );
    }
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('client_sequence')) {
      context.handle(
        _clientSequenceMeta,
        clientSequence.isAcceptableOrUnknown(
          data['client_sequence']!,
          _clientSequenceMeta,
        ),
      );
    }
    if (data.containsKey('client_counter')) {
      context.handle(
        _clientCounterMeta,
        clientCounter.isAcceptableOrUnknown(
          data['client_counter']!,
          _clientCounterMeta,
        ),
      );
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      libraryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_id'],
      )!,
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      )!,
      clientSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_sequence'],
      )!,
      clientCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_counter'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String operationId;
  final String documentId;
  final String entityType;
  final String entityId;
  final String operationType;
  final String payloadJson;
  final String libraryId;
  final String installationId;
  final int clientSequence;
  final int clientCounter;
  final int? baseRevision;
  final int attempts;
  final DateTime createdAt;
  final DateTime? nextAttemptAt;
  final String? lastError;
  const SyncOutboxData({
    required this.operationId,
    required this.documentId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payloadJson,
    required this.libraryId,
    required this.installationId,
    required this.clientSequence,
    required this.clientCounter,
    this.baseRevision,
    required this.attempts,
    required this.createdAt,
    this.nextAttemptAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['document_id'] = Variable<String>(documentId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation_type'] = Variable<String>(operationType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['library_id'] = Variable<String>(libraryId);
    map['installation_id'] = Variable<String>(installationId);
    map['client_sequence'] = Variable<int>(clientSequence);
    map['client_counter'] = Variable<int>(clientCounter);
    if (!nullToAbsent || baseRevision != null) {
      map['base_revision'] = Variable<int>(baseRevision);
    }
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      operationId: Value(operationId),
      documentId: Value(documentId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      payloadJson: Value(payloadJson),
      libraryId: Value(libraryId),
      installationId: Value(installationId),
      clientSequence: Value(clientSequence),
      clientCounter: Value(clientCounter),
      baseRevision: baseRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(baseRevision),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      operationId: serializer.fromJson<String>(json['operationId']),
      documentId: serializer.fromJson<String>(json['documentId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      libraryId: serializer.fromJson<String>(json['libraryId']),
      installationId: serializer.fromJson<String>(json['installationId']),
      clientSequence: serializer.fromJson<int>(json['clientSequence']),
      clientCounter: serializer.fromJson<int>(json['clientCounter']),
      baseRevision: serializer.fromJson<int?>(json['baseRevision']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'documentId': serializer.toJson<String>(documentId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(operationType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'libraryId': serializer.toJson<String>(libraryId),
      'installationId': serializer.toJson<String>(installationId),
      'clientSequence': serializer.toJson<int>(clientSequence),
      'clientCounter': serializer.toJson<int>(clientCounter),
      'baseRevision': serializer.toJson<int?>(baseRevision),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxData copyWith({
    String? operationId,
    String? documentId,
    String? entityType,
    String? entityId,
    String? operationType,
    String? payloadJson,
    String? libraryId,
    String? installationId,
    int? clientSequence,
    int? clientCounter,
    Value<int?> baseRevision = const Value.absent(),
    int? attempts,
    DateTime? createdAt,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncOutboxData(
    operationId: operationId ?? this.operationId,
    documentId: documentId ?? this.documentId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operationType: operationType ?? this.operationType,
    payloadJson: payloadJson ?? this.payloadJson,
    libraryId: libraryId ?? this.libraryId,
    installationId: installationId ?? this.installationId,
    clientSequence: clientSequence ?? this.clientSequence,
    clientCounter: clientCounter ?? this.clientCounter,
    baseRevision: baseRevision.present ? baseRevision.value : this.baseRevision,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      clientSequence: data.clientSequence.present
          ? data.clientSequence.value
          : this.clientSequence,
      clientCounter: data.clientCounter.present
          ? data.clientCounter.value
          : this.clientCounter,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('operationId: $operationId, ')
          ..write('documentId: $documentId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('libraryId: $libraryId, ')
          ..write('installationId: $installationId, ')
          ..write('clientSequence: $clientSequence, ')
          ..write('clientCounter: $clientCounter, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    documentId,
    entityType,
    entityId,
    operationType,
    payloadJson,
    libraryId,
    installationId,
    clientSequence,
    clientCounter,
    baseRevision,
    attempts,
    createdAt,
    nextAttemptAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.operationId == this.operationId &&
          other.documentId == this.documentId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.payloadJson == this.payloadJson &&
          other.libraryId == this.libraryId &&
          other.installationId == this.installationId &&
          other.clientSequence == this.clientSequence &&
          other.clientCounter == this.clientCounter &&
          other.baseRevision == this.baseRevision &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> operationId;
  final Value<String> documentId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operationType;
  final Value<String> payloadJson;
  final Value<String> libraryId;
  final Value<String> installationId;
  final Value<int> clientSequence;
  final Value<int> clientCounter;
  final Value<int?> baseRevision;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.operationId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.installationId = const Value.absent(),
    this.clientSequence = const Value.absent(),
    this.clientCounter = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String operationId,
    required String documentId,
    required String entityType,
    required String entityId,
    required String operationType,
    required String payloadJson,
    this.libraryId = const Value.absent(),
    this.installationId = const Value.absent(),
    this.clientSequence = const Value.absent(),
    this.clientCounter = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.attempts = const Value.absent(),
    required DateTime createdAt,
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       documentId = Value(documentId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operationType = Value(operationType),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? operationId,
    Expression<String>? documentId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? payloadJson,
    Expression<String>? libraryId,
    Expression<String>? installationId,
    Expression<int>? clientSequence,
    Expression<int>? clientCounter,
    Expression<int>? baseRevision,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (documentId != null) 'document_id': documentId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (libraryId != null) 'library_id': libraryId,
      if (installationId != null) 'installation_id': installationId,
      if (clientSequence != null) 'client_sequence': clientSequence,
      if (clientCounter != null) 'client_counter': clientCounter,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? operationId,
    Value<String>? documentId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operationType,
    Value<String>? payloadJson,
    Value<String>? libraryId,
    Value<String>? installationId,
    Value<int>? clientSequence,
    Value<int>? clientCounter,
    Value<int?>? baseRevision,
    Value<int>? attempts,
    Value<DateTime>? createdAt,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      operationId: operationId ?? this.operationId,
      documentId: documentId ?? this.documentId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payloadJson: payloadJson ?? this.payloadJson,
      libraryId: libraryId ?? this.libraryId,
      installationId: installationId ?? this.installationId,
      clientSequence: clientSequence ?? this.clientSequence,
      clientCounter: clientCounter ?? this.clientCounter,
      baseRevision: baseRevision ?? this.baseRevision,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (clientSequence.present) {
      map['client_sequence'] = Variable<int>(clientSequence.value);
    }
    if (clientCounter.present) {
      map['client_counter'] = Variable<int>(clientCounter.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('operationId: $operationId, ')
          ..write('documentId: $documentId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('libraryId: $libraryId, ')
          ..write('installationId: $installationId, ')
          ..write('clientSequence: $clientSequence, ')
          ..write('clientCounter: $clientCounter, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localJsonMeta = const VerificationMeta(
    'localJson',
  );
  @override
  late final GeneratedColumn<String> localJson = GeneratedColumn<String>(
    'local_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteJsonMeta = const VerificationMeta(
    'remoteJson',
  );
  @override
  late final GeneratedColumn<String> remoteJson = GeneratedColumn<String>(
    'remote_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    entityType,
    entityId,
    localJson,
    remoteJson,
    detectedAt,
    resolvedAt,
    resolution,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('local_json')) {
      context.handle(
        _localJsonMeta,
        localJson.isAcceptableOrUnknown(data['local_json']!, _localJsonMeta),
      );
    }
    if (data.containsKey('remote_json')) {
      context.handle(
        _remoteJsonMeta,
        remoteJson.isAcceptableOrUnknown(data['remote_json']!, _remoteJsonMeta),
      );
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      localJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_json'],
      ),
      remoteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_json'],
      ),
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String id;
  final String documentId;
  final String entityType;
  final String entityId;
  final String? localJson;
  final String? remoteJson;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? resolution;
  const SyncConflict({
    required this.id,
    required this.documentId,
    required this.entityType,
    required this.entityId,
    this.localJson,
    this.remoteJson,
    required this.detectedAt,
    this.resolvedAt,
    this.resolution,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || localJson != null) {
      map['local_json'] = Variable<String>(localJson);
    }
    if (!nullToAbsent || remoteJson != null) {
      map['remote_json'] = Variable<String>(remoteJson);
    }
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      localJson: localJson == null && nullToAbsent
          ? const Value.absent()
          : Value(localJson),
      remoteJson: remoteJson == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteJson),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      localJson: serializer.fromJson<String?>(json['localJson']),
      remoteJson: serializer.fromJson<String?>(json['remoteJson']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolution: serializer.fromJson<String?>(json['resolution']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'localJson': serializer.toJson<String?>(localJson),
      'remoteJson': serializer.toJson<String?>(remoteJson),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolution': serializer.toJson<String?>(resolution),
    };
  }

  SyncConflict copyWith({
    String? id,
    String? documentId,
    String? entityType,
    String? entityId,
    Value<String?> localJson = const Value.absent(),
    Value<String?> remoteJson = const Value.absent(),
    DateTime? detectedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<String?> resolution = const Value.absent(),
  }) => SyncConflict(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localJson: localJson.present ? localJson.value : this.localJson,
    remoteJson: remoteJson.present ? remoteJson.value : this.remoteJson,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolution: resolution.present ? resolution.value : this.resolution,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      localJson: data.localJson.present ? data.localJson.value : this.localJson,
      remoteJson: data.remoteJson.present
          ? data.remoteJson.value
          : this.remoteJson,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    entityType,
    entityId,
    localJson,
    remoteJson,
    detectedAt,
    resolvedAt,
    resolution,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.localJson == this.localJson &&
          other.remoteJson == this.remoteJson &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.resolution == this.resolution);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> localJson;
  final Value<String?> remoteJson;
  final Value<DateTime> detectedAt;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolution;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.localJson = const Value.absent(),
    this.remoteJson = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String documentId,
    required String entityType,
    required String entityId,
    this.localJson = const Value.absent(),
    this.remoteJson = const Value.absent(),
    required DateTime detectedAt,
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       detectedAt = Value(detectedAt);
  static Insertable<SyncConflict> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? localJson,
    Expression<String>? remoteJson,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolution,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (localJson != null) 'local_json': localJson,
      if (remoteJson != null) 'remote_json': remoteJson,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolution != null) 'resolution': resolution,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String?>? localJson,
    Value<String?>? remoteJson,
    Value<DateTime>? detectedAt,
    Value<DateTime?>? resolvedAt,
    Value<String?>? resolution,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localJson: localJson ?? this.localJson,
      remoteJson: remoteJson ?? this.remoteJson,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (localJson.present) {
      map['local_json'] = Variable<String>(localJson.value);
    }
    if (remoteJson.present) {
      map['remote_json'] = Variable<String>(remoteJson.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncTombstonesTable extends SyncTombstones
    with TableInfo<$SyncTombstonesTable, SyncTombstone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncTombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _propagatedAtMeta = const VerificationMeta(
    'propagatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> propagatedAt = GeneratedColumn<DateTime>(
    'propagated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purgeEligibleAtMeta = const VerificationMeta(
    'purgeEligibleAt',
  );
  @override
  late final GeneratedColumn<DateTime> purgeEligibleAt =
      GeneratedColumn<DateTime>(
        'purge_eligible_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    deletedAt,
    propagatedAt,
    purgeEligibleAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncTombstone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    if (data.containsKey('propagated_at')) {
      context.handle(
        _propagatedAtMeta,
        propagatedAt.isAcceptableOrUnknown(
          data['propagated_at']!,
          _propagatedAtMeta,
        ),
      );
    }
    if (data.containsKey('purge_eligible_at')) {
      context.handle(
        _purgeEligibleAtMeta,
        purgeEligibleAt.isAcceptableOrUnknown(
          data['purge_eligible_at']!,
          _purgeEligibleAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purgeEligibleAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  SyncTombstone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncTombstone(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
      propagatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}propagated_at'],
      ),
      purgeEligibleAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purge_eligible_at'],
      )!,
    );
  }

  @override
  $SyncTombstonesTable createAlias(String alias) {
    return $SyncTombstonesTable(attachedDatabase, alias);
  }
}

class SyncTombstone extends DataClass implements Insertable<SyncTombstone> {
  final String entityType;
  final String entityId;
  final DateTime deletedAt;
  final DateTime? propagatedAt;
  final DateTime purgeEligibleAt;
  const SyncTombstone({
    required this.entityType,
    required this.entityId,
    required this.deletedAt,
    this.propagatedAt,
    required this.purgeEligibleAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    if (!nullToAbsent || propagatedAt != null) {
      map['propagated_at'] = Variable<DateTime>(propagatedAt);
    }
    map['purge_eligible_at'] = Variable<DateTime>(purgeEligibleAt);
    return map;
  }

  SyncTombstonesCompanion toCompanion(bool nullToAbsent) {
    return SyncTombstonesCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      deletedAt: Value(deletedAt),
      propagatedAt: propagatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(propagatedAt),
      purgeEligibleAt: Value(purgeEligibleAt),
    );
  }

  factory SyncTombstone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncTombstone(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
      propagatedAt: serializer.fromJson<DateTime?>(json['propagatedAt']),
      purgeEligibleAt: serializer.fromJson<DateTime>(json['purgeEligibleAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
      'propagatedAt': serializer.toJson<DateTime?>(propagatedAt),
      'purgeEligibleAt': serializer.toJson<DateTime>(purgeEligibleAt),
    };
  }

  SyncTombstone copyWith({
    String? entityType,
    String? entityId,
    DateTime? deletedAt,
    Value<DateTime?> propagatedAt = const Value.absent(),
    DateTime? purgeEligibleAt,
  }) => SyncTombstone(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    deletedAt: deletedAt ?? this.deletedAt,
    propagatedAt: propagatedAt.present ? propagatedAt.value : this.propagatedAt,
    purgeEligibleAt: purgeEligibleAt ?? this.purgeEligibleAt,
  );
  SyncTombstone copyWithCompanion(SyncTombstonesCompanion data) {
    return SyncTombstone(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      propagatedAt: data.propagatedAt.present
          ? data.propagatedAt.value
          : this.propagatedAt,
      purgeEligibleAt: data.purgeEligibleAt.present
          ? data.purgeEligibleAt.value
          : this.purgeEligibleAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstone(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('propagatedAt: $propagatedAt, ')
          ..write('purgeEligibleAt: $purgeEligibleAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityType,
    entityId,
    deletedAt,
    propagatedAt,
    purgeEligibleAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncTombstone &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.deletedAt == this.deletedAt &&
          other.propagatedAt == this.propagatedAt &&
          other.purgeEligibleAt == this.purgeEligibleAt);
}

class SyncTombstonesCompanion extends UpdateCompanion<SyncTombstone> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<DateTime> deletedAt;
  final Value<DateTime?> propagatedAt;
  final Value<DateTime> purgeEligibleAt;
  final Value<int> rowid;
  const SyncTombstonesCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.propagatedAt = const Value.absent(),
    this.purgeEligibleAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncTombstonesCompanion.insert({
    required String entityType,
    required String entityId,
    required DateTime deletedAt,
    this.propagatedAt = const Value.absent(),
    required DateTime purgeEligibleAt,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       deletedAt = Value(deletedAt),
       purgeEligibleAt = Value(purgeEligibleAt);
  static Insertable<SyncTombstone> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? propagatedAt,
    Expression<DateTime>? purgeEligibleAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (propagatedAt != null) 'propagated_at': propagatedAt,
      if (purgeEligibleAt != null) 'purge_eligible_at': purgeEligibleAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncTombstonesCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<DateTime>? deletedAt,
    Value<DateTime?>? propagatedAt,
    Value<DateTime>? purgeEligibleAt,
    Value<int>? rowid,
  }) {
    return SyncTombstonesCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      deletedAt: deletedAt ?? this.deletedAt,
      propagatedAt: propagatedAt ?? this.propagatedAt,
      purgeEligibleAt: purgeEligibleAt ?? this.purgeEligibleAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (propagatedAt.present) {
      map['propagated_at'] = Variable<DateTime>(propagatedAt.value);
    }
    if (purgeEligibleAt.present) {
      map['purge_eligible_at'] = Variable<DateTime>(purgeEligibleAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstonesCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('propagatedAt: $propagatedAt, ')
          ..write('purgeEligibleAt: $purgeEligibleAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncEntityStatesTable extends SyncEntityStates
    with TableInfo<$SyncEntityStatesTable, SyncEntityState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEntityStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientCounterMeta = const VerificationMeta(
    'clientCounter',
  );
  @override
  late final GeneratedColumn<int> clientCounter = GeneratedColumn<int>(
    'client_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _winningDeviceIdMeta = const VerificationMeta(
    'winningDeviceId',
  );
  @override
  late final GeneratedColumn<String> winningDeviceId = GeneratedColumn<String>(
    'winning_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remotelyDeletedMeta = const VerificationMeta(
    'remotelyDeleted',
  );
  @override
  late final GeneratedColumn<bool> remotelyDeleted = GeneratedColumn<bool>(
    'remotely_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remotely_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    clientCounter,
    serverRevision,
    winningDeviceId,
    remotelyDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_entity_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncEntityState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('client_counter')) {
      context.handle(
        _clientCounterMeta,
        clientCounter.isAcceptableOrUnknown(
          data['client_counter']!,
          _clientCounterMeta,
        ),
      );
    }
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
      );
    }
    if (data.containsKey('winning_device_id')) {
      context.handle(
        _winningDeviceIdMeta,
        winningDeviceId.isAcceptableOrUnknown(
          data['winning_device_id']!,
          _winningDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('remotely_deleted')) {
      context.handle(
        _remotelyDeletedMeta,
        remotelyDeleted.isAcceptableOrUnknown(
          data['remotely_deleted']!,
          _remotelyDeletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  SyncEntityState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEntityState(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      clientCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_counter'],
      )!,
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
      )!,
      winningDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winning_device_id'],
      ),
      remotelyDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remotely_deleted'],
      )!,
    );
  }

  @override
  $SyncEntityStatesTable createAlias(String alias) {
    return $SyncEntityStatesTable(attachedDatabase, alias);
  }
}

class SyncEntityState extends DataClass implements Insertable<SyncEntityState> {
  final String entityType;
  final String entityId;
  final int clientCounter;
  final int serverRevision;
  final String? winningDeviceId;
  final bool remotelyDeleted;
  const SyncEntityState({
    required this.entityType,
    required this.entityId,
    required this.clientCounter,
    required this.serverRevision,
    this.winningDeviceId,
    required this.remotelyDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['client_counter'] = Variable<int>(clientCounter);
    map['server_revision'] = Variable<int>(serverRevision);
    if (!nullToAbsent || winningDeviceId != null) {
      map['winning_device_id'] = Variable<String>(winningDeviceId);
    }
    map['remotely_deleted'] = Variable<bool>(remotelyDeleted);
    return map;
  }

  SyncEntityStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncEntityStatesCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      clientCounter: Value(clientCounter),
      serverRevision: Value(serverRevision),
      winningDeviceId: winningDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(winningDeviceId),
      remotelyDeleted: Value(remotelyDeleted),
    );
  }

  factory SyncEntityState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEntityState(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      clientCounter: serializer.fromJson<int>(json['clientCounter']),
      serverRevision: serializer.fromJson<int>(json['serverRevision']),
      winningDeviceId: serializer.fromJson<String?>(json['winningDeviceId']),
      remotelyDeleted: serializer.fromJson<bool>(json['remotelyDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'clientCounter': serializer.toJson<int>(clientCounter),
      'serverRevision': serializer.toJson<int>(serverRevision),
      'winningDeviceId': serializer.toJson<String?>(winningDeviceId),
      'remotelyDeleted': serializer.toJson<bool>(remotelyDeleted),
    };
  }

  SyncEntityState copyWith({
    String? entityType,
    String? entityId,
    int? clientCounter,
    int? serverRevision,
    Value<String?> winningDeviceId = const Value.absent(),
    bool? remotelyDeleted,
  }) => SyncEntityState(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    clientCounter: clientCounter ?? this.clientCounter,
    serverRevision: serverRevision ?? this.serverRevision,
    winningDeviceId: winningDeviceId.present
        ? winningDeviceId.value
        : this.winningDeviceId,
    remotelyDeleted: remotelyDeleted ?? this.remotelyDeleted,
  );
  SyncEntityState copyWithCompanion(SyncEntityStatesCompanion data) {
    return SyncEntityState(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      clientCounter: data.clientCounter.present
          ? data.clientCounter.value
          : this.clientCounter,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      winningDeviceId: data.winningDeviceId.present
          ? data.winningDeviceId.value
          : this.winningDeviceId,
      remotelyDeleted: data.remotelyDeleted.present
          ? data.remotelyDeleted.value
          : this.remotelyDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityState(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('clientCounter: $clientCounter, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('winningDeviceId: $winningDeviceId, ')
          ..write('remotelyDeleted: $remotelyDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityType,
    entityId,
    clientCounter,
    serverRevision,
    winningDeviceId,
    remotelyDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEntityState &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.clientCounter == this.clientCounter &&
          other.serverRevision == this.serverRevision &&
          other.winningDeviceId == this.winningDeviceId &&
          other.remotelyDeleted == this.remotelyDeleted);
}

class SyncEntityStatesCompanion extends UpdateCompanion<SyncEntityState> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<int> clientCounter;
  final Value<int> serverRevision;
  final Value<String?> winningDeviceId;
  final Value<bool> remotelyDeleted;
  final Value<int> rowid;
  const SyncEntityStatesCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.clientCounter = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.winningDeviceId = const Value.absent(),
    this.remotelyDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncEntityStatesCompanion.insert({
    required String entityType,
    required String entityId,
    this.clientCounter = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.winningDeviceId = const Value.absent(),
    this.remotelyDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId);
  static Insertable<SyncEntityState> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? clientCounter,
    Expression<int>? serverRevision,
    Expression<String>? winningDeviceId,
    Expression<bool>? remotelyDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (clientCounter != null) 'client_counter': clientCounter,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (winningDeviceId != null) 'winning_device_id': winningDeviceId,
      if (remotelyDeleted != null) 'remotely_deleted': remotelyDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncEntityStatesCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<int>? clientCounter,
    Value<int>? serverRevision,
    Value<String?>? winningDeviceId,
    Value<bool>? remotelyDeleted,
    Value<int>? rowid,
  }) {
    return SyncEntityStatesCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      clientCounter: clientCounter ?? this.clientCounter,
      serverRevision: serverRevision ?? this.serverRevision,
      winningDeviceId: winningDeviceId ?? this.winningDeviceId,
      remotelyDeleted: remotelyDeleted ?? this.remotelyDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (clientCounter.present) {
      map['client_counter'] = Variable<int>(clientCounter.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (winningDeviceId.present) {
      map['winning_device_id'] = Variable<String>(winningDeviceId.value);
    }
    if (remotelyDeleted.present) {
      map['remotely_deleted'] = Variable<bool>(remotelyDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityStatesCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('clientCounter: $clientCounter, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('winningDeviceId: $winningDeviceId, ')
          ..write('remotelyDeleted: $remotelyDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LegacyIdMapsTable extends LegacyIdMaps
    with TableInfo<$LegacyIdMapsTable, LegacyIdMap> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LegacyIdMapsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRecordIdMeta = const VerificationMeta(
    'sourceRecordId',
  );
  @override
  late final GeneratedColumn<String> sourceRecordId = GeneratedColumn<String>(
    'source_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legacyIdMeta = const VerificationMeta(
    'legacyId',
  );
  @override
  late final GeneratedColumn<String> legacyId = GeneratedColumn<String>(
    'legacy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _v1UuidMeta = const VerificationMeta('v1Uuid');
  @override
  late final GeneratedColumn<String> v1Uuid = GeneratedColumn<String>(
    'v1_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _jsonPathMeta = const VerificationMeta(
    'jsonPath',
  );
  @override
  late final GeneratedColumn<String> jsonPath = GeneratedColumn<String>(
    'json_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceKind,
    sourceRecordId,
    entityType,
    legacyId,
    v1Uuid,
    jsonPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'legacy_id_maps';
  @override
  VerificationContext validateIntegrity(
    Insertable<LegacyIdMap> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKindMeta);
    }
    if (data.containsKey('source_record_id')) {
      context.handle(
        _sourceRecordIdMeta,
        sourceRecordId.isAcceptableOrUnknown(
          data['source_record_id']!,
          _sourceRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('legacy_id')) {
      context.handle(
        _legacyIdMeta,
        legacyId.isAcceptableOrUnknown(data['legacy_id']!, _legacyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_legacyIdMeta);
    }
    if (data.containsKey('v1_uuid')) {
      context.handle(
        _v1UuidMeta,
        v1Uuid.isAcceptableOrUnknown(data['v1_uuid']!, _v1UuidMeta),
      );
    } else if (isInserting) {
      context.missing(_v1UuidMeta);
    }
    if (data.containsKey('json_path')) {
      context.handle(
        _jsonPathMeta,
        jsonPath.isAcceptableOrUnknown(data['json_path']!, _jsonPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    sourceKind,
    sourceRecordId,
    entityType,
    legacyId,
  };
  @override
  LegacyIdMap map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LegacyIdMap(
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
      )!,
      sourceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_record_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      legacyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_id'],
      )!,
      v1Uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}v1_uuid'],
      )!,
      jsonPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_path'],
      ),
    );
  }

  @override
  $LegacyIdMapsTable createAlias(String alias) {
    return $LegacyIdMapsTable(attachedDatabase, alias);
  }
}

class LegacyIdMap extends DataClass implements Insertable<LegacyIdMap> {
  final String sourceKind;
  final String sourceRecordId;
  final String entityType;
  final String legacyId;
  final String v1Uuid;
  final String? jsonPath;
  const LegacyIdMap({
    required this.sourceKind,
    required this.sourceRecordId,
    required this.entityType,
    required this.legacyId,
    required this.v1Uuid,
    this.jsonPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_kind'] = Variable<String>(sourceKind);
    map['source_record_id'] = Variable<String>(sourceRecordId);
    map['entity_type'] = Variable<String>(entityType);
    map['legacy_id'] = Variable<String>(legacyId);
    map['v1_uuid'] = Variable<String>(v1Uuid);
    if (!nullToAbsent || jsonPath != null) {
      map['json_path'] = Variable<String>(jsonPath);
    }
    return map;
  }

  LegacyIdMapsCompanion toCompanion(bool nullToAbsent) {
    return LegacyIdMapsCompanion(
      sourceKind: Value(sourceKind),
      sourceRecordId: Value(sourceRecordId),
      entityType: Value(entityType),
      legacyId: Value(legacyId),
      v1Uuid: Value(v1Uuid),
      jsonPath: jsonPath == null && nullToAbsent
          ? const Value.absent()
          : Value(jsonPath),
    );
  }

  factory LegacyIdMap.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LegacyIdMap(
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      sourceRecordId: serializer.fromJson<String>(json['sourceRecordId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      legacyId: serializer.fromJson<String>(json['legacyId']),
      v1Uuid: serializer.fromJson<String>(json['v1Uuid']),
      jsonPath: serializer.fromJson<String?>(json['jsonPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceKind': serializer.toJson<String>(sourceKind),
      'sourceRecordId': serializer.toJson<String>(sourceRecordId),
      'entityType': serializer.toJson<String>(entityType),
      'legacyId': serializer.toJson<String>(legacyId),
      'v1Uuid': serializer.toJson<String>(v1Uuid),
      'jsonPath': serializer.toJson<String?>(jsonPath),
    };
  }

  LegacyIdMap copyWith({
    String? sourceKind,
    String? sourceRecordId,
    String? entityType,
    String? legacyId,
    String? v1Uuid,
    Value<String?> jsonPath = const Value.absent(),
  }) => LegacyIdMap(
    sourceKind: sourceKind ?? this.sourceKind,
    sourceRecordId: sourceRecordId ?? this.sourceRecordId,
    entityType: entityType ?? this.entityType,
    legacyId: legacyId ?? this.legacyId,
    v1Uuid: v1Uuid ?? this.v1Uuid,
    jsonPath: jsonPath.present ? jsonPath.value : this.jsonPath,
  );
  LegacyIdMap copyWithCompanion(LegacyIdMapsCompanion data) {
    return LegacyIdMap(
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      sourceRecordId: data.sourceRecordId.present
          ? data.sourceRecordId.value
          : this.sourceRecordId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      legacyId: data.legacyId.present ? data.legacyId.value : this.legacyId,
      v1Uuid: data.v1Uuid.present ? data.v1Uuid.value : this.v1Uuid,
      jsonPath: data.jsonPath.present ? data.jsonPath.value : this.jsonPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LegacyIdMap(')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('entityType: $entityType, ')
          ..write('legacyId: $legacyId, ')
          ..write('v1Uuid: $v1Uuid, ')
          ..write('jsonPath: $jsonPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceKind,
    sourceRecordId,
    entityType,
    legacyId,
    v1Uuid,
    jsonPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LegacyIdMap &&
          other.sourceKind == this.sourceKind &&
          other.sourceRecordId == this.sourceRecordId &&
          other.entityType == this.entityType &&
          other.legacyId == this.legacyId &&
          other.v1Uuid == this.v1Uuid &&
          other.jsonPath == this.jsonPath);
}

class LegacyIdMapsCompanion extends UpdateCompanion<LegacyIdMap> {
  final Value<String> sourceKind;
  final Value<String> sourceRecordId;
  final Value<String> entityType;
  final Value<String> legacyId;
  final Value<String> v1Uuid;
  final Value<String?> jsonPath;
  final Value<int> rowid;
  const LegacyIdMapsCompanion({
    this.sourceKind = const Value.absent(),
    this.sourceRecordId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.legacyId = const Value.absent(),
    this.v1Uuid = const Value.absent(),
    this.jsonPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LegacyIdMapsCompanion.insert({
    required String sourceKind,
    this.sourceRecordId = const Value.absent(),
    required String entityType,
    required String legacyId,
    required String v1Uuid,
    this.jsonPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceKind = Value(sourceKind),
       entityType = Value(entityType),
       legacyId = Value(legacyId),
       v1Uuid = Value(v1Uuid);
  static Insertable<LegacyIdMap> custom({
    Expression<String>? sourceKind,
    Expression<String>? sourceRecordId,
    Expression<String>? entityType,
    Expression<String>? legacyId,
    Expression<String>? v1Uuid,
    Expression<String>? jsonPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceKind != null) 'source_kind': sourceKind,
      if (sourceRecordId != null) 'source_record_id': sourceRecordId,
      if (entityType != null) 'entity_type': entityType,
      if (legacyId != null) 'legacy_id': legacyId,
      if (v1Uuid != null) 'v1_uuid': v1Uuid,
      if (jsonPath != null) 'json_path': jsonPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LegacyIdMapsCompanion copyWith({
    Value<String>? sourceKind,
    Value<String>? sourceRecordId,
    Value<String>? entityType,
    Value<String>? legacyId,
    Value<String>? v1Uuid,
    Value<String?>? jsonPath,
    Value<int>? rowid,
  }) {
    return LegacyIdMapsCompanion(
      sourceKind: sourceKind ?? this.sourceKind,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      entityType: entityType ?? this.entityType,
      legacyId: legacyId ?? this.legacyId,
      v1Uuid: v1Uuid ?? this.v1Uuid,
      jsonPath: jsonPath ?? this.jsonPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (sourceRecordId.present) {
      map['source_record_id'] = Variable<String>(sourceRecordId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (legacyId.present) {
      map['legacy_id'] = Variable<String>(legacyId.value);
    }
    if (v1Uuid.present) {
      map['v1_uuid'] = Variable<String>(v1Uuid.value);
    }
    if (jsonPath.present) {
      map['json_path'] = Variable<String>(jsonPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LegacyIdMapsCompanion(')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('entityType: $entityType, ')
          ..write('legacyId: $legacyId, ')
          ..write('v1Uuid: $v1Uuid, ')
          ..write('jsonPath: $jsonPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MigrationHistoryTable extends MigrationHistory
    with TableInfo<$MigrationHistoryTable, MigrationHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MigrationHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceSha256Meta = const VerificationMeta(
    'sourceSha256',
  );
  @override
  late final GeneratedColumn<String> sourceSha256 = GeneratedColumn<String>(
    'source_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceSchemaMeta = const VerificationMeta(
    'sourceSchema',
  );
  @override
  late final GeneratedColumn<String> sourceSchema = GeneratedColumn<String>(
    'source_schema',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportJsonMeta = const VerificationMeta(
    'reportJson',
  );
  @override
  late final GeneratedColumn<String> reportJson = GeneratedColumn<String>(
    'report_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceKind,
    sourceSha256,
    sourceSchema,
    importedAt,
    reportJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'migration_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<MigrationHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKindMeta);
    }
    if (data.containsKey('source_sha256')) {
      context.handle(
        _sourceSha256Meta,
        sourceSha256.isAcceptableOrUnknown(
          data['source_sha256']!,
          _sourceSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSha256Meta);
    }
    if (data.containsKey('source_schema')) {
      context.handle(
        _sourceSchemaMeta,
        sourceSchema.isAcceptableOrUnknown(
          data['source_schema']!,
          _sourceSchemaMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('report_json')) {
      context.handle(
        _reportJsonMeta,
        reportJson.isAcceptableOrUnknown(data['report_json']!, _reportJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_reportJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceKind, sourceSha256},
  ];
  @override
  MigrationHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MigrationHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
      )!,
      sourceSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_sha256'],
      )!,
      sourceSchema: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_schema'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      reportJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_json'],
      )!,
    );
  }

  @override
  $MigrationHistoryTable createAlias(String alias) {
    return $MigrationHistoryTable(attachedDatabase, alias);
  }
}

class MigrationHistoryData extends DataClass
    implements Insertable<MigrationHistoryData> {
  final String id;
  final String sourceKind;
  final String sourceSha256;
  final String? sourceSchema;
  final DateTime importedAt;
  final String reportJson;
  const MigrationHistoryData({
    required this.id,
    required this.sourceKind,
    required this.sourceSha256,
    this.sourceSchema,
    required this.importedAt,
    required this.reportJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_kind'] = Variable<String>(sourceKind);
    map['source_sha256'] = Variable<String>(sourceSha256);
    if (!nullToAbsent || sourceSchema != null) {
      map['source_schema'] = Variable<String>(sourceSchema);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['report_json'] = Variable<String>(reportJson);
    return map;
  }

  MigrationHistoryCompanion toCompanion(bool nullToAbsent) {
    return MigrationHistoryCompanion(
      id: Value(id),
      sourceKind: Value(sourceKind),
      sourceSha256: Value(sourceSha256),
      sourceSchema: sourceSchema == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSchema),
      importedAt: Value(importedAt),
      reportJson: Value(reportJson),
    );
  }

  factory MigrationHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MigrationHistoryData(
      id: serializer.fromJson<String>(json['id']),
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      sourceSha256: serializer.fromJson<String>(json['sourceSha256']),
      sourceSchema: serializer.fromJson<String?>(json['sourceSchema']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      reportJson: serializer.fromJson<String>(json['reportJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceKind': serializer.toJson<String>(sourceKind),
      'sourceSha256': serializer.toJson<String>(sourceSha256),
      'sourceSchema': serializer.toJson<String?>(sourceSchema),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'reportJson': serializer.toJson<String>(reportJson),
    };
  }

  MigrationHistoryData copyWith({
    String? id,
    String? sourceKind,
    String? sourceSha256,
    Value<String?> sourceSchema = const Value.absent(),
    DateTime? importedAt,
    String? reportJson,
  }) => MigrationHistoryData(
    id: id ?? this.id,
    sourceKind: sourceKind ?? this.sourceKind,
    sourceSha256: sourceSha256 ?? this.sourceSha256,
    sourceSchema: sourceSchema.present ? sourceSchema.value : this.sourceSchema,
    importedAt: importedAt ?? this.importedAt,
    reportJson: reportJson ?? this.reportJson,
  );
  MigrationHistoryData copyWithCompanion(MigrationHistoryCompanion data) {
    return MigrationHistoryData(
      id: data.id.present ? data.id.value : this.id,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      sourceSha256: data.sourceSha256.present
          ? data.sourceSha256.value
          : this.sourceSha256,
      sourceSchema: data.sourceSchema.present
          ? data.sourceSchema.value
          : this.sourceSchema,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      reportJson: data.reportJson.present
          ? data.reportJson.value
          : this.reportJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MigrationHistoryData(')
          ..write('id: $id, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceSha256: $sourceSha256, ')
          ..write('sourceSchema: $sourceSchema, ')
          ..write('importedAt: $importedAt, ')
          ..write('reportJson: $reportJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceKind,
    sourceSha256,
    sourceSchema,
    importedAt,
    reportJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MigrationHistoryData &&
          other.id == this.id &&
          other.sourceKind == this.sourceKind &&
          other.sourceSha256 == this.sourceSha256 &&
          other.sourceSchema == this.sourceSchema &&
          other.importedAt == this.importedAt &&
          other.reportJson == this.reportJson);
}

class MigrationHistoryCompanion extends UpdateCompanion<MigrationHistoryData> {
  final Value<String> id;
  final Value<String> sourceKind;
  final Value<String> sourceSha256;
  final Value<String?> sourceSchema;
  final Value<DateTime> importedAt;
  final Value<String> reportJson;
  final Value<int> rowid;
  const MigrationHistoryCompanion({
    this.id = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceSha256 = const Value.absent(),
    this.sourceSchema = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.reportJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MigrationHistoryCompanion.insert({
    required String id,
    required String sourceKind,
    required String sourceSha256,
    this.sourceSchema = const Value.absent(),
    required DateTime importedAt,
    required String reportJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceKind = Value(sourceKind),
       sourceSha256 = Value(sourceSha256),
       importedAt = Value(importedAt),
       reportJson = Value(reportJson);
  static Insertable<MigrationHistoryData> custom({
    Expression<String>? id,
    Expression<String>? sourceKind,
    Expression<String>? sourceSha256,
    Expression<String>? sourceSchema,
    Expression<DateTime>? importedAt,
    Expression<String>? reportJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (sourceSha256 != null) 'source_sha256': sourceSha256,
      if (sourceSchema != null) 'source_schema': sourceSchema,
      if (importedAt != null) 'imported_at': importedAt,
      if (reportJson != null) 'report_json': reportJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MigrationHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceKind,
    Value<String>? sourceSha256,
    Value<String?>? sourceSchema,
    Value<DateTime>? importedAt,
    Value<String>? reportJson,
    Value<int>? rowid,
  }) {
    return MigrationHistoryCompanion(
      id: id ?? this.id,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceSha256: sourceSha256 ?? this.sourceSha256,
      sourceSchema: sourceSchema ?? this.sourceSchema,
      importedAt: importedAt ?? this.importedAt,
      reportJson: reportJson ?? this.reportJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (sourceSha256.present) {
      map['source_sha256'] = Variable<String>(sourceSha256.value);
    }
    if (sourceSchema.present) {
      map['source_schema'] = Variable<String>(sourceSchema.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (reportJson.present) {
      map['report_json'] = Variable<String>(reportJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MigrationHistoryCompanion(')
          ..write('id: $id, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceSha256: $sourceSha256, ')
          ..write('sourceSchema: $sourceSchema, ')
          ..write('importedAt: $importedAt, ')
          ..write('reportJson: $reportJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InstallationSettingsTable installationSettings =
      $InstallationSettingsTable(this);
  late final $LibraryOwnersTable libraryOwners = $LibraryOwnersTable(this);
  late final $LibraryCategoriesTable libraryCategories =
      $LibraryCategoriesTable(this);
  late final $LibraryItemsTable libraryItems = $LibraryItemsTable(this);
  late final $ContextsTable contexts = $ContextsTable(this);
  late final $LibraryItemContextsTable libraryItemContexts =
      $LibraryItemContextsTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $TripMembersTable tripMembers = $TripMembersTable(this);
  late final $TripCategoriesTable tripCategories = $TripCategoriesTable(this);
  late final $TripItemsTable tripItems = $TripItemsTable(this);
  late final $TripItemSourcesTable tripItemSources = $TripItemSourcesTable(
    this,
  );
  late final $TripGenerationChoicesTable tripGenerationChoices =
      $TripGenerationChoicesTable(this);
  late final $QuickListsTable quickLists = $QuickListsTable(this);
  late final $QuickListItemsTable quickListItems = $QuickListItemsTable(this);
  late final $SyncDocumentsTable syncDocuments = $SyncDocumentsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $SyncTombstonesTable syncTombstones = $SyncTombstonesTable(this);
  late final $SyncEntityStatesTable syncEntityStates = $SyncEntityStatesTable(
    this,
  );
  late final $LegacyIdMapsTable legacyIdMaps = $LegacyIdMapsTable(this);
  late final $MigrationHistoryTable migrationHistory = $MigrationHistoryTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    installationSettings,
    libraryOwners,
    libraryCategories,
    libraryItems,
    contexts,
    libraryItemContexts,
    trips,
    tripMembers,
    tripCategories,
    tripItems,
    tripItemSources,
    tripGenerationChoices,
    quickLists,
    quickListItems,
    syncDocuments,
    syncOutbox,
    syncConflicts,
    syncTombstones,
    syncEntityStates,
    legacyIdMaps,
    migrationHistory,
  ];
}

typedef $$InstallationSettingsTableCreateCompanionBuilder =
    InstallationSettingsCompanion Function({
      Value<String> id,
      required String installationId,
      Value<String?> futureUserId,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<String> libraryId,
      Value<int> nextOperationSequence,
      Value<int> pullCursor,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });
typedef $$InstallationSettingsTableUpdateCompanionBuilder =
    InstallationSettingsCompanion Function({
      Value<String> id,
      Value<String> installationId,
      Value<String?> futureUserId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<String> libraryId,
      Value<int> nextOperationSequence,
      Value<int> pullCursor,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });

class $$InstallationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $InstallationSettingsTable> {
  $$InstallationSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get futureUserId => $composableBuilder(
    column: $table.futureUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextOperationSequence => $composableBuilder(
    column: $table.nextOperationSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstallationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallationSettingsTable> {
  $$InstallationSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get futureUserId => $composableBuilder(
    column: $table.futureUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextOperationSequence => $composableBuilder(
    column: $table.nextOperationSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstallationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallationSettingsTable> {
  $$InstallationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get futureUserId => $composableBuilder(
    column: $table.futureUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get libraryId =>
      $composableBuilder(column: $table.libraryId, builder: (column) => column);

  GeneratedColumn<int> get nextOperationSequence => $composableBuilder(
    column: $table.nextOperationSequence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );
}

class $$InstallationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstallationSettingsTable,
          InstallationSetting,
          $$InstallationSettingsTableFilterComposer,
          $$InstallationSettingsTableOrderingComposer,
          $$InstallationSettingsTableAnnotationComposer,
          $$InstallationSettingsTableCreateCompanionBuilder,
          $$InstallationSettingsTableUpdateCompanionBuilder,
          (
            InstallationSetting,
            BaseReferences<
              _$AppDatabase,
              $InstallationSettingsTable,
              InstallationSetting
            >,
          ),
          InstallationSetting,
          PrefetchHooks Function()
        > {
  $$InstallationSettingsTableTableManager(
    _$AppDatabase db,
    $InstallationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallationSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InstallationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> installationId = const Value.absent(),
                Value<String?> futureUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<String> libraryId = const Value.absent(),
                Value<int> nextOperationSequence = const Value.absent(),
                Value<int> pullCursor = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallationSettingsCompanion(
                id: id,
                installationId: installationId,
                futureUserId: futureUserId,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                libraryId: libraryId,
                nextOperationSequence: nextOperationSequence,
                pullCursor: pullCursor,
                syncStatus: syncStatus,
                syncError: syncError,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String installationId,
                Value<String?> futureUserId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<String> libraryId = const Value.absent(),
                Value<int> nextOperationSequence = const Value.absent(),
                Value<int> pullCursor = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallationSettingsCompanion.insert(
                id: id,
                installationId: installationId,
                futureUserId: futureUserId,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                libraryId: libraryId,
                nextOperationSequence: nextOperationSequence,
                pullCursor: pullCursor,
                syncStatus: syncStatus,
                syncError: syncError,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstallationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstallationSettingsTable,
      InstallationSetting,
      $$InstallationSettingsTableFilterComposer,
      $$InstallationSettingsTableOrderingComposer,
      $$InstallationSettingsTableAnnotationComposer,
      $$InstallationSettingsTableCreateCompanionBuilder,
      $$InstallationSettingsTableUpdateCompanionBuilder,
      (
        InstallationSetting,
        BaseReferences<
          _$AppDatabase,
          $InstallationSettingsTable,
          InstallationSetting
        >,
      ),
      InstallationSetting,
      PrefetchHooks Function()
    >;
typedef $$LibraryOwnersTableCreateCompanionBuilder =
    LibraryOwnersCompanion Function({
      required String id,
      required String kind,
      required String syncScope,
      Value<String> generationRole,
      required String name,
      Value<String?> icon,
      Value<String?> linkedParticipantOwnerId,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LibraryOwnersTableUpdateCompanionBuilder =
    LibraryOwnersCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> syncScope,
      Value<String> generationRole,
      Value<String> name,
      Value<String?> icon,
      Value<String?> linkedParticipantOwnerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LibraryOwnersTableReferences
    extends BaseReferences<_$AppDatabase, $LibraryOwnersTable, LibraryOwner> {
  $$LibraryOwnersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LibraryCategoriesTable, List<LibraryCategory>>
  _libraryCategoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.libraryCategories,
        aliasName: 'library_owners__id__library_categories__owner_id',
      );

  $$LibraryCategoriesTableProcessedTableManager get libraryCategoriesRefs {
    final manager = $$LibraryCategoriesTableTableManager(
      $_db,
      $_db.libraryCategories,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _libraryCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LibraryOwnersTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryOwnersTable> {
  $$LibraryOwnersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncScope => $composableBuilder(
    column: $table.syncScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get generationRole => $composableBuilder(
    column: $table.generationRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedParticipantOwnerId => $composableBuilder(
    column: $table.linkedParticipantOwnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> libraryCategoriesRefs(
    Expression<bool> Function($$LibraryCategoriesTableFilterComposer f) f,
  ) {
    final $$LibraryCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryCategories,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.libraryCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryOwnersTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryOwnersTable> {
  $$LibraryOwnersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncScope => $composableBuilder(
    column: $table.syncScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generationRole => $composableBuilder(
    column: $table.generationRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedParticipantOwnerId => $composableBuilder(
    column: $table.linkedParticipantOwnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryOwnersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryOwnersTable> {
  $$LibraryOwnersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get syncScope =>
      $composableBuilder(column: $table.syncScope, builder: (column) => column);

  GeneratedColumn<String> get generationRole => $composableBuilder(
    column: $table.generationRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get linkedParticipantOwnerId => $composableBuilder(
    column: $table.linkedParticipantOwnerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> libraryCategoriesRefs<T extends Object>(
    Expression<T> Function($$LibraryCategoriesTableAnnotationComposer a) f,
  ) {
    final $$LibraryCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.libraryCategories,
          getReferencedColumn: (t) => t.ownerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibraryCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.libraryCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LibraryOwnersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryOwnersTable,
          LibraryOwner,
          $$LibraryOwnersTableFilterComposer,
          $$LibraryOwnersTableOrderingComposer,
          $$LibraryOwnersTableAnnotationComposer,
          $$LibraryOwnersTableCreateCompanionBuilder,
          $$LibraryOwnersTableUpdateCompanionBuilder,
          (LibraryOwner, $$LibraryOwnersTableReferences),
          LibraryOwner,
          PrefetchHooks Function({bool libraryCategoriesRefs})
        > {
  $$LibraryOwnersTableTableManager(_$AppDatabase db, $LibraryOwnersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryOwnersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryOwnersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryOwnersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> syncScope = const Value.absent(),
                Value<String> generationRole = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> linkedParticipantOwnerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryOwnersCompanion(
                id: id,
                kind: kind,
                syncScope: syncScope,
                generationRole: generationRole,
                name: name,
                icon: icon,
                linkedParticipantOwnerId: linkedParticipantOwnerId,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String syncScope,
                Value<String> generationRole = const Value.absent(),
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<String?> linkedParticipantOwnerId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryOwnersCompanion.insert(
                id: id,
                kind: kind,
                syncScope: syncScope,
                generationRole: generationRole,
                name: name,
                icon: icon,
                linkedParticipantOwnerId: linkedParticipantOwnerId,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LibraryOwnersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({libraryCategoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (libraryCategoriesRefs) db.libraryCategories,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (libraryCategoriesRefs)
                    await $_getPrefetchedData<
                      LibraryOwner,
                      $LibraryOwnersTable,
                      LibraryCategory
                    >(
                      currentTable: table,
                      referencedTable: $$LibraryOwnersTableReferences
                          ._libraryCategoriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LibraryOwnersTableReferences(
                            db,
                            table,
                            p0,
                          ).libraryCategoriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ownerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LibraryOwnersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryOwnersTable,
      LibraryOwner,
      $$LibraryOwnersTableFilterComposer,
      $$LibraryOwnersTableOrderingComposer,
      $$LibraryOwnersTableAnnotationComposer,
      $$LibraryOwnersTableCreateCompanionBuilder,
      $$LibraryOwnersTableUpdateCompanionBuilder,
      (LibraryOwner, $$LibraryOwnersTableReferences),
      LibraryOwner,
      PrefetchHooks Function({bool libraryCategoriesRefs})
    >;
typedef $$LibraryCategoriesTableCreateCompanionBuilder =
    LibraryCategoriesCompanion Function({
      required String id,
      required String ownerId,
      required String name,
      Value<String?> icon,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LibraryCategoriesTableUpdateCompanionBuilder =
    LibraryCategoriesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> name,
      Value<String?> icon,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LibraryCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LibraryCategoriesTable,
          LibraryCategory
        > {
  $$LibraryCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LibraryOwnersTable _ownerIdTable(_$AppDatabase db) => db.libraryOwners
      .createAlias('library_categories__owner_id__library_owners__id');

  $$LibraryOwnersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$LibraryOwnersTableTableManager(
      $_db,
      $_db.libraryOwners,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LibraryItemsTable, List<LibraryItem>>
  _libraryItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.libraryItems,
    aliasName: 'library_categories__id__library_items__category_id',
  );

  $$LibraryItemsTableProcessedTableManager get libraryItemsRefs {
    final manager = $$LibraryItemsTableTableManager(
      $_db,
      $_db.libraryItems,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_libraryItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LibraryCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryCategoriesTable> {
  $$LibraryCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryOwnersTableFilterComposer get ownerId {
    final $$LibraryOwnersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.libraryOwners,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryOwnersTableFilterComposer(
            $db: $db,
            $table: $db.libraryOwners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> libraryItemsRefs(
    Expression<bool> Function($$LibraryItemsTableFilterComposer f) f,
  ) {
    final $$LibraryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryItemsTableFilterComposer(
            $db: $db,
            $table: $db.libraryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryCategoriesTable> {
  $$LibraryCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryOwnersTableOrderingComposer get ownerId {
    final $$LibraryOwnersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.libraryOwners,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryOwnersTableOrderingComposer(
            $db: $db,
            $table: $db.libraryOwners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryCategoriesTable> {
  $$LibraryCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LibraryOwnersTableAnnotationComposer get ownerId {
    final $$LibraryOwnersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.libraryOwners,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryOwnersTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryOwners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> libraryItemsRefs<T extends Object>(
    Expression<T> Function($$LibraryItemsTableAnnotationComposer a) f,
  ) {
    final $$LibraryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryCategoriesTable,
          LibraryCategory,
          $$LibraryCategoriesTableFilterComposer,
          $$LibraryCategoriesTableOrderingComposer,
          $$LibraryCategoriesTableAnnotationComposer,
          $$LibraryCategoriesTableCreateCompanionBuilder,
          $$LibraryCategoriesTableUpdateCompanionBuilder,
          (LibraryCategory, $$LibraryCategoriesTableReferences),
          LibraryCategory,
          PrefetchHooks Function({bool ownerId, bool libraryItemsRefs})
        > {
  $$LibraryCategoriesTableTableManager(
    _$AppDatabase db,
    $LibraryCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryCategoriesCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                icon: icon,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String name,
                Value<String?> icon = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryCategoriesCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                icon: icon,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LibraryCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerId = false, libraryItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (libraryItemsRefs) db.libraryItems],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ownerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ownerId,
                                referencedTable:
                                    $$LibraryCategoriesTableReferences
                                        ._ownerIdTable(db),
                                referencedColumn:
                                    $$LibraryCategoriesTableReferences
                                        ._ownerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (libraryItemsRefs)
                    await $_getPrefetchedData<
                      LibraryCategory,
                      $LibraryCategoriesTable,
                      LibraryItem
                    >(
                      currentTable: table,
                      referencedTable: $$LibraryCategoriesTableReferences
                          ._libraryItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LibraryCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).libraryItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LibraryCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryCategoriesTable,
      LibraryCategory,
      $$LibraryCategoriesTableFilterComposer,
      $$LibraryCategoriesTableOrderingComposer,
      $$LibraryCategoriesTableAnnotationComposer,
      $$LibraryCategoriesTableCreateCompanionBuilder,
      $$LibraryCategoriesTableUpdateCompanionBuilder,
      (LibraryCategory, $$LibraryCategoriesTableReferences),
      LibraryCategory,
      PrefetchHooks Function({bool ownerId, bool libraryItemsRefs})
    >;
typedef $$LibraryItemsTableCreateCompanionBuilder =
    LibraryItemsCompanion Function({
      required String id,
      required String categoryId,
      required String name,
      Value<int> defaultQuantity,
      Value<String?> logicalSourceId,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LibraryItemsTableUpdateCompanionBuilder =
    LibraryItemsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String> name,
      Value<int> defaultQuantity,
      Value<String?> logicalSourceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LibraryItemsTableReferences
    extends BaseReferences<_$AppDatabase, $LibraryItemsTable, LibraryItem> {
  $$LibraryItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LibraryCategoriesTable _categoryIdTable(_$AppDatabase db) => db
      .libraryCategories
      .createAlias('library_items__category_id__library_categories__id');

  $$LibraryCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$LibraryCategoriesTableTableManager(
      $_db,
      $_db.libraryCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $LibraryItemContextsTable,
    List<LibraryItemContext>
  >
  _libraryItemContextsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.libraryItemContexts,
        aliasName: 'library_items__id__library_item_contexts__item_id',
      );

  $$LibraryItemContextsTableProcessedTableManager get libraryItemContextsRefs {
    final manager = $$LibraryItemContextsTableTableManager(
      $_db,
      $_db.libraryItemContexts,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _libraryItemContextsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LibraryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultQuantity => $composableBuilder(
    column: $table.defaultQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logicalSourceId => $composableBuilder(
    column: $table.logicalSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryCategoriesTableFilterComposer get categoryId {
    final $$LibraryCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.libraryCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.libraryCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> libraryItemContextsRefs(
    Expression<bool> Function($$LibraryItemContextsTableFilterComposer f) f,
  ) {
    final $$LibraryItemContextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryItemContexts,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryItemContextsTableFilterComposer(
            $db: $db,
            $table: $db.libraryItemContexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultQuantity => $composableBuilder(
    column: $table.defaultQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logicalSourceId => $composableBuilder(
    column: $table.logicalSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryCategoriesTableOrderingComposer get categoryId {
    final $$LibraryCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.libraryCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.libraryCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get defaultQuantity => $composableBuilder(
    column: $table.defaultQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logicalSourceId => $composableBuilder(
    column: $table.logicalSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LibraryCategoriesTableAnnotationComposer get categoryId {
    final $$LibraryCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.libraryCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibraryCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.libraryCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> libraryItemContextsRefs<T extends Object>(
    Expression<T> Function($$LibraryItemContextsTableAnnotationComposer a) f,
  ) {
    final $$LibraryItemContextsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.libraryItemContexts,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibraryItemContextsTableAnnotationComposer(
                $db: $db,
                $table: $db.libraryItemContexts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LibraryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryItemsTable,
          LibraryItem,
          $$LibraryItemsTableFilterComposer,
          $$LibraryItemsTableOrderingComposer,
          $$LibraryItemsTableAnnotationComposer,
          $$LibraryItemsTableCreateCompanionBuilder,
          $$LibraryItemsTableUpdateCompanionBuilder,
          (LibraryItem, $$LibraryItemsTableReferences),
          LibraryItem,
          PrefetchHooks Function({
            bool categoryId,
            bool libraryItemContextsRefs,
          })
        > {
  $$LibraryItemsTableTableManager(_$AppDatabase db, $LibraryItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> defaultQuantity = const Value.absent(),
                Value<String?> logicalSourceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryItemsCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                defaultQuantity: defaultQuantity,
                logicalSourceId: logicalSourceId,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required String name,
                Value<int> defaultQuantity = const Value.absent(),
                Value<String?> logicalSourceId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryItemsCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                defaultQuantity: defaultQuantity,
                logicalSourceId: logicalSourceId,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LibraryItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, libraryItemContextsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (libraryItemContextsRefs) db.libraryItemContexts,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$LibraryItemsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$LibraryItemsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (libraryItemContextsRefs)
                        await $_getPrefetchedData<
                          LibraryItem,
                          $LibraryItemsTable,
                          LibraryItemContext
                        >(
                          currentTable: table,
                          referencedTable: $$LibraryItemsTableReferences
                              ._libraryItemContextsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LibraryItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).libraryItemContextsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LibraryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryItemsTable,
      LibraryItem,
      $$LibraryItemsTableFilterComposer,
      $$LibraryItemsTableOrderingComposer,
      $$LibraryItemsTableAnnotationComposer,
      $$LibraryItemsTableCreateCompanionBuilder,
      $$LibraryItemsTableUpdateCompanionBuilder,
      (LibraryItem, $$LibraryItemsTableReferences),
      LibraryItem,
      PrefetchHooks Function({bool categoryId, bool libraryItemContextsRefs})
    >;
typedef $$ContextsTableCreateCompanionBuilder =
    ContextsCompanion Function({
      required String id,
      required String name,
      required String syncScope,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ContextsTableUpdateCompanionBuilder =
    ContextsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> syncScope,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ContextsTableReferences
    extends BaseReferences<_$AppDatabase, $ContextsTable, Context> {
  $$ContextsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $LibraryItemContextsTable,
    List<LibraryItemContext>
  >
  _libraryItemContextsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.libraryItemContexts,
        aliasName: 'contexts__id__library_item_contexts__context_id',
      );

  $$LibraryItemContextsTableProcessedTableManager get libraryItemContextsRefs {
    final manager = $$LibraryItemContextsTableTableManager(
      $_db,
      $_db.libraryItemContexts,
    ).filter((f) => f.contextId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _libraryItemContextsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContextsTableFilterComposer
    extends Composer<_$AppDatabase, $ContextsTable> {
  $$ContextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncScope => $composableBuilder(
    column: $table.syncScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> libraryItemContextsRefs(
    Expression<bool> Function($$LibraryItemContextsTableFilterComposer f) f,
  ) {
    final $$LibraryItemContextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryItemContexts,
      getReferencedColumn: (t) => t.contextId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryItemContextsTableFilterComposer(
            $db: $db,
            $table: $db.libraryItemContexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContextsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContextsTable> {
  $$ContextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncScope => $composableBuilder(
    column: $table.syncScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContextsTable> {
  $$ContextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get syncScope =>
      $composableBuilder(column: $table.syncScope, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> libraryItemContextsRefs<T extends Object>(
    Expression<T> Function($$LibraryItemContextsTableAnnotationComposer a) f,
  ) {
    final $$LibraryItemContextsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.libraryItemContexts,
          getReferencedColumn: (t) => t.contextId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibraryItemContextsTableAnnotationComposer(
                $db: $db,
                $table: $db.libraryItemContexts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContextsTable,
          Context,
          $$ContextsTableFilterComposer,
          $$ContextsTableOrderingComposer,
          $$ContextsTableAnnotationComposer,
          $$ContextsTableCreateCompanionBuilder,
          $$ContextsTableUpdateCompanionBuilder,
          (Context, $$ContextsTableReferences),
          Context,
          PrefetchHooks Function({bool libraryItemContextsRefs})
        > {
  $$ContextsTableTableManager(_$AppDatabase db, $ContextsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> syncScope = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContextsCompanion(
                id: id,
                name: name,
                syncScope: syncScope,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String syncScope,
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContextsCompanion.insert(
                id: id,
                name: name,
                syncScope: syncScope,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContextsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({libraryItemContextsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (libraryItemContextsRefs) db.libraryItemContexts,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (libraryItemContextsRefs)
                    await $_getPrefetchedData<
                      Context,
                      $ContextsTable,
                      LibraryItemContext
                    >(
                      currentTable: table,
                      referencedTable: $$ContextsTableReferences
                          ._libraryItemContextsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ContextsTableReferences(
                        db,
                        table,
                        p0,
                      ).libraryItemContextsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.contextId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ContextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContextsTable,
      Context,
      $$ContextsTableFilterComposer,
      $$ContextsTableOrderingComposer,
      $$ContextsTableAnnotationComposer,
      $$ContextsTableCreateCompanionBuilder,
      $$ContextsTableUpdateCompanionBuilder,
      (Context, $$ContextsTableReferences),
      Context,
      PrefetchHooks Function({bool libraryItemContextsRefs})
    >;
typedef $$LibraryItemContextsTableCreateCompanionBuilder =
    LibraryItemContextsCompanion Function({
      required String itemId,
      required String contextId,
      Value<String?> associationId,
      Value<String> syncScope,
      required DateTime createdAt,
      Value<DateTime?> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LibraryItemContextsTableUpdateCompanionBuilder =
    LibraryItemContextsCompanion Function({
      Value<String> itemId,
      Value<String> contextId,
      Value<String?> associationId,
      Value<String> syncScope,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LibraryItemContextsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LibraryItemContextsTable,
          LibraryItemContext
        > {
  $$LibraryItemContextsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LibraryItemsTable _itemIdTable(_$AppDatabase db) => db.libraryItems
      .createAlias('library_item_contexts__item_id__library_items__id');

  $$LibraryItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$LibraryItemsTableTableManager(
      $_db,
      $_db.libraryItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContextsTable _contextIdTable(_$AppDatabase db) => db.contexts
      .createAlias('library_item_contexts__context_id__contexts__id');

  $$ContextsTableProcessedTableManager get contextId {
    final $_column = $_itemColumn<String>('context_id')!;

    final manager = $$ContextsTableTableManager(
      $_db,
      $_db.contexts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contextIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LibraryItemContextsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryItemContextsTable> {
  $$LibraryItemContextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get associationId => $composableBuilder(
    column: $table.associationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncScope => $composableBuilder(
    column: $table.syncScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryItemsTableFilterComposer get itemId {
    final $$LibraryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.libraryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryItemsTableFilterComposer(
            $db: $db,
            $table: $db.libraryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContextsTableFilterComposer get contextId {
    final $$ContextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contextId,
      referencedTable: $db.contexts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContextsTableFilterComposer(
            $db: $db,
            $table: $db.contexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryItemContextsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryItemContextsTable> {
  $$LibraryItemContextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get associationId => $composableBuilder(
    column: $table.associationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncScope => $composableBuilder(
    column: $table.syncScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryItemsTableOrderingComposer get itemId {
    final $$LibraryItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.libraryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryItemsTableOrderingComposer(
            $db: $db,
            $table: $db.libraryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContextsTableOrderingComposer get contextId {
    final $$ContextsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contextId,
      referencedTable: $db.contexts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContextsTableOrderingComposer(
            $db: $db,
            $table: $db.contexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryItemContextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryItemContextsTable> {
  $$LibraryItemContextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get associationId => $composableBuilder(
    column: $table.associationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncScope =>
      $composableBuilder(column: $table.syncScope, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LibraryItemsTableAnnotationComposer get itemId {
    final $$LibraryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.libraryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContextsTableAnnotationComposer get contextId {
    final $$ContextsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contextId,
      referencedTable: $db.contexts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContextsTableAnnotationComposer(
            $db: $db,
            $table: $db.contexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryItemContextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryItemContextsTable,
          LibraryItemContext,
          $$LibraryItemContextsTableFilterComposer,
          $$LibraryItemContextsTableOrderingComposer,
          $$LibraryItemContextsTableAnnotationComposer,
          $$LibraryItemContextsTableCreateCompanionBuilder,
          $$LibraryItemContextsTableUpdateCompanionBuilder,
          (LibraryItemContext, $$LibraryItemContextsTableReferences),
          LibraryItemContext,
          PrefetchHooks Function({bool itemId, bool contextId})
        > {
  $$LibraryItemContextsTableTableManager(
    _$AppDatabase db,
    $LibraryItemContextsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryItemContextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryItemContextsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LibraryItemContextsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> contextId = const Value.absent(),
                Value<String?> associationId = const Value.absent(),
                Value<String> syncScope = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryItemContextsCompanion(
                itemId: itemId,
                contextId: contextId,
                associationId: associationId,
                syncScope: syncScope,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required String contextId,
                Value<String?> associationId = const Value.absent(),
                Value<String> syncScope = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryItemContextsCompanion.insert(
                itemId: itemId,
                contextId: contextId,
                associationId: associationId,
                syncScope: syncScope,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LibraryItemContextsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false, contextId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable:
                                    $$LibraryItemContextsTableReferences
                                        ._itemIdTable(db),
                                referencedColumn:
                                    $$LibraryItemContextsTableReferences
                                        ._itemIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (contextId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contextId,
                                referencedTable:
                                    $$LibraryItemContextsTableReferences
                                        ._contextIdTable(db),
                                referencedColumn:
                                    $$LibraryItemContextsTableReferences
                                        ._contextIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LibraryItemContextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryItemContextsTable,
      LibraryItemContext,
      $$LibraryItemContextsTableFilterComposer,
      $$LibraryItemContextsTableOrderingComposer,
      $$LibraryItemContextsTableAnnotationComposer,
      $$LibraryItemContextsTableCreateCompanionBuilder,
      $$LibraryItemContextsTableUpdateCompanionBuilder,
      (LibraryItemContext, $$LibraryItemContextsTableReferences),
      LibraryItemContext,
      PrefetchHooks Function({bool itemId, bool contextId})
    >;
typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      required String id,
      required String name,
      Value<String?> destinationJson,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String> shareState,
      Value<String?> remoteRecordId,
      Value<String?> shareCode,
      Value<int?> remoteRevision,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> destinationJson,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String> shareState,
      Value<String?> remoteRecordId,
      Value<String?> shareCode,
      Value<int?> remoteRevision,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, Trip> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TripMembersTable, List<TripMember>>
  _tripMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripMembers,
    aliasName: 'trips__id__trip_members__trip_id',
  );

  $$TripMembersTableProcessedTableManager get tripMembersRefs {
    final manager = $$TripMembersTableTableManager(
      $_db,
      $_db.tripMembers,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TripCategoriesTable, List<TripCategory>>
  _tripCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripCategories,
    aliasName: 'trips__id__trip_categories__trip_id',
  );

  $$TripCategoriesTableProcessedTableManager get tripCategoriesRefs {
    final manager = $$TripCategoriesTableTableManager(
      $_db,
      $_db.tripCategories,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripCategoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TripItemsTable, List<TripItem>>
  _tripItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripItems,
    aliasName: 'trips__id__trip_items__trip_id',
  );

  $$TripItemsTableProcessedTableManager get tripItemsRefs {
    final manager = $$TripItemsTableTableManager(
      $_db,
      $_db.tripItems,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TripGenerationChoicesTable,
    List<TripGenerationChoice>
  >
  _tripGenerationChoicesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tripGenerationChoices,
        aliasName: 'trips__id__trip_generation_choices__trip_id',
      );

  $$TripGenerationChoicesTableProcessedTableManager
  get tripGenerationChoicesRefs {
    final manager = $$TripGenerationChoicesTableTableManager(
      $_db,
      $_db.tripGenerationChoices,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tripGenerationChoicesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationJson => $composableBuilder(
    column: $table.destinationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareState => $composableBuilder(
    column: $table.shareState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteRecordId => $composableBuilder(
    column: $table.remoteRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareCode => $composableBuilder(
    column: $table.shareCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tripMembersRefs(
    Expression<bool> Function($$TripMembersTableFilterComposer f) f,
  ) {
    final $$TripMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripMembers,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripMembersTableFilterComposer(
            $db: $db,
            $table: $db.tripMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tripCategoriesRefs(
    Expression<bool> Function($$TripCategoriesTableFilterComposer f) f,
  ) {
    final $$TripCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripCategories,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.tripCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tripItemsRefs(
    Expression<bool> Function($$TripItemsTableFilterComposer f) f,
  ) {
    final $$TripItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemsTableFilterComposer(
            $db: $db,
            $table: $db.tripItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tripGenerationChoicesRefs(
    Expression<bool> Function($$TripGenerationChoicesTableFilterComposer f) f,
  ) {
    final $$TripGenerationChoicesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tripGenerationChoices,
          getReferencedColumn: (t) => t.tripId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TripGenerationChoicesTableFilterComposer(
                $db: $db,
                $table: $db.tripGenerationChoices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationJson => $composableBuilder(
    column: $table.destinationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareState => $composableBuilder(
    column: $table.shareState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteRecordId => $composableBuilder(
    column: $table.remoteRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareCode => $composableBuilder(
    column: $table.shareCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get destinationJson => $composableBuilder(
    column: $table.destinationJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get shareState => $composableBuilder(
    column: $table.shareState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteRecordId => $composableBuilder(
    column: $table.remoteRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shareCode =>
      $composableBuilder(column: $table.shareCode, builder: (column) => column);

  GeneratedColumn<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> tripMembersRefs<T extends Object>(
    Expression<T> Function($$TripMembersTableAnnotationComposer a) f,
  ) {
    final $$TripMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripMembers,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.tripMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tripCategoriesRefs<T extends Object>(
    Expression<T> Function($$TripCategoriesTableAnnotationComposer a) f,
  ) {
    final $$TripCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripCategories,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.tripCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tripItemsRefs<T extends Object>(
    Expression<T> Function($$TripItemsTableAnnotationComposer a) f,
  ) {
    final $$TripItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tripGenerationChoicesRefs<T extends Object>(
    Expression<T> Function($$TripGenerationChoicesTableAnnotationComposer a) f,
  ) {
    final $$TripGenerationChoicesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tripGenerationChoices,
          getReferencedColumn: (t) => t.tripId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TripGenerationChoicesTableAnnotationComposer(
                $db: $db,
                $table: $db.tripGenerationChoices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          Trip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (Trip, $$TripsTableReferences),
          Trip,
          PrefetchHooks Function({
            bool tripMembersRefs,
            bool tripCategoriesRefs,
            bool tripItemsRefs,
            bool tripGenerationChoicesRefs,
          })
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> destinationJson = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> shareState = const Value.absent(),
                Value<String?> remoteRecordId = const Value.absent(),
                Value<String?> shareCode = const Value.absent(),
                Value<int?> remoteRevision = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                name: name,
                destinationJson: destinationJson,
                startDate: startDate,
                endDate: endDate,
                shareState: shareState,
                remoteRecordId: remoteRecordId,
                shareCode: shareCode,
                remoteRevision: remoteRevision,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> destinationJson = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> shareState = const Value.absent(),
                Value<String?> remoteRecordId = const Value.absent(),
                Value<String?> shareCode = const Value.absent(),
                Value<int?> remoteRevision = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                name: name,
                destinationJson: destinationJson,
                startDate: startDate,
                endDate: endDate,
                shareState: shareState,
                remoteRecordId: remoteRecordId,
                shareCode: shareCode,
                remoteRevision: remoteRevision,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TripsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripMembersRefs = false,
                tripCategoriesRefs = false,
                tripItemsRefs = false,
                tripGenerationChoicesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tripMembersRefs) db.tripMembers,
                    if (tripCategoriesRefs) db.tripCategories,
                    if (tripItemsRefs) db.tripItems,
                    if (tripGenerationChoicesRefs) db.tripGenerationChoices,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tripMembersRefs)
                        await $_getPrefetchedData<
                          Trip,
                          $TripsTable,
                          TripMember
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._tripMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tripCategoriesRefs)
                        await $_getPrefetchedData<
                          Trip,
                          $TripsTable,
                          TripCategory
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._tripCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tripItemsRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, TripItem>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._tripItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tripGenerationChoicesRefs)
                        await $_getPrefetchedData<
                          Trip,
                          $TripsTable,
                          TripGenerationChoice
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._tripGenerationChoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripGenerationChoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      Trip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (Trip, $$TripsTableReferences),
      Trip,
      PrefetchHooks Function({
        bool tripMembersRefs,
        bool tripCategoriesRefs,
        bool tripItemsRefs,
        bool tripGenerationChoicesRefs,
      })
    >;
typedef $$TripMembersTableCreateCompanionBuilder =
    TripMembersCompanion Function({
      required String id,
      required String tripId,
      Value<String?> sourceOwnerId,
      required String groupKind,
      required String name,
      Value<String?> icon,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TripMembersTableUpdateCompanionBuilder =
    TripMembersCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String?> sourceOwnerId,
      Value<String> groupKind,
      Value<String> name,
      Value<String?> icon,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TripMembersTableReferences
    extends BaseReferences<_$AppDatabase, $TripMembersTable, TripMember> {
  $$TripMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('trip_members__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TripCategoriesTable, List<TripCategory>>
  _tripCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripCategories,
    aliasName: 'trip_members__id__trip_categories__member_id',
  );

  $$TripCategoriesTableProcessedTableManager get tripCategoriesRefs {
    final manager = $$TripCategoriesTableTableManager(
      $_db,
      $_db.tripCategories,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripCategoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripMembersTableFilterComposer
    extends Composer<_$AppDatabase, $TripMembersTable> {
  $$TripMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceOwnerId => $composableBuilder(
    column: $table.sourceOwnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupKind => $composableBuilder(
    column: $table.groupKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tripCategoriesRefs(
    Expression<bool> Function($$TripCategoriesTableFilterComposer f) f,
  ) {
    final $$TripCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripCategories,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.tripCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $TripMembersTable> {
  $$TripMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceOwnerId => $composableBuilder(
    column: $table.sourceOwnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupKind => $composableBuilder(
    column: $table.groupKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripMembersTable> {
  $$TripMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceOwnerId => $composableBuilder(
    column: $table.sourceOwnerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupKind =>
      $composableBuilder(column: $table.groupKind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tripCategoriesRefs<T extends Object>(
    Expression<T> Function($$TripCategoriesTableAnnotationComposer a) f,
  ) {
    final $$TripCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripCategories,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.tripCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripMembersTable,
          TripMember,
          $$TripMembersTableFilterComposer,
          $$TripMembersTableOrderingComposer,
          $$TripMembersTableAnnotationComposer,
          $$TripMembersTableCreateCompanionBuilder,
          $$TripMembersTableUpdateCompanionBuilder,
          (TripMember, $$TripMembersTableReferences),
          TripMember,
          PrefetchHooks Function({bool tripId, bool tripCategoriesRefs})
        > {
  $$TripMembersTableTableManager(_$AppDatabase db, $TripMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String?> sourceOwnerId = const Value.absent(),
                Value<String> groupKind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripMembersCompanion(
                id: id,
                tripId: tripId,
                sourceOwnerId: sourceOwnerId,
                groupKind: groupKind,
                name: name,
                icon: icon,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                Value<String?> sourceOwnerId = const Value.absent(),
                required String groupKind,
                required String name,
                Value<String?> icon = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripMembersCompanion.insert(
                id: id,
                tripId: tripId,
                sourceOwnerId: sourceOwnerId,
                groupKind: groupKind,
                name: name,
                icon: icon,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tripId = false, tripCategoriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tripCategoriesRefs) db.tripCategories,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripId,
                                    referencedTable:
                                        $$TripMembersTableReferences
                                            ._tripIdTable(db),
                                    referencedColumn:
                                        $$TripMembersTableReferences
                                            ._tripIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tripCategoriesRefs)
                        await $_getPrefetchedData<
                          TripMember,
                          $TripMembersTable,
                          TripCategory
                        >(
                          currentTable: table,
                          referencedTable: $$TripMembersTableReferences
                              ._tripCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripMembersTableReferences(
                                db,
                                table,
                                p0,
                              ).tripCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memberId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripMembersTable,
      TripMember,
      $$TripMembersTableFilterComposer,
      $$TripMembersTableOrderingComposer,
      $$TripMembersTableAnnotationComposer,
      $$TripMembersTableCreateCompanionBuilder,
      $$TripMembersTableUpdateCompanionBuilder,
      (TripMember, $$TripMembersTableReferences),
      TripMember,
      PrefetchHooks Function({bool tripId, bool tripCategoriesRefs})
    >;
typedef $$TripCategoriesTableCreateCompanionBuilder =
    TripCategoriesCompanion Function({
      required String id,
      required String tripId,
      Value<String?> memberId,
      Value<String?> sourceCategoryId,
      required String name,
      Value<String?> icon,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TripCategoriesTableUpdateCompanionBuilder =
    TripCategoriesCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String?> memberId,
      Value<String?> sourceCategoryId,
      Value<String> name,
      Value<String?> icon,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TripCategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $TripCategoriesTable, TripCategory> {
  $$TripCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('trip_categories__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripMembersTable _memberIdTable(_$AppDatabase db) => db.tripMembers
      .createAlias('trip_categories__member_id__trip_members__id');

  $$TripMembersTableProcessedTableManager? get memberId {
    final $_column = $_itemColumn<String>('member_id');
    if ($_column == null) return null;
    final manager = $$TripMembersTableTableManager(
      $_db,
      $_db.tripMembers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TripItemsTable, List<TripItem>>
  _tripItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripItems,
    aliasName: 'trip_categories__id__trip_items__category_id',
  );

  $$TripItemsTableProcessedTableManager get tripItemsRefs {
    final manager = $$TripItemsTableTableManager(
      $_db,
      $_db.tripItems,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $TripCategoriesTable> {
  $$TripCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceCategoryId => $composableBuilder(
    column: $table.sourceCategoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripMembersTableFilterComposer get memberId {
    final $$TripMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.tripMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripMembersTableFilterComposer(
            $db: $db,
            $table: $db.tripMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tripItemsRefs(
    Expression<bool> Function($$TripItemsTableFilterComposer f) f,
  ) {
    final $$TripItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemsTableFilterComposer(
            $db: $db,
            $table: $db.tripItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TripCategoriesTable> {
  $$TripCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceCategoryId => $composableBuilder(
    column: $table.sourceCategoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripMembersTableOrderingComposer get memberId {
    final $$TripMembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.tripMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripMembersTableOrderingComposer(
            $db: $db,
            $table: $db.tripMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripCategoriesTable> {
  $$TripCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceCategoryId => $composableBuilder(
    column: $table.sourceCategoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripMembersTableAnnotationComposer get memberId {
    final $$TripMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.tripMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.tripMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tripItemsRefs<T extends Object>(
    Expression<T> Function($$TripItemsTableAnnotationComposer a) f,
  ) {
    final $$TripItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripCategoriesTable,
          TripCategory,
          $$TripCategoriesTableFilterComposer,
          $$TripCategoriesTableOrderingComposer,
          $$TripCategoriesTableAnnotationComposer,
          $$TripCategoriesTableCreateCompanionBuilder,
          $$TripCategoriesTableUpdateCompanionBuilder,
          (TripCategory, $$TripCategoriesTableReferences),
          TripCategory,
          PrefetchHooks Function({
            bool tripId,
            bool memberId,
            bool tripItemsRefs,
          })
        > {
  $$TripCategoriesTableTableManager(
    _$AppDatabase db,
    $TripCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<String?> sourceCategoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripCategoriesCompanion(
                id: id,
                tripId: tripId,
                memberId: memberId,
                sourceCategoryId: sourceCategoryId,
                name: name,
                icon: icon,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                Value<String?> memberId = const Value.absent(),
                Value<String?> sourceCategoryId = const Value.absent(),
                required String name,
                Value<String?> icon = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripCategoriesCompanion.insert(
                id: id,
                tripId: tripId,
                memberId: memberId,
                sourceCategoryId: sourceCategoryId,
                name: name,
                icon: icon,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tripId = false, memberId = false, tripItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (tripItemsRefs) db.tripItems],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripId,
                                    referencedTable:
                                        $$TripCategoriesTableReferences
                                            ._tripIdTable(db),
                                    referencedColumn:
                                        $$TripCategoriesTableReferences
                                            ._tripIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (memberId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.memberId,
                                    referencedTable:
                                        $$TripCategoriesTableReferences
                                            ._memberIdTable(db),
                                    referencedColumn:
                                        $$TripCategoriesTableReferences
                                            ._memberIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tripItemsRefs)
                        await $_getPrefetchedData<
                          TripCategory,
                          $TripCategoriesTable,
                          TripItem
                        >(
                          currentTable: table,
                          referencedTable: $$TripCategoriesTableReferences
                              ._tripItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).tripItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripCategoriesTable,
      TripCategory,
      $$TripCategoriesTableFilterComposer,
      $$TripCategoriesTableOrderingComposer,
      $$TripCategoriesTableAnnotationComposer,
      $$TripCategoriesTableCreateCompanionBuilder,
      $$TripCategoriesTableUpdateCompanionBuilder,
      (TripCategory, $$TripCategoriesTableReferences),
      TripCategory,
      PrefetchHooks Function({bool tripId, bool memberId, bool tripItemsRefs})
    >;
typedef $$TripItemsTableCreateCompanionBuilder =
    TripItemsCompanion Function({
      required String id,
      required String tripId,
      required String categoryId,
      required String name,
      Value<int> quantity,
      Value<String> status,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TripItemsTableUpdateCompanionBuilder =
    TripItemsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> categoryId,
      Value<String> name,
      Value<int> quantity,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TripItemsTableReferences
    extends BaseReferences<_$AppDatabase, $TripItemsTable, TripItem> {
  $$TripItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('trip_items__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripCategoriesTable _categoryIdTable(_$AppDatabase db) => db
      .tripCategories
      .createAlias('trip_items__category_id__trip_categories__id');

  $$TripCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$TripCategoriesTableTableManager(
      $_db,
      $_db.tripCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TripItemSourcesTable, List<TripItemSource>>
  _tripItemSourcesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripItemSources,
    aliasName: 'trip_items__id__trip_item_sources__trip_item_id',
  );

  $$TripItemSourcesTableProcessedTableManager get tripItemSourcesRefs {
    final manager = $$TripItemSourcesTableTableManager(
      $_db,
      $_db.tripItemSources,
    ).filter((f) => f.tripItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tripItemSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TripItemsTable> {
  $$TripItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripCategoriesTableFilterComposer get categoryId {
    final $$TripCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.tripCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.tripCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tripItemSourcesRefs(
    Expression<bool> Function($$TripItemSourcesTableFilterComposer f) f,
  ) {
    final $$TripItemSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripItemSources,
      getReferencedColumn: (t) => t.tripItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemSourcesTableFilterComposer(
            $db: $db,
            $table: $db.tripItemSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripItemsTable> {
  $$TripItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripCategoriesTableOrderingComposer get categoryId {
    final $$TripCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.tripCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.tripCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripItemsTable> {
  $$TripItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripCategoriesTableAnnotationComposer get categoryId {
    final $$TripCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.tripCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.tripCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tripItemSourcesRefs<T extends Object>(
    Expression<T> Function($$TripItemSourcesTableAnnotationComposer a) f,
  ) {
    final $$TripItemSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripItemSources,
      getReferencedColumn: (t) => t.tripItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.tripItemSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripItemsTable,
          TripItem,
          $$TripItemsTableFilterComposer,
          $$TripItemsTableOrderingComposer,
          $$TripItemsTableAnnotationComposer,
          $$TripItemsTableCreateCompanionBuilder,
          $$TripItemsTableUpdateCompanionBuilder,
          (TripItem, $$TripItemsTableReferences),
          TripItem,
          PrefetchHooks Function({
            bool tripId,
            bool categoryId,
            bool tripItemSourcesRefs,
          })
        > {
  $$TripItemsTableTableManager(_$AppDatabase db, $TripItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripItemsCompanion(
                id: id,
                tripId: tripId,
                categoryId: categoryId,
                name: name,
                quantity: quantity,
                status: status,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String categoryId,
                required String name,
                Value<int> quantity = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripItemsCompanion.insert(
                id: id,
                tripId: tripId,
                categoryId: categoryId,
                name: name,
                quantity: quantity,
                status: status,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripId = false,
                categoryId = false,
                tripItemSourcesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tripItemSourcesRefs) db.tripItemSources,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripId,
                                    referencedTable: $$TripItemsTableReferences
                                        ._tripIdTable(db),
                                    referencedColumn: $$TripItemsTableReferences
                                        ._tripIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$TripItemsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$TripItemsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tripItemSourcesRefs)
                        await $_getPrefetchedData<
                          TripItem,
                          $TripItemsTable,
                          TripItemSource
                        >(
                          currentTable: table,
                          referencedTable: $$TripItemsTableReferences
                              ._tripItemSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripItemSourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripItemsTable,
      TripItem,
      $$TripItemsTableFilterComposer,
      $$TripItemsTableOrderingComposer,
      $$TripItemsTableAnnotationComposer,
      $$TripItemsTableCreateCompanionBuilder,
      $$TripItemsTableUpdateCompanionBuilder,
      (TripItem, $$TripItemsTableReferences),
      TripItem,
      PrefetchHooks Function({
        bool tripId,
        bool categoryId,
        bool tripItemSourcesRefs,
      })
    >;
typedef $$TripItemSourcesTableCreateCompanionBuilder =
    TripItemSourcesCompanion Function({
      required String tripItemId,
      required String sourceLibraryItemId,
      required String sourceKind,
      Value<String> reasonKind,
      Value<String> reasonId,
      Value<String?> contributingLibraryItemId,
      Value<int> rowid,
    });
typedef $$TripItemSourcesTableUpdateCompanionBuilder =
    TripItemSourcesCompanion Function({
      Value<String> tripItemId,
      Value<String> sourceLibraryItemId,
      Value<String> sourceKind,
      Value<String> reasonKind,
      Value<String> reasonId,
      Value<String?> contributingLibraryItemId,
      Value<int> rowid,
    });

final class $$TripItemSourcesTableReferences
    extends
        BaseReferences<_$AppDatabase, $TripItemSourcesTable, TripItemSource> {
  $$TripItemSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripItemsTable _tripItemIdTable(_$AppDatabase db) => db.tripItems
      .createAlias('trip_item_sources__trip_item_id__trip_items__id');

  $$TripItemsTableProcessedTableManager get tripItemId {
    final $_column = $_itemColumn<String>('trip_item_id')!;

    final manager = $$TripItemsTableTableManager(
      $_db,
      $_db.tripItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripItemSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $TripItemSourcesTable> {
  $$TripItemSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceLibraryItemId => $composableBuilder(
    column: $table.sourceLibraryItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonKind => $composableBuilder(
    column: $table.reasonKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonId => $composableBuilder(
    column: $table.reasonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contributingLibraryItemId => $composableBuilder(
    column: $table.contributingLibraryItemId,
    builder: (column) => ColumnFilters(column),
  );

  $$TripItemsTableFilterComposer get tripItemId {
    final $$TripItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripItemId,
      referencedTable: $db.tripItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemsTableFilterComposer(
            $db: $db,
            $table: $db.tripItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripItemSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $TripItemSourcesTable> {
  $$TripItemSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceLibraryItemId => $composableBuilder(
    column: $table.sourceLibraryItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonKind => $composableBuilder(
    column: $table.reasonKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonId => $composableBuilder(
    column: $table.reasonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contributingLibraryItemId => $composableBuilder(
    column: $table.contributingLibraryItemId,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripItemsTableOrderingComposer get tripItemId {
    final $$TripItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripItemId,
      referencedTable: $db.tripItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemsTableOrderingComposer(
            $db: $db,
            $table: $db.tripItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripItemSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripItemSourcesTable> {
  $$TripItemSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceLibraryItemId => $composableBuilder(
    column: $table.sourceLibraryItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reasonKind => $composableBuilder(
    column: $table.reasonKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reasonId =>
      $composableBuilder(column: $table.reasonId, builder: (column) => column);

  GeneratedColumn<String> get contributingLibraryItemId => $composableBuilder(
    column: $table.contributingLibraryItemId,
    builder: (column) => column,
  );

  $$TripItemsTableAnnotationComposer get tripItemId {
    final $$TripItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripItemId,
      referencedTable: $db.tripItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripItemSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripItemSourcesTable,
          TripItemSource,
          $$TripItemSourcesTableFilterComposer,
          $$TripItemSourcesTableOrderingComposer,
          $$TripItemSourcesTableAnnotationComposer,
          $$TripItemSourcesTableCreateCompanionBuilder,
          $$TripItemSourcesTableUpdateCompanionBuilder,
          (TripItemSource, $$TripItemSourcesTableReferences),
          TripItemSource,
          PrefetchHooks Function({bool tripItemId})
        > {
  $$TripItemSourcesTableTableManager(
    _$AppDatabase db,
    $TripItemSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripItemSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripItemSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripItemSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tripItemId = const Value.absent(),
                Value<String> sourceLibraryItemId = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String> reasonKind = const Value.absent(),
                Value<String> reasonId = const Value.absent(),
                Value<String?> contributingLibraryItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripItemSourcesCompanion(
                tripItemId: tripItemId,
                sourceLibraryItemId: sourceLibraryItemId,
                sourceKind: sourceKind,
                reasonKind: reasonKind,
                reasonId: reasonId,
                contributingLibraryItemId: contributingLibraryItemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tripItemId,
                required String sourceLibraryItemId,
                required String sourceKind,
                Value<String> reasonKind = const Value.absent(),
                Value<String> reasonId = const Value.absent(),
                Value<String?> contributingLibraryItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripItemSourcesCompanion.insert(
                tripItemId: tripItemId,
                sourceLibraryItemId: sourceLibraryItemId,
                sourceKind: sourceKind,
                reasonKind: reasonKind,
                reasonId: reasonId,
                contributingLibraryItemId: contributingLibraryItemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripItemSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripItemId,
                                referencedTable:
                                    $$TripItemSourcesTableReferences
                                        ._tripItemIdTable(db),
                                referencedColumn:
                                    $$TripItemSourcesTableReferences
                                        ._tripItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripItemSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripItemSourcesTable,
      TripItemSource,
      $$TripItemSourcesTableFilterComposer,
      $$TripItemSourcesTableOrderingComposer,
      $$TripItemSourcesTableAnnotationComposer,
      $$TripItemSourcesTableCreateCompanionBuilder,
      $$TripItemSourcesTableUpdateCompanionBuilder,
      (TripItemSource, $$TripItemSourcesTableReferences),
      TripItemSource,
      PrefetchHooks Function({bool tripItemId})
    >;
typedef $$TripGenerationChoicesTableCreateCompanionBuilder =
    TripGenerationChoicesCompanion Function({
      required String id,
      required String tripId,
      required String choiceKind,
      required String choiceId,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TripGenerationChoicesTableUpdateCompanionBuilder =
    TripGenerationChoicesCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> choiceKind,
      Value<String> choiceId,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TripGenerationChoicesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TripGenerationChoicesTable,
          TripGenerationChoice
        > {
  $$TripGenerationChoicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('trip_generation_choices__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripGenerationChoicesTableFilterComposer
    extends Composer<_$AppDatabase, $TripGenerationChoicesTable> {
  $$TripGenerationChoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get choiceKind => $composableBuilder(
    column: $table.choiceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get choiceId => $composableBuilder(
    column: $table.choiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripGenerationChoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $TripGenerationChoicesTable> {
  $$TripGenerationChoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get choiceKind => $composableBuilder(
    column: $table.choiceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get choiceId => $composableBuilder(
    column: $table.choiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripGenerationChoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripGenerationChoicesTable> {
  $$TripGenerationChoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get choiceKind => $composableBuilder(
    column: $table.choiceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get choiceId =>
      $composableBuilder(column: $table.choiceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripGenerationChoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripGenerationChoicesTable,
          TripGenerationChoice,
          $$TripGenerationChoicesTableFilterComposer,
          $$TripGenerationChoicesTableOrderingComposer,
          $$TripGenerationChoicesTableAnnotationComposer,
          $$TripGenerationChoicesTableCreateCompanionBuilder,
          $$TripGenerationChoicesTableUpdateCompanionBuilder,
          (TripGenerationChoice, $$TripGenerationChoicesTableReferences),
          TripGenerationChoice,
          PrefetchHooks Function({bool tripId})
        > {
  $$TripGenerationChoicesTableTableManager(
    _$AppDatabase db,
    $TripGenerationChoicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripGenerationChoicesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TripGenerationChoicesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TripGenerationChoicesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> choiceKind = const Value.absent(),
                Value<String> choiceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripGenerationChoicesCompanion(
                id: id,
                tripId: tripId,
                choiceKind: choiceKind,
                choiceId: choiceId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String choiceKind,
                required String choiceId,
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripGenerationChoicesCompanion.insert(
                id: id,
                tripId: tripId,
                choiceKind: choiceKind,
                choiceId: choiceId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripGenerationChoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable:
                                    $$TripGenerationChoicesTableReferences
                                        ._tripIdTable(db),
                                referencedColumn:
                                    $$TripGenerationChoicesTableReferences
                                        ._tripIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripGenerationChoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripGenerationChoicesTable,
      TripGenerationChoice,
      $$TripGenerationChoicesTableFilterComposer,
      $$TripGenerationChoicesTableOrderingComposer,
      $$TripGenerationChoicesTableAnnotationComposer,
      $$TripGenerationChoicesTableCreateCompanionBuilder,
      $$TripGenerationChoicesTableUpdateCompanionBuilder,
      (TripGenerationChoice, $$TripGenerationChoicesTableReferences),
      TripGenerationChoice,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$QuickListsTableCreateCompanionBuilder =
    QuickListsCompanion Function({
      required String id,
      required String name,
      Value<String> shareState,
      Value<String?> remoteRecordId,
      Value<String?> shareCode,
      Value<int?> remoteRevision,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$QuickListsTableUpdateCompanionBuilder =
    QuickListsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> shareState,
      Value<String?> remoteRecordId,
      Value<String?> shareCode,
      Value<int?> remoteRevision,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$QuickListsTableReferences
    extends BaseReferences<_$AppDatabase, $QuickListsTable, QuickList> {
  $$QuickListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuickListItemsTable, List<QuickListItem>>
  _quickListItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.quickListItems,
    aliasName: 'quick_lists__id__quick_list_items__quick_list_id',
  );

  $$QuickListItemsTableProcessedTableManager get quickListItemsRefs {
    final manager = $$QuickListItemsTableTableManager(
      $_db,
      $_db.quickListItems,
    ).filter((f) => f.quickListId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_quickListItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuickListsTableFilterComposer
    extends Composer<_$AppDatabase, $QuickListsTable> {
  $$QuickListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareState => $composableBuilder(
    column: $table.shareState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteRecordId => $composableBuilder(
    column: $table.remoteRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareCode => $composableBuilder(
    column: $table.shareCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> quickListItemsRefs(
    Expression<bool> Function($$QuickListItemsTableFilterComposer f) f,
  ) {
    final $$QuickListItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quickListItems,
      getReferencedColumn: (t) => t.quickListId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuickListItemsTableFilterComposer(
            $db: $db,
            $table: $db.quickListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuickListsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuickListsTable> {
  $$QuickListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareState => $composableBuilder(
    column: $table.shareState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteRecordId => $composableBuilder(
    column: $table.remoteRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareCode => $composableBuilder(
    column: $table.shareCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuickListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuickListsTable> {
  $$QuickListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shareState => $composableBuilder(
    column: $table.shareState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteRecordId => $composableBuilder(
    column: $table.remoteRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shareCode =>
      $composableBuilder(column: $table.shareCode, builder: (column) => column);

  GeneratedColumn<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> quickListItemsRefs<T extends Object>(
    Expression<T> Function($$QuickListItemsTableAnnotationComposer a) f,
  ) {
    final $$QuickListItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quickListItems,
      getReferencedColumn: (t) => t.quickListId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuickListItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.quickListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuickListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuickListsTable,
          QuickList,
          $$QuickListsTableFilterComposer,
          $$QuickListsTableOrderingComposer,
          $$QuickListsTableAnnotationComposer,
          $$QuickListsTableCreateCompanionBuilder,
          $$QuickListsTableUpdateCompanionBuilder,
          (QuickList, $$QuickListsTableReferences),
          QuickList,
          PrefetchHooks Function({bool quickListItemsRefs})
        > {
  $$QuickListsTableTableManager(_$AppDatabase db, $QuickListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuickListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuickListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuickListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> shareState = const Value.absent(),
                Value<String?> remoteRecordId = const Value.absent(),
                Value<String?> shareCode = const Value.absent(),
                Value<int?> remoteRevision = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuickListsCompanion(
                id: id,
                name: name,
                shareState: shareState,
                remoteRecordId: remoteRecordId,
                shareCode: shareCode,
                remoteRevision: remoteRevision,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> shareState = const Value.absent(),
                Value<String?> remoteRecordId = const Value.absent(),
                Value<String?> shareCode = const Value.absent(),
                Value<int?> remoteRevision = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuickListsCompanion.insert(
                id: id,
                name: name,
                shareState: shareState,
                remoteRecordId: remoteRecordId,
                shareCode: shareCode,
                remoteRevision: remoteRevision,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuickListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({quickListItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (quickListItemsRefs) db.quickListItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (quickListItemsRefs)
                    await $_getPrefetchedData<
                      QuickList,
                      $QuickListsTable,
                      QuickListItem
                    >(
                      currentTable: table,
                      referencedTable: $$QuickListsTableReferences
                          ._quickListItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$QuickListsTableReferences(
                            db,
                            table,
                            p0,
                          ).quickListItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.quickListId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$QuickListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuickListsTable,
      QuickList,
      $$QuickListsTableFilterComposer,
      $$QuickListsTableOrderingComposer,
      $$QuickListsTableAnnotationComposer,
      $$QuickListsTableCreateCompanionBuilder,
      $$QuickListsTableUpdateCompanionBuilder,
      (QuickList, $$QuickListsTableReferences),
      QuickList,
      PrefetchHooks Function({bool quickListItemsRefs})
    >;
typedef $$QuickListItemsTableCreateCompanionBuilder =
    QuickListItemsCompanion Function({
      required String id,
      required String quickListId,
      required String name,
      Value<int> quantity,
      Value<bool> isChecked,
      required DateTime createdAt,
      required DateTime updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$QuickListItemsTableUpdateCompanionBuilder =
    QuickListItemsCompanion Function({
      Value<String> id,
      Value<String> quickListId,
      Value<String> name,
      Value<int> quantity,
      Value<bool> isChecked,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAtLocal,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$QuickListItemsTableReferences
    extends BaseReferences<_$AppDatabase, $QuickListItemsTable, QuickListItem> {
  $$QuickListItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QuickListsTable _quickListIdTable(_$AppDatabase db) => db.quickLists
      .createAlias('quick_list_items__quick_list_id__quick_lists__id');

  $$QuickListsTableProcessedTableManager get quickListId {
    final $_column = $_itemColumn<String>('quick_list_id')!;

    final manager = $$QuickListsTableTableManager(
      $_db,
      $_db.quickLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quickListIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuickListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QuickListItemsTable> {
  $$QuickListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$QuickListsTableFilterComposer get quickListId {
    final $$QuickListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quickListId,
      referencedTable: $db.quickLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuickListsTableFilterComposer(
            $db: $db,
            $table: $db.quickLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuickListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuickListItemsTable> {
  $$QuickListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuickListsTableOrderingComposer get quickListId {
    final $$QuickListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quickListId,
      referencedTable: $db.quickLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuickListsTableOrderingComposer(
            $db: $db,
            $table: $db.quickLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuickListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuickListItemsTable> {
  $$QuickListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtLocal => $composableBuilder(
    column: $table.updatedAtLocal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$QuickListsTableAnnotationComposer get quickListId {
    final $$QuickListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quickListId,
      referencedTable: $db.quickLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuickListsTableAnnotationComposer(
            $db: $db,
            $table: $db.quickLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuickListItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuickListItemsTable,
          QuickListItem,
          $$QuickListItemsTableFilterComposer,
          $$QuickListItemsTableOrderingComposer,
          $$QuickListItemsTableAnnotationComposer,
          $$QuickListItemsTableCreateCompanionBuilder,
          $$QuickListItemsTableUpdateCompanionBuilder,
          (QuickListItem, $$QuickListItemsTableReferences),
          QuickListItem,
          PrefetchHooks Function({bool quickListId})
        > {
  $$QuickListItemsTableTableManager(
    _$AppDatabase db,
    $QuickListItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuickListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuickListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuickListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> quickListId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAtLocal = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuickListItemsCompanion(
                id: id,
                quickListId: quickListId,
                name: name,
                quantity: quantity,
                isChecked: isChecked,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String quickListId,
                required String name,
                Value<int> quantity = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAtLocal,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuickListItemsCompanion.insert(
                id: id,
                quickListId: quickListId,
                name: name,
                quantity: quantity,
                isChecked: isChecked,
                createdAt: createdAt,
                updatedAtLocal: updatedAtLocal,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuickListItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({quickListId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (quickListId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.quickListId,
                                referencedTable: $$QuickListItemsTableReferences
                                    ._quickListIdTable(db),
                                referencedColumn:
                                    $$QuickListItemsTableReferences
                                        ._quickListIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuickListItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuickListItemsTable,
      QuickListItem,
      $$QuickListItemsTableFilterComposer,
      $$QuickListItemsTableOrderingComposer,
      $$QuickListItemsTableAnnotationComposer,
      $$QuickListItemsTableCreateCompanionBuilder,
      $$QuickListItemsTableUpdateCompanionBuilder,
      (QuickListItem, $$QuickListItemsTableReferences),
      QuickListItem,
      PrefetchHooks Function({bool quickListId})
    >;
typedef $$SyncDocumentsTableCreateCompanionBuilder =
    SyncDocumentsCompanion Function({
      required String documentId,
      required String documentType,
      Value<String?> remoteRecordId,
      Value<String?> shareCode,
      Value<String?> capabilityToken,
      Value<int> pullCursor,
      Value<int> confirmedRevision,
      Value<DateTime?> lastSyncedAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncDocumentsTableUpdateCompanionBuilder =
    SyncDocumentsCompanion Function({
      Value<String> documentId,
      Value<String> documentType,
      Value<String?> remoteRecordId,
      Value<String?> shareCode,
      Value<String?> capabilityToken,
      Value<int> pullCursor,
      Value<int> confirmedRevision,
      Value<DateTime?> lastSyncedAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncDocumentsTable> {
  $$SyncDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteRecordId => $composableBuilder(
    column: $table.remoteRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareCode => $composableBuilder(
    column: $table.shareCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capabilityToken => $composableBuilder(
    column: $table.capabilityToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmedRevision => $composableBuilder(
    column: $table.confirmedRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncDocumentsTable> {
  $$SyncDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteRecordId => $composableBuilder(
    column: $table.remoteRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareCode => $composableBuilder(
    column: $table.shareCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capabilityToken => $composableBuilder(
    column: $table.capabilityToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedRevision => $composableBuilder(
    column: $table.confirmedRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncDocumentsTable> {
  $$SyncDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteRecordId => $composableBuilder(
    column: $table.remoteRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shareCode =>
      $composableBuilder(column: $table.shareCode, builder: (column) => column);

  GeneratedColumn<String> get capabilityToken => $composableBuilder(
    column: $table.capabilityToken,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confirmedRevision => $composableBuilder(
    column: $table.confirmedRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncDocumentsTable,
          SyncDocument,
          $$SyncDocumentsTableFilterComposer,
          $$SyncDocumentsTableOrderingComposer,
          $$SyncDocumentsTableAnnotationComposer,
          $$SyncDocumentsTableCreateCompanionBuilder,
          $$SyncDocumentsTableUpdateCompanionBuilder,
          (
            SyncDocument,
            BaseReferences<_$AppDatabase, $SyncDocumentsTable, SyncDocument>,
          ),
          SyncDocument,
          PrefetchHooks Function()
        > {
  $$SyncDocumentsTableTableManager(_$AppDatabase db, $SyncDocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> documentId = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<String?> remoteRecordId = const Value.absent(),
                Value<String?> shareCode = const Value.absent(),
                Value<String?> capabilityToken = const Value.absent(),
                Value<int> pullCursor = const Value.absent(),
                Value<int> confirmedRevision = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDocumentsCompanion(
                documentId: documentId,
                documentType: documentType,
                remoteRecordId: remoteRecordId,
                shareCode: shareCode,
                capabilityToken: capabilityToken,
                pullCursor: pullCursor,
                confirmedRevision: confirmedRevision,
                lastSyncedAt: lastSyncedAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String documentId,
                required String documentType,
                Value<String?> remoteRecordId = const Value.absent(),
                Value<String?> shareCode = const Value.absent(),
                Value<String?> capabilityToken = const Value.absent(),
                Value<int> pullCursor = const Value.absent(),
                Value<int> confirmedRevision = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDocumentsCompanion.insert(
                documentId: documentId,
                documentType: documentType,
                remoteRecordId: remoteRecordId,
                shareCode: shareCode,
                capabilityToken: capabilityToken,
                pullCursor: pullCursor,
                confirmedRevision: confirmedRevision,
                lastSyncedAt: lastSyncedAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncDocumentsTable,
      SyncDocument,
      $$SyncDocumentsTableFilterComposer,
      $$SyncDocumentsTableOrderingComposer,
      $$SyncDocumentsTableAnnotationComposer,
      $$SyncDocumentsTableCreateCompanionBuilder,
      $$SyncDocumentsTableUpdateCompanionBuilder,
      (
        SyncDocument,
        BaseReferences<_$AppDatabase, $SyncDocumentsTable, SyncDocument>,
      ),
      SyncDocument,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String operationId,
      required String documentId,
      required String entityType,
      required String entityId,
      required String operationType,
      required String payloadJson,
      Value<String> libraryId,
      Value<String> installationId,
      Value<int> clientSequence,
      Value<int> clientCounter,
      Value<int?> baseRevision,
      Value<int> attempts,
      required DateTime createdAt,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> operationId,
      Value<String> documentId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operationType,
      Value<String> payloadJson,
      Value<String> libraryId,
      Value<String> installationId,
      Value<int> clientSequence,
      Value<int> clientCounter,
      Value<int?> baseRevision,
      Value<int> attempts,
      Value<DateTime> createdAt,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientSequence => $composableBuilder(
    column: $table.clientSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientCounter => $composableBuilder(
    column: $table.clientCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientSequence => $composableBuilder(
    column: $table.clientSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientCounter => $composableBuilder(
    column: $table.clientCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get libraryId =>
      $composableBuilder(column: $table.libraryId, builder: (column) => column);

  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clientSequence => $composableBuilder(
    column: $table.clientSequence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clientCounter => $composableBuilder(
    column: $table.clientCounter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> libraryId = const Value.absent(),
                Value<String> installationId = const Value.absent(),
                Value<int> clientSequence = const Value.absent(),
                Value<int> clientCounter = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                operationId: operationId,
                documentId: documentId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadJson: payloadJson,
                libraryId: libraryId,
                installationId: installationId,
                clientSequence: clientSequence,
                clientCounter: clientCounter,
                baseRevision: baseRevision,
                attempts: attempts,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String documentId,
                required String entityType,
                required String entityId,
                required String operationType,
                required String payloadJson,
                Value<String> libraryId = const Value.absent(),
                Value<String> installationId = const Value.absent(),
                Value<int> clientSequence = const Value.absent(),
                Value<int> clientCounter = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                operationId: operationId,
                documentId: documentId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadJson: payloadJson,
                libraryId: libraryId,
                installationId: installationId,
                clientSequence: clientSequence,
                clientCounter: clientCounter,
                baseRevision: baseRevision,
                attempts: attempts,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String documentId,
      required String entityType,
      required String entityId,
      Value<String?> localJson,
      Value<String?> remoteJson,
      required DateTime detectedAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String?> localJson,
      Value<String?> remoteJson,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get localJson =>
      $composableBuilder(column: $table.localJson, builder: (column) => column);

  GeneratedColumn<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String?> localJson = const Value.absent(),
                Value<String?> remoteJson = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                documentId: documentId,
                entityType: entityType,
                entityId: entityId,
                localJson: localJson,
                remoteJson: remoteJson,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required String entityType,
                required String entityId,
                Value<String?> localJson = const Value.absent(),
                Value<String?> remoteJson = const Value.absent(),
                required DateTime detectedAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                documentId: documentId,
                entityType: entityType,
                entityId: entityId,
                localJson: localJson,
                remoteJson: remoteJson,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$SyncTombstonesTableCreateCompanionBuilder =
    SyncTombstonesCompanion Function({
      required String entityType,
      required String entityId,
      required DateTime deletedAt,
      Value<DateTime?> propagatedAt,
      required DateTime purgeEligibleAt,
      Value<int> rowid,
    });
typedef $$SyncTombstonesTableUpdateCompanionBuilder =
    SyncTombstonesCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<DateTime> deletedAt,
      Value<DateTime?> propagatedAt,
      Value<DateTime> purgeEligibleAt,
      Value<int> rowid,
    });

class $$SyncTombstonesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncTombstonesTable> {
  $$SyncTombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get propagatedAt => $composableBuilder(
    column: $table.propagatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purgeEligibleAt => $composableBuilder(
    column: $table.purgeEligibleAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncTombstonesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncTombstonesTable> {
  $$SyncTombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get propagatedAt => $composableBuilder(
    column: $table.propagatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purgeEligibleAt => $composableBuilder(
    column: $table.purgeEligibleAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncTombstonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncTombstonesTable> {
  $$SyncTombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get propagatedAt => $composableBuilder(
    column: $table.propagatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purgeEligibleAt => $composableBuilder(
    column: $table.purgeEligibleAt,
    builder: (column) => column,
  );
}

class $$SyncTombstonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncTombstonesTable,
          SyncTombstone,
          $$SyncTombstonesTableFilterComposer,
          $$SyncTombstonesTableOrderingComposer,
          $$SyncTombstonesTableAnnotationComposer,
          $$SyncTombstonesTableCreateCompanionBuilder,
          $$SyncTombstonesTableUpdateCompanionBuilder,
          (
            SyncTombstone,
            BaseReferences<_$AppDatabase, $SyncTombstonesTable, SyncTombstone>,
          ),
          SyncTombstone,
          PrefetchHooks Function()
        > {
  $$SyncTombstonesTableTableManager(
    _$AppDatabase db,
    $SyncTombstonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncTombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncTombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncTombstonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<DateTime?> propagatedAt = const Value.absent(),
                Value<DateTime> purgeEligibleAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncTombstonesCompanion(
                entityType: entityType,
                entityId: entityId,
                deletedAt: deletedAt,
                propagatedAt: propagatedAt,
                purgeEligibleAt: purgeEligibleAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                required DateTime deletedAt,
                Value<DateTime?> propagatedAt = const Value.absent(),
                required DateTime purgeEligibleAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncTombstonesCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                deletedAt: deletedAt,
                propagatedAt: propagatedAt,
                purgeEligibleAt: purgeEligibleAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncTombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncTombstonesTable,
      SyncTombstone,
      $$SyncTombstonesTableFilterComposer,
      $$SyncTombstonesTableOrderingComposer,
      $$SyncTombstonesTableAnnotationComposer,
      $$SyncTombstonesTableCreateCompanionBuilder,
      $$SyncTombstonesTableUpdateCompanionBuilder,
      (
        SyncTombstone,
        BaseReferences<_$AppDatabase, $SyncTombstonesTable, SyncTombstone>,
      ),
      SyncTombstone,
      PrefetchHooks Function()
    >;
typedef $$SyncEntityStatesTableCreateCompanionBuilder =
    SyncEntityStatesCompanion Function({
      required String entityType,
      required String entityId,
      Value<int> clientCounter,
      Value<int> serverRevision,
      Value<String?> winningDeviceId,
      Value<bool> remotelyDeleted,
      Value<int> rowid,
    });
typedef $$SyncEntityStatesTableUpdateCompanionBuilder =
    SyncEntityStatesCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<int> clientCounter,
      Value<int> serverRevision,
      Value<String?> winningDeviceId,
      Value<bool> remotelyDeleted,
      Value<int> rowid,
    });

class $$SyncEntityStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEntityStatesTable> {
  $$SyncEntityStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientCounter => $composableBuilder(
    column: $table.clientCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winningDeviceId => $composableBuilder(
    column: $table.winningDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remotelyDeleted => $composableBuilder(
    column: $table.remotelyDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncEntityStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEntityStatesTable> {
  $$SyncEntityStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientCounter => $composableBuilder(
    column: $table.clientCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winningDeviceId => $composableBuilder(
    column: $table.winningDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remotelyDeleted => $composableBuilder(
    column: $table.remotelyDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncEntityStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEntityStatesTable> {
  $$SyncEntityStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get clientCounter => $composableBuilder(
    column: $table.clientCounter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winningDeviceId => $composableBuilder(
    column: $table.winningDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remotelyDeleted => $composableBuilder(
    column: $table.remotelyDeleted,
    builder: (column) => column,
  );
}

class $$SyncEntityStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncEntityStatesTable,
          SyncEntityState,
          $$SyncEntityStatesTableFilterComposer,
          $$SyncEntityStatesTableOrderingComposer,
          $$SyncEntityStatesTableAnnotationComposer,
          $$SyncEntityStatesTableCreateCompanionBuilder,
          $$SyncEntityStatesTableUpdateCompanionBuilder,
          (
            SyncEntityState,
            BaseReferences<
              _$AppDatabase,
              $SyncEntityStatesTable,
              SyncEntityState
            >,
          ),
          SyncEntityState,
          PrefetchHooks Function()
        > {
  $$SyncEntityStatesTableTableManager(
    _$AppDatabase db,
    $SyncEntityStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEntityStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEntityStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncEntityStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> clientCounter = const Value.absent(),
                Value<int> serverRevision = const Value.absent(),
                Value<String?> winningDeviceId = const Value.absent(),
                Value<bool> remotelyDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityStatesCompanion(
                entityType: entityType,
                entityId: entityId,
                clientCounter: clientCounter,
                serverRevision: serverRevision,
                winningDeviceId: winningDeviceId,
                remotelyDeleted: remotelyDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                Value<int> clientCounter = const Value.absent(),
                Value<int> serverRevision = const Value.absent(),
                Value<String?> winningDeviceId = const Value.absent(),
                Value<bool> remotelyDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityStatesCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                clientCounter: clientCounter,
                serverRevision: serverRevision,
                winningDeviceId: winningDeviceId,
                remotelyDeleted: remotelyDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncEntityStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncEntityStatesTable,
      SyncEntityState,
      $$SyncEntityStatesTableFilterComposer,
      $$SyncEntityStatesTableOrderingComposer,
      $$SyncEntityStatesTableAnnotationComposer,
      $$SyncEntityStatesTableCreateCompanionBuilder,
      $$SyncEntityStatesTableUpdateCompanionBuilder,
      (
        SyncEntityState,
        BaseReferences<_$AppDatabase, $SyncEntityStatesTable, SyncEntityState>,
      ),
      SyncEntityState,
      PrefetchHooks Function()
    >;
typedef $$LegacyIdMapsTableCreateCompanionBuilder =
    LegacyIdMapsCompanion Function({
      required String sourceKind,
      Value<String> sourceRecordId,
      required String entityType,
      required String legacyId,
      required String v1Uuid,
      Value<String?> jsonPath,
      Value<int> rowid,
    });
typedef $$LegacyIdMapsTableUpdateCompanionBuilder =
    LegacyIdMapsCompanion Function({
      Value<String> sourceKind,
      Value<String> sourceRecordId,
      Value<String> entityType,
      Value<String> legacyId,
      Value<String> v1Uuid,
      Value<String?> jsonPath,
      Value<int> rowid,
    });

class $$LegacyIdMapsTableFilterComposer
    extends Composer<_$AppDatabase, $LegacyIdMapsTable> {
  $$LegacyIdMapsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get v1Uuid => $composableBuilder(
    column: $table.v1Uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonPath => $composableBuilder(
    column: $table.jsonPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LegacyIdMapsTableOrderingComposer
    extends Composer<_$AppDatabase, $LegacyIdMapsTable> {
  $$LegacyIdMapsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get v1Uuid => $composableBuilder(
    column: $table.v1Uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonPath => $composableBuilder(
    column: $table.jsonPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LegacyIdMapsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LegacyIdMapsTable> {
  $$LegacyIdMapsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legacyId =>
      $composableBuilder(column: $table.legacyId, builder: (column) => column);

  GeneratedColumn<String> get v1Uuid =>
      $composableBuilder(column: $table.v1Uuid, builder: (column) => column);

  GeneratedColumn<String> get jsonPath =>
      $composableBuilder(column: $table.jsonPath, builder: (column) => column);
}

class $$LegacyIdMapsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LegacyIdMapsTable,
          LegacyIdMap,
          $$LegacyIdMapsTableFilterComposer,
          $$LegacyIdMapsTableOrderingComposer,
          $$LegacyIdMapsTableAnnotationComposer,
          $$LegacyIdMapsTableCreateCompanionBuilder,
          $$LegacyIdMapsTableUpdateCompanionBuilder,
          (
            LegacyIdMap,
            BaseReferences<_$AppDatabase, $LegacyIdMapsTable, LegacyIdMap>,
          ),
          LegacyIdMap,
          PrefetchHooks Function()
        > {
  $$LegacyIdMapsTableTableManager(_$AppDatabase db, $LegacyIdMapsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LegacyIdMapsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LegacyIdMapsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LegacyIdMapsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceKind = const Value.absent(),
                Value<String> sourceRecordId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> legacyId = const Value.absent(),
                Value<String> v1Uuid = const Value.absent(),
                Value<String?> jsonPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LegacyIdMapsCompanion(
                sourceKind: sourceKind,
                sourceRecordId: sourceRecordId,
                entityType: entityType,
                legacyId: legacyId,
                v1Uuid: v1Uuid,
                jsonPath: jsonPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceKind,
                Value<String> sourceRecordId = const Value.absent(),
                required String entityType,
                required String legacyId,
                required String v1Uuid,
                Value<String?> jsonPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LegacyIdMapsCompanion.insert(
                sourceKind: sourceKind,
                sourceRecordId: sourceRecordId,
                entityType: entityType,
                legacyId: legacyId,
                v1Uuid: v1Uuid,
                jsonPath: jsonPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LegacyIdMapsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LegacyIdMapsTable,
      LegacyIdMap,
      $$LegacyIdMapsTableFilterComposer,
      $$LegacyIdMapsTableOrderingComposer,
      $$LegacyIdMapsTableAnnotationComposer,
      $$LegacyIdMapsTableCreateCompanionBuilder,
      $$LegacyIdMapsTableUpdateCompanionBuilder,
      (
        LegacyIdMap,
        BaseReferences<_$AppDatabase, $LegacyIdMapsTable, LegacyIdMap>,
      ),
      LegacyIdMap,
      PrefetchHooks Function()
    >;
typedef $$MigrationHistoryTableCreateCompanionBuilder =
    MigrationHistoryCompanion Function({
      required String id,
      required String sourceKind,
      required String sourceSha256,
      Value<String?> sourceSchema,
      required DateTime importedAt,
      required String reportJson,
      Value<int> rowid,
    });
typedef $$MigrationHistoryTableUpdateCompanionBuilder =
    MigrationHistoryCompanion Function({
      Value<String> id,
      Value<String> sourceKind,
      Value<String> sourceSha256,
      Value<String?> sourceSchema,
      Value<DateTime> importedAt,
      Value<String> reportJson,
      Value<int> rowid,
    });

class $$MigrationHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $MigrationHistoryTable> {
  $$MigrationHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceSha256 => $composableBuilder(
    column: $table.sourceSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceSchema => $composableBuilder(
    column: $table.sourceSchema,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportJson => $composableBuilder(
    column: $table.reportJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MigrationHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $MigrationHistoryTable> {
  $$MigrationHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceSha256 => $composableBuilder(
    column: $table.sourceSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceSchema => $composableBuilder(
    column: $table.sourceSchema,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportJson => $composableBuilder(
    column: $table.reportJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MigrationHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $MigrationHistoryTable> {
  $$MigrationHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceSha256 => $composableBuilder(
    column: $table.sourceSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceSchema => $composableBuilder(
    column: $table.sourceSchema,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportJson => $composableBuilder(
    column: $table.reportJson,
    builder: (column) => column,
  );
}

class $$MigrationHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MigrationHistoryTable,
          MigrationHistoryData,
          $$MigrationHistoryTableFilterComposer,
          $$MigrationHistoryTableOrderingComposer,
          $$MigrationHistoryTableAnnotationComposer,
          $$MigrationHistoryTableCreateCompanionBuilder,
          $$MigrationHistoryTableUpdateCompanionBuilder,
          (
            MigrationHistoryData,
            BaseReferences<
              _$AppDatabase,
              $MigrationHistoryTable,
              MigrationHistoryData
            >,
          ),
          MigrationHistoryData,
          PrefetchHooks Function()
        > {
  $$MigrationHistoryTableTableManager(
    _$AppDatabase db,
    $MigrationHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MigrationHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MigrationHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MigrationHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String> sourceSha256 = const Value.absent(),
                Value<String?> sourceSchema = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<String> reportJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MigrationHistoryCompanion(
                id: id,
                sourceKind: sourceKind,
                sourceSha256: sourceSha256,
                sourceSchema: sourceSchema,
                importedAt: importedAt,
                reportJson: reportJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceKind,
                required String sourceSha256,
                Value<String?> sourceSchema = const Value.absent(),
                required DateTime importedAt,
                required String reportJson,
                Value<int> rowid = const Value.absent(),
              }) => MigrationHistoryCompanion.insert(
                id: id,
                sourceKind: sourceKind,
                sourceSha256: sourceSha256,
                sourceSchema: sourceSchema,
                importedAt: importedAt,
                reportJson: reportJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MigrationHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MigrationHistoryTable,
      MigrationHistoryData,
      $$MigrationHistoryTableFilterComposer,
      $$MigrationHistoryTableOrderingComposer,
      $$MigrationHistoryTableAnnotationComposer,
      $$MigrationHistoryTableCreateCompanionBuilder,
      $$MigrationHistoryTableUpdateCompanionBuilder,
      (
        MigrationHistoryData,
        BaseReferences<
          _$AppDatabase,
          $MigrationHistoryTable,
          MigrationHistoryData
        >,
      ),
      MigrationHistoryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InstallationSettingsTableTableManager get installationSettings =>
      $$InstallationSettingsTableTableManager(_db, _db.installationSettings);
  $$LibraryOwnersTableTableManager get libraryOwners =>
      $$LibraryOwnersTableTableManager(_db, _db.libraryOwners);
  $$LibraryCategoriesTableTableManager get libraryCategories =>
      $$LibraryCategoriesTableTableManager(_db, _db.libraryCategories);
  $$LibraryItemsTableTableManager get libraryItems =>
      $$LibraryItemsTableTableManager(_db, _db.libraryItems);
  $$ContextsTableTableManager get contexts =>
      $$ContextsTableTableManager(_db, _db.contexts);
  $$LibraryItemContextsTableTableManager get libraryItemContexts =>
      $$LibraryItemContextsTableTableManager(_db, _db.libraryItemContexts);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$TripMembersTableTableManager get tripMembers =>
      $$TripMembersTableTableManager(_db, _db.tripMembers);
  $$TripCategoriesTableTableManager get tripCategories =>
      $$TripCategoriesTableTableManager(_db, _db.tripCategories);
  $$TripItemsTableTableManager get tripItems =>
      $$TripItemsTableTableManager(_db, _db.tripItems);
  $$TripItemSourcesTableTableManager get tripItemSources =>
      $$TripItemSourcesTableTableManager(_db, _db.tripItemSources);
  $$TripGenerationChoicesTableTableManager get tripGenerationChoices =>
      $$TripGenerationChoicesTableTableManager(_db, _db.tripGenerationChoices);
  $$QuickListsTableTableManager get quickLists =>
      $$QuickListsTableTableManager(_db, _db.quickLists);
  $$QuickListItemsTableTableManager get quickListItems =>
      $$QuickListItemsTableTableManager(_db, _db.quickListItems);
  $$SyncDocumentsTableTableManager get syncDocuments =>
      $$SyncDocumentsTableTableManager(_db, _db.syncDocuments);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$SyncTombstonesTableTableManager get syncTombstones =>
      $$SyncTombstonesTableTableManager(_db, _db.syncTombstones);
  $$SyncEntityStatesTableTableManager get syncEntityStates =>
      $$SyncEntityStatesTableTableManager(_db, _db.syncEntityStates);
  $$LegacyIdMapsTableTableManager get legacyIdMaps =>
      $$LegacyIdMapsTableTableManager(_db, _db.legacyIdMaps);
  $$MigrationHistoryTableTableManager get migrationHistory =>
      $$MigrationHistoryTableTableManager(_db, _db.migrationHistory);
}
