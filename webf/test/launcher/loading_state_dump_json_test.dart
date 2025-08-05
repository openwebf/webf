/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/launcher.dart';

void main() {
  group('LoadingStateDump toJSON', () {
    test('should export loading state to JSON format', () {
      final dumper = LoadingState();

      // Record some phases
      dumper.recordPhase(LoadingState.phaseConstructor);
      dumper.recordPhase(LoadingState.phaseInit);
      dumper.recordPhase(LoadingState.phaseFirstPaint);
      dumper.recordPhase(LoadingState.phaseFirstContentfulPaint);
      dumper.recordPhase(LoadingState.phaseLargestContentfulPaint, parameters: {
        'isFinal': true,
        'timeSinceNavigationStart': 1500,
        'elementTag': 'IMG',
        'largestContentSize': 50000,
      });

      // Get the dump
      final dump = dumper.dump();
      final json = dump.toJson();

      // Verify summary
      expect(json['summary'], isNotNull);
      expect(json['summary']['totalPhases'], equals(5));
      expect(json['summary']['totalErrors'], equals(0));
      expect(json['summary']['hasReachedFP'], isTrue);
      expect(json['summary']['hasReachedFCP'], isTrue);
      expect(json['summary']['hasReachedLCP'], isTrue);
      expect(json['summary']['hasLCPFinalized'], isTrue);
      expect(json['summary']['lcpElementTag'], equals('IMG'));
      expect(json['summary']['lcpContentSize'], equals(50000));

      // Verify network stats in summary
      expect(json['summary']['totalNetworkRequests'], equals(0));

      // Verify script stats in summary
      expect(json['summary']['totalScripts'], equals(0));

      // Verify phases array
      expect(json['phases'], isA<List>());
      expect(json['phases'].length, equals(5));
      expect(json['phases'][0]['name'], equals(LoadingState.phaseConstructor));
      expect(json['phases'][0]['timestamp'], isA<String>());
      expect(json['phases'][0]['elapsed'], equals(0));

      // Verify arrays exist
      expect(json['networkRequests'], isA<List>());
      expect(json['scriptElements'], isA<List>());
      expect(json['errors'], isA<List>());
    });

    test('should handle errors in JSON export', () {
      final dumper = LoadingState();

      // Record an error
      dumper.recordError('init', Exception('Test error'), stackTrace: StackTrace.current);

      final dump = dumper.dump();
      final json = dump.toJson();

      expect(json['summary']['totalErrors'], equals(1));
      expect(json['errors'].length, equals(1));
      expect(json['errors'][0]['phase'], equals('init'));
      expect(json['errors'][0]['error'], contains('Test error'));
      expect(json['errors'][0]['timestamp'], isA<String>());
    });

    test('should include all data types in JSON export', () {
      final dumper = LoadingState();

      // Record multiple types of data
      dumper.recordPhase(LoadingState.phaseInit);
      dumper.recordPhaseStart('network');
      dumper.recordPhase('network.complete', parameters: {'duration': 100});

      final dump = dumper.dump();
      final json = dump.toJson();

      // Verify structure
      expect(json, isA<Map<String, dynamic>>());
      expect(json.keys, containsAll(['startTime', 'totalDuration', 'summary', 'phases', 'networkRequests', 'scriptElements', 'errors']));

      // Verify summary has all expected fields
      final summary = json['summary'] as Map<String, dynamic>;
      expect(summary.keys, containsAll(['totalPhases', 'totalNetworkRequests', 'totalErrors', 'totalScripts',
                                       'hasReachedFP', 'hasReachedFCP', 'hasReachedLCP', 'hasLCPFinalized']));

      // Verify phases includes our custom phases
      final phases = json['phases'] as List;
      expect(phases.length, greaterThan(0));
      expect(phases.any((p) => p['name'] == LoadingState.phaseInit), isTrue);

      // recordPhaseStart creates a phase with .start suffix
      expect(phases.any((p) => p['name'] == 'network.start'), isTrue);
    });
  });
}
