/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:core';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ffi' as ffi;

import 'package:flutter/painting.dart';
import 'package:webf/webf.dart';
import 'package:webf/css.dart';

enum ImageSmoothingQuality { low, medium, high }

enum CanvasLineCap { butt, round, square }

enum CanvasLineJoin { round, bevel, miter }

enum CanvasTextAlign { start, end, left, right, center }

enum CanvasTextBaseline { top, hanging, middle, alphabetic, ideographic, bottom }

enum CanvasDirection { ltr, rtl, inherit }

class ImageData {
  ImageData(
    this.width,
    this.height, {
    required this.data,
  });

  double width;
  double height;
  Uint8List data;
}

abstract class CanvasCompositing {
  double globalAlpha = 1.0; // (default 1.0)
  String globalCompositeOperation = 'source-over'; // (default source-over)
}

abstract class CanvasImageSmoothing {
  // image smoothing
  bool imageSmoothingEnabled = true; // (default true)
  ImageSmoothingQuality imageSmoothingQuality = ImageSmoothingQuality.low; // (default low)
}

class CanvasImageSource {
  CanvasImageSource(source) {
    _fillCanvasImageSource(source);
  }

  void _fillCanvasImageSource(source) {
    if (source is ImageElement) {
      imageElement = source;
    } else if (source is CanvasElement) {
      canvasElement = source;
    }
  }

  ImageElement? imageElement;

  CanvasElement? canvasElement;
}

abstract class CanvasFillStrokeStyles {
  // colors and styles (see also the CanvasPathDrawingStyles and CanvasTextDrawingStyles
  Color strokeStyle = Color(0xFF000000); // (default black)
  Color fillStyle = Color(0xFF000000); // (default black)
  CanvasGradient createLinearGradient(double x0, double y0, double x1, double y1);

  CanvasGradient createRadialGradient(double x0, double y0, double r0, double x1, double y1, double r1);

  CanvasPattern createPattern(CanvasImageSource image, String repetition);
}

abstract class CanvasShadowStyles {
  // shadows
  double shadowOffsetX = 0.0; // (default 0)
  double shadowOffsetY = 0.0; // (default 0)
  double shadowBlur = 0.0; // (default 0)
  Color shadowColor = Color(0x00000000); // (default transparent black)
}

abstract class CanvasFilters {
  // filters
  String filter = 'none'; // (default "none")
}

abstract class CanvasImageData {
  // pixel manipulation
  ImageData createImageData({double sw, double sh, ImageData imagedata});

  ImageData getImageData(double sx, double sy, double sw, double sh);

  void putImageData(ImageData imagedata, double dx, double dy,
      {double dirtyX, double dirtyY, double dirtyWidth, double dirtyHeight});
}

// ignore: one_member_abstracts
class CanvasGradient extends DynamicBindingObject {
  CanvasGradient(BindingContext super.context, this.ownerCanvasElement)
      : _pointer = context.pointer;

  final ffi.Pointer<NativeBindingObject> _pointer;
  final CanvasElement ownerCanvasElement;

  @override
  get pointer => _pointer;

  List<CSSColorStop> colorGradients = [];

  // opaque object
  void addColorStop(num offset, String color) {
    Color? colorStop = CSSColor.parseColor(color, renderStyle: ownerCanvasElement.renderStyle);
    if (colorStop != null) {
      colorGradients.add(CSSColorStop(colorStop, offset as double));
    }
  }

  @override
  void initializeDynamicMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeDynamicMethods(methods);
    methods['addColorStop'] =
        BindingObjectMethodSync(call: (args) => addColorStop(castToType<num>(args[0]), castToType<String>(args[1])));
  }
}

// ignore: one_member_abstracts
class CanvasPattern extends DynamicBindingObject {
  CanvasPattern(BindingContext super.context, CanvasImageSource image, String repetition)
      : _pointer = context.pointer,
        _image = image,
        _repetition = repetition;

  final ffi.Pointer<NativeBindingObject> _pointer;

  final String _repetition;

  final CanvasImageSource _image;

  String get repetition => _repetition;

  CanvasImageSource get image => _image;

  @override
  get pointer => _pointer;

  // opaque object
  void setTransform(DOMMatrix domMatrix) {
    // ignore: avoid_print
    print('[CanvasPattern] setTransform called with matrix: $domMatrix');
  }

  @override
  void initializeDynamicMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeDynamicMethods(methods);
    methods['setTransform'] = BindingObjectMethodSync(call: (args) {
      BindingObject domMatrix = args[0];
      if (domMatrix is DOMMatrix) {
        return setTransform(domMatrix);
      }
    });
  }

}

class CanvasLinearGradient extends CanvasGradient {
  double x0;
  double y0;
  double x1;
  double y1;

  CanvasLinearGradient(super.context, super.ownerCanvasElement, this.x0, this.y0, this.x1, this.y1);
}

class CanvasRadialGradient extends CanvasGradient {
  double x0;
  double y0;
  double r0;
  double x1;
  double y1;
  double r1;

  CanvasRadialGradient(super.context, super.ownerCanvasElement, this.x0, this.y0, this.r0, this.x1, this.y1, this.r1);
}
