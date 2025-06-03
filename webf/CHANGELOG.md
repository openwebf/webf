## 0.21.4+2

🐛 Bug Fixes

- Fixed race condition in EventTarget disposal (https://github.com/openwebf/webf/commit/4ece049c5)
  - Defers freeing of pointers with pending events until controller disposal
  - Prevents potential crashes when EventTarget objects are garbage collected while still dispatching events
  - Adds separate tracking for pointers with pending events using _pendingPointersWithEvents list
  - Increases batch threshold from 500 to 2000 for better performance

## 0.21.4+1

🐛 Bug Fixes

- Fixed WebFTextElement not updating when React.js changes TextNode data (https://github.com/openwebf/webf/commit/70fd51128)
  - Added proper update mechanism for text elements when React.js modifies TextNode data directly
  - Resolved issue where React text updates weren't reflected in the UI
  - Implemented notifyRootTextElement() method to update ancestor WebFTextElement nodes
  - Added comprehensive test coverage for text element updates
- Fixed preloaded bundle disposal issue for SVG images (https://github.com/openwebf/webf/commit/2b6e8a4da)
  - Prevented disposal of preloaded bundles after first use
  - Ensured preloaded SVG images can be efficiently reused across multiple img elements
  - Added proper bundle lifecycle management for preloaded resources
- Fixed text span edge case (https://github.com/openwebf/webf/commit/77090f40e)
  - Added proper bounds checking in WebFTextSpan to prevent substring index out of bounds errors
  - Improved text content extraction safety

✨ Features

- Added ListView properties support (https://github.com/openwebf/webf/commit/574c0d867)
  - Added support for shrinkWrap: false in ListView components

🔧 Chores

- Added android:use-prebuilt npm script for Android package building (https://github.com/openwebf/webf/commit/77090f40e)

## v0.21.4

### 🚀 New Features

#### Developer Tools

- **WebF Inspector**: Added a floating inspector panel for real-time WebF controller management and debugging
  - View active, detached, and disposed controller counts
  - Monitor controller states and configurations
  - Bulk disposal of controllers for testing
  - Visual debugging interface for development

#### Performance & Memory Management

- **Idle Scheduling for Memory Cleanup**: Implemented batch freeing of native binding objects during idle time
  - Processes up to 100 pointers per idle frame to avoid UI blocking
  - Automatic batch cleanup when threshold (500 pointers) is reached
  - Improved memory management and reduced overhead

#### Build System

- **iOS Prebuilt Framework Support**: Added scripts to use prebuilt frameworks instead of source compilation
  - `npm run ios:use-prebuilt`: Switch to xcframework usage
  - `npm run ios:use-source`: Revert to source compilation
  - Significantly reduces pod install time for iOS builds

#### Platform Features
- **Method Channel Timeout**: Added configurable timeout limits for WebF method channel calls to prevent hanging

### 🐛 Bug Fixes

#### CSS & Styling
- **CSS Variables with display:none**: Fixed CSS variables not updating correctly for elements with `display: none`
- **Gradient Cache**: Improved gradient cache invalidation with comprehensive test coverage
- **Flexbox Constraints**: Fixed maxHeight constraints not being properly applied to flex items
- **Transition Animations**: Fixed transitions not triggering when elements are mounted

#### Memory & Resource Management
- **Image Memory Leak**: Fixed BoxFitImage holding controller instances causing memory leaks
- **Animation Parsing**: Fixed CSS animation parsing issues when controller is detached or disposed

#### Platform-Specific
- **iOS Compilation**: Fixed iOS compilation issues

## 0.21.3

🚀 New Features

Memory Management

- Batch cleanup system for native binding objects - Implemented efficient memory cleanup with
  batchFreeNativeBindingObjects C++ function and IdleCleanupManager to schedule cleanup operations
  during idle time, reducing memory
  fragmentation and preventing main thread blocking

ListView Enhancements

- resetHeader and resetFooter API - Added new APIs for ListView element to programmatically reset
  header and footer components

HTML & Preloading

- HTML link preloading - Added support for <link rel="preload"> with 'as' attribute for resource
  preloading
- Programmatic preloading - Added addPreloadedBundle method to WebFController

Text & Layout

- Text reflow in flex containers - Improved dynamic height adjustment of text and inline elements
  within flex containers with proper text reflow when container width changes
- Text overflow and line clamp - Added support for setting text overflow and line clamp properties
  on text elements

🐛 Bug Fixes

Layout & Rendering

- Flex content size calculation - Fixed incorrect maxHeight clamping in flex content size
  calculation and removed maxHeight constraint from content size calculation
- Scrollable overflow - Fixed scrollable exception with overflow hidden
- Route link activation - Fixed route link path activation to only occur after router link is
  connected

Runtime & Memory

- Context validation - Added context valid checks for handleBindingCall from Dart
- QuickJS garbage collection - Always turn on QuickJS GC for better memory management
- iOS compilation - Fixed iOS compile options in release mode

🧹 Maintenance

- Legacy API removal - Removed legacy profile AP

## 0.21.2+1

New Features

### Added `<text />` Layout Element

- New text component that provides more precise text layout control
- Supports proper whitespace handling, including collapsing and trimming
- Configurable with CSS properties like font-family, line-height, text-align

### Enhanced ListView Pull-to-Refresh and Load More

- Added automatic event dispatch for pull-to-refresh and load-more actions

### Improved Router Link Event Handling

- Fixed event firing order for router navigation events
- Events now fire correctly after the onscreen event when navigating
- Added `dispatchEventByDeps` method to ensure proper event sequencing
- Enhanced event dependency tracking to handle timing-sensitive events

### Android Build Improvements

- Added pre-compile scripts for Android to streamline the build process:
  - `build_android_jnilibs.js`: Copies JNI libraries from bridge/build to webf/android/jniLibs
  - `build_android_package.js`: Orchestrates the entire Android package build process
  - `patch_android_build_gradle.js`: Updates Android build.gradle for pre-compiled libraries

## Bug Fixes

- Fixed iOS build issues
- Revert the changes for resizeViewportRelatedElements.

## 0.21.2

New Features

FormData Support

- Added FormData/File API support for web-compatible file uploads
- Implemented native FormData interface with proper multipart handling
- Extended fetch module to work with FormData objects

Pull-to-Refresh Improvements

- Integrated easy_refresh package for better pull refresh and load more functionality
- Simplified custom ListView implementation with native refresh capabilities

Bug Fixes

Layout Improvements

- Fixed position layout handling for elements not connected to DOM
- Made flushPendingProperties synchronous for more predictable layout behavior
- Fixed viewport metrics changes by properly dispatching relayout for affected render objects
- Disabled scrolling when overflow is set to hidden
- Fixed line-height computation when inheriting from parent elements

Crash Fixes

- Fixed issue where _hostSet was not properly initialized

Build System

- Made bytecode generator into a standalone script for better maintainability
- Fixed Android NDK limits for better cross-platform compatibility

Framework Improvements

- Fixed forceUpdate on WebF controller when created by AutoManagedWebF widget

## 0.21.1

New Features

- Upgraded to official QuickJS version 2025-04-26
- Added visual error handling for layout errors showing on-screen exceptions
- Generate polyfill bytecode in production mode for better performance

Bug Fixes

- Fixed crash when passing parameters to new Blob constructor
- Fixed scrollableViewportSize to correctly constrain box layout
- Fixed renderStyle.isScrollingContainer implementation
- Only show layout errors in debug/profile mode (hidden in release mode)
- Fixed WebF.fromControllerName in concurrent conditions
- Fixed passing parameter to new Blob constructor
- Fixed gesture event hitTest functionality
- Fixed inline text placeholder hitTest
- Added lineAscentHeightOffset to text layout lineOffset
- Fixed various Windows compilation issues

Infrastructure & Building

- Added support for compiling with MSYS2
- Removed legacy QuickJS engine and bytecode generator

QuickJS Release Logs between the previous used version:

2025-04-26:

- removed the bignum extensions and qjscalc
- new BigInt implementation optimized for small numbers
- added WeakRef, FinalizationRegistry and symbols as weakrefs
- added builtin float64 printing and parsing functions for more correctness
- faster repeated string concatenation
- qjs: promise unhandled rejections are fatal errors by default
- added column number in debug information
- removed the "use strip" extension
- qjs: added -s and --strip-source options
- qjsc: added -s and --keep-source options
- added JS_GetAnyOpaque()
- added more callbacks for exotic objects in JSClassExoticMethods
- misc bug fixes

2024-01-13:

- top-level-await support in modules
- allow 'await' in the REPL
- added Array.prototype.{with,toReversed,toSpliced,toSorted} and
  TypedArray.prototype.{with,toReversed,toSorted}
- added String.prototype.isWellFormed and String.prototype.toWellFormed
- added Object.groupBy and Map.groupBy
- added Promise.withResolvers
- class static block
- 'in' operator support for private fields
- optional chaining fixes
- added RegExp 'd' flag
- fixed RegExp zero length match logic
- fixed RegExp case insensitive flag
- added os.sleepAsync(), os.getpid() and os.now()
- added cosmopolitan build
- misc bug fixes

2023-12-09:

- added Object.hasOwn, {String|Array|TypedArray}.prototype.at,
  {Array|TypedArray}.prototype.findLast{Index}
- BigInt support is enabled even if CONFIG_BIGNUM disabled
- updated to Unicode 15.0.0
- misc bug fixes

## 0.21.0-beta.7

**Bug Fixes**

Dark Mode Improvements

- Enhanced darkModeOverride: Improved dark mode handling in widget mode with a more robust
  implementation [d6908531c]
  - Added proper change detection to prevent unnecessary style recalculations
  - Ensured events and style updates occur only when actual changes happen
  - Simplified API by eliminating need for manual platform brightness change calls
  - Added clear documentation explaining conditional logic

QuickJS Runtime Fixes

- JSClassID Overflow Fix: Fixed critical crash that occurred when total created controller instances
  exceeded 200. [89c1887ef]
- Bundle Preprocessing: Added checks to ensure page is alive when preprocessing JavaScript bundles,
  preventing potential crashes.
  [2dd2b7d91]

CSS & Styling Fixes

- CSS Variables: Fixed issues when overriding CSS variable properties with normal CSS values,
  improving CSS variable reliability.
  [936562108]
- Head Element Style Reload: Fixed null exception that occurred when reloading styles in head
  elements. [907804f4d]

Layout Engine Improvements

- Flexbox Container Sizing: Significantly improved flexbox margin handling with proper container
  dimension recalculation
  - Added container size recalculation after child sizing adjustments
  - Added cross-axis extent recalculation after child relayout
  - Enhanced flexbox margin behavior with comprehensive test cases [99b08a88c]

**New Features**

- Controller Creation Callbacks: Added callbacks to notify when a controller is created by WebF
  widget, improving lifecycle
  management. [cc53ddf23]

Storage Enhancements

- Shared Storage Cache: Implemented shared storage box cache for AsyncStorage and
  LocalStorage [30d2b6339]
  - Added Maps to cache box instances across the application
  - Maintained shared instances between modules
  - Improved cleanup in dispose methods

**Other Changes**

- Test Coverage: Added extensive CSS variable test specifications, improving test
  coverage. [a4d2de1dd]
- Documentation: Fixed changelog formatting. [cbe51803c]

## 0.21.0-beta.6

**iOS Native Integration**

- Complete overhaul of iOS build system to use direct source compilation instead of pre-built
  frameworks
  - Integrated QuickJS source files directly in iOS build
  - Added Gumbo Parser and modp_b64 libraries to iOS project
  - Added Dart FFI support to iOS project
  - Updated dynamic library loading for iOS using `DynamicLibrary.executable()`

**WebF Package Publishing**

- Added prepare_webf_package script for publishing
- Added handling for dynamic libraries and C++ source files preparation
- Added automated patching for CMakeLists.txt, app revision, and version

**Router and Event Handling**

- Delayed push and pushNext router change events to ensure firing after screen events in webf router
  link element

**Bug Fixes**

- Fixed scheduleFrame() in the image element to ensure frame updates
- Fixed _markChildrenTextNeedsLayout to use DOM tree instead of renderObject tree
- Added checks for module disposal before modifying collections in WebSocketModule to prevent
  ConcurrentModificationError
- Fixed build scripts and integration test dependencies
- Updated iOS code_gen include paths

## 0.21.0-beta.5+3

Image Loading Reliability

- Added automatic fallback mechanism for failed image loads:
  - Images that fail to load now automatically retry once after invalidating cache
  - Prevents broken images due to corrupted cache files or temporary network issues
  - Improved user experience by reducing instances of broken images

Technical Improvements

- Enhanced ImageElement with smart retry logic:
  - Added tracking to prevent unnecessary multiple reload attempts
  - Implemented forced cache eviction during reload attempts
  - Images are properly cleared from Flutter's image cache during reload
  - Built on top of existing HTTP cache invalidation mechanism

Bug Fixes

- Fixed case with border rendering in inline elements
- Improved logic flow in LogicLineBox for better handling of nested inline elements
- Fixed HTTP cache invalidation mechanism for consistent behavior across image and script loading

## 0.21.0-beta.5+2

**Features**

Controller Management Improvements

- Add timeout request limits for preload and prerendering to prevent hanging requests
- Make addOrUpdateControllerWithLoading return null if the race condition fails, improving error
  handling

Performance Enhancements

- Add timeline tracking for flex layout performance monitoring
- Optimize concurrent request handling with race conditions
- Upgrade web_socket_channel version to 3.0.1 for better WebSocket performance

React.js Integration

- Make input events compatible with React.js event system, improving framework integration
- Enhanced synthetic event handling for better cross-framework support

Bug Fixes

Memory Management

- Fix memory leaks with pending script promises by properly tracking promise lifecycle
- Fix context check during release of alive script wrappable objects
- Fix crash when disposing script promises by checking context availability
- Fix crash when finalizing JavaScript runtime with canvas context

Timeout and Request Handling

- Fix parameters and annotations with timeout functionality
- Improve error handling during concurrent controller operations
- Add proper race condition resolution for multiple preload/prerendering requests

Stability Improvements

- Fix canvas rendering context finalization crash
- Fix sticky position holder null error that caused layout issues
- Implement more robust controller lifecycle management

Other Changes

- Move most of WebF pages to cold load in example app for better performance
- Add test specifications for color change functionality
- Improve code documentation and type annotations

## 0.21.0-beta.5+1

Features

**Controller Lifecycle Management**

- Fallback Mechanism: Added support for fallback to previous controller when concurrent requests
  fail, ensuring uninterrupted user experience
- Preload/Prerender Handling: Implemented race condition handling for multiple bundle operations,
  optimizing performance for parallel requests
- Auto-managed WebF Widgets: Added controller manager for automatic widget lifecycle management
- Dynamic Controller Replacement: Support replacing WebFController instances for existing WebF
  widgets

**API Improvements**

- Exception Handling: Enhanced error handling by throwing exceptions for failed preloading requests
- Streamlined API: Merged addWithPreload and updateWithPreload methods into a single implementation
- TypeScript Support: Added auto-generated typings with improved documentation

Fixes

**Stability Improvements**

- Position Fixes: Fixed sticky position holder null error and temporarily disabled problematic
  sticky position layouts
- Navigation Fixes: Resolved hybrid router pop event issues when path is "/"
- Preload API: Fixed addOrUpdateWithPreload API when applied to attached controllers

**Other Improvements**

- Test Reliability: Fixed integration test setup and execution
- Example App: Updated example application configuration and added build scripts
- Documentation: Enhanced API annotations for WebFControllerManager

Chores

- Package Renaming: Reorganized package structure for better clarity
- Build Tools: Added example build scripts to streamline development workflow
- Test Coverage: Added test specs for parallel request handling scenarios

## 0.21.0-beta.5

**New Features**

- Added Inline Formatting Context support for improved text rendering and layout
  - Introduces more accurate text layout with proper inline element handling
  - Added line-join functionality for inline elements
  - Implemented WebFTextPainter for enhanced text rendering performance
  - Added TextSpan and LogicBox rendering support
- Increased loadmore event frequency in WebFListView for smoother infinite scrolling experiences
  - Reduced the delay between loadmore events from 1000ms to 500ms
  - Improved user experience when scrolling through large lists

**Performance Improvements**

- Optimized text CSS style handling to prevent unnecessary renders
- Enhanced text layout and rendering performance

**Bug Fixes**

- Removed unnecessary showcaseview dependency

## 0.21.0-beta.4+5

New Features

- Added support for custom ListView components
  - Includes both Material and Cupertino implementations
  - Added to example application with demo page
- Added support for ShowCaseView component
  - Integrated showcase examples in the demo application
- Added WebFControllerManager.instance.cancelUpdateOrLoadingIfNecessary API
  - Allows canceling pending updates or loading operations

Bug Fixes

- Fixed issue where loading didn't properly request an animation frame
- Fixed override default widget element functionality
- Enhanced element registry system

## 0.21.0-beta.4+4

### Bug Fixes

- Fix onScreen event on RouterLinkElement
- Fix router change events
- Fix did change metrics not updating viewport CSS values
- Fix forEach element attached flutter state

## 0.21.0-beta.4+3

### Features

- Support dashed border for single side
- New implementation for gesture handling
- Display error when widget loading fails

### Bug Fixes

- Fix min-height with parent fit-content
- Fix offscreen event dispatch on hybrid router
- Fix conversion of widget elements constraints to inner HTML Elements
- Fix flex cross size affected by min-height
- Fix min-height definition triggering flex item not to stretch
- Fix painting order with multiple renderObject instances
- Fix max constraint height inheritance in WebFWidgetElementChild
- Fix Element.getBoundingClientRect in hybrid router mode

## 0.21.0-beta.4+2

### Features

- Support fixed positioned layout both for overflow and <webf-listview /> without stacking context
  support.

### Bug Fixes

- Fix recalculate style for connected node.
- Fix change position value to static.
- Fix put positioned elements in route link element.
- Fix scrolling with fixed elements.
- Fix rust integration test.

### Tests
-

- Temporarily disable test specs with stacking context.
- Add position fixed tests with router link specs.
- Add position fixed listview specs.
- Add position-fixed-comprehensive test specs.
- Add position fixed click tests.
- Fix rust integration tests.

### Other Changes

- Remove profile tracking.
- Add flutter cupertino demo in react.js

## 0.21.0-beta.4

### Features

- Add WebFTouchArea element to avoid SyntheticEvent side effects in React.js
- Add NativeByteData for receiving bytes from JavaScript to Dart
- Make webf.invokeModule accept multiple parameters
- Use Completer for async returns for modules
- Add helper functions in render style
- Add controller.printDOMTree API for debugging
- Make Cupertino slider code generator friendly
- Optimize onscreen event priority for `<webf-router-path />` element
- Optimize page loading to avoid rebuilding the whole widget tree
- Optimize loading screen for already loaded pages
- Optimize canvas needsPaint UI commands

### Bug Fixes

- Fix share demo and miracle plus share demo
- Fix flex-item size with flex-basics
- Fix mark parent needs relayout with RenderEventListener
- Fix RenderEventListener stopping the mark needs layout
- Fix minContentWidth and minContentHeight calculation in event listener
- Fix localStorage.removeItem
- Fix flex layout baseline computation affected by renderEventListener
- Fix dump rendering snapshots on widget elements
- Fix hit test for event listeners and box wrapper
- Fix array buffer memory leaks when dispose the engine
- Fix memory leaks due to ui command items
- Fix widget element state disposed by add event listener on element
- Fix event target gesture target mixed between main and hybrid route pages
- Fix mark needs build for root WebFState
- Fix WebF touch area default style
- Fix height constraints from parent widget elements
- Fix avoid repeat call needsPaint for canvas element

### Other Changes

- Enhance type definitions and interfaces across polyfill modules
- Remove the profile tracking in layout and paint
- Add NativeBytedata test specs
- Add array buffer demo for testing

## 0.21.0-beta.3+1

### Features

- feat: add WebFWidgetElementChild widget for pass outer constraints to inner HTMLElement child. (
  3a71af271)
- feat: add controller.printRenderObjectTree API. (c505040ea)
- feat: add create component utils for react (3373d4481)

### Bug Fixes

- fix: fix flush pending properties order. (1fa7d3673)
- fix: fix change font size in html element with rem values. (80495dd1f)
- fix: fix FontsAndImages specs. (7878474fc)
- fix: fix module test specs. (b15a2bef4)
- fix: fix null check with image onload. (fa2d8a935)
- fix: fix race condition for check shared ui command is empty. (998bbd7a1)

## 0.21.0-beta.3

## WebF Core

### Features

- Added support for dashed border style.
- Added support for CSS logical properties in LTR mode.
- Added support for custom listview element rendering behavior.
- Added support for `requestIdleCallback`.
- Added support for `Event.preventDefault`.

**The CSS Logical properties supported in LTR mode**

```
1. Margin Properties

- margin-inline-start → margin-left
- margin-inline-end → margin-right
- margin-block-start → margin-top
- margin-block-end → margin-bottom

2. Padding Properties

- padding-inline-start → padding-left
- padding-inline-end → padding-right
- padding-block-start → padding-top
- padding-block-end → padding-bottom

3. Border Shorthand Properties

- border-inline-start → border-left
- border-inline-end → border-right
- border-block-start → border-top
- border-block-end → border-bottom

4. Border Width Properties

- border-inline-start-width → border-left-width
- border-inline-end-width → border-right-width
- border-block-start-width → border-top-width
- border-block-end-width → border-bottom-width

5. Border Style Properties

- border-inline-start-style → border-left-style
- border-inline-end-style → border-right-style
- border-block-start-style → border-top-style
- border-block-end-style → border-bottom-style

6. Border Color Properties

- border-inline-start-color → border-left-color
- border-inline-end-color → border-right-color
- border-block-start-color → border-top-color
- border-block-end-color → border-bottom-color

7. Inset/Position Properties

- inset-inline-start → left
- inset-inline-end → right
- inset-block-start → top
- inset-block-end → bottom
```

### Bug Fixes

- Fixed dispatch of `didpush` and `didpushNext` hybridRouterChange events.
- Fixed type errors in bridge polyfill.
- Fixed `controller.currentBuildContext` error with `replaceState` on the hybrid router.
- Fixed error when Flutter was not attached in the hybrid history API.
- Fixed Android build issues.
- Fixed gesture handling event target in router link.
- Fixed viewport rendering on layout.
- Fixed delay in controller disposal.

### Other Changes

- Refactored widget elements to use the new API pattern.
- Using `flutter_svg` to render SVG images for `<img>` tags.

---

### The New Pattern for Writing a WidgetElement

```dart
class FlutterCupertinoActionSheet extends WidgetElement {
  /// WidgetElement will live much longer than Flutter widgets
  /// and have the same lifecycle as the corresponding HTMLElement in JavaScript.
  /// When the element is removed by JavaScript, this element will be disposed.
  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoActionSheetState(this);
  }
}

// FlutterCupertinoActionSheetState is a subclass of Flutter's State class
class FlutterCupertinoActionSheetState extends WebFWidgetElementState {
  FlutterCupertinoActionSheetState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This element itself doesn't render anything visible
    return const SizedBox();
  }
// ..
}
```

---

### How to Customize `<webf-listview />`

```dart
WebF.overrideCustomElement
('webf-listview
'
, (context) => CustomWebFListView(context));

class CustomWebFListView extends WebFListViewElement {
CustomWebFListView(super.context);

@override
WebFWidgetElementState createState() {
return CustomListViewState(this);
}
}

class CustomListViewState extends WebFListViewState {
CustomListViewState(super.widgetElement);

@override
Widget buildLoadMore() {
return widgetElement.hasEventListener('loadmore')
? Container(
height: 50,
alignment: Alignment.center,
child: isLoadingMore ? const CupertinoActivityIndicator() : const SizedBox.shrink(),
)
  : const SizedBox.shrink();
}

@override
Widget buildRefreshControl() {
return CupertinoSliverRefreshControl(
onRefresh: () async {
if (widgetElement.hasEventListener('refresh')) {
widgetElement.dispatchEvent(dom.Event('refresh'));
await Future.delayed(const Duration(seconds: 2));
}
},
);
}

@override
Widget buildRefreshIndicator(Widget scrollView) {
return RefreshIndicator(
onRefresh: () async {
if (widgetElement.hasEventListener('refresh')) {
widgetElement.dispatchEvent(dom.Event('refresh'));
await Future.delayed(const Duration(seconds: 2));
}
},
child: scrollView,
);
}

@override
void handleScroll() {
double scrollPixels = scrollController?.position.pixels ?? 0;
print('Scrolling... $scrollPixels');
}

@override
bool hasRefreshIndicator() {
return true;
}
}
```

---

## Examples

### Cupertino Components

- Added `formRow` and `formSection` components.
- Added `action-sheet` component.
- Added `timer picker` component.
- Added `radio` and `checkbox` components.
- Added `cupertino-context-menu` and `slider` widget.
- Fixed context menu demo.
- Fixed button text color to use CSS variables.
- Added CSS variables for Cupertino gallery.
- Updated Cupertino button implementation and usage.
- Added `textarea` demo page.

### MiraclePlus Examples

- Switched MiraclePlus to prerendering mode.
- Fixed MiraclePlus demo.
- Fixed toast pop error.

### Hybrid Router

- Added hybrid router template.
- Added `initialRoute` parameter for hybrid router delegate.
- Added ECharts playground.
- Added `ListTile` and `ListSection` components.
- Enhanced `FlutterListViewElement` with platform-specific refresh controls.
- Added loading icon for loading more items.
- Added support for the `share` method.

## 0.21.0-beta.2

## Core Features

**WebF API**

1. **Add WebFRouterView.fromControllerName API**
   When used in the `onGenerateRoute` callback of Navigator, this API automatically manages the
   lifecycle, including initialization, disposal, and displaying the loading widget. Users only need
   to specify the controller name and customize the loading widget.

   Example:
   ```dart
   Route<dynamic>? handleOnGenerateRoute(RouteSettings settings) {
       return CupertinoPageRoute(
         settings: settings,
         builder: (context) {
           return WebFRouterView.fromControllerName(
               controllerName: webfPageName.value,
               path: settings.name!,
               builder: (context, controller) {
                 return WebFSubView(controller: controller, path: settings.name!);
               },
               loadingWidget: _WebFDemoState.buildSplashScreen());
         },
       );
   }
   ```

2. **Support for Updating WebF Controller by Name in WebFControllerManager**
   For created WebFControllers with a name, users can update the controller and its rendering
   content by calling `WebFControllerManager.instance.updateWithPreload` or
   `WebFControllerManager.instance.updateWithPrerendering` to reinitialize and preload or prerender
   with the same controller name.

   Example:
   ```dart
   WebFControllerManager.instance.updateWithPreload(
       createController: () => WebFController(
             initialRoute: '/',
             routeObserver: routeObserver,
             devToolsService: kDebugMode ? ChromeDevToolsService() : null,
           ),
       name: 'html/css',
       routes: {
         '/todomvc': (context, controller) => WebFSubView(path: '/todomvc', controller: controller),
         '/positioned_layout': (context, controller) =>
             WebFSubView(path: '/positioned_layout', controller: controller),
       },
       bundle: WebFBundle.fromUrl('assets:///vue_project/dist/index.html'));
   ```

3. **Add WebFController.cookieManager for App-Level Cookie Management**
4. Add `initialRoute` and `initialState` for the initialize hybrid route path and state when
   initialize WebF.

---

**Hybrid Router**

1. **Add Hybrid Router Change Event for `<webf-router-link />` Element**
   You can now listen for the `hybridrouterchange` event in the `<webf-router-link />` element when
   the hybrid router pushes in or pops back.

   Example:
   ```vue
   <webf-router-link :path="path" @onscreen="onScreen" :title="title" @hybridrouterchange="onRouterChange">
     <slot v-if="isMounted"></slot>
   </webf-router-link>
   ```

   The `HybridRouterChangeEvent` provides the following properties:
   ```typescript
   interface HybridRouterChangeEvent extends Event {
     readonly state: any; // The state object for the current path
     readonly kind: string;
     readonly path: string;
     new(): HybridRouterChangeEvent;
   }
   ```

   There are four kinds of `HybridRouterChangeEvent`:
1. `didPopNext` – Called when the top route is popped off, and the current route shows up.
2. `didPop` – Called when the current route is pushed.
3. `didPush` – Called when the current route is popped off.
5. `didPushNext` – Called when a new route is pushed, and the current route is no longer visible.

2. **Fix WebF App Rebuild Triggered by Hybrid Router Push and Pop**
3. **Fix hybridRouter.state When Pushing from Another Router Page**
4. **Add More APIs for Hybrid Router**
1. `pushNamed` – Push a named route onto the navigator that most tightly encloses the given context.
2. `restorablePopAndPushNamed` – Restorably pop the current route and push a named route.
3. `pushReplacementNamed` – Push a replacement named route.
4. `canPop` – Whether the navigator can be popped.
6. `maybePop` – Pop the top-most route off, only if it's not the last route.
7. `popAndPushNamed` – Pop the current route off and push a named route in its place.
8. `popUntil` – Pops until a route with the given name.
9. `pushNamedAndRemoveUntil` – Push the route with the given name and remove routes until the named
   route is reached.

---

**Layout**

1. **Fix Flex Item Layout Size When Parent is a Flex Container and Overflows**
2. **Fix Positioned Element Not Updating Offset Position When Scrolling**
3. **Fix Replaced Element Intrinsic Layout Size as Flex Item**

---

**Gestures**

1. **Fix Draggable Effect Demo Built with React.js Based on `ontouchstart` and `ontouchmove`
   Gestures**
   Demo
   URL: [http://andycall.oss-cn-beijing.aliyuncs.com/demo/dragable-list.js](http://andycall.oss-cn-beijing.aliyuncs.com/demo/dragable-list.js)

---

**JS Runtime**

1. **Fix Memory Leaks for Unresolved Promises**
2. **Fix Null Pointer Crash for `removeEventListener`**

---

**Miracle Plus**

1. **Add Skeleton Effect for Page Loading**
2. **Support Dark Mode for All Pages**
3. **Add Cupertino Library Gallery**

---

**Others**

1. **Upgrade Hive Dependencies to `hive_ce@2.10.1`**

## 0.21.0-beta.1

**Bug Fixes**

1. Fixed known issues during the Rendering Architecture Migration:
1. Fixed `WebF.methodChannel` not being initialized.
2. Reworked CSS overflow.
3. Reworked CSS positioned layout.
4. Reworked CSSOM API (`Element.offsetTop`, `Element.scrollTo`, etc.).
5. Fixed margin collapse in various combination cases.
6. Supported CSSOM API for `<webf-listview />`.
2. Fixed CSS style inspection through Chrome DevTools.

**Features**

1. Added `webf.hybridRouter.path` and `webf.hybridRouter.replaceState` APIs.
2. Added `onscreen` and `offscreen` events for all DOM elements.
3. Added CSS stacking context support.
4. Supported reloading WebF pages through Chrome DevTools.
5. Supported overriding WebF modules.
6. Supported initializing `WebFController` without any rendering context.
7. Added `WebFControllerManager` to maintain the maximum number of alive and attached
   `WebFController` instances.

## 0.20.0

Upgrade to enterprise version, which starts at 0.20.0 version.

+ Feat: Add support for fully async internal binding API.
+ Feat: Optimize the performance WidgetElement binding API.
+ Feat: Add MediaQuery and Dark mode support.
+ Feat: Redesigned Flutter Widget Adapter System.
+ Feat: Add Echarts.js with line char graph support.

## 0.16.3+1

Fixed compilation issues for Linux, Android, and Windows platforms.

## 0.16.3

This version supports Flutter 3.27.x, 3.24.x, 3.22.x, 3.19.x, 3.16.x, and 3.13.x.

## Features

+ Optimize Dart/C++ FFI performance in multiple thread
  mode. https://github.com/openwebf/webf/pull/654
+ Change viewport css property value automatically when app metrics
  changed. https://github.com/openwebf/webf/pull/655
+ Optimize listview performance. https://github.com/openwebf/webf/pull/669
+ Full support of CanvasContext2D.Path2D. https://github.com/openwebf/webf/pull/684
+ Add WebFChildNodeSize widget. https://github.com/openwebf/webf/pull/690
+ Add console.inspect() API for inspecting JavaScript
  Objects. https://github.com/openwebf/webf/pull/691
+ Using std::atomic value types for disposed checks of
  NativeBindingObject. https://github.com/openwebf/webf/pull/699
+ Upgrade intl deps to 0.19.0. https://github.com/openwebf/webf/pull/701

## Bug Fixed

+ Fix dart type error when attach flex layout underneath of Flutter
  ListView. https://github.com/openwebf/webf/pull/650
+ Fix crash when clear ui commands without commands. https://github.com/openwebf/webf/pull/651
+ Fix onClick events respond very slowly on React 18. https://github.com/openwebf/webf/pull/665
+ Fix negative percentage translate in positioned
  elements. https://github.com/openwebf/webf/pull/680
+ Fix ios simulator[arm64] build. https://github.com/openwebf/webf/pull/681
+ Fix globalToLocal coordinate conversion related to position fixed
  layout. https://github.com/openwebf/webf/pull/686
+ Rework inline cache handling. https://github.com/openwebf/webf/pull/688
+ Fix crash when add property maybe failed on build
  arguments. https://github.com/openwebf/webf/pull/689

## Experimental Features

### Rust/Native API

**Have a Try**

https://github.com/openwebf/webf/tree/main/webf/example/rust_builder/rust

Provides support for native plugin APIs and offers corresponding Rust bindings.

## 0.16.2

This version supports Flutter 3.24.x, 3.22.x, 3.19.x, 3.16.x, and 3.13.x.

**Features**

1. Add flutter 3.24.x support. https://github.com/openwebf/webf/pull/644

**Bug Fixed**

1. Fix memory leaks in Flutter engineGroup mode. https://github.com/openwebf/webf/pull/629
2. Fix rendering order when change css display:none to
   block. https://github.com/openwebf/webf/pull/639

## 0.16.1

This version supports Flutter 3.22.x, 3.19.x, 3.16.x, and 3.13.x.

**Features**

1. Add support for AbortController JS API. https://github.com/openwebf/webf/pull/606
2. Add flutter 3.22.x support. https://github.com/openwebf/webf/pull/624

**Bug Fixed**

1. Fix iOS FontFamilyFallback on -apple-system style, display error on Vietnamese
   lang. https://github.com/openwebf/webf/pull/609
2. Fix crash with unexpected format string on `window.btoa`
   API. https://github.com/openwebf/webf/pull/615; https://github.com/openwebf/webf/pull/616

## 0.16.0

This version supports Flutter 3.19.x, 3.16.x, and 3.13.x.

A version compatible with Flutter 3.10.x landed in **0.15.2**.
A version compatible with Flutter 3.7.x landed in **0.14.4**.

**Architecture Upgrade**

The JavaScript Runtime has now migrated to a dedicated thread and is enabled by default in this
version.

For users who want to keep the single-threading mode the same as in the previous version, use the
following configuration:

```dart
WebFController
(
context
,
runningThread
:
FlutterUIThread
(
)
,
);
```

**Big News**

1. Added PreRendering and Preload loading modes, which can save up to 90% of loading time.
   Click [here](https://openwebf.com/docs/tutorials/performance_optimization/prerendering_and_preload_mode)
   for more details.

**Features**

1. Support preloadedBundles in WebF. https://github.com/openwebf/webf/pull/500
2. Add pre-rendering and persistent rendering modes.  https://github.com/openwebf/webf/pull/501
3. Optimize the evaluate times at the first time. https://github.com/openwebf/webf/pull/503
4. Add MutationObserver API support. https://github.com/openwebf/webf/pull/508
5. Add Dedicated Threading support.  https://github.com/openwebf/webf/pull/512
6. Optimize raster performance on Animated images. https://github.com/openwebf/webf/pull/513
7. Turn off quickjs GC at page loading phase.  https://github.com/openwebf/webf/pull/515
8. Optimization matrix algorithm. https://github.com/openwebf/webf/pull/516
9. Support override default contentType for WebFBundle. https://github.com/openwebf/webf/pull/534
10. Support dns-prefetch. https://github.com/openwebf/webf/pull/535
11. Add more SVG tags. https://github.com/openwebf/webf/pull/543
12. Optimize MutationObserver performance. https://github.com/openwebf/webf/pull/545
13. QuickJS add property inline cache. https://github.com/openwebf/webf/pull/546
14. Optimize paint and add profile records. https://github.com/openwebf/webf/pull/547
15. Pause the activity of webf when app visibility
    changed. https://github.com/openwebf/webf/pull/549
16. Optimize bytecode cache load speed and fix http cache. https://github.com/openwebf/webf/pull/552
17. Add Element.parentElement support. https://github.com/openwebf/webf/pull/555
18. Add repaintBoundary for animated images when using css
    background-images https://github.com/openwebf/webf/pull/557
19. Add support for hash router https://github.com/openwebf/webf/pull/572
20. Add support for object event listener. https://github.com/openwebf/webf/pull/575
21. Optimize performance for recalculate styles https://github.com/openwebf/webf/pull/579

**Bug Fixed**

1. Fix class selector not match on html element. https://github.com/openwebf/webf/pull/490
2. Fix concurrent modification during iteration. https://github.com/openwebf/webf/pull/491
3. Fix JavaScript stack overflow error when print Proxy
   object. https://github.com/openwebf/webf/pull/493
4. Fix borderXxxRadius transition. https://github.com/openwebf/webf/pull/495
5. Avoid Hive.init cause conflicts with box paths. https://github.com/openwebf/webf/pull/504
6. Fix assertion error when change display in input
   element. https://github.com/openwebf/webf/pull/505
7. Fix lenght variable issue. https://github.com/openwebf/webf/pull/510
8. Fix transform value not updated in percentage when box size
   changed. https://github.com/openwebf/webf/pull/514
9. Fix crashed due to trigger touch events to inaccessible dom
   elements. https://github.com/openwebf/webf/pull/517
10. Fix crash due to init touchEvent from JS. https://github.com/openwebf/webf/pull/518
11. Fix event.target still can be pointed by event after finalized by JavaScript
    GC. https://github.com/openwebf/webf/pull/519
12. Fix flex-grow not work. https://github.com/openwebf/webf/pull/524
13. Fix bg_image_update not update error. https://github.com/openwebf/webf/pull/526
14. Fix text calculate constraints error. https://github.com/openwebf/webf/pull/527
15. Fix min precision case some error and waste cpu. https://github.com/openwebf/webf/pull/528
16. Fix sliver layout child boundingClientRect offset
    error. https://github.com/openwebf/webf/pull/530
17. Fix build on ArchLinux. https://github.com/openwebf/webf/pull/536
18. Fix devtool select img element. https://github.com/openwebf/webf/pull/538
19. Fix ui command exec order in dedicated thread mode. https://github.com/openwebf/webf/pull/540
20. Fix img gif work error. https://github.com/openwebf/webf/pull/541
21. Fix request flutter to update frame when sync commands to
    dart. https://github.com/openwebf/webf/pull/548
22. Fix textarea elements in ios/android can not auto
    unfocus. https://github.com/openwebf/webf/pull/551
23. Fix crash when binding object had been released by GC. https://github.com/openwebf/webf/pull/553
24. Fix windows platform crash with 0.16.0. https://github.com/openwebf/webf/pull/558
25. Fix page load failed when using async attributes in `<script />`
    elements. https://github.com/openwebf/webf/pull/561
26. Fix dart element memory leaks when js gc collected. https://github.com/openwebf/webf/pull/563
27. Fix crash on flutter engine dispose. https://github.com/openwebf/webf/pull/566
28. Fix background-image disappear with multiple image
    links. https://github.com/openwebf/webf/pull/574
29. Fix js log does not show in terrminal and devtools. https://github.com/openwebf/webf/pull/584
30. Fix mem leaks caused by event dispatch. https://github.com/openwebf/webf/pull/585
31. Fix input when resume apps https://github.com/openwebf/webf/pull/589
32. Fix memory leak caused by img element https://github.com/openwebf/webf/pull/590
33. Fix input elements or widget elements when preload or prerendering
    complete. https://github.com/openwebf/webf/pull/595
34. Fix animation time resume. https://github.com/openwebf/webf/pull/597
35. Fix invalid xcframework for ios release. https://github.com/openwebf/webf/pull/600

## 0.15.1

This version will support Flutter 3.10.x

**Features**

1. Optimize location API for better performance results. https://github.com/openwebf/webf/pull/420
2. Optimize the webf_bridge and quickjs binary size. https://github.com/openwebf/webf/pull/414
3. Support CSS initial length value. https://github.com/openwebf/webf/pull/421
4. Optimize Element.children() and Document.all()
   performance. https://github.com/openwebf/webf/pull/424
5. Support element <line> for svg. https://github.com/openwebf/webf/pull/475
6. Add WebFController.onTitleChanged API. https://github.com/openwebf/webf/pull/479

**Bug Fixed**

1. Fix percentage width and height not working under inline block
   box. https://github.com/openwebf/webf/pull/430
2. Fix Node.insertBefore with SVGElement error. https://github.com/openwebf/webf/pull/431
3. Fix cookie delete file error when it's not available. https://github.com/openwebf/webf/pull/429
4. Fix use css vars with
   initial. https://github.com/openwebf/webf/pull/421/commits/1da2e5899c53e82a31271c26de3333168e780134
   0.15.0-beta.3
5. Fix toggle position: fixed on bodyElement with other fixed
   elements. https://github.com/openwebf/webf/pull/416
6. Fix css nth-child not work. https://github.com/openwebf/webf/pull/417
7. Fix Node.childNodes didn't update when nodes changed. https://github.com/openwebf/webf/pull/419
8. Fix loading fonts cause assertion when remove or attach
   RenderObjects. https://github.com/openwebf/webf/pull/425
9. fix crash when reload pages. https://github.com/openwebf/webf/pull/476
10. Fix memory leaks. https://github.com/openwebf/webf/pull/487

## 0.15.0

This version will support Flutter 3.10.x

**Break Changes**

1. Remove `navigator.connection` API. https://github.com/openwebf/webf/pull/411

**Features**

1. Upgrade Flutter support to 3.10.x. https://github.com/openwebf/webf/pull/345
2. Optimize location API for better performance results. https://github.com/openwebf/webf/pull/420
3. Optimize the size of webf_bridge.xcframework and
   quickjs.xcframework. https://github.com/openwebf/webf/pull/414
4. Support CSS initial length value. https://github.com/openwebf/webf/pull/421
5. Optimize Element.children() and Document.all()
   performance. https://github.com/openwebf/webf/pull/424
6. Support base64 format font data in `@font-face` src. https://github.com/openwebf/webf/pull/399
7. Support Element.dir API. https://github.com/openwebf/webf/pull/418
8. Add `<circle />` and `<ellipse>` tags for SVG. https://github.com/openwebf/webf/pull/423
9. Support share customized JS properties in event object. https://github.com/openwebf/webf/pull/427
10. Support `window.pageXOffset` and `window.pageYOffset`
    API. https://github.com/openwebf/webf/pull/428/files
11. Optimize layout/paint performance when block box size is
    fixed. https://github.com/openwebf/webf/pull/450
12. Optimize performance when update Element.className.  https://github.com/openwebf/webf/pull/452
13. Support CanvasRenderingContext2D.createPattern() API. https://github.com/openwebf/webf/pull/464

**Bug Fixed**

1. Fix use css vars with initial. https://github.com/openwebf/webf/pull/421
2. Fix toggle position: fixed on bodyElement with other fixed
   elements. https://github.com/openwebf/webf/pull/416
3. Fss nth-child not work. https://github.com/openwebf/webf/pull/417
4. Fix Node.childNodes didn't update when nodes changed. https://github.com/openwebf/webf/pull/419
5. Fix loading fonts cause assertion when remove or attach
   RenderObjects. https://github.com/openwebf/webf/pull/425
6. Fix percentage width and height not working under inline block
   box. https://github.com/openwebf/webf/pull/430
7. Fix Node.insertBefore with SVGElement error. https://github.com/openwebf/webf/pull/431
8. Fix cookie delete file error when it's not available. https://github.com/openwebf/webf/pull/429
9. Fix read ANDROID_SDK_HOME before implying to platform
   defaults. https://github.com/openwebf/webf/pull/422
10. Fix cookie delete file error.  https://github.com/openwebf/webf/pull/429
11. Fix percentage width and height not working under inline block
    box. https://github.com/openwebf/webf/pull/430
12. Fix Node.insertBefore with SVGElement error. https://github.com/openwebf/webf/pull/431
13. Fix DevTool's network panel not working. https://github.com/openwebf/webf/pull/435
14. Losen intl dependency constraint. https://github.com/openwebf/webf/pull/439
15. Fix built-in methods in the event object cannot be
    overridden. https://github.com/openwebf/webf/pull/443
16. Fix crash when touching pseduo elements.  https://github.com/openwebf/webf/pull/445
17. Fix event not responding when multiple flutter engine
    created. https://github.com/openwebf/webf/pull/451
18. Fix Element.style.cssText API not works. https://github.com/openwebf/webf/pull/455
19. Fix use-of-free crash of shared string property in event
    object. https://github.com/openwebf/webf/pull/458
20. Fix dynamic build items in WidgetElement. https://github.com/openwebf/webf/pull/461
21. Fix CSS content property have sequences of unicode
    chars. https://github.com/openwebf/webf/pull/463
22. Fix crash when create unsupported svg element with
    style. https://github.com/openwebf/webf/pull/465

## 0.14.1

**Features**

1. Add CSS @font-face support. https://github.com/openwebf/webf/pull/380
2. Support ::before/::after selector. https://github.com/openwebf/webf/pull/332
3. Add document.elementFromPoint API. https://github.com/openwebf/webf/pull/381
4. Support set textContent on textArea elements. https://github.com/openwebf/webf/pull/369
5. Support receive binary data from fetch and
   XMLHttpRequest. https://github.com/openwebf/webf/pull/397
6. Add support for event capture phases. https://github.com/openwebf/webf/pull/404
7. Support change the current animation stage for transition
   animations. https://github.com/openwebf/webf/pull/401
8. Add CSSStyleDeclaration.cssText support. https://github.com/openwebf/webf/pull/410
9. Move the webf_websocket plugin into webf. https://github.com/openwebf/webf/pull/398

**Bug Fixed**

1. Fix error when setting display:none for input and
   textarea. https://github.com/openwebf/webf/pull/369
2. Fix focus state didn't cleared when input unmount from the DOM
   Tree. https://github.com/openwebf/webf/pull/369
3. Fix defaultStyle for textarea elements. https://github.com/openwebf/webf/pull/369
4. Fix a crash when a JSObject was finalized after the ExecutingContext was
   freed. https://github.com/openwebf/webf/pull/372
5. Fix a crash when ExecutingContext is not alive at timer
   callbacks. https://github.com/openwebf/webf/pull/373
6. Fix a crashed when running in multiple flutter engine
   instance. https://github.com/openwebf/webf/pull/377
7. Fix the size of the input is wrong when using a unit other than
   px. https://github.com/openwebf/webf/pull/378
8. Fix crashed when shutdown the app. https://github.com/openwebf/webf/pull/383
9. Fix Resource temporarily unavailable for Hive lock
   file. https://github.com/openwebf/webf/pull/387
10. Fix a memory leaks in TouchList. https://github.com/openwebf/webf/pull/388
11. Fix match error for animation time. https://github.com/openwebf/webf/pull/390/files
12. Fix built-in string initialized multiples and cause
    leaks.  https://github.com/openwebf/webf/pull/391
13. Fix constructor property on DOM elements. https://github.com/openwebf/webf/pull/402

## 0.14.0

**Big News**

1. Add Flutter 3.3/3.7 support. https://github.com/openwebf/webf/pull/246
2. Add SVG suppport. https://github.com/openwebf/webf/pull/279
3. Add Windows support. https://github.com/openwebf/webf/pull/162
4. Add multiple flutter engine group support. https://github.com/openwebf/webf/pull/338

**Features**

2. Support transform property for computedstyle. https://github.com/openwebf/webf/pull/245
3. Add `btoa()` and `atob()` API support. https://github.com/openwebf/webf/pull/253
4. Add Vue SSR support. https://github.com/openwebf/webf/pull/256
5. Replace malloc to mimalloc. https://github.com/openwebf/webf/pull/267
6. Add CanvasRenderingContext2D.createLinearGradients and
   CanvasRenderingContext2D.createRadialGradient support. https://github.com/openwebf/webf/pull/269
7. Optimize Fetch() API performance. https://github.com/openwebf/webf/pull/287
8. Add Blob.base64() to export base64 string from Blob
   directly. https://github.com/openwebf/webf/pull/278
9. Expand quickjs default prop size and realloc capacity. https://github.com/openwebf/webf/pull/270
10. Add context API for WidgetElement. https://github.com/openwebf/webf/pull/264
11. Add kbc file type support for script element. https://github.com/openwebf/webf/pull/250
12. Support react.js without any polyfill. https://github.com/openwebf/webf/pull/257
13. Auto cache parsed bytecode for the first load. https://github.com/openwebf/webf/pull/280
14. Invalidate cache when expect Http request errors https://github.com/openwebf/webf/pull/305
15. Optimize dart dom and CSS selector performance. https://github.com/openwebf/webf/pull/309
16. Support background-clip text. https://github.com/openwebf/webf/pull/318
17. Remove ios armv7 armv7s support. https://github.com/openwebf/webf/pull/331
18. Add DOMContentLoaded API. https://github.com/openwebf/webf/pull/330
19. Optimize image load performance. https://github.com/openwebf/webf/pull/335
20. Validate bytecode cache with CRC32 checksum. https://github.com/openwebf/webf/pull/336
21. Add Element.querySelectorAll and Element.querySelector
    API. https://github.com/openwebf/webf/pull/342
22. Support document.domain and document.compatMode. https://github.com/openwebf/webf/pull/343
23. Support document.readyState. https://github.com/openwebf/webf/pull/347
24. Add localStorage and sessionStorage support. https://github.com/openwebf/webf/pull/344
25. Support document.visibilityState and document.hidden.  https://github.com/openwebf/webf/pull/350
26. Add document.defaultView API. https://github.com/openwebf/webf/pull/346
27. Add support for Element.dataset API. https://github.com/openwebf/webf/pull/348
28. Add Element.matches API.  https://github.com/openwebf/webf/pull/365
29. Add append() and prepend() support for Element, Document and
    DocumentElement. https://github.com/openwebf/webf/pull/361
30. Add before() and after() support for Element and
    CharaterData. https://github.com/openwebf/webf/pull/361
31. Add Element.closest API. https://github.com/openwebf/webf/pull/364
32. Add HTMLScriptElement.readyState API. https://github.com/openwebf/webf/pull/367

**Bug Fixed**

1. fix: fix pan scroll on desktop versions. https://github.com/openwebf/webf/pull/248
2. fix: canvas should clip overflowed element. https://github.com/openwebf/webf/pull/263
3. fix: ic should use none instead of atom flag and free it to prevent double
   delete. https://github.com/openwebf/webf/pull/277
4. fix: pending promise crash for early gc and add lto to
   quickjs. https://github.com/openwebf/webf/pull/283
5. fix update className property on hidden element. https://github.com/openwebf/webf/pull/255
6. fix bytecode read should free atom to prevent leak. https://github.com/openwebf/webf/pull/285
7. fix empty src on image. https://github.com/openwebf/webf/pull/286
8. fix <img /> can not be GC even if it's detached or removed from the DOM
   tree. https://github.com/openwebf/webf/pull/291
9. fix change size of canvas element didn't works. https://github.com/openwebf/webf/pull/276
10. fix: ic free atom crash when ctx early free. https://github.com/openwebf/webf/pull/293
11. fix: fix script execution order with inline script
    element. https://github.com/openwebf/webf/pull/273
12. fix css function resolve base url. https://github.com/openwebf/webf/pull/282
13. fix: rules didn't match which start with undefine
    at-rules. https://github.com/openwebf/webf/pull/294
14. fix: fix child_node_list can be null.  https://github.com/openwebf/webf/pull/297
15. fix native memory leaks. https://github.com/openwebf/webf/pull/292
16. fix renderObject memory leaks. https://github.com/openwebf/webf/pull/298
17. fix dom content loaded event trigger condition. https://github.com/openwebf/webf/pull/274
18. fix Element.toBlob() is not default to current
    pixel_ratio. https://github.com/openwebf/webf/pull/306
19. fix scrollable size when update. https://github.com/openwebf/webf/pull/301
20. fix layout error when using percentage value on
    transform. https://github.com/openwebf/webf/pull/307
21. fix: css priority error. https://github.com/openwebf/webf/pull/310
22. fix atob empty string cause crash. https://github.com/openwebf/webf/pull/311
23. fix canvas element get multiple context error. https://github.com/openwebf/webf/pull/312
24. fix http cache control parse error. https://github.com/openwebf/webf/pull/313
25. fix image width/height attribute. https://github.com/openwebf/webf/pull/315
26. fix crash when cancelAnimationFrame in frame
    callbacks. https://github.com/openwebf/webf/pull/317
27. fix style didn't take effect and offsetLeftToScrollContainer value is calculated
    incorrectly. https://github.com/openwebf/webf/pull/322
28. fix GIF images cause rendering performance overhead. https://github.com/openwebf/webf/pull/325
29. fix: remove flushLayout when reading contentSize. https://github.com/openwebf/webf/pull/326
30. fix setting lazy loading for an image didn't work. https://github.com/openwebf/webf/pull/328
31. fix remounting widgetElement in the same frame to the DOM tree causes renderWidgets to be
    unmounted from the renderObject tree. https://github.com/openwebf/webf/pull/329
32. fix: make sure renderObject had been layout before read view module
    properties. https://github.com/openwebf/webf/pull/333
33. fix: protect DOMTimers until the ExecutingContext
    exits. https://github.com/openwebf/webf/pull/334
34. fix reading target property on Touch caused crash. https://github.com/openwebf/webf/pull/340
35. fix css vars() and calc() in some user cases. https://github.com/openwebf/webf/pull/355
36. fix template element's content property cause mem
    leaks. https://github.com/openwebf/webf/pull/349

## 0.14.0-beta.1

* Support flutter 3.3.10/3.7.3

## 0.13.3

**Features**

* Add Self Poly Inline Cache for quickjs. https://github.com/openwebf/webf/pull/227
  | | master | feat/ic | |
  | ----------------- | ------ | ------- | ------ |
  | Richards | 752 | 888 | +18.0% |
  | Crypto | 618 | 713 | +15.3% |
  | RayTrace | 807 | 833 | +3.2% |
  | NavierStokes | 1497 | 1319 | -11.8% |
  | DeltaBlue | 744 | 845 | +13.5% |
  | Score (version 7) | 841 | 890 | +5.5% |
* Add window.getComputedStyle support. https://github.com/openwebf/webf/pull/183
* Add namespace API. https://github.com/openwebf/webf/pull/126
* The performance of `display: sliver` had been improved. https://github.com/openwebf/webf/pull/225

**Bug Fixed**

* fix: fix history pushState() API. https://github.com/openwebf/webf/pull/218
* fix: Input use leading to support line-height. https://github.com/openwebf/webf/pull/173
* fix: fix widget element unmount renderObject. https://github.com/openwebf/webf/pull/221
* fix: fix scrollable content not work when toggle
  display. https://github.com/openwebf/webf/pull/220
* fix: fix set background color on body element. https://github.com/openwebf/webf/pull/130
* fix: fix renderObject didn't disposed when frame update
  paused. https://github.com/openwebf/webf/pull/231
* fix: fix assertion when webf disposed. https://github.com/openwebf/webf/pull/228
* fix: fix CSS calc value become zero when parameter kind are
  same. https://github.com/openwebf/webf/issues/234
* fix: Query computed style for kebabize property name. https://github.com/openwebf/webf/pull/239
* fix: fix build error on M1 iOS simulator. https://github.com/openwebf/webf/pull/238
* fix: fix set max-height on scroller box. https://github.com/openwebf/webf/pull/216
* fix: fix animation transform have no effect when value are rotate(
  360deg). https://github.com/openwebf/webf/pull/184

## 0.13.2+1

* remove logs

## 0.13.2

**Features**

* Add Element.classList API support. https://github.com/openwebf/webf/pull/196
* Add RemoteDevServerService() for remote debugging. https://github.com/openwebf/webf/pull/198

**Bug Fixed**

* Fix fix call binding methods on proxies objects. https://github.com/openwebf/webf/pull/193
* Fix input have default content padding. https://github.com/openwebf/webf/pull/194
* Fix history.back() cause page reload. https://github.com/openwebf/webf/pull/195
* Fix location.href never changed. https://github.com/openwebf/webf/pull/195
* Fix CommentNode always return empty string of nodeValue. https://github.com/openwebf/webf/pull/197
* Fix fix img width become infinity when not
  attached. https://github.com/openwebf/webf/pull/200/files
* Fix unconstrained inline-block can't calculate content box
  size. https://github.com/openwebf/webf/pull/201
* Fix positioned elements should be reapply when toggle
  display. https://github.com/openwebf/webf/pull/202
* Fix replaced element didn't render with toggle display. https://github.com/openwebf/webf/pull/203
* Fix view module value changed by scroll offset. https://github.com/openwebf/webf/pull/207
* Fix initializeCookie API when twice load. https://github.com/openwebf/webf/pull/208
* Fix gesture conflict on Android devices. https://github.com/openwebf/webf/pull/210

## 0.13.2-beta.2

* Fix location.href didn't get changed when history changes.

## 0.13.2-beta.1

* fix page reload when history.back().

## 0.13.1

**Bug Fixed**

1. Fix renderBoxModel is null cause performLayout error. https://github.com/openwebf/webf/pull/187
2. Fix position absolute cause mistake overflow. https://github.com/openwebf/webf/pull/167
3. Fix var in keyframes not work. https://github.com/openwebf/webf/issues/147
4. Fix var in translate not work. https://github.com/openwebf/webf/issues/154
5. Fix unexpected token in linear-graident. https://github.com/openwebf/webf/issues/119
6. Fix tag element selector. https://github.com/openwebf/webf/issues/169
7. Fix var attribute dynamic modification exception. https://github.com/openwebf/webf/issues/144

**Feature**

1. Add `initialCookies` params on WebF widget. https://github.com/openwebf/webf/pull/186

## 0.13.0

The biggest update since the `webf/kraken` release.

1. The DOM API and C++ bindings had been redesigned and
   refactored.  https://github.com/openwebf/webf/pull/18
1. DOM node operations methods such as `Node.appendChild` and `Node.insertBefore` are 2x - 5x
   faster than 0.12.0.
2. The new C++ bindings system can keep the bridge code safer to avoid crashes.
2. Add CSS StyleSheets support.  https://github.com/openwebf/webf/pull/11
1. Support load CSS with  `<link />` element.
2. Support load CSS with `<style />` element.
4. Flutter Widgets System had been redesigned and refactored, now all flutter widgets can be used to
   define your HTMLElements, including from Flutter material design, pub.dev, and
   yours. https://github.com/openwebf/webf/pull/58
5. Add CSS animation support. https://github.com/openwebf/webf/pull/41
6. Sync the latest features from quickjs offical. https://github.com/openwebf/webf/pull/165

Others:

## Features

+ Add cookie support. https://github.com/openwebf/webf/pull/65
+ Add Quickjs column number support.  https://github.com/openwebf/webf/pull/116
+ Support return value from `webf. invokeModule` API. https://github.com/openwebf/webf/pull/54

  **Upgrade from 0.12.0**

  This feature could lead to the following error if you using `web.addWebfModuleListener` API in
  0.12.0.
  ```
  TypeError: Failed to execute '__webf_add_module_listener__' : 2 argument required, but 1 present.
          at __webf_add_module_listener__ (native)
          at <anonymous> (internal://:127)
          at <eval> (internal://:135)
  ```

  Please add the target module name to the first arguments:

  **before**
    ```javascript
    webf.addWebfModuleListener(function(moduleName, event, data) {
      if (moduleName == 'AlarmClock') {
         // ...
      }
    });
    ```

  **After**
    ```javascript
    webf.addWebfModuleListener('AlarmClock', function(event, data) {
     // ...
    });
    ```

**Bug Fixed**

+ CSS `hsl()` not works. https://github.com/openwebf/webf/issues/23
+ flex:1 failed when the parent node style has minHeight/minWidth
  property. https://github.com/openwebf/webf/pull/28
+ Fix overflow not works with transform. https://github.com/openwebf/webf/pull/48
+ Fix memory leaks caused by CSSLengthValue and
  ModuleManager. https://github.com/openwebf/webf/pull/57
+ Fix animation shaking when controlling the animation with touch
  events. https://github.com/openwebf/webf/pull/67
+ Fix webf_bridge.xcframework and quickjs.xcframework did not product when run
  `flutter build ios-frameworks` command. https://github.com/openwebf/webf/pull/71
+ Fix dynamic library not found in some android devices. https://github.com/openwebf/webf/pull/91
+ Fix position and transform to cause a more scrollable
  area. https://github.com/openwebf/webf/issues/112
+ Fix the size of HTMLElement is not always equal to the
  viewport. https://github.com/openwebf/webf/pull/122
+ Fix collapsedMarginBottom seems work incorrectly. https://github.com/openwebf/webf/issues/132
+ Fix opacity after transform not work. https://github.com/openwebf/webf/issues/142
+ Fix set attribute with CSS vars not work. https://github.com/openwebf/webf/pull/155

## 0.13.0-beta.9

* fix input border style.

## 0.13.0-beta.8

* fix macOS arm64 build error.

## 0.13.0-beta.7

* fix github action ndk path.

## 0.13.0-beta.6

* downgrade android NDK version requirement to r22b.

## 0.13.0-beta.5

* fix: request body should be UTF-8 encoded string.
* fix: fix onLoad didn't not trigger when reload.
* fix: fix rendering empty if window size is not ready.
* fix: should dispose webf managed renderObject after flutter framework does.

## 0.13.0-beta.4

* Test for new custom elements system.

## 0.13.0-beta.3

* Fix reload crash.

## 0.13.0-beta.2

* Test for new bridge and css selector.

## 0.12.0+2

**Bug Fixed**

* Add Flutter version requirement at pubspec.yaml.

## 0.12.0+1

**Bug Fixed**

* Fix Apple silicon platform build error.

## 0.12.0

**Big News**

* Set flutter version requirement to v3.0.5.

**Bug Fixed**

+ Fix devtools select dom position offset. https://github.com/openkraken/kraken/pull/1289
+ Fix the white-flash of canvas painting. https://github.com/openkraken/kraken/pull/1317
+ Fix the memory leak of animation timeline
  lifecycle. https://github.com/openkraken/kraken/pull/1312
+ Fix request failed while response was gzipped. https://github.com/openkraken/kraken/pull/1302
+ Fix exception in paragraph paint in some edge
  cases. https://github.com/openkraken/kraken/pull/1334
+ Fix flex-basis with percentage not working. https://github.com/openkraken/kraken/pull/1300
+ Fix memory leak when dispatch gesture events. https://github.com/openkraken/kraken/pull/1333
+ Fix negative margin value. https://github.com/openkraken/kraken/pull/1308
+ Fix margin auto value. https://github.com/openkraken/kraken/pull/1331
+ Fix JS error report twice. https://github.com/openkraken/kraken/pull/1337
+ Fix event concurrent exception. https://github.com/openkraken/kraken/pull/1354
+ Fix text white space collapse. https://github.com/openkraken/kraken/pull/1352
+ Fix inline replaced element layout size. https://github.com/openkraken/kraken/pull/1343
+ Fix event listener remove when call
  removeEventListener. https://github.com/openkraken/kraken/pull/1357/files
+ Fix error of textNode when attach to WidgetElement. https://github.com/openkraken/kraken/pull/1336
+ Fix null safety error when handle pointer events. https://github.com/openkraken/kraken/pull/1360
+ Fix script element with async attribute error. https://github.com/openkraken/kraken/pull/1358
+ Fix event handlers removal with once time. https://github.com/openkraken/kraken/pull/1359
+ Fix text not wrap in flex container of column
  direction. https://github.com/openkraken/kraken/pull/1356
+ Fix the sliver with positioned element usage
  problem. https://github.com/openkraken/kraken/pull/1341
+ Fix set overflow on body can still scroll. https://github.com/openkraken/kraken/pull/1366
+ Fix positioned element offset when containing block has
  transform. https://github.com/openkraken/kraken/pull/1368
+ Fix replaced flex item size. https://github.com/openkraken/kraken/pull/1338
+ Fix memory usage of img element. https://github.com/openkraken/kraken/pull/1347
+ Fix position: fixed elements hittest not correct. https://github.com/openkraken/kraken/pull/1374
+ Fix html scroll value. https://github.com/openkraken/kraken/pull/1367
+ Fix custom element widget unmount. https://github.com/openkraken/kraken/pull/1375
+ Fix the null value for CSS content-visibility and
  position. https://github.com/openkraken/kraken/pull/1389
+ Fix custom element item layout. https://github.com/openkraken/kraken/pull/1392
+ Fix script elements sync load order. https://github.com/openkraken/kraken/pull/1405
+ Fix element.style property match. https://github.com/openkraken/kraken/pull/1410
+ Fix viewport dispose twice. https://github.com/openkraken/kraken/pull/1404
+ Fix localToGlobal on silver container. https://github.com/openkraken/kraken/pull/1421
+ Fix add PointerDeviceKind on scrollable. https://github.com/openkraken/kraken/pull/1439
+ Fix add new child of sliver container. https://github.com/openkraken/kraken/pull/1412
+ Fix stylesheet can not load with link elements. https://github.com/openkraken/kraken/pull/1441
+ Fix not support relative protocol. https://github.com/openkraken/kraken/pull/1444

**Features**

+ Add reset for canvas rendering context 2d. https://github.com/openkraken/kraken/pull/1310
+ Add temporary Console panel at Chrome DevTools. https://github.com/openkraken/kraken/pull/1328
+ Add built-in attributes for event handlers. https://github.com/openkraken/kraken/pull/1330
+ Add document.getElementsByName API. https://github.com/openkraken/kraken/pull/1383
+ Add absolute-size & relative-size keywords of
  font-size. https://github.com/openkraken/kraken/pull/1430
+ Add scroll support of input、textarea、sliver with mouse wheel when setting
  overflow. https://github.com/openkraken/kraken/pull/1438

## 0.11.0

**Breaking Changes**

+ Update flutter requirement to 2.8.x https://github.com/openkraken/kraken/pull/1298

**Bug Fixed**

- Fix Kraken widget instance memory leak from window. https://github.com/openkraken/kraken/pull/1297

## 0.10.4

**Features**

+ Support window.innerWidth & window.innerHeight, and screen.availWidth &
  screen.availHeight. https://github.com/openkraken/kraken/pull/1256

**Bug Fixed**

+ Fix error when using KrakenBundle.fromByteCode(). https://github.com/openkraken/kraken/pull/1245
+ Fix DataBundle string with non latin. https://github.com/openkraken/kraken/pull/1263

** Others **

+ Change copyright to `The Kraken authors`.

## 0.10.3

**Bug Fixed**

+ Fix Http cache file io error https://github.com/openkraken/kraken/pull/1202.
+ Fix align-self not work for positioned flex item. https://github.com/openkraken/kraken/pull/1207
+ Fix text-align should only work for text node for flex
  item. https://github.com/openkraken/kraken/pull/1208
+ Fix crash with scrolling.  https://github.com/openkraken/kraken/pull/1209
+ Fix children of inline-block element not stretch. https://github.com/openkraken/kraken/pull/1214
+ Fix style set to empty string. https://github.com/openkraken/kraken/pull/1220
+ Fix flex item not stretch when child size changed. https://github.com/openkraken/kraken/pull/1229
+ Fix html parse error. https://github.com/openkraken/kraken/pull/1231
+ Fix asset protocol error. https://github.com/openkraken/kraken/pull/1232
+ Fix file protocol. https://github.com/openkraken/kraken/pull/1234

## 0.10.2+1

**Bug Fixed**

+ Fix ios framework bundle missing CFBundleVersion and CFBundleAShortVersionString
  key. https://github.com/openkraken/kraken/pull/1194

## 0.10.2

**Bug Fixed**

+ Fix report error cause stack overflow. https://github.com/openkraken/kraken/pull/1164
+ Fix object-fit not work due to image resize
  optimization. https://github.com/openkraken/kraken/pull/1165
+ Fix crash when reload. https://github.com/openkraken/kraken/pull/1167
+ Fix referer and origin. https://github.com/openkraken/kraken/pull/1170
+ Fix large file content may fail. https://github.com/openkraken/kraken/pull/1176
+ Fix native event memory align on 32 bit devices. https://github.com/openkraken/kraken/pull/1182
+ Fix image load error cause crash. https://github.com/openkraken/kraken/pull/1187

## 0.10.1

**Bug Fixed**

+ Fix custom flutter widget when kraken disposed.  https://github.com/openkraken/kraken/pull/1142
+ Fix scrollable size should include padding. https://github.com/openkraken/kraken/pull/1135
+ Fix http request doesn't support multiple headers. https://github.com/openkraken/kraken/pull/1148
+ Fix document.location is undefined. https://github.com/openkraken/kraken/pull/1150

## 0.10.0+5

**Bug Fixed**

+ Fix WebSocket dev server error. https://github.com/openkraken/kraken/pull/1131
+ Fix image intrinsic size not correct which include padding and
  border. https://github.com/openkraken/kraken/pull/1127
+ Fix unhandledPromiseRejection event. https://github.com/openkraken/kraken/pull/1137
+ Fix fetch API request options. https://github.com/openkraken/kraken/pull/1139

## 0.10.0+4

**Bug Fixed**

+ Fix HttpCache error on linux platform. https://github.com/openkraken/kraken/pull/1113
+ Fix exception leak cause globalObject not fully
  freed. https://github.com/openkraken/kraken/pull/1117
+ Fix border radius of one percentage value. https://github.com/openkraken/kraken/pull/1121

## 0.10.0+3

**Bug Fixed**

+ Fix empty screen when page reload. https://github.com/openkraken/kraken/pull/1109
+ Fix linux dynamic rpath. https://github.com/openkraken/kraken/pull/1111

## 0.10.0+2

**Bug Fixed**

+ Fix error when set empty string to textOverflow. https://github.com/openkraken/kraken/pull/1095
+ Fix input delete key binding. https://github.com/openkraken/kraken/pull/1096
+ Fix load kraken bundle from env and native side. https://github.com/openkraken/kraken/pull/1098
+ Fix crash when reload page. https://github.com/openkraken/kraken/pull/1102

## 0.10.0+1

**Bug Fixed**

+ Fix stack overflow when working with multiple
  thread. https://github.com/openkraken/kraken/pull/1086
+ Fix sepeated setting of style is invalid. https://github.com/openkraken/kraken/pull/1088

## 0.10.0

**Break Changes**

* `Kraken.loadURL`, `Kraken.loadContent`, `Kraken.loadByteCode` are deprecated. Please use
  `KrakenBundle.fromUrl`, `KrakenBundle.fromContent` instead.
* Flutter Widget API had been upgraded, please refer
  to https://openkraken.com/guide/advanced/widget-custom-element for more info.

**Big News**

* Support using Flutter Widget as HTML Custom Element which can greatly extend the capability of
  Web, refer to [this doc](https://openkraken.com/en-US/guide/advanced/widget-custom-element) for
  detailed use.

+ Performance optimized:
  - Page load time reduced 10%.
  - Scrolling FPS incrased 40%.
+ Linux platform supported.
+ Support Flutter 2.5.3.

**Features**

+ Support defining Flutter widget as HTML custom
  element. https://github.com/openkraken/kraken/pull/904
+ Support `style` element and `className` attribute. https://github.com/openkraken/kraken/pull/656
+ Support  `link` element and CSS variables. https://github.com/openkraken/kraken/pull/961
+ Support `assets:` protocol to unify the means to load local assets for different
  platforms. https://github.com/openkraken/kraken/pull/866
+ Support pause kraken pages when navigator changes. https://github.com/openkraken/kraken/pull/877
+ Support linux platform. https://github.com/openkraken/kraken/pull/887
+ Support customize kraken dynamic library path. https://github.com/openkraken/kraken/pull/1048

**Bug Fixed**

+ Fix width error in case of min width width padding. https://github.com/openkraken/kraken/pull/843
+ Fix percentage with decimal point. https://github.com/openkraken/kraken/pull/845
+ Fix iOS App store certificate validation. https://github.com/openkraken/kraken/pull/847
+ Fix text height with text-overflow ellipsis. https://github.com/openkraken/kraken/pull/848
+ Fix clone documentFragment node support. https://github.com/openkraken/kraken/pull/851
+ Fix layout wrapping space. https://github.com/openkraken/kraken/pull/856
+ Fix position placeholder offset not including
  margin. https://github.com/openkraken/kraken/pull/857
+ Fix position sticky fail with overflow hidden. https://github.com/openkraken/kraken/pull/858
+ Fix HTMLAnchorElement lack full property support. https://github.com/openkraken/kraken/pull/864
+ Fix HTMLBRElement size not correct. https://github.com/openkraken/kraken/pull/867
+ Fix crash due to disposeEventTarget sync
  implementation. https://github.com/openkraken/kraken/pull/873
+ Fix image performance by add image cache. https://github.com/openkraken/kraken/pull/879
+ Fix empty text node renderObject. https://github.com/openkraken/kraken/pull/881
+ Fix previous blank of text node. https://github.com/openkraken/kraken/pull/886
+ Fix only trigger gc once when disposed. https://github.com/openkraken/kraken/pull/892
+ Fix crash due to weak reference between style and
  element. https://github.com/openkraken/kraken/pull/895
+ Fix layout performance by caching constraints. https://github.com/openkraken/kraken/pull/897
+ Fix sliver child is text without renderer should not
  accept. https://github.com/openkraken/kraken/pull/898
+ Fix renderObject and element memory leaks. https://github.com/openkraken/kraken/pull/900
+ Fix hit test children not works in sliver list. https://github.com/openkraken/kraken/pull/905
+ Fix intersection observer performance. https://github.com/openkraken/kraken/pull/908
+ Fix crash when reportError. https://github.com/openkraken/kraken/pull/913
+ Fix style fail after resize. https://github.com/openkraken/kraken/pull/916
+ Fix some sliver usage cases. https://github.com/openkraken/kraken/pull/922
+ Fix free event targets properties by gc mark. https://github.com/openkraken/kraken/pull/929
+ Fix insert before fixed element. https://github.com/openkraken/kraken/pull/930
+ Fix document.createElement in multiple context. https://github.com/openkraken/kraken/pull/935
+ Fix error due to lacking negative length validation. https://github.com/openkraken/kraken/pull/938
+ Fix bridge memory leaks. https://github.com/openkraken/kraken/pull/939
+ Fix nested fixed element paint order. https://github.com/openkraken/kraken/pull/947
+ Fix image natural size with same url. https://github.com/openkraken/kraken/pull/948
+ Fix createElement and createTextNode performance. https://github.com/openkraken/kraken/pull/952
+ Fix text not shrink in flex container. https://github.com/openkraken/kraken/pull/980
+ Fix text rendering performance. https://github.com/openkraken/kraken/pull/990
+ Fix flex stretch height when positioned child
  exists. https://github.com/openkraken/kraken/pull/1004
+ Fix transform should avoid trigger layout. https://github.com/openkraken/kraken/pull/1008
+ Fix ui command buffer instance leak. https://github.com/openkraken/kraken/pull/1014
+ Fix element attributes incorrect reference count. https://github.com/openkraken/kraken/pull/1020
+ Fix relayout boundary of flex item. https://github.com/openkraken/kraken/pull/1023
+ Fix element insert order of insertBefore. https://github.com/openkraken/kraken/pull/1024
+ Fix event target string property leak. https://github.com/openkraken/kraken/pull/1028
+ Fix reposition children logic lacking when position
  changed. https://github.com/openkraken/kraken/pull/1033
+ Fix this_val on global func call. https://github.com/openkraken/kraken/pull/1036
+ Fix event type atom id changed when free. https://github.com/openkraken/kraken/pull/1040
+ Fix offsetTop and offsetLeft should relative to body element if no positioned parent
  found. https://github.com/openkraken/kraken/pull/1041
+ Fix percentage of positioned element. https://github.com/openkraken/kraken/pull/1044
+ Fix input should blur when click other target. https://github.com/openkraken/kraken/pull/1052
+ Fix positioned element logical width/height
  calculation. https://github.com/openkraken/kraken/pull/1053

## 0.9.0

**Big News**

The QuickJS engine is now landed on kraken and we decided to replace our original JavaScriptCore
implementation, which can provide low latency page init time and memory usage.

**Break Changes**

+ `Kraken.defineCustomElement` API had been redesigned, now you can define both element and widget
  with the same API. https://github.com/openkraken/kraken/pull/792

**Features**

+ Migrate JavaScript Engine from JavaScriptCore to QuickJS.
+ Support query attributes on element from `document.querySelector` and
  `document.querySelectorAll`. https://github.com/openkraken/kraken/pull/747
+ Auto detect physical device type and use different scroll animation behavior.
  `BouncingScrollPhysics` on iOS and `ClampingScrollPhysics` on
  Android. https://github.com/openkraken/kraken/pull/750
+ Add empty SVGElement tags but not svg rendering, to let vue app
  works. https://github.com/openkraken/kraken/pull/757
+ Add Apple silicon support. https://github.com/openkraken/kraken/pull/767
+ Add Webpack HMR support. https://github.com/openkraken/kraken/pull/785

**Bug Fixed**

+ Fix async error when update src property on image
  element. https://github.com/openkraken/kraken/pull/759
+ Fix http-cache not updating when `last-modified` headers on HTTP request
  changed. https://github.com/openkraken/kraken/pull/784
+ Fix HTML tags can not use custom tags. https://github.com/openkraken/kraken/pull/790
+ Fix rendering error when append child on image
  elemnet. https://github.com/openkraken/kraken/pull/791
+ Fix translate negative percentage not working. https://github.com/openkraken/kraken/pull/832

## 0.8.4

**Break Changes**

+ Navigator.vibrate API no long support as default. https://github.com/openkraken/kraken/pull/655
+ Rename `kraken.setMethodCallHandler` to
  `kraken.addMethodCallHandler`. https://github.com/openkraken/kraken/pull/658
+ `gestureClient` API migrated to `GestureListener`
  API. https://github.com/openkraken/kraken/pull/716

**Features**

+ Support documentFragment. https://github.com/openkraken/kraken/pull/641
+ Add default 1em margin for `<p>` https://github.com/openkraken/kraken/pull/648
+ Support document.querySelector and
  document.querySelectorAll. https://github.com/openkraken/kraken/pull/672
+ Improve canvas performance when drawing pictures. https://github.com/openkraken/kraken/pull/679
+ Use xcframework for iOS release. https://github.com/openkraken/kraken/pull/698
+ Support vue-router with History API. https://github.com/openkraken/kraken/pull/711
+ Support `<template />` and element.innerHTML API. https://github.com/openkraken/kraken/pull/713
+ Support offline http cache. https://github.com/openkraken/kraken/pull/723

**Bug Fixed**

+ Fix webpack hot reload. https://github.com/openkraken/kraken/issues/642
+ Fix hit test with detached child render object. https://github.com/openkraken/kraken/pull/651
+ Fix silver conflict with overflow-y. https://github.com/openkraken/kraken/pull/662
+ Fix child of flex item with flex-grow not stretch. https://github.com/openkraken/kraken/pull/665
+ Fix auto margin in flexbox. https://github.com/openkraken/kraken/pull/667
+ Fix positioned element size wrong when no width/height is
  set. https://github.com/openkraken/kraken/pull/671
+ Fix scroll not working when overflowY is set to auto/scroll and overflowX not
  set. https://github.com/openkraken/kraken/pull/681
+ Fix multi frame image can replay when loading from
  caches.  https://github.com/openkraken/kraken/pull/685
+ Fix main axis auto size not including margin. https://github.com/openkraken/kraken/pull/702

## 0.8.3+3

**Bug Fixed**

+ Fix error when reading local path. https://github.com/openkraken/kraken/pull/635

## 0.8.3+2

**Bug Fixed**

+ Fix fetch request lost HTTP headers. https://github.com/openkraken/kraken/pull/633

## 0.8.3+1

**Bug Fixed**

+ Fix ios build. https://github.com/openkraken/kraken/pull/629

## 0.8.3

**Bug Fixed**

+ Fix crash caused by context has been released. https://github.com/openkraken/kraken/pull/605
+ Fix window.open() not working when bundleURL not
  exist. https://github.com/openkraken/kraken/pull/612
+ Fix location.href is empty when set onLoadError
  handler. https://github.com/openkraken/kraken/pull/613
+ Fix http cache should not intercept multi times. https://github.com/openkraken/kraken/pull/619
+ Fix input value when set to null. https://github.com/openkraken/kraken/pull/623
+ Fix input change event not trigger when blur. https://github.com/openkraken/kraken/pull/626
+ Fix keyboard not shown when keyboard dismissed and input gets focused
  again. https://github.com/openkraken/kraken/pull/627

**Features**

+ Support window.onerror and global error event. https://github.com/openkraken/kraken/pull/601
+ Add HTML Head's tags, like `<head>`, `<link>`,
  `<style>`. https://github.com/openkraken/kraken/pull/603
+ Support customize `User-Agent` header. https://github.com/openkraken/kraken/pull/604
+ Remove androidx dependence. https://github.com/openkraken/kraken/pull/606
+ Add default margin for h1-h6 elements. https://github.com/openkraken/kraken/pull/607

## 0.8.2+1

**Bug Fixed**

+ Fix kraken widget layout size https://github.com/openkraken/kraken/pull/584
+ Fix input can not focus when hitting enter key https://github.com/openkraken/kraken/pull/595

## 0.8.2

**Features**

+ Support percentage for translate3d translateX and
  translateY https://github.com/openkraken/kraken/pull/547
+ Add findProxyFromEnvironment methods in
  HttpOverrides. https://github.com/openkraken/kraken/pull/551/files
+ Treat empty scheme as https protocol. https://github.com/openkraken/kraken/pull/557/files
+ Support length/percentage value for background-size. https://github.com/openkraken/kraken/pull/568
+ Support dbclick event. https://github.com/openkraken/kraken/pull/573

**Bug Fixed**

+ Fix crash when HMR enabled. https://github.com/openkraken/kraken/pull/507
+ Fix parent box height can't auto caculate by scrollable container
  children. https://github.com/openkraken/kraken/pull/517
+ Fix linear-gradient parse failed when have more than one
  bracket. https://github.com/openkraken/kraken/pull/518
+ Fix image flex items have no size. https://github.com/openkraken/kraken/pull/520
+ Fix transition throw error. https://github.com/openkraken/kraken/pull/542
+ Fix empty screen in launcher mode. https://github.com/openkraken/kraken/pull/544
+ Fix element instanceof HTMLElement return false https://github.com/openkraken/kraken/pull/546
+ Fix transition animation execution order. https://github.com/openkraken/kraken/pull/559
+ Fix transition of backgroundColor with no default value not
  working. https://github.com/openkraken/kraken/pull/562
+ Fix opacity 0 not working. https://github.com/openkraken/kraken/pull/565
+ Fix hittest with z-index order. https://github.com/openkraken/kraken/pull/572
+ Fix click event not triggerd on input element. https://github.com/openkraken/kraken/pull/575
+ Fix ios bridge build. https://github.com/openkraken/kraken/pull/576

## 0.8.1

**Features**

+ input element not support maxlength property https://github.com/openkraken/kraken/pull/450
+ support em and rem CSS length https://github.com/openkraken/kraken/pull/475

**Bug Fixed**

+ remove same origin policy for xhr https://github.com/openkraken/kraken/pull/463
+ fix error when scroll to top in silver box https://github.com/openkraken/kraken/issues/468
+ fix js contextId allocate order
  error https://github.com/openkraken/kraken/pull/474 https://github.com/openkraken/kraken/pull/477

## 0.8.0+2

**Features**

+ input element now support inputmode property https://github.com/openkraken/kraken/pull/441

## 0.8.0+1

**Bug Fixed**

+ Fix DOM events can't bind with addEventListener https://github.com/openkraken/kraken/pull/436

## 0.8.0

**Big News**

+ Kraken v0.8.0 now support flutter 2.2.0

**Features**

+ Support dart null safety and all dependencies had upgraded.
+ Lock Android NDK version to 21.4.7075529. https://github.com/openkraken/kraken/pull/394
+ Add length value support in background-position https://github.com/openkraken/kraken/pull/421

**Bug Fixed**

+ Fix error when setting element's eventHandler property to
  null  https://github.com/openkraken/kraken/pull/426
+ Fix crash when trigger `touchcancel` events https://github.com/openkraken/kraken/pull/424
+ Fix error when reload kraken pages. https://github.com/openkraken/kraken/pull/419
+ Fix element's doesn't show up when setting display: none to display:
  block. https://github.com/openkraken/kraken/pull/405
+ Fix empty blank screen in Android / iOS physical devices launching with SDK
  mode. https://github.com/openkraken/kraken/pull/399
+ Fix WebView (created by iframe element) can't
  scroll. https://github.com/openkraken/kraken/pull/398
+ Fix percentage length doesn't work in flex layout
  box. https://github.com/openkraken/kraken/pull/397
+ Fix input element's height can't set with CSS height
  property. https://github.com/openkraken/kraken/pull/395
+ Fix crash when set element.style multiple times in a short of
  times. https://github.com/openkraken/kraken/pull/391

## 0.7.3+2

**Features**

+ Input element now support type=password options https://github.com/openkraken/kraken/pull/377

**Bug Fixed**

+ Fix event can't bubble to document element https://github.com/openkraken/kraken/pull/380
+ fix: fix bridge crash with getStringProperty on
  InputElement. https://github.com/openkraken/kraken/pull/386

## 0.7.3+1

* Fix: fix prebuilt binary.

## 0.7.3

**Features**

+ Feat: add network proxy interface in dart widget API https://github.com/openkraken/kraken/pull/292
+ Feat: add AsyncStorage.length method https://github.com/openkraken/kraken/pull/298
+ Feat: improve bridge call performance. https://github.com/openkraken/kraken/pull/328
+ feat: add SVGElement https://github.com/openkraken/kraken/pull/338

**Bug Fixed**

+ Fix input setting value does not take effect before adding the dom
  tree. https://github.com/openkraken/kraken/pull/297/files
+ Fix: remove unnecessary flushUICommand https://github.com/openkraken/kraken/pull/318
+ Fix: img lazy loading not work https://github.com/openkraken/kraken/pull/319
+ Fix: touchend crash caused by bridge https://github.com/openkraken/kraken/pull/320
+ Fix: fix target of the event agent does not point to the clicked
  Node https://github.com/openkraken/kraken/pull/322

**Refactor**

+ refactor: position sticky https://github.com/openkraken/kraken/pull/324

## 0.7.2+4

feat: support mouse event https://github.com/openkraken/kraken/pull/220
fix: event bubble not works properly https://github.com/openkraken/kraken/pull/264
fix: return value of Event.stopPropagation() should be
undefined https://github.com/openkraken/kraken/pull/284
fix/text node value https://github.com/openkraken/kraken/pull/279
fix: fix kraken.methodChannel.setMethodCallHandler did't get called before kraken.invokeMethod
called https://github.com/openkraken/kraken/pull/289

## 0.7.2+3

feat: add willReload and didReload hooks for devTools.

## 0.7.2+2

fix: export getUIThreadId and getGlobalContextRef symbols.

## 0.7.2+1

fix: export getDartMethod() symbols.

## 0.7.2

**Break Changes**

fix: change default font size from 14px to 16px https://github.com/openkraken/kraken/pull/145

**Bug Fixed**
fix: modify customevent to event https://github.com/openkraken/kraken/pull/138
fix: layout performance  https://github.com/openkraken/kraken/pull/155
fix: fix elements created by new operator didn't have
ownerDocument. https://github.com/openkraken/kraken/pull/178
fix: flex-basis rule https://github.com/openkraken/kraken/pull/176
fix: transform functions split error when more than
one.  https://github.com/openkraken/kraken/pull/196
fix: Fix the crash caused by navigation in dart https://github.com/openkraken/kraken/pull/249
fix update device_info 1.0.0  https://github.com/openkraken/kraken/pull/262

## 0.7.1

**Bug Fixed**

- fix: resize img wainting for img layouted[#86](https://github.com/openkraken/kraken/pull/86)
- fix: fix: encoding snapshots filename to compact with
  windows. [#69](https://github.com/openkraken/kraken/pull/69)
- fix: fix insertBefore crash when passing none node
  object. [#70](https://github.com/openkraken/kraken/pull/70)
- fix: windows platform support build target to
  Android. [#88](https://github.com/openkraken/kraken/pull/88)
- fix: element size not change when widget size
  change [#90](https://github.com/openkraken/kraken/pull/90)
- fix: fix navigation failed of anchor element. [#95](https://github.com/openkraken/kraken/pull/95)
- fix: 'kraken.methodChannel.setMethodCallHandler' override previous
  handler [#96](https://github.com/openkraken/kraken/pull/96)
- fix: repaintBoundary convert logic [#111](https://github.com/openkraken/kraken/pull/111)
- fix: element append order wrong with comment node
  exists [#116](https://github.com/openkraken/kraken/pull/116)
- fix: fix access Node.previousSibling crashed when target node at top of
  childNodes. [#126](https://github.com/openkraken/kraken/pull/126)
- fix: fix access Element.children crashed when contains non-element nodes in
  childNodes. [#126](https://github.com/openkraken/kraken/pull/126)
- fix: percentage resolve fail with multiple sibling
  exists [#144](https://github.com/openkraken/kraken/pull/144)
- fix: default unknow element display change to
  inline [#133](https://github.com/openkraken/kraken/pull/133)

**Feature**

- feat: support Node.ownerDocument [#107](https://github.com/openkraken/kraken/pull/107)
- feat: support vmin and vmax [#109](https://github.com/openkraken/kraken/pull/109)
- feat: support css none value [#129](https://github.com/openkraken/kraken/pull/129)
- feat: suport Event.initEvent() and
  Document.createEvent() [#130](https://github.com/openkraken/kraken/pull/131)
- feat: Add block element: h1-h6 main header
  aside. [#133](https://github.com/openkraken/kraken/pull/133)
- feat: Add inline element: small i code
  samp... [#133](https://github.com/openkraken/kraken/pull/133)

## 0.7.0

**Bug Fixed**

- fix: zIndex set fail [#45](https://github.com/openkraken/kraken/pull/45)
- fix: border radius percentage [#50](https://github.com/openkraken/kraken/pull/50)
- fix: create text node empty string has height [#52](https://github.com/openkraken/kraken/pull/52)
- fix: cached percentage image has no size [#54](https://github.com/openkraken/kraken/pull/54)
- fix: fix set property to window did't refer to
  globalThis [#60](https://github.com/openkraken/kraken/pull/60)
- fix: box-shadow [#66](https://github.com/openkraken/kraken/pull/66)

**Feature**

- Feat: resize if viewport changed [#47](https://github.com/openkraken/kraken/pull/47)
