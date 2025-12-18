/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart' show Curve;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/foundation/logger.dart';
import 'package:webf/src/foundation/debug_flags.dart';

// CSS Transitions: https://drafts.csswg.org/css-transitions/
const String _zeroSeconds = '0s';

Color? _parseColor(String color, RenderStyle renderStyle, String propertyName) {
  return CSSColor
      .resolveColor(color, renderStyle, propertyName)
      ?.value;
}

String _stringifyColor(Color color) {
  return CSSColor(color).cssText();
}

Color _updateColor(Color oldColor, Color newColor, double progress, String property, RenderStyle renderStyle) {
  // Heuristic for more intuitive color fades when one side is fully
  // transparent (alpha == 0): treat the transparent endpoint as having
  // the same RGB channels as the opaque endpoint so that we interpolate
  // only alpha (red → transparent red) instead of passing through black.
  Color effectiveOld = oldColor;
  Color effectiveNew = newColor;
  if (oldColor.a == 0.0 && newColor.a > 0.0) {
    effectiveOld = newColor.withAlpha(0);
  } else if (newColor.a == 0.0 && oldColor.a > 0.0) {
    effectiveNew = oldColor.withAlpha(0);
  }

  Color? result = Color.lerp(effectiveOld, effectiveNew, progress);
  if (DebugFlags.shouldLogTransitionForProp(property)) {
    final cssOld = CSSColor(effectiveOld).cssText();
    final cssNew = CSSColor(effectiveNew).cssText();
    final cssCurrent = CSSColor(result!).cssText();
    cssLogger.info(
        '[transition][tick] ${renderStyle.target.tagName}.$property t=${progress.toStringAsFixed(3)} '
        'from=$cssOld to=$cssNew value=$cssCurrent');
  }
  renderStyle.target.setRenderStyleProperty(property, CSSColor(result!));
  return result;
}

double _parseLength(String length, RenderStyle renderStyle, String property) {
  return CSSLength
      .parseLength(length, renderStyle, property)
      .computedValue;
}

String _stringifyLength(double value) {
  return '${value}px';
}

double _updateLength(double oldLengthValue, double newLengthValue, double progress, String property,
    CSSRenderStyle renderStyle) {
  double value = oldLengthValue * (1 - progress) + newLengthValue * progress;
  renderStyle.target.setRenderStyleProperty(property, CSSLengthValue(value, CSSLengthType.PX));
  return value;
}

CSSBorderRadius? _parseBorderLength(String length, RenderStyle renderStyle, String property) {
  return CSSBorderRadius.parseBorderRadius(length, renderStyle, property);
}

String _stringifyBorderLength(CSSBorderRadius? value) {
  return value?.toString() ?? '';
}

CSSBorderRadius? _updateBorderLength(CSSBorderRadius startRadius, CSSBorderRadius endRadius, double progress,
    String property, CSSRenderStyle renderStyle) {
  Radius? radius = Radius.lerp(startRadius.computedRadius, endRadius.computedRadius, progress);
  if (radius != null) {
    CSSLengthValue oldX = startRadius.x;
    CSSLengthValue oldY = startRadius.y;
    CSSLengthValue newX = CSSLength.parseLength(
        _stringifyLength(radius.x), oldX.renderStyle, oldX.propertyName, oldX.axisType);
    CSSLengthValue newY = CSSLength.parseLength(
        _stringifyLength(radius.y), oldY.renderStyle, oldY.propertyName, oldY.axisType);
    CSSBorderRadius newRadius = CSSBorderRadius(newX, newY);
    //fix optimization current value and the last value have not changed
    dynamic lastValueObj = renderStyle.getProperty(property);
    if (lastValueObj is CSSBorderRadius) {
      if (lastValueObj.computedRadius.x == newRadius.computedRadius.x
          && lastValueObj.computedRadius.y == newRadius.computedRadius.y) {
        return newRadius;
      }
    }
    renderStyle.target.setRenderStyleProperty(property, newRadius);
    return newRadius;
  }
  return null;
}

FontWeight _parseFontWeight(String fontWeight, RenderStyle renderStyle, String property) {
  return CSSText.resolveFontWeight(fontWeight);
}

String _stringifyFontWeight(FontWeight fontWeight) {
  return fontWeight.cssText();
}

FontWeight _updateFontWeight(FontWeight oldValue, FontWeight newValue, double progress, String property,
    CSSRenderStyle renderStyle) {
  FontWeight? fontWeight = FontWeight.lerp(oldValue, newValue, progress) ?? FontWeight.normal;
  switch (property) {
    case FONT_WEIGHT:
      renderStyle.fontWeight = fontWeight;
      break;
  }

  return fontWeight;
}

double? _parseNumber(String number, RenderStyle renderStyle, String property) {
  return CSSNumber.parseNumber(number);
}

String _stringifyNumber(double num) {
  return num.toString();
}

double _getNumber(double oldValue, double newValue, double progress) {
  return oldValue * (1 - progress) + newValue * progress;
}

double _updateNumber(double oldValue, double newValue, double progress, String property, RenderStyle renderStyle) {
  double number = _getNumber(oldValue, newValue, progress);
  renderStyle.target.setRenderStyleProperty(property, number);
  return number;
}

double _parseLineHeight(String lineHeight, RenderStyle renderStyle, String property) {
  if (CSSNumber.isNumber(lineHeight)) {
    return CSSLengthValue(CSSNumber.parseNumber(lineHeight), CSSLengthType.EM, renderStyle, LINE_HEIGHT).computedValue;
  }
  return CSSLength
      .parseLength(lineHeight, renderStyle, LINE_HEIGHT)
      .computedValue;
}

