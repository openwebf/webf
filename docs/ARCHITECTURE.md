# WebF Architecture Pipeline

## UICommand → Element → Widget → RenderObject Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   C++ Bridge Layer                                  │
│  ┌─────────────────┐                                                               │
│  │   JavaScript    │  DOM Mutations                                                │
│  │   Runtime       ├──────────────┐                                                │
│  │  (QuickJS)      │              │                                                │
│  └─────────────────┘              ▼                                                │
│                           ┌─────────────────┐                                      │
│                           │   UICommand     │                                      │
│                           │   Generator     │                                      │
│                           └────────┬────────┘                                      │
│                                    │                                                │
│                                    │ UICommand[]                                    │
└────────────────────────────────────┼───────────────────────────────────────────────┘
                                     │
                                     │ FFI (ui_command.dart)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                 Dart/Flutter Layer                                  │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │                          WebFViewController                                  │  │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │  │
│  │  │ execUICommands()│───▶│ createElement() │    │ setInlineStyle()│        │  │
│  │  └─────────────────┘    └────────┬────────┘    └────────┬────────┘        │  │
│  └────────────────────────────────────┼─────────────────────┼──────────────────┘  │
│                                       │                     │                       │
│                                       ▼                     ▼                       │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │                              DOM Layer                                       │  │
│  │  ┌──────────────┐         ┌──────────────┐         ┌──────────────┐       │  │
│  │  │   Element    │◀────────│   Document   │────────▶│   TextNode   │       │  │
│  │  │              │         └──────────────┘         └──────────────┘       │  │
│  │  │ ┌──────────┐ │                                                          │  │
│  │  │ │renderStyle│ │         CSS Processing                                  │  │
│  │  │ └──────────┘ │         ┌──────────────┐                               │  │
│  │  └───────┬──────┘         │CSSRenderStyle│                               │  │
│  │          │                └───────┬──────┘                               │  │
│  │          └────────────────────────┘                                       │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                           │
│                                       │ toWidget()                                │
│                                       ▼                                           │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │                          Widget Adapter Layer                                │  │
│  │  ┌──────────────────┐      ┌────────────────────┐      ┌─────────────────┐ │  │
│  │  │ElementAdapterMixin│     │ WebFElementWidget  │      │WebFElementWidget│ │  │
│  │  │                   │────▶│   (StatefulWidget) │────▶│      State      │ │  │
│  │  └──────────────────┘      └────────────────────┘      └────────┬────────┘ │  │
│  └───────────────────────────────────────────────────────────────────┼──────────┘  │
│                                                                       │              │
│                                                                       │ build()      │
│                                                                       ▼              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │                           RenderObject Layer                                 │  │
│  │  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐ │  │
│  │  │  RenderBoxModel  │      │ RenderFlowLayout │      │ RenderFlexLayout │ │  │
│  │  │  (Base Class)    │◀─────┤  (Block/Inline)  │      │   (Flexbox)      │ │  │
│  │  │                  │      └──────────────────┘      └──────────────────┘ │  │
│  │  │ ┌─────────────┐  │                                                      │  │
│  │  │ │ Box Model   │  │      ┌──────────────────┐      ┌──────────────────┐ │  │
│  │  │ │ ┌─────────┐ │  │      │  RenderReplaced  │      │   RenderWidget   │ │  │
│  │  │ │ │ margin  │ │  │◀─────┤   (img, video)   │      │ (Custom Widgets) │ │  │
│  │  │ │ │ border  │ │  │      └──────────────────┘      └──────────────────┘ │  │
│  │  │ │ │ padding │ │  │                                                      │  │
│  │  │ │ └─────────┘ │  │      ┌──────────────────┐                          │  │
│  │  │ └─────────────┘  │      │   Flutter Render  │                          │  │
│  │  └──────────────────┘      │      Tree         │                          │  │
│  │                             └──────────────────┘                          │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                                   │
└─────────────────────────────────────────────────────────────────────────────────┘

