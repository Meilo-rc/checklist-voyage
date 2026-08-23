import 'package:flutter/services.dart';

class SafetyBackupFileGateway {
  const SafetyBackupFileGateway({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'fr.checklistvoyage.app/safety_backup';
  final MethodChannel _channel;

  Future<bool> save({required String name, required Uint8List bytes}) async {
    return await _channel.invokeMethod<bool>('saveBackup', {
          'name': name,
          'bytes': bytes,
        }) ??
        false;
  }
}
