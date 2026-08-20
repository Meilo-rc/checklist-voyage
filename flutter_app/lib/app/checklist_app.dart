import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/home_shell.dart';
import 'app_dependencies.dart';

class ChecklistApp extends StatelessWidget {
  const ChecklistApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist Voyage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: HomeShell(dependencies: dependencies),
    );
  }
}
