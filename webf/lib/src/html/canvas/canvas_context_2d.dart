/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
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

typedef CanvasAction = void Function(Canvas, Size);

class CanvasRenderingContext2D extends BindingObject {
  CanvasRenderingContext2D(BindingContext context, this.canvas)
      : _pointer = context.pointer,
        super(context);

  final ffi.Pointer<NativeBindingObject> _pointer;

  @override
  get pointer => _pointer;

  @override
  get contextId => canvas.contextId;

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    methods['arc'] = BindingObjectMethodSync(
        call: (args) => arc(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble(),
            castToType<num>(args[4]).toDouble(),
            anticlockwise: (args.length > 5 && args[5] == 1) ? true : false));
    methods['arcTo'] = BindingObjectMethodSync(
        call: (args) => arcTo(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble(),
            castToType<num>(args[4]).toDouble()));
    methods['fillRect'] = BindingObjectMethodSync(
        call: (args) => fillRect(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble()));
    methods['clearRect'] = BindingObjectMethodSync(
        call: (args) => clearRect(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble()));
    methods['strokeRect'] = BindingObjectMethodSync(
        call: (args) => strokeRect(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble()));
    methods['fillText'] = BindingObjectMethodSync(call: (args) {
      if (args.length > 3) {
        double maxWidth = castToType<num>(args[3]).toDouble();
        if (!maxWidth.isNaN) {
          return fillText(
              castToType<String>(args[0]),
              castToType<num>(args[1]).toDouble(),
              castToType<num>(args[2]).toDouble(),
              maxWidth: maxWidth);
        }
        return fillText(
            castToType<String>(args[0]),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble());
      } else {
        return fillText(
            castToType<String>(args[0]),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble());
      }
    });
    methods['strokeText'] = BindingObjectMethodSync(call: (args) {
      if (args.length > 3) {
        double maxWidth = castToType<num>(args[3]).toDouble();
        if (!maxWidth.isNaN) {
          return strokeText(
              castToType<String>(args[0]),
              castToType<num>(args[1]).toDouble(),
              castToType<num>(args[2]).toDouble(),
              maxWidth: maxWidth);
        }
        return strokeText(
            castToType<String>(args[0]),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble());
      } else {
        return strokeText(
            castToType<String>(args[0]),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble());
      }
    });
    methods['save'] = BindingObjectMethodSync(call: (_) => save());
    methods['restore'] = BindingObjectMethodSync(call: (_) => restore());
    methods['beginPath'] = BindingObjectMethodSync(call: (_) => beginPath());
    methods['bezierCurveTo'] = BindingObjectMethodSync(
        call: (args) => bezierCurveTo(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble(),
            castToType<num>(args[4]).toDouble(),
            castToType<num>(args[5]).toDouble()));
    methods['clip'] = BindingObjectMethodSync(call: (args) {
      PathFillType fillType =
          (args.isNotEmpty && castToType<String>(args[0]) == EVENODD)
              ? PathFillType.evenOdd
              : PathFillType.nonZero;
      return clip(fillType);
    });
    methods['closePath'] = BindingObjectMethodSync(call: (_) => closePath());
    methods['drawImage'] = BindingObjectMethodSync(call: (args) {
      BindingObject imageElement = args[0];
      if (imageElement is ImageElement) {
        double sx = 0.0,
            sy = 0.0,
            sWidth = 0.0,
            sHeight = 0.0,
            dx = 0.0,
            dy = 0.0,
            dWidth = 0.0,
            dHeight = 0.0;

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

        return drawImage(args.length, imageElement, sx, sy, sWidth,
            sHeight, dx, dy, dWidth, dHeight);
      }
    });
    methods['fill'] = BindingObjectMethodSync(call: (args) {
      PathFillType fillType = (args.isNotEmpty && args[0] == EVENODD)
          ? PathFillType.evenOdd
          : PathFillType.nonZero;
      return fill(fillType);
    });
    methods['lineTo'] = BindingObjectMethodSync(
        call: (args) => lineTo(castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble()));
    methods['moveTo'] = BindingObjectMethodSync(
        call: (args) => moveTo(castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble()));
    methods['quadraticCurveTo'] = BindingObjectMethodSync(
        call: (args) => quadraticCurveTo(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble()));
    methods['rect'] = BindingObjectMethodSync(
        call: (args) => rect(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble()));
    methods['rotate'] = BindingObjectMethodSync(
        call: (args) => rotate(castToType<num>(args[0]).toDouble()));
    methods['resetTransform'] =
        BindingObjectMethodSync(call: (_) => resetTransform());
    methods['scale'] = BindingObjectMethodSync(
        call: (args) => scale(castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble()));
    methods['stroke'] = BindingObjectMethodSync(call: (args) => stroke());
    methods['setTransform'] = BindingObjectMethodSync(
        call: (args) => setTransform(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble(),
            castToType<num>(args[4]).toDouble(),
            castToType<num>(args[5]).toDouble()));
    methods['transform'] = BindingObjectMethodSync(
        call: (args) => transform(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble(),
            castToType<num>(args[4]).toDouble(),
            castToType<num>(args[5]).toDouble()));
    methods['translate'] = BindingObjectMethodSync(
        call: (args) => translate(castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble()));
    methods['reset'] = BindingObjectMethodSync(call: (_) => reset());
    methods['createLinearGradient'] = BindingObjectMethodSync(
        call: (args) => createLinearGradient(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble()));
    methods['createRadialGradient'] = BindingObjectMethodSync(
        call: (args) => createRadialGradient(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble(),
            castToType<num>(args[4]).toDouble(),
            castToType<num>(args[5]).toDouble()));
    methods['createPattern'] = BindingObjectMethodSync(
        call: (args) => createPattern(
            CanvasImageSource(args[0]), castToType<String>(args[1])));
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    properties['fillStyle'] = BindingObjectProperty(getter: () {
      if (fillStyle is CanvasGradient) {
        return fillStyle;
      }
      return CSSColor.convertToHex(fillStyle as Color);
    }, setter: (value) {
      if (value is String) {
        Color? color = CSSColor.parseColor(castToType<String>(value),
            renderStyle: canvas.renderStyle);
        if (color != null) fillStyle = color;
      } else if (value is CanvasGradient || value is CanvasPattern) {
        fillStyle = value;
      }
    });
    properties['direction'] = BindingObjectProperty(
        getter: () => _textDirectionInString,
        setter: (value) =>
            direction = parseDirection(castToType<String>(value)));
    properties['font'] = BindingObjectProperty(
        getter: () => font,
        setter: (value) => font = castToType<String>(value));
    properties['strokeStyle'] = BindingObjectProperty(getter: () {
      if (strokeStyle is CanvasGradient) {
        return strokeStyle;
      }
      return CSSColor.convertToHex(strokeStyle as Color);
    }, setter: (value) {
      if (value is String) {
        Color? color = CSSColor.parseColor(castToType<String>(value),
            renderStyle: canvas.renderStyle);
        if (color != null) strokeStyle = color;
      } else if (value is CanvasGradient) {
        strokeStyle = value;
      }
    });
    properties['lineCap'] = BindingObjectProperty(
        getter: () => lineCap,
        setter: (value) => lineCap = parseLineCap(castToType<String>(value)));
    properties['lineDashOffset'] = BindingObjectProperty(
        getter: () => lineDashOffset,
        setter: (value) => lineDashOffset = castToType<num>(value).toDouble());
    properties['lineJoin'] = BindingObjectProperty(
        getter: () => lineJoin,
        setter: (value) => lineJoin = parseLineJoin(castToType<String>(value)));
    properties['lineWidth'] = BindingObjectProperty(
        getter: () => lineWidth,
        setter: (value) => lineWidth = castToType<num>(value).toDouble());
    properties['miterLimit'] = BindingObjectProperty(
        getter: () => miterLimit,
        setter: (value) => miterLimit = castToType<num>(value).toDouble());
    properties['textAlign'] = BindingObjectProperty(
        getter: () => textAlign.toString(),
        setter: (value) =>
            textAlign = parseTextAlign(castToType<String>(value)));
    properties['textBaseline'] = BindingObjectProperty(
        getter: () => textBaseline.toString(),
        setter: (value) =>
            textBaseline = parseTextBaseline(castToType<String>(value)));
  }

  @override
  Future<void> dispose() async {
    _actions.clear();
    _pendingActions.clear();
    super.dispose();
  }

  final CanvasRenderingContext2DSettings _settings =
      CanvasRenderingContext2DSettings();

  CanvasRenderingContext2DSettings getContextAttributes() => _settings;

  CanvasElement canvas;

  // HACK: We need record the current matrix state because flutter canvas not export resetTransform now.
  // https://github.com/flutter/engine/pull/25449
  Matrix4 _matrix = Matrix4.identity();
  Matrix4 _lastMatrix = Matrix4.identity();

  int get actionCount => _actions.length;

  List<CanvasAction> _actions = [];
  List<CanvasAction> _pendingActions = [];

  void addAction(CanvasAction action) {
    _actions.add(action);
    // Must trigger repaint after action
    canvas.repaintNotifier
        .notifyListeners(); // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  }

  // For CanvasRenderingContext2D: createPattern() method; Creating a pattern from a canvas need to replay the actions because the canvas element may be not drawn.
  void replayActions(Canvas canvas, Size size) {
    Path2D paintTemp = path2d;
    path2d = Path2D();
    _actions.forEach((action) {
      action.call(canvas, size);
    });
    path2d = paintTemp;
  }

  // Perform canvas drawing.
  List<CanvasAction> performActions(Canvas canvas, Size size) {
    // HACK: Must sync transform first because each paint will saveLayer and restore that make the transform not effect
    if (!_lastMatrix.isIdentity()) {
      canvas.transform(_lastMatrix.storage);
    }
    _pendingActions = _actions;
    _actions = [];
    for (int i = 0; i < _pendingActions.length; i++) {
      _pendingActions[i](canvas, size);
    }
    return _pendingActions;
  }

  // Clear the saved pending actions.
  void clearActions(List<CanvasAction> actions) {
    if (_lastMatrix != _matrix) {
      _lastMatrix = _matrix.clone();
    }
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
    addAction((Canvas canvas, Size size) {
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

  CanvasTextBaseline _textBaseline =
      CanvasTextBaseline.alphabetic; // (default: "alphabetic")
  set textBaseline(CanvasTextBaseline? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
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
    addAction((Canvas canvas, Size size) {
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
        _fontSize =
            CSSLength.parseLength(properties[FONT_SIZE]!, canvas.renderStyle)
                .computedValue;
      }
    }
    return true;
  }

  String _font = _DEFAULT_FONT; // (default 10px sans-serif)
  set font(String value) {
    addAction((Canvas canvas, Size size) {
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
    addAction((Canvas canvas, Size size) {
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

      canvas.restore();
    });
  }

  // pop state stack and restore state
  void save() {
    addAction((Canvas canvas, Size size) {
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
        direction
      ]);
      canvas.save();
    });
  }

  Path2D path2d = Path2D();

  void beginPath() {
    addAction((Canvas canvas, Size size) {
      path2d = Path2D();
    });
  }

  void clip(PathFillType fillType) {
    addAction((Canvas canvas, Size size) {
      path2d.path.fillType = fillType;
      canvas.clipPath(path2d.path);
    });
  }

  void fill(PathFillType fillType) {
    addAction((Canvas canvas, Size size) {
      if (fillStyle is! Color) {
        return;
      }
      path2d.path.fillType = fillType;
      Paint paint = Paint()
        ..color = fillStyle as Color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path2d.path, paint);
    });
  }

  void stroke() {
    addAction((Canvas canvas, Size size) {
      if (strokeStyle is! Color) {
        return;
      }
      Paint paint = Paint()
        ..color = strokeStyle as Color
        ..strokeJoin = lineJoin
        ..strokeCap = lineCap
        ..strokeWidth = lineWidth
        ..strokeMiterLimit = miterLimit
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path2d.path, paint);
    });
  }

  bool isPointInPath(double x, double y, PathFillType fillRule) {
    return path2d.path.contains(Offset(x, y));
  }

  bool isPointInStroke(double x, double y) {
    return path2d.path.contains(Offset(x, y));
  }

  void arc(
      double x, double y, double radius, double startAngle, double endAngle,
      {bool anticlockwise = false}) {
    addAction((Canvas canvas, Size size) {
      path2d.arc(x, y, radius, startAngle, endAngle,
          anticlockwise: anticlockwise);
    });
  }

  void arcTo(double x1, double y1, double x2, double y2, double radius) {
    addAction((Canvas canvas, Size size) {
      path2d.arcTo(x1, y1, x2, y2, radius);
    });
  }

  void bezierCurveTo(
      double cp1x, double cp1y, double cp2x, double cp2y, double x, double y) {
    addAction((Canvas canvas, Size size) {
      path2d.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
    });
  }

  void closePath() {
    addAction((Canvas canvas, Size size) {
      path2d.closePath();
    });
  }

  void drawImage(
      int argumentCount,
      ImageElement? imgElement,
      double sx,
      double sy,
      double sWidth,
      double sHeight,
      double dx,
      double dy,
      double dWidth,
      double dHeight) {

    addAction((Canvas canvas, Size size) {
      if (imgElement?.image == null) return;
      
      Image img = imgElement!.image!;
      // ctx.drawImage(image, dx, dy);
      if (argumentCount == 3) {
        canvas.drawImage(img, Offset(dx, dy), Paint());
      } else {
        if (argumentCount == 5) {
          // ctx.drawImage(image, dx, dy, dWidth, dHeight);
          sx = 0;
          sy = 0;
          sWidth = img.width.toDouble();
          sHeight = img.height.toDouble();
        }

        canvas.drawImageRect(img, Rect.fromLTWH(sx, sy, sWidth, sHeight),
            Rect.fromLTWH(dx, dy, dWidth, dHeight), Paint());
      }
    });
  }

  void ellipse(double x, double y, double radiusX, double radiusY,
      double rotation, double startAngle, double endAngle,
      {bool anticlockwise = false}) {
    addAction((Canvas canvas, Size size) {
      path2d.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle,
          anticlockwise: anticlockwise);
    });
  }

  void lineTo(double x, double y) {
    addAction((Canvas canvas, Size size) {
      path2d.lineTo(x, y);
    });
  }

  void moveTo(double x, double y) {
    addAction((Canvas canvas, Size size) {
      path2d.moveTo(x, y);
    });
  }

  void quadraticCurveTo(double cpx, double cpy, double x, double y) {
    addAction((Canvas canvas, Size size) {
      path2d.quadraticCurveTo(cpx, cpy, x, y);
    });
  }

  void rect(double x, double y, double w, double h) {
    addAction((Canvas canvas, Size size) {
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
    addAction((Canvas canvas, Size size) {
      _lineCap = value;
    });
  }

  StrokeCap get lineCap => _lineCap;

  double _lineDashOffset = 0.0;

  set lineDashOffset(double? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
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
    addAction((Canvas canvas, Size size) {
      _lineJoin = value;
    });
  }

  StrokeJoin get lineJoin => _lineJoin;

  double _lineWidth = 1.0; // (default 1)
  set lineWidth(double? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _lineWidth = value;
    });
  }

  double get lineWidth => _lineWidth;

  double _miterLimit = 10.0; // (default 10)
  set miterLimit(double? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _miterLimit = value;
    });
  }

  double get miterLimit => _miterLimit;

  String _lineDash = 'empty'; // default empty

  String getLineDash() {
    return _lineDash;
  }

  void setLineDash(String segments) {
    _lineDash = segments;
  }

  void translate(double x, double y) {
    _matrix.translate(x, y);
    addAction((Canvas canvas, Size size) {
      canvas.translate(x, y);
    });
  }

  void rotate(double angle) {
    _matrix.setRotationZ(angle);
    addAction((Canvas canvas, Size size) {
      canvas.rotate(angle);
    });
  }

  // transformations (default transform is the identity matrix)
  void scale(double x, double y) {
    _matrix.scale(x, y);
    addAction((Canvas canvas, Size size) {
      canvas.scale(x, y);
    });
  }

  Matrix4 getTransform() {
    return _matrix;
  }

  // https://github.com/WebKit/WebKit/blob/a77a158d4e2086fbe712e488ed147e8a54d44d3c/Source/WebCore/html/canvas/CanvasRenderingContext2DBase.cpp#L843
  void setTransform(
      double a, double b, double c, double d, double e, double f) {
    resetTransform();
    transform(a, b, c, d, e, f);
  }

  // Resets the current transform to the identity matrix.
  void resetTransform() {
    Matrix4 m4 = Matrix4.inverted(_matrix);
    _matrix = Matrix4.identity();
    addAction((Canvas canvas, Size size) {
      canvas.transform(m4.storage);
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
    //   e, f, 1, 0,
    //   0, 0, 0, 1 ]
    final Float64List m4storage = Float64List(16);
    m4storage[0] = a;
    m4storage[1] = b;
    m4storage[2] = 0.0;
    m4storage[3] = 0.0;
    m4storage[4] = c;
    m4storage[5] = d;
    m4storage[6] = 0.0;
    m4storage[7] = 0.0;
    m4storage[8] = e;
    m4storage[9] = f;
    m4storage[10] = 1.0;
    m4storage[11] = 0.0;
    m4storage[12] = 0.0;
    m4storage[13] = 0.0;
    m4storage[14] = 0.0;
    m4storage[15] = 1.0;

    _matrix = Matrix4.fromFloat64List(m4storage)..multiply(_matrix);
    addAction((Canvas canvas, Size size) {
      canvas.transform(m4storage);
    });
  }

  Object _strokeStyle = CSSColor.initial; // default black
  Object get strokeStyle => _strokeStyle;

  set strokeStyle(Object? newValue) {
    if (newValue == null) return;
    addAction((Canvas canvas, Size size) {
      _strokeStyle = newValue;
    });
  }

  Object _fillStyle = CSSColor.initial; // default black
  Object get fillStyle => _fillStyle;

  set fillStyle(Object? newValue) {
    if (newValue == null) return;
    addAction((Canvas canvas, Size size) {
      _fillStyle = newValue;
    });
  }

  CanvasGradient createLinearGradient(
      double x0, double y0, double x1, double y1) {
    return CanvasLinearGradient(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), canvas, x0, y0, x1, y1);
  }

  CanvasPattern createPattern(CanvasImageSource image, String repetition) {
    return CanvasPattern(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), image, repetition);
  }

  CanvasGradient createRadialGradient(
      double x0, double y0, double r0, double x1, double y1, double r1) {
    return CanvasRadialGradient(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), canvas, x0, y0, r0, x1, y1, r1);
  }

  void clearRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    addAction((Canvas canvas, Size size) {
      // Must saveLayer before clear avoid there is a "black" background
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.clear;
      canvas.drawRect(rect, paint);
    });
  }

  void fillRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    addAction((Canvas canvas, Size size) {
      Paint paint = Paint();
      if (fillStyle is Color ||
          fillStyle is CanvasRadialGradient ||
          fillStyle is CanvasLinearGradient) {
        if (fillStyle is Color) {
          paint..color = fillStyle as Color;
        } else if (fillStyle is CanvasRadialGradient) {
          paint
            ..shader = _drawRadialGradient(
                    fillStyle as CanvasRadialGradient, x, y, w, h)
                .createShader(rect);
        } else if (fillStyle is CanvasLinearGradient) {
          paint
            ..shader = _drawLinearGradient(
                    fillStyle as CanvasLinearGradient, x, y, w, h)
                .createShader(rect);
        }
        canvas.drawRect(rect, paint);
      } else if (fillStyle is CanvasPattern) {
        var canvasPattern = fillStyle as CanvasPattern;
        if (canvasPattern.image.image_element == null &&
            canvasPattern.image.canvas_element == null) {
          throw AssertionError(
              'CanvasPattern must be created from a canvas or image');
        }

        String repetition = canvasPattern.repetition;
        int patternWidth = canvasPattern.image.image_element != null
            ? canvasPattern.image.image_element!.width
            : canvasPattern.image.canvas_element!.width;
        int patternHeight = canvasPattern.image.image_element != null
            ? canvasPattern.image.image_element!.height
            : canvasPattern.image.canvas_element!.height;
        double xRepeatNum = ((w - x) / patternWidth);
        double yRepeatNum = ((h - y) / patternHeight);
        // CanvasPattern created from an image
        if (canvasPattern.image.image_element != null ||
            (canvasPattern.image.canvas_element != null &&
                canvasPattern.image.canvas_element?.painter.snapshot != null)) {
          Image? repeatImg = canvasPattern.image.image_element?.image ??
              canvasPattern.image.canvas_element?.painter.snapshot;

          if (repetition == 'no-repeat') {
            xRepeatNum = 1;
            yRepeatNum = 1;
          } else if (repetition == 'repeat-x') {
            yRepeatNum = 1;
          } else if (repetition == 'repeat-y') {
            xRepeatNum = 1;
          }

          for (int i = 0; i < xRepeatNum; i++) {
            for (int j = 0; j < yRepeatNum; j++) {
              canvas.drawImage(repeatImg!,
                  Offset(x + i * patternWidth, y + j * patternHeight), paint);
            }
          }
        } else {
          // CanvasPattern created from a canvas
          canvas.translate(x, y);
          switch (repetition) {
            case 'no-repeat':
              canvasPattern.image.canvas_element?.context2d!
                  .replayActions(canvas, size);
              break;
            case 'repeat-x':
              for (int i = 0; i < xRepeatNum; i++) {
                canvasPattern.image.canvas_element?.context2d!
                    .replayActions(canvas, size);
                canvas.translate(patternWidth.toDouble(), 0);
              }
              break;
            case 'repeat-y':
              for (int j = 0; j < yRepeatNum; j++) {
                canvasPattern.image.canvas_element?.context2d!
                    .replayActions(canvas, size);
                canvas.translate(0, patternHeight.toDouble());
              }
              break;
            case 'repeat':
              for (int i = 0; i < xRepeatNum; i++) {
                for (int j = 0; j < yRepeatNum; j++) {
                  canvasPattern.image.canvas_element?.context2d!
                      .replayActions(canvas, size);
                  canvas.translate(0, patternHeight.toDouble());
                }
                canvas.translate(patternWidth.toDouble(), y - h);
              }
              break;
          }
        }
      }
    });
  }

  void strokeRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    addAction((Canvas canvas, Size size) {
      Paint paint = Paint();
      if (strokeStyle is Color) {
        paint..color = strokeStyle as Color;
      } else if (strokeStyle is CanvasRadialGradient) {
        paint
          ..shader = _drawRadialGradient(
                  strokeStyle as CanvasRadialGradient, x, y, w, h)
              .createShader(rect);
      } else if (strokeStyle is CanvasLinearGradient) {
        paint
          ..shader = _drawLinearGradient(
                  strokeStyle as CanvasLinearGradient, x, y, w, h)
              .createShader(rect);
      }
      paint
        ..strokeJoin = lineJoin
        ..strokeCap = lineCap
        ..strokeWidth = lineWidth
        ..strokeMiterLimit = miterLimit
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, paint);
    });
  }

  TextStyle _getTextStyle(Color color, bool shouldStrokeText) {
    if (_fontProperties.isEmpty) {
      _parseFont(_DEFAULT_FONT);
    }
    var fontFamilyFallback =
        CSSText.resolveFontFamilyFallback(_fontProperties[FONT_FAMILY]);
    FontWeight fontWeight =
        CSSText.resolveFontWeight(_fontProperties[FONT_WEIGHT]);
    if (shouldStrokeText) {
      return TextStyle(
          fontSize: _fontSize ?? 10,
          fontFamilyFallback: fontFamilyFallback,
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

  TextPainter _getTextPainter(String text, Color color,
      {bool shouldStrokeText = false}) {
    TextStyle textStyle = _getTextStyle(color, shouldStrokeText);
    TextSpan span = TextSpan(text: text, style: textStyle);
    TextPainter textPainter = TextPainter(
      text: span,
      // FIXME: Current must passed but not work in canvas text painter
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
        return direction == TextDirection.rtl
            ? Offset(width, 0.0)
            : Offset.zero;
      case TextAlign.end:
        return direction == TextDirection.rtl
            ? Offset.zero
            : Offset(width, 0.0);
    }
  }

  void fillText(String text, double x, double y, {double? maxWidth}) {
    addAction((Canvas canvas, Size size) {
      if (fillStyle is! Color) {
        return;
      }
      TextPainter textPainter = _getTextPainter(text, fillStyle as Color);
      if (maxWidth != null) {
        // FIXME: should scale down to a smaller font size in order to fit the text in the specified width.
        textPainter.layout(maxWidth: maxWidth);
      } else {
        textPainter.layout();
      }
      // Paint text start with baseline.
      double offsetToBaseline =
          textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      textPainter.paint(canvas,
          Offset(x, y - offsetToBaseline) - _getAlignOffset(textPainter.width));
    });
  }

  void strokeText(String text, double x, double y, {double? maxWidth}) {
    addAction((Canvas canvas, Size size) {
      if (strokeStyle is! Color) {
        return;
      }
      TextPainter textPainter =
          _getTextPainter(text, strokeStyle as Color, shouldStrokeText: true);
      if (maxWidth != null) {
        // FIXME: should scale down to a smaller font size in order to fit the text in the specified width.
        textPainter.layout(maxWidth: maxWidth);
      } else {
        textPainter.layout();
      }

      double offsetToBaseline =
          textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      // Paint text start with baseline.
      textPainter.paint(canvas,
          Offset(x, y - offsetToBaseline) - _getAlignOffset(textPainter.width));
    });
  }

  TextMetrics? measureText(String text) {
    // TextPainter textPainter = _getTextPainter(text, fillStyle);
    // TODO: transform textPainter layout info into TextMetrics.
    return null;
  }

  LinearGradient _drawLinearGradient(CanvasLinearGradient gradient, double rX,
      double rY, double rW, double rH) {
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
    for (var colorStop in gradient.colorGradients
      ..sort((a, b) => a.stop?.compareTo(b.stop ?? 0) ?? 0)) {
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

  RadialGradient _drawRadialGradient(CanvasRadialGradient gradient, double rX,
      double rY, double rW, double rH) {
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
    for (var colorStop in gradient.colorGradients
      ..sort((a, b) => a.stop?.compareTo(b.stop ?? 0) ?? 0)) {
      Color? color = colorStop.color;
      double? stop = colorStop.stop;
      if (color != null && stop != null) {
        colors.add(color);
        stops.add(stop);
      }
    }
    return RadialGradient(
        focal: Alignment(fx, fy),
        focalRadius: fr,
        center: Alignment(cx, cy),
        radius: cr,
        colors: colors,
        stops: stops);
  }

  // Reset the rendering context to its default state.
  // Called while canvas element's dimensions were changed.
  void reset() {
    _pendingActions = [];
    _actions = [];
    _states.clear();
    _matrix = Matrix4.identity();
    _lastMatrix = Matrix4.identity();
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
    _lineDash = 'empty';
    _lineDashOffset = 0.0;
    _miterLimit = 10.0;
    path2d = Path2D();
  }
}
