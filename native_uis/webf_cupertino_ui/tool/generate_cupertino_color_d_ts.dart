import 'dart:convert';
import 'dart:io';

/// Generates a TypeScript declaration file (lib/src/cupertino_colors.d.ts) that
/// contains a single enum `CupertinoColors` mapping color names to CSS rgba()
/// string literals.
///
/// Usage:
///   dart run tool/generate_cupertino_color_d_ts.dart
///     - Discovers Flutter SDK via `flutter` in PATH and reads
///       packages/flutter/lib/src/cupertino/colors.dart
///     - Writes lib/src/cupertino_colors.d.ts
///
///   dart run tool/generate_cupertino_color_d_ts.dart `<path/to/colors.dart>` [output.d.ts]
Future<void> main(List<String> args) async {
  // Resolve input path: prefer CLI arg; otherwise discover via flutter in PATH.
  String inputPath;
  if (args.isNotEmpty) {
    inputPath = args[0];
  } else {
    final sdkRoot = await _findFlutterSdkRoot();
    if (sdkRoot == null) {
      stderr.writeln('Unable to locate Flutter SDK via PATH or FLUTTER_ROOT.');
      stderr.writeln('Pass the path to colors.dart explicitly as the first argument.');
      exitCode = 2;
      return;
    }
    inputPath =
        File('$sdkRoot/packages/flutter/lib/src/cupertino/colors.dart').path;
  }

  // Default output path inside this package.
  final outputPath = args.length > 1 ? args[1] : 'lib/src/cupertino_colors.d.ts';

  final file = File(inputPath);
  if (!await file.exists()) {
    stderr.writeln('Input file not found: $inputPath');
    exitCode = 2;
    return;
  }

  final content = await file.readAsString();

  // Gather color values.
  final Map<String, String> colorCss = <String, String>{};
  // Track aliases like `activeBlue = systemBlue;` for later resolution.
  final Map<String, String> dynamicAliases = <String, String>{};

  // 1) Parse static `Color` constants like:
  //    static const Color white = Color(0xFFFFFFFF);
  final staticColorHex = RegExp(
    r'static\s+const\s+Color\s+(\w+)\s*=\s*Color\((0x[0-9A-Fa-f]{8})\)\s*;',
    multiLine: true,
  );
  for (final m in staticColorHex.allMatches(content)) {
    final name = m.group(1)!;
    final rgba = _rgbaFrom0xAARRGGBB(m.group(2)!);
    colorCss[name] = rgba;
  }

  // 2) Parse static Color.fromARGB like:
  //    static const Color name = Color.fromARGB(255, r, g, b);
  final staticFromARGB = RegExp(
    r'static\s+const\s+Color\s+(\w+)\s*=\s*Color\.fromARGB\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\s*;',
    multiLine: true,
  );
  for (final m in staticFromARGB.allMatches(content)) {
    final name = m.group(1)!;
    final a = int.parse(m.group(2)!);
    final r = int.parse(m.group(3)!);
    final g = int.parse(m.group(4)!);
    final b = int.parse(m.group(5)!);
    colorCss[name] = _rgbaFromARGB(a, r, g, b);
  }

  // 3) Parse static Color.fromRGBO like:
  //    static const Color name = Color.fromRGBO(255, 255, 255, 1.0);
  final staticFromRGBO = RegExp(
    r'static\s+const\s+Color\s+(\w+)\s*=\s*Color\.fromRGBO\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*\)\s*;',
    multiLine: true,
  );
  for (final m in staticFromRGBO.allMatches(content)) {
    final name = m.group(1)!;
    final r = int.parse(m.group(2)!);
    final g = int.parse(m.group(3)!);
    final b = int.parse(m.group(4)!);
    final opacity = _formatAlphaFraction(m.group(5)!);
    colorCss[name] = 'rgba($r, $g, $b, $opacity)';
  }

  // 4) Parse dynamic colors defined via CupertinoDynamicColor.with... with a `color:` property.
  final dynamicBlock = RegExp(
    r'static\s+const\s+CupertinoDynamicColor\s+(\w+)\s*=\s*CupertinoDynamicColor\.[^(]+\((.*?)\);',
    multiLine: true,
    dotAll: true,
  );
  for (final m in dynamicBlock.allMatches(content)) {
    final name = m.group(1)!;
    final block = m.group(2)!;
    final colorArg = _parseColorArg(block);
    if (colorArg != null) {
      colorCss[name] = colorArg;
    }
  }

  // 4b) Parse dynamic colors defined via plain CupertinoDynamicColor(...)
  final dynamicPlainBlock = RegExp(
    r'static\s+const\s+CupertinoDynamicColor\s+(\w+)\s*=\s*CupertinoDynamicColor\s*\((.*?)\);',
    multiLine: true,
    dotAll: true,
  );
  for (final m in dynamicPlainBlock.allMatches(content)) {
    final name = m.group(1)!;
    final block = m.group(2)!;
    final colorArg = _parseColorArg(block);
    if (colorArg != null) {
      colorCss[name] = colorArg;
    }
  }

  // 5) Parse aliases like:
  //    static const CupertinoDynamicColor activeBlue = systemBlue;
  final aliasRe = RegExp(
    r'static\s+const\s+CupertinoDynamicColor\s+(\w+)\s*=\s*(\w+)\s*;',
    multiLine: true,
  );
  for (final m in aliasRe.allMatches(content)) {
    final name = m.group(1)!;
    final target = m.group(2)!;
    dynamicAliases[name] = target;
  }

  // Resolve aliases transitively.
  String? resolveAlias(String key, Set<String> seen) {
    if (colorCss.containsKey(key)) return colorCss[key];
    final target = dynamicAliases[key];
    if (target == null) return null;
    if (seen.contains(key)) return null; // cycle guard
    seen.add(key);
    final resolved = resolveAlias(target, seen);
    if (resolved != null) {
      colorCss[key] = resolved;
    }
    return resolved;
  }

  for (final k in dynamicAliases.keys) {
    resolveAlias(k, <String>{});
  }

  // Prepare .d.ts content: define enum with rgba() string values.
  final sortedNames = colorCss.keys.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  final StringBuffer out = StringBuffer();
  out.writeln('// Generated by tool/generate_cupertino_colors_d_ts.dart');
  out.writeln('// Do not edit by hand.');
  out.writeln();
  out.writeln('declare enum CupertinoColors {');
  for (final name in sortedNames) {
    final css = colorCss[name]!;
    out.writeln('  $name = ${jsonEncode(css)},');
  }
  out.writeln('}');
  out.writeln();

  await File(outputPath).writeAsString(out.toString());
  stdout.writeln('Wrote $outputPath with ${sortedNames.length} colors.');
}

