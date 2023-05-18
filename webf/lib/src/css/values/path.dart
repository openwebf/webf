/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

enum _CSSPathCommandCategory {
  MoveTo,
  LineTo,
  CubicBezier,
  QuadraticBezier,
  Arc,
  Other,
}

enum _CSSPathCommandType {
  // MoveTo
  M(_CSSPathCommandCategory.MoveTo), m(_CSSPathCommandCategory.MoveTo),
  // Close path
  Z(_CSSPathCommandCategory.Other), z(_CSSPathCommandCategory.Other),
  // LineTo
  L(_CSSPathCommandCategory.LineTo), l(_CSSPathCommandCategory.LineTo),
  H(_CSSPathCommandCategory.LineTo), h(_CSSPathCommandCategory.LineTo),
  V(_CSSPathCommandCategory.LineTo), v(_CSSPathCommandCategory.LineTo),
  // Curve
  C(_CSSPathCommandCategory.CubicBezier), c(_CSSPathCommandCategory.CubicBezier),
  S(_CSSPathCommandCategory.CubicBezier), s(_CSSPathCommandCategory.CubicBezier),
  Q(_CSSPathCommandCategory.QuadraticBezier), q(_CSSPathCommandCategory.QuadraticBezier),
  T(_CSSPathCommandCategory.QuadraticBezier), t(_CSSPathCommandCategory.QuadraticBezier),
  // Arc
  A(_CSSPathCommandCategory.Arc), a(_CSSPathCommandCategory.Arc);

  final _CSSPathCommandCategory _category;
  _CSSPathCommandCategory get category => _category;

  get isBezierCurve => _category == _CSSPathCommandCategory.CubicBezier || _category == _CSSPathCommandCategory.QuadraticBezier;

  const _CSSPathCommandType(this._category);
}

var _CSSPathCommandTypeMap = _CSSPathCommandType.values.asNameMap();

class _CSSPathCommand {
  final _CSSPathCommandType type;

  final List<double> params;

  // M 0 0      10 10   20 20
  //   ^=false  ^=true  ^=true
  final bool isSubSequent;

  _CSSPathCommand(this.type, this.params, {this.isSubSequent = false});
}

List<String> _validFirstNumbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];
List<String> _validFirstNumberTokens = ['+', '-', '0', ..._validFirstNumbers];
List<String> _validNumberTokens = ['0', ..._validFirstNumbers ];
List<String> _whitespaceTokens = [String.fromCharCode(0x9), String.fromCharCode(0x20),String.fromCharCode(0xA), String.fromCharCode(0xC), String.fromCharCode(0xD)];

class _CSSPathParser {
  String input;

  int index = 0;
  int preIndex = 0;
  List<_CSSPathCommand> commands = [];
  List<double> params = [];
  late _CSSPathCommandType type;

  int errorIndex = -1;

  get hasError => errorIndex != -1;

  _CSSPathParser(this.input);

  CSSPath parse() {
    var firstType = _loopNextCommandType();
    if (firstType == null) {
      // first is invalid
      _error();
      return CSSPath.None;
    }

    type = firstType;
    _readWhitespace();
    _readLoop();

    return CSSPath(input, commands);
  }

  void _readLoop() {
    var isSubSeq = false;
    while (index < input.length && !hasError) {
      switch(type) {
        case _CSSPathCommandType.Z:
        case _CSSPathCommandType.z:
          // zero param;
          break;

        case _CSSPathCommandType.H:
        case _CSSPathCommandType.h:
        case _CSSPathCommandType.V:
        case _CSSPathCommandType.v:
          _readOneNumber();
          break;

        case _CSSPathCommandType.M:
        case _CSSPathCommandType.m:
        case _CSSPathCommandType.L:
        case _CSSPathCommandType.l:
        case _CSSPathCommandType.T:
        case _CSSPathCommandType.t:
          _readNumberPair();
          break;

        case _CSSPathCommandType.S:
        case _CSSPathCommandType.s:
        case _CSSPathCommandType.Q:
        case _CSSPathCommandType.q:
          _readNumberPairDouble();
          break;

        case _CSSPathCommandType.A:
        case _CSSPathCommandType.a:
          _readNumberArc();
          break;

        case _CSSPathCommandType.C:
        case _CSSPathCommandType.c:
          _readNumberPairTriplet();
          break;
      }

      if (hasError) return;

      commands.add(_CSSPathCommand(type, params, isSubSequent: isSubSeq));
      params = [];

      final tryNextType = _loopNextCommandType();
      if (tryNextType != null) {
        isSubSeq = false;
        type = tryNextType;
        _readWhitespace();
      } else {
        isSubSeq = true;
        // read next sequence
        _readCommaWhitespace();
      }
    }
    if (!hasError && type == _CSSPathCommandType.Z || type == _CSSPathCommandType.z) {
      commands.add(_CSSPathCommand(type, params, isSubSequent: isSubSeq));
    }
  }

