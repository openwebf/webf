---
sidebar_position: 5
title: Offline Resources Loading
---

WebF supports the `https://`, `http://`, `file://`, and `assets://` protocols for fetching external resources.

## `http://` and `https://` Protocols

Like web browsers, the standard method to fetch remote resources is through the HTTP protocol.

```dart
controller = WebFController(
  context,
);
controller.preload(WebFBundle.fromUrl('https://xxx.com/demo.html'));
```

## `file://` Protocol

This protocol is used to access any disk location with readable permissions, available on both desktop and mobile platforms.

```dart
controller = WebFController(
  context,
);
controller.preload(WebFBundle.fromUrl('file:///data/demo/demo.html'));
```

## `assets://` Protocol

This protocol is used for resources bundled with Flutter assets.

```dart
controller = WebFController(
  context,
);
controller.preload(WebFBundle.fromUrl('assets:///assets/bundle.html'));
```