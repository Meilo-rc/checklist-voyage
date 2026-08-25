import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/version/app_version.dart';
import '../features/home/home_shell.dart';
import '../features/launch/launch_animation.dart';
import 'app_dependencies.dart';

class ChecklistApp extends StatelessWidget {
  const ChecklistApp({
    super.key,
    required this.dependencies,
    this.appVersion,
    this.showLaunchAnimation = false,
  });

  final AppDependencies dependencies;
  final AppVersionInfo? appVersion;
  final bool showLaunchAnimation;

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
        child: showLaunchAnimation
            ? LaunchGate(home: HomeShell(dependencies: dependencies))
            : HomeShell(dependencies: dependencies),
      ),
    );
  }
}
