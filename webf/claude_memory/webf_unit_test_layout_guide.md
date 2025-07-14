# WebF Unit Test Layout Guide

This guide explains how to write unit tests for layout properties in WebF, including the limitations and best practices.

## Key Concepts

### 1. Layout Measurements in Unit Tests

In WebF unit tests, layout measurements behave differently than in integration tests:

- `offsetWidth`, `offsetHeight`, `getBoundingClientRect()` will return actual values (not 0) when using the proper test template
- You need to wait for layout completion using the standard template
- Unit tests can verify layout calculations, but integration tests are better for complex layout scenarios

### 2. Default Box-Sizing

**Important**: WebF uses `border-box` as the default box-sizing (not `content-box`). This means:
- Width and height include padding and border
- A 100px wide element with 10px padding will still be 100px wide (not 120px)

## Standard Test Template

Always use this template for widget unit tests that need layout measurements:

```dart
testWidgets('test description', (WidgetTester tester) async {
  WebFController? controller;
  
  await tester.runAsync(() async {
    controller = await WebFControllerManager.instance.addWithPreload(
      name: 'unique-test-name',
      createController: () => WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
      ),
      bundle: WebFBundle.fromContent('''
        <html>
          <body style="margin: 0; padding: 0;">
            <\!-- Your HTML content here -->
          </body>
        </html>
      ''', contentType: htmlContentType),
    );
    await controller\!.controlledInitCompleter.future;
  });

  final webf = WebF.fromControllerName(controllerName: 'unique-test-name');
  await tester.pumpWidget(webf);

  // Wait for initial rendering
  await tester.pump();
  await tester.pump(Duration(milliseconds: 100));

  await tester.runAsync(() async {
    await controller\!.controllerPreloadingCompleter.future;
  });

  // Additional frames to ensure layout
  await tester.pump();
  await tester.pump(Duration(milliseconds: 100));
  await tester.pumpFrames(webf, Duration(milliseconds: 100));

  await tester.runAsync(() async {
    return Future.wait([
      controller\!.controllerOnDOMContentLoadedCompleter.future,
      controller\!.viewportLayoutCompleter.future,
    ]);
  });

  // Now you can access elements and their layout properties
  final element = controller\!.view.document.getElementById(['element-id']);
  expect(element, isNotNull);
  
  // Layout measurements will have actual values
  print('Element size: ${element\!.offsetWidth}x${element.offsetHeight}');
});
```

## Best Practices

### 1. Test Setup

```dart
void main() {
  setUp(() {
    setupTest();
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() {
    // Controllers are automatically cleaned up when tests end
  });
  
  group('Your Test Group', () {
    // Add tests here
  });
}
```

### 2. Element Access

```dart
// Use getElementById with array parameter
final element = controller\!.view.document.getElementById(['element-id']);

// Check element exists
expect(element, isNotNull);

// Access layout properties
final width = element\!.offsetWidth;
final height = element\!.offsetHeight;
final rect = element.getBoundingClientRect();
```

### 3. Force Layout Flush

If measurements return 0, try forcing a layout flush:

```dart
element.flushLayout();
```

### 4. Common Layout Properties

```dart
// Offset properties
element.offsetWidth    // Element width including padding and border
element.offsetHeight   // Element height including padding and border
element.offsetTop      // Distance from top of offset parent
element.offsetLeft     // Distance from left of offset parent

// Bounding client rect
final rect = element.getBoundingClientRect();
rect.width            // Element width
rect.height           // Element height
rect.top              // Top position relative to viewport
rect.left             // Left position relative to viewport
```

## Example Test Cases

### 1. Testing Flexbox Layout

```dart
testWidgets('flex layout distributes space correctly', (WidgetTester tester) async {
  // ... setup code using template ...
  
  final container = controller\!.view.document.getElementById(['container']);
  final item1 = controller\!.view.document.getElementById(['item1']);
  final item2 = controller\!.view.document.getElementById(['item2']);
  
  // Verify flex items have correct widths
  if (item1\!.offsetWidth > 0 && item2\!.offsetWidth > 0) {
    final ratio = item2.offsetWidth / item1.offsetWidth;
    expect(ratio, closeTo(2.0, 0.2), reason: 'Item 2 should be twice as wide');
  }
});
```

### 2. Testing Box-Sizing

```dart
testWidgets('border-box sizing includes padding', (WidgetTester tester) async {
  // ... setup code using template ...
  
  // Element with width: 100px, padding: 10px
  final box = controller\!.view.document.getElementById(['box']);
  
  // With border-box, total width should be 100px (not 120px)
  expect(box\!.offsetWidth, equals(100.0));
});
```

### 3. Testing Text Wrapping

```dart
testWidgets('text wrapping affects height', (WidgetTester tester) async {
  // ... setup code using template ...
  
  final shortText = controller\!.view.document.getElementById(['short']);
  final longText = controller\!.view.document.getElementById(['long']);
  
  // Long text that wraps should be taller
  expect(longText\!.offsetHeight, greaterThan(shortText\!.offsetHeight));
});
```

## Limitations

1. **Complex Layouts**: For complex layout scenarios, integration tests may be more appropriate
2. **Dynamic Content**: Tests with dynamic content loading may need additional waiting
3. **Animations**: Layout during animations is difficult to test reliably

## When to Use Integration Tests Instead

Use integration tests (TypeScript) when:
- Testing complex layout interactions
- Verifying visual regression with snapshots
- Testing responsive layouts
- Measuring performance of layout operations

## Debugging Tips

1. **Print Render Tree**: Use `controller.printRenderObjectTree(null)` for debugging
2. **Check Evaluated State**: Ensure `controller.evaluated` is true before measurements
3. **Add Debug Output**: Print measurements to understand what's happening
4. **Use Multiple Pumps**: Sometimes additional `pump()` calls help stabilize layout

Remember: Unit tests with the proper template can successfully measure layouts, but integration tests remain the gold standard for complex layout verification.
EOF < /dev/null