String _stringifyLineHeight(CSSLengthValue lineNumber) {
  return '${lineNumber.value}px';
}

CSSLengthValue _updateLineHeight(double oldValue, double newValue, double progress, String property,
    CSSRenderStyle renderStyle) {
  CSSLengthValue lengthValue = CSSLengthValue(_getNumber(oldValue, newValue, progress), CSSLengthType.PX);
  renderStyle.lineHeight = lengthValue;
  return lengthValue;
}

TransformAnimationValue _parseTransform(String value, RenderStyle renderStyle, String property) {
  // Capture a frozen matrix at setup so percentage-based transforms like
  // translateX(100%) don’t re-resolve against an evolving width/height
  // while other properties (e.g., width) are simultaneously animating.
  return CSSTransformMixin.resolveTransformForAnimation(value, renderStyle);
}

String _stringifyTransform(Matrix4 value) {
  return value.cssText();
}

Matrix4 _updateTransform(TransformAnimationValue begin, TransformAnimationValue end, double t, String property,
    CSSRenderStyle renderStyle) {
  // Resolve transform matrices dynamically on each tick so percentage-based
  // transforms (e.g., translateX(100%)) are evaluated against the element’s
  // current reference box while other properties (like width/left) are
  // simultaneously animating.
  Matrix4 beginMatrix = begin.frozenMatrix ?? (CSSMatrix.computeTransformMatrix(begin.value, renderStyle) ?? Matrix4.identity());
  Matrix4 endMatrix = end.frozenMatrix ?? (end.value == null
      ? Matrix4.identity()
      : (CSSMatrix.computeTransformMatrix(end.value, renderStyle) ?? Matrix4.identity()));

  Matrix4 newMatrix4 = CSSMatrix.lerpMatrix(beginMatrix, endMatrix, t);

  renderStyle.transformMatrix = newMatrix4;
  return newMatrix4;
}

CSSOrigin? _parseTransformOrigin(String value, RenderStyle renderStyle, String property) {
  return CSSOrigin.parseOrigin(value, renderStyle, property);
}

String _stringifyTransformOrigin(CSSOrigin value) {
  return 'CSSOrigin(${value.offset.dx},${value.offset.dy},${value.alignment.x},${value.alignment.y})';
}

CSSOrigin _updateTransformOrigin(CSSOrigin begin, CSSOrigin end, double progress, String property,
    CSSRenderStyle renderStyle) {
  Offset offset = begin.offset + (end.offset - begin.offset) * progress;
  Alignment alignment = begin.alignment + (end.alignment - begin.alignment) * progress;
  CSSOrigin result = CSSOrigin(offset, alignment);
  renderStyle.transformOrigin = result;
  return result;
}

const List<Function> _colorHandler = [_parseColor, _updateColor, _stringifyColor];
const List<Function> _lengthHandler = [_parseLength, _updateLength, _stringifyLength];
const List<Function> _borderLengthHandler = [_parseBorderLength, _updateBorderLength, _stringifyBorderLength];
const List<Function> _fontWeightHandler = [_parseFontWeight, _updateFontWeight, _stringifyFontWeight];
const List<Function> _numberHandler = [_parseNumber, _updateNumber, _stringifyNumber];
const List<Function> _lineHeightHandler = [_parseLineHeight, _updateLineHeight, _stringifyLineHeight];
const List<Function> _transformHandler = [_parseTransform, _updateTransform, _stringifyTransform];
const List<Function> _transformOriginHandler = [
  _parseTransformOrigin,
  _updateTransformOrigin,
  _stringifyTransformOrigin
];

// box-shadow handler: parses "<shadow-list>" and interpolates per-layer.
List<CSSBoxShadow> _parseBoxShadowForTransition(String value, RenderStyle renderStyle, String property) {
  // Expand inline var(...) so transition keyframes see the same resolved
  // shadow lists as the normal computed style pipeline.
  String expanded = value;
  if (value.contains('var(')) {
    try {
      expanded = CSSWritingModeMixin.expandInlineVars(value, renderStyle, property);
    } catch (_) {}
  }

  final List<CSSBoxShadow>? parsed = CSSBoxShadow.parseBoxShadow(expanded, renderStyle, property);
  if (parsed == null) return const <CSSBoxShadow>[];
  // Use a fresh list so we don't accidentally mutate cached instances.
  return List<CSSBoxShadow>.from(parsed);
}

String _stringifyBoxShadowForTransition(List<CSSBoxShadow> shadows) {
  if (shadows.isEmpty) return NONE;

  final List<String> layers = <String>[];
  for (final CSSBoxShadow shadow in shadows) {
    layers.add(shadow.cssText());
  }

  // getShadowValues() reverses layers for internal storage; reverse again
  // here so round-tripping through parse -> stringify -> parse preserves
  // the same internal ordering.
  return layers.reversed.join(', ');
}

