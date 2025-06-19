# WebF LCP Integration Tests

This directory contains integration tests for WebF's LCP (Largest Contentful Paint) feature.

## Overview

These integration tests verify LCP functionality in a real Flutter environment where paint cycles actually occur, unlike unit tests. The tests cover:

1. **Basic LCP tracking** - Text and image content
2. **Navigation** - LCP tracking across page loads
3. **User interaction** - LCP finalization on tap/click
4. **Loading animations** - LCP recalculation when loading elements are removed
5. **Auto-finalization** - LCP finalization after 5 seconds without interaction
6. **Prerendering mode** - LCP behavior with WebF's prerendering feature

## Running the Tests

### Run all integration tests:
```bash
flutter test integration_test/lcp_integration_test.dart
```

### Run with specific device (iOS Simulator):
```bash
flutter test integration_test/lcp_integration_test.dart -d iPhone
```

### Run with specific device (Android):
```bash
flutter test integration_test/lcp_integration_test.dart -d android
```

### Run a specific test:
```bash
flutter test integration_test/lcp_integration_test.dart --name "LCP tracks text content"
```

## Test Structure

Each test follows this pattern:

1. **Setup**: Initialize WebFControllerManager
2. **Create Controller**: Add controller with LCP callbacks using the manager
3. **Load Content**: Use WebF.fromControllerName() to properly load content
4. **Verify**: Check that LCP callbacks are triggered with valid timing
5. **Cleanup**: Dispose all controllers

## Key Differences from Unit Tests

- Uses `IntegrationTestWidgetsFlutterBinding` instead of regular test binding
- Paint cycles actually occur, making LCP measurements realistic
- Can test actual timing (e.g., 5-second auto-finalization)
- Tests navigation and page transitions
- Tests user interactions in a real Flutter app context

## Debugging

To see LCP timing output, the tests include print statements that show:
- When LCP is reported
- The actual LCP time in milliseconds
- LCP updates during page lifecycle

## Notes

- LCP timing starts when AutoManagedWebFState is created
- LCP is reported progressively until finalized
- Finalization occurs on user interaction or after 5 seconds
- Only visible content in the viewport counts for LCP