Key Components:

1. UICommand: Bridge layer commands (createElement, setStyle, setAttribute)
2. WebFViewController: Processes commands and manages DOM updates
3. Element/CSSRenderStyle: DOM tree and computed styles
4. ElementAdapterMixin: Bridges DOM elements to Flutter widgets
5. WebFElementWidget: StatefulWidget wrapper for elements
6. RenderBoxModel: Base render object implementing CSS box model
7. Specialized RenderObjects: Flow, Flex, Replaced, Widget variants

Data Flow:
- Commands flow from C++ → Dart via FFI
- Elements maintain DOM structure and styles
- Widget adapters convert elements to Flutter widgets
- RenderObjects handle layout and painting in Flutter's render tree
```

## Key Architecture Concepts

### 1. C++ Bridge Layer
The C++ bridge layer (`bridge/`) contains:
- **JavaScript Runtime**: QuickJS engine for executing JavaScript
- **DOM API Implementation**: Native C++ implementation of DOM APIs
- **HTML Parser**: Parses HTML and generates DOM mutations
- **UICommand Generator**: Converts DOM mutations into UICommands

### 2. FFI Communication
The Foreign Function Interface (FFI) enables communication between C++ and Dart:
- UICommands are serialized in C++ and sent to Dart
- Dart callbacks can be invoked from C++
- Memory management is critical at this boundary

### 3. Dart/Flutter Layer
The Dart layer (`webf/`) processes UICommands and manages the Flutter UI:
- **WebFViewController**: Central controller that processes UICommands
- **DOM Implementation**: Dart implementation of DOM tree
- **CSS Engine**: Computes styles and manages inheritance
- **Layout Engine**: Custom render objects for CSS layout

### 4. Widget Adapter Pattern
Elements are converted to Flutter widgets through adapters:
- **ElementAdapterMixin**: Provides toWidget() method
- **WebFElementWidget**: StatefulWidget that wraps elements
- Allows seamless integration with Flutter's widget tree

### 5. RenderObject Specialization
Different render objects handle different layout modes:
- **RenderFlowLayout**: Block and inline layout
- **RenderFlexLayout**: Flexbox layout
- **RenderReplaced**: Images, videos, and other replaced elements
- **RenderWidget**: Custom Flutter widgets embedded in WebF

## Thread Model

### JavaScript Thread
- Runs QuickJS engine
- Executes JavaScript code
- Generates UICommands
- Isolated from UI thread for performance

### UI Thread (Dart Isolate)
- Processes UICommands
- Updates DOM tree
- Triggers Flutter rebuilds
- Handles user interactions

### Communication Patterns
- **Async**: PostToJs/PostToDart for most operations
- **Sync**: PostToJsSync for critical operations (use sparingly)
- **Ring Buffer**: High-performance command queue

## Memory Management

### C++ Side
- RAII patterns for automatic cleanup
- Reference counting for shared objects
- Careful string management across boundaries

### Dart Side
- Garbage collection handles most cases
- Manual cleanup for FFI allocations
- Persistent handles for async operations

### FFI Boundary
- Copy strings when crossing boundaries
- Use persistent handles for async callbacks
- Free native memory explicitly

## Performance Considerations

### Command Batching
- UICommands are batched for efficiency
- Reduces FFI overhead
- Processed in frame boundaries

### Layout Optimization
- Incremental layout updates
- Caching of computed styles
- Efficient render tree updates

### Memory Optimization
- Object pooling for frequent allocations
- Lazy initialization of properties
- Efficient data structures

## Extension Points

### Custom Elements
- Register custom element types
- Implement custom render objects
- Integrate native Flutter widgets

### Custom Properties
- Extend CSS property support
- Add custom layout algorithms
- Implement new visual effects

### DevTools Integration
- Performance monitoring
- Network inspection
- DOM tree visualization