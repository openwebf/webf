/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:core';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ffi' as ffi;

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
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

@immutable
class TextMetrics {
  TextMetrics(
    this.width,
    this.actualBoundingBoxLeft,
    this.actualBoundingBoxRight,
    this.fontBoundingBoxAscent,
    this.fontBoundingBoxDescent,
    this.actualBoundingBoxAscent,
    this.actualBoundingBoxDescent,
    this.emHeightAscent,
    this.emHeightDescent,
    this.hangingBaseline,
    this.alphabeticBaseline,
    this.ideographicBaseline,
  );

  // x-direction
  final double width;
  final double actualBoundingBoxLeft;
  final double actualBoundingBoxRight;

  // y-direction
  final double fontBoundingBoxAscent;
  final double fontBoundingBoxDescent;
  final double actualBoundingBoxAscent;
  final double actualBoundingBoxDescent;
  final double emHeightAscent;
  final double emHeightDescent;
  final double hangingBaseline;
  final double alphabeticBaseline;
  final double ideographicBaseline;
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
      image_element = source;
    } else if (source is CanvasElement) {
      canvas_element = source;
    }
  }

  ImageElement? image_element;

  CanvasElement? canvas_element;
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
class CanvasGradient extends BindingObject {
  CanvasGradient(BindingContext context, this.ownerCanvasElement)
      : _pointer = context.pointer,
        super(context);

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
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    methods['addColorStop'] =
        BindingObjectMethodSync(call: (args) => addColorStop(castToType<num>(args[0]), castToType<String>(args[1])));
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {}
}

// ignore: one_member_abstracts
class CanvasPattern extends BindingObject {
  CanvasPattern(BindingContext context, CanvasImageSource image, String repetition)
      : _pointer = context.pointer,
        _image = image,
        _repetition = repetition,
        super(context);

  final ffi.Pointer<NativeBindingObject> _pointer;

  final String _repetition;

  final CanvasImageSource _image;

  String get repetition => _repetition;

  CanvasImageSource get image => _image;

  @override
  get pointer => _pointer;

  // opaque object
  void setTransform(DOMMatrix domMatrix) {
    print('setTransform: $domMatrix');
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    methods['setTransform'] = BindingObjectMethodSync(call: (args) {
      BindingObject domMatrix = args[0];
      if (domMatrix is DOMMatrix) {
        return setTransform(domMatrix);
      }
    });
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {}
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