List<CSSBoxShadow> _updateBoxShadowForTransition(
    List<CSSBoxShadow> begin, List<CSSBoxShadow> end, double progress, String property, CSSRenderStyle renderStyle) {
  if (begin.isEmpty && end.isEmpty) {
    renderStyle.target.setRenderStyleProperty(BOX_SHADOW, null);
    return const <CSSBoxShadow>[];
  }

  // When layer counts differ (e.g., from 'none' to a single shadow), treat
  // missing entries as transparent shadows with matching geometry so we can
  // smoothly fade them in/out instead of stepping at 50%.
  final int maxLen = begin.length > end.length ? begin.length : end.length;

  CSSLengthValue lerpLen(CSSLengthValue? a, CSSLengthValue? b) {
    final double av = a?.computedValue ?? 0.0;
    final double bv = b?.computedValue ?? 0.0;
    final double v = av * (1 - progress) + bv * progress;
    return CSSLengthValue(v, CSSLengthType.PX);
  }

  final List<CSSBoxShadow> result = <CSSBoxShadow>[];
  for (int i = 0; i < maxLen; i++) {
    CSSBoxShadow normalize(List<CSSBoxShadow> list, int index, {CSSBoxShadow? template, bool asTransparent = false}) {
      if (index < list.length) {
        final CSSBoxShadow s = list[index];
        if (!asTransparent) return s;
        final Color base = s.color ?? CSSColor.initial;
        return CSSBoxShadow(
          color: base.withAlpha(0),
          offsetX: s.offsetX ?? CSSLengthValue.zero,
          offsetY: s.offsetY ?? CSSLengthValue.zero,
          blurRadius: s.blurRadius ?? CSSLengthValue.zero,
          spreadRadius: s.spreadRadius ?? CSSLengthValue.zero,
          inset: s.inset,
        );
      }
      if (template != null) {
        final CSSBoxShadow t = template;
        final Color base = t.color ?? CSSColor.initial;
        return CSSBoxShadow(
          color: asTransparent ? base.withAlpha(0) : base,
          offsetX: t.offsetX ?? CSSLengthValue.zero,
          offsetY: t.offsetY ?? CSSLengthValue.zero,
          blurRadius: t.blurRadius ?? CSSLengthValue.zero,
          spreadRadius: t.spreadRadius ?? CSSLengthValue.zero,
          inset: t.inset,
        );
      }
      return CSSBoxShadow(
        color: (asTransparent ? CSSColor.transparent : CSSColor.initial),
        offsetX: CSSLengthValue.zero,
        offsetY: CSSLengthValue.zero,
        blurRadius: CSSLengthValue.zero,
        spreadRadius: CSSLengthValue.zero,
        inset: false,
      );
    }

    // Choose templates so that missing shadows on one side fade from/to
    // transparent versions of the opposite side's geometry.
    final CSSBoxShadow? template = (i < begin.length ? begin[i] : (i < end.length ? end[i] : null));
    final CSSBoxShadow sb =
        normalize(begin, i, template: template, asTransparent: begin.isEmpty || i >= begin.length);
    final CSSBoxShadow se =
        normalize(end, i, template: template, asTransparent: end.isEmpty || i >= end.length);

    final Color fromColor = sb.color ?? CSSColor.initial;
    final Color toColor = se.color ?? CSSColor.initial;
    final Color color = Color.lerp(fromColor, toColor, progress) ?? toColor;

    final bool inset =
        (sb.inset == se.inset) ? sb.inset : (progress < 0.5 ? sb.inset : se.inset);

    result.add(CSSBoxShadow(
      color: color,
      offsetX: lerpLen(sb.offsetX, se.offsetX),
      offsetY: lerpLen(sb.offsetY, se.offsetY),
      blurRadius: lerpLen(sb.blurRadius, se.blurRadius),
      spreadRadius: lerpLen(sb.spreadRadius, se.spreadRadius),
      inset: inset,
    ));
  }

  renderStyle.target.setRenderStyleProperty(BOX_SHADOW, result);
  return result;
}

// background-size handler: parses "<bg-size>" and interpolates width/height when numeric/percentage.
CSSBackgroundSize _parseBackgroundSize(String value, RenderStyle renderStyle, String property) {
  return CSSBackground.resolveBackgroundSize(value, renderStyle, property);
}

String _stringifyBackgroundSize(CSSBackgroundSize size) {
  return size.cssText();
}

CSSBackgroundSize _updateBackgroundSize(CSSBackgroundSize begin, CSSBackgroundSize end, double progress,
    String property, CSSRenderStyle renderStyle) {
  // If either uses a non-numeric fit (cover/contain/none mismatch), fallback to step at half.
  final BoxFit fb = begin.fit;
  final BoxFit fe = end.fit;
  if (fb != BoxFit.none || fe != BoxFit.none) {
    // Only interpolate numeric sizes when both are none; else step.
    final CSSBackgroundSize chosen = progress < 0.5 ? begin : end;
    renderStyle.target.setRenderStyleProperty(BACKGROUND_SIZE, chosen);
    // Do not write to inline style during transitions to avoid reentrancy.
    return chosen;
  }

  CSSLengthValue? lerpLen(CSSLengthValue? a, CSSLengthValue? b, bool isX) {
    if (a == null && b == null) return null;
    if (a == null || b == null) return progress < 0.5 ? a : b;
    // When both percentages, interpolate the percent.
    if (a.type == CSSLengthType.PERCENTAGE && b.type == CSSLengthType.PERCENTAGE) {
      final double av = a.value ?? 0;
      final double bv = b.value ?? 0;
      final double v = av * (1 - progress) + bv * progress;
      return CSSLengthValue(v, CSSLengthType.PERCENTAGE, renderStyle, BACKGROUND_SIZE, isX ? Axis.horizontal : Axis.vertical);
    }
    // When both absolute lengths, lerp in px.
    if (a.type != CSSLengthType.PERCENTAGE && b.type != CSSLengthType.PERCENTAGE) {
      final double av = a.computedValue;
      final double bv = b.computedValue;
      final double v = av * (1 - progress) + bv * progress;
      return CSSLengthValue(v, CSSLengthType.PX);
    }
    // Mixed types: fallback to step.
    return progress < 0.5 ? a : b;
  }

  final CSSLengthValue? w = lerpLen(begin.width, end.width, true);
  final CSSLengthValue? h = lerpLen(begin.height, end.height, false);
  final CSSBackgroundSize result = CSSBackgroundSize(fit: BoxFit.none, width: w, height: h);

  renderStyle.target.setRenderStyleProperty(BACKGROUND_SIZE, result);
  return result;
}

