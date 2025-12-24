/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
// ignore_for_file: constant_identifier_names

import 'dart:math' as math;
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ffi' as ffi;

import 'package:flutter/painting.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';
import 'package:webf/css.dart';
import 'package:webf/html.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:webf/src/html/canvas/canvas_text_metrics.dart';

import 'canvas_context.dart';
import 'canvas_path_2d.dart';

const String _DEFAULT_FONT = '10px sans-serif';
const String START = 'start';
const String END = 'end';
const String CENTER = 'center';
const String LTR = 'ltr';
const String RTL = 'rtl';
const String INHERIT = 'inherit';
const String HANGING = 'hanging';
const String MIDDLE = 'middle';
const String ALPHABETIC = 'alphabetic';
const String IDEOGRAPHIC = 'ideographic';
const String EVENODD = 'evenodd';
const String BUTT = 'butt';
const String ROUND = 'round';
const String SQUARE = 'square';
const String MITER = 'miter';
const String BEVEL = 'bevel';

class CanvasRenderingContext2DSettings {
  bool alpha = true;
  bool desynchronized = false;
}

enum FillStyleType { string, canvasGradient }

typedef CanvasActionFn = void Function(Canvas, Size);

enum CanvasActionType {
  execute,
  needsPaint
}

class CanvasAction {
  CanvasAction(this.debugName, this.fn, [this.type = CanvasActionType.execute]);
  CanvasActionFn fn;
  CanvasActionType type;
  String debugName;
}

class ImageBitmap extends DynamicBindingObject {
  ImageBitmap(BindingContext super.context)
      : _pointer = context.pointer;

  final ffi.Pointer<NativeBindingObject> _pointer;

  @override
  get pointer => _pointer;

  // Backing image snapshot used for drawing.
  // For now this is populated implicitly via the associated HTMLImageElement.
  // The bridge currently resolves ImageBitmap back to an ImageElement when
  // drawing, so this field is mainly here for type completeness.
  Image? image;
}

class CanvasRenderingContext2D extends DynamicBindingObject with StaticDefinedBindingObject {
  CanvasRenderingContext2D(BindingContext super.context, this.canvas)
      : _pointer = context.pointer;

  final ffi.Pointer<NativeBindingObject> _pointer;

  @override
  get pointer => _pointer;

  @override
  get contextId => canvas.contextId;

