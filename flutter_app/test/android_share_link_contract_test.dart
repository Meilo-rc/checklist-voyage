import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android déclare l App Link vérifié et le canal natif', () async {
    final manifest = await File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsString();
    final activity = await File(
      'android/app/src/main/kotlin/fr/checklistvoyage/'
      'checklist_voyage_v1/MainActivity.kt',
    ).readAsString();

    expect(manifest, contains('android:autoVerify="true"'));
    expect(manifest, contains('android:host="checklist-voyage-pb.fly.dev"'));
    expect(manifest, contains('android:pathPrefix="/join"'));
    expect(manifest, contains('android:scheme="checklistvoyage"'));
    expect(activity, contains('Intent.ACTION_SEND'));
    expect(activity, contains('Intent.createChooser'));
    expect(activity, contains('override fun onNewIntent'));
    expect(activity, contains('takeInitialJoinLink'));
    expect(activity, contains('onJoinLink'));
  });

  test('le backend prépare assetlinks et un fallback Web minimal', () async {
    final hook = await File('../pocketbase/pb_hooks/cv1_links.pb.js')
        .readAsString();
    final dockerfile = await File('../pocketbase/Dockerfile').readAsString();

    expect(hook, contains('/.well-known/assetlinks.json'));
    expect(hook, contains('fr.checklistvoyage.app'));
    expect(hook, contains('delegate_permission/common.handle_all_urls'));
    expect(hook, contains('routerAdd("GET", "/join"'));
    expect(hook, contains('checklistvoyage://join?type='));
    expect(hook, contains('Code : <strong>'));
    expect(hook.toLowerCase(), isNot(contains('capability_token')));
    expect(dockerfile, contains('cv1_links.pb.js'));
  });
}