  // wsp*
  void _readWhitespace() {
    String char;
    while (index < input.length) {
      char = input[index];
      if (!_whitespaceTokens.contains(char)) break;
      index++;
    }
    preIndex = index;
  }

  // comma_wsp?
  void _readCommaWhitespace() {
    String char;
    while (index < input.length) {
      char = input[index];
      if (!_whitespaceTokens.contains(char) && char != ',') break;
      index++;
    }
    preIndex = index;
  }

  double? _readNumber() {
    // I think 0 is not a valid first token, but it works.
    if (!_validFirstNumberTokens.contains(input[index])) {
      return null;
    }
    var hasDot = input[index] == '.';
    index += 1;
    while (index < input.length && _validNumberTokens.contains(input[index])) {
      if (input[index] == '.') {
        // only one dot is allowed
        if (hasDot) break;
        hasDot = true;
      }
      index += 1;
    }
    double? num = double.tryParse(input.substring(preIndex, index));
    preIndex = index;
    return num;
  }

  double? _readFlag() {
    if (input[index] != '0' && input[index] != '1') {
      return null;
    }
    double num = double.tryParse(input.substring(index, index + 1))!;
    preIndex = index += 1;
    return num;
  }

  void _readOneNumber() {
    var num = _readNumber();
    if (num == null) return _error();
    params.add(num);
  }

  void _readOneFlag() {
    var flag = _readFlag();
    if (flag == null) return _error();
    params.add(flag);
  }

  void _readNumberPair() {
    _readOneNumber();
    if (hasError) return;

    _readCommaWhitespace();

    _readOneNumber();
    if (hasError) return;
  }

  void _readNumberPairDouble() {
    _readNumberPair();
    if (hasError) return;

    _readCommaWhitespace();

    _readNumberPair();
    if (hasError) return;
  }

  void _readNumberPairTriplet() {
    _readNumberPair();
    if (hasError) return;

    _readCommaWhitespace();

    _readNumberPair();
    if (hasError) return;

    _readCommaWhitespace();

    _readNumberPair();
    if (hasError) return;
  }

  void _readNumberArc() {
    _readOneNumber(); // rx
    if (hasError) return;

    _readCommaWhitespace();

    _readOneNumber(); // ry
    if (hasError) return;

    _readCommaWhitespace();

    _readOneNumber(); // angle
    if (hasError) return;

    _readCommaWhitespace();

    _readOneFlag(); // large arc flag
    if (hasError) return;

    _readCommaWhitespace();

    _readOneFlag(); // sweep flag
    if (hasError) return;

    _readCommaWhitespace();

    _readNumberPair(); // x, y
    if (hasError) return;
  }

  _CSSPathCommandType? _loopNextCommandType() {
    final cacheIndex = index;
    _readWhitespace();
    if (index >= input.length) return null;
    final char = input[index];
    final type = _CSSPathCommandTypeMap[char];
    if (type == null) {
      // restore index
      preIndex = index = cacheIndex;
    } else {
      preIndex = index += 1;
    }
    return type;
  }

  void _error() {
    errorIndex = index;
  }
}

class CSSPath {
  static const None = CSSPath('', []);

  // https://svgwg.org/svg2-draft/paths.html#PathData
  static parseValue(String input) {
    if (input.isEmpty) {
      return None;
    }

    return _CSSPathParser(input).parse();
  }

  final String _value;
  get value => _value;

  final List<_CSSPathCommand> _commands;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(Object other) => other is CSSPath && _value == other._value;

  const CSSPath(this._value, this._commands);

