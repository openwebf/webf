# Dart/Flutter Development Guide (webf/)

This guide covers Dart/Flutter development in the `webf/` directory, which implements DOM/CSS and layout/painting on top of Flutter.

## Development Workflow
- No build needed for Dart-only changes
- Use widget unit tests to verify rendering changes: `cd webf && flutter test test/src/rendering/`
- Use integration tests for end-to-end verification: `cd webf && flutter test integration_test/`

## Dart Code Style
- Follow rules in webf/analysis_options.yaml
- Use single quotes for strings
- File names must use snake_case
- Class names must use PascalCase
- Variables/functions use camelCase
- Prefer final fields when applicable
- Lines should be max 120 characters

## Lint and Format Commands
- Lint: `npm run lint` (runs flutter analyze in webf directory)
- Format: `npm run format` (formats with 120 char line length)

## Dart/Flutter Testing
- Run Flutter dart tests: `cd webf && flutter test`
- Run a single Flutter test: `cd webf && flutter test test/path/to/test_file.dart`
- Run widget unit tests: `cd webf && flutter test test/src/rendering/`
- Run integration tests: `cd webf && flutter test integration_test/`
- See Unit Tests (webf/test) section for detailed guide

## Verifying Changes Without Running the App
Since you cannot directly launch Flutter examples, use these approaches:
1. **Widget Unit Tests**: Best for testing rendering, layout, and CSS properties
   - Use `WebFWidgetTestUtils.prepareWidgetTest()` to test HTML/CSS rendering
   - Access render objects to verify layout calculations
   - Example: `test/src/rendering/flow_layout_test.dart`

2. **Integration Tests**: Best for end-to-end functionality
   - Located in `webf/integration_test/`
   - Test complete features like performance metrics, gestures, etc.

3. **Snapshot Tests**: Visual regression testing
   - Located in `integration_tests/specs/`
   - Use `await snapshot()` to capture visual output
   - Compare against baseline images

## Important Dart Files and Patterns
- `lib/bridge.dart`: FFI bindings to C++ bridge
- `lib/src/dom/`: DOM element implementations
- `lib/src/css/`: CSS property implementations
- `lib/src/rendering/`: Layout and rendering logic
- `RenderBoxModel`: Base class for layout
- `CSSRenderStyle`: Style computation and storage

## WebF Widget Unit Test Guide
Comprehensive guide for writing widget unit tests with WebFWidgetTestUtils.

### Overview
WebFWidgetTestUtils provides a standardized way to write unit tests for WebF widgets, handling the complex setup required for testing WebF components.

### Basic Usage

