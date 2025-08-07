# WebF LoadingState Error Callbacks Documentation

## Overview
The WebF LoadingState now provides a comprehensive error callback system that allows developers to handle loading failures for different types of resources with fine-grained control.

## Error Types
The system categorizes loading errors into 5 types:

```dart
enum LoadingErrorType {
  entrypoint,  // Main HTML/JS bundle failures
  script,      // External script loading failures  
  css,         // Stylesheet loading failures
  image,       // Image loading failures
  fetch,       // XHR/Fetch API request failures
}
```

## Error Event Structure
Each error event contains detailed information:

```dart
class LoadingErrorEvent {
  final LoadingErrorType type;    // Type of resource that failed
  final String url;                // URL of the failed resource
  final String error;              // Error message/description
  final DateTime timestamp;        // When the error occurred
  final Map<String, dynamic>? metadata; // Additional context
}
```

## Using Error Callbacks

### Listen to All Errors
```dart
controller.loadingState.onAnyLoadingError((event) {
  print('Loading error: ${event.type} - ${event.url}');
  print('Error: ${event.error}');
  
  // Handle based on type
  switch (event.type) {
    case LoadingErrorType.entrypoint:
      handleCriticalError(event);
      break;
    case LoadingErrorType.script:
      logScriptError(event);
      break;
    case LoadingErrorType.fetch:
      retryApiCall(event.url);
      break;
    // ... handle other types
  }
});
```

### Listen to Specific Error Types
```dart
// Listen only for script and CSS errors
controller.loadingState.onLoadingError(
  {LoadingErrorType.script, LoadingErrorType.css},
  (event) {
    print('Resource failed: ${event.url}');
    loadFallbackResource(event.type, event.url);
  }
);

// Listen only for API failures
controller.loadingState.onLoadingError(
  {LoadingErrorType.fetch},
  (event) {
    print('API call failed: ${event.url}');
    if (event.metadata?['method'] == 'POST') {
      // Handle POST failures specially
      queueForRetry(event);
    }
  }
);
```

### Multiple Callbacks
You can register multiple callbacks for the same error types:

```dart
// First callback - logging
controller.loadingState.onLoadingError(
  {LoadingErrorType.script},
  (event) => logger.error('Script failed: ${event.url}')
);

// Second callback - user notification  
controller.loadingState.onLoadingError(
  {LoadingErrorType.script},
  (event) => showUserNotification('Failed to load application resources')
);

// Both callbacks will be triggered for script errors
```

## Error Recording Methods

### For Direct Use (Testing/Debugging)
```dart
// Record entrypoint failure
loadingState.recordEntrypointError(
  'https://example.com/app.html',
  'Failed to parse HTML',
  metadata: {'line': 42, 'column': 15}
);

// Record script failure
loadingState.recordScriptElementError(
  'https://cdn.example.com/lib.js',
  '404 Not Found'
);

// Record CSS failure
loadingState.recordCSSError(
  'https://example.com/styles.css',
  'Invalid CSS syntax'
);

// Record image failure
loadingState.recordImageError(
  'https://images.example.com/logo.png',
  'Decode error',
  metadata: {'format': 'png', 'size': 102400}
);

// Record XHR/Fetch failure
loadingState.recordNetworkRequestError(
  'https://api.example.com/data',
  'CORS policy violation',
  isXHR: true  // Important: set to true for Fetch/XHR
);
```

## Legacy Callback Support
The older phase-specific callbacks continue to work:

```dart
// Legacy callbacks (still supported)
controller.loadingState.onScriptError((event) {
  print('Script error phase: ${event.name}');
});

controller.loadingState.onFetchError((event) {
  print('Fetch error phase: ${event.name}');  
});

controller.loadingState.onPreloadError((event) {
  print('Preload error phase: ${event.name}');
});
```

## Real-World Examples

