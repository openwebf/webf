/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:ui';
import 'package:webf/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/launcher.dart';

class ScreenData extends Struct {
  @Int64()
  external int availWidth;

  @Int64()
  external int availHeight;

  @Int64()
  external int width;

  @Int64()
  external int height;
}

// As its name suggests, the Screen interface represents information about the screen of the output device.
// https://drafts.csswg.org/cssom-view/#the-screen-interface
class Screen extends StaticBindingObject {
  final FlutterView currentView;
  Screen(double contextId, this.currentView, WebFViewController view) : super(BindingContext(view, contextId, allocateNewBindingObject()));

  @override
  Pointer<Void> buildExtraNativeData() {
    Pointer<ScreenData> extraData = malloc.allocate(sizeOf<ScreenData>());
    extraData.ref.width = currentView.physicalSize.width ~/ currentView.devicePixelRatio;
    extraData.ref.height = currentView.physicalSize.height ~/ currentView.devicePixelRatio;
    extraData.ref.availWidth = currentView.physicalSize.width ~/ currentView.devicePixelRatio;
    extraData.ref.availHeight = currentView.physicalSize.height ~/ currentView.devicePixelRatio;
    return extraData.cast<Void>();
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