#### Test Setup
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  setUp(() {
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(Duration(milliseconds: 100));
  });

  testWidgets('test description', (WidgetTester tester) async {
    // Test implementation
  });
}
```

#### Using WebFWidgetTestUtils
```dart
testWidgets('should render element correctly', (WidgetTester tester) async {
  final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: 'unique-test-name-${DateTime.now().millisecondsSinceEpoch}',
    html: '''
      <div id="test-element" style="width: 100px; height: 100px;">
        Test Content
      </div>
    ''',
  );

  // Access controller and elements
  final controller = prepared.controller;
  final element = prepared.getElementById('test-element');

  expect(element, isNotNull);
  expect(element.renderStyle.width, equals(100));
});
```

### Advanced Testing

#### Testing Async Operations
```dart
testWidgets('should handle async updates', (WidgetTester tester) async {
  final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: 'async-test',
    html: '<div id="target">Initial</div>',
  );

  final element = prepared.getElementById('target');

  // Trigger async update
  element.textContent = 'Updated';

  // Wait for update to propagate
  await tester.pump();

  // Verify update
  expect(element.textContent, equals('Updated'));
});
```

#### Testing Layout Properties
```dart
testWidgets('should calculate layout correctly', (WidgetTester tester) async {
  final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: 'layout-test',
    html: '''
      <div style="display: flex; width: 300px;">
        <div style="flex: 1;">Item 1</div>
        <div style="flex: 2;">Item 2</div>
      </div>
    ''',
  );

  await tester.pump();

  final container = prepared.controller.view.document.querySelector(['div']);
  final children = container.children;

  // Access render boxes for layout info
  final child1Box = children[0].attachedRenderer;
  final child2Box = children[1].attachedRenderer;

  expect(child1Box.size.width, equals(100)); // 1/3 of 300px
  expect(child2Box.size.width, equals(200)); // 2/3 of 300px
});
```

### Best Practices

#### 1. Unique Controller Names
Always use unique controller names to avoid conflicts:
```dart
controllerName: 'test-${testName}-${DateTime.now().millisecondsSinceEpoch}'
```

#### 2. Proper Cleanup
Always clean up after tests:
```dart
tearDown(() async {
  WebFControllerManager.instance.disposeAll();
  await Future.delayed(Duration(milliseconds: 100)); // Allow file handles to close
});
```

#### 3. Wait for Layouts
When testing layout properties, ensure layout is complete:
```dart
await tester.pump(); // Trigger layout
await tester.pumpAndSettle(); // Wait for animations
```

#### 4. Error Handling
Test error conditions:
```dart
testWidgets('should handle errors gracefully', (WidgetTester tester) async {
  final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: 'error-test',
    html: '<div id="test"></div>',
  );

  final element = prepared.getElementById('test');

  // Test invalid style
  expect(
    () => element.style.setProperty('width', 'invalid'),
    throwsA(isA<FormatException>()),
  );
});
```

### Common Patterns

#### Testing Style Changes
```dart
final element = prepared.getElementById('target');
element.style.backgroundColor = 'red';
await tester.pump();

expect(element.renderStyle.backgroundColor, equals(Color(0xFFFF0000)));
```

#### Testing Events
```dart
final button = prepared.getElementById('button');
button.addEventListener('click', (event) {
  clickCount++;
});

// Simulate click
button.dispatchEvent(Event('click'));
await tester.pump();

expect(clickCount, equals(1));
```

#### Testing Render Objects
```dart
final element = prepared.getElementById('test');
final renderBox = element.attachedRenderer as RenderFlowLayout;

expect(renderBox.establishIFC, isTrue);
expect(renderBox.size, equals(Size(100, 100)));
```

### Example: Verifying a CSS Change
```dart
testWidgets('should apply new CSS property correctly', (WidgetTester tester) async {
  final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: 'css-test-${DateTime.now().millisecondsSinceEpoch}',
    html: '''
      <div id="test" style="width: 100px; height: 100px; background-color: red;">
        Test Content
      </div>
    ''',
  );

  final element = prepared.getElementById('test');
  final renderBox = element.attachedRenderer as RenderBoxModel;

  // Verify the property was applied
  expect(renderBox.renderStyle.backgroundColor, equals(Color(0xFFFF0000)));
  expect(renderBox.size, equals(Size(100, 100)));
});
```

## Flutter Integration Tests (webf/integration_test)
- LCP integration tests: `webf/integration_test/integration_test/lcp_integration_test.dart`
- FCP integration tests: `webf/integration_test/integration_test/fcp_integration_test.dart`
- FP integration tests: `webf/integration_test/integration_test/fp_integration_test.dart`
- Run with: `cd webf && flutter test integration_test/integration_test/test_name.dart`

## Widget Element Extension System
Documentation for the WidgetElement extension system.

### Overview
The WidgetElement extension system allows custom Flutter widgets to be integrated into WebF's DOM tree, enabling developers to use Flutter widgets as if they were HTML elements.

### Architecture

#### Registration System
```dart
class WidgetElementRegistry {
  static final Map<String, WidgetElementBuilder> _builders = {};

  static void register(String tagName, WidgetElementBuilder builder) {
    _builders[tagName.toLowerCase()] = builder;
  }