  applyTo(Path path) {
    // initial point of a sub-path, absolute position, updated on MoveTo
    double ix = 0;
    double iy = 0;
    // current point, absolute position
    double x = 0;
    double y = 0;
    // control point for bezier curve, absolute position
    double? cx;
    double? cy;
    _CSSPathCommandType? preType;

    for (var command in _commands) {
      final params = command.params;
      final type = command.type;

      if (preType != null && preType.category != type.category) {
        // reset control point for bezier curve when category is changed
        cx = null;
        cy = null;
      }

      switch (type) {
        case _CSSPathCommandType.M:
          if (command.isSubSequent) {
            // sub sequent command treated as line to
            path.lineTo(x = params[0], y = params[1]);
          } else {
            path.moveTo(ix = x = params[0], iy = y = params[1]);
          }
          break;
        case _CSSPathCommandType.m:
          if (command.isSubSequent) {
            path.relativeLineTo(params[0], params[1]);
            x += params[0];
            y += params[1];
          } else {
            path.relativeMoveTo(params[0], params[1]);
            ix = x += params[0];
            iy = y += params[1];
          }
          break;
        case _CSSPathCommandType.L:
          path.lineTo(x = params[0], y = params[1]);
          break;
        case _CSSPathCommandType.l:
          path.relativeLineTo(params[0], params[1]);
          x += params[0];
          y += params[1];
          break;
        case _CSSPathCommandType.H:
          path.lineTo(x = params[0], y);
          break;
        case _CSSPathCommandType.h:
          x += params[0];
          path.relativeLineTo(params[0], 0);
          break;
        case _CSSPathCommandType.V:
          path.lineTo(x, y = params[0]);
          break;
        case _CSSPathCommandType.v:
          y += params[0];
          path.relativeLineTo(0, params[0]);
          break;
        case _CSSPathCommandType.A:
          path.arcToPoint(
              Offset(x = params[5], y = params[6]),
              radius: Radius.elliptical(params[0], params[1]),
            rotation: params[2],
            largeArc: params[3] == 1,
            clockwise: params[4] == 1,
          );
          break;
        case _CSSPathCommandType.a:
          x += params[5];
          y += params[6];
          path.relativeArcToPoint(Offset(params[5], params[6]),
            radius: Radius.elliptical(params[0], params[1]),
            rotation: params[2],
            largeArc: params[3] == 1,
            clockwise: params[4] == 1);
          break;

        case _CSSPathCommandType.C:
          path.cubicTo(params[0], params[1], cx = params[2], cy = params[3], x = params[4], y = params[5]);
          break;
        case _CSSPathCommandType.c:
          path.relativeCubicTo(params[0], params[1], params[2], params[3], params[4], params[5]);
          cx = x + params[2];
          cy = y + params[3];
          x += params[4];
          y += params[5];
          break;

        case _CSSPathCommandType.S:
          path.cubicTo(cx ?? x, cy ?? y, cx = params[0], cy = params[1], x = params[2], y = params[3]);
          break;

        case _CSSPathCommandType.s:
          path.relativeCubicTo(cx != null ? cx - x : 0, cy != null ? cy - y : 0, params[0], params[1], params[2], params[3]);
          cx = x + params[0];
          cy = y + params[1];
          x += params[2];
          y += params[3];
          break;

        case _CSSPathCommandType.Q:
          path.quadraticBezierTo(cx = params[0], cy = params[1], x = params[2], y = params[3]);
          break;
        case _CSSPathCommandType.q:
          path.relativeQuadraticBezierTo(params[0], params[1], params[2], params[3]);
          cx = x + params[0];
          cy = y + params[1];
          x += params[2];
          y += params[3];
          break;

        case _CSSPathCommandType.T:
          cx ??= x;
          cy ??= y;
          path.quadraticBezierTo(cx, cy, x = params[0], y = params[1]);
          break;

        case _CSSPathCommandType.t:
          path.relativeQuadraticBezierTo(cx != null ? cx - x : 0, cy != null ? cy - y : 0, params[0], params[1]);
          x += params[0];
          y += params[1];
          cx ??= x;
          cy ??= y;
          break;

        case _CSSPathCommandType.Z:
        case _CSSPathCommandType.z:
          path.close();
          x = ix;
          y = iy;
          break;
      }

      if (type.isBezierCurve) {
        // reflect control point based on the end point
        assert(cx != null);
        assert(cy != null);
        cx = x + (x - cx!);
        cy = y + (y - cy!);
      }

      preType = type;
    }
  }

  bool isSmoothlySame(CSSPath other) {
    if (_commands.length == other._commands.length) {
      // TODO: more compare
      return true;
    }
    return false;
  }
}
