import 'package:checklist_voyage_v1/core/version/app_version.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('fr.checklistvoyage.app/app_info');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'lit la version et le build depuis les métadonnées installées',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'getVersion');
            return <String, Object?>{
              'versionName': '1.0.0-rc.2',
              'versionCode': '16',
            };
          });

      final version = await const AppVersionGateway().load();

      expect(version.versionName, '1.0.0-rc.2');
      expect(version.versionCode, '16');
      expect(version.compactLabel, '1.0.0-rc.2 · 16');
    },
  );

  testWidgets('affiche la version sans ajouter une ligne à l’en-tête', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppVersionScope(
          info: const AppVersionInfo(
            versionName: '1.0.0-rc.2',
            versionCode: '16',
          ),
          child: Scaffold(
            appBar: AppBar(title: const VersionedTitle('Checklist Voyage')),
          ),
        ),
      ),
    );

    expect(find.text('Checklist Voyage'), findsOneWidget);
    expect(find.text('1.0.0-rc.2 · 16'), findsOneWidget);
    expect(find.byKey(const Key('installed-app-version')), findsOneWidget);
  });
}
