import 'package:flutter/material.dart';

import 'app/app_dependencies.dart';
import 'app/checklist_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(ChecklistApp(dependencies: dependencies));
}
