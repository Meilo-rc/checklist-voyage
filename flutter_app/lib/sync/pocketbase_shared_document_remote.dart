import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'pocketbase_v1_contract.dart';
import 'shared_document_remote.dart';
import 'sync_models.dart';
import 'sync_remote_gateway.dart';

class PocketBaseSharedDocumentRemote implements SharedDocumentRemoteGateway {
  PocketBaseSharedDocumentRemote({
    String baseUrl = PocketBaseV1Contract.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _baseUri = Uri.parse(baseUrl),
       _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;
  final Duration timeout;

  @override
  Future<RemoteDocumentAccess> share({
    required String documentId,
    required String documentType,
    required String deviceId,
  }) async {
    final response = await _post(PocketBaseV1Contract.documentSharePath, {
      'document_uuid': documentId,
      'document_type': documentType,
      'device_uuid': deviceId,
    });
    return RemoteDocumentAccess.fromJson(_decode(response));
  }

  @override
  Future<RemoteDocumentAccess> join({
    required String shareCode,
    required String deviceId,
  }) async {
    final response = await _post(PocketBaseV1Contract.documentJoinPath, {
      'share_code': shareCode,
      'device_uuid': deviceId,
    }, invalidCode: true);
    return RemoteDocumentAccess.fromJson(_decode(response));
  }

  @override
  Future<SyncPushResult> pushDocument({
    required SyncOperation operation,
    required String capabilityToken,
  }) async {
    final payload = operation.toJson();
    payload['document_uuid'] = payload.remove('library_uuid');
    final response = await _post(
      PocketBaseV1Contract.documentPushPath,
      payload,
      headers: _accessHeaders(operation.deviceId, capabilityToken),
    );
    final json = _decode(response);
    json['library_uuid'] = json.remove('document_uuid');
    return SyncPushResult(remoteOperation: RemoteOperation.fromJson(json));
  }

  @override
  Future<SyncPullPage> pullDocument({
    required String documentId,
    required String deviceId,
    required String capabilityToken,
    required int afterRevision,
    int limit = 200,
  }) async {
    final uri = _baseUri
        .resolve(PocketBaseV1Contract.documentPullPath)
        .replace(
          queryParameters: {
            'document_uuid': documentId,
            'after_revision': '$afterRevision',
            'limit': '$limit',
          },
        );
    final response = await _send(
      () =>
          _client.get(uri, headers: _accessHeaders(deviceId, capabilityToken)),
    );
    final json = _decode(response);
    return SyncPullPage(
      operations: (json['operations'] as List? ?? const [])
          .map((value) {
            final operation = Map<String, Object?>.from(value as Map);
            operation['library_uuid'] = operation.remove('document_uuid');
            return RemoteOperation.fromJson(operation);
          })
          .toList(growable: false),
      cursor: (json['cursor'] as num?)?.toInt() ?? afterRevision,
    );
  }

  Map<String, String> _accessHeaders(String deviceId, String token) => {
    'x-cv1-device': deviceId,
    'x-cv1-capability': token,
  };

  Future<http.Response> _post(
    String path,
    Map<String, Object?> body, {
    Map<String, String> headers = const {},
    bool invalidCode = false,
  }) async {
    final response = await _send(
      () => _client.post(
        _baseUri.resolve(path),
        headers: {'content-type': 'application/json', ...headers},
        body: jsonEncode(body),
      ),
      allowError: invalidCode,
    );
    if (invalidCode && response.statusCode >= 400) {
      throw const InvalidShareCodeException();
    }
    return response;
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    bool allowError = false,
  }) async {
    try {
      final response = await request().timeout(timeout);
      if (!allowError &&
          (response.statusCode < 200 || response.statusCode >= 300)) {
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