String? _parseColorArg(String block) {
  // Try Color(0xAARRGGBB)
  final hexRe = RegExp(r'\bcolor\s*:\s*Color\((0x[0-9A-Fa-f]{8})\)');
  final mHex = hexRe.firstMatch(block);
  if (mHex != null) {
    return _rgbaFrom0xAARRGGBB(mHex.group(1)!);
  }

  // Try Color.fromARGB(a, r, g, b)
  final argbRe = RegExp(r'\bcolor\s*:\s*Color\.fromARGB\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)');
  final mArgb = argbRe.firstMatch(block);
  if (mArgb != null) {
    final a = int.parse(mArgb.group(1)!);
    final r = int.parse(mArgb.group(2)!);
    final g = int.parse(mArgb.group(3)!);
    final b = int.parse(mArgb.group(4)!);
    return _rgbaFromARGB(a, r, g, b);
  }

  // Try Color.fromRGBO(r, g, b, o)
  final rgboRe = RegExp(r'\bcolor\s*:\s*Color\.fromRGBO\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*\)');
  final mRgbo = rgboRe.firstMatch(block);
  if (mRgbo != null) {
    final r = int.parse(mRgbo.group(1)!);
    final g = int.parse(mRgbo.group(2)!);
    final b = int.parse(mRgbo.group(3)!);
    final opacity = _formatAlphaFraction(mRgbo.group(4)!);
    return 'rgba($r, $g, $b, $opacity)';
  }

  return null;
}

String _rgbaFrom0xAARRGGBB(String hex) {
  // input like 0xFFFFFFFF
  final value = int.parse(hex.substring(2), radix: 16);
  final a = (value >> 24) & 0xFF;
  final r = (value >> 16) & 0xFF;
  final g = (value >> 8) & 0xFF;
  final b = value & 0xFF;
  return _rgbaFromARGB(a, r, g, b);
}

String _rgbaFromARGB(int a, int r, int g, int b) {
  a = a.clamp(0, 255);
  r = r.clamp(0, 255);
  g = g.clamp(0, 255);
  b = b.clamp(0, 255);
  final alpha = _formatAlphaFromInt(a);
  return 'rgba($r, $g, $b, $alpha)';
}

String _formatAlphaFraction(String raw) {
  // Normalize alpha in [0,1] to concise string: '1', '0', or up to 3 decimals.
  double v;
  try {
    v = double.parse(raw);
  } catch (_) {
    v = 1.0;
  }
  return _formatAlphaDoubleValue(v);
}

String _formatAlphaFromInt(int a) {
  if (a >= 255) return '1';
  if (a <= 0) return '0';
  final v = a / 255.0;
  return _formatAlphaDoubleValue(v);
}

String _formatAlphaDoubleValue(double v) {
  if (v >= 1.0) return '1';
  if (v <= 0.0) return '0';
  final s = v.toStringAsFixed(3);
  return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

Future<String?> _findFlutterSdkRoot() async {
  // 1) Check FLUTTER_ROOT environment variable.
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null && env.isNotEmpty) {
    final candidate = Directory(env);
    if (await _looksLikeFlutterRoot(candidate)) return candidate.path;
  }

  // 2) Try `which flutter` to locate the binary and ascend to sdk root.
  try {
    final which = await Process.run('which', ['flutter']);
    if (which.exitCode == 0) {
      final p = (which.stdout as String).trim();
      if (p.isNotEmpty) {
        try {
          final resolved = File(p).resolveSymbolicLinksSync();
          final binDir = Directory(resolved).parent;
          final root = binDir.parent; // .../flutter/bin/flutter -> root is parent of bin
          if (await _looksLikeFlutterRoot(root)) return root.path;
        } catch (_) {
          // Fallthrough
        }
      }
    }
  } catch (_) {
    // ignore
  }

  // 3) Try `flutter --version --machine` JSON for flutterRoot (best effort).
  try {
    final proc = await Process.run('flutter', ['--version', '--machine']);
    if (proc.exitCode == 0) {
      final stdoutStr = (proc.stdout as String).trim();
      if (stdoutStr.isNotEmpty) {
        final dynamic jsonObj = json.decode(stdoutStr);
        final root = jsonObj is Map ? jsonObj['flutterRoot'] as String? : null;
        if (root != null) {
          final dir = Directory(root);
          if (await _looksLikeFlutterRoot(dir)) return dir.path;
        }
      }
    }
  } catch (_) {
    // ignore
  }

  return null;
}

Future<bool> _looksLikeFlutterRoot(Directory dir) async {
  try {
    final colors = File(
      '${dir.path}/packages/flutter/lib/src/cupertino/colors.dart',
    );
    return await colors.exists();
  } catch (_) {
    return false;
  }
}
