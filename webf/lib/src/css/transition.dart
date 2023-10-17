/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart' show Curve;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';

// CSS Transitions: https://drafts.csswg.org/css-transitions/
const String _0s = '0s';

Color? _parseColor(String color, RenderStyle renderStyle, String propertyName) {
  return CSSColor.resolveColor(color, renderStyle, propertyName)?.value;
}

String _stringifyColor(Color color) {
  return CSSColor(color).cssText();
}

Color _updateColor(Color oldColor, Color newColor, double progress, String property, RenderStyle renderStyle) {
  Color? result = Color.lerp(oldColor, newColor, progress);
  renderStyle.target.setRenderStyleProperty(property, CSSColor(result!));
  return result;
}

double _parseLength(String length, RenderStyle renderStyle, String property) {
  return CSSLength.parseLength(length, renderStyle, property).computedValue;
}

String _stringifyLength(double value) {
  return '${value}px';
}

double _updateLength(
    double oldLengthValue, double newLengthValue, double progress, String property, CSSRenderStyle renderStyle) {
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

CSSBorderRadius? _updateBorderLength(
    CSSBorderRadius startRadius, CSSBorderRadius endRadius, double progress, String property, CSSRenderStyle renderStyle) {
  Radius? radius = Radius.lerp(startRadius.computedRadius, endRadius.computedRadius, progress);
  if (radius != null) {
    CSSLengthValue oldX = startRadius.x;
    CSSLengthValue oldY = startRadius.y;
    CSSLengthValue newX = CSSLength.parseLength(_stringifyLength(radius.x), oldX.renderStyle, oldX.propertyName, oldX.axisType);
    CSSLengthValue newY = CSSLength.parseLength(_stringifyLength(radius.y), oldY.renderStyle, oldY.propertyName, oldY.axisType);
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

FontWeight _updateFontWeight(
    FontWeight oldValue, FontWeight newValue, double progress, String property, CSSRenderStyle renderStyle) {
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
  return CSSLength.parseLength(lineHeight, renderStyle, LINE_HEIGHT).computedValue;
}

String _stringifyLineHeight(CSSLengthValue lineNumber) {
  return '${lineNumber.value}px';
}

CSSLengthValue _updateLineHeight(double oldValue, double newValue, double progress, String property, CSSRenderStyle renderStyle) {
  CSSLengthValue lengthValue = CSSLengthValue(_getNumber(oldValue, newValue, progress), CSSLengthType.PX);
  renderStyle.lineHeight = lengthValue;
  return lengthValue;
}

TransformAnimationValue _parseTransform(String value, RenderStyle renderStyle, String property) {
  return CSSTransformMixin.resolveTransformForAnimation(value);
}

String _stringifyTransform(Matrix4 value) {
  return value.cssText();
}

Matrix4 _updateTransform(TransformAnimationValue begin, TransformAnimationValue end, double t, String property, CSSRenderStyle renderStyle) {
  var beginMatrix = CSSMatrix.computeTransformMatrix(begin.value, renderStyle);
  var endMatrix = CSSMatrix.computeTransformMatrix(end.value, renderStyle);

  if (!renderStyle.renderBoxModel!.isRepaintBoundary) {
    renderStyle.target.updateRenderBoxModel();
  }

  if (beginMatrix != null && endMatrix != null) {
    Matrix4 newMatrix4 = CSSMatrix.lerpMatrix(beginMatrix, endMatrix, t);
    renderStyle.transformMatrix = newMatrix4;
    return newMatrix4;
  }

  return Matrix4.identity();
}

CSSOrigin? _parseTransformOrigin(String value, RenderStyle renderStyle, String property) {
  return CSSOrigin.parseOrigin(value, renderStyle, property);
}

String _stringifyTransformOrigin(CSSOrigin value) {
  return 'CSSOrigin(${value.offset.dx},${value.offset.dy},${value.alignment.x},${value.alignment.y})';
}

CSSOrigin _updateTransformOrigin(
    CSSOrigin begin, CSSOrigin end, double progress, String property, CSSRenderStyle renderStyle) {
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
const List<Function> _transformOriginHandler = [_parseTransformOrigin, _updateTransformOrigin, _stringifyTransformOrigin];

Map<String, List<Function>> CSSTransitionHandlers = {
  COLOR: _colorHandler,
  BACKGROUND_COLOR: _colorHandler,
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
  List<String> get transitionDuration => _transitionDuration ?? const [_0s];

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
  List<String> get transitionDelay => _transitionDelay ?? const [_0s];

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
    // When begin propertyValue is AUTO, skip animation and trigger style update directly.
    prevValue = (prevValue == null || prevValue.isEmpty) ? CSSInitialValues[property] : prevValue;
    if (CSSLength.isAuto(prevValue) || CSSLength.isAuto(nextValue)) {
      return false;
    }

    // Transition does not work when renderBoxModel has not been layout yet.
    if (renderBoxModel != null &&
        renderBoxModel!.hasSize &&
        CSSTransitionHandlers[property] != null &&
        (effectiveTransitions.containsKey(property) || effectiveTransitions.containsKey(ALL))) {
      bool shouldTransition = false;
      // Transition will be disabled when all transition has transitionDuration as 0.
      effectiveTransitions.forEach((String transitionKey, List transitionOptions) {
        int? duration = CSSTime.parseTime(transitionOptions[0]);
        if (duration != null && duration != 0) {
          shouldTransition = true;
        }
      });
      return shouldTransition;
    }
    return false;
  }

  final Map<String, Animation> _propertyRunningTransition = {};

  bool _hasRunningTransition(String property) {
    return _propertyRunningTransition.containsKey(property);
  }

  void runTransition(String propertyName, begin, end) {
    if (_hasRunningTransition(propertyName)) {
      Animation animation = _propertyRunningTransition[propertyName]!;
      if (CSSTransitionHandlers.containsKey(propertyName) && animation.effect is KeyframeEffect) {
        KeyframeEffect effect = animation.effect as KeyframeEffect;
        var interpolation = effect.interpolations.firstWhere((interpolation) => interpolation.property == propertyName);
        var stringifyFunc = CSSTransitionHandlers[propertyName]![2];
        // Matrix4 begin, Matrix4 end, double t, String property, CSSRenderStyle renderStyle
        begin = stringifyFunc(interpolation.lerp(interpolation.begin, interpolation.end, animation.progress, propertyName, this));
      }

      CSSTransitionHandlers[propertyName];

      animation.cancel();
      // An Event fired when a CSS transition has been cancelled.
      target.dispatchEvent(Event(EVENT_TRANSITION_CANCEL));
    }

    if (begin == null || (begin is String && begin.isEmpty)) {
      begin = CSSInitialValues[propertyName];
      if (begin == CURRENT_COLOR) {
        begin = currentColor;
      }
    }

    if (end is String && end.isEmpty) {
      end = CSSInitialValues[propertyName];
    }

    EffectTiming? options = getTransitionEffectTiming(propertyName);

    List<Keyframe> keyframes = [
      Keyframe(propertyName, begin, 0, LINEAR),
      Keyframe(propertyName, end, 1, LINEAR),
    ];
    KeyframeEffect effect = KeyframeEffect(this, target, keyframes, options);
    Animation animation = Animation(effect, target.ownerDocument.animationTimeline);
    _propertyRunningTransition[propertyName] = animation;

    animation.onstart = () {
      // An Event fired when a CSS transition is created,
      // when it is added to a set of running transitions,
      // though not necessarily started.
      target.dispatchEvent(Event(EVENT_TRANSITION_START));
    };

    animation.onfinish = (AnimationPlaybackEvent event) {
      _propertyRunningTransition.remove(propertyName);
      target.setRenderStyle(propertyName, end);
      // An Event fired when a CSS transition has finished playing.
      target.dispatchEvent(Event(EVENT_TRANSITION_END));
    };

    target.dispatchEvent(Event(EVENT_TRANSITION_RUN));

    animation.play();
  }

  void cancelRunningTransition() {
    if (_propertyRunningTransition.isNotEmpty) {
      for (Animation animation in _propertyRunningTransition.values) {
        animation.cancel();
      }
      _propertyRunningTransition.clear();
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
    List? transitionOptions = effectiveTransitions[property] ?? effectiveTransitions[ALL];
    // [duration, function, delay]
    if (transitionOptions != null) {
      return EffectTiming(
        duration: CSSTime.parseNotNegativeTime(transitionOptions[0])!.toDouble(),
        easing: transitionOptions[1],
        delay: CSSTime.parseTime(transitionOptions[2])!.toDouble(),
        // In order for CSS Transitions to be seeked backwards, they need to have their fill mode set to backwards
        // such that the original CSS value applied prior to the transition is used for a negative current time.
        fill: FillMode.backwards,
      );
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
}

class CSSStepCurve extends Curve {
  final int? step;
  final bool isStart;

  CSSStepCurve(this.step, this.isStart);

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
