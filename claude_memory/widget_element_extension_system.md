# WidgetElement Extension System

## Overview
The WidgetElement extension system in WebF allows developers to create custom HTML elements that are rendered using Flutter widgets while maintaining full compatibility with the DOM and CSS systems. This provides a bridge between web technologies and Flutter's widget system.

## Core Components

### WidgetElement (`webf/lib/src/widget/widget_element.dart`)
Abstract base class for custom elements rendered by Flutter widgets.

#### Key Features:
- Extends `dom.Element` to provide full DOM API compatibility
- Manages widget state through `WebFWidgetElementState` instances
- Provides lifecycle callbacks for reactive updates
- Uses `RenderObjectManagerType.FLUTTER_ELEMENT` for rendering
- Supports `disableBoxModelPaint` property for custom painting control

#### Lifecycle Methods:
```dart
void attributeDidUpdate(String key, String value) {}
void propertyDidUpdate(String key, value) {}
void styleDidUpdate(String property, String value) {}
bool shouldElementRebuild(String key, previousValue, nextValue) {}
```

#### State Management:
- Maintains a set of `WebFWidgetElementState` instances
- Automatically triggers state updates when attributes/properties change
- Provides access to current state via `state` getter

### RenderWidget (`webf/lib/src/rendering/widget.dart`)
RenderBox implementation for widget elements.

#### Key Features:
- Extends `RenderBoxModel` with container capabilities
- Handles layout for positioned, sticky, and normal flow children
- Reports performance metrics (FP/FCP/LCP) for contentful widgets
- Respects `disableBoxModelPaint` flag from WidgetElement
- Manages paint offset calculations for fixed position elements

#### Paint Behavior:
- Default: Calls `paintBoxModel()` for standard box model painting
- With `disableBoxModelPaint = true`: Calls `performPaint()` directly
- Reports performance metrics when contentful content is painted

### Supporting Classes

#### WidgetElementAdapter
- Converts WidgetElement to Flutter StatefulWidget
- Creates `WebFWidgetElementAdapterElement` for the widget tree
- Handles display:none by returning `SizedBox.shrink()`

#### WebFWidgetElementState
- Abstract state class for custom widget elements
- Provides `requestUpdateState()` for triggering rebuilds
- Manages widget lifecycle and disposal

#### RenderWidgetElement
- MultiChildRenderObjectElement implementation
- Handles mount/unmount lifecycle with renderer attachment
- Dispatches OnScreenEvent/OffScreenEvent for navigation awareness

## Usage Pattern

### Creating a Custom Element

```dart
class MyCustomElement extends WidgetElement {
  MyCustomElement(BindingContext? context) : super(context);
  
  @override
  WebFWidgetElementState createState() => MyCustomElementState(this);
  
  @override
  void attributeDidUpdate(String key, String value) {
    // React to attribute changes
  }
  
  // Optional: Disable box model painting for custom rendering
  @override
  bool get disableBoxModelPaint => true;
}

class MyCustomElementState extends WebFWidgetElementState {
  MyCustomElementState(MyCustomElement element) : super(element);
  
  @override
  Widget build(BuildContext context) {
    // Build your Flutter widget tree here
    return Container(
      child: Text('Custom Element'),
    );
  }
}
```

### Registration and Usage

Custom elements can be registered and used like standard HTML elements:
- Supports all DOM operations (appendChild, setAttribute, etc.)
- Integrates with CSS styling and layout
- Handles WebF events through `WebFEventListener`
- Works with positioned elements (absolute/fixed/sticky)

## Performance Considerations

### Metrics Reporting
- **FP (First Paint)**: Reported when any visual change occurs
- **FCP (First Contentful Paint)**: Reported when contentful widgets are painted
- **LCP (Largest Contentful Paint)**: Tracks the largest contentful element

### Contentful Detection
- Uses `ContentfulWidgetDetector.getContentfulPaintAreaFromFlutterWidget()`
- Only considers render objects created by the widget's build method
- Skips RenderBoxModel and RenderWidget children to avoid duplicates

## Advanced Features

### Position Handling
- Supports all CSS position types (static, relative, absolute, fixed, sticky)
- Fixed position elements adjust for scroll offset during painting
- Sticky children are tracked in a dedicated set for offset calculations

