/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'dart:ffi' hide Size;
import 'package:ffi/ffi.dart';
import 'dart:ui' show Size;
import 'package:webf/bridge.dart';
import 'package:webf/launcher.dart';

final class ScreenData extends Struct {
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
  final WebFViewController view;
  Screen(double contextId, this.view)
      : super(BindingContext(view, contextId, allocateNewBindingObject()));

  Screen.zero(double contextId, this.view)
      : super(BindingContext(view, contextId, allocateNewBindingObject()));

  @override
  Pointer<Void> buildExtraNativeData() {
    Pointer<ScreenData> extraData = malloc.allocate(sizeOf<ScreenData>());
    Size viewportSize = view.viewport?.boxSize ?? Size.zero;
    extraData.ref.width = viewportSize.width.toInt();
    extraData.ref.height = viewportSize.height.toInt();
    extraData.ref.availWidth = viewportSize.width.toInt();
    extraData.ref.availHeight = viewportSize.height.toInt();
    return extraData.cast<Void>();
  }

  // The availWidth attribute must return the width of the Web-exposed available screen area.
  // The Web-exposed available screen area is one of the following:
  //   - The available area of the rendering surface of the output device, in CSS pixels.
  //   - The area of the output device, in CSS pixels.
  //   - The area of the viewport, in CSS pixels.
  int get availWidth => view.viewport!.boxSize?.width.toInt() ?? 0;

  // The availHeight attribute must return the height of the Web-exposed available screen area.
  int get availHeight => view.viewport!.boxSize?.height.toInt() ?? 0;

  // The width attribute must return the width of the Web-exposed screen area.
  // The Web-exposed screen area is one of the following:
  //   - The area of the output device, in CSS pixels.
  //   - The area of the viewport, in CSS pixels.
  int get width => availWidth;

  // The height attribute must return the height of the Web-exposed screen area.
  int get height => availHeight;
}
