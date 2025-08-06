/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/launcher.dart';

void main() {
  group('LoadingStateDumper', () {
    late LoadingState dumper;

    setUp(() {
      dumper = LoadingState();
    });

    test('should record phases with timestamps', () {
      // Record some phases
      dumper.recordPhase('test-phase-1', parameters: {'key': 'value1'});
      dumper.recordPhase('test-phase-2', parameters: {'key': 'value2'});

      // Verify phases were recorded
      expect(dumper.phases.length, 2);
      expect(dumper.phases[0].name, 'test-phase-1');
      expect(dumper.phases[0].parameters['key'], 'value1');
      expect(dumper.phases[1].name, 'test-phase-2');
      expect(dumper.phases[1].parameters['key'], 'value2');
    });

    test('should calculate duration between phases', () async {
      dumper.recordPhase('phase1');

      // Add a small delay
      await Future.delayed(Duration(milliseconds: 10));

      dumper.recordPhase('phase2');

      // The second phase should have a duration
      expect(dumper.phases[1].duration, isNotNull);
      expect(dumper.phases[1].duration!.inMilliseconds, greaterThanOrEqualTo(10));
    });

    test('should format dump output correctly', () {
      dumper.recordPhase(LoadingState.phaseConstructor, parameters: {
        'bundle': 'test.html',
        'enableDebug': true,
      });
      dumper.recordPhase(LoadingState.phaseInit);
      dumper.recordPhase(LoadingState.phaseLoadStart);

      final output = dumper.dump().toString();

      // Check that output contains expected sections
      expect(output, contains('WebFController Loading State Dump'));
      expect(output, contains('Total Duration:'));
      expect(output, contains('Phases: 3'));
      expect(output, contains('Loading Phases:'));
      expect(output, contains('Constructor'));
      expect(output, contains('Initialize'));
      expect(output, contains('Load Start'));
    });

    test('should show phases correctly', () {
      dumper.recordPhase('test-phase', parameters: {
        'param1': 'value1',
        'param2': 42,
      });

      final output = dumper.dump().toString();

      // Phase should appear in the output
      expect(output, contains('test-phase'));
      expect(output, contains('Loading Phases:'));
    });

    test('should handle phase start/end recording', () async {
      final endCallback = dumper.recordPhaseStart('async-operation', parameters: {
        'input': 'test',
      });

      await Future.delayed(Duration(milliseconds: 20));

      endCallback();

      // Should have recorded both start and end phases
      expect(dumper.phases.length, 2);
      expect(dumper.phases[0].name, 'async-operation.start');
      expect(dumper.phases[1].name, 'async-operation.end');

      // End phase should include duration
      expect(dumper.phases[1].parameters['duration'], isNotNull);
      expect(dumper.phases[1].parameters['duration'] as int, greaterThanOrEqualTo(20));
    });

    test('should calculate total duration correctly', () async {
      dumper.recordPhase('start');
      await Future.delayed(Duration(milliseconds: 50));
      dumper.recordPhase('end');

      final totalDuration = dumper.totalDuration;
      expect(totalDuration, isNotNull);
      expect(totalDuration!.inMilliseconds, greaterThanOrEqualTo(50));
    });

    test('should reset dumper state', () {
      dumper.recordPhase('phase1');
      dumper.recordPhase('phase2');

      expect(dumper.phases.length, 2);

      dumper.reset();

      expect(dumper.phases.length, 0);
      expect(dumper.totalDuration, isNull);
    });

    test('should show visual timeline for key phases', () {
      // Record some key phases
      dumper.recordPhase(LoadingState.phaseInit);
      dumper.recordPhase(LoadingState.phaseLoadStart);
      dumper.recordPhase(LoadingState.phaseParseHTML);
      dumper.recordPhase(LoadingState.phaseEvaluateScripts);
      dumper.recordPhase(LoadingState.phaseDOMContentLoaded);
      dumper.recordPhase(LoadingState.phaseFirstPaint);
      dumper.recordPhase(LoadingState.phaseWindowLoad);

      final output = dumper.dump().toString();

      // Check that the loading phases table is shown
      expect(output, contains('Loading Phases:'));
      expect(output, contains('┌─────────────────────────────────┬──────────────┬──────────┬────────────┐'));
      expect(output, contains('│ Phase')); // Table headers
    });

    test('should handle empty phases gracefully', () {
      final output = dumper.dump().toString();
      expect(output, equals('No loading phases recorded'));
    });

    test('should format durations correctly', () {
      // Test milliseconds formatting
      dumper.recordPhase('phase1');
      final output1 = dumper.dump().toString();
      expect(RegExp(r'\d+ms').hasMatch(output1), isTrue);

      // For testing seconds/minutes formatting, we'd need to mock the duration
      // but this at least tests the basic millisecond case
    });

    test('should track network requests', () {
      // Record a network request
      dumper.recordNetworkRequestStart('https://example.com/api/data', method: 'GET');

      // Verify network request is tracked
      expect(dumper.networkRequests.length, 1);
      expect(dumper.networkRequests[0].url, 'https://example.com/api/data');
      expect(dumper.networkRequests[0].method, 'GET');
      expect(dumper.networkRequests[0].isComplete, false);

      // Complete the request
      dumper.recordNetworkRequestComplete(
        'https://example.com/api/data',
        statusCode: 200,
        responseSize: 1024,
        contentType: 'application/json',
      );

      // Verify completion
      expect(dumper.networkRequests[0].isComplete, true);
      expect(dumper.networkRequests[0].statusCode, 200);
      expect(dumper.networkRequests[0].responseSize, 1024);
      expect(dumper.networkRequests[0].isSuccessful, true);
    });

    test('should track network request errors', () {
      dumper.recordNetworkRequestStart('https://example.com/api/error');
      dumper.recordNetworkRequestError('https://example.com/api/error', 'Connection timeout');

      final request = dumper.networkRequests[0];
      expect(request.isComplete, true);
      expect(request.error, 'Connection timeout');
      expect(request.isSuccessful, false);
    });

    test('should include network statistics in dump', () {
      // Add some network requests
      dumper.recordNetworkRequestStart('https://example.com/api/1');
      dumper.recordNetworkRequestComplete('https://example.com/api/1',
        statusCode: 200, responseSize: 2048);

      dumper.recordNetworkRequestStart('https://example.com/api/2');
      dumper.recordNetworkRequestComplete('https://example.com/api/2',
        statusCode: 404, responseSize: 512);

      dumper.recordNetworkRequestStart('https://example.com/api/3');
      dumper.recordNetworkRequestError('https://example.com/api/3', 'Network error');

      // Add a phase to have something in the timeline
      dumper.recordPhase('test-phase');

      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();

      // Check network statistics in header
      expect(output, contains('Network Requests: 3'));
      expect(output, contains('Total Downloaded:'));
      expect(output, contains('Total Network Time:'));

      // Check individual requests are shown
      expect(output, contains('https://example.com/api/1'));
      expect(output, contains('200'));
      expect(output, contains('404'));
      expect(output, contains('ERROR'));
    });

    test('should format bytes correctly', () {
      dumper.recordNetworkRequestStart('https://example.com/small');
      dumper.recordNetworkRequestComplete('https://example.com/small', responseSize: 512);

      dumper.recordNetworkRequestStart('https://example.com/medium');
      dumper.recordNetworkRequestComplete('https://example.com/medium', responseSize: 2048);

      dumper.recordNetworkRequestStart('https://example.com/large');
      dumper.recordNetworkRequestComplete('https://example.com/large', responseSize: 2097152); // 2MB

      dumper.recordPhase('test');
      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();

      expect(output, contains('512B'));
      expect(output, contains('2.0KB'));
      expect(output, contains('2.0MB'));
    });

    test('should track buildRootView phase', () {
      // Record some phases including buildRootView
      dumper.recordPhase(LoadingState.phaseInit);
      dumper.recordPhase(LoadingState.phaseDOMContentLoaded);
      dumper.recordPhase(LoadingState.phaseBuildRootView, parameters: {
        'initialRoute': '/home',
        'hasHybridRoute': true,
      });
      dumper.recordPhase(LoadingState.phaseWindowLoad);

      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();

      // Check that buildRootView is recorded
      expect(output, contains('buildRootView'));

      // In verbose mode, check parameters
      expect(output, contains('initialRoute: /home'));
      expect(output, contains('hasHybridRoute: true'));

      // Check visual timeline includes buildRootView
      expect(output, contains('Visual Timeline:'));
      final phases = dumper.phases;
      expect(phases.any((p) => p.name == LoadingState.phaseBuildRootView), isTrue);
    });

    test('should track errors during loading', () {
      // Record some phases
      dumper.recordPhase(LoadingState.phaseInit);
      dumper.recordPhase(LoadingState.phaseResolveEntrypoint);

      // Record an error
      dumper.recordError(
        LoadingState.phaseResolveEntrypoint,
        Exception('Failed to resolve bundle'),
        context: {
          'bundle': 'https://example.com/app.js',
          'errorType': 'NetworkError',
        }
      );

      // Continue with more phases
      dumper.recordPhase(LoadingState.phaseEvaluateStart);

      // Check error tracking
      expect(dumper.hasErrors, isTrue);
      expect(dumper.errors.length, 1);
      expect(dumper.errors[0].phase, LoadingState.phaseResolveEntrypoint);
      expect(dumper.errors[0].error.toString(), contains('Failed to resolve bundle'));

      // Check dump output
      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();
      expect(output, contains('⚠️  Errors: 1'));
      expect(output, contains('⚠️  Errors and Exceptions:'));
      expect(output, contains('ERROR at'));
      expect(output, contains('Failed to resolve bundle'));
    });

    test('should track multiple errors', () {
      dumper.recordPhase(LoadingState.phaseInit);

      // Record multiple errors
      dumper.recordError(
        LoadingState.phaseResolveEntrypoint,
        Exception('Network timeout'),
      );

      dumper.recordError(
        LoadingState.phaseEvaluateScripts,
        'Script evaluation failed',
      );

      dumper.recordCurrentPhaseError(
        Exception('Unexpected error'),
        context: {'detail': 'some context'},
      );

      expect(dumper.errors.length, 3);
      expect(dumper.hasErrors, isTrue);

      final output = dumper.dump().toString();
      expect(output, contains('⚠️  Errors: 3'));
    });

    test('should include stack trace in verbose mode', () {
      dumper.recordPhase(LoadingState.phaseInit);

      // Create a stack trace
      try {
        throw Exception('Test error');
      } catch (e, stack) {
        dumper.recordError(
          LoadingState.phaseInit,
          e,
          stackTrace: stack,
        );
      }

      final verboseOutput = dumper.dump(options: LoadingStateDumpOptions.full).toString();
      final normalOutput = dumper.dump().toString();

      // Stack trace should only appear in verbose mode
      expect(verboseOutput, contains('Stack trace:'));
      expect(normalOutput, isNot(contains('Stack trace:')));
    });

    test('should reset errors when reset is called', () {
      dumper.recordPhase(LoadingState.phaseInit);
      dumper.recordError(LoadingState.phaseInit, Exception('Error'));

      expect(dumper.hasErrors, isTrue);

      dumper.reset();

      expect(dumper.hasErrors, isFalse);
      expect(dumper.errors.length, 0);
    });

    test('should track parseHTML phase with duration', () async {
      final endCallback = dumper.recordPhaseStart(LoadingState.phaseParseHTML, parameters: {
        'dataSize': 1024,
      });

      await Future.delayed(Duration(milliseconds: 50));

      endCallback();

      expect(dumper.phases.length, 2);
      expect(dumper.phases[0].name, '${LoadingState.phaseParseHTML}.start');
      expect(dumper.phases[1].name, '${LoadingState.phaseParseHTML}.end');
      expect(dumper.phases[1].parameters['duration'], greaterThanOrEqualTo(50));

      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();
      expect(output, contains('parseHTML'));
    });

    test('should track evaluateScripts phase with parameters', () async {
      final endCallback = dumper.recordPhaseStart(LoadingState.phaseEvaluateScripts, parameters: {
        'url': 'https://example.com/script.js',
        'loadedFromCache': true,
        'dataSize': 2048,
      });

      await Future.delayed(Duration(milliseconds: 30));

      endCallback();

      expect(dumper.phases.length, 2);
      expect(dumper.phases[0].name, '${LoadingState.phaseEvaluateScripts}.start');
      expect(dumper.phases[1].name, '${LoadingState.phaseEvaluateScripts}.end');

      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();
      expect(output, contains('evaluateScripts'));
    });

    test('should track bytecode evaluation', () async {
      final endCallback = dumper.recordPhaseStart(LoadingState.phaseEvaluateScripts, parameters: {
        'type': 'bytecode',
        'dataSize': 4096,
      });

      await Future.delayed(Duration(milliseconds: 20));

      endCallback();

      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();
      expect(output, contains('evaluateScripts'));
    });

    test('should track script element loading', () {
      // Queue a script
      final script = dumper.recordScriptElementQueue(
        source: 'https://example.com/script.js',
        isInline: false,
        isModule: false,
        isAsync: true,
        isDefer: false,
      );

      // Verify script was recorded
      expect(dumper.scriptElements.length, 1);
      expect(dumper.scriptElements[0].source, 'https://example.com/script.js');
      expect(dumper.scriptElements[0].isAsync, true);
      expect(dumper.scriptElements[0].readyState, 'loading');

      // Record loading start
      dumper.recordScriptElementLoadStart('https://example.com/script.js');
      expect(dumper.scriptElements[0].readyState, 'interactive');

      // Record loading complete
      dumper.recordScriptElementLoadComplete('https://example.com/script.js', dataSize: 2048);
      expect(dumper.scriptElements[0].dataSize, 2048);

      // Record execution start
      dumper.recordScriptElementExecuteStart('https://example.com/script.js');

      // Record execution complete
      dumper.recordScriptElementExecuteComplete('https://example.com/script.js');
      expect(dumper.scriptElements[0].readyState, 'complete');
      expect(dumper.scriptElements[0].isComplete, true);
      expect(dumper.scriptElements[0].isSuccessful, true);
    });

    test('should track script element errors', () {
      // Queue a script
      dumper.recordScriptElementQueue(
        source: 'https://example.com/error.js',
        isInline: false,
        isModule: false,
        isAsync: false,
        isDefer: false,
      );

      // Record loading start
      dumper.recordScriptElementLoadStart('https://example.com/error.js');

      // Record error
      dumper.recordScriptElementError('https://example.com/error.js', 'Network timeout');

      expect(dumper.scriptElements[0].error, 'Network timeout');
      expect(dumper.scriptElements[0].readyState, 'error');
      expect(dumper.scriptElements[0].isComplete, true);
      expect(dumper.scriptElements[0].isSuccessful, false);
    });

    test('should track inline scripts', () {
      // Queue an inline script
      dumper.recordScriptElementQueue(
        source: '<inline>',
        isInline: true,
        isModule: false,
        isAsync: false,
        isDefer: false,
      );

      // Record phases
      dumper.recordScriptElementLoadStart('<inline>');
      dumper.recordScriptElementLoadComplete('<inline>', dataSize: 256);
      dumper.recordScriptElementExecuteStart('<inline>');
      dumper.recordScriptElementExecuteComplete('<inline>');

      expect(dumper.scriptElements[0].isInline, true);
      expect(dumper.scriptElements[0].source, '<inline>');
      expect(dumper.scriptElements[0].isSuccessful, true);
    });

    test('should show script elements in dump', () {
      // Add some phases first
      dumper.recordPhase('test');

      // Add multiple scripts
      dumper.recordScriptElementQueue(
        source: 'https://example.com/app.js',
        isInline: false,
        isModule: false,
        isAsync: true,
        isDefer: false,
      );
      dumper.recordScriptElementLoadComplete('https://example.com/app.js', dataSize: 1024);
      dumper.recordScriptElementExecuteComplete('https://example.com/app.js');

      dumper.recordScriptElementQueue(
        source: '<inline>',
        isInline: true,
        isModule: true,
        isAsync: false,
        isDefer: false,
      );
      dumper.recordScriptElementExecuteComplete('<inline>');

      dumper.recordScriptElementQueue(
        source: 'https://example.com/broken.js',
        isInline: false,
        isModule: false,
        isAsync: false,
        isDefer: true,
      );
      dumper.recordScriptElementError('https://example.com/broken.js', 'Syntax error');

      // Check verbose dump
      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();

      // Check header
      expect(output, contains('Script Elements: 3 (2 successful, 1 failed)'));

      // Check script elements section
      expect(output, contains('Script Elements:'));
      expect(output, contains('app.js'));
      expect(output, contains('module'));
      expect(output, contains('async'));
      expect(output, contains('defer'));
      expect(output, contains('<inline script>'));
      expect(output, contains('ERROR'));
      expect(output, contains('Syntax error'));
    });

    test('should calculate script durations correctly', () async {
      dumper.recordScriptElementQueue(
        source: 'test.js',
        isInline: false,
        isModule: false,
        isAsync: true,
        isDefer: false,
      );

      await Future.delayed(Duration(milliseconds: 10));
      dumper.recordScriptElementLoadStart('test.js');

      await Future.delayed(Duration(milliseconds: 20));
      dumper.recordScriptElementLoadComplete('test.js', dataSize: 512);

      await Future.delayed(Duration(milliseconds: 15));
      dumper.recordScriptElementExecuteStart('test.js');

      await Future.delayed(Duration(milliseconds: 25));
      dumper.recordScriptElementExecuteComplete('test.js');

      final script = dumper.scriptElements[0];
      expect(script.loadDuration, isNotNull);
      expect(script.loadDuration!.inMilliseconds, greaterThanOrEqualTo(20));
      expect(script.executeDuration, isNotNull);
      expect(script.executeDuration!.inMilliseconds, greaterThanOrEqualTo(25));
      expect(script.totalDuration, isNotNull);
      expect(script.totalDuration!.inMilliseconds, greaterThanOrEqualTo(70));
    });

    test('should count script statistics correctly', () {
      // Add successful scripts
      dumper.recordScriptElementQueue(
        source: 'success1.js',
        isInline: false,
        isModule: false,
        isAsync: true,
        isDefer: false,
      );
      dumper.recordScriptElementExecuteComplete('success1.js');

      dumper.recordScriptElementQueue(
        source: 'success2.js',
        isInline: false,
        isModule: false,
        isAsync: false,
        isDefer: false,
      );
      dumper.recordScriptElementExecuteComplete('success2.js');

      // Add failed scripts
      dumper.recordScriptElementQueue(
        source: 'fail1.js',
        isInline: false,
        isModule: false,
        isAsync: false,
        isDefer: false,
      );
      dumper.recordScriptElementError('fail1.js', 'Network error');

      dumper.recordScriptElementQueue(
        source: 'fail2.js',
        isInline: false,
        isModule: false,
        isAsync: false,
        isDefer: false,
      );
      dumper.recordScriptElementError('fail2.js', 'Parse error');

      expect(dumper.scriptElements.length, 4);
      expect(dumper.successfulScriptsCount, 2);
      expect(dumper.failedScriptsCount, 2);
    });

    test('should reset script elements when reset is called', () {
      dumper.recordPhase('test');
      dumper.recordScriptElementQueue(
        source: 'test.js',
        isInline: false,
        isModule: false,
        isAsync: true,
        isDefer: false,
      );

      expect(dumper.scriptElements.length, 1);

      dumper.reset();

      expect(dumper.scriptElements.length, 0);
    });

    test('should display network requests during resolveEntrypoint phase', () {
      // Record resolve entrypoint phases
      dumper.recordPhase('resolveEntrypoint.start');
      
      // Record a network request during resolve
      dumper.recordNetworkRequestStart('https://miracleplus.openwebf.com/', method: 'GET');
      
      // Set cache info
      dumper.recordNetworkRequestCacheInfo(
        'https://miracleplus.openwebf.com/',
        cacheHit: true,
      );
      
      // Complete the network request
      dumper.recordNetworkRequestComplete(
        'https://miracleplus.openwebf.com/',
        statusCode: 200,
        responseSize: 2048,
        contentType: 'text/html',
      );
      
      dumper.recordPhase('resolveEntrypoint.end');
      
      // Get the dump with network details
      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();
      
      // Check that network request is shown under resolveEntrypoint
      expect(output, contains('Resolve Entrypoint End'));
      expect(output, contains('Network requests:'));
      expect(output, contains('URL: https://miracleplus.openwebf.com/'));
      expect(output, contains('Status: CACHED'));
      expect(output, contains('Duration:'));
    });

    test('should show multiple network requests with proper formatting', () {
      // Record resolve entrypoint phases
      dumper.recordPhase('resolveEntrypoint.start');
      
      // Record multiple network requests
      dumper.recordNetworkRequestStart('https://example.com/api/data', method: 'GET');
      dumper.recordNetworkRequestComplete(
        'https://example.com/api/data',
        statusCode: 200,
        responseSize: 1024,
      );
      
      dumper.recordNetworkRequestStart('https://example.com/styles.css', method: 'GET');
      dumper.recordNetworkRequestCacheInfo(
        'https://example.com/styles.css',
        cacheHit: true,
      );
      dumper.recordNetworkRequestComplete(
        'https://example.com/styles.css',
        statusCode: 304,
      );
      
      dumper.recordNetworkRequestStart('https://example.com/script.js', method: 'GET');
      dumper.recordNetworkRequestError('https://example.com/script.js', 'Network timeout');
      
      dumper.recordPhase('resolveEntrypoint.end');
      
      // Get the dump with network details
      final output = dumper.dump(options: LoadingStateDumpOptions.full).toString();
      
      // Check all network requests are displayed
      expect(output, contains('https://example.com/api/data'));
      expect(output, contains('Status: 200 1.0KB'));
      
      expect(output, contains('https://example.com/styles.css'));
      expect(output, contains('Status: CACHED'));
      
      expect(output, contains('https://example.com/script.js'));
      expect(output, contains('Status: ERROR'));
    });

    test('should not show network requests when showNetworkDetails is false', () {
      // Record resolve entrypoint phases
      dumper.recordPhase('resolveEntrypoint.start');
      
      // Record a network request
      dumper.recordNetworkRequestStart('https://example.com/', method: 'GET');
      dumper.recordNetworkRequestComplete('https://example.com/', statusCode: 200);
      
      dumper.recordPhase('resolveEntrypoint.end');
      
      // Get the dump without network details
      final output = dumper.dump(options: LoadingStateDumpOptions()).toString();
      
      // Network requests should not be shown under resolveEntrypoint
      expect(output, contains('Resolve Entrypoint End'));
      expect(output, isNot(contains('Network requests:')));
      // Note: Network requests still appear in Additional Phases as network phases
      // The showNetworkDetails flag only controls whether they appear under resolveEntrypoint
    });
  });
}
