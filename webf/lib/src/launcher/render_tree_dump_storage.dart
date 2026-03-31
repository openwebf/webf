/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'dart:io';

import 'package:path_provider/path_provider.dart';

const int kRenderTreeClipboardSoftLimit = 200 * 1024;

/// Avoid sending very large render-tree dumps through platform clipboard
/// channels, which can hit mobile transaction and string-size limits.
bool shouldPersistRenderTreeDumpToFile(
  String text, {
  int clipboardSoftLimit = kRenderTreeClipboardSoftLimit,
}) {
  return text.length > clipboardSoftLimit;
}

String? buildAndroidRenderTreeDumpPullCommand(String savedFilePath) {
  final String normalizedPath = savedFilePath.replaceAll('\\', '/');
  final RegExpMatch? match = RegExp(
    r'^/data/(?:user/\d+|data)/([^/]+)/app_flutter/WebF_Debug/([^/]+)$',
  ).firstMatch(normalizedPath);
  if (match == null) {
    return null;
  }

  final String packageName = match.group(1)!;
  final String filename = match.group(2)!;
  return 'adb shell run-as $packageName cat app_flutter/WebF_Debug/$filename > $filename';
}

Future<String> writeRenderTreeDumpToFile(
  String renderTree, {
  String? routePath,
  Directory? outputDirectory,
}) async {
  final Directory targetDirectory =
      outputDirectory ?? await _resolveRenderTreeDumpDirectory();
  await targetDirectory.create(recursive: true);

  final String timestamp = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');
  final String sanitizedRoute =
      (routePath == null || routePath.isEmpty ? 'root' : routePath)
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
  final String filename = 'render_tree_${sanitizedRoute}_$timestamp.txt';
  final File file =
      File('${targetDirectory.path}${Platform.pathSeparator}$filename');
  await file.writeAsString(renderTree);
  return file.path;
}

Future<Directory> _resolveRenderTreeDumpDirectory() async {
  Directory? documentsDir;
  if (Platform.isMacOS || Platform.isLinux) {
    final String? home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      documentsDir = Directory('$home/Documents');
    }
  } else if (Platform.isWindows) {
    final String? userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null && userProfile.isNotEmpty) {
      documentsDir = Directory('$userProfile\\Documents');
    }
  }

  documentsDir ??= await getApplicationDocumentsDirectory();
  return Directory('${documentsDir.path}${Platform.pathSeparator}WebF_Debug');
}
