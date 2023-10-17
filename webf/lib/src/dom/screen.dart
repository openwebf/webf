/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';
import 'package:webf/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/launcher.dart';

// As its name suggests, the Screen interface represents information about the screen of the output device.
// https://drafts.csswg.org/cssom-view/#the-screen-interface
class Screen extends BindingObject {
  final FlutterView currentView;
  Screen(int contextId, this.currentView, WebFViewController view) : super(BindingContext(view, contextId, allocateNewBindingObject()));

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    properties['availWidth'] = BindingObjectProperty(getter: () => availWidth);
    properties['availHeight'] = BindingObjectProperty(getter: () => availHeight);
    properties['width'] = BindingObjectProperty(getter: () => width);
    properties['height'] = BindingObjectProperty(getter: () => height);
  }

  // The availWidth attribute must return the width of the Web-exposed available screen area.
  // The Web-exposed available screen area is one of the following:
  //   - The available area of the rendering surface of the output device, in CSS pixels.
  //   - The area of the output device, in CSS pixels.
  //   - The area of the viewport, in CSS pixels.
  // @NOTE: Why using physicalSize: in most cases, kraken is integrated into host native app,
  //        so the size of kraken view is depending on how big is the flutter view, for users
  //        they can not adjust size of kraken view. The [window.physicalSize] is the size of
  //        native flutter view. (@zeroling)
  int get availWidth => currentView.physicalSize.width ~/ currentView.devicePixelRatio;

  // The availHeight attribute must return the height of the Web-exposed available screen area.
  int get availHeight => currentView.physicalSize.height ~/ currentView.devicePixelRatio;

  // The width attribute must return the width of the Web-exposed screen area.
  // The Web-exposed screen area is one of the following:
  //   - The area of the output device, in CSS pixels.
  //   - The area of the viewport, in CSS pixels.
  int get width => currentView.physicalSize.width ~/ currentView.devicePixelRatio;

  // The height attribute must return the height of the Web-exposed screen area.
  int get height => currentView.physicalSize.height ~/ currentView.devicePixelRatio;
}
