/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/launcher.dart';

void main() {
  group('LoadingState Error Callbacks - Simple Tests', () {
    test('recordEntrypointError should trigger onAnyLoadingError', () {
      final loadingState = LoadingState();
      bool callbackTriggered = false;
      LoadingErrorEvent? capturedEvent;
      
      // Register callback for all errors
      loadingState.onAnyLoadingError((event) {
        callbackTriggered = true;
        capturedEvent = event;
      });
      
      // Record an entrypoint error
      loadingState.recordEntrypointError(
        'https://example.com/app.html',
        'Failed to load application bundle',
        metadata: {'statusCode': 404}
      );
      
      expect(callbackTriggered, isTrue, 
        reason: 'onAnyLoadingError should be triggered for entrypoint errors');
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.type, equals(LoadingErrorType.entrypoint));
      expect(capturedEvent!.url, equals('https://example.com/app.html'));
      expect(capturedEvent!.error, equals('Failed to load application bundle'));
      expect(capturedEvent!.metadata?['statusCode'], equals(404));
    });
    
    test('recordError with resolveEntrypoint phase should trigger callbacks', () {
      final loadingState = LoadingState();
      bool anyErrorTriggered = false;
      bool entrypointErrorTriggered = false;
      LoadingErrorEvent? capturedEvent;
      
      // Register callbacks
      loadingState.onAnyLoadingError((event) {
        anyErrorTriggered = true;
        capturedEvent = event;
      });
      
      loadingState.onLoadingError({LoadingErrorType.entrypoint}, (event) {
        entrypointErrorTriggered = true;
      });
      
      // Record error using the generic recordError with resolveEntrypoint phase
      loadingState.recordError(
        LoadingState.phaseResolveEntrypoint,
        'Network timeout',
        context: {
          'bundle': 'https://example.com/bundle.js',
          'errorType': 'TimeoutException',
        }
      );
      
      expect(anyErrorTriggered, isTrue,
        reason: 'onAnyLoadingError should be triggered for resolveEntrypoint phase errors');
      expect(entrypointErrorTriggered, isTrue,
        reason: 'onLoadingError for entrypoint type should be triggered');
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.type, equals(LoadingErrorType.entrypoint));
      expect(capturedEvent!.error, equals('Network timeout'));
      expect(capturedEvent!.url, equals('https://example.com/bundle.js'));
    });
    
    test('multiple error callbacks should all fire for entrypoint errors', () {
      final loadingState = LoadingState();
      int callbackCount = 0;
      
      // Register multiple callbacks
      loadingState.onAnyLoadingError((event) {
        callbackCount++;
      });
      
      loadingState.onLoadingError({LoadingErrorType.entrypoint}, (event) {
        callbackCount++;
      });
      
      loadingState.onAnyLoadingError((event) {
        callbackCount++;
      });
      
      // Record an entrypoint error
      loadingState.recordEntrypointError(
        'https://example.com/index.html',
        'Connection refused'
      );
      
      expect(callbackCount, equals(3),
        reason: 'All registered callbacks should be triggered');
    });
    
    test('entrypoint error should not trigger callbacks for other types', () {
      final loadingState = LoadingState();
      bool scriptTriggered = false;
      bool fetchTriggered = false;
      bool cssTriggered = false;
      bool entrypointTriggered = false;
      
      // Register type-specific callbacks
      loadingState.onLoadingError({LoadingErrorType.script}, (event) {
        scriptTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        fetchTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.css}, (event) {
        cssTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.entrypoint}, (event) {
        entrypointTriggered = true;
      });
      
      // Record an entrypoint error
      loadingState.recordEntrypointError(
        'https://example.com/app.js',
        'Parse error'
      );
      
      expect(scriptTriggered, isFalse,
        reason: 'Script callback should not be triggered');
      expect(fetchTriggered, isFalse,
        reason: 'Fetch callback should not be triggered');
      expect(cssTriggered, isFalse,
        reason: 'CSS callback should not be triggered');
      expect(entrypointTriggered, isTrue,
        reason: 'Only entrypoint callback should be triggered');
    });
    
    test('all error types should trigger onAnyLoadingError', () {
      final loadingState = LoadingState();
      List<LoadingErrorType> capturedTypes = [];
      
      loadingState.onAnyLoadingError((event) {
        capturedTypes.add(event.type);
      });
      
      // Record different types of errors
      loadingState.recordEntrypointError('entrypoint.html', 'Error 1');
      loadingState.recordScriptElementError('script.js', 'Error 2');
      loadingState.recordCSSError('styles.css', 'Error 3');
      loadingState.recordImageError('image.png', 'Error 4');
      loadingState.recordNetworkRequestError('api/data', 'Error 5', isXHR: true);
      
      expect(capturedTypes.length, equals(5),
        reason: 'Should have captured all 5 error types');
      expect(capturedTypes, contains(LoadingErrorType.entrypoint));
      expect(capturedTypes, contains(LoadingErrorType.script));
      expect(capturedTypes, contains(LoadingErrorType.css));
      expect(capturedTypes, contains(LoadingErrorType.image));
      expect(capturedTypes, contains(LoadingErrorType.fetch));
    });
    
    test('onLoadingError with multiple types should filter correctly', () {
      final loadingState = LoadingState();
      List<LoadingErrorType> capturedTypes = [];
      
      // Listen for only script and CSS errors
      loadingState.onLoadingError(
        {LoadingErrorType.script, LoadingErrorType.css},
        (event) {
          capturedTypes.add(event.type);
        }
      );
      
      // Record various error types
      loadingState.recordEntrypointError('entrypoint.html', 'Error');
      loadingState.recordScriptElementError('script.js', 'Error');
      loadingState.recordCSSError('styles.css', 'Error');
      loadingState.recordImageError('image.png', 'Error');
      
      expect(capturedTypes.length, equals(2),
        reason: 'Should only capture script and CSS errors');
      expect(capturedTypes, contains(LoadingErrorType.script));
      expect(capturedTypes, contains(LoadingErrorType.css));
      expect(capturedTypes, isNot(contains(LoadingErrorType.entrypoint)));
      expect(capturedTypes, isNot(contains(LoadingErrorType.image)));
    });
    
    test('recordError with resolveEntrypoint.start phase should also trigger', () {
      final loadingState = LoadingState();
      bool triggered = false;
      
      loadingState.onAnyLoadingError((event) {
        triggered = true;
      });
      
      // Test with a sub-phase
      loadingState.recordError(
        'resolveEntrypoint.start',
        'Failed to start loading',
        context: {'bundle': 'test.html'}
      );
      
      expect(triggered, isTrue,
        reason: 'Phases containing resolveEntrypoint should trigger entrypoint callbacks');
    });
  });
}