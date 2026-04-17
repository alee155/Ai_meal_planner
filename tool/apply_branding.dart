import 'dart:io';

class BrandingConfig {
  BrandingConfig({
    required this.appName,
    required this.bundleId,
    required this.iconPath,
    required this.removeAlphaIos,
  });

  final String appName;
  final String bundleId;
  final String iconPath;
  final bool removeAlphaIos;
}

void main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = args.contains('--dry-run') || !apply;
  final generateIcons = args.contains('--generate-icons');

  if (args.contains('--help') || args.contains('-h')) {
    stdout.writeln('Usage: dart run tool/apply_branding.dart [options]');
    stdout.writeln('Options:');
    stdout.writeln('  --apply            Write changes to files');
    stdout.writeln('  --dry-run          Show what would change (default)');
    stdout.writeln('  --generate-icons   Run flutter_launcher_icons after updating pubspec.yaml');
    exitCode = 0;
    return;
  }

  final configFile = File('tool/app_config.yaml');
  if (!configFile.existsSync()) {
    stderr.writeln('Missing config: tool/app_config.yaml');
    exitCode = 2;
    return;
  }

  final config = _parseConfig(configFile.readAsStringSync());
  _validateConfig(config);

  final changes = <String>[];

  // Android: app name (launcher label)
  changes.addAll(_updateAndroidAppName(config, dryRun: dryRun));

  // Android: applicationId/namespace + manifest package (for legacy tooling)
  changes.addAll(_updateAndroidGradleIds(config, dryRun: dryRun));
  changes.addAll(_updateAndroidManifest(config, dryRun: dryRun));

  // Android: native Kotlin package + any hardcoded string identifiers
  changes.addAll(_updateAndroidKotlin(config, dryRun: dryRun));

  // iOS: app name + bundle id
  changes.addAll(_updateIosInfoPlist(config, dryRun: dryRun));
  changes.addAll(_updateIosProjectBundleId(config, dryRun: dryRun));

  // Flutter: method channel name + launcher icon generator config
  changes.addAll(_updateFlutterMethodChannel(config, dryRun: dryRun));
  changes.addAll(_updatePubspecLauncherIcons(config, dryRun: dryRun));

  if (changes.isEmpty) {
    stdout.writeln(dryRun ? 'No changes needed.' : 'No changes applied (already up to date).');
  } else {
    if (dryRun) {
      stdout.writeln('Dry-run: would update:');
      for (final item in changes) {
        stdout.writeln(' - $item');
      }
      stdout.writeln('\nRun with --apply to write changes.');
    } else {
      stdout.writeln('Updated:');
      for (final item in changes) {
        stdout.writeln(' - $item');
      }
    }
  }

  if (!dryRun && generateIcons) {
    await _run(
      'flutter',
      const ['pub', 'run', 'flutter_launcher_icons'],
    );
  }
}

BrandingConfig _parseConfig(String contents) {
  final map = <String, String>{};
  for (final rawLine in contents.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final idx = line.indexOf(':');
    if (idx <= 0) continue;
    final key = line.substring(0, idx).trim();
    var value = line.substring(idx + 1).trim();
    if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
      value = value.substring(1, value.length - 1);
    }
    if (value.startsWith("'") && value.endsWith("'") && value.length >= 2) {
      value = value.substring(1, value.length - 1);
    }
    map[key] = value;
  }

  final appName = map['app_name'] ?? '';
  final bundleId = map['bundle_id'] ?? '';
  final iconPath = map['icon_path'] ?? '';
  final removeAlphaRaw = (map['remove_alpha_ios'] ?? 'true').toLowerCase();
  final removeAlphaIos = removeAlphaRaw == 'true' || removeAlphaRaw == 'yes' || removeAlphaRaw == '1';

  return BrandingConfig(
    appName: appName,
    bundleId: bundleId,
    iconPath: iconPath,
    removeAlphaIos: removeAlphaIos,
  );
}

void _validateConfig(BrandingConfig config) {
  void fail(String message) {
    throw FormatException('tool/app_config.yaml: $message');
  }

  if (config.appName.trim().isEmpty) fail('app_name is required');
  if (config.bundleId.trim().isEmpty) fail('bundle_id is required');
  if (!RegExp(r'^[a-zA-Z0-9]+(\.[a-zA-Z0-9_]+)+$').hasMatch(config.bundleId)) {
    fail('bundle_id looks invalid: ${config.bundleId}');
  }
  if (config.iconPath.trim().isEmpty) fail('icon_path is required');
  if (!File(config.iconPath).existsSync()) {
    fail('icon_path does not exist: ${config.iconPath}');
  }
}

