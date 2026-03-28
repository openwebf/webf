import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  final int startMicros =
      (await driver.serviceClient.getVMTimelineMicros()).timestamp!;

  late final Map<String, dynamic> response;
  try {
    final String jsonResult = await driver.requestData(
      null,
      timeout: const Duration(minutes: 20),
    );
    response = (json.decode(jsonResult) as Map<Object?, Object?>)
        .cast<String, dynamic>();
  } finally {
    // Keep the VM service connection alive until after any host-side CPU
    // samples are collected below.
  }

  final int endMicros =
      (await driver.serviceClient.getVMTimelineMicros()).timestamp!;
  final Map<String, dynamic>? responseData =
      (response['data'] as Map<Object?, Object?>?)?.cast<String, dynamic>();

  if (responseData != null) {
    await _materializeDriverCpuSamples(
      driver,
      responseData,
      startMicros: startMicros,
      endMicros: endMicros,
    );
    await _writeResponseData(responseData);
  }

  await driver.close();

  final bool allTestsPassed = response['result'] == 'true';
  if (allTestsPassed) {
    stdout.writeln('All tests passed.');
    exit(0);
  }

  final List<dynamic> failureDetails =
      (response['failureDetails'] as List<dynamic>? ?? <dynamic>[]);
  if (failureDetails.isNotEmpty) {
    stdout.writeln('Failure Details:');
    for (final dynamic failure in failureDetails) {
      stdout.writeln(json.decode(failure as String)['details']);
    }
  }
  exit(1);
}

Future<void> _materializeDriverCpuSamples(
  FlutterDriver driver,
  Map<String, dynamic> responseData, {
  required int startMicros,
  required int endMicros,
}) async {
  final List<MapEntry<String, Map<String, dynamic>>> pendingCpuCaptures =
      responseData.entries
          .where((MapEntry<String, dynamic> entry) {
            return entry.key.endsWith('_cpu_samples') &&
                entry.value is Map<String, dynamic> &&
                (entry.value as Map<String, dynamic>)['captureMode'] ==
                    'driver';
          })
          .map((MapEntry<String, dynamic> entry) => MapEntry<String, Map<String,
                  dynamic>>(
                entry.key,
                Map<String, dynamic>.from(entry.value as Map<String, dynamic>),
              ))
          .toList();

  if (pendingCpuCaptures.isEmpty) {
    return;
  }

  final int fallbackTimeExtentMicros =
      endMicros > startMicros ? endMicros - startMicros : 1;

  for (final MapEntry<String, Map<String, dynamic>> pendingCpuCapture
      in pendingCpuCaptures) {
    final int captureStartMicros =
        pendingCpuCapture.value['timeOriginMicros'] as int? ?? startMicros;
    final int captureTimeExtentMicros =
        pendingCpuCapture.value['timeExtentMicros'] as int? ??
            fallbackTimeExtentMicros;
    final Map<String, dynamic> allSamples = (await driver.serviceClient
            .getCpuSamples(
              driver.appIsolate.id!,
              captureStartMicros,
              captureTimeExtentMicros,
            ))
        .toJson();
    final List<dynamic> allSampleEntries =
        (allSamples['samples'] as List<dynamic>? ?? <dynamic>[]);
    final String profileLabel =
        pendingCpuCapture.value['profileLabel'] as String? ?? '';
    final List<dynamic> filteredSamples = allSampleEntries
        .where((dynamic sample) =>
            sample is Map<String, dynamic> &&
            sample['userTag'] == profileLabel)
        .toList();

    final Map<String, dynamic> filteredCpuSamples =
        Map<String, dynamic>.from(allSamples);
    filteredCpuSamples['sampleCount'] = filteredSamples.length;
    filteredCpuSamples['timeOriginMicros'] = captureStartMicros;
    filteredCpuSamples['timeExtentMicros'] = captureTimeExtentMicros;
    filteredCpuSamples['samples'] = filteredSamples;

    responseData[pendingCpuCapture.key] = <String, dynamic>{
      'profileLabel': profileLabel,
      'isolateId': driver.appIsolate.id,
      'timeOriginMicros': captureStartMicros,
      'timeExtentMicros': captureTimeExtentMicros,
      'samples': filteredCpuSamples,
    };
  }
}

Future<void> _writeResponseData(Map<String, dynamic> data) async {
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
    if ((entry.key.endsWith('_timeline') ||
            entry.key.endsWith('_cpu_samples')) &&
        entry.value is Map) {
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