  static WidgetElement? createElement(String tagName) {
    final builder = _builders[tagName.toLowerCase()];
    return builder?.call();
  }
}
```

#### WidgetElement Base Class
```dart
abstract class WidgetElement extends Element {
  Widget? _widget;

  @override
  RenderObject createRenderer() {
    return RenderWidgetElement(this);
  }

  /// Build the Flutter widget for this element
  Widget buildWidget(BuildContext context);

  /// Update widget when attributes change
  void updateWidget() {
    _widget = buildWidget(context);
    _markNeedsRebuild();
  }
}
```

### Creating Custom Elements

#### Example: Video Player Element
```dart
class VideoPlayerElement extends WidgetElement {
  String get src => getAttribute('src') ?? '';
  bool get autoplay => hasAttribute('autoplay');

  @override
  Widget buildWidget(BuildContext context) {
    return VideoPlayer(
      url: src,
      autoplay: autoplay,
      onReady: () {
        dispatchEvent(Event('loadedmetadata'));
      },
    );
  }

  @override
  void attributeChangedCallback(String name, String? oldValue, String? newValue) {
    super.attributeChangedCallback(name, oldValue, newValue);

    if (name == 'src' || name == 'autoplay') {
      updateWidget();
    }
  }
}

// Registration
WidgetElementRegistry.register('video-player', () => VideoPlayerElement());
```

#### Usage in HTML
```html
<video-player
  src="https://example.com/video.mp4"
  autoplay
  id="myPlayer">
</video-player>

<script>
  const player = document.getElementById('myPlayer');
  player.addEventListener('loadedmetadata', () => {
    console.log('Video ready!');
  });
</script>
```

### Advanced Features

#### Two-way Data Binding
```dart
class InputElement extends WidgetElement {
  final _controller = TextEditingController();

  String get value => _controller.text;
  set value(String v) {
    _controller.text = v;
    dispatchEvent(Event('input'));
  }

  @override
  Widget buildWidget(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (text) {
        dispatchEvent(Event('input'));
      },
    );
  }
}
```

#### Method Exposure
```dart
class ChartElement extends WidgetElement {
  final _chartKey = GlobalKey<ChartState>();

  void updateData(List<double> data) {
    _chartKey.currentState?.updateData(data);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Chart(key: _chartKey);
  }

  // Expose method to JavaScript
  @override
  dynamic getProperty(String name) {
    if (name == 'updateData') {
      return allowInterop(updateData);
    }
    return super.getProperty(name);
  }
}
```

### Best Practices

1. **Attribute Observation**: Only observe attributes that affect the widget
2. **Memory Management**: Dispose controllers and subscriptions
3. **Event Dispatching**: Follow W3C event standards
4. **Performance**: Minimize widget rebuilds
5. **Accessibility**: Implement ARIA attributes when applicable

## Memory Management in FFI
- Always free allocated memory in Dart FFI:
  - Use `malloc.free()` for `toNativeUtf8()` allocations
  - Free in `finally` blocks to ensure cleanup on exceptions
  - Track ownership of allocated pointers in callbacks
- For async callbacks:
  - Consider when to free memory (in callback or after future completes)
  - Document memory ownership clearly
  - Use RAII patterns in C++ where possible
- Native value handling:
  - Free NativeValue pointers after converting with `fromNativeValue`
  - Be careful with pointer lifetime across thread boundaries

## Unit Test Patterns
- Always call `setupTest()` in the `setUpAll()` method for one-time setup
- When testing with WebFController, wait for initialization: `await controller.controlledInitCompleter.future;`
- Use mock bundles from `test/src/foundation/mock_bundle.dart` for testing

### Common Testing Patterns
```dart
// Unit test setup
setUp(() {
  setupTest();
});

// Controller initialization
final controller = WebFController(
  viewportWidth: 360,
  viewportHeight: 640,
  bundle: WebFBundle.fromContent('<html></html>', contentType: ContentType.html),
);
await controller.controlledInitCompleter.future;
```