// background-position handler: parses "<pos-x> <pos-y>" and interpolates per-axis.
List<CSSBackgroundPosition> _parseBackgroundPosition(String value, RenderStyle renderStyle, String property) {
  final List<String> pair = CSSPosition.parsePositionShorthand(value);
  final CSSBackgroundPosition x = CSSPosition.resolveBackgroundPosition(
      pair[0], renderStyle, BACKGROUND_POSITION_X, true);
  final CSSBackgroundPosition y = CSSPosition.resolveBackgroundPosition(
      pair[1], renderStyle, BACKGROUND_POSITION_Y, false);
  return [x, y];
}

String _stringifyBackgroundPosition(List<CSSBackgroundPosition> pair) {
  final x = pair[0];
  final y = pair[1];
  return '${x.cssText()} ${y.cssText()}';
}

List<CSSBackgroundPosition> _updateBackgroundPosition(List<CSSBackgroundPosition> begin,
    List<CSSBackgroundPosition> end,
    double progress,
    String property,
    CSSRenderStyle renderStyle) {
  CSSBackgroundPosition lerpOne(CSSBackgroundPosition a, CSSBackgroundPosition b, bool isX) {
    // Prefer numeric interpolation when both sides are numeric (length/calc).
    final String axisProperty = isX ? BACKGROUND_POSITION_X : BACKGROUND_POSITION_Y;
    final bool aNumeric = a.length != null || a.calcValue != null;
    final bool bNumeric = b.length != null || b.calcValue != null;
    if (aNumeric && bNumeric) {
      double ax = a.length != null
          ? a.length!.computedValue
          : (a.calcValue!.computedValue(axisProperty) ?? 0);
      double bx = b.length != null
          ? b.length!.computedValue
          : (b.calcValue!.computedValue(axisProperty) ?? 0);
      final double v = ax * (1 - progress) + bx * progress;
      return CSSBackgroundPosition(length: CSSLengthValue(v, CSSLengthType.PX));
    }
    // Percentage interpolation when both are percentages.
    if (a.percentage != null && b.percentage != null) {
      final double v = a.percentage! * (1 - progress) + b.percentage! * progress;
      return CSSBackgroundPosition(percentage: v);
    }
    // Mixed types: fallback to step at half.
    return progress < 0.5 ? a : b;
  }

  final CSSBackgroundPosition x = lerpOne(begin[0], end[0], true);
  final CSSBackgroundPosition y = lerpOne(begin[1], end[1], false);

  // Update render style longhands to drive painting.
  renderStyle.target.setRenderStyleProperty(BACKGROUND_POSITION_X, x);
  renderStyle.target.setRenderStyleProperty(BACKGROUND_POSITION_Y, y);

  return [x, y];
}

// background-position-x/y handlers for cases where keyframes use longhands
CSSBackgroundPosition _parseBackgroundPositionX(String value, RenderStyle renderStyle, String property) {
  return CSSPosition.resolveBackgroundPosition(value, renderStyle, BACKGROUND_POSITION_X, true);
}

CSSBackgroundPosition _parseBackgroundPositionY(String value, RenderStyle renderStyle, String property) {
  return CSSPosition.resolveBackgroundPosition(value, renderStyle, BACKGROUND_POSITION_Y, false);
}

String _stringifyBackgroundPositionAxis(CSSBackgroundPosition pos) {
  return pos.cssText();
}

CSSBackgroundPosition _lerpBackgroundPositionAxis(CSSBackgroundPosition a, CSSBackgroundPosition b, double progress,
    bool isX) {
  final String axisProperty = isX ? BACKGROUND_POSITION_X : BACKGROUND_POSITION_Y;
  final bool aNumeric = a.length != null || a.calcValue != null;
  final bool bNumeric = b.length != null || b.calcValue != null;
  if (aNumeric && bNumeric) {
    double av = a.length != null ? a.length!.computedValue : (a.calcValue!.computedValue(axisProperty) ?? 0);
    double bv = b.length != null ? b.length!.computedValue : (b.calcValue!.computedValue(axisProperty) ?? 0);
    final double v = av * (1 - progress) + bv * progress;
    return CSSBackgroundPosition(length: CSSLengthValue(v, CSSLengthType.PX));
  }
  if (a.percentage != null && b.percentage != null) {
    final double v = a.percentage! * (1 - progress) + b.percentage! * progress;
    return CSSBackgroundPosition(percentage: v);
  }
  return progress < 0.5 ? a : b;
}

CSSBackgroundPosition _updateBackgroundPositionX(CSSBackgroundPosition begin, CSSBackgroundPosition end,
    double progress, String property, CSSRenderStyle renderStyle) {
  final CSSBackgroundPosition x = _lerpBackgroundPositionAxis(begin, end, progress, true);
  renderStyle.target.setRenderStyleProperty(BACKGROUND_POSITION_X, x);
  return x;
}

CSSBackgroundPosition _updateBackgroundPositionY(CSSBackgroundPosition begin, CSSBackgroundPosition end,
    double progress, String property, CSSRenderStyle renderStyle) {
  final CSSBackgroundPosition y = _lerpBackgroundPositionAxis(begin, end, progress, false);
  renderStyle.target.setRenderStyleProperty(BACKGROUND_POSITION_Y, y);
  return y;
}