### Event Integration
- OnScreenEvent: Dispatched when element becomes visible (mount)
- OffScreenEvent: Dispatched when element is removed (unmount)
- Includes route information for navigation-aware widgets

### Custom Painting
When `disableBoxModelPaint = true`:
- Skips standard box model painting (borders, background, etc.)
- Directly calls `performPaint()` for complete custom rendering
- Useful for widgets that manage their own visual appearance

## Best Practices

1. **State Management**: Use `shouldElementRebuild()` to control when updates trigger rebuilds
2. **Memory Management**: Widget states are automatically cleaned up on disposal
3. **Performance**: Leverage `disableBoxModelPaint` when box model features aren't needed
4. **DOM Integration**: Always call super methods when overriding DOM operations
5. **Layout**: Consider using intrinsic sizing for better integration with web layout

## Common Use Cases

1. **Complex UI Components**: Date pickers, charts, custom controls
2. **Media Players**: Video/audio players with Flutter controls
3. **Canvas Elements**: Custom drawing surfaces
4. **Third-party Widgets**: Integration of Flutter packages as HTML elements
5. **Performance-critical UI**: Elements requiring optimized rendering paths

## CLI Codegen Integration

The WidgetElement system is designed to work seamlessly with the WebF CLI's code generation capabilities, enabling automatic creation of type-safe React/Vue components from Flutter widget implementations.

### Architecture Overview

The codegen process follows a three-layer architecture:

1. **TypeScript Definitions** (`.d.ts` files in Flutter package)
   - Define component properties and events interfaces
   - Serve as the source of truth for the component API
   - Example: `button.d.ts` defines `FlutterCupertinoButtonProperties` and `FlutterCupertinoButtonEvents`

2. **Generated Dart Bindings** (`*_bindings_generated.dart`)
   - Auto-generated abstract classes with property/attribute bindings
   - Handle type conversion between JavaScript and Dart
   - Provide attribute getters/setters with proper type coercion

3. **Manual Flutter Implementation** (`*.dart`)
   - Extends the generated bindings
   - Implements actual Flutter widget rendering
   - Handles state management and lifecycle

### Codegen Process

```bash
# Generate React components
webf codegen output-dir --flutter-package-src=/path/to/flutter/package --framework=react

# Generate Vue components
webf codegen output-dir --flutter-package-src=/path/to/flutter/package --framework=vue
```

The CLI:
1. Analyzes TypeScript definitions in the Flutter package
2. Generates Dart binding classes with property/attribute mappings
3. Creates React/Vue components with proper TypeScript types
4. Sets up build configuration and package structure

### Component Structure Example

**TypeScript Definition** (`button.d.ts`):
```typescript
interface FlutterCupertinoButtonProperties {
  variant?: string;
  size?: string;
  disabled?: boolean;
  'pressed-opacity'?: string;
}

interface FlutterCupertinoButtonEvents {
  click: Event;
}
```

**Generated Dart Bindings** (`button_bindings_generated.dart`):
```dart
abstract class FlutterCupertinoButtonBindings extends WidgetElement {
  String? get variant;
  set variant(value);
  
  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    attributes['variant'] = ElementAttributeProperty(
      getter: () => variant?.toString(),
      setter: (value) => variant = value,
      deleter: () => variant = null
    );
  }
}
```

**Flutter Implementation** (`button.dart`):
```dart
class FlutterCupertinoButton extends FlutterCupertinoButtonBindings {
  @override
  WebFWidgetElementState createState() => FlutterCupertinoButtonState(this);
}
```

**Generated React Component** (`button.tsx`):
```tsx
import { createWebFComponent } from '@openwebf/webf-react-core-ui';

export const FlutterCupertinoButton = createWebFComponent<
  FlutterCupertinoButtonProps,
  FlutterCupertinoButtonElement
>('flutter-cupertino-button', {
  variant: { type: 'string' },
  size: { type: 'string' },
  disabled: { type: 'boolean' },
  pressedOpacity: { type: 'string', attribute: 'pressed-opacity' }
}, {
  onClick: 'click'
});
```

### Registration

Components are registered in the Flutter package using `WebF.defineCustomElement()`:

```dart
void installWebFCupertinoUI() {
  WebF.defineCustomElement('flutter-cupertino-button', 
    (context) => FlutterCupertinoButton(context));
  // ... register other components
}
```

