// ignore_for_file: avoid_print

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import '../../setup.dart';

void main() {
  setupTest();
  
  group('LoadingState Simple Fetch Test', () {
    test('direct call to recordNetworkRequestError should trigger callbacks', () async {
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );
      
      bool errorTriggered = false;
      
      controller.loadingState.onAnyLoadingError((event) {
        errorTriggered = true;
        print('Error triggered: ${event.type}, ${event.url}');
      });
      
      await controller.controlledInitCompleter.future;
      
      // Directly call the error recording method
      controller.loadingState.recordNetworkRequestError(
        'http://test.com/api',
        'Test error',
        isXHR: true
      );
      
      expect(errorTriggered, isTrue);
      
      controller.dispose();
    });
  });
}
