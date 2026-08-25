import 'package:flutter/material.dart';

import 'app/app_dependencies.dart';
import 'app/checklist_app.dart';
import 'core/version/app_version.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appVersion = await const AppVersionGateway().load();
  final dependencies = await AppDependencies.create();
  runApp(
    ChecklistApp(
      dependencies: dependencies,
      appVersion: appVersion,
      showLaunchAnimation: true,
    ),
  );
}
