import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';

import 'package:checklist_voyage_v1/data/backup/v1_safety_backup_service.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) _usage();
  final command = arguments.first;
  final options = _options(arguments.skip(1));
  if (command == 'inspect') {
    final backup = _required(options, 'backup');
    final database = AppDatabase(NativeDatabase.memory());
    try {
      final info = V1SafetyBackupService(
        database,
      ).inspect(await File(backup).readAsBytes());
      stdout.writeln(jsonEncode(_manifest(info)));
    } finally {
      await database.close();
    }
    return;
  }

  final databasePath = _required(options, 'database');
  final database = AppDatabase(NativeDatabase(File(databasePath)));
  final service = V1SafetyBackupService(database);
  try {
    if (command == 'export') {
      final output = _required(options, 'output');
      final bytes = await service.exportBytes();
      await File(output).writeAsBytes(bytes, flush: true);
      stdout.writeln(jsonEncode(_manifest(service.inspect(bytes))));
      return;
    }
    if (command == 'restore') {
      if (!options.containsKey('allow-replace')) {
        stderr.writeln('La restauration exige --allow-replace.');
        exitCode = 2;
        return;
      }
      final backup = _required(options, 'backup');
      final info = await service.restoreBytes(await File(backup).readAsBytes());
      stdout.writeln(jsonEncode(_manifest(info)));
      return;
    }
    _usage();
  } finally {
    await database.close();
  }
}

Map<String, Object?> _manifest(V1SafetyBackupInfo info) => {
  'schemaVersion': info.schemaVersion,
  'installationId': info.installationId,
  'exportedAtUtc': info.exportedAtUtc.toIso8601String(),
  'contentSha256': info.sha256,
  'tableCounts': info.tableCounts,
};

Map<String, String?> _options(Iterable<String> arguments) {
  final result = <String, String?>{};
  final values = arguments.toList(growable: false);
  for (var index = 0; index < values.length; index++) {
    final option = values[index];
    if (!option.startsWith('--')) _usage();
    final key = option.substring(2);
    if (key == 'allow-replace') {
      result[key] = null;
      continue;
    }
    if (++index >= values.length) _usage();
    result[key] = values[index];
  }
  return result;
}

String _required(Map<String, String?> options, String name) {
  final value = options[name];
  if (value == null || value.isEmpty) _usage();
  return value;
}

Never _usage() {
  stderr.writeln('Usage :');
  stderr.writeln(
    '  dart run tool/v1_safety_backup.dart export '
    '--database <sqlite> --output <backup.json>',
  );
  stderr.writeln(
    '  dart run tool/v1_safety_backup.dart inspect --backup <backup.json>',
  );
  stderr.writeln(
    '  dart run tool/v1_safety_backup.dart restore --database <sqlite> '
    '--backup <backup.json> --allow-replace',
  );
  exit(2);
}
