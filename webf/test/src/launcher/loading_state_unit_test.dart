/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/launcher.dart';

void main() {
  group('LoadingState Script Error Unit Tests', () {
    test('recordScriptElementError should trigger callbacks for all script errors', () {
      final loadingState = LoadingState();
      List<LoadingErrorEvent> allErrors = [];
      List<LoadingErrorEvent> scriptErrors = [];
      
      // Register callbacks
      loadingState.onAnyLoadingError((event) {
        allErrors.add(event);
      });
      
      loadingState.onLoadingError({LoadingErrorType.script}, (event) {
        scriptErrors.add(event);
      });
      
      // Record multiple script errors
      loadingState.recordScriptElementError('https://cdn.example.com/lib.js', 'Network timeout');
      loadingState.recordScriptElementError('https://api.example.com/sdk.js', '404 Not Found');
      loadingState.recordScriptElementError('inline-script-1', 'Syntax error');
      
      expect(allErrors.length, equals(3),
        reason: 'onAnyLoadingError should capture all 3 script errors');
      expect(scriptErrors.length, equals(3),
        reason: 'onLoadingError for scripts should capture all 3 script errors');
      
      // Verify error details
      expect(allErrors[0].url, equals('https://cdn.example.com/lib.js'));
      expect(allErrors[0].error, equals('Network timeout'));
      expect(allErrors[0].type, equals(LoadingErrorType.script));
      
      expect(allErrors[1].url, equals('https://api.example.com/sdk.js'));
      expect(allErrors[1].error, equals('404 Not Found'));
      
      expect(allErrors[2].url, equals('inline-script-1'));
      expect(allErrors[2].error, equals('Syntax error'));
    });
    
    test('script errors should not trigger callbacks for other types', () {
      final loadingState = LoadingState();
      bool imageTriggered = false;
      bool fetchTriggered = false;
      bool scriptTriggered = false;
      
      loadingState.onLoadingError({LoadingErrorType.image}, (event) {
        imageTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        fetchTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.script}, (event) {
        scriptTriggered = true;
      });
      
      // Record a script error
      loadingState.recordScriptElementError('test.js', 'Failed to load');
      
      expect(scriptTriggered, isTrue);
      expect(imageTriggered, isFalse);
      expect(fetchTriggered, isFalse);
    });
  });
  
  group('LoadingState Fetch/XHR Error Unit Tests', () {
    test('recordNetworkRequestError with isXHR should trigger fetch callbacks', () {
      final loadingState = LoadingState();
      List<LoadingErrorEvent> fetchErrors = [];
      List<LoadingErrorEvent> allErrors = [];
      
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        fetchErrors.add(event);
      });
      
      loadingState.onAnyLoadingError((event) {
        allErrors.add(event);
      });
      
      // Record XHR/Fetch errors
      loadingState.recordNetworkRequestError(
        'https://api.example.com/users',
        'Connection refused',
        isXHR: true
      );
      
      loadingState.recordNetworkRequestError(
        'https://api.example.com/data.json',
        'CORS error',
        isXHR: true
      );
      
      // Record a non-XHR network error (should not trigger fetch callbacks)
      loadingState.recordNetworkRequestError(
        'https://cdn.example.com/image.png',
        'Network timeout',
        isXHR: false
      );
      
      expect(fetchErrors.length, equals(2),
        reason: 'Only XHR/Fetch errors should trigger fetch callbacks');
      expect(fetchErrors[0].url, equals('https://api.example.com/users'));
      expect(fetchErrors[0].error, equals('Connection refused'));
      expect(fetchErrors[1].url, equals('https://api.example.com/data.json'));
      expect(fetchErrors[1].error, equals('CORS error'));
      
      // All errors includes the 2 XHR errors (non-XHR without pending request is ignored)
      expect(allErrors.length, equals(2));
    });
    
    test('fetch errors should have correct type and metadata', () {
      final loadingState = LoadingState();
      LoadingErrorEvent? capturedEvent;
      
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        capturedEvent = event;
      });
      
      loadingState.recordNetworkRequestError(
        'https://api.example.com/submit',
        'Request timeout after 30s',
        isXHR: true
      );
      
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.type, equals(LoadingErrorType.fetch));
      expect(capturedEvent!.url, equals('https://api.example.com/submit'));
      expect(capturedEvent!.error, contains('timeout'));
      expect(capturedEvent!.timestamp, isA<DateTime>());
      expect(capturedEvent!.metadata, isNotNull);
    });
    
    test('fetch errors should not trigger script or image callbacks', () {
      final loadingState = LoadingState();
      bool scriptTriggered = false;
      bool imageTriggered = false;
      bool fetchTriggered = false;
      
      loadingState.onLoadingError({LoadingErrorType.script}, (event) {
        scriptTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.image}, (event) {
        imageTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        fetchTriggered = true;
      });
      
      loadingState.recordNetworkRequestError(
        'https://api.test.com/endpoint',
        'API Error',
        isXHR: true
      );
      
      expect(fetchTriggered, isTrue);
      expect(scriptTriggered, isFalse);
      expect(imageTriggered, isFalse);
    });
  });
  
  group('LoadingState Image Error Unit Tests', () {
    test('recordImageError should trigger image callbacks', () {
      final loadingState = LoadingState();
      List<LoadingErrorEvent> imageErrors = [];
      List<LoadingErrorEvent> allErrors = [];
      
      loadingState.onLoadingError({LoadingErrorType.image}, (event) {
        imageErrors.add(event);
      });
      
      loadingState.onAnyLoadingError((event) {
        allErrors.add(event);
      });
      
      // Record image errors
      loadingState.recordImageError('https://cdn.example.com/logo.png', '404 Not Found');
      loadingState.recordImageError('https://images.example.com/banner.jpg', 'Decode error');
      loadingState.recordImageError('data:image/png;base64,invalid', 'Invalid data URI');
      
      expect(imageErrors.length, equals(3));
      expect(allErrors.length, equals(3));
      
      expect(imageErrors[0].url, equals('https://cdn.example.com/logo.png'));
      expect(imageErrors[0].error, equals('404 Not Found'));
      expect(imageErrors[0].type, equals(LoadingErrorType.image));
      
      expect(imageErrors[1].url, equals('https://images.example.com/banner.jpg'));
      expect(imageErrors[1].error, equals('Decode error'));
      
      expect(imageErrors[2].url, contains('data:image'));
      expect(imageErrors[2].error, equals('Invalid data URI'));
    });
    
    test('image errors should not trigger other type callbacks', () {
      final loadingState = LoadingState();
      bool scriptTriggered = false;
      bool fetchTriggered = false;
      bool cssTriggered = false;
      bool imageTriggered = false;
      
      loadingState.onLoadingError({LoadingErrorType.script}, (event) {
        scriptTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        fetchTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.css}, (event) {
        cssTriggered = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.image}, (event) {
        imageTriggered = true;
      });
      
      loadingState.recordImageError('test.png', 'Load failed');
      
      expect(imageTriggered, isTrue);
      expect(scriptTriggered, isFalse);
      expect(fetchTriggered, isFalse);
      expect(cssTriggered, isFalse);
    });
    
    test('image error metadata should be included', () {
      final loadingState = LoadingState();
      LoadingErrorEvent? capturedEvent;
      
      loadingState.onLoadingError({LoadingErrorType.image}, (event) {
        capturedEvent = event;
      });
      
      loadingState.recordImageError(
        'https://cdn.test.com/hero.webp',
        'Unsupported format',
        metadata: {
          'width': 1920,
          'height': 1080,
          'format': 'webp'
        }
      );
      
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.metadata, isNotNull);
      expect(capturedEvent!.metadata!['width'], equals(1920));
      expect(capturedEvent!.metadata!['height'], equals(1080));
      expect(capturedEvent!.metadata!['format'], equals('webp'));
    });
  });
  
  group('LoadingState CSS Error Unit Tests', () {
    test('recordCSSError should trigger CSS callbacks', () {
      final loadingState = LoadingState();
      List<LoadingErrorEvent> cssErrors = [];
      
      loadingState.onLoadingError({LoadingErrorType.css}, (event) {
        cssErrors.add(event);
      });
      
      loadingState.recordCSSError('https://cdn.example.com/styles.css', '404 Not Found');
      loadingState.recordCSSError('https://fonts.example.com/font.css', 'Parse error');
      
      expect(cssErrors.length, equals(2));
      expect(cssErrors[0].type, equals(LoadingErrorType.css));
      expect(cssErrors[0].url, equals('https://cdn.example.com/styles.css'));
      expect(cssErrors[1].url, equals('https://fonts.example.com/font.css'));
    });
  });
  
  group('LoadingState Mixed Error Type Tests', () {
    test('multiple error types should all trigger onAnyLoadingError', () {
      final loadingState = LoadingState();
      Map<LoadingErrorType, int> errorCounts = {};
      
      loadingState.onAnyLoadingError((event) {
        errorCounts[event.type] = (errorCounts[event.type] ?? 0) + 1;
      });
      
      // Record different types of errors
      loadingState.recordEntrypointError('index.html', 'Parse error');
      loadingState.recordScriptElementError('app.js', 'Syntax error');
      loadingState.recordCSSError('styles.css', '404');
      loadingState.recordImageError('logo.png', 'Decode failed');
      loadingState.recordNetworkRequestError('api/data', 'Timeout', isXHR: true);
      
      expect(errorCounts[LoadingErrorType.entrypoint], equals(1));
      expect(errorCounts[LoadingErrorType.script], equals(1));
      expect(errorCounts[LoadingErrorType.css], equals(1));
      expect(errorCounts[LoadingErrorType.image], equals(1));
      expect(errorCounts[LoadingErrorType.fetch], equals(1));
    });
    
    test('selective multi-type listening should filter correctly', () {
      final loadingState = LoadingState();
      List<LoadingErrorType> capturedTypes = [];
      
      // Listen only for script, CSS, and image errors
      loadingState.onLoadingError(
        {LoadingErrorType.script, LoadingErrorType.css, LoadingErrorType.image},
        (event) {
          capturedTypes.add(event.type);
        }
      );
      
      // Record various error types
      loadingState.recordEntrypointError('index.html', 'Error');
      loadingState.recordScriptElementError('script.js', 'Error');
      loadingState.recordCSSError('style.css', 'Error');
      loadingState.recordImageError('image.png', 'Error');
      loadingState.recordNetworkRequestError('api', 'Error', isXHR: true);
      
      expect(capturedTypes.length, equals(3));
      expect(capturedTypes.contains(LoadingErrorType.script), isTrue);
      expect(capturedTypes.contains(LoadingErrorType.css), isTrue);
      expect(capturedTypes.contains(LoadingErrorType.image), isTrue);
      expect(capturedTypes.contains(LoadingErrorType.entrypoint), isFalse);
      expect(capturedTypes.contains(LoadingErrorType.fetch), isFalse);
    });
    
    test('error timestamps should be properly set', () {
      final loadingState = LoadingState();
      List<LoadingErrorEvent> events = [];
      
      loadingState.onAnyLoadingError((event) {
        events.add(event);
      });
      
      final beforeTime = DateTime.now();
      
      loadingState.recordScriptElementError('test.js', 'Error');
      loadingState.recordImageError('test.png', 'Error');
      loadingState.recordNetworkRequestError('api', 'Error', isXHR: true);
      
      final afterTime = DateTime.now();
      
      expect(events.length, equals(3));
      
      for (final event in events) {
        expect(event.timestamp.isAfter(beforeTime) || event.timestamp == beforeTime, isTrue,
          reason: 'Timestamp should be after or equal to start time');
        expect(event.timestamp.isBefore(afterTime) || event.timestamp == afterTime, isTrue,
          reason: 'Timestamp should be before or equal to end time');
      }
    });
    
    test('callbacks should be called in registration order', () {
      final loadingState = LoadingState();
      List<int> callOrder = [];
      
      loadingState.onAnyLoadingError((event) {
        callOrder.add(1);
      });
      
      loadingState.onLoadingError({LoadingErrorType.script}, (event) {
        callOrder.add(2);
      });
      
      loadingState.onAnyLoadingError((event) {
        callOrder.add(3);
      });
      
      loadingState.recordScriptElementError('test.js', 'Error');
      
      expect(callOrder, equals([2, 1, 3]),
        reason: 'Type-specific callbacks fire first, then generic in registration order');
    });
  });
  
  group('LoadingState Legacy Callback Compatibility', () {
    test('onScriptError should work alongside new callbacks', () {
      final loadingState = LoadingState();
      bool legacyCalled = false;
      bool newCalled = false;
      
      loadingState.onScriptError((event) {
        legacyCalled = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.script}, (event) {
        newCalled = true;
      });
      
      loadingState.recordScriptElementError('test.js', 'Error');
      
      expect(legacyCalled, isTrue);
      expect(newCalled, isTrue);
    });
    
    test('onFetchError should work alongside new callbacks', () {
      final loadingState = LoadingState();
      bool legacyCalled = false;
      bool newCalled = false;
      
      loadingState.onFetchError((event) {
        legacyCalled = true;
      });
      
      loadingState.onLoadingError({LoadingErrorType.fetch}, (event) {
        newCalled = true;
      });
      
      loadingState.recordNetworkRequestError('api/test', 'Error', isXHR: true);
      
      expect(legacyCalled, isTrue);
      expect(newCalled, isTrue);
    });
  });
}