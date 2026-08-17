import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'pocketbase_v1_contract.dart';
import 'sync_models.dart';
import 'sync_remote_gateway.dart';

class PocketBaseSyncRemote implements SyncRemoteGateway {
  PocketBaseSyncRemote({
    String baseUrl = PocketBaseV1Contract.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _baseUri = Uri.parse(baseUrl),
       _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;
  final Duration timeout;

  @override
  Future<SyncPushResult> push(SyncOperation operation) async {
    final response = await _send(
      () => _client.post(
        _baseUri.resolve(PocketBaseV1Contract.pushPath),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode(operation.toJson()),
      ),
    );
    return SyncPushResult(
      remoteOperation: RemoteOperation.fromJson(_decode(response)),
    );
  }

  @override
  Future<SyncPullPage> pull({
    required String libraryId,
    required int afterRevision,
    int limit = 200,
  }) async {
    final uri = _baseUri
        .resolve(PocketBaseV1Contract.pullPath)
        .replace(
          queryParameters: {
            'library_uuid': libraryId,
            'after_revision': '$afterRevision',
            'limit': '$limit',
          },
        );
    final response = await _send(() => _client.get(uri));
    final json = _decode(response);
    return SyncPullPage(
      operations: (json['operations'] as List? ?? const [])
          .map(
            (item) => RemoteOperation.fromJson(
              Map<String, Object?>.from(item as Map),
            ),
          )
          .toList(growable: false),
      cursor: (json['cursor'] as num?)?.toInt() ?? afterRevision,
    );
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'PocketBase ${response.statusCode}: ${response.body}',
        );
      }
      return response;
    } on TimeoutException catch (_) {
      throw const SyncOfflineException('Délai réseau dépassé.');
    } on SocketException catch (_) {
      throw const SyncOfflineException();
    } on http.ClientException catch (_) {
      throw const SyncOfflineException();
    }
  }

  Map<String, Object?> _decode(http.Response response) {
    final value = jsonDecode(utf8.decode(response.bodyBytes));
    if (value is! Map) throw const FormatException('Réponse V1 invalide.');
    return Map<String, Object?>.from(value);
  }
}
