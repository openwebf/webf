/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/launcher.dart';

void main() {
  group('LoadingState Integration Tests with Mock Errors', () {
    test('simulate complete loading flow with various errors', () async {
      final loadingState = LoadingState();
      
      // Track all errors
      Map<LoadingErrorType, List<LoadingErrorEvent>> errorsByType = {
        for (var type in LoadingErrorType.values) type: []
      };
      
      List<LoadingErrorEvent> allErrors = [];
      
      // Register comprehensive error handling
      loadingState.onAnyLoadingError((event) {
        allErrors.add(event);
        errorsByType[event.type]!.add(event);
      });
      
      // Simulate loading phases with errors
      
      // 1. Start loading
      loadingState.recordPhase(LoadingState.phaseInit);
      loadingState.recordPhase(LoadingState.phaseLoadStart);
      
      // 2. Entrypoint resolution starts
      loadingState.recordPhase('${LoadingState.phaseResolveEntrypoint}.start');
      
      // 3. Entrypoint fails to load
      loadingState.recordError(
        LoadingState.phaseResolveEntrypoint,
        'Network timeout while loading bundle',
        context: {
          'bundle': 'https://app.example.com/index.html',
          'errorType': 'TimeoutException',
        }
      );
      
      // Verify entrypoint error was captured
      expect(errorsByType[LoadingErrorType.entrypoint]!.length, equals(1));
      expect(errorsByType[LoadingErrorType.entrypoint]!.first.url, 
        equals('https://app.example.com/index.html'));
      
      // 4. Continue with fallback bundle (simulating recovery)
      loadingState.recordPhase(LoadingState.phaseParseHTML);
      
      // 5. Scripts start loading
      loadingState.recordScriptElementQueue(
        source: 'https://cdn.example.com/vendor.js',
        isInline: false,
        isAsync: true,
        isDefer: false,
        isModule: false,
      );
      
      loadingState.recordScriptElementQueue(
        source: 'https://cdn.example.com/app.js',
        isInline: false,
        isModule: true,
        isAsync: false,
        isDefer: false,
      );
      
      // 6. First script fails
      loadingState.recordScriptElementError(
        'https://cdn.example.com/vendor.js',
        '404 Not Found'
      );
      
      expect(errorsByType[LoadingErrorType.script]!.length, equals(1));
      expect(errorsByType[LoadingErrorType.script]!.first.error, 
        equals('404 Not Found'));
      
      // 7. Second script loads successfully
      loadingState.recordScriptElementLoadComplete('https://cdn.example.com/app.js');
      
      // 8. CSS fails to load
      loadingState.recordCSSError(
        'https://cdn.example.com/styles.css',
        'Parse error: Invalid CSS syntax',
        metadata: {'line': 42, 'column': 7}
      );
      
      expect(errorsByType[LoadingErrorType.css]!.length, equals(1));
      
      // 9. Images start loading
      loadingState.recordNetworkRequestStart('https://images.example.com/logo.png');
      loadingState.recordNetworkRequestStart('https://images.example.com/banner.jpg');
      
      // 10. One image fails
      loadingState.recordImageError(
        'https://images.example.com/logo.png',
        'Unsupported image format'
      );
      
      expect(errorsByType[LoadingErrorType.image]!.length, equals(1));
      
      // 11. API calls (XHR/Fetch)
      loadingState.recordNetworkRequestStart('https://api.example.com/user');
      loadingState.recordNetworkRequestError(
        'https://api.example.com/user',
        'CORS policy: No Access-Control-Allow-Origin header',
        isXHR: true
      );
      
      expect(errorsByType[LoadingErrorType.fetch]!.length, equals(1));
      expect(errorsByType[LoadingErrorType.fetch]!.first.error, 
        contains('CORS'));
      
      // 12. DOM ready
      loadingState.recordPhase(LoadingState.phaseDOMContentLoaded);
      
      // 13. Another fetch error
      loadingState.recordNetworkRequestError(
        'https://api.example.com/data',
        'Connection refused',
        isXHR: true
      );
      
      expect(errorsByType[LoadingErrorType.fetch]!.length, equals(2));
      
      // 14. Window load
      loadingState.recordPhase(LoadingState.phaseWindowLoad);
      
      // Verify final state
      expect(allErrors.length, equals(6), 
        reason: '1 entrypoint + 1 script + 1 CSS + 1 image + 2 fetch = 6 errors');
      
      // Verify error types are correctly categorized
      expect(errorsByType[LoadingErrorType.entrypoint]!.length, equals(1));
      expect(errorsByType[LoadingErrorType.script]!.length, equals(1));
      expect(errorsByType[LoadingErrorType.css]!.length, equals(1));
      expect(errorsByType[LoadingErrorType.image]!.length, equals(1));
      expect(errorsByType[LoadingErrorType.fetch]!.length, equals(2));
      
      // Verify all errors have timestamps
      for (final error in allErrors) {
        expect(error.timestamp, isA<DateTime>());
        expect(error.url, isNotEmpty);
        expect(error.error, isNotEmpty);
      }
      
      // Verify errors maintain chronological order
      for (int i = 1; i < allErrors.length; i++) {
        expect(
          allErrors[i].timestamp.isAfter(allErrors[i-1].timestamp) ||
          allErrors[i].timestamp == allErrors[i-1].timestamp,
          isTrue,
          reason: 'Errors should be in chronological order'
        );
      }
    });
    
    test('error callbacks with filtering work in loading flow', () async {
      final loadingState = LoadingState();
      
      List<LoadingErrorEvent> criticalErrors = [];
      List<LoadingErrorEvent> resourceErrors = [];
      List<LoadingErrorEvent> apiErrors = [];
      
      // Register filtered callbacks
      
      // Critical errors (entrypoint and scripts)
      loadingState.onLoadingError(
        {LoadingErrorType.entrypoint, LoadingErrorType.script},
        (event) => criticalErrors.add(event)
      );
      
      // Resource errors (CSS and images)
      loadingState.onLoadingError(
        {LoadingErrorType.css, LoadingErrorType.image},
        (event) => resourceErrors.add(event)
      );
      
      // API errors (fetch/XHR)
      loadingState.onLoadingError(
        {LoadingErrorType.fetch},
        (event) => apiErrors.add(event)
      );
      
      // Simulate various errors
      loadingState.recordEntrypointError('bundle.js', 'Parse error');
      loadingState.recordScriptElementError('lib.js', 'Syntax error');
      loadingState.recordCSSError('theme.css', '404');
      loadingState.recordImageError('icon.svg', 'Invalid SVG');
      loadingState.recordNetworkRequestError('api/data', 'Timeout', isXHR: true);
      loadingState.recordScriptElementError('app.js', 'Network error');
      loadingState.recordImageError('photo.jpg', 'Too large');
      
      // Verify filtering worked correctly
      expect(criticalErrors.length, equals(3), 
        reason: '1 entrypoint + 2 scripts');
      expect(resourceErrors.length, equals(3),
        reason: '1 CSS + 2 images');
      expect(apiErrors.length, equals(1),
        reason: '1 fetch');
      
      // Verify correct types in each list
      expect(criticalErrors.every((e) => 
        e.type == LoadingErrorType.entrypoint || 
        e.type == LoadingErrorType.script), isTrue);
      
      expect(resourceErrors.every((e) => 
        e.type == LoadingErrorType.css || 
        e.type == LoadingErrorType.image), isTrue);
      
      expect(apiErrors.every((e) => 
        e.type == LoadingErrorType.fetch), isTrue);
    });
    
    test('legacy callbacks work alongside new system', () async {
      final loadingState = LoadingState();
      
      bool legacyScriptCalled = false;
      bool legacyFetchCalled = false;
      bool newScriptCalled = false;
      bool newFetchCalled = false;
      
      // Register legacy callbacks
      loadingState.onScriptError((event) {
        legacyScriptCalled = true;
      });
      
      loadingState.onFetchError((event) {
        legacyFetchCalled = true;
      });
      
      // Register new callbacks
      loadingState.onLoadingError({LoadingErrorType.script}, (event) {
        newScriptCalled = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        newFetchCalled = true;
      });
      
      // Trigger errors
      loadingState.recordScriptElementError('test.js', 'Failed');
      loadingState.recordNetworkRequestError('api/test', 'Failed', isXHR: true);
      
      // Both systems should work
      expect(legacyScriptCalled, isTrue);
      expect(newScriptCalled, isTrue);
      expect(legacyFetchCalled, isTrue);
      expect(newFetchCalled, isTrue);
    });
  });
}