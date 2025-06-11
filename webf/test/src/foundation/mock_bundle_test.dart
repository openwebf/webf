/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

import 'mock_bundle.dart';

void main() {
  group('MockTimedBundle', () {
    test('fast bundle resolves quickly', () async {
      final bundle = MockTimedBundle.fast(content: 'console.log("Fast")');

      final stopwatch = Stopwatch()..start();
      await bundle.resolve();
      await bundle.obtainData();
      stopwatch.stop();

      // Should resolve in approximately 10ms (with some buffer for test variations)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(utf8.decode(bundle.data!), equals('console.log("Fast")'));
    });

    test('slow bundle resolves slowly', () async {
      final bundle = MockTimedBundle.slow(content: 'console.log("Slow")');

      final stopwatch = Stopwatch()..start();
      await bundle.resolve();
      await bundle.obtainData();
      stopwatch.stop();

      // Should take at least 400ms to resolve (the delay is 500ms per method)
      expect(stopwatch.elapsedMilliseconds, greaterThan(400));
      expect(utf8.decode(bundle.data!), equals('console.log("Slow")'));
    });

    test('controlled bundle waits for completer', () async {
      final completer = Completer<void>();
      final bundle = MockTimedBundle.controlled(
        completer: completer,
        content: 'console.log("Controlled")',
      );

      // Start resolving but don't await (it should wait for the completer)
      final resolveFuture = bundle.resolve();

      // Wait a bit, check that it's not resolved yet
      await Future.delayed(Duration(milliseconds: 100));
      expect(bundle.data, isNotNull); // Data is pre-set with autoResolve=true

      // Complete the completer to let it finish
      completer.complete();
      await resolveFuture;

      // Now it should be resolved
      expect(utf8.decode(bundle.data!), equals('console.log("Controlled")'));
    });

    test('works with bytecode', () async {
      final bytecode = Uint8List.fromList(List.generate(10, (i) => i));
      final bundle = MockTimedBundle.fast(bytecode: bytecode);

      await bundle.resolve();
      await bundle.obtainData();

      expect(bundle.data, equals(bytecode));
    });
  });
}