Map<String, List<Function>> cssTransitionHandlers = {
  COLOR: _colorHandler,
  BACKGROUND_COLOR: _colorHandler,
  BACKGROUND_POSITION: [_parseBackgroundPosition, _updateBackgroundPosition, _stringifyBackgroundPosition],
  BACKGROUND_POSITION_X: [_parseBackgroundPositionX, _updateBackgroundPositionX, _stringifyBackgroundPositionAxis],
  BACKGROUND_POSITION_Y: [_parseBackgroundPositionY, _updateBackgroundPositionY, _stringifyBackgroundPositionAxis],
  BACKGROUND_SIZE: [_parseBackgroundSize, _updateBackgroundSize, _stringifyBackgroundSize],
  BOX_SHADOW: [_parseBoxShadowForTransition, _updateBoxShadowForTransition, _stringifyBoxShadowForTransition],
  BORDER_BOTTOM_COLOR: _colorHandler,
  BORDER_LEFT_COLOR: _colorHandler,
  BORDER_RIGHT_COLOR: _colorHandler,
  BORDER_TOP_COLOR: _colorHandler,
  BORDER_COLOR: _colorHandler,
  TEXT_DECORATION_COLOR: _colorHandler,
  OPACITY: _numberHandler,
  Z_INDEX: _numberHandler,
  FLEX_GROW: _numberHandler,
  FLEX_SHRINK: _numberHandler,
  FONT_WEIGHT: _fontWeightHandler,
  LINE_HEIGHT: _lineHeightHandler,
  TRANSFORM: _transformHandler,
  TRANSFORM_ORIGIN: _transformOriginHandler,
  BORDER_BOTTOM_LEFT_RADIUS: _borderLengthHandler,
  BORDER_BOTTOM_RIGHT_RADIUS: _borderLengthHandler,
  BORDER_TOP_LEFT_RADIUS: _borderLengthHandler,
  BORDER_TOP_RIGHT_RADIUS: _borderLengthHandler,
  RIGHT: _lengthHandler,
  TOP: _lengthHandler,
  BOTTOM: _lengthHandler,
  LEFT: _lengthHandler,
  LETTER_SPACING: _lengthHandler,
  MARGIN_BOTTOM: _lengthHandler,
  MARGIN_LEFT: _lengthHandler,
  MARGIN_RIGHT: _lengthHandler,
  MARGIN_TOP: _lengthHandler,
  MIN_HEIGHT: _lengthHandler,
  MIN_WIDTH: _lengthHandler,
  PADDING_BOTTOM: _lengthHandler,
  PADDING_LEFT: _lengthHandler,
  PADDING_RIGHT: _lengthHandler,
  PADDING_TOP: _lengthHandler,
  // should non negative value
  BORDER_BOTTOM_WIDTH: _lengthHandler,
  BORDER_LEFT_WIDTH: _lengthHandler,
  BORDER_RIGHT_WIDTH: _lengthHandler,
  BORDER_TOP_WIDTH: _lengthHandler,
  FLEX_BASIS: _lengthHandler,
  FONT_SIZE: _lengthHandler,
  HEIGHT: _lengthHandler,
  WIDTH: _lengthHandler,
  MAX_HEIGHT: _lengthHandler,
  MAX_WIDTH: _lengthHandler,
};

/// The types of TransitionEvent
enum CSSTransitionEvent {
  /// The transitionrun event occurs when a transition is created
  run,

  /// The transitionstart event occurs when a transition’s delay phase ends.
  start,

  /// The transitionend event occurs at the completion of the transition.
  end,

  /// The transitioncancel event occurs when a transition is canceled.
  cancel,
}

