import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  await integrationDriver(
    responseDataCallback: (Map<String, dynamic>? data) async {
      if (data == null) {
        return;
      }

      final Directory outputDirectory = Directory(
        path.join(Directory.current.path, 'build', 'profile_hotspots'),
      )..createSync(recursive: true);

      final Map<String, dynamic> response = Map<String, dynamic>.from(data);
      final Map<String, dynamic> manifest = <String, dynamic>{};

      await _writeJson(
        outputDirectory,
        response,
        testOutputFilename: 'all_cases',
      );

      for (final MapEntry<String, dynamic> entry in response.entries) {
        if (entry.key.endsWith('_timeline') && entry.value is Map) {
          await _writeJson(
            outputDirectory,
            Map<String, dynamic>.from(entry.value as Map),
            testOutputFilename: entry.key,
          );
          manifest[entry.key] = <String, dynamic>{
            'path': path.join(outputDirectory.path, '${entry.key}.json'),
          };
        } else {
          manifest[entry.key] = entry.value;
        }
      }

      await _writeJson(
        outputDirectory,
        manifest,
        testOutputFilename: 'manifest',
      );
    },
  );
}

Future<void> _writeJson(
  Directory outputDirectory,
  Object data, {
  required String testOutputFilename,
}) async {
  final File file = File(
    path.join(outputDirectory.path, '$testOutputFilename.json'),
  );
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(data),
  );
}
