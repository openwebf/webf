# Add WebF To Flutter

This guide is for Flutter developers who want to integrate WebF into their existing Flutter applications to leverage web technologies, reuse web code, or create powerful hybrid user interfaces.

## Table of Contents

*   **1. Introduction**
    *   [What is WebF?](#what-is-webf)
    *   [What is a WebF App?](#what-is-a-webf-app)
    *   [Why Integrate WebF into a Flutter App?](#why-integrate-webf-into-a-flutter-app)
*   **2. Getting Started**
    *   [Installation](#installation)
    *   [Creating Your First WebF Instance](#creating-your-first-webf-instance)
    *   [Understanding the `WebFControllerManager`](#understanding-the-webfcontrollermanager)
    *   [Loading WebF Apps with `WebFBundle`](#loading-webf-apps-with-webfbundle)
*   **3. Core Concepts for Flutter Developers**
    *   [The Managed `WebF` Widget](#the-managed-webf-widget)
    *   [Accessing the `WebFController`](#accessing-the-webfcontroller)
    *   [Lifecycle of a Managed Controller](#lifecycle-of-a-managed-controller)
    *   [Performance: Understanding Loading Modes](#performance-understanding-loading-modes)
*   **4. Embedding WebF in Flutter**
    *   [Integrating `WebF` into Your Widget Tree](#integrating-webf-into-your-widget-tree)
    *   [Handling Layout, Sizing, and Constraints](#handling-layout-sizing-and-constraints)
*   **5. Adding Flutter Widgets to WebF (Hybrid UI)**
    *   [Overview of the Hybrid UI Approach](#overview-of-the-hybrid-ui-approach)
    *   [Automatic Binding Generation with `webf codegen`](#automatic-binding-generation-with-webf-codegen-for-widgets)
    *   [Manual Setup (for advanced understanding)](#manual-setup-for-widgets-for-advanced-understanding)
*   **6. Adding Flutter Plugins to WebF (The Bridge)**
    *   [Overview of Exposing Dart Services](#overview-of-exposing-dart-services)
    *   [Automatic Binding Generation with `webf codegen`](#automatic-binding-generation-with-webf-codegen-for-plugins)
    *   [Manual Setup (for advanced understanding)](#manual-setup-for-plugins-for-advanced-understanding)
*   **7. Advanced Topics**
    *   [Hybrid Routing](#hybrid-routing)
    *   [Performance Monitoring](#performance-monitoring)
    *   [Controlling Color Themes](#controlling-color-themes)
    *   [Caching](#caching)
    *   [Sub-views](#sub-views)
*   **8. API Reference & Examples**
    *   [API Reference](#api-reference)
    *   [Examples](#examples)

---

## 1. Introduction

### What is WebF?

WebF is a high-performance web rendering engine built on Flutter that enables you to **build native Flutter apps using web technologies** (HTML, CSS, and JavaScript). Unlike traditional webviews, WebF directly renders WebF apps using Flutter's rendering pipeline, providing native-like performance and seamless integration with Flutter widgets.

#### What is a WebF App?

A **WebF app** consists of two complementary parts:

1. **Web Standards Layer**: Standard HTML, CSS, and JavaScript code that's compatible with web standards
   - Works with popular frameworks like React, Vue, and vanilla JS
   - Uses familiar DOM APIs, CSS styling, and JavaScript features
   - Portable and can run in browsers with minimal modifications

2. **Flutter Integration Layer**: Custom APIs, components, and services exposed from Flutter
   - **Custom Elements**: Flutter widgets accessible as HTML elements (e.g., `<flutter-button>`)
   - **Native Modules**: Dart/Flutter APIs callable from JavaScript (e.g., camera, storage, sensors)
   - **Platform Features**: Access to device capabilities through Flutter plugins

This hybrid architecture lets you leverage both the web ecosystem and Flutter's native capabilities in a single application.

Key characteristics:
- **Not a browser**: WebF builds Flutter apps, not web apps
- **Native rendering**: Uses Flutter's rendering engine, not browser rendering
- **JavaScript runtime**: Powered by QuickJS for efficient JS execution
- **Web standards support**: Implements core DOM/CSS APIs with C++ and Dart
- **Hybrid UI**: Mix Flutter widgets and WebF apps seamlessly

### Why Integrate WebF into a Flutter App?

WebF unlocks powerful capabilities for Flutter developers:

1. **Leverage Web Ecosystem**: Use popular web frameworks like React, Vue, and their vast ecosystem of libraries
2. **Code Reuse**: Share code and components between web and mobile without maintaining separate codebases
3. **Hot Updates**: Update UI and logic over-the-air without app store approvals (within platform guidelines)
4. **Rapid Prototyping**: Build complex UIs faster using familiar web technologies
5. **Hybrid Teams**: Enable web developers to contribute to mobile apps
6. **Dynamic Content**: Load and render dynamic WebF apps safely
7. **Cross-Platform UI**: Write once in React/Vue, run on iOS, Android, macOS, Linux, and Windows

Use cases include:
- Building feature-rich apps with frequent updates
- Creating content-driven applications (news, blogs, e-commerce)
- Integrating web-based admin panels or dashboards
- Developing apps with complex, dynamic layouts
- Sharing business logic between web and mobile platforms

---

## 2. Getting Started

### Installation

Add `webf` to your `pubspec.yaml`:

```yaml
dependencies:
  webf: ^0.23.0  # Check pub.dev for the latest version
```

Run:
```bash
flutter pub get
```

### Creating Your First WebF Instance

WebF uses a managed architecture through `WebFControllerManager`. Here's a minimal example:

```dart
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

void main() {
  // 1. Initialize the controller manager
  WidgetsFlutterBinding.ensureInitialized();
  WebFControllerManager.instance.initialize(
    WebFControllerManagerConfig(
      maxAliveInstances: 5,
      maxAttachedInstances: 3,
    ),
  );

  // 2. Add a controller with content
  WebFControllerManager.instance.addWithPrerendering(
    name: 'home',
    createController: () => WebFController(),
    bundle: WebFBundle.fromUrl('https://example.com/'),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: WebF.fromControllerName(
          controllerName: 'home',
          loadingWidget: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
```

This example:
1. Initializes the controller manager with lifecycle limits
2. Pre-renders a controller named 'home' with content from a URL
3. Displays the WebF content using `WebF.fromControllerName`

### Understanding the `WebFControllerManager`

The `WebFControllerManager` is a singleton that manages the lifecycle of all WebF instances in your app. It handles:

- **Controller Creation**: Creates and initializes WebF controllers
- **Resource Management**: Enforces limits on active instances
- **Lifecycle Control**: Automatically attaches/detaches controllers based on visibility
- **Memory Optimization**: Disposes unused controllers when limits are reached
- **State Persistence**: Maintains controller state when detached

Key configuration options:

```dart
WebFControllerManager.instance.initialize(
  WebFControllerManagerConfig(
    maxAliveInstances: 5,        // Max controllers in memory
    maxAttachedInstances: 3,      // Max controllers rendering simultaneously
    autoDisposeWhenLimitReached: true,  // Auto-cleanup LRU controllers
    enableDevTools: true,         // Enable Chrome DevTools debugging
    onControllerDisposed: (name, controller) {
      print('Controller $name disposed');
    },
    onControllerDetached: (name, controller) {
      print('Controller $name detached');
    },
  ),
);
```

**Best practices**:
- Initialize in `main()` before `runApp()`
- Set `maxAliveInstances` based on your app's memory constraints
- Keep `maxAttachedInstances` low (1-3) for optimal performance
- Use lifecycle callbacks for debugging and analytics

### Loading WebF Apps with `WebFBundle`

`WebFBundle` specifies where to load your WebF app from. WebF supports multiple sources:

#### 1. Remote URL
```dart
WebFBundle.fromUrl('https://example.com/')
```

#### 2. Local Assets
```dart
// First, add to pubspec.yaml:
// flutter:
//   assets:
//     - assets/web/

WebFBundle.fromUrl('assets:///assets/web/index.html')
```

#### 3. Localhost Development
```dart
// For local development with React/Vue dev servers
WebFBundle.fromUrl('http://localhost:3000/')
```

#### 4. Inline Content
```dart
WebFBundle.fromContent('''
<!DOCTYPE html>
<html>
  <body>
    <h1>Hello from WebF!</h1>
    <script>
      document.body.style.backgroundColor = 'lightblue';
    </script>
  </body>
</html>
''')
```

**Complete example with pre-rendering**:

```dart
await WebFControllerManager.instance.addWithPrerendering(
  name: 'product_page',
  createController: () => WebFController(
    initialRoute: '/products',
  ),
  bundle: WebFBundle.fromUrl('https://myapp.com/'),
  setup: (controller) {
    // Additional setup after controller creation
    controller.onLCP = (time, isEvaluated) {
      print('LCP: $time ms');
    };
  },
);
```

---

## 3. Core Concepts for Flutter Developers

### The Managed `WebF` Widget

The `WebF` widget is the entry point for displaying WebF apps in Flutter. **Always use `WebF.fromControllerName`** instead of the default constructor for proper lifecycle management:

```dart
WebF.fromControllerName(
  controllerName: 'home',           // Reference to managed controller
  initialRoute: '/',                 // Initial URL path
  loadingWidget: CircularProgressIndicator(),
  onControllerCreated: (controller) {
    print('Controller ready: $controller');
  },
  onBuildSuccess: () {
    print('UI rendered successfully');
  },
)
```

**Why use `fromControllerName`?**
- Automatic lifecycle management
- Seamless controller recreation after disposal
- Memory-efficient controller sharing
- Support for preloading and pre-rendering

### Accessing the `WebFController`

The `WebFController` provides programmatic control over the WebF instance. Access it in several ways:

#### 1. Via `onControllerCreated` callback
```dart
WebFController? _controller;

WebF.fromControllerName(
  controllerName: 'home',
  onControllerCreated: (controller) {
    _controller = controller;
    // Configure hybrid history delegate
    controller.hybridHistory.delegate = MyCustomHybridHistoryDelegate();
  },
)
```

#### 2. Via `WebFControllerManager`
```dart
// In an async context
final controller = await WebFControllerManager.instance.getController('home');
if (controller != null) {
  controller.evaluateJavaScript('alert("Hello from Dart!")');
}
```

#### 3. In setup callback during initialization
```dart
WebFControllerManager.instance.addWithPrerendering(
  name: 'home',
  createController: () => WebFController(),
  bundle: WebFBundle.fromUrl('https://example.com/'),
  setup: (controller) {
    // Controller is guaranteed to be available here
    controller.httpLoggerOptions = HttpLoggerOptions(
      requestHeader: true,
      requestBody: true,
    );
  },
);
```

**Common controller operations**:

```dart
// Navigation
controller.hybridHistory.pushState(stateData, '/new-route');
controller.hybridHistory.back();

// JavaScript execution
controller.evaluateJavaScript('console.log("Hello!")');

// Theme control
controller.darkModeOverride = true;

// Loading state
controller.loadingState.onLargestContentfulPaint((event) {
  print('LCP at ${event.elapsed.inMilliseconds}ms');
});
```

### Lifecycle of a Managed Controller

Controllers go through distinct lifecycle states:

```
[Created] → [Initialized] → [Attached] → [Detached] → [Disposed]
```

#### States explained:

1. **Created**: Controller instance exists but not initialized
2. **Initialized**: Bridge to JavaScript engine established, ready to load content
3. **Attached**: Actively rendering in Flutter widget tree
4. **Detached**: Paused rendering but state preserved in memory
5. **Disposed**: Fully destroyed, all resources released

#### Lifecycle hooks:

```dart
WebFControllerManager.instance.initialize(
  WebFControllerManagerConfig(
    onControllerDetached: (name, controller) {
      // Called when controller stops rendering but stays in memory
      // Good for pausing animations, stopping timers
      print('$name detached');
    },
    onControllerDisposed: (name, controller) {
      // Called when controller is fully destroyed
      // Release any external resources held by this controller
      print('$name disposed');
    },
  ),
);

// Per-controller lifecycle
WebFController(
  onControllerInit: (controller) async {
    // Called once after bridge initialization
    print('Controller initialized');
  },
)
```

#### Automatic lifecycle management:

The manager automatically handles:
- **Attachment**: When a `WebF` widget appears on screen
- **Detachment**: When removed from widget tree (but kept in memory if under limit)
- **Disposal**: When memory limits are reached (LRU strategy)

**Manual control**:

```dart
// Manually dispose a controller
await WebFControllerManager.instance.disposeController('home');

// Dispose all controllers
await WebFControllerManager.instance.disposeAll();
```

### Performance: Understanding Loading Modes

WebF supports three loading modes to optimize performance:

#### 1. Pre-rendering (Recommended Default)
```dart
WebFControllerManager.instance.addWithPrerendering(
  name: 'home',
  createController: () => WebFController(),
  bundle: WebFBundle.fromUrl('https://example.com/'),
);
```
- Fully loads, executes, and renders WebF app in background
- Instant display when widget attached
- Best user experience with minimal perceived load time
- **Recommended for most screens in your app**

#### 2. Preloading (Optional)
```dart
WebFControllerManager.instance.addWithPreload(
  name: 'settings',
  createController: () => WebFController(),
  bundle: WebFBundle.fromUrl('https://example.com/'),
);
```
- HTML/JS downloaded and parsed in background
- JavaScript execution deferred until widget attached
- Memory usage: <10 MB per controller
- Use when you need a separate JavaScript context with lower memory footprint

#### 3. Normal Loading (Special Cases)
```dart
WebF.fromControllerName(
  controllerName: 'rarely_used',
  bundle: WebFBundle.fromUrl('https://example.com/'),
  // No special mode specified
)
```
- Controller created when widget is first built
- WebF app loaded on-demand
- Lowest memory usage
- **Use only for rarely-accessed screens or when memory is extremely constrained**

**Performance comparison**:

| Mode | Initial Load Time | Memory Usage | User Experience | When to Use |
|------|------------------|--------------|-----------------|-------------|
| Pre-render | Near instant | 10-30 MB | Best | Most controllers (recommended default) |
| Preload | ~60% of normal | <10 MB | Good | Separate JS contexts with lower memory |
| Normal | 100% (baseline) | Minimal | Slower | Rarely-used screens only |

**Best practices**:
- **Pre-render your controller** - WebF is designed for long-lived contexts where a single controller manages an entire app with multiple routes
- Most apps need only **one controller** that hosts all screens and routes in a single JavaScript context
- Use WebF's routing frameworks (`@openwebf/react-router`, `@openwebf/vue-router`) within your WebF app instead of creating multiple controllers
- If you need **multiple separate JavaScript contexts** (e.g., two independent in-app apps), pre-render multiple controllers - one for each context
- Preloading is useful when you need a separate JS context but want to reduce memory usage
- Monitor with `onLCP` and `onFCP` callbacks to measure improvements

---

## 4. Embedding WebF in Flutter

### Integrating `WebF` into Your Widget Tree

**Typical Usage**: WebF apps usually take the **full screen** in Flutter apps. The most common pattern is to use WebF with `go_router` for full-screen navigation between routes.

#### Full-Screen Integration (Recommended)
```dart
// Most common pattern - WebF takes full screen with go_router
MaterialApp.router(
  routerConfig: GoRouter(
    routes: [
      GoRoute(
        path: '/:webfPath(.*)',
        pageBuilder: (context, state) {
          final path = '/${state.pathParameters['webfPath']}';
          final controller = WebFControllerManager.instance.getControllerSync('app')!;

          return MaterialPage(
            child: WebFSubView(
              path: path,
              controller: controller,
              onAppBarCreated: (title, routeLinkElement) => AppBar(
                title: Text(title),
              ),
            ),
          );
        },
      ),
    ],
  ),
)
```

#### Basic Full-Screen Setup
```dart
Scaffold(
  body: WebF.fromControllerName(
    controllerName: 'home',
  ),
)
```

#### Advanced: Partial Screen Usage

While less common, you can embed WebF in partial screen layouts for specialized use cases:

```dart
// In a Column with Flutter widgets
Column(
  children: [
    Text('Flutter Header'),
    Expanded(
      child: WebF.fromControllerName(
        controllerName: 'content',
      ),
    ),
    ElevatedButton(
      onPressed: () {},
      child: Text('Flutter Button'),
    ),
  ],
)

// Overlay with Flutter UI
Stack(
  children: [
    WebF.fromControllerName(
      controllerName: 'background',
    ),
    Positioned(
      top: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    ),
  ],
)
```

**Note**: For most apps, full-screen WebF with internal routing (using `@openwebf/react-router`) is the recommended approach rather than multiple partial WebF widgets.

### Handling Layout, Sizing, and Constraints

WebF respects Flutter's constraint system. Understanding how constraints flow is crucial:

#### Fill Available Space (Most Common)
```dart
// WebF will fill its parent's constraints
Expanded(
  child: WebF.fromControllerName(controllerName: 'home'),
)
```

#### Fixed Size
```dart
SizedBox(
  width: 400,
  height: 600,
  child: WebF.fromControllerName(controllerName: 'card'),
)
```

#### Responsive Sizing
```dart
LayoutBuilder(
  builder: (context, constraints) {
    return SizedBox(
      width: constraints.maxWidth,
      height: constraints.maxHeight * 0.7,  // 70% of parent height
      child: WebF.fromControllerName(controllerName: 'content'),
    );
  },
)
```

#### Inside Scrollable (Important!)
When embedding WebF in scrollable widgets, you must give it a fixed height:

```dart
// ❌ BAD - Will cause layout errors
ListView(
  children: [
    WebF.fromControllerName(controllerName: 'article'),
  ],
)

// ✅ GOOD - Fixed height
ListView(
  children: [
    SizedBox(
      height: 500,
      child: WebF.fromControllerName(controllerName: 'article'),
    ),
  ],
)
```

#### Viewport Sizing in WebF Apps
The WebF app inside the widget sees the widget's constraints as viewport size:

```dart
// Flutter code - 300x400 widget
SizedBox(
  width: 300,
  height: 400,
  child: WebF.fromControllerName(controllerName: 'box'),
)

// In your web code:
// window.innerWidth === 300 (in CSS pixels)
// window.innerHeight === 400 (in CSS pixels)
// 100vw === 300px
// 100vh === 400px
```

**Handling Different Screen Sizes**:

```dart
// Responsive WebF app
MediaQuery.of(context).size.width < 600
  ? SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 500,
      child: WebF.fromControllerName(controllerName: 'mobile_view'),
    )
  : SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 800,
      child: WebF.fromControllerName(controllerName: 'desktop_view'),
    )
```

---

## 5. Adding Flutter Widgets to WebF (Hybrid UI)

### Overview of the Hybrid UI Approach

WebF's Hybrid UI system lets you use Flutter widgets as custom HTML elements in your WebF apps. This enables:

- **Native performance**: UI-critical widgets rendered by Flutter
- **Platform widgets**: Use iOS/Android native components (Cupertino/Material)
- **Existing Flutter packages**: Leverage Flutter's ecosystem
- **Seamless integration**: WebF apps treat them like normal HTML elements

Architecture:
```
JavaScript/HTML → Custom Element → WidgetElement (Dart) → Flutter Widget
```

Example flow:
```jsx
// React code
import React from 'react';
import { FlutterButton } from 'my-widgets';

function MyComponent() {
  const handlePress = () => {
    console.log('Button pressed!');
  };

  return (
    <FlutterButton label="Click Me" onPress={handlePress} />
  );
}
```

```dart
// Flutter-side implementation
class FlutterButton extends WidgetElement {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => dispatchEvent(Event('press')),
      child: Text(getAttribute('label') ?? 'Button'),
    );
  }
}

// Register the custom element
WebF.defineCustomElement('flutter-button', (context) => FlutterButton(context));
```

### Automatic Binding Generation with `webf codegen` for Widgets

**This is the recommended approach** for production apps. The CLI generates all necessary code automatically.

#### Step 1: Install WebF CLI
```bash
npm install -g @openwebf/webf-cli
```

#### Step 2: Create TypeScript Definitions
Create a `.d.ts` file describing your widget's interface:

```typescript
// my-widgets.d.ts

/**
 * Properties for <flutter-cupertino-button>
 */
interface FlutterCupertinoButtonProperties {
  /**
   * Visual variant of the button.
   * - 'plain': Standard CupertinoButton
   * - 'filled': CupertinoButton.filled
   * - 'tinted': CupertinoButton.tinted
   * Default: 'plain'
   */
  variant?: string;

  /**
   * Size style used to derive default padding and min height.
   * - 'small': minSize ~32, compact padding
   * - 'large': minSize ~44, comfortable padding
   * Default: 'small'
   */
  size?: string;

  /**
   * Disable interactions.
   */
  disabled?: boolean;

  /**
   * Opacity applied while pressed (0.0–1.0). Default: 0.4
   */
  'pressed-opacity'?: string;

  /**
   * Hex color used when disabled. Accepts '#RRGGBB' or '#AARRGGBB'.
   */
  'disabled-color'?: string;
}

/**
 * Events emitted by <flutter-cupertino-button>
 */
interface FlutterCupertinoButtonEvents {
  /** Fired when the button is pressed (not emitted when disabled). */
  click: Event;
}

/**
 * Properties for <flutter-cupertino-slider>
 */
interface FlutterCupertinoSliderProperties {
  /** Current value of the slider. Default: 0.0. */
  val?: double;
  /** Minimum value of the slider range. Default: 0.0. */
  min?: double;
  /** Maximum value of the slider range. Default: 100.0. */
  max?: double;
  /** Number of discrete divisions between min and max. */
  step?: int;
  /** Whether the slider is disabled. Default: false. */
  disabled?: boolean;
}

interface FlutterCupertinoSliderMethods {
  /** Get the current value. */
  getValue(): double;
  /** Set the current value (clamped between min and max). */
  setValue(val: double): void;
}

interface FlutterCupertinoSliderEvents {
  /** Fired whenever the slider value changes. detail = value. */
  change: CustomEvent<double>;
  /** Fired when the user starts interacting with the slider. */
  changestart: CustomEvent<double>;
  /** Fired when the user stops interacting with the slider. */
  changeend: CustomEvent<double>;
}
```

#### Step 3: Generate Bindings
```bash
webf codegen my-widgets.d.ts \
  --flutter-package-src=../my_flutter_package \
  --publish-to-npm \
  --npm-registry=https://registry.npmjs.org/
```

This generates:
- **Dart binding classes** (abstract base classes) in `my_flutter_package/lib/src/`
  - Example: `button_bindings_generated.dart` with `FlutterCupertinoButtonBindings`
- NPM package with TypeScript definitions and React components
- Registration code structure

**Important**: `webf codegen` generates **binding classes only**. You still need to implement the actual widget logic.

#### Step 4: Implement Your Widget (Dart)

Extend the generated binding class and implement the widget:

```dart
// lib/src/button.dart
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'button_bindings_generated.dart';

class FlutterCupertinoButton extends FlutterCupertinoButtonBindings {
  FlutterCupertinoButton(super.context);

  String _variant = 'plain';
  String _sizeStyle = 'small';
  bool _disabled = false;
  double _pressedOpacity = 0.4;
  String? _disabledColor;

  // Implement property getters/setters from bindings
  @override
  String get variant => _variant;

  @override
  set variant(value) {
    _variant = value;
  }

  @override
  String get size => _sizeStyle;

  @override
  set size(value) {
    _sizeStyle = value;
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    _disabled = value;
  }

  @override
  String get pressedOpacity => _pressedOpacity.toString();

  @override
  set pressedOpacity(value) {
    _pressedOpacity = double.tryParse(value) ?? 0.4;
  }

  @override
  String? get disabledColor => _disabledColor;

  @override
  set disabledColor(value) {
    _disabledColor = value;
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoButtonState(this);
  }
}

class FlutterCupertinoButtonState extends WebFWidgetElementState {
  FlutterCupertinoButtonState(super.widgetElement);

  @override
  FlutterCupertinoButton get widgetElement => super.widgetElement as FlutterCupertinoButton;

  @override
  Widget build(BuildContext context) {
    // Build actual Flutter widget based on properties
    Widget buttonChild = WebFWidgetElementChild(
      child: widgetElement.childNodes.isEmpty
          ? const SizedBox()
          : widgetElement.childNodes.first.toWidget()
    );

    switch (widgetElement.variant) {
      case 'filled':
        return CupertinoButton.filled(
          onPressed: widgetElement.disabled ? null : () {
            widgetElement.dispatchEvent(Event('click'));
          },
          pressedOpacity: widgetElement._pressedOpacity,
          child: buttonChild,
        );
      case 'tinted':
        return CupertinoButton.tinted(
          onPressed: widgetElement.disabled ? null : () {
            widgetElement.dispatchEvent(Event('click'));
          },
          pressedOpacity: widgetElement._pressedOpacity,
          child: buttonChild,
        );
      default:
        return CupertinoButton(
          onPressed: widgetElement.disabled ? null : () {
            widgetElement.dispatchEvent(Event('click'));
          },
          pressedOpacity: widgetElement._pressedOpacity,
          child: buttonChild,
        );
    }
  }
}
```

#### Step 5: Register Your Widget

```dart
import 'package:webf/webf.dart';
import 'src/button.dart';

void installMyWidgets() {
  WebF.defineCustomElement(
    'flutter-cupertino-button',
    (context) => FlutterCupertinoButton(context)
  );
}

// In your main.dart
void main() {
  installMyWidgets();

  WebFControllerManager.instance.initialize(...);
  runApp(MyApp());
}
```

#### Step 6: Use in Your Web App
```bash
npm install my-widgets
```

```tsx
// React example
import React, { useState } from 'react';
import { FlutterCupertinoSlider, FlutterCupertinoButton } from 'my-widgets';

function App() {
  const [value, setValue] = useState(50);

  return (
    <div>
      <FlutterCupertinoSlider
        val={value}
        min={0}
        max={100}
        step={10}
        onChange={(e) => setValue(e.detail)}
        onChangeStart={(e) => console.log('Started:', e.detail)}
        onChangeEnd={(e) => console.log('Ended:', e.detail)}
      />

      <FlutterCupertinoButton
        variant="filled"
        size="large"
        disabled={false}
        pressed-opacity="0.6"
        onClick={() => console.log('Submitted!', value)}
      >
        Submit
      </FlutterCupertinoButton>
    </div>
  );
}
```

### Manual Setup for Widgets (for advanced understanding)

For complete control or learning purposes, you can manually implement custom elements.

#### Step 1: Create WidgetElement Class

```dart
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

class FlutterButton extends WidgetElement {
  FlutterButton(super.context);

  // Optional: Define default CSS styles
  @override
  Map<String, dynamic> get defaultStyle => {
    'display': 'block',
    'width': '100%',
  };

  @override
  WebFWidgetElementState createState() {
    return FlutterButtonState(this);
  }
}

class FlutterButtonState extends WebFWidgetElementState {
  FlutterButtonState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // Access attributes
    final label = widgetElement.getAttribute('label') ?? 'Button';
    final disabled = widgetElement.getAttribute('disabled') != null;

    return ElevatedButton(
      onPressed: disabled ? null : () {
        // Dispatch custom event back to JavaScript
        widgetElement.dispatchEvent(Event('press'));
      },
      child: Text(label),
    );
  }
}
```

#### Step 2: Register the Element

```dart
void main() {
  WebFControllerManager.instance.initialize(...);

  // Register custom element
  WebF.defineCustomElement('flutter-button', (context) => FlutterButton(context));

  runApp(MyApp());
}
```

#### Step 3: Use in Your WebF App

```html
<flutter-button label="Click Me" id="myBtn"></flutter-button>

<script>
  const btn = document.getElementById('myBtn');

  btn.addEventListener('press', () => {
    console.log('Button pressed!');
    btn.setAttribute('label', 'Clicked!');
  });
</script>
```

#### Advanced: Handling Children

```dart
class FlutterCard extends WidgetElement {
  FlutterCard(super.context);

  @override
  WebFWidgetElementState createState() => FlutterCardState(this);
}

class FlutterCardState extends WebFWidgetElementState {
  FlutterCardState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Convert child nodes to Flutter widgets
            ...widgetElement.childNodes.map((node) => node.toWidget()),
          ],
        ),
      ),
    );
  }
}
```

Usage:
```html
<flutter-card>
  <h1>Card Title</h1>
  <p>Card content goes here</p>
  <flutter-button label="Action"></flutter-button>
</flutter-card>
```

#### Advanced: Two-Way Data Binding

```dart
class FlutterSlider extends WidgetElement {
  FlutterSlider(super.context);

  @override
  WebFWidgetElementState createState() => FlutterSliderState(this);
}

class FlutterSliderState extends WebFWidgetElementState {
  FlutterSliderState(super.widgetElement);

  double _value = 0;

  @override
  void initState() {
    super.initState();
    _value = double.tryParse(widgetElement.getAttribute('value') ?? '0') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _value,
      min: 0,
      max: 100,
      onChanged: (newValue) {
        setState(() {
          _value = newValue;
        });

        // Update attribute
        widgetElement.setAttribute('value', newValue.toString());

        // Dispatch event with value
        widgetElement.dispatchEvent(
          CustomEvent('change', detail: newValue)
        );
      },
    );
  }
}
```

---

## 6. Adding Flutter Plugins to WebF (The Bridge)

### Overview of Exposing Dart Services

WebF's module system lets you expose Dart APIs to JavaScript, enabling WebF apps to:
- Access native device features (camera, GPS, sensors)
- Call Flutter plugins (shared_preferences, path_provider, etc.)
- Interact with platform-specific APIs
- Share complex business logic between Dart and JS

Architecture:
```
JavaScript call → Bridge → Dart Module → Flutter Plugin/Service
```

### Automatic Binding Generation with `webf codegen` for Plugins

**Recommended for production.** The CLI generates type-safe bindings automatically.

#### Step 1: Create TypeScript Definitions

```typescript
// my-services.d.ts
declare module 'my-services' {
  export class StorageService {
    static save(key: string, value: string): Promise<boolean>;
    static load(key: string): Promise<string | null>;
    static delete(key: string): Promise<boolean>;
  }

  export class ShareService {
    static shareText(text: string, subject?: string): Promise<boolean>;
    static shareImage(imageUrl: string): Promise<boolean>;
  }
}
```

#### Step 2: Generate Bindings

```bash
webf codegen my-services.d.ts \
  --flutter-package-src=../my_flutter_package \
  --type=module \
  --publish-to-npm
```

#### Step 3: Implement Generated Classes

The generator creates stub classes you fill in:

```dart
// Generated: lib/modules/storage_service.dart
import 'package:webf/webf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends WebFBaseModule {
  StorageService(super.moduleManager);

  @override
  String get name => 'StorageService';

  @override
  invoke(String method, params) async {
    switch (method) {
      case 'save':
        return await _save(params[0], params[1]);
      case 'load':
        return await _load(params[0]);
      case 'delete':
        return await _delete(params[0]);
      default:
        throw 'Unknown method: $method';
    }
  }

  Future<bool> _save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  Future<String?> _load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> _delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  @override
  void dispose() {}
}
```

#### Step 4: Register Module

```dart
void main() {
  WebFControllerManager.instance.initialize(...);

  WebF.defineModule((context) => StorageService(context));

  runApp(MyApp());
}
```

#### Step 5: Use in Your WebF App

```bash
npm install my-services
```

```typescript
import { StorageService } from 'my-services';

// Type-safe API calls
async function saveUserData() {
  const success = await StorageService.save('username', 'john_doe');
  if (success) {
    console.log('Saved!');
  }

  const username = await StorageService.load('username');
  console.log('Username:', username);
}
```

### Manual Setup for Plugins (for advanced understanding)

For learning or full control, implement modules manually.

#### Example: Share Module

```dart
import 'package:webf/webf.dart';
import 'package:share_plus/share_plus.dart';

class ShareModule extends WebFBaseModule {
  ShareModule(super.moduleManager);

  @override
  String get name => 'Share';

  @override
  invoke(String method, params) async {
    switch (method) {
      case 'shareText':
        return await _shareText(params);
      case 'shareImage':
        return await _shareImage(params);
      default:
        throw 'Unknown method: $method';
    }
  }

  Future<bool> _shareText(List<dynamic> params) async {
    try {
      String text = params[0];
      String? subject = params.length > 1 ? params[1] : null;

      await Share.share(text, subject: subject);
      return true;
    } catch (e) {
      print('Share failed: $e');
      return false;
    }
  }

  Future<bool> _shareImage(List<dynamic> params) async {
    try {
      // params[0] is NativeByteData from canvas
      final imageData = params[0] as NativeByteData;

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageData.bytes);

      await Share.shareXFiles([XFile(file.path)]);
      return true;
    } catch (e) {
      print('Share image failed: $e');
      return false;
    }
  }

  @override
  void dispose() {
    // Cleanup resources if needed
  }
}
```

#### Register and Use

```dart
// Register
WebF.defineModule((context) => ShareModule(context));
```

```javascript
// JavaScript side
async function shareContent() {
  // Call the module
  const success = await webf.invokeModule('Share', 'shareText', ['Check out WebF!', 'Sharing']);
  console.log('Share result:', success);
}
```

#### Advanced: Complex Data Types

```dart
class LocationModule extends WebFBaseModule {
  LocationModule(super.moduleManager);

  @override
  String get name => 'Location';

  @override
  invoke(String method, params) async {
    if (method == 'getCurrentPosition') {
      return await _getCurrentPosition();
    }
  }

  Future<Map<String, dynamic>> _getCurrentPosition() async {
    // Using geolocator package
    final position = await Geolocator.getCurrentPosition();

    // Return complex object - automatically serialized to JS
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'heading': position.heading,
      'speed': position.speed,
      'timestamp': position.timestamp.toIso8601String(),
    };
  }

  @override
  void dispose() {}
}
```

```javascript
// JavaScript - receives native objects
const location = await webf.invokeModule('Location', 'getCurrentPosition', []);
console.log(`Location: ${location.latitude}, ${location.longitude}`);
console.log(`Accuracy: ${location.accuracy}m`);
```

---

## 7. Advanced Topics

### Hybrid Routing

Hybrid routing synchronizes navigation between Flutter's Navigator (or go_router) and WebF's internal routing. This is essential for creating multi-route WebF apps.

#### Understanding WebFSubView

`WebFSubView` is the **essential entry point** for displaying sub-route pages in your WebF app. It works in conjunction with WebF's routing frameworks (`@openwebf/react-router`, `@openwebf/vue-router`) to enable seamless navigation between routes.

**Key concepts:**
- WebF apps define routes using `<router-link>` elements in your HTML/JSX
- Flutter displays these routes using `WebFSubView` widget
- Each route can have its own title and navigation bar styling

#### Basic Setup with go_router (Recommended)

```dart
import 'package:go_router/go_router.dart';
import 'package:webf/webf.dart';

final router = GoRouter(
  routes: [
    // Catch-all route for WebF app routes
    GoRoute(
      path: '/:webfPath(.*)',
      pageBuilder: (context, state) {
        final path = '/${state.pathParameters['webfPath']}';
        final controller = WebFControllerManager.instance.getControllerSync('app')!;

        return MaterialPage(
          child: WebFSubView(
            path: path,
            controller: controller,
            onAppBarCreated: (title, routeLinkElement) => AppBar(
              title: Text(title),
            ),
          ),
        );
      },
    ),
  ],
);

// Use in MaterialApp
MaterialApp.router(
  routerConfig: router,
)
```

#### Adaptive UI Styling (Material vs Cupertino)

WebFSubView supports platform-adaptive navigation bars:

```dart
GoRoute(
  path: '/:webfPath(.*)',
  pageBuilder: (context, state) {
    final path = '/${state.pathParameters['webfPath']}';
    final controller = WebFControllerManager.instance.getControllerSync('app')!;

    // Check theme attribute from router-link element
    final routeElement = controller.view.getHybridRouterView(path);
    final theme = routeElement?.getAttribute('theme') ?? 'material';

    if (theme == 'cupertino') {
      return CupertinoPage(
        child: WebFSubView(
          path: path,
          controller: controller,
          onAppBarCreated: (title, routeLinkElement) => CupertinoNavigationBar(
            middle: Text(title),
          ),
        ),
      );
    }

    return MaterialPage(
      child: WebFSubView(
        path: path,
        controller: controller,
        onAppBarCreated: (title, routeLinkElement) => AppBar(
          title: Text(title),
        ),
      ),
    );
  },
)
```

#### Complete Example with @openwebf/react-router

**Flutter Side:**
```dart
// 1. Pre-render controller with your WebF app
WebFControllerManager.instance.addWithPrerendering(
  name: 'app',
  createController: () => WebFController(),
  bundle: WebFBundle.fromUrl('https://myapp.com/'),
);

// 2. Set up go_router with WebFSubView
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/:webfPath(.*)',
      pageBuilder: (context, state) {
        final path = '/${state.pathParameters['webfPath']}';
        final controller = WebFControllerManager.instance.getControllerSync('app')!;

        return MaterialPage(
          child: WebFSubView(
            path: path,
            controller: controller,
            onAppBarCreated: (title, routeLinkElement) => AppBar(
              title: Text(title),
            ),
          ),
        );
      },
    ),
  ],
);
```

**React Side (with @openwebf/react-router):**
```jsx
import { Routes, Route, WebFRouter } from '@openwebf/react-router';

function App() {
  return (
    <div className="App">
      <Routes>
        <Route path="/" title="Home" element={<HomePage />} />
        <Route path="/profile" title="Profile" theme="cupertino" element={<ProfilePage />} />
        <Route path="/settings" title="Settings" element={<SettingsPage />} />
        <Route path="/network" title="Network Demo" element={<NetworkPage />} />
      </Routes>
    </div>
  );
}

function HomePage() {
  return (
    <div>
      <h1>Home Page</h1>
      {/* Programmatic navigation using WebFRouter API */}
      <button onClick={() => WebFRouter.push('/profile')}>
        Go to Profile
      </button>
      <button onClick={() => WebFRouter.pushState({ from: 'home' }, '/settings')}>
        Go to Settings (with state)
      </button>
    </div>
  );
}

function ProfilePage() {
  // Use navigation methods
  const goBack = () => WebFRouter.back();
  const replaceRoute = () => WebFRouter.replace('/settings');

  return (
    <div>
      <h1>Profile</h1>
      <button onClick={goBack}>Back</button>
      <button onClick={replaceRoute}>Replace with Settings</button>
    </div>
  );
}
```

**WebFRouter API Methods:**
```javascript
// Basic navigation
WebFRouter.push(path, state)           // Navigate to route with optional state
WebFRouter.replace(path, state)         // Replace current route
WebFRouter.back()                       // Go back
WebFRouter.pushState(state, path)       // HTML5-style pushState
WebFRouter.replaceState(state, path)    // HTML5-style replaceState

// Advanced Flutter-style methods
WebFRouter.popAndPushNamed(path, state) // Pop current and push new route
WebFRouter.canPop()                     // Check if can go back
WebFRouter.maybePop({ cancelled })      // Conditionally pop
WebFRouter.restorablePopAndPushNamed(path, state) // With restoration support
```

**Key Features:**
- `<Routes>` and `<Route>` components for defining app routes
- `title` attribute sets the navigation bar title in Flutter
- `theme` attribute controls Material vs Cupertino styling
- `WebFRouter` provides programmatic navigation
- `WebFSubView` on Flutter side displays the route content
- Each route automatically gets its own navigation bar via `onAppBarCreated`

### Performance Monitoring

WebF provides comprehensive performance monitoring through loading state events.

#### Monitoring Key Metrics

```dart
WebFController(
  onControllerInit: (controller) {
    // First Paint (FP)
    controller.loadingState.onFirstPaint((event) {
      print('FP: ${event.elapsed.inMilliseconds}ms');
    });

    // First Contentful Paint (FCP)
    controller.loadingState.onFirstContentfulPaint((event) {
      print('FCP: ${event.elapsed.inMilliseconds}ms');
    });

    // Largest Contentful Paint (LCP) - Most important
    controller.loadingState.onLargestContentfulPaint((event) {
      final isCandidate = event.parameters['isCandidate'] ?? false;
      final isFinal = event.parameters['isFinal'] ?? false;

      if (isFinal) {
        print('LCP (Final): ${event.elapsed.inMilliseconds}ms');
        // Log to analytics
      }
    });

    // DOM Content Loaded
    controller.loadingState.onDOMContentLoaded((event) {
      print('DOMContentLoaded: ${event.elapsed.inMilliseconds}ms');
    });

    // Window Load (all resources)
    controller.loadingState.onWindowLoad((event) {
      print('Window Load: ${event.elapsed.inMilliseconds}ms');
    });
  },
)
```

#### Detailed Performance Dump

```dart
controller.loadingState.onFinalLargestContentfulPaint((event) {
  final dump = controller.dumpLoadingState(
    options: LoadingStateDumpOptions.html |
              LoadingStateDumpOptions.api |
              LoadingStateDumpOptions.scripts |
              LoadingStateDumpOptions.networkDetailed,
  );

  print(dump.toStringFiltered());
  // Outputs: HTML parsing time, script execution, API calls, network requests
});
```

#### LCP Content Verification

```dart
WebFController(
  onLCPContentVerification: (contentInfo, routePath) {
    print('LCP element: ${contentInfo.tagName}');
    print('LCP area: ${contentInfo.width}x${contentInfo.height}');
    print('Route: $routePath');

    // Verify LCP is meaningful content, not loading spinner
    if (contentInfo.tagName == 'IMG' && contentInfo.width < 100) {
      print('Warning: LCP may be incorrect (small image)');
    }
  },
)
```

### Controlling Color Themes

Synchronize Flutter themes with your WebF app.

#### Basic Dark Mode Support

```dart
WebFController? _controller;

// When theme changes in Flutter
void onThemeChanged(bool isDarkMode) async {
  _controller?.darkModeOverride = isDarkMode;
  // This automatically:
  // 1. Updates prefers-color-scheme media query
  // 2. Dispatches 'colorschemchange' event
  // 3. Re-evaluates CSS with new color scheme
}

// In your UI
AdaptiveTheme.of(context).setDark(); // or setLight()
onThemeChanged(true);
```

#### In Your WebF App (CSS)

```css
/* Automatically responds to darkModeOverride */
@media (prefers-color-scheme: dark) {
  body {
    background-color: #1e1e1e;
    color: #ffffff;
  }
}

@media (prefers-color-scheme: light) {
  body {
    background-color: #ffffff;
    color: #000000;
  }
}
```

#### In Your WebF App (JavaScript)

```javascript
// Listen for theme changes
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
  if (e.matches) {
    console.log('Switched to dark mode');
    document.body.classList.add('dark');
  } else {
    console.log('Switched to light mode');
    document.body.classList.remove('dark');
  }
});

// Check current theme
const isDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
```

### Caching

WebF provides sophisticated caching for both HTTP resources and JavaScript bytecode.

#### HTTP Cache Configuration

```dart
// Set global cache mode
WebF.setHttpCacheMode(HttpCacheMode.cacheFirst);  // Default: cacheFirst

// Available modes:
// - HttpCacheMode.cacheFirst: Check cache first, then network
// - HttpCacheMode.networkOnly: Always fetch from network
// - HttpCacheMode.cacheOnly: Only use cache (fail if not cached)
```

#### Per-Controller Cache Settings

```dart
WebFController(
  networkOptions: WebFNetworkOptions(
    android: WebFNetworkOptions(
      httpClientAdapter: () async {
        // Use Cronet for advanced caching on Android
        final cacheDir = await HttpCacheController.getCacheDirectory(
          Uri.parse('https://myapp.com/')
        );

        final cronetEngine = CronetEngine.build(
          cacheMode: CacheMode.disk,
          cacheMaxSize: 50 * 1024 * 1024,  // 50MB
          enableBrotli: true,
          enableHttp2: true,
          enableQuic: true,
          storagePath: cacheDir,
        );

        return CronetAdapter(cronetEngine);
      },
      enableHttpCache: false,  // Cronet handles caching
    ),
  ),
)
```

#### Clear Caches

```dart
// Clear all caches (HTTP + bytecode)
await WebF.clearAllCaches();

// Or use controller-specific cache clearing
HttpCacheController.clearMemoryCache();
```

#### QuickJS Bytecode Cache

WebF automatically caches compiled JavaScript for faster subsequent loads:

```dart
// Bytecode cache is automatic, but you can configure:
// Location: <temp_dir>/ByteCodeCaches_<version>/
// Cleared by WebF.clearAllCaches()
```

### Sub-views

Sub-views allow embedding Flutter widgets at specific routes within your WebF app.

#### Define Route-Specific Widgets

```dart
WebFControllerManager.instance.addWithPrerendering(
  name: 'app',
  createController: () => WebFController(),
  bundle: WebFBundle.fromUrl('https://myapp.com/'),
  routes: {
    '/profile': (controller) {
      // Return Flutter widget for this route
      return CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Profile'),
            floating: true,
          ),
          SliverToBoxAdapter(
            child: WebFRouterView(
              controller: controller,
              path: '/profile',
            ),
          ),
        ],
      );
    },
    '/settings': (controller) {
      return ListView(
        children: [
          ListTile(
            title: Text('Flutter Setting'),
            onTap: () {},
          ),
          Container(
            height: 500,
            child: WebFRouterView(
              controller: controller,
              path: '/settings',
            ),
          ),
        ],
      );
    },
  },
);
```

#### Use Router View Widget

```dart
// Display WebF app for a specific route
WebFRouterView(
  controller: controller,
  path: '/profile',
)

// Or use with controller name
WebFRouterView.fromControllerName(
  controllerName: 'app',
  path: '/profile',
  builder: (context, controller) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: WebFRouterView(
        controller: controller,
        path: '/profile',
      ),
    );
  },
)
```

---

## 8. API Reference & Examples

### API Reference

#### Core Classes

- **`WebF`**: Main widget for displaying WebF apps ([webf/lib/src/widget/webf.dart](../webf/lib/src/widget/webf.dart))
- **`WebFController`**: Controls WebF instance lifecycle ([webf/lib/src/launcher/controller.dart](../webf/lib/src/launcher/controller.dart))
- **`WebFControllerManager`**: Manages multiple controllers ([webf/lib/src/launcher/controller_manager.dart](../webf/lib/src/launcher/controller_manager.dart))
- **`WebFBundle`**: Specifies content source ([webf/lib/src/launcher/bundle.dart](../webf/lib/src/launcher/bundle.dart))
- **`WidgetElement`**: Base for custom elements ([webf/lib/src/widget/widget_element.dart](../webf/lib/src/widget/widget_element.dart))
- **`WebFBaseModule`**: Base for Dart modules ([webf/lib/src/module/module_manager.dart](../webf/lib/src/module/module_manager.dart))

#### Key APIs

**WebFController Methods**:
```dart
controller.evaluateJavaScript(code)
controller.hybridHistory.pushState(state, path)
controller.hybridHistory.back()
controller.reload()
controller.view.document.getElementById(id)
controller.darkModeOverride = bool
```

**WebFControllerManager Methods**:
```dart
await WebFControllerManager.instance.getController(name)
await WebFControllerManager.instance.addWithPreload(...)
await WebFControllerManager.instance.addWithPrerendering(...)
await WebFControllerManager.instance.disposeController(name)
```

**Custom Element APIs**:
```dart
WebF.defineCustomElement(tagName, creator)
widgetElement.getAttribute(name)
widgetElement.setAttribute(name, value)
widgetElement.dispatchEvent(event)
```

**Module APIs**:
```dart
WebF.defineModule(creator)
webf.invokeModule(moduleName, method, params)
```

### Examples

The WebF repository includes comprehensive examples:

#### 1. Main Example App
Location: `webf/example/`

Demonstrates:
- Multiple custom elements (button, slider, tabs, etc.)
- Module integration (share, storage)
- Hybrid routing
- Dark mode theming
- Pre-rendering and preloading

Key files:
- `lib/main.dart` - App setup and controller registration
- `lib/custom_elements/` - Custom element implementations
- `lib/modules/` - Module implementations

#### 2. React Integration
Shows React apps running in WebF with:
- React Router integration
- Material-UI components
- Custom hooks for WebF APIs

#### 3. Vue Integration
Demonstrates:
- Vue Router with hybrid navigation
- Vuex state management
- Composition API patterns

#### 4. Performance Demo
Location: `webf/example/` → MiraclePlus App

Production-quality app showing:
- Optimal loading strategies
- LCP monitoring
- HTTP caching with Cronet
- DevTools integration

#### Running Examples

```bash
# Clone repository
git clone https://github.com/openwebf/webf.git
cd webf/webf/example

# Install dependencies
flutter pub get

# Run example app
flutter run

# Try different demos from the landing page
```

---

## Additional Resources

- **GitHub**: https://github.com/openwebf/webf
- **Documentation**: https://webf.dev
- **Discord Community**: https://discord.gg/DvUBtXZ5rK
- **API Docs**: https://pub.dev/documentation/webf/latest/

## Contributing

WebF is open source! Contributions are welcome:
- Report issues: https://github.com/openwebf/webf/issues
- Submit PRs: https://github.com/openwebf/webf/pulls
- Join discussions: https://github.com/openwebf/webf/discussions