List<String> _updateAndroidAppName(BrandingConfig config, {required bool dryRun}) {
  final file = File('android/app/src/main/res/values/strings.xml');
  if (!file.existsSync()) {
    // Create minimal strings.xml if missing.
    final content = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">${_xmlEscape(config.appName)}</string>
</resources>
''';
    if (!dryRun) {
      file.createSync(recursive: true);
      file.writeAsStringSync(content);
    }
    return ['android/app/src/main/res/values/strings.xml'];
  }

  final before = file.readAsStringSync();
  final updated = before.replaceAllMapped(
    RegExp(r'<string\s+name="app_name">([\s\S]*?)</string>'),
    (m) => '<string name="app_name">${_xmlEscape(config.appName)}</string>',
  );

  if (before == updated) return const [];
  if (!dryRun) file.writeAsStringSync(updated);
  return ['android/app/src/main/res/values/strings.xml'];
}

List<String> _updateAndroidGradleIds(BrandingConfig config, {required bool dryRun}) {
  final file = File('android/app/build.gradle.kts');
  if (!file.existsSync()) return const [];
  final before = file.readAsStringSync();

  var updated = before;
  updated = updated.replaceAllMapped(
    RegExp(r'^\s*namespace\s*=\s*"[^"]*"\s*$', multiLine: true),
    (m) => '    namespace = "${config.bundleId}"',
  );
  updated = updated.replaceAllMapped(
    RegExp(r'^\s*applicationId\s*=\s*"[^"]*"\s*$', multiLine: true),
    (m) => '        applicationId = "${config.bundleId}"',
  );

  if (before == updated) return const [];
  if (!dryRun) file.writeAsStringSync(updated);
  return ['android/app/build.gradle.kts'];
}

List<String> _updateAndroidManifest(BrandingConfig config, {required bool dryRun}) {
  final file = File('android/app/src/main/AndroidManifest.xml');
  if (!file.existsSync()) return const [];
  final before = file.readAsStringSync();

  var updated = before;

  // Ensure manifest has package="..."
  updated = updated.replaceFirstMapped(
    RegExp(r'<manifest\b[^>]*>'),
    (m) {
      final tag = m.group(0)!;
      if (RegExp(r'\bpackage="[^"]*"').hasMatch(tag)) {
        return tag.replaceAll(RegExp(r'\bpackage="[^"]*"'), 'package="${config.bundleId}"');
      }
      // Insert attribute before closing >
      return tag.substring(0, tag.length - 1) + '\n    package="${config.bundleId}">';
    },
  );

  // Ensure label uses @string/app_name
  updated = updated.replaceAll(
    RegExp(r'android:label="[^"]*"'),
    'android:label="@string/app_name"',
  );

  if (before == updated) return const [];
  if (!dryRun) file.writeAsStringSync(updated);
  return ['android/app/src/main/AndroidManifest.xml'];
}

List<String> _updateAndroidKotlin(BrandingConfig config, {required bool dryRun}) {
  final kotlinRoot = Directory('android/app/src/main/kotlin');
  if (!kotlinRoot.existsSync()) return const [];

  String? oldBasePackage;

  File? mainActivityFile;
  for (final entity in kotlinRoot.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('/MainActivity.kt')) {
      mainActivityFile = entity;
      break;
    }
  }

  if (mainActivityFile != null) {
    final content = mainActivityFile.readAsStringSync();
    final pkg = RegExp(r'^\s*package\s+([A-Za-z0-9_\.]+)\s*$', multiLine: true).firstMatch(content);
    oldBasePackage = pkg?.group(1);
  }

  // Fallback: use any .kt file's package as the "old base package".
  if (oldBasePackage == null) {
    File? anyKtFile;
    for (final entity in kotlinRoot.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.kt')) {
        anyKtFile = entity;
        break;
      }
    }
    if (anyKtFile == null) return const [];
    final anyContent = anyKtFile.readAsStringSync();
    final anyPkg =
        RegExp(r'^\s*package\s+([A-Za-z0-9_\.]+)\s*$', multiLine: true).firstMatch(anyContent);
    oldBasePackage = anyPkg?.group(1);
  }

  // If we're already on the desired package, don't touch Kotlin at all.
  if (oldBasePackage != null && oldBasePackage == config.bundleId) {
    return const [];
  }

  final changedFiles = <String>{};

  for (final entity in kotlinRoot.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.kt')) continue;
    final file = entity;
    final before = file.readAsStringSync();
    final pkgMatch =
        RegExp(r'^\s*package\s+([A-Za-z0-9_\.]+)\s*$', multiLine: true).firstMatch(before);
    if (pkgMatch == null) continue;

    final currentPkg = pkgMatch.group(1)!;
    final prefix = oldBasePackage ?? currentPkg;

    // If current package doesn't start with prefix, just do a simple bundleId replace for known identifiers.
    final simpleUpdated = before.replaceAll(prefix, config.bundleId);
    String updated = before;

    if (currentPkg.startsWith(prefix)) {
      final suffix = currentPkg.substring(prefix.length); // includes leading ".widgets" etc (or empty)
      final newPkg = '${config.bundleId}$suffix';
      updated = before.replaceFirst(
        RegExp(r'^\s*package\s+[A-Za-z0-9_\.]+\s*$', multiLine: true),
        'package $newPkg',
      );
      // Also replace hardcoded identifiers that include the old base package.
      updated = updated.replaceAll(prefix, config.bundleId);

      // Move file to new folder structure.
      final newDir = Directory(
        'android/app/src/main/kotlin/${newPkg.replaceAll('.', '/')}',
      );
      final newPath = '${newDir.path}/${file.uri.pathSegments.last}';

      if (!dryRun) {
        newDir.createSync(recursive: true);
        File(newPath).writeAsStringSync(updated);
        if (file.path != newPath) {
          file.deleteSync();
        }
      }
      if (file.path != newPath || before != updated) {
        changedFiles.add(newPath);
      }
      continue;
    }

    // Fallback: at least update any old identifiers found.
    if (before != simpleUpdated) {
      if (!dryRun) file.writeAsStringSync(simpleUpdated);
      changedFiles.add(file.path);
    }
  }

  return changedFiles.toList()..sort();
}

List<String> _updateIosInfoPlist(BrandingConfig config, {required bool dryRun}) {
  final file = File('ios/Runner/Info.plist');
  if (!file.existsSync()) return const [];
  final before = file.readAsStringSync();

  String updated = before;
  updated = _replacePlistStringValue(updated, key: 'CFBundleDisplayName', value: config.appName);
  updated = _replacePlistStringValue(updated, key: 'CFBundleName', value: config.appName);

  if (before == updated) return const [];
  if (!dryRun) file.writeAsStringSync(updated);
  return ['ios/Runner/Info.plist'];
}

List<String> _updateIosProjectBundleId(BrandingConfig config, {required bool dryRun}) {
  final file = File('ios/Runner.xcodeproj/project.pbxproj');
  if (!file.existsSync()) return const [];
  final before = file.readAsStringSync();

  final runnerTestsId = '${config.bundleId}.RunnerTests';
  final updated = before.replaceAllMapped(
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*([^;]+);'),
    (m) {
      final current = m.group(1)!.trim();
      // Keep tests targets in a separate identifier.
      if (current.endsWith('.RunnerTests') || current.contains('RunnerTests')) {
        return 'PRODUCT_BUNDLE_IDENTIFIER = $runnerTestsId;';
      }
      return 'PRODUCT_BUNDLE_IDENTIFIER = ${config.bundleId};';
    },
  );

  if (before == updated) return const [];
  if (!dryRun) file.writeAsStringSync(updated);
  return ['ios/Runner.xcodeproj/project.pbxproj'];
}

List<String> _updateFlutterMethodChannel(BrandingConfig config, {required bool dryRun}) {
  final channel = '${config.bundleId}/alarm';
  final touched = <String>[];

  void updateFile(String path, String from) {
    final file = File(path);
    if (!file.existsSync()) return;
    final before = file.readAsStringSync();
    final updated = before.replaceAll(from, channel);
    if (before == updated) return;
    if (!dryRun) file.writeAsStringSync(updated);
    touched.add(path);
  }

  // We keep backward compat simple: only replace known channel strings if present.
  updateFile('lib/notification_service.dart', 'com.example.ai_meal_planner/alarm');
  updateFile('lib/notification_service.dart', 'com.devsouq.caloriq.app/alarm');
  updateFile('ios/Runner/AppDelegate.swift', 'com.example.ai_meal_planner/alarm');
  updateFile('ios/Runner/AppDelegate.swift', 'com.devsouq.caloriq.app/alarm');

  // MainActivity might move; try both locations.
  updateFile(
    'android/app/src/main/kotlin/${config.bundleId.replaceAll('.', '/')}/MainActivity.kt',
    'com.example.ai_meal_planner/alarm',
  );
  updateFile(
    'android/app/src/main/kotlin/${config.bundleId.replaceAll('.', '/')}/MainActivity.kt',
    'com.devsouq.caloriq.app/alarm',
  );

  // Also update any Kotlin file that contains the old channel string.
  final kotlinRoot = Directory('android/app/src/main/kotlin');
  if (kotlinRoot.existsSync()) {
    for (final entity in kotlinRoot.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.kt')) continue;
      final before = entity.readAsStringSync();
      if (!before.contains('/alarm')) continue;
      final updated = before
          .replaceAll('com.example.ai_meal_planner/alarm', channel)
          .replaceAll('com.devsouq.caloriq.app/alarm', channel);
      if (before == updated) continue;
      if (!dryRun) entity.writeAsStringSync(updated);
      touched.add(entity.path);
    }
  }

  touched.sort();
  return touched;
}

List<String> _updatePubspecLauncherIcons(BrandingConfig config, {required bool dryRun}) {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) return const [];
  final before = file.readAsStringSync();

  // Update image paths in flutter_launcher_icons block if present.
  var updated = before;
  updated = updated.replaceAllMapped(
    RegExp('^[ \\t]*image_path:[ \\t]*[\\\'"][^\\\'"]*[\\\'"][ \\t]*\$', multiLine: true),
    (m) => '  image_path: "${config.iconPath}"',
  );
  updated = updated.replaceAllMapped(
    RegExp(
      '^[ \\t]*adaptive_icon_foreground:[ \\t]*[\\\'"][^\\\'"]*[\\\'"][ \\t]*\$',
      multiLine: true,
    ),
    (m) => '  adaptive_icon_foreground: "${config.iconPath}"',
  );

  if (RegExp(r'^\s*flutter_launcher_icons:\s*$', multiLine: true).hasMatch(updated)) {
    final hasRemoveAlpha =
        RegExp(r'^[ \t]*remove_alpha_ios:[ \t]*(true|false)[ \t]*$', multiLine: true).hasMatch(updated);
    if (hasRemoveAlpha) {
      updated = updated.replaceAllMapped(
        RegExp(r'^[ \t]*remove_alpha_ios:[ \t]*(true|false)[ \t]*$', multiLine: true),
        (m) => '  remove_alpha_ios: ${config.removeAlphaIos}',
      );
    } else {
      // Insert remove_alpha_ios near the end of the flutter_launcher_icons block.
      // Simple heuristic: append at end of file if we can't find a clean insertion point.
      updated = '${updated.trimRight()}\n  remove_alpha_ios: ${config.removeAlphaIos}\n';
    }
  }

  if (!updated.endsWith('\n')) {
    updated = '$updated\n';
  }

  if (before == updated) return const [];
  if (!dryRun) file.writeAsStringSync(updated);
  return ['pubspec.yaml'];
}

String _replacePlistStringValue(String plist, {required String key, required String value}) {
  // Replace:
  // <key>KEY</key>\n <string>...</string>
  final re = RegExp(
    '<key>${RegExp.escape(key)}</key>\\s*\\n\\s*<string>([\\s\\S]*?)</string>',
  );
  if (!re.hasMatch(plist)) return plist;
  return plist.replaceFirstMapped(
    re,
    (m) => '<key>$key</key>\n\t\t<string>${_xmlEscape(value)}</string>',
  );
}

String _xmlEscape(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

Future<void> _run(String executable, List<String> arguments) async {
  stdout.writeln('\nRunning: $executable ${arguments.join(' ')}');
  final result = await Process.run(
    executable,
    arguments,
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    throw ProcessException(executable, arguments, 'Command failed', result.exitCode);
  }
}
