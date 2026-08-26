import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../sync/pocketbase_v1_contract.dart';
import '../local/app_database.dart';

const _format = 'checklist-voyage-v1-safety-backup';
const _formatVersion = 1;

class V1SafetyBackupInfo {
  const V1SafetyBackupInfo({
    required this.installationId,
    required this.schemaVersion,
    required this.exportedAtUtc,
    required this.sha256,
    required this.tableCounts,
  });

  final String installationId;
  final int schemaVersion;
  final DateTime exportedAtUtc;
  final String sha256;
  final Map<String, int> tableCounts;

  int count(String table) => tableCounts[table] ?? 0;
}

class V1SafetyBackupService {
  V1SafetyBackupService(this._database);

  final AppDatabase _database;

  static const tableNames = <String>[
    'installation_settings',
    'library_owners',
    'library_categories',
    'library_items',
    'contexts',
    'library_item_contexts',
    'trips',
    'trip_members',
    'trip_categories',
    'trip_items',
    'trip_item_sources',
    'trip_generation_choices',
    'quick_lists',
    'quick_list_items',
    'sync_documents',
    'sync_outbox',
    'sync_conflicts',
    'sync_tombstones',
    'sync_entity_states',
    'legacy_id_maps',
    'migration_history',
  ];

  Future<Uint8List> exportBytes({DateTime? now}) async {
    final tables = <String, List<Map<String, Object?>>>{};
    await _database.transaction(() async {
      for (final table in tableNames) {
        final rows = await _database
            .customSelect('SELECT * FROM "$table"')
            .get();
        tables[table] = [for (final row in rows) Map.of(row.data)];
      }
    });
    final settings = tables['installation_settings']!;
    if (settings.length != 1) {
      throw const FormatException('Identité d’installation introuvable.');
    }
    final exportedAt = (now ?? DateTime.now()).toUtc();
    final content = <String, Object?>{
      'format': _format,
      'formatVersion': _formatVersion,
      'databaseSchemaVersion': _database.schemaVersion,
      'exportedAtUtc': exportedAt.toIso8601String(),
      'backendUrl': PocketBaseV1Contract.baseUrl,
      'installationId': settings.single['installation_id'],
      'tableCounts': {
        for (final entry in tables.entries) entry.key: entry.value.length,
      },
      'tables': tables,
    };
    final checksum = _checksum(content);
    return Uint8List.fromList(
      utf8.encode(jsonEncode({...content, 'sha256': checksum})),
    );
  }

  V1SafetyBackupInfo inspect(Uint8List bytes) {
    final decoded = _decodeAndValidate(bytes);
    final counts = (decoded['tableCounts']! as Map<String, Object?>).map(
      (key, value) => MapEntry(key, value as int),
    );
    return V1SafetyBackupInfo(
      installationId: decoded['installationId']! as String,
      schemaVersion: decoded['databaseSchemaVersion']! as int,
      exportedAtUtc: DateTime.parse(
        decoded['exportedAtUtc']! as String,
      ).toUtc(),
      sha256: decoded['sha256']! as String,
      tableCounts: Map.unmodifiable(counts),
    );
  }

  Future<V1SafetyBackupInfo> restoreBytes(Uint8List bytes) async {
    final decoded = _decodeAndValidate(bytes);
    final tables = decoded['tables']! as Map<String, Object?>;
    await _database.transaction(() async {
      await _database.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final table in tableNames.reversed) {
        await _database.customStatement('DELETE FROM "$table"');
      }
      for (final table in tableNames) {
        final rows = tables[table]! as List<Object?>;
        for (final encodedRow in rows) {
          final row = encodedRow! as Map<String, Object?>;
          final columns = row.keys.toList(growable: false);
          if (columns.isEmpty) {
            throw FormatException('Ligne vide dans $table.');
          }
          final quotedColumns = columns.map((column) => '"$column"').join(', ');
          final placeholders = List.filled(columns.length, '?').join(', ');
          await _database.customInsert(
            'INSERT INTO "$table" ($quotedColumns) VALUES ($placeholders)',
            variables: [for (final column in columns) _variable(row[column])],
          );
        }
      }
    });
    return inspect(bytes);
  }

  Map<String, Object?> _decodeAndValidate(Uint8List bytes) {
    final Object? raw;
    try {
      raw = jsonDecode(utf8.decode(bytes));
    } on Object {
      throw const FormatException('Sauvegarde V1 illisible.');
    }
    if (raw is! Map<String, Object?>) {
      throw const FormatException('Format de sauvegarde V1 invalide.');
    }
    final decoded = Map<String, Object?>.from(raw);
    if (decoded['format'] != _format ||
        decoded['formatVersion'] != _formatVersion) {
      throw const FormatException(
        'Ce fichier n’est pas une sauvegarde V1 compatible.',
      );
    }
    final backupSchemaVersion = decoded['databaseSchemaVersion'];
    if (backupSchemaVersion is! int ||
        backupSchemaVersion < 7 ||
        backupSchemaVersion > _database.schemaVersion) {
      throw FormatException(
        'Schéma incompatible : attendu ${_database.schemaVersion}.',
      );
    }
    final expectedChecksum = decoded.remove('sha256');
    if (expectedChecksum is! String || expectedChecksum != _checksum(decoded)) {
      throw const FormatException('Empreinte de sauvegarde V1 invalide.');
    }
    decoded['sha256'] = expectedChecksum;
    final tables = decoded['tables'];
    final counts = decoded['tableCounts'];
    if (tables is! Map<String, Object?> || counts is! Map<String, Object?>) {
      throw const FormatException('Tables de sauvegarde V1 manquantes.');
    }
    if (tables.keys.toSet().difference(tableNames.toSet()).isNotEmpty ||
        tableNames.any((table) => !tables.containsKey(table))) {
      throw const FormatException('Liste des tables V1 incompatible.');
    }
    for (final table in tableNames) {
      final rows = tables[table];
      if (rows is! List<Object?> || counts[table] != rows.length) {
        throw FormatException('Comptage invalide pour $table.');
      }
      for (final row in rows) {
        if (row is! Map<String, Object?> ||
            row.keys.any((column) => !_isSafeIdentifier(column))) {
          throw FormatException('Colonnes invalides pour $table.');
        }
      }
    }
    final settings = tables['installation_settings']! as List<Object?>;
    if (settings.length != 1 ||
        (settings.single! as Map<String, Object?>)['installation_id'] !=
            decoded['installationId']) {
      throw const FormatException('Identité d’installation incohérente.');
    }
    DateTime.parse(decoded['exportedAtUtc']! as String);
    return decoded;
  }

  static bool _isSafeIdentifier(String value) =>
      RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value);

  static String _checksum(Map<String, Object?> content) =>
      sha256.convert(utf8.encode(jsonEncode(content))).toString();

  static Variable _variable(Object? value) => switch (value) {
    null => const Variable<String>(null),
    int value => Variable.withInt(value),
    double value => Variable.withReal(value),
    bool value => Variable.withBool(value),
    String value => Variable.withString(value),
    _ => throw FormatException(
      'Type SQLite non pris en charge : ${value.runtimeType}.',
    ),
  };
}
