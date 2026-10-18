import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/core/sharing/share_invitation.dart';

void main() {
  group('ShareJoinRequest', () {
    test('parse les liens HTTPS Voyage et Liste rapide', () {
      final trip = ShareJoinRequest.tryParse(
        'https://checklist-voyage-pb.fly.dev/join?type=trip&code=GJEJDNJE',
      );
      final list = ShareJoinRequest.tryParse(
        'https://checklist-voyage-pb.fly.dev/join?type=quick-list&code=ABCDEFGH',
      );

      expect(trip?.type, ShareableDocumentType.trip);
      expect(trip?.code, 'GJEJDNJE');
      expect(list?.type, ShareableDocumentType.quickList);
      expect(list?.code, 'ABCDEFGH');
    });

    test('accepte les paramètres supplémentaires et normalise la casse', () {
      final request = ShareJoinRequest.tryParse(
        'https://checklist-voyage-pb.fly.dev/join?source=mail&type=trip&code=gjejdnje',
      );

      expect(request?.type, ShareableDocumentType.trip);
      expect(request?.code, 'GJEJDNJE');
    });

    test('accepte le schéma de secours de la page Web', () {
      final request = ShareJoinRequest.tryParse(
        'checklistvoyage://join?type=quick-list&code=GJEJDNJE',
      );

      expect(request?.type, ShareableDocumentType.quickList);
      expect(request?.code, 'GJEJDNJE');
    });

    test('rejette types, codes, domaines et URL invalides', () {
      for (final value in <String>[
        'https://checklist-voyage-pb.fly.dev/join?type=unknown&code=GJEJDNJE',
        'https://checklist-voyage-pb.fly.dev/join?type=trip',
        'https://checklist-voyage-pb.fly.dev/join?type=trip&code=ABC',
        'https://example.com/join?type=trip&code=GJEJDNJE',
        'pas une url',
      ]) {
        expect(ShareJoinRequest.tryParse(value), isNull, reason: value);
      }
    });
  });

  group('ShareInvitation', () {
    test('produit le message français attendu pour un voyage', () {
      const invitation = ShareInvitation(
        type: ShareableDocumentType.trip,
        displayName: 'Séjour à Djèrba',
        code: 'GJEJDNJE',
      );

      expect(
        invitation.message,
        'Salut ! Voici un voyage que je veux partager avec toi : '
        'Séjour à Djèrba\n\n'
        'Code : GJEJDNJE\n\n'
        'Ouvre-le directement dans Checklist Voyage :\n'
        'https://checklist-voyage-pb.fly.dev/join?type=trip&code=GJEJDNJE',
      );
    });

    test('produit le message attendu sans donnée sensible pour une liste', () {
      const invitation = ShareInvitation(
        type: ShareableDocumentType.quickList,
        displayName: 'Courses été',
        code: 'ABCDEFGH',
      );

      expect(invitation.message, contains('Voici une liste'));
      expect(invitation.message, contains('Courses été'));
      expect(invitation.message, contains('Code : ABCDEFGH'));
      expect(
        invitation.message,
        contains(
          'https://checklist-voyage-pb.fly.dev/join?type=quick-list&code=ABCDEFGH',
        ),
      );
      expect(invitation.message.toLowerCase(), isNot(contains('token')));
      expect(invitation.message.toLowerCase(), isNot(contains('capability')));
      expect(
        invitation.message,
        isNot(contains('123e4567-e89b-12d3-a456-426614174000')),
      );
    });
  });
}