### Error Recovery System
```dart
class ErrorRecoveryManager {
  final WebFController controller;
  final Map<String, int> retryCount = {};
  
  ErrorRecoveryManager(this.controller) {
    setupErrorHandling();
  }
  
  void setupErrorHandling() {
    controller.loadingState.onAnyLoadingError((event) {
      final key = '${event.type}_${event.url}';
      retryCount[key] = (retryCount[key] ?? 0) + 1;
      
      if (retryCount[key]! <= 3) {
        // Retry up to 3 times
        Future.delayed(Duration(seconds: retryCount[key]!), () {
          retryResource(event);
        });
      } else {
        // Give up and use fallback
        loadFallback(event);
      }
    });
  }
  
  void retryResource(LoadingErrorEvent event) {
    switch (event.type) {
      case LoadingErrorType.script:
        // Inject script tag with alternate CDN
        injectAlternateScript(event.url);
        break;
      case LoadingErrorType.fetch:
        // Retry API call with backoff
        retryApiCall(event.url);
        break;
      // ... handle other types
    }
  }
}
```

### Error Analytics
```dart
class LoadingAnalytics {
  final WebFController controller;
  
  LoadingAnalytics(this.controller) {
    trackErrors();
  }
  
  void trackErrors() {
    controller.loadingState.onAnyLoadingError((event) {
      // Send to analytics service
      analytics.track('loading_error', {
        'type': event.type.toString(),
        'url': event.url,
        'error': event.error,
        'timestamp': event.timestamp.toIso8601String(),
        'metadata': event.metadata,
      });
      
      // Track critical errors specially
      if (event.type == LoadingErrorType.entrypoint) {
        analytics.track('critical_failure', {
          'url': event.url,
          'error': event.error,
        });
      }
    });
  }
}
```

### User Notification System
```dart
class UserErrorNotifier {
  final WebFController controller;
  
  UserErrorNotifier(this.controller) {
    setupNotifications();
  }
  
  void setupNotifications() {
    // Only notify users about critical errors
    controller.loadingState.onLoadingError(
      {LoadingErrorType.entrypoint, LoadingErrorType.script},
      (event) {
        if (event.type == LoadingErrorType.entrypoint) {
          showError('Unable to load application. Please refresh the page.');
        } else if (event.url.contains('critical')) {
          showWarning('Some features may be unavailable.');
        }
      }
    );
    
    // Silent logging for non-critical errors
    controller.loadingState.onLoadingError(
      {LoadingErrorType.image, LoadingErrorType.css},
      (event) => debugPrint('Resource failed: ${event.url}')
    );
  }
}
```

## Testing

### Unit Testing Error Callbacks
```dart
test('should handle script errors correctly', () {
  final loadingState = LoadingState();
  LoadingErrorEvent? capturedEvent;
  
  loadingState.onLoadingError(
    {LoadingErrorType.script},
    (event) => capturedEvent = event
  );
  
  loadingState.recordScriptElementError(
    'test.js',
    'Network error'
  );
  
  expect(capturedEvent, isNotNull);
  expect(capturedEvent!.type, equals(LoadingErrorType.script));
  expect(capturedEvent!.url, equals('test.js'));
  expect(capturedEvent!.error, equals('Network error'));
});
```

## Implementation Details

### Automatic Entrypoint Error Detection
When `recordError` is called with phase `resolveEntrypoint` or any phase containing "resolveEntrypoint", it automatically dispatches a `LoadingErrorEvent` with type `LoadingErrorType.entrypoint`.

### XHR/Fetch Detection
The system uses the `X-WebF-Request-Type` header to distinguish between regular network requests (like image loading) and JavaScript-initiated XHR/Fetch requests. Only requests marked with this header trigger fetch error callbacks.

### Callback Order
1. Type-specific callbacks are triggered first
2. Generic callbacks (`onAnyLoadingError`) are triggered second
3. Within each category, callbacks are called in registration order

## Migration from Legacy System
If you're using the older phase-based error handling:

```dart
// Old way
controller.loadingState.onScriptError((event) {
  handleScriptError(event.parameters);
});

// New way (recommended)
controller.loadingState.onLoadingError(
  {LoadingErrorType.script},
  (event) {
    handleScriptError(event.url, event.error, event.metadata);
  }
);
```

Both approaches work and can be used simultaneously during migration.