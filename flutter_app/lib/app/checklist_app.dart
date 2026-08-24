import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/version/app_version.dart';
import '../features/home/home_shell.dart';
import 'app_dependencies.dart';

class ChecklistApp extends StatelessWidget {
  const ChecklistApp({super.key, required this.dependencies, this.appVersion});

  final AppDependencies dependencies;
  final AppVersionInfo? appVersion;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist Voyage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: AppVersionScope(
        info: appVersion,
        child: HomeShell(dependencies: dependencies),
      ),
    );
  }
}