### Type Safety Features

1. **Property Type Conversion**: Automatic conversion between JS and Dart types
   - Strings to enums/numbers/booleans
   - Kebab-case attributes to camelCase properties
   - Boolean attributes supporting both `attr="true"` and presence detection

2. **Event Handling**: Type-safe event mapping
   - Flutter `dispatchEvent()` to React/Vue event handlers
   - Proper event object typing

3. **CSS Integration**: Full CSS property support
   - Access to `renderStyle` for reading CSS values
   - Automatic style recalculation on property changes

### Best Practices for Codegen-Compatible Elements

1. **TypeScript Definitions**:
   - Keep interfaces simple and flat
   - Use standard web types where possible
   - Document properties with JSDoc comments

2. **Property Implementation**:
   - Implement getters/setters in the bindings class
   - Handle null/undefined gracefully
   - Provide sensible defaults

3. **State Updates**:
   - Call `state.requestUpdateState()` when properties change
   - Use `shouldElementRebuild()` to optimize updates

4. **Component Naming**:
   - Use consistent prefixes (e.g., `flutter-cupertino-`)
   - Match TypeScript interface names to Dart class names

This integration enables developers to create Flutter-based components that can be consumed as native React/Vue components with full type safety and IDE support.

## WidgetElement API Reference

The WidgetElement system provides a comprehensive API for JavaScript interoperability, with most features automatically generated by the CLI from TypeScript definitions.

### Properties (CLI-Generated)

Properties are defined in TypeScript interfaces and automatically generate Dart bindings:

**TypeScript Definition:**
```typescript
interface FlutterCupertinoButtonProperties {
  variant?: string;
  size?: string;
  disabled?: boolean;
  'pressed-opacity'?: string;
}
```

**Generated Dart Bindings:**
- Abstract getters/setters in `*_bindings_generated.dart`
- Automatic type conversion (string ↔ bool, string ↔ number)
- Property-to-attribute synchronization
- JavaScript property access through static maps

**Implementation Pattern:**
```dart
class MyElement extends MyElementBindings {
  String _variant = 'default';
  
  @override
  String get variant => _variant;
  
  @override
  set variant(value) {
    _variant = value;
    state?.requestUpdateState();
  }
}
```

### Attributes (CLI-Generated)

HTML attributes are automatically mapped to properties with type conversion:

**Generated Attribute Initialization:**
```dart
@override
void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
  super.initializeAttributes(attributes);
  
  // Boolean attribute with presence detection
  attributes['disabled'] = ElementAttributeProperty(
    getter: () => disabled.toString(),
    setter: (value) => disabled = value == 'true' || value == '',
    deleter: () => disabled = false
  );
  
  // Numeric attribute with parsing
  attributes['background-opacity'] = ElementAttributeProperty(
    getter: () => backgroundOpacity?.toString(),
    setter: (value) => backgroundOpacity = double.tryParse(value) ?? 0.0,
    deleter: () => backgroundOpacity = null
  );
}
```

**Features:**
- Kebab-case to camelCase conversion
- Type coercion (string → bool/number/enum)
- Null handling with deleters
- Bidirectional synchronization

### Methods (CLI-Generated)

Synchronous methods exposed to JavaScript:

**TypeScript Definition:**
```typescript
interface MyElementMethods {
  show(): void;
  hide(): void;
  setActions(actions: Array<{label: string, event?: string}>): void;
}
```

**Generated Method Map:**
```dart
static StaticDefinedSyncBindingObjectMethodMap myElementMethods = {
  'show': StaticDefinedSyncBindingObjectMethod(
    call: (element, args) {
      return castToType<MyElement>(element).show(args);
    },
  ),
  'setActions': StaticDefinedSyncBindingObjectMethod(
    call: (element, args) {
      final elem = castToType<MyElement>(element);
      if (args.isNotEmpty && args[0] is List) {
        elem.setActions(args[0]);
      }
    },
  ),
};
```

**Complex Method Implementation:**
```dart
void setActions(List<dynamic> actions) {
  _actions = actions.map((item) {
    if (item is Map) {
      return Map<String, dynamic>.from(item);
    }
    return <String, dynamic>{};
  }).toList();
  state?.requestUpdateState();
}
```

