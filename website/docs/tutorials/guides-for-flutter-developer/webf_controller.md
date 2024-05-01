---
sidebar_position: 2
title: The WebFController and WebF Widget
---

## The WebFController Class

The WebFController class encapsulates a WebF page's context, including its isolated JavaScript runtime. Initializing a WebFController is akin to opening a page in a browser and is essential for utilizing WebF.

### viewportSize

You can set a fixed viewport size using the `viewportWidth` and `viewportHeight` properties.

```dart
var controller = WebFController(
  context,
  viewportWidth: 200,
  viewportHeight: 200,
);
```

### background

This property sets the background color of the rendered content. The default color is white.

```dart
controller = WebFController(
  context,
  background: Colors.white,
);
```

### MethodChannel

For details on Dart and JavaScript intercommunication, refer to [Dart and JS Intercommunication](/docs/tutorials/guides-for-flutter-developer/dart_js_intercommunication).

### navigationDelegate

This property allows you to intercept or handle navigation actions initiated by `<a />` tags or changes to the `location.href` property in JavaScript.

```dart
WebFNavigationDelegate delegate = WebFNavigationDelegate();
delegate.setDecisionHandler((action) async {
  if (action.target.contains('home')) {
    return WebFNavigationActionPolicy.cancel;
  }
  return WebFNavigationActionPolicy.allow;
});

controller = WebFController(
  context,
  navigationDelegate: delegate
);
```

### Bundle

Defines the page loading entry point, effectively an alias for `controller.preload(bundle)`.

### runningThread

For details on running JavaScript in a dedicated thread, see [Dedicated Thread Mode](/docs/tutorials/performance_optimization/multiple_thread_mode).

### Event Callbacks

- `onLoad`: Triggered when the page fully loads.
- `onDOMContentLoaded`: Fires when the DOM content has fully loaded.
- `onLoadError`: Executes if there is a network error while loading remote resources.
- `onJSError`: Executes when an unexpected JavaScript error occurs.

### httpClientInterceptor

This property allows interception or capture of network requests made by WebF.

```dart
class CustomWebFHttpInterceptor extends HttpClientInterceptor {
  // Implementations
}
controller = WebFController(
  context,
  httpClientInterceptor: CustomWebFHttpInterceptor(),
);
```

### devToolsService [experimental]

Enables the use of Chrome Developer Tools for inspecting elements and stylesheets.

```dart
controller = WebFController(
  context,
  devToolsService: ChromeDevToolsService(),
);
```

### uriParser

Customizes the behavior for resolving paths when loading external resources.

```dart
class WebFCustomUriParser extends UriParser {
  @override
  Uri resolve(Uri base, Uri relative) {
    Uri resolvedUri = super.resolve(base, relative);
    resolvedUri.removeFragment();
    return resolvedUri;
  }
}
controller = WebFController(
  context,
  uriParser: WebFCustomUriParser(),
);
```

### preloadedBundles

An array of WebFBundles to preload, enhancing performance for recurring resources.

```dart
// In somewhere before WebFController created
WebFBundle preloadFont = WebFBundle.fromUrl('http://xxx.com/font.ttf');
await preloadFont.resolve();
await preloadFont.obtainData();

controller = WebFController(
  context,
  preloadedBundles: [preloadFont],
);
```

### initialCookies

Sets initial cookies for request headers.

```dart
controller = WebFController(
  context,
  initialCookies: [Cookie.fromSetCookieValue('name=value')],
);
```

## The WebF Widget

The WebF Widget serves as the visual entry point for WebF, integrating HTML/CSS/JavaScript content into Flutter applications seamlessly.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('WebF Demo'),
    ),
    body: Center(
      child: WebF(controller: controller),
    ),
  );
}
```