mixin CSSTransitionMixin on RenderStyle {
  // Map longhand properties to their canonical transition key so that
  // a shorthand like `background-position` drives transitions for
  // `background-position-x`/`-y` changes.
  static String _canonicalTransitionKey(String property) {
    switch (property) {
      case BACKGROUND_POSITION_X:
      case BACKGROUND_POSITION_Y:
        return BACKGROUND_POSITION;
      // Border colors → border-color shorthand
      case BORDER_TOP_COLOR:
      case BORDER_RIGHT_COLOR:
      case BORDER_BOTTOM_COLOR:
      case BORDER_LEFT_COLOR:
        return BORDER_COLOR;
      // Border widths → border-width shorthand
      case BORDER_TOP_WIDTH:
      case BORDER_RIGHT_WIDTH:
      case BORDER_BOTTOM_WIDTH:
      case BORDER_LEFT_WIDTH:
        return BORDER_WIDTH;
      // Border styles → border-style shorthand
      case BORDER_TOP_STYLE:
      case BORDER_RIGHT_STYLE:
      case BORDER_BOTTOM_STYLE:
      case BORDER_LEFT_STYLE:
        return BORDER_STYLE;
      // Border radii → border-radius shorthand
      case BORDER_TOP_LEFT_RADIUS:
      case BORDER_TOP_RIGHT_RADIUS:
      case BORDER_BOTTOM_RIGHT_RADIUS:
      case BORDER_BOTTOM_LEFT_RADIUS:
        return BORDER_RADIUS;
      // Padding longhands → padding shorthand
      case PADDING_LEFT:
      case PADDING_RIGHT:
      case PADDING_TOP:
      case PADDING_BOTTOM:
        return 'padding';
      // Margin longhands → margin shorthand
      case MARGIN_LEFT:
      case MARGIN_RIGHT:
      case MARGIN_TOP:
      case MARGIN_BOTTOM:
        return 'margin';
      default:
        return property;
    }
  }
  // https://drafts.csswg.org/css-transitions/#transition-property-property
  // Name: transition-property
  // Value: none | <single-transition-property>#
  // Initial: all
  // Applies to: all elements
  // Inherited: no
  // Percentages: N/A
  // Computed value: the keyword none else a list of identifiers
  // Canonical order: per grammar
  // Animation type: not animatable
  List<String>? _transitionProperty;

  set transitionProperty(List<String>? value) {
    _transitionProperty = value;
    _effectiveTransitions = null;
    // https://github.com/WebKit/webkit/blob/master/Source/WebCore/animation/AnimationTimeline.cpp#L257
    // Any animation found in previousAnimations but not found in newAnimations is not longer current and should be canceled.
    // @HACK: There are no way to get animationList from styles(Webkit will create an new Style object when style changes, but Kraken not).
    // Therefore we should cancel all running transition to get thing works.
    finishRunningTransition();
  }

  @override
  List<String> get transitionProperty => _transitionProperty ?? const [ALL];

  // https://drafts.csswg.org/css-transitions/#transition-duration-property
  // Name: transition-duration
  // Value: <time>#
  // Initial: 0s
  // Applies to: all elements
  // Inherited: no
  // Percentages: N/A
  // Computed value: list, each item a duration
  // Canonical order: per grammar
  // Animation type: not animatable
  List<String>? _transitionDuration;

  set transitionDuration(List<String>? value) {
    _transitionDuration = value;
    _effectiveTransitions = null;
  }

  @override
  List<String> get transitionDuration => _transitionDuration ?? const [_zeroSeconds];

  // https://drafts.csswg.org/css-transitions/#transition-timing-function-property
  // Name: transition-timing-function
  // Value: <easing-function>#
  // Initial: ease
  // Applies to: all elements
  // Inherited: no
  // Percentages: N/A
  // Computed value: as specified
  // Canonical order: per grammar
  // Animation type: not animatable
  List<String>? _transitionTimingFunction;

  set transitionTimingFunction(List<String>? value) {
    _transitionTimingFunction = value;
    _effectiveTransitions = null;
  }

  @override
  List<String> get transitionTimingFunction => _transitionTimingFunction ?? const [EASE];

  // https://drafts.csswg.org/css-transitions/#transition-delay-property
  // Name: transition-delay
  // Value: <time>#
  // Initial: 0s
  // Applies to: all elements
  // Inherited: no
  // Percentages: N/A
  // Computed value: list, each item a duration
  // Canonical order: per grammar
  // Animation type: not animatable
  List<String>? _transitionDelay;

  set transitionDelay(List<String>? value) {
    _transitionDelay = value;
    _effectiveTransitions = null;
  }

  @override
  List<String> get transitionDelay => _transitionDelay ?? const [_zeroSeconds];

  Map<String, List>? _effectiveTransitions;

  Map<String, List> get effectiveTransitions {
    if (_effectiveTransitions != null) return _effectiveTransitions!;
    Map<String, List> transitions = {};

    for (int i = 0; i < transitionProperty.length; i++) {
      String property = camelize(transitionProperty[i]);
      String duration = transitionDuration.length == 1 ? transitionDuration[0] : transitionDuration[i];
      String function =
      transitionTimingFunction.length == 1 ? transitionTimingFunction[0] : transitionTimingFunction[i];
      String delay = transitionDelay.length == 1 ? transitionDelay[0] : transitionDelay[i];
      transitions[property] = [duration, function, delay];
    }
    return _effectiveTransitions = transitions;
  }

  bool shouldTransition(String property, String? prevValue, String nextValue) {
    if (DebugFlags.shouldLogTransitionForProp(property)) {
      cssLogger.info('[transition][check] property=$property prev=${prevValue ?? 'null'} next=$nextValue');
    }

    // Custom properties (CSS variables) are not animatable. Their changes may
    // indirectly drive transitions on animatable properties (e.g., transform)
    // via the CSSVariableMixin path. Skip here to avoid confusing logs.
    if (CSSVariable.isCSSSVariableProperty(property)) {
      return false;
    }
    // When begin propertyValue is AUTO, skip animation and trigger style update directly.
    prevValue = (prevValue == null || prevValue.isEmpty) ? cssInitialValues[property] : prevValue;
    // If the serialized values are identical, skip scheduling here. Var-driven
    // changes may be handled by the CSSVariableMixin path that schedules a
    // transition with an explicit prev substitution.
    if (prevValue == nextValue) {
      if (DebugFlags.shouldLogTransitionForProp(property)) {
        cssLogger.info('[transition][check] property=$property skip: same-serialized');
      }
      return false;
    }
    if (CSSLength.isAuto(prevValue) || CSSLength.isAuto(nextValue)) {
      if (DebugFlags.shouldLogTransitionForProp(property)) {
        cssLogger.info('[transition][check] property=$property skip: auto');
      }
      return false;
    }

    // Transition does not work when renderBoxModel has not been layout yet
    // or when we don't have a transition handler for this property.
    final bool hasRenderBoxModel = hasRenderBox();
    final bool hasBoxSize = isBoxModelHaveSize();
    final bool hasHandler = cssTransitionHandlers[property] != null;

    if (!hasRenderBoxModel || !hasBoxSize || !hasHandler) {
      if (DebugFlags.shouldLogTransitionForProp(property)) {
        final String reason;
        if (!hasRenderBoxModel || !hasBoxSize) {
          reason = 'no-layout (hasRenderBox=$hasRenderBoxModel hasSize=$hasBoxSize)';
        } else {
          reason = 'no-handler';
        }
        cssLogger.info('[transition][check] property=$property skip: $reason');
      }
      return false;
    }

    final String key = _canonicalTransitionKey(property);
    final bool configured = effectiveTransitions.containsKey(key) || effectiveTransitions.containsKey(ALL);
    if (!configured) {
      if (DebugFlags.shouldLogTransitionForProp(property)) {
        cssLogger
            .info('[transition][check] property=$property skip: not-configured (key=$key)');
      }
      return false;
    }
    if (DebugFlags.shouldLogTransitionForProp(property)) {
      final List? opts = effectiveTransitions[key] ?? effectiveTransitions[ALL];
      cssLogger.info(
          '[transition][check] property=$property key=$key opts=${opts != null ? '{duration: ${opts[0]}, easing: ${opts[1]}, delay: ${opts[2]}}' : 'null'}');
    }
    bool shouldTransition = false;
    // Transition will be disabled when all transition has transitionDuration as 0.
    effectiveTransitions.forEach((String transitionKey, List transitionOptions) {
      int? duration = CSSTime.parseTime(transitionOptions[0]);
      if (duration != null && duration != 0) {
        shouldTransition = true;
      }
    });
    if (DebugFlags.shouldLogTransitionForProp(property)) {
      cssLogger.info(
          '[transition][check] property=$property configured key=$key result=$shouldTransition');
    }
    return shouldTransition;
  }

  final Map<String, Animation> _propertyRunningTransition = {};

  bool _hasRunningTransition(String property) {
    return _propertyRunningTransition.containsKey(property);
  }

  // Public guard for other subsystems (layout/transform) to query whether a
  // transition for a given property is currently running. Avoids clobbering
  // animation-driven interim values during layout invalidations.
  bool isTransitionRunning(String property) {
    return _propertyRunningTransition.containsKey(property);
  }

  void runTransition(String propertyName, begin, end) {
    if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
      cssLogger.info('[transition][run] property=$propertyName begin=${begin ?? 'null'} end=$end');
    }

    // For box-shadow, prefer the current computed shadow list as the
    // transition begin value when the previous CSS text is var()-based.
    // This avoids snapping when variables are updated before the
    // shorthand (e.g., Tailwind's --tw-shadow patterns).
    if (propertyName == BOX_SHADOW && begin is String && begin.contains('var(')) {
      final dynamic current = getProperty(propertyName);
      if (current is List<CSSBoxShadow> && current.isNotEmpty) {
        try {
          begin = _stringifyBoxShadowForTransition(current);
          if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
            cssLogger.info('[transition][run] property=$propertyName override-begin-from-computed "$begin"');
          }
        } catch (_) {
          // Fallback to string-based begin if serialization fails.
        }
      }
    }
    if (_hasRunningTransition(propertyName)) {
      Animation animation = _propertyRunningTransition[propertyName]!;
      if (cssTransitionHandlers.containsKey(propertyName) && animation.effect is KeyframeEffect) {
        KeyframeEffect effect = animation.effect as KeyframeEffect;
        var interpolation = effect.interpolations.firstWhere((interpolation) => interpolation.property == propertyName);
        var stringifyFunc = cssTransitionHandlers[propertyName]![2];
        // Matrix4 begin, Matrix4 end, double t, String property, CSSRenderStyle renderStyle
        begin = stringifyFunc(
            interpolation.lerp(interpolation.begin, interpolation.end, animation.progress, propertyName, this));
      }

      if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
        cssLogger.info('[transition][run] cancel-existing property=$propertyName progress=${animation.progress.toStringAsFixed(3)}');
      }
      animation.cancel();
      // An Event fired when a CSS transition has been cancelled.
      target.dispatchEvent(Event(EVENT_TRANSITION_CANCEL));
    }

    if (begin == null || (begin is String && begin.isEmpty)) {
      begin = cssInitialValues[propertyName] ?? '';
      if (begin == CURRENT_COLOR) {
        begin = currentColor;
      }
    }

    if (end == null || (end is String && end.isEmpty)) {
      end = cssInitialValues[propertyName] ?? '';
    }

    // Keyframe.value is typed as String; ensure our transition endpoints
    // are always serialized strings before constructing keyframes.
    if (begin is! String) {
      begin = begin.toString();
    }
    if (end is! String) {
      end = end.toString();
    }

    EffectTiming? options = getTransitionEffectTiming(propertyName);

    // Fallback: if effective duration is 0, apply end immediately rather than
    // creating a no-op animation that never fires finish.
    final double durationMs = options?.duration ?? 0;
    if (durationMs <= 0) {
      if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
        cssLogger.info('[transition][run] property=$propertyName duration=0; direct-apply "$end"');
      }
      target.setRenderStyle(propertyName, end);
      return;
    }

    List<Keyframe> keyframes = [
      Keyframe(propertyName, begin, 0, LINEAR),
      Keyframe(propertyName, end, 1, LINEAR),
    ];
    KeyframeEffect effect = KeyframeEffect(this, keyframes, options, isTransition: true);
    Animation animation = Animation(effect, target.ownerDocument.animationTimeline);
    _propertyRunningTransition[propertyName] = animation;

    animation.onstart = () {
      // An Event fired when a CSS transition is created,
      // when it is added to a set of running transitions,
      // though not necessarily started.
      target.dispatchEvent(TransitionEvent(
        EVENT_TRANSITION_START,
        propertyName: _toHyphenatedCSSProperty(propertyName),
        elapsedTime: 0.0,
      ));
    };

    animation.onfinish = (AnimationPlaybackEvent event) {
      _propertyRunningTransition.remove(propertyName);
      target.setRenderStyle(propertyName, end);
      // An Event fired when a CSS transition has finished playing.
      if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
        cssLogger.info('[transition][finish] property=$propertyName applied-end "$end"');
      }
      // elapsedTime is the time the transition has run, in seconds,
      // excluding any transition-delay. Our EffectTiming stores duration
      // in milliseconds.
      final double durationMs = options?.duration ?? 0.0;
      final double elapsedSec = durationMs > 0 ? durationMs / 1000.0 : 0.0;
      target.dispatchEvent(TransitionEvent(
        EVENT_TRANSITION_END,
        propertyName: _toHyphenatedCSSProperty(propertyName),
        elapsedTime: elapsedSec,
      ));
    };

    // For transitionrun, elapsedTime is always 0.
    target.dispatchEvent(TransitionEvent(
      EVENT_TRANSITION_RUN,
      propertyName: _toHyphenatedCSSProperty(propertyName),
      elapsedTime: 0.0,
    ));
    if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
      cssLogger.info('[transition][run] play property=$propertyName duration=${options?.duration} easing=${options?.easing} delay=${options?.delay}');
    }

    animation.play();
  }

  void cancelRunningTransition() {
    if (_propertyRunningTransition.isNotEmpty) {
      final List<String> props = _propertyRunningTransition.keys.toList();
      for (final String prop in props) {
        final Animation? animation = _propertyRunningTransition.remove(prop);
        if (animation != null) {
          if (DebugFlags.shouldLogTransitionForProp(prop)) {
            cssLogger.info('[transition][cancel] property=$prop (bulk)');
          }
          animation.cancel();
        }
        // After cancel, re-apply the current computed property value to ensure
        // any animation-driven value is cleared immediately. The property
        // setter should clear any cached animation state when re-applying.
        final String computed = target.style.getPropertyValue(prop);
        target.setRenderStyle(prop, computed);
      }
    }
  }

  // Cancel a running transition for a specific property, if any.
  // Dispatches a transitioncancel event to mirror runTransition()'s cancel path.
  void cancelTransitionFor(String propertyName) {
    final Animation? animation = _propertyRunningTransition.remove(propertyName);
    if (animation != null) {
      if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
        cssLogger.info('[transition][cancel] property=$propertyName');
      }
      // Compute elapsedTime at cancel as progress * duration (in seconds),
      // excluding any transition-delay.
      double elapsedSec = 0.0;
      final EffectTiming? options = getTransitionEffectTiming(propertyName);
      final double durationMs = options?.duration ?? 0.0;
      if (durationMs > 0) {
        try {
          elapsedSec = (animation.progress * durationMs) / 1000.0;
        } catch (_) {
          elapsedSec = 0.0;
        }
      }
      animation.cancel();
      // Align with runTransition() which explicitly fires transitioncancel on cancel.
      target.dispatchEvent(TransitionEvent(
        EVENT_TRANSITION_CANCEL,
        propertyName: _toHyphenatedCSSProperty(propertyName),
        elapsedTime: elapsedSec,
      ));
    }
  }

  void finishRunningTransition() {
    if (_propertyRunningTransition.isNotEmpty) {
      for (String property in _propertyRunningTransition.keys) {
        _propertyRunningTransition[property]!.finish();
      }
      _propertyRunningTransition.clear();
    }
  }

  EffectTiming? getTransitionEffectTiming(String property) {
    final String key = _canonicalTransitionKey(property);
    List? transitionOptions = effectiveTransitions[key] ?? effectiveTransitions[ALL];
    // [duration, function, delay]
    if (transitionOptions != null) {
      final EffectTiming timing = EffectTiming(
        duration: CSSTime.parseNotNegativeTime(transitionOptions[0])!.toDouble(),
        easing: transitionOptions[1],
        delay: CSSTime.parseTime(transitionOptions[2])!.toDouble(),
        // In order for CSS Transitions to be seeked backwards, they need to have their fill mode set to backwards
        // such that the original CSS value applied prior to the transition is used for a negative current time.
        fill: FillMode.backwards,
      );
      if (DebugFlags.shouldLogTransitionForProp(property)) {
        cssLogger.info('[transition][opts] property=$property key=$key duration=${timing.duration} easing=${timing.easing} delay=${timing.delay}');
      }
      return timing;
    }

    return null;
  }

  static bool isValidTransitionPropertyValue(String value) {
    return value == ALL || value == NONE || CSSTextual.isCustomIdent(value);
  }

  static bool isValidTransitionTimingFunctionValue(String value) {
    return value == LINEAR ||
        value == EASE ||
        value == EASE_IN ||
        value == EASE_OUT ||
        value == EASE_IN_OUT ||
        value == STEP_END ||
        value == STEP_START ||
        CSSFunction.isFunction(value);
  }

  // No-op placeholder for future property-specific cancel cleanup hooks.
}

class CSSStepCurve extends Curve {
  final int? step;
  final bool isStart;

  const CSSStepCurve(this.step, this.isStart);

  @override
  double transformInternal(double t) {
    int addition = 0;
    if (!isStart) {
      addition = 1;
    }

    int cur = (t * step!).floor();
    cur = cur + addition;

    return cur / step!;
  }
}

// Convert an internal camelCase property key (e.g., "backgroundColor")
// to the standard CSS hyphenated form used in TransitionEvent.propertyName
// (e.g., "background-color"). If the string already contains a hyphen, it is
// returned as-is.
String _toHyphenatedCSSProperty(String property) {
  if (property.contains('-')) return property;
  final StringBuffer sb = StringBuffer();
  for (int i = 0; i < property.length; i++) {
    final int code = property.codeUnitAt(i);
    final bool isUpper = code >= 65 && code <= 90; // 'A'..'Z'
    if (isUpper) {
      if (i != 0) sb.write('-');
      sb.writeCharCode(code + 32); // to lowercase
    } else {
      sb.writeCharCode(code);
    }
  }
  return sb.toString();
}