### Events (Manual Implementation)

Events must be manually implemented as they're not generated by the CLI:

**Standard DOM Events:**
```dart
// Click event
CupertinoButton(
  onPressed: () {
    widgetElement.dispatchEvent(Event('click'));
  },
)
```

**Custom Events with Detail:**
```dart
// Change event with data
onSelectedItemChanged: (index) {
  final value = getValueAtIndex(index);
  widgetElement.dispatchEvent(CustomEvent('change', detail: value));
}

// Close event after async operation
showCupertinoModalPopup(...).then((_) {
  widgetElement.dispatchEvent(CustomEvent('close'));
});
```

**Dynamic Event Names:**
```dart
// Event name from data
final eventName = action['event'] as String? ?? 'press';
onPressed: () {
  widgetElement.dispatchEvent(CustomEvent(eventName));
}
```

**React/Vue Event Binding:**
```tsx
// React component (generated)
import { createWebFComponent } from '@openwebf/webf-react-core-ui';

export const MyElement = createWebFComponent<...>({
  events: [{
    propName: 'onChange',
    eventName: 'change',
    handler: (callback) => (event) => {
      callback((event as CustomEvent).detail);
    },
  }],
});
```

### Async Methods (Future Support)

While the current examples don't show async methods, the architecture supports them:

**TypeScript Definition (proposed):**
```typescript
interface MyElementAsyncMethods {
  fetchData(): Promise<string>;
  saveState(): Promise<boolean>;
}
```

**Dart Implementation Pattern:**
```dart
Future<String> fetchData() async {
  // Async operation
  final result = await performAsyncWork();
  return result;
}
```

### Lifecycle Integration

The WidgetElement lifecycle hooks enable reactive updates:

```dart
// Property change notification
@override
void propertyDidUpdate(String key, value) {
  if (key == 'variant') {
    _updateVariant(value);
  }
}

// Attribute change notification
@override
void attributeDidUpdate(String key, String value) {
  // React to attribute changes
}

// Style change notification
@override
void styleDidUpdate(String property, String value) {
  // React to CSS changes
}

// Control rebuild behavior
@override
bool shouldElementRebuild(String key, previousValue, nextValue) {
  // Optimize rebuilds
  return previousValue != nextValue;
}
```

### JavaScript Usage

The generated components provide type-safe JavaScript/TypeScript usage:

```typescript
// React
<FlutterCupertinoButton
  variant="filled"
  size="large"
  disabled={false}
  onClick={(e) => console.log('clicked')}
>
  Click Me
</FlutterCupertinoButton>

// Vanilla JavaScript
const button = document.createElement('flutter-cupertino-button');
button.variant = 'filled';
button.addEventListener('click', (e) => console.log('clicked'));
button.show(); // Call method
```

This comprehensive API enables full bidirectional communication between Flutter widgets and JavaScript, maintaining type safety and reactive updates throughout the system.

## Building Flutter Widgets for Custom Elements

When implementing custom elements, Flutter developers have access to key properties from the WidgetElement to build rich, interactive widgets.

### Accessing Child Nodes

The `widgetElement.childNodes` provides access to DOM children that can be rendered as Flutter widgets:

```dart
@override
Widget build(BuildContext context) {
  // Render child nodes as Flutter widgets
  Widget buttonChild = WebFWidgetElementChild(
    child: widgetElement.childNodes.isEmpty
        ? const SizedBox()
        : widgetElement.childNodes.first.toWidget()
  );
  
  // Use in Flutter widget
  return CupertinoButton(
    child: buttonChild,
    onPressed: () { /* ... */ },
  );
}
```

**WebFWidgetElementChild** wrapper:
- Provides proper constraint passing to inner HTML elements
- Ensures correct layout integration between Flutter and WebF
- Handles empty child nodes gracefully

### Using RenderStyle

Access CSS properties through `widgetElement.renderStyle` to style Flutter widgets:

