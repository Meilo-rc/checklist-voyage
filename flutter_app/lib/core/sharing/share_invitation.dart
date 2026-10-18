import 'dart:async';

import 'package:flutter/services.dart';

enum ShareableDocumentType {
  trip('trip'),
  quickList('quick-list');

  const ShareableDocumentType(this.urlValue);

  final String urlValue;
}

class ShareJoinRequest {
  const ShareJoinRequest({required this.type, required this.code});

  final ShareableDocumentType type;
  final String code;

  Uri get url => Uri.https(ShareInvitation.linkHost, '/join', {
    'type': type.urlValue,
    'code': code,
  });

  static ShareJoinRequest? tryParse(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) return null;

    final validHttps =
        uri.scheme == 'https' &&
        uri.host == ShareInvitation.linkHost &&
        uri.path == '/join';
    final validFallback =
        uri.scheme == 'checklistvoyage' &&
        uri.host == 'join' &&
        (uri.path.isEmpty || uri.path == '/');
    if (!validHttps && !validFallback) return null;

    final type = switch (uri.queryParameters['type']) {
      'trip' => ShareableDocumentType.trip,
      'quick-list' => ShareableDocumentType.quickList,
      _ => null,
    };
    final code = uri.queryParameters['code']?.trim().toUpperCase();
    if (type == null || code == null || !_codePattern.hasMatch(code)) {
      return null;
    }
    return ShareJoinRequest(type: type, code: code);
  }

  static final _codePattern = RegExp(r'^[A-Z2-9]{8}$');
}

class ShareInvitation {
  const ShareInvitation({
    required this.type,
    required this.displayName,
    required this.code,
  });

  static const linkHost = 'checklist-voyage-pb.fly.dev';

  final ShareableDocumentType type;
  final String displayName;
  final String code;

  ShareJoinRequest get joinRequest => ShareJoinRequest(type: type, code: code);

  String get subject => switch (type) {
    ShareableDocumentType.trip => 'Voyage partagé · Checklist Voyage',
    ShareableDocumentType.quickList => 'Liste partagée · Checklist Voyage',
  };

  String get message {
    final object = switch (type) {
      ShareableDocumentType.trip => 'un voyage',
      ShareableDocumentType.quickList => 'une liste',
    };
    final pronoun = switch (type) {
      ShareableDocumentType.trip => 'Ouvre-le',
      ShareableDocumentType.quickList => 'Ouvre-la',
    };
    return 'Salut ! Voici $object que je veux partager avec toi : '
        '$displayName\n\n'
        'Code : $code\n\n'
        '$pronoun directement dans Checklist Voyage :\n'
        '${joinRequest.url}';
  }
}

abstract interface class ShareInvitationGateway {
  Stream<ShareJoinRequest> get incomingRequests;

  Future<ShareJoinRequest?> takeInitialRequest();

  Future<void> share(ShareInvitation invitation);

  Future<void> close();
}

class AndroidShareInvitationGateway implements ShareInvitationGateway {
  AndroidShareInvitationGateway({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName) {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static const _channelName = 'fr.checklistvoyage.app/share_invitation';

  final MethodChannel _channel;
  final _incoming = StreamController<ShareJoinRequest>.broadcast();

  @override
  Stream<ShareJoinRequest> get incomingRequests => _incoming.stream;

  Future<void> _handleNativeCall(MethodCall call) async {
    if (call.method != 'onJoinLink') return;
    final request = ShareJoinRequest.tryParse(call.arguments as String?);
    if (request != null) _incoming.add(request);
  }

  @override
  Future<ShareJoinRequest?> takeInitialRequest() async {
    final url = await _channel.invokeMethod<String>('takeInitialJoinLink');
    return ShareJoinRequest.tryParse(url);
  }

  @override
  Future<void> share(ShareInvitation invitation) => _channel.invokeMethod<void>(
    'shareText',
    {'subject': invitation.subject, 'text': invitation.message},
  );

  @override
  Future<void> close() async {
    _channel.setMethodCallHandler(null);
    await _incoming.close();
  }
}

class UnavailableShareInvitationGateway implements ShareInvitationGateway {
  const UnavailableShareInvitationGateway();

  @override
  Stream<ShareJoinRequest> get incomingRequests => const Stream.empty();

  @override
  Future<ShareJoinRequest?> takeInitialRequest() async => null;

  @override
  Future<void> share(ShareInvitation invitation) {
    throw UnsupportedError('Partage Android indisponible.');
  }

  @override
  Future<void> close() async {}
}
