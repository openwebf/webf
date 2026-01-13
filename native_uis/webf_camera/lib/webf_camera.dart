/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:webf/webf.dart';

export 'src/camera.dart';

import 'src/camera.dart';

/// Installs all Camera UI custom elements for WebF.
///
/// Call this function in your main() before running your WebF application
/// to register the camera custom element.
///
/// Example:
/// ```dart
/// void main() {
///   installWebFCamera();
///   runApp(MyApp());
/// }
/// ```
void installWebFCamera() {
  WebF.defineCustomElement(
      'flutter-camera', (context) => FlutterCamera(context));
}
