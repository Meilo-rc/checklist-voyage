import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/features/launch/launch_animation.dart';

void main() {
  testWidgets('compose les calques puis ouvre l accueil après 1,8 seconde', (
    tester,
  ) async {
    expect(launchAnimationDuration, const Duration(milliseconds: 1800));

    await tester.pumpWidget(
      const MaterialApp(
        home: LaunchGate(home: Scaffold(body: Text('Accueil prêt'))),
      ),
    );

    expect(find.byKey(const Key('launch-animation')), findsOneWidget);
    expect(find.byKey(const Key('launch-blue-suitcase')), findsOneWidget);
    expect(find.byKey(const Key('launch-pink-bag')), findsOneWidget);
    expect(find.byKey(const Key('launch-handle')), findsOneWidget);
    expect(find.byKey(const Key('launch-decorations')), findsOneWidget);
    expect(find.text('Accueil prêt'), findsNothing);

    await tester.pump();
    await tester.pump(
      launchAnimationDuration - const Duration(milliseconds: 1),
    );
    expect(find.byKey(const Key('launch-animation')), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('launch-animation')), findsNothing);
    expect(find.text('Accueil prêt'), findsOneWidget);
  });
}