```dart
@override
Widget build(BuildContext context) {
  final renderStyle = widgetElement.renderStyle;
  
  // Extract CSS values
  final hasWidth = renderStyle.width.computedValue != 0.0;
  final hasHeight = renderStyle.height.computedValue != 0.0;
  final hasPadding = renderStyle.padding != EdgeInsets.zero;
  final hasBorderRadius = renderStyle.borderRadius != null;
  final backgroundColor = _parseCSSColor(renderStyle.backgroundColor);
  final textAlign = renderStyle.textAlign;
  
  // Apply to Flutter widgets
  return Container(
    width: hasWidth ? renderStyle.width.computedValue : null,
    padding: hasPadding ? renderStyle.padding : getDefaultPadding(),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: hasBorderRadius 
          ? BorderRadius.circular(renderStyle.borderRadius!.first.x)
          : BorderRadius.circular(8),
    ),
    child: /* ... */,
  );
}
```

### Common Patterns

#### 1. Conditional Rendering Based on CSS
```dart
// Handle display: none
if (widgetElement.renderStyle.display == CSSDisplay.none) {
  return SizedBox.shrink();
}
```

#### 2. Alignment from Text-Align
```dart
AlignmentGeometry alignment;
switch (renderStyle.textAlign) {
  case TextAlign.left:
    alignment = Alignment.centerLeft;
    break;
  case TextAlign.right:
    alignment = Alignment.centerRight;
    break;
  default:
    alignment = Alignment.center;
}
```

#### 3. Responsive Sizing
```dart
// Use CSS values with fallbacks
minSize: hasMinHeight 
    ? renderStyle.minHeight.value 
    : widgetElement.getDefaultMinSize(),
```

#### 4. Multiple Children Handling
```dart
// Iterate through all child nodes
List<Widget> children = widgetElement.childNodes
    .map((node) => node.toWidget())
    .toList();

// Or filter specific types
final textNodes = widgetElement.childNodes
    .whereType<dom.Text>()
    .map((text) => Text(text.data))
    .toList();
```

#### 5. CSS Color Parsing
```dart
Color? _parseCSSColor(CSSColor? color) {
  if (color == null) return null;
  return color.value;
}
```

### Advanced Integration

#### Fixed Position Elements
```dart
@override
Widget build(BuildContext context) {
  List<Widget> children = [mainChild];
  
  // Add fixed position elements
  widgetElement.fixedPositionElements.forEach((element) {
    children.add(element.toWidget());
  });
  
  return Stack(children: children);
}
```

#### Theme Integration
```dart
final theme = CupertinoTheme.of(context);
final isDark = theme.brightness == Brightness.dark;

// Apply theme-aware colors
Color getDisabledColor() {
  return isDark
      ? CupertinoColors.systemGrey4.darkColor
      : CupertinoColors.systemGrey4;
}
```

### Best Practices

1. **Always use WebFWidgetElementChild** for wrapping child nodes to ensure proper constraint handling
2. **Check for CSS values** before applying them (hasWidth, hasPadding, etc.)
3. **Provide sensible defaults** when CSS values are not specified
4. **Respect CSS display property** - return SizedBox.shrink() for display:none
5. **Parse CSS values carefully** - use helper methods for type conversion
6. **Consider theme context** when applying colors and styles
7. **Handle empty childNodes** gracefully with fallback widgets

### Example: Complete Custom Element Widget

```dart
class MyCustomElementState extends WebFWidgetElementState {
  @override
  Widget build(BuildContext context) {
    final renderStyle = widgetElement.renderStyle;
    
    // Handle display none
    if (renderStyle.display == CSSDisplay.none) {
      return SizedBox.shrink();
    }
    
    // Process child nodes
    Widget child = WebFWidgetElementChild(
      child: widgetElement.childNodes.isEmpty
          ? Text('Default Content')
          : Column(
              children: widgetElement.childNodes
                  .map((node) => node.toWidget())
                  .toList(),
            ),
    );
    
    // Apply CSS styling
    return Container(
      width: renderStyle.width.isAuto ? null : renderStyle.width.computedValue,
      height: renderStyle.height.isAuto ? null : renderStyle.height.computedValue,
      padding: renderStyle.padding,
      margin: renderStyle.margin,
      decoration: BoxDecoration(
        color: renderStyle.backgroundColor?.value,
        borderRadius: renderStyle.borderRadius != null
            ? BorderRadius.circular(renderStyle.borderRadius!.first.x)
            : null,
      ),
      child: child,
    );
  }
}
```

This approach allows Flutter developers to create custom elements that seamlessly integrate with WebF's DOM and CSS systems while leveraging the full power of Flutter's widget system.