  static final StaticDefinedSyncBindingObjectMethodMap _context2dSyncMethods = {
    'arc': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).arc(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          anticlockwise: (args.length > 5 && args[5]) ? true : false);
    }),
    'arcTo': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).arcTo(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble());
    }),
    'fillRect': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).fillRect(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
    }),
    'clearRect': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).clearRect(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
    }),
    'setLineDash': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      final List<num> list = List<num>.from(args[0] as List);
      final List<double> segments = list.map((v) => v.toDouble()).toList();
      castToType<CanvasRenderingContext2D>(context).setLineDash(segments);
    }),
    'getLineDash': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).getLineDash();
    }),
    'strokeRect': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).strokeRect(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
    }),
    'fillText': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      if (args.length > 3) {
        double maxWidth = castToType<num>(args[3]).toDouble();
        if (!maxWidth.isNaN) {
          return castToType<CanvasRenderingContext2D>(context).fillText(
              castToType<String>(args[0]), castToType<num>(args[1]).toDouble(), castToType<num>(args[2]).toDouble(),
              maxWidth: maxWidth);
        }
        return castToType<CanvasRenderingContext2D>(context).fillText(
            castToType<String>(args[0]), castToType<num>(args[1]).toDouble(), castToType<num>(args[2]).toDouble());
      } else {
        return castToType<CanvasRenderingContext2D>(context).fillText(
            castToType<String>(args[0]), castToType<num>(args[1]).toDouble(), castToType<num>(args[2]).toDouble());
      }
    }),
    'ellipse': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).ellipse(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          castToType<num>(args[5]).toDouble(),
          castToType<num>(args[6]).toDouble(),
          anticlockwise: (args.length > 7 && args[7] == 1) ? true : false);
    }),
    'strokeText': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      if (args.length > 3) {
        double maxWidth = castToType<num>(args[3]).toDouble();
        if (!maxWidth.isNaN) {
          return castToType<CanvasRenderingContext2D>(context).strokeText(
              castToType<String>(args[0]), castToType<num>(args[1]).toDouble(), castToType<num>(args[2]).toDouble(),
              maxWidth: maxWidth);
        }
        return castToType<CanvasRenderingContext2D>(context).strokeText(
            castToType<String>(args[0]), castToType<num>(args[1]).toDouble(), castToType<num>(args[2]).toDouble());
      } else {
        return castToType<CanvasRenderingContext2D>(context).strokeText(
            castToType<String>(args[0]), castToType<num>(args[1]).toDouble(), castToType<num>(args[2]).toDouble());
      }
    }),
    'save': StaticDefinedSyncBindingObjectMethod(
        call: (context, _) => castToType<CanvasRenderingContext2D>(context).save()),
    'restore': StaticDefinedSyncBindingObjectMethod(
        call: (context, _) => castToType<CanvasRenderingContext2D>(context).restore()),
    'beginPath': StaticDefinedSyncBindingObjectMethod(
        call: (context, _) => castToType<CanvasRenderingContext2D>(context).beginPath()),
    'bezierCurveTo': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).bezierCurveTo(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          castToType<num>(args[5]).toDouble());
    }),
    'clip': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      if (args.isNotEmpty && args[0] is Path2D) {
        PathFillType fillType = (args.length == 2 && args[1] == EVENODD) ? PathFillType.evenOdd : PathFillType.nonZero;
        return castToType<CanvasRenderingContext2D>(context).clip(fillType, path: args[0]);
      } else {
        PathFillType fillType = (args.length == 1 && args[0] == EVENODD) ? PathFillType.evenOdd : PathFillType.nonZero;
        return castToType<CanvasRenderingContext2D>(context).clip(fillType);
      }
    }),
    'putImageData': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      // Arguments bridged from C++:
      // [0] NativeByteData bytes
      // [1] width (int)
      // [2] height (int)
      // [3] dx
      // [4] dy
      // [5] dirtyX
      // [6] dirtyY
      // [7] dirtyWidth
      // [8] dirtyHeight
      final CanvasRenderingContext2D ctx2d = castToType<CanvasRenderingContext2D>(context);
      final NativeByteData bytes = args[0] as NativeByteData;
      final int width = castToType<num>(args[1]).toInt();
      final int height = castToType<num>(args[2]).toInt();
      final double dx = castToType<num>(args[3]).toDouble();
      final double dy = castToType<num>(args[4]).toDouble();
      final double dirtyX = castToType<num>(args[5]).toDouble();
      final double dirtyY = castToType<num>(args[6]).toDouble();
      final double dirtyWidth = castToType<num>(args[7]).toDouble();
      final double dirtyHeight = castToType<num>(args[8]).toDouble();

      ctx2d.putImageData(bytes, width, height, dx, dy,
          dirtyX: dirtyX, dirtyY: dirtyY, dirtyWidth: dirtyWidth, dirtyHeight: dirtyHeight);
    }),
    'closePath': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).closePath();
    }),
    'drawImage': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      BindingObject imageSource = args[0];
      Image? image;

      if (imageSource is ImageElement) {
        image = imageSource.image;
      } else if (imageSource is ImageBitmap) {
        image = imageSource.image;
      }

      if (image != null) {
        double sx = 0.0, sy = 0.0, sWidth = 0.0, sHeight = 0.0, dx = 0.0, dy = 0.0, dWidth = 0.0, dHeight = 0.0;

        if (args.length == 3) {
          dx = castToType<num>(args[1]).toDouble();
          dy = castToType<num>(args[2]).toDouble();
        } else if (args.length == 5) {
          dx = castToType<num>(args[1]).toDouble();
          dy = castToType<num>(args[2]).toDouble();
          dWidth = castToType<num>(args[3]).toDouble();
          dHeight = castToType<num>(args[4]).toDouble();
        } else if (args.length == 9) {
          sx = castToType<num>(args[1]).toDouble();
          sy = castToType<num>(args[2]).toDouble();
          sWidth = castToType<num>(args[3]).toDouble();
          sHeight = castToType<num>(args[4]).toDouble();
          dx = castToType<num>(args[5]).toDouble();
          dy = castToType<num>(args[6]).toDouble();
          dWidth = castToType<num>(args[7]).toDouble();
          dHeight = castToType<num>(args[8]).toDouble();
        }

        return castToType<CanvasRenderingContext2D>(context)
            .drawImage(args.length, image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight);
      }
    }),
    'fill': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      if (args.isEmpty) {
        return castToType<CanvasRenderingContext2D>(context).fill(PathFillType.nonZero);
      } else if (args.length == 1) {
        if (args[0] is Path2D) {
          return castToType<CanvasRenderingContext2D>(context).fill(PathFillType.nonZero, path: args[0]);
        } else {
          PathFillType fillType = args[0] == EVENODD ? PathFillType.evenOdd : PathFillType.nonZero;
          return castToType<CanvasRenderingContext2D>(context).fill(fillType);
        }
      } else if (args.length == 2) {
        assert(args[0] is Path2D);
        PathFillType fillType = (args[1] == EVENODD) ? PathFillType.evenOdd : PathFillType.nonZero;
        return castToType<CanvasRenderingContext2D>(context).fill(fillType, path: args[0]);
      }
    }),
    'lineTo': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context)
          .lineTo(castToType<num>(args[0]).toDouble(), castToType<num>(args[1]).toDouble());
    }),
    'moveTo': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context)
          .moveTo(castToType<num>(args[0]).toDouble(), castToType<num>(args[1]).toDouble());
    }),
    'measureText': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).measureText(castToType<String>(args[0]));
    }),
    'quadraticCurveTo': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).quadraticCurveTo(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
    }),
    'rect': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).rect(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
    }),
    'rotate': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).rotate(castToType<num>(args[0]).toDouble());
    }),
    'roundRect': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).roundRect(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          List<double>.from(args[4]));
    }),
    'resetTransform': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).resetTransform();
    }),
    'scale': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context)
          .scale(castToType<num>(args[0]).toDouble(), castToType<num>(args[1]).toDouble());
    }),
    'stroke': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      Path2D? path;
      if (args.length == 1 && args[0] is Path2D) {
        path = args[0];
      }
      castToType<CanvasRenderingContext2D>(context).stroke(path: path);
    }),
    'setTransform': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).setTransform(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          castToType<num>(args[5]).toDouble());
    }),
    'transform': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).transform(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          castToType<num>(args[5]).toDouble());
    }),
    'translate': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).translate(castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble());
    }),
    'reset': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).reset();
    }),
    'isPointInPath': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      final CanvasRenderingContext2D ctx2d = castToType<CanvasRenderingContext2D>(context);
      Path2D? path;
      int offset = 0;

      if (args.isNotEmpty && args[0] is Path2D) {
        path = args[0] as Path2D;
        offset = 1;
      }

      if (args.length < offset + 2) {
        return false;
      }

      final double x = castToType<num>(args[offset]).toDouble();
      final double y = castToType<num>(args[offset + 1]).toDouble();

      PathFillType fillType = PathFillType.nonZero;
      if (args.length > offset + 2 && args[offset + 2] is String && args[offset + 2] == EVENODD) {
        fillType = PathFillType.evenOdd;
      }

      // ignore: avoid_print
      print(
          '[Canvas2D] binding isPointInPath pathProvided=${path != null} x=$x y=$y fillType=$fillType rawArgs=$args');

      if (path != null) {
        path.path.fillType = fillType;
        final Rect pathBounds = path.path.getBounds();
        final bool result = path.path.contains(Offset(x, y));
        // ignore: avoid_print
        print('[Canvas2D] binding isPointInPath(path) bounds=$pathBounds result=$result');
        return result;
      }

      final bool result = ctx2d.isPointInPath(x, y, fillType);
      // ignore: avoid_print
      print('[Canvas2D] binding isPointInPath(currentPath) result=$result');
      return result;
    }),
    'isPointInStroke': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      final CanvasRenderingContext2D ctx2d = castToType<CanvasRenderingContext2D>(context);
      Path2D? path;
      int offset = 0;

      if (args.isNotEmpty && args[0] is Path2D) {
        path = args[0] as Path2D;
        offset = 1;
      }

      if (args.length < offset + 2) {
        return false;
      }

      final double x = castToType<num>(args[offset]).toDouble();
      final double y = castToType<num>(args[offset + 1]).toDouble();

      // ignore: avoid_print
      print('[Canvas2D] binding isPointInStroke pathProvided=${path != null} x=$x y=$y rawArgs=$args');

      if (path != null) {
        final Rect pathBounds = path.path.getBounds();
        final bool result = path.path.contains(Offset(x, y));
        // ignore: avoid_print
        print('[Canvas2D] binding isPointInStroke(path) bounds=$pathBounds result=$result');
        return result;
      }

      final bool result = ctx2d.isPointInStroke(x, y);
      // ignore: avoid_print
      print('[Canvas2D] binding isPointInStroke(currentPath) result=$result');
      return result;
    }),
    'createLinearGradient': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).createLinearGradient(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
    }),
    'createRadialGradient': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context).createRadialGradient(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          castToType<num>(args[5]).toDouble());
    }),
    'createPattern': StaticDefinedSyncBindingObjectMethod(call: (context, args) {
      return castToType<CanvasRenderingContext2D>(context)
          .createPattern(CanvasImageSource(args[0]), castToType<String>(args[1]));
    }),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _context2dSyncMethods];

  static final StaticDefinedBindingPropertyMap _context2dProperties = {
    'globalAlpha': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).globalAlpha,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).globalAlpha = castToType<num>(value).toDouble()),
    'globalCompositeOperation': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).globalCompositeOperation,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).globalCompositeOperation = castToType<String>(value)),
    'fillStyle': StaticDefinedBindingProperty(getter: (context) {
      final CanvasRenderingContext2D ctx2d = castToType<CanvasRenderingContext2D>(context);
      final Object style = ctx2d.fillStyle;
      if (style is CanvasGradient || style is CanvasPattern) {
        return style;
      }
      return CSSColor.convertToHex(style as Color);
    }, setter: (context, value) {
      if (value is String) {
        Color? color = CSSColor.parseColor(castToType<String>(value),
            renderStyle: castToType<CanvasRenderingContext2D>(context).canvas.renderStyle);
        if (color != null) castToType<CanvasRenderingContext2D>(context).fillStyle = color;
      } else if (value is CanvasGradient || value is CanvasPattern) {
        castToType<CanvasRenderingContext2D>(context).fillStyle = value;
      }
    }),
    'direction': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context)._textDirectionInString,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).direction = parseDirection(castToType<String>(value))),
    'font': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).font,
        setter: (context, value) => castToType<CanvasRenderingContext2D>(context).font = castToType<String>(value)),
    'strokeStyle': StaticDefinedBindingProperty(getter: (context) {
      final CanvasRenderingContext2D ctx2d = castToType<CanvasRenderingContext2D>(context);
      final Object style = ctx2d.strokeStyle;
      // ignore: avoid_print
      print('[Canvas2D] getter strokeStyle, runtimeType=${style.runtimeType}');
      if (style is CanvasGradient || style is CanvasPattern) {
        return style;
      }
      return CSSColor.convertToHex(style as Color);
    }, setter: (context, value) {
      // ignore: avoid_print
      print('[Canvas2D] setter strokeStyle, runtimeType=${value.runtimeType}');
      if (value is String) {
        Color? color = CSSColor.parseColor(castToType<String>(value),
            renderStyle: castToType<CanvasRenderingContext2D>(context).canvas.renderStyle);
        if (color != null) castToType<CanvasRenderingContext2D>(context).strokeStyle = color;
      } else if (value is CanvasGradient || value is CanvasPattern) {
        castToType<CanvasRenderingContext2D>(context).strokeStyle = value;
      } else {
        // ignore: avoid_print
        print('[Canvas2D] strokeStyle setter received unsupported value: $value');
      }
    }),
    'lineCap': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).lineCap,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).lineCap = parseLineCap(castToType<String>(value))),
    'lineDashOffset': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).lineDashOffset,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).lineDashOffset = castToType<num>(value).toDouble()),
    'lineJoin': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).lineJoin,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).lineJoin = parseLineJoin(castToType<String>(value))),
    'lineWidth': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).lineWidth,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).lineWidth = castToType<num>(value).toDouble()),
    'miterLimit': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).miterLimit,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).miterLimit = castToType<num>(value).toDouble()),
    'textAlign': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).textAlign.toString(),
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).textAlign = parseTextAlign(castToType<String>(value))),
    'textBaseline': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).textBaseline.toString(),
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).textBaseline = parseTextBaseline(castToType<String>(value))),
    'shadowBlur': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context).shadowBlur,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context).shadowBlur = castToType<num>(value).toDouble()),
    'shadowOffsetX': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context)._shadowOffsetX,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context)._shadowOffsetX = castToType<num>(value).toDouble()),
    'shadowOffsetY': StaticDefinedBindingProperty(
        getter: (context) => castToType<CanvasRenderingContext2D>(context)._shadowOffsetY,
        setter: (context, value) =>
            castToType<CanvasRenderingContext2D>(context)._shadowOffsetY = castToType<num>(value).toDouble()),
    'shadowColor': StaticDefinedBindingProperty(getter: (context) {
      return CSSColor.convertToHex(castToType<CanvasRenderingContext2D>(context).shadowColor);
    }, setter: (context, value) {
      if (value is String) {
        Color? color = CSSColor.parseColor(value,
            renderStyle: castToType<CanvasRenderingContext2D>(context).canvas.renderStyle);
        if (color != null) {
          castToType<CanvasRenderingContext2D>(context).shadowColor = color;
        }
      }
    })
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _context2dProperties];

  @override
  Future<void> dispose() async {
    _actions.clear();
    _pendingActions.clear();
    super.dispose();
  }

  final CanvasRenderingContext2DSettings _settings = CanvasRenderingContext2DSettings();

  CanvasRenderingContext2DSettings getContextAttributes() => _settings;

  CanvasElement canvas;

  List<CanvasAction> _actions = [];
  List<CanvasAction> _pendingActions = [];

  // Transform actions (scale/rotate/translate/transform/setTransform/resetTransform)
  // that are applied at the root state (outside any save/restore) before the
  // first paint. These represent the persistent CTM that should be re-applied
  // on every subsequent frame, so that transforms like `ctx.scale(dpr, dpr)`
  // done once before an animation loop keep affecting all later frames, just
  // like in browsers.
  final List<CanvasAction> _persistentRootTransforms = [];

  bool isActionsNotEmpty() {
    return _actions.isNotEmpty;
  }

  void addAction(String name, CanvasActionFn action,
      [CanvasActionType type = CanvasActionType.execute, Map<String, dynamic>? debugDetails]) {
    _actions.add(CanvasAction(name, action, type));
  }

  Map<String, dynamic>? _describeStyleValue(Object? value) {
    if (value == null) return null;
    if (value is Color) {
      return {
        'valueType': 'Color',
        'value': CSSColor.convertToHex(value),
      };
    }
    return {
      'valueType': value.runtimeType.toString(),
      'value': value.toString(),
    };
  }

  // For CanvasRenderingContext2D: createPattern() method; Creating a pattern from a canvas need to replay the actions because the canvas element may be not drawn.
  void replayActions(Canvas canvas, Size size) {
    Path2D paintTemp = path2d;
    path2d = Path2D();
    // ignore: avoid_print
    print('[Canvas2D] replayActions: canvasSize=$size, actionsCount=${_actions.length}');
    for (var action in _actions) {
      action.fn.call(canvas, size);
    }
    path2d = paintTemp;
  }

  List<int> needsPaintIndexes = [];
  void requestPaint() {
    if (_actions.isEmpty || _actions.last.type == CanvasActionType.needsPaint) {
      return;
    }
    addAction('needsPaint', (p0, p1) { }, CanvasActionType.needsPaint);

    int needsPaintIndex = _actions.length - 1;
    needsPaintIndexes.add(needsPaintIndex);
    // Must trigger repaint after add needsPaint
    canvas.notifyRepaint();
  }

  // Perform canvas drawing.
  List<CanvasAction> performActions(Canvas canvas, Size size) {
    if (needsPaintIndexes.isEmpty) {
      return [];
    }

    int needsPaintIndex = needsPaintIndexes[0];
    _pendingActions = _actions.sublist(0, needsPaintIndex);
    _actions = _actions.sublist(needsPaintIndex + 1);

    // Detect root-level transform actions (outside any save/restore) that
    // appear at the very start of the first painted frame and treat them as
    // persistent CTM. Transforms that occur later (after any drawing at the
    // root level) must NOT be treated as persistent, or they'd incorrectly
    // affect earlier draws when replayed.
    if (_persistentRootTransforms.isEmpty && _pendingActions.isNotEmpty) {
      int stackDepth = 0;
      final List<int> rootTransformIndexes = [];
      bool seenNonTransformAtRoot = false;
      for (int i = 0; i < _pendingActions.length && !seenNonTransformAtRoot; i++) {
        final CanvasAction action = _pendingActions[i];
        final String name = action.debugName;
        if (name == 'save') {
          stackDepth++;
        } else if (name == 'restore') {
          if (stackDepth > 0) stackDepth--;
        } else if (stackDepth == 0) {
          if (name == 'scale' ||
              name == 'rotate' ||
              name == 'translate' ||
              name == 'transform' ||
              name == 'setTransform' ||
              name == 'resetTransform') {
            _persistentRootTransforms.add(action);
            rootTransformIndexes.add(i);
          } else {
            // First non-transform action at root level: stop collecting
            // persistent transforms. Any transforms after this must be
            // applied only where they appear.
            seenNonTransformAtRoot = true;
          }
        }
      }
      // Remove those root-level transform actions from the first frame's
      // pending list; they will be applied via _persistentRootTransforms
      // instead. This avoids double-applying the same transform on the
      // initial painted frame.
      if (rootTransformIndexes.isNotEmpty) {
        for (int i = rootTransformIndexes.length - 1; i >= 0; i--) {
          _pendingActions.removeAt(rootTransformIndexes[i]);
        }
      }
    }

    // Apply persistent root transforms (if any) at the start of every frame,
    // before running frame-specific actions. This restores the same CTM that
    // was in effect when the first frame was painted.
    if (_persistentRootTransforms.isNotEmpty) {
      for (int i = 0; i < _persistentRootTransforms.length; i++) {
        CanvasAction persistent = _persistentRootTransforms[i];
        persistent.fn(canvas, size);
      }
    }

    for (int i = 0; i < _pendingActions.length; i++) {
      _pendingActions[i].fn(canvas, size);
    }

    // update needsPaint index
    for (int i = 0; i < needsPaintIndexes.length; i++) {
      needsPaintIndexes[i] = needsPaintIndexes[i] - (needsPaintIndex + 1);
    }
    needsPaintIndexes = needsPaintIndexes.sublist(1);
    return _pendingActions;
  }

  // Clear the saved pending actions.
  void clearActions(List<CanvasAction> actions) {
    actions.clear();
  }

  static TextAlign? parseTextAlign(String value) {
    switch (value) {
      case START:
        return TextAlign.start;
      case END:
        return TextAlign.end;
      case LEFT:
        return TextAlign.left;
      case RIGHT:
        return TextAlign.right;
      case CENTER:
        return TextAlign.center;
    }
    return null;
  }

  TextAlign _textAlign = TextAlign.start; // (default: "start")
  set textAlign(TextAlign? value) {
    if (value == null) return;
    addAction('textAlign', (Canvas canvas, Size size) {
      _textAlign = value;
    });
  }

  TextAlign get textAlign => _textAlign;

  static CanvasTextBaseline? parseTextBaseline(String value) {
    switch (value) {
      case TOP:
        return CanvasTextBaseline.top;
      case HANGING:
        return CanvasTextBaseline.hanging;
      case MIDDLE:
        return CanvasTextBaseline.middle;
      case ALPHABETIC:
        return CanvasTextBaseline.alphabetic;
      case IDEOGRAPHIC:
        return CanvasTextBaseline.ideographic;
      case BOTTOM:
        return CanvasTextBaseline.bottom;
    }
    return null;
  }

  CanvasTextBaseline _textBaseline = CanvasTextBaseline.alphabetic; // (default: "alphabetic")
  set textBaseline(CanvasTextBaseline? value) {
    if (value == null) return;
    addAction('textBaseline', (Canvas canvas, Size size) {
      _textBaseline = value;
    });
  }

  CanvasTextBaseline get textBaseline => _textBaseline;

  static TextDirection? parseDirection(String value) {
    switch (value) {
      case LTR:
        return TextDirection.ltr;
      case RTL:
        return TextDirection.rtl;
      case INHERIT:
        return TextDirection.ltr;
    }
    return null;
  }

  // FIXME: The text direction is inherited from the <canvas> element or the Document as appropriate.
  TextDirection _direction = TextDirection.ltr; // (default: "inherit")
  set direction(TextDirection? value) {
    if (value == null) return;
    addAction('direction', (Canvas canvas, Size size) {
      _direction = value;
    });
  }

  TextDirection get direction => _direction;

  String get _textDirectionInString {
    switch (_direction) {
      case TextDirection.ltr:
        return 'ltr';
      case TextDirection.rtl:
        return 'rtl';
    }
  }

  Map<String, String?> _fontProperties = {};
  double? _fontSize;

  double _shadowOffsetX = 0.0;
  double _shadowOffsetY = 0.0;

  double _globalAlpha = 1.0;
  double get globalAlpha => _globalAlpha;
  set globalAlpha(double? value) {
    if (value == null) return;
    final double alpha = value.clamp(0.0, 1.0);
    addAction('globalAlpha', (Canvas canvas, Size size) {
      _globalAlpha = alpha;
    }, CanvasActionType.execute, {
      'value': alpha,
    });
  }

  String _globalCompositeOperation = 'source-over';
  BlendMode _globalBlendMode = BlendMode.srcOver;

  String get globalCompositeOperation => _globalCompositeOperation;

  static BlendMode? _parseCompositeOperation(String value) {
    switch (value) {
      case 'source-over':
        return BlendMode.srcOver;
      case 'source-atop':
        return BlendMode.srcATop;
      case 'source-in':
        return BlendMode.srcIn;
      case 'source-out':
        return BlendMode.srcOut;
      case 'destination-over':
        return BlendMode.dstOver;
      case 'destination-atop':
        return BlendMode.dstATop;
      case 'destination-in':
        return BlendMode.dstIn;
      case 'destination-out':
        return BlendMode.dstOut;
      case 'lighter':
        return BlendMode.plus;
      case 'copy':
        return BlendMode.src;
      case 'xor':
        return BlendMode.xor;
      case 'multiply':
        return BlendMode.multiply;
      case 'screen':
        return BlendMode.screen;
      case 'overlay':
        return BlendMode.overlay;
      case 'darken':
        return BlendMode.darken;
      case 'lighten':
        return BlendMode.lighten;
      case 'color-dodge':
        return BlendMode.colorDodge;
      case 'color-burn':
        return BlendMode.colorBurn;
      case 'hard-light':
        return BlendMode.hardLight;
      case 'soft-light':
        return BlendMode.softLight;
      case 'difference':
        return BlendMode.difference;
      case 'exclusion':
        return BlendMode.exclusion;
      case 'hue':
        return BlendMode.hue;
      case 'saturation':
        return BlendMode.saturation;
      case 'color':
        return BlendMode.color;
      case 'luminosity':
        return BlendMode.luminosity;
    }
    return null;
  }

  set globalCompositeOperation(String value) {
    final BlendMode? mode = _parseCompositeOperation(value);
    if (mode == null) {
      // Ignore invalid composite operations per spec.
      return;
    }
    addAction('globalCompositeOperation', (Canvas canvas, Size size) {
      _globalCompositeOperation = value;
      _globalBlendMode = mode;
    }, CanvasActionType.execute, {
      'value': value,
    });
  }

  bool _parseFont(String newValue) {
    Map<String, String?> properties = {};
    CSSStyleProperty.setShorthandFont(properties, newValue);
    if (properties.isEmpty) return false;
    _fontProperties = properties;

    // In canvas font property, the em and rem units do not update when font-size changed,
    // so computed the relative length immediately.
    String? fontSize = properties[FONT_SIZE];
    if (fontSize != null) {
      if (CSSPercentage.isPercentage(fontSize)) {
        double? percentage = CSSPercentage.parsePercentage(fontSize);
        if (percentage != null) {
          _fontSize = percentage * canvas.renderStyle.fontSize.computedValue;
        }
      } else {
        _fontSize = CSSLength.parseLength(properties[FONT_SIZE]!, canvas.renderStyle).computedValue;
      }
    }
    return true;
  }

  String _font = _DEFAULT_FONT; // (default 10px sans-serif)
  set font(String value) {
    _font = value;
    addAction('font', (Canvas canvas, Size size) {
      // Must lazy parse in action because it has side-effect with _fontProperties.
      if (_parseFont(value)) {
        _font = value;
      }
    });
  }

  String get font => _font;

  final List _states = [];

  // push state on state stack
  void restore() {
    addAction('restore', (Canvas canvas, Size size) {
      var state = _states.last;
      _states.removeLast();
      _strokeStyle = state[0];
      _fillStyle = state[1];
      _lineWidth = state[2];
      _lineCap = state[3];
      _lineJoin = state[4];
      _lineDashOffset = state[5];
      _miterLimit = state[6];
      _font = state[7];
      _textAlign = state[8];
      _direction = state[9];
      _shadowBlur = state[10];
      _shadowColor = state[11];
      _shadowOffsetX = state[12] as double;
      _shadowOffsetY = state[13] as double;
      _globalAlpha = state[14] as double;
      _globalCompositeOperation = state[15] as String;
      _globalBlendMode = _parseCompositeOperation(_globalCompositeOperation) ?? BlendMode.srcOver;

      canvas.restore();
    }, CanvasActionType.execute, {
      'stackDepthBefore': _states.length,
    });
  }

  // pop state stack and restore state
  void save() {
    addAction('save', (Canvas canvas, Size size) {
      _states.add([
        strokeStyle,
        fillStyle,
        lineWidth,
        lineCap,
        lineJoin,
        lineDashOffset,
        miterLimit,
        font,
        textAlign,
        direction,
        shadowBlur,
        shadowColor,
        _shadowOffsetX,
        _shadowOffsetY,
        _globalAlpha,
        _globalCompositeOperation,
      ]);
      canvas.save();
    }, CanvasActionType.execute, {
      'stackDepthBefore': _states.length,
    });
  }

  Path2D path2d = Path2D();

  void beginPath() {
    final Rect previousBounds = path2d.path.getBounds();
    addAction('beginPath', (Canvas canvas, Size size) {
      path2d = Path2D();
    }, CanvasActionType.execute, {
      'previousPathBounds': previousBounds.toString(),
    });
  }

  void clip(PathFillType fillType, {Path2D? path}) {
    addAction('clip', (Canvas canvas, Size size) {
      path?.path.fillType = fillType;
      path2d.path.fillType = fillType;
      canvas.clipPath(path?.path ?? path2d.path);
    });
  }

  void fill(PathFillType fillType, {Path2D? path}) {
    addAction('fill', (Canvas canvas, Size size) {
      if (fillStyle is! Color) {
        return;
      }
      _drawWithGlobalCompositing(canvas, size, (Canvas drawCanvas) {
        Paint paint = Paint()
          ..color = fillStyle as Color
          ..style = PaintingStyle.fill;
        if (path != null) {
          path.path.fillType = fillType;
          _paintShadowForPath(drawCanvas, path.path, paintingStyle: PaintingStyle.fill);
          drawCanvas.drawPath(path.path, paint);
        } else {
          path2d.path.fillType = fillType;
          _paintShadowForPath(drawCanvas, path2d.path, paintingStyle: PaintingStyle.fill);
          drawCanvas.drawPath(path2d.path, paint);
        }
      });
    }, CanvasActionType.execute, {
      'fillType': fillType.toString(),
      'pathProvided': path != null,
      'style': _describeStyleValue(fillStyle),
    });
  }

  void stroke({Path2D? path}) {
    addAction('stroke', (Canvas canvas, Size size) {
      // ignore: avoid_print
      print(
          '[Canvas2D] stroke() paint, strokeStyle.runtimeType=${strokeStyle.runtimeType}, lineWidth=$lineWidth, lineCap=$lineCap, lineJoin=$lineJoin');
      _drawWithGlobalCompositing(canvas, size, (Canvas drawCanvas) {
        final Path basePath = path?.path ?? path2d.path;
        final Path effectivePath = _applyLineDashIfNeeded(basePath);
        if (strokeStyle is CanvasPattern) {
          final CanvasPattern canvasPattern = strokeStyle as CanvasPattern;
          final Rect pathBounds = effectivePath.getBounds();
          // ignore: avoid_print
          print('[Canvas2D] stroke() pattern branch, pathBounds=$pathBounds');
          // Approximate the stroke region as a rectangular ring based on the
          // path bounds and lineWidth, then clip the pattern to that ring. This
          // confines the pattern to the lines instead of filling the interior.
          final double halfWidth = lineWidth / 2.0;
          final Rect outerRect = pathBounds.inflate(halfWidth);
          final Rect innerRect = pathBounds.deflate(halfWidth);
          final Path ring = Path()
            ..fillType = PathFillType.evenOdd
            ..addRect(outerRect)
            ..addRect(innerRect);
          drawCanvas.save();
          drawCanvas.clipPath(ring);
          _paintShadowForPath(drawCanvas, effectivePath, paintingStyle: PaintingStyle.stroke);
          _drawPattern(drawCanvas, size, outerRect.left, outerRect.top, outerRect.width, outerRect.height,
              canvasPattern);
          drawCanvas.restore();
        } else {
          Paint paint = Paint();
          if (strokeStyle is Color) {
            paint.color = strokeStyle as Color;
          } else if (strokeStyle is CanvasRadialGradient) {
            final Rect bounds = effectivePath.getBounds();
            paint
              .shader =
                  _drawRadialGradient(strokeStyle as CanvasRadialGradient, bounds.left, bounds.top, bounds.width,
                          bounds.height)
                      .createShader(bounds);
          } else if (strokeStyle is CanvasLinearGradient) {
            final Rect bounds = effectivePath.getBounds();
            paint
              .shader =
                  _drawLinearGradient(strokeStyle as CanvasLinearGradient, bounds.left, bounds.top, bounds.width,
                          bounds.height)
                      .createShader(bounds);
          } else {
            // Unsupported stroke style type.
            return;
          }
          paint
            ..strokeJoin = lineJoin
            ..strokeCap = lineCap
            ..strokeWidth = lineWidth
            ..strokeMiterLimit = miterLimit
            ..style = PaintingStyle.stroke;
          _paintShadowForPath(drawCanvas, effectivePath, paintingStyle: PaintingStyle.stroke);
          drawCanvas.drawPath(effectivePath, paint);
        }
      });
    }, CanvasActionType.execute, {
      'pathProvided': path != null,
      'style': _describeStyleValue(strokeStyle),
      'lineWidth': lineWidth,
    });
  }

  bool isPointInPath(double x, double y, PathFillType fillRule) {
    final Rect bounds = path2d.path.getBounds();
    // ignore: avoid_print
    print('[Canvas2D] isPointInPath(currentPath) x=$x y=$y fillRule=$fillRule bounds=$bounds');
    final bool result = path2d.path.contains(Offset(x, y));
    // ignore: avoid_print
    print('[Canvas2D] isPointInPath(currentPath) result=$result');
    return result;
  }

  bool isPointInStroke(double x, double y) {
    final Rect bounds = path2d.path.getBounds();
    // ignore: avoid_print
    print('[Canvas2D] isPointInStroke(currentPath) x=$x y=$y bounds=$bounds');
    final bool result = path2d.path.contains(Offset(x, y));
    // ignore: avoid_print
    print('[Canvas2D] isPointInStroke(currentPath) result=$result');
    return result;
  }

  void arc(
      double x, double y, double radius, double startAngle, double endAngle,
      {bool anticlockwise = false}) {
    addAction('arc', (Canvas canvas, Size size) {
      path2d.arc(x, y, radius, startAngle, endAngle,
          anticlockwise: anticlockwise);
    }, CanvasActionType.execute, {
      'x': x,
      'y': y,
      'radius': radius,
      'startAngle': startAngle,
      'endAngle': endAngle,
      'anticlockwise': anticlockwise,
    });
  }

  void arcTo(double x1, double y1, double x2, double y2, double radius) {
    addAction('arcTo', (Canvas canvas, Size size) {
      path2d.arcTo(x1, y1, x2, y2, radius);
    });
  }

  void bezierCurveTo(
      double cp1x, double cp1y, double cp2x, double cp2y, double x, double y) {
    addAction('bezierCurveTo', (Canvas canvas, Size size) {
      path2d.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
    });
  }

  void closePath() {
    addAction('closePath', (Canvas canvas, Size size) {
      path2d.closePath();
    });
  }

  void drawImage(
      int argumentCount,
      Image? img,
      double sx,
      double sy,
      double sWidth,
      double sHeight,
      double dx,
      double dy,
      double dWidth,
      double dHeight) {

    addAction('drawImage', (Canvas canvas, Size size) {
      if (img == null) return;

      // ctx.drawImage(image, dx, dy);
      _drawWithGlobalCompositing(canvas, size, (Canvas drawCanvas) {
        if (argumentCount == 3) {
          drawCanvas.drawImage(img, Offset(dx, dy), Paint());
        } else {
          if (argumentCount == 5) {
            // ctx.drawImage(image, dx, dy, dWidth, dHeight);
            sx = 0;
            sy = 0;
            sWidth = img.width.toDouble();
            sHeight = img.height.toDouble();
          }

          drawCanvas.drawImageRect(
              img, Rect.fromLTWH(sx, sy, sWidth, sHeight), Rect.fromLTWH(dx, dy, dWidth, dHeight), Paint());
        }
      });
    });
  }

  void putImageData(
    NativeByteData nativeBytes,
    int width,
    int height,
    double dx,
    double dy, {
    double? dirtyX,
    double? dirtyY,
    double? dirtyWidth,
    double? dirtyHeight,
  }) {
    if (width <= 0 || height <= 0) return;

    final Uint8List buffer = nativeBytes.bytes;
    if (buffer.isEmpty) return;

    final int expectedLength = width * height * 4;
    if (buffer.length < expectedLength) return;

    final double sx = dirtyX ?? 0.0;
    final double sy = dirtyY ?? 0.0;
    final double sw = dirtyWidth ?? width.toDouble();
    final double sh = dirtyHeight ?? height.toDouble();

    addAction('putImageData', (Canvas canvas, Size size) {
      final int startX = sx.floor();
      final int startY = sy.floor();
      final int endX = (sx + sw).ceil();
      final int endY = (sy + sh).ceil();

      // Keep a strong reference to the NativeByteData so that the
      // underlying memory stays alive for as long as this action exists.
      // ignore: unused_local_variable
      final NativeByteData keepAlive = nativeBytes;
      final int stride = width * 4;
      final Paint paint = Paint();

      _drawWithGlobalCompositing(canvas, size, (Canvas drawCanvas) {
        for (int y = startY; y < endY; y++) {
          if (y < 0 || y >= height) continue;
          for (int x = startX; x < endX; x++) {
            if (x < 0 || x >= width) continue;
            final int index = y * stride + x * 4;
            final int r = buffer[index];
            final int g = buffer[index + 1];
            final int b = buffer[index + 2];
            final int a = buffer[index + 3];

            if (a == 0) {
              // Fully transparent pixel, skip.
              continue;
            }

            paint
              ..color = Color.fromARGB(a, r, g, b)
              ..blendMode = _globalBlendMode;

            drawCanvas.drawRect(
              Rect.fromLTWH(dx + x.toDouble(), dy + y.toDouble(), 1.0, 1.0),
              paint,
            );
          }
        }
      });
    });
  }

  void ellipse(double x, double y, double radiusX, double radiusY,
      double rotation, double startAngle, double endAngle,
      {bool anticlockwise = false}) {
    addAction('ellipse', (Canvas canvas, Size size) {
      path2d.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle,
          anticlockwise: anticlockwise);
    });
  }

  void lineTo(double x, double y) {
    addAction('lineTo', (Canvas canvas, Size size) {
      path2d.lineTo(x, y);
    });
  }

  void moveTo(double x, double y) {
    addAction('moveTo', (Canvas canvas, Size size) {
      path2d.moveTo(x, y);
    });
  }

  void quadraticCurveTo(double cpx, double cpy, double x, double y) {
    addAction('quadraticCurveTo', (Canvas canvas, Size size) {
      path2d.quadraticCurveTo(cpx, cpy, x, y);
    });
  }

  void rect(double x, double y, double w, double h) {
    // Update the current path immediately so APIs like
    // isPointInPath() that operate on the "current path"
    // can see the geometry without waiting for a paint.
    path2d.rect(x, y, w, h);
    // ignore: avoid_print
    print('[Canvas2D] rect() updated current path: bounds=${path2d.path.getBounds()}');

    addAction('rect', (Canvas canvas, Size size) {
      path2d.rect(x, y, w, h);
    });
  }

  // butt, round, square
  static StrokeCap? parseLineCap(String value) {
    switch (value) {
      case BUTT:
        return StrokeCap.butt;
      case ROUND:
        return StrokeCap.round;
      case SQUARE:
        return StrokeCap.square;
    }
    return null;
  }

  StrokeCap _lineCap = StrokeCap.butt; // (default "butt")
  set lineCap(StrokeCap? value) {
    if (value == null) return;
    addAction('lineCap', (Canvas canvas, Size size) {
      _lineCap = value;
    });
  }

  StrokeCap get lineCap => _lineCap;

  double _lineDashOffset = 0.0;

  set lineDashOffset(double? value) {
    if (value == null) return;
    addAction('lineDashOffset', (Canvas canvas, Size size) {
      _lineDashOffset = value;
    });
  }

  double get lineDashOffset => _lineDashOffset;

  static StrokeJoin? parseLineJoin(String value) {
    // round, bevel, miter
    switch (value) {
      case ROUND:
        return StrokeJoin.round;
      case BEVEL:
        return StrokeJoin.bevel;
      case MITER:
        return StrokeJoin.miter;
    }
    return null;
  }

  // The lineJoin can effect the stroke(), strokeRect(), and strokeText() methods.
  StrokeJoin _lineJoin = StrokeJoin.miter;

  set lineJoin(StrokeJoin? value) {
    if (value == null) return;
    addAction('lineJoin', (Canvas canvas, Size size) {
      _lineJoin = value;
    });
  }

  StrokeJoin get lineJoin => _lineJoin;

  double _lineWidth = 1.0; // (default 1)
  set lineWidth(double? value) {
    if (value == null) return;
    addAction('lineWidth', (Canvas canvas, Size size) {
      _lineWidth = value;
    });
  }

  double get lineWidth => _lineWidth;

  double _shadowBlur = 0.0;
  set shadowBlur(double? value) {
    if (value == null) return;
    addAction('shadowBlur', (Canvas canvas, Size size) {
      _shadowBlur = math.max(0.0, value);
    }, CanvasActionType.execute, {
      'value': value,
    });
  }

  double get shadowBlur => _shadowBlur;

  Color _shadowColor = const Color(0x00000000);
  set shadowColor(Color? value) {
    if (value == null) return;
    addAction('shadowColor', (Canvas canvas, Size size) {
      _shadowColor = value;
    }, CanvasActionType.execute, {
      'value': CSSColor.convertToHex(value),
    });
  }

  Color get shadowColor => _shadowColor;

  double _miterLimit = 10.0; // (default 10)
  set miterLimit(double? value) {
    if (value == null) return;
    addAction('miterLimit', (Canvas canvas, Size size) {
      _miterLimit = value;
    });
  }

  double get miterLimit => _miterLimit;

  List<double> _lineDash = const <double>[];

  List<double> getLineDash() {
    return List<double>.from(_lineDash);
  }

  void setLineDash(List<double> segments) {
    _lineDash = segments;
  }

  bool get _shouldPaintShadow =>
      _shadowColor.a != 0 && (_shadowBlur > 0 || _shadowOffsetX != 0.0 || _shadowOffsetY != 0.0);

  double _shadowSigmaFromRadius(double radius) {
    if (radius <= 0) return 0.0;
    return radius;
  }

  void _paintShadowForPath(Canvas canvas, Path path, {required PaintingStyle paintingStyle}) {
    if (!_shouldPaintShadow) return;
    final Path shadowPath = paintingStyle == PaintingStyle.stroke ? _applyLineDashIfNeeded(path) : path;
    final Paint shadowPaint = Paint()
      ..style = paintingStyle
      ..color = _shadowColor;
    if (_shadowBlur > 0) {
      final double sigma = _shadowSigmaFromRadius(_shadowBlur);
      shadowPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
    }
    if (paintingStyle == PaintingStyle.stroke) {
      shadowPaint
        ..strokeJoin = lineJoin
        ..strokeCap = lineCap
        ..strokeWidth = lineWidth
        ..strokeMiterLimit = miterLimit;
    }
    canvas.save();
    if (_shadowOffsetX != 0.0 || _shadowOffsetY != 0.0) {
      canvas.translate(_shadowOffsetX, _shadowOffsetY);
    }
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();
  }

  void _paintShadowForRect(Canvas canvas, Rect rect, {required PaintingStyle style}) {
    if (!_shouldPaintShadow) return;
    final Path rectPath = Path()..addRect(rect);
    _paintShadowForPath(canvas, rectPath, paintingStyle: style);
  }

  Path _applyLineDashIfNeeded(Path source) {
    if (_lineDash.isEmpty) {
      return source;
    }
    final List<double> segments = _lineDash.where((v) => v.isFinite && v > 0).toList();
    if (segments.isEmpty) {
      return source;
    }
    final Path dest = Path();
    final double patternLength = segments.fold(0.0, (double sum, double v) => sum + v);
    if (patternLength == 0.0) {
      return source;
    }

    double offset = _lineDashOffset;
    if (!offset.isFinite) {
      offset = 0.0;
    }
    offset = offset % patternLength;
    if (offset < 0) {
      offset += patternLength;
    }

    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;

      int index = 0;
      bool draw = true;
      double segmentRemaining = segments[0];

      double localOffset = offset;
      while (localOffset > 0.0) {
        if (localOffset > segmentRemaining) {
          localOffset -= segmentRemaining;
          index = (index + 1) % segments.length;
          segmentRemaining = segments[index];
          draw = !draw;
        } else {
          segmentRemaining -= localOffset;
          localOffset = 0.0;
        }
      }

      while (distance < metric.length) {
        final double len = math.min(segmentRemaining, metric.length - distance);
        if (draw && len > 0.0) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        segmentRemaining -= len;
        if (segmentRemaining <= 0.0) {
          index = (index + 1) % segments.length;
          segmentRemaining = segments[index];
          draw = !draw;
        }
      }
    }

    return dest;
  }

  void _drawWithGlobalCompositing(Canvas canvas, Size size, void Function(Canvas drawCanvas) draw, {Rect? bounds}) {
    if (_globalAlpha == 1.0 && _globalBlendMode == BlendMode.srcOver) {
      draw(canvas);
      return;
    }
    final Paint layerPaint = Paint()
      ..blendMode = _globalBlendMode
      ..color = const Color(0xFFFFFFFF).withValues(alpha: _globalAlpha);
    canvas.saveLayer(bounds, layerPaint);
    draw(canvas);
    canvas.restore();
  }

  void translate(double x, double y) {
    addAction('translate', (Canvas canvas, Size size) {
      canvas.translate(x, y);
    }, CanvasActionType.execute, {
      'x': x,
      'y': y,
    });
  }

  void rotate(double angle) {
    addAction('rotate', (Canvas canvas, Size size) {
      canvas.rotate(angle);
    }, CanvasActionType.execute, {
      'angle': angle,
    });
  }

  void roundRect(double x, double y, double w, double h, List<double> radii) {
    addAction('roundRect', (Canvas canvas, Size size) {
      path2d.roundRect(x, y, w, h, radii);
    });
  }

  // transformations (default transform is the identity matrix)
  void scale(double x, double y) {
    addAction('scale', (Canvas canvas, Size size) {
      canvas.scale(x, y);
    }, CanvasActionType.execute, {
      'x': x,
      'y': y,
    });
  }

  // https://github.com/WebKit/WebKit/blob/a77a158d4e2086fbe712e488ed147e8a54d44d3c/Source/WebCore/html/canvas/CanvasRenderingContext2DBase.cpp#L843
  void setTransform(double a, double b, double c, double d, double e, double f) {
    resetTransform();
    transform(a, b, c, d, e, f);
  }

  // Resets the current transform to the identity matrix.
  void resetTransform() {
    CanvasElement canvasElement = canvas;
    addAction('resetTransform', (Canvas canvas, Size size) {
      Float64List curM4Storage = canvas.getTransform();
      Matrix4 curM4 = Matrix4.fromFloat64List(curM4Storage);
      Matrix4 m4 = Matrix4.inverted(curM4);
      canvas.transform(m4.storage);
      canvas.scale(canvasElement.painter.scaleX, canvasElement.painter.scaleY);
    }, CanvasActionType.execute, {
      'scaleX': canvasElement.painter.scaleX,
      'scaleY': canvasElement.painter.scaleY,
    });
  }

  void transform(double a, double b, double c, double d, double e, double f) {
    // Matrix3
    // [ a c e
    //   b d f
    //   0 0 1 ]
    //
    // Matrix4
    // [ a, b, 0, 0,
    //   c, d, 0, 0,
    //   0, 0, 1, 0,
    //   e, f, 0, 1 ]
    final Float64List m4storage = Float64List(16);
    m4storage[0] = a;
    m4storage[1] = b;
    m4storage[2] = 0.0;
    m4storage[3] = 0.0;
    m4storage[4] = c;
    m4storage[5] = d;
    m4storage[6] = 0.0;
    m4storage[7] = 0.0;
    m4storage[8] = 0.0;
    m4storage[9] = 0.0;
    m4storage[10] = 1.0;
    m4storage[11] = 0.0;
    m4storage[12] = e;
    m4storage[13] = f;
    m4storage[14] = 0.0;
    m4storage[15] = 1.0;

    addAction('transform', (Canvas canvas, Size size) {
      canvas.transform(m4storage);
    }, CanvasActionType.execute, {
      'matrix': [a, b, c, d, e, f],
    });
  }

  Object _strokeStyle = CSSColor.initial; // default black
  Object get strokeStyle => _strokeStyle;

  set strokeStyle(Object? newValue) {
    if (newValue == null) return;
    // ignore: avoid_print
    print('[Canvas2D] CanvasRenderingContext2D.strokeStyle setter newValue.runtimeType=${newValue.runtimeType}');
    addAction('strokeStyle', (Canvas canvas, Size size) {
      _strokeStyle = newValue;
    }, CanvasActionType.execute, _describeStyleValue(newValue));
  }

  Object _fillStyle = CSSColor.initial; // default black
  Object get fillStyle => _fillStyle;

  set fillStyle(Object? newValue) {
    if (newValue == null) return;
    addAction('fillStyle', (Canvas canvas, Size size) {
      _fillStyle = newValue;
    }, CanvasActionType.execute, _describeStyleValue(newValue));
  }

  CanvasGradient createLinearGradient(double x0, double y0, double x1, double y1) {
    return CanvasLinearGradient(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), canvas, x0, y0, x1, y1);
  }

  CanvasPattern createPattern(CanvasImageSource image, String repetition) {
    // ignore: avoid_print
    print(
        "[Canvas2D] createPattern: imageType=${image.imageElement != null ? 'HTMLImageElement' : (image.canvasElement != null ? 'HTMLCanvasElement' : 'Unknown')}, repetition=$repetition");
    return CanvasPattern(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), image, repetition);
  }

  CanvasGradient createRadialGradient(double x0, double y0, double r0, double x1, double y1, double r1) {
    return CanvasRadialGradient(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), canvas, x0, y0, r0, x1, y1, r1);
  }

  void clearRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);

    // If this clear covers the canvas content box, drop previously cached
    // pictures so old frames don't keep compositing underneath new ones.
    // This matches the common animation pattern of clearing the whole canvas
    // each frame and redrawing everything.
    CanvasElement canvasElement = canvas;
    Size canvasSize = canvasElement.size;
    if (x <= 0 &&
        y <= 0 &&
        w >= canvasSize.width &&
        h >= canvasSize.height) {
      canvasElement.painter.paintedPictures.clear();
    }

    addAction('clearRect', (Canvas canvas, Size size) {
      // Must saveLayer before clear avoid there is a "black" background
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.clear;
      canvas.drawRect(rect, paint);
    }, CanvasActionType.execute, {
      'x': x,
      'y': y,
      'width': w,
      'height': h,
    });
  }

  void _drawPattern(
      Canvas drawCanvas, Size size, double x, double y, double width, double height, CanvasPattern canvasPattern) {
    // ignore: avoid_print
    print(
        '[Canvas2D] _drawPattern: repetition=${canvasPattern.repetition}, x=$x, y=$y, width=$width, height=$height');
    if (canvasPattern.image.imageElement == null && canvasPattern.image.canvasElement == null) {
      throw AssertionError('CanvasPattern must be created from a canvas or image');
    }

    String repetition = canvasPattern.repetition;
    int patternWidth = canvasPattern.image.imageElement != null
        ? canvasPattern.image.imageElement!.width
        : canvasPattern.image.canvasElement!.width;
    int patternHeight = canvasPattern.image.imageElement != null
        ? canvasPattern.image.imageElement!.height
        : canvasPattern.image.canvasElement!.height;
    // Compute repeat counts based on the full canvas size so that the pattern
    // phase is always anchored at the canvas origin (0, 0), matching browser
    // behavior. The requested (x, y, width, height) region is then applied
    // via clipping so only that area is visible.
    int xRepeatCount = math.max(1, (size.width / patternWidth).ceil());
    int yRepeatCount = math.max(1, (size.height / patternHeight).ceil());
    // ignore: avoid_print
    print(
        '[Canvas2D] _drawPattern metrics: patternWidth=$patternWidth, patternHeight=$patternHeight, '
        'xRepeatCount=$xRepeatCount, yRepeatCount=$yRepeatCount');

    final Rect clipRegion = Rect.fromLTWH(x, y, width, height);
    drawCanvas.save();
    drawCanvas.clipRect(clipRegion);

    // CanvasPattern created from an image
    if (canvasPattern.image.imageElement != null) {
      Image? repeatImg = canvasPattern.image.imageElement?.image;

      if (repetition == 'no-repeat') {
        xRepeatCount = 1;
        yRepeatCount = 1;
      } else if (repetition == 'repeat-x') {
        yRepeatCount = 1;
      } else if (repetition == 'repeat-y') {
        xRepeatCount = 1;
      }

      if (repeatImg != null) {
        final Paint paint = Paint();
        for (int i = 0; i < xRepeatCount; i++) {
          for (int j = 0; j < yRepeatCount; j++) {
            // ignore: avoid_print
            print(
                '[Canvas2D] _drawPattern image tile at (${i * patternWidth}, ${j * patternHeight}) [i=$i, j=$j]');
            drawCanvas.drawImage(repeatImg, Offset(i * patternWidth.toDouble(), j * patternHeight.toDouble()), paint);
          }
        }
      }
    } else {
      // CanvasPattern created from a canvas
      final CanvasElement? patternCanvasElement = canvasPattern.image.canvasElement;
      if (patternCanvasElement == null) {
        throw AssertionError('CanvasPattern must be created from a canvas');
      }
      final Size patternSize = patternCanvasElement.size;
      // ignore: avoid_print
      print('[Canvas2D] _drawPattern canvas sourceSize=$patternSize, destSize=$size');

      switch (repetition) {
        case 'no-repeat':
          // ignore: avoid_print
          print('[Canvas2D] _drawPattern canvas no-repeat');
          patternCanvasElement.context2d!.replayActions(drawCanvas, patternSize);
          break;
        case 'repeat-x':
          for (int i = 0; i < xRepeatCount; i++) {
            // ignore: avoid_print
            print('[Canvas2D] _drawPattern canvas repeat-x column=$i');
            drawCanvas.save();
            drawCanvas.translate(i * patternWidth.toDouble(), 0);
            patternCanvasElement.context2d!.replayActions(drawCanvas, patternSize);
            drawCanvas.restore();
          }
          break;
        case 'repeat-y':
          for (int j = 0; j < yRepeatCount; j++) {
            // ignore: avoid_print
            print('[Canvas2D] _drawPattern canvas repeat-y row=$j');
            drawCanvas.save();
            drawCanvas.translate(0, j * patternHeight.toDouble());
            patternCanvasElement.context2d!.replayActions(drawCanvas, patternSize);
            drawCanvas.restore();
          }
          break;
        case 'repeat':
          for (int i = 0; i < xRepeatCount; i++) {
            for (int j = 0; j < yRepeatCount; j++) {
              // ignore: avoid_print
              print('[Canvas2D] _drawPattern canvas repeat tile column=$i row=$j');
              drawCanvas.save();
              drawCanvas.translate(i * patternWidth.toDouble(), j * patternHeight.toDouble());
              patternCanvasElement.context2d!.replayActions(drawCanvas, patternSize);
              drawCanvas.restore();
            }
          }
          break;
      }
    }
    drawCanvas.restore();
  }

  void fillRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    addAction('fillRect', (Canvas canvas, Size size) {
      _drawWithGlobalCompositing(canvas, size, (Canvas drawCanvas) {
        // ignore: avoid_print
        print(
            '[Canvas2D] fillRect: rect=$rect, fillStyle.runtimeType=${fillStyle.runtimeType}, globalAlpha=$_globalAlpha, globalCompositeOperation=$_globalCompositeOperation');
        Paint paint = Paint();
        _paintShadowForRect(drawCanvas, rect, style: PaintingStyle.fill);
        if (fillStyle is Color || fillStyle is CanvasRadialGradient || fillStyle is CanvasLinearGradient) {
          if (fillStyle is Color) {
            paint.color = fillStyle as Color;
          } else if (fillStyle is CanvasRadialGradient) {
            paint.shader = _drawRadialGradient(fillStyle as CanvasRadialGradient, x, y, w, h).createShader(rect);
          } else if (fillStyle is CanvasLinearGradient) {
            paint.shader = _drawLinearGradient(fillStyle as CanvasLinearGradient, x, y, w, h).createShader(rect);
          }
          drawCanvas.drawRect(rect, paint);
        } else if (fillStyle is CanvasPattern) {
          var canvasPattern = fillStyle as CanvasPattern;
          _drawPattern(drawCanvas, size, x, y, w, h, canvasPattern);
        }
      });
    }, CanvasActionType.execute, {
      'x': x,
      'y': y,
      'width': w,
      'height': h,
      'fillStyle': _describeStyleValue(_fillStyle),
    });
  }

  void strokeRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    addAction('strokeRect', (Canvas canvas, Size size) {
      _drawWithGlobalCompositing(canvas, size, (Canvas drawCanvas) {
        // ignore: avoid_print
        print(
            '[Canvas2D] strokeRect() paint, rect=$rect, strokeStyle.runtimeType=${strokeStyle.runtimeType}, lineWidth=$lineWidth, lineCap=$lineCap, lineJoin=$lineJoin');
        Paint paint = Paint();
        final Path rectPath = Path()..addRect(rect);
        final Path effectivePath = _applyLineDashIfNeeded(rectPath);
        _paintShadowForPath(drawCanvas, effectivePath, paintingStyle: PaintingStyle.stroke);
        if (strokeStyle is Color) {
          paint.color = strokeStyle as Color;
        } else if (strokeStyle is CanvasRadialGradient) {
          paint.shader = _drawRadialGradient(strokeStyle as CanvasRadialGradient, x, y, w, h).createShader(rect);
        } else if (strokeStyle is CanvasLinearGradient) {
          paint.shader = _drawLinearGradient(strokeStyle as CanvasLinearGradient, x, y, w, h).createShader(rect);
        }
        paint
          ..strokeJoin = lineJoin
          ..strokeCap = lineCap
          ..strokeWidth = lineWidth
          ..strokeMiterLimit = miterLimit
          ..style = PaintingStyle.stroke;
        drawCanvas.drawPath(effectivePath, paint);
      });
    }, CanvasActionType.execute, {
      'x': x,
      'y': y,
      'width': w,
      'height': h,
      'strokeStyle': _describeStyleValue(_strokeStyle),
      'lineWidth': lineWidth,
    });
  }

  TextStyle _getTextStyle(Color color, bool shouldStrokeText) {
    if (_fontProperties.isEmpty) {
      _parseFont(_DEFAULT_FONT);
    }
    var fontFamilyFallback = CSSText.resolveFontFamilyFallback(_fontProperties[FONT_FAMILY]);
    FontWeight fontWeight = CSSText.resolveFontWeight(_fontProperties[FONT_WEIGHT]);
    if (canvas.ownerDocument.controller.boldText && fontWeight.index < FontWeight.w700.index) {
      fontWeight = FontWeight.w700;
    }
    if (shouldStrokeText) {
      return TextStyle(
          fontSize: _fontSize ?? 10,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: fontWeight,
          foreground: Paint()
            ..strokeJoin = lineJoin
            ..strokeCap = lineCap
            ..strokeWidth = lineWidth
            ..strokeMiterLimit = miterLimit
            ..style = PaintingStyle.stroke
            ..color = color);
    } else {
      return TextStyle(
        color: color,
        fontSize: _fontSize,
        fontFamilyFallback: fontFamilyFallback,
        fontWeight: fontWeight,
      );
    }
  }

  TextPainter _getTextPainter(String text, Color color, {bool shouldStrokeText = false}) {
    TextStyle textStyle = _getTextStyle(color, shouldStrokeText);
    TextSpan span = TextSpan(text: text, style: textStyle);
    final TextScaler textScaler = canvas.ownerDocument.controller.textScaler;
    TextPainter textPainter = TextPainter(
      text: span,
      // FIXME: Current must passed but not work in canvas text painter
      textScaler: textScaler,
      textDirection: direction,
      textAlign: textAlign,
    );

    return textPainter;
  }

  Offset _getAlignOffset(double width) {
    switch (textAlign) {
      case TextAlign.left:
        return Offset.zero;
      case TextAlign.right:
        return Offset(width, 0.0);
      case TextAlign.justify:
      case TextAlign.center:
        // The alignment is relative to the x value of the fillText() method.
        // For example, if textAlign is "center", then the text's left edge will be at x - (textWidth / 2).
        return Offset(width / 2.0, 0.0);
      case TextAlign.start:
        return direction == TextDirection.rtl ? Offset(width, 0.0) : Offset.zero;
      case TextAlign.end:
        return direction == TextDirection.rtl ? Offset.zero : Offset(width, 0.0);
    }
  }

  void fillText(String text, double x, double y, {double? maxWidth}) {
    addAction('fillText', (Canvas canvas, Size size) {
      if (fillStyle is! Color) {
        return;
      }
      _drawWithGlobalCompositing(canvas, size, (Canvas drawCanvas) {
        TextPainter textPainter = _getTextPainter(text, fillStyle as Color);
        if (maxWidth != null) {
          // FIXME: should scale down to a smaller font size in order to fit the text in the specified width.
          textPainter.layout(maxWidth: maxWidth);
        } else {
          textPainter.layout();
        }
        // Paint text start with baseline.
        double offsetToBaseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
        textPainter.paint(drawCanvas, Offset(x, y - offsetToBaseline) - _getAlignOffset(textPainter.width));
      });
    });
  }

  void strokeText(String text, double x, double y, {double? maxWidth}) {
    addAction('strokeText', (Canvas canvas, Size size) {
      if (strokeStyle is! Color) {
        return;
      }
      _drawWithGlobalCompositing(canvas, size, (Canvas drawCanvas) {
        TextPainter textPainter = _getTextPainter(text, strokeStyle as Color, shouldStrokeText: true);
        if (maxWidth != null) {
          // FIXME: should scale down to a smaller font size in order to fit the text in the specified width.
          textPainter.layout(maxWidth: maxWidth);
        } else {
          textPainter.layout();
        }

        double offsetToBaseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
        // Paint text start with baseline.
        textPainter.paint(drawCanvas, Offset(x, y - offsetToBaseline) - _getAlignOffset(textPainter.width));
      });
    });
  }

  TextMetrics? measureText(String text) {
    // create TextPainter after parse font
    _parseFont(_font);
    TextPainter textPainter = _getTextPainter(text, fillStyle as Color);
    textPainter.layout();
    double width = textPainter.width;
    TextMetrics textMetrics =
        TextMetrics(context: BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), width: width);
    return textMetrics;
  }

  LinearGradient _drawLinearGradient(CanvasLinearGradient gradient, double rX, double rY, double rW, double rH) {
    double cW = rW / 2;
    double cH = rH / 2;
    double lX = rX + cW;
    double lY = rY + cH;
    double centerX = (gradient.x0 - lX) / cW;
    double centerY = (gradient.y0 - lY) / cH;
    double focalX = (gradient.x1 - lX) / cW;
    double focalY = (gradient.y1 - lY) / cH;
    List<Color> colors = [];
    List<double> stops = [];
    for (var colorStop in gradient.colorGradients..sort((a, b) => a.stop?.compareTo(b.stop ?? 0) ?? 0)) {
      Color? color = colorStop.color;
      double? stop = colorStop.stop;
      if (color != null && stop != null) {
        colors.add(color);
        stops.add(stop);
      }
    }
    return LinearGradient(
        begin: Alignment(centerX, centerY),
        end: Alignment(focalX, focalY),
        colors: colors,
        stops: stops,
        tileMode: TileMode.clamp);
  }

  RadialGradient _drawRadialGradient(CanvasRadialGradient gradient, double rX, double rY, double rW, double rH) {
    double cW = rW / 2;
    double cH = rH / 2;
    double oX = rX + cW;
    double oY = rY + cH;

    /// The radius of the gradient, as a fraction of the shortest side
    /// of the paint box.
    double oR = math.min(rW, rH);
    double fx = (gradient.x0 - oX) / cW;
    double fy = (gradient.y0 - oY) / cH;
    double fr = gradient.r0 / oR;
    double cx = (gradient.x1 - oX) / cW;
    double cy = (gradient.y1 - oY) / cH;
    double cr = gradient.r1 / oR;
    List<Color> colors = [];
    List<double> stops = [];
    for (var colorStop in gradient.colorGradients..sort((a, b) => a.stop?.compareTo(b.stop ?? 0) ?? 0)) {
      Color? color = colorStop.color;
      double? stop = colorStop.stop;
      if (color != null && stop != null) {
        colors.add(color);
        stops.add(stop);
      }
    }
    return RadialGradient(
        focal: Alignment(fx, fy), focalRadius: fr, center: Alignment(cx, cy), radius: cr, colors: colors, stops: stops);
  }

  // Reset the rendering context to its default state.
  // Called while canvas element's dimensions were changed.
  void reset() {
    _pendingActions = [];
    _actions = [];
    _states.clear();
    _textAlign = TextAlign.start;
    _textBaseline = CanvasTextBaseline.alphabetic;
    _direction = TextDirection.ltr;
    _fontProperties.clear();
    _fontSize = null;
    _font = _DEFAULT_FONT;
    _strokeStyle = CSSColor.initial;
    _fillStyle = CSSColor.initial;
    _lineCap = StrokeCap.butt;
    _lineJoin = StrokeJoin.miter;
    _lineWidth = 1.0;
    _lineDash = const <double>[];
    _lineDashOffset = 0.0;
    _miterLimit = 10.0;
    _shadowBlur = 0.0;
    _shadowColor = const Color(0x00000000);
    _shadowOffsetX = 0.0;
    _shadowOffsetY = 0.0;
    _globalAlpha = 1.0;
    _globalCompositeOperation = 'source-over';
    _globalBlendMode = BlendMode.srcOver;
    path2d = Path2D();
  }
}
