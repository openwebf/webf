/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/foundation/loading_state_registry.dart';

void main() {
  group('LoadingState Fetch Error Direct Tests', () {
    test('FetchModule error should trigger onAnyLoadingError callback', () {
      // Create a LoadingState instance
      final loadingState = LoadingState();
      
      // Track if callback was triggered
      bool anyErrorTriggered = false;
      LoadingErrorEvent? capturedEvent;
      
      // Register callback
      loadingState.onAnyLoadingError((event) {
        anyErrorTriggered = true;
        capturedEvent = event;
      });
      
      // The URL that will be fetched
      final testUrl = 'https://api.example.com/data';
      
      // Simulate a fetch error by directly calling the error recording
      // (This simulates what happens when FetchModule.invoke encounters an error)
      loadingState.recordNetworkRequestError(
        testUrl,
        'Connection refused',
        isXHR: true
      );
      
      // Verify the callback was triggered
      expect(anyErrorTriggered, isTrue,
        reason: 'onAnyLoadingError should be triggered for fetch errors');
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.type, equals(LoadingErrorType.fetch));
      expect(capturedEvent!.url, equals(testUrl));
      expect(capturedEvent!.error, equals('Connection refused'));
    });
    
    test('FetchModule error should trigger type-specific callbacks', () {
      final loadingState = LoadingState();
      
      bool fetchErrorTriggered = false;
      bool scriptErrorTriggered = false;
      LoadingErrorEvent? fetchEvent;
      
      // Register type-specific callbacks
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        fetchErrorTriggered = true;
        fetchEvent = event;
      });
      
      loadingState.onLoadingError({LoadingErrorType.script}, (event) {
        scriptErrorTriggered = true;
      });
      
      // Simulate fetch error
      loadingState.recordNetworkRequestError(
        'https://api.test.com/endpoint',
        'Network timeout',
        isXHR: true
      );
      
      expect(fetchErrorTriggered, isTrue,
        reason: 'Fetch error callback should be triggered');
      expect(scriptErrorTriggered, isFalse,
        reason: 'Script error callback should NOT be triggered');
      expect(fetchEvent, isNotNull);
      expect(fetchEvent!.type, equals(LoadingErrorType.fetch));
    });
    
    test('Multiple fetch errors should each trigger callbacks', () {
      final loadingState = LoadingState();
      
      List<LoadingErrorEvent> fetchErrors = [];
      
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        fetchErrors.add(event);
      });
      
      // Simulate multiple fetch errors
      loadingState.recordNetworkRequestError(
        'https://api1.example.com/users',
        'CORS policy violation',
        isXHR: true
      );
      
      loadingState.recordNetworkRequestError(
        'https://api2.example.com/data',
        '500 Internal Server Error',
        isXHR: true
      );
      
      loadingState.recordNetworkRequestError(
        'https://api3.example.com/config',
        'DNS resolution failed',
        isXHR: true
      );
      
      expect(fetchErrors.length, equals(3));
      expect(fetchErrors[0].url, contains('api1'));
      expect(fetchErrors[1].url, contains('api2'));
      expect(fetchErrors[2].url, contains('api3'));
      
      // Verify each has different error message
      expect(fetchErrors[0].error, contains('CORS'));
      expect(fetchErrors[1].error, contains('500'));
      expect(fetchErrors[2].error, contains('DNS'));
    });
    
    test('Legacy onFetchError should work with new fetch error recording', () {
      final loadingState = LoadingState();
      
      bool legacyCallbackTriggered = false;
      LoadingPhaseEvent? legacyEvent;
      
      // Register legacy callback
      loadingState.onFetchError((event) {
        legacyCallbackTriggered = true;
        legacyEvent = event;
      });
      
      // Record fetch error
      loadingState.recordNetworkRequestError(
        'https://legacy.test.com/api',
        'Connection reset',
        isXHR: true
      );
      
      expect(legacyCallbackTriggered, isTrue,
        reason: 'Legacy onFetchError should still work');
      expect(legacyEvent, isNotNull);
      expect(legacyEvent!.name, equals(LoadingState.phaseFetchError));
      expect(legacyEvent!.parameters['url'], equals('https://legacy.test.com/api'));
      expect(legacyEvent!.parameters['error'], equals('Connection reset'));
    });
    
    test('Fetch error with LoadingStateRegistry integration', () {
      // This test simulates the full integration with LoadingStateRegistry
      final contextId = 1.0;
      final loadingState = LoadingState();
      
      // Register the loading state with the registry
      LoadingStateRegistry.instance.register(contextId, loadingState);
      
      bool errorCaptured = false;
      LoadingErrorEvent? capturedEvent;
      
      loadingState.onAnyLoadingError((event) {
        errorCaptured = true;
        capturedEvent = event;
      });
      
      // Get the dumper from registry (as FetchModule would)
      final dumper = LoadingStateRegistry.instance.getDumper(contextId);
      
      // Record error through the dumper
      dumper?.recordNetworkRequestError(
        'https://registry.test.com/api',
        'SSL certificate invalid',
        isXHR: true
      );
      
      expect(errorCaptured, isTrue);
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.type, equals(LoadingErrorType.fetch));
      expect(capturedEvent!.error, contains('SSL'));
      
      // Clean up
      LoadingStateRegistry.instance.unregister(contextId);
    });
  });
}