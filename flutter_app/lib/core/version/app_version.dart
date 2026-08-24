import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppVersionInfo {
  const AppVersionInfo({required this.versionName, required this.versionCode});

  final String versionName;
  final String versionCode;

  String get compactLabel => '$versionName · $versionCode';
}

class AppVersionGateway {
  const AppVersionGateway();

  static const _channel = MethodChannel('fr.checklistvoyage.app/app_info');

  Future<AppVersionInfo> load() async {
    final data = await _channel.invokeMapMethod<String, Object?>('getVersion');
    final versionName = data?['versionName'];
    final versionCode = data?['versionCode'];
    if (versionName is! String ||
        versionName.isEmpty ||
        versionCode is! String ||
        versionCode.isEmpty) {
      throw const FormatException('Métadonnées de version Android invalides.');
    }
    return AppVersionInfo(versionName: versionName, versionCode: versionCode);
  }
}

class AppVersionScope extends InheritedWidget {
  const AppVersionScope({super.key, required this.info, required super.child});

  final AppVersionInfo? info;

  static AppVersionInfo? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppVersionScope>()?.info;

  @override
  bool updateShouldNotify(AppVersionScope oldWidget) => info != oldWidget.info;
}

class VersionedTitle extends StatelessWidget {
  const VersionedTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final version = AppVersionScope.maybeOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (version != null) ...[
          const SizedBox(width: 8),
          Text(
            version.compactLabel,
            key: const Key('installed-app-version'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
