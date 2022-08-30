import 'dart:ui';

import 'package:webf/css.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:webf/dom.dart';

// CSS Animation: https://drafts.csswg.org/css-animations/

const String EVENT_ANIMATION_CANCEL = 'animationcancel';
const String EVENT_ANIMATION_START = 'animationstart';
const String EVENT_ANIMATION_END = 'animationend';
const String EVENT_ANIMATION_ITERATION = 'animationiteration';

class AnimationEvent extends Event {
  AnimationEvent(String type,
      {String? animationName, double? elapsedTime, String? pseudoElement})
      : animationName = animationName ?? '',
        elapsedTime = elapsedTime ?? 0.0,
        pseudoElement = pseudoElement ?? '',
        super(type) {}

  String animationName;
  double elapsedTime;
  String pseudoElement;
}

const String _0s = '0s';

String _toCamelCase(String s) {
  var sb = StringBuffer();
  var shouldUpperCase = false;
  for (int rune in s.runes) {
    // '-' char code is 45
    if (rune == 45) {
      shouldUpperCase = true;
    } else {
      var char = String.fromCharCode(rune);
      if (shouldUpperCase) {
        sb.write(char.toUpperCase());
        shouldUpperCase = false;
      } else {
        sb.write(char);
      }
    }
  }

  return sb.toString();
}

Color? _parseColor(String color, RenderStyle renderStyle, String propertyName) {
  return CSSColor.resolveColor(color, renderStyle, propertyName);
}

void _updateColor(Color oldColor, Color newColor, double progress,
    String property, RenderStyle renderStyle) {
  int alphaDiff = newColor.alpha - oldColor.alpha;
  int redDiff = newColor.red - oldColor.red;
  int greenDiff = newColor.green - oldColor.green;
  int blueDiff = newColor.blue - oldColor.blue;

  int alpha = (alphaDiff * progress).toInt() + oldColor.alpha;
  int red = (redDiff * progress).toInt() + oldColor.red;
  int blue = (blueDiff * progress).toInt() + oldColor.blue;
  int green = (greenDiff * progress).toInt() + oldColor.green;
  Color color = Color.fromARGB(alpha, red, green, blue);

  renderStyle.target.setRenderStyleProperty(property, color);
}

double? _parseLength(String length, RenderStyle renderStyle, String property) {
  return CSSLength.parseLength(length, renderStyle, property).computedValue;
}

void _updateLength(double oldLengthValue, double newLengthValue,
    double progress, String property, CSSRenderStyle renderStyle) {
  double value = oldLengthValue * (1 - progress) + newLengthValue * progress;
  renderStyle.target.setRenderStyleProperty(
      property, CSSLengthValue(value, CSSLengthType.PX));
}

FontWeight _parseFontWeight(
    String fontWeight, RenderStyle renderStyle, String property) {
  return CSSText.resolveFontWeight(fontWeight);
}

void _updateFontWeight(FontWeight oldValue, FontWeight newValue,
    double progress, String property, CSSRenderStyle renderStyle) {
  FontWeight? fontWeight = FontWeight.lerp(oldValue, newValue, progress);
  switch (property) {
    case FONT_WEIGHT:
      renderStyle.fontWeight = fontWeight;
      break;
  }
}

double? _parseNumber(String number, RenderStyle renderStyle, String property) {
  return CSSNumber.parseNumber(number);
}

double _getNumber(double oldValue, double newValue, double progress) {
  return oldValue * (1 - progress) + newValue * progress;
}

void _updateNumber(double oldValue, double newValue, double progress,
    String property, RenderStyle renderStyle) {
  double number = _getNumber(oldValue, newValue, progress);
  renderStyle.target.setRenderStyleProperty(property, number);
}

double _parseLineHeight(
    String lineHeight, RenderStyle renderStyle, String property) {
  if (CSSNumber.isNumber(lineHeight)) {
    return CSSLengthValue(CSSNumber.parseNumber(lineHeight), CSSLengthType.EM,
            renderStyle, LINE_HEIGHT)
        .computedValue;
  }
  return CSSLength.parseLength(lineHeight, renderStyle, LINE_HEIGHT)
      .computedValue;
}

void _updateLineHeight(double oldValue, double newValue, double progress,
    String property, CSSRenderStyle renderStyle) {
  renderStyle.lineHeight = CSSLengthValue(
      _getNumber(oldValue, newValue, progress), CSSLengthType.PX);
}

Matrix4? _parseTransform(
    String value, RenderStyle renderStyle, String property) {
  return CSSMatrix.computeTransformMatrix(
      CSSFunction.parseFunction(value), renderStyle);
}

void _updateTransform(Matrix4 begin, Matrix4 end, double t, String property,
    CSSRenderStyle renderStyle) {
  Matrix4 newMatrix4 = CSSMatrix.lerpMatrix(begin, end, t);
  renderStyle.transformMatrix = newMatrix4;
}

const List<Function> _colorHandler = [_parseColor, _updateColor];
const List<Function> _lengthHandler = [_parseLength, _updateLength];
const List<Function> _fontWeightHandler = [_parseFontWeight, _updateFontWeight];
const List<Function> _numberHandler = [_parseNumber, _updateNumber];
const List<Function> _lineHeightHandler = [_parseLineHeight, _updateLineHeight];
const List<Function> _transformHandler = [_parseTransform, _updateTransform];

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
  BORDER_BOTTOM_LEFT_RADIUS: _lengthHandler,
  BORDER_BOTTOM_RIGHT_RADIUS: _lengthHandler,
  BORDER_TOP_LEFT_RADIUS: _lengthHandler,
  BORDER_TOP_RIGHT_RADIUS: _lengthHandler,
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

mixin CSSAnimationMixin on RenderStyle {
  List<String>? _animationName;

  set animationName(List<String>? value) {
    _animationName = value;
  }

  @override
  List<String> get animationName => _animationName ?? [NONE];

  List<String>? _animationDuration;

  set animationDuration(List<String>? value) {
    _animationDuration = value;
  }

  @override
  List<String> get animationDuration => _animationDuration ?? const [_0s];

  List<String>? _animationTimingFunction;

  set animationTimingFunction(List<String>? value) {
    _animationTimingFunction = value;
  }

  @override
  List<String> get animationTimingFunction =>
      _animationTimingFunction ?? const [EASE];

  List<String>? _animationDelay;

  set animationDelay(List<String>? value) {
    _animationDelay = value;
  }

  @override
  List<String> get animationDelay => _animationDelay ?? const [_0s];

  List<String>? _animationIterationCount;

  set animationIterationCount(List<String>? value) {
    _animationIterationCount = value;
  }

  @override
  List<String> get animationIterationCount => _animationIterationCount ?? ['1'];

  List<String>? _animationDirection;

  set animationDirection(List<String>? value) {
    _animationDirection = value;
  }

  @override
  List<String> get animationDirection => _animationDirection ?? ['normal'];

  List<String>? _animationFillMode;

  set animationFillMode(List<String>? value) {
    _animationFillMode = value;
  }

  @override
  List<String> get animationFillMode => _animationFillMode ?? ['none'];

  List<String>? _animationPlayState;

  set animationPlayState(List<String>? value) {
    _animationPlayState = value;
  }

  @override
  List<String> get animationPlayState =>
      _animationPlayState ?? ['running']; // paused

  bool shouldAnimation(List<String> properties) {
    if (renderBoxModel != null) {
      bool shouldAnimation = false;
      if (properties.any((element) => element.startsWith('animation'))) {
        shouldAnimation = true;
      }
      return shouldAnimation;
    }
    return false;
  }

  final Map<String, Animation> _runningAnimation = {};
  final Map<String, String> _animationProperties = {};
  final Map<String, String> _cacheOriginProperties = {};

  @override
  String? removeAnimationProperty(String propertyName) {
    String? prevValue = EMPTY_STRING;

    if (_animationProperties.containsKey(propertyName)) {
      prevValue = _animationProperties[propertyName];
      _animationProperties.remove(propertyName);
    }

    return prevValue;
  }

  String _getSingleString(List<String> list, int index) {
    return list[index];
  }

  List<Keyframe>? _getKeyFrames(String animationName) {
    final styleSheets = target.ownerDocument.styleSheets;

    CSSKeyframesRule? cssKeyframesRule = null;
    for (int j = styleSheets.length - 1; j >= 0; j--) {
      final sheet = styleSheets[j];
      List<CSSRule> rules = sheet.cssRules;
      for (int i = rules.length - 1; i >= 0; i--) {
        CSSRule rule = rules[i];
        if (rule is CSSKeyframesRule) {
          if (rule.name == animationName) {
            cssKeyframesRule = rule;
            break;
          }
        }
      }
    }
    if (cssKeyframesRule != null) {
      List<Keyframe> keyframes = [];

      cssKeyframesRule.blocks.forEach((rule) {
        double? offset;
        final keyText = rule.blockSelectors[0];
        if (keyText == 'from') {
          offset = 0;
        } else if (keyText == 'to') {
          offset = 1;
        } else {
          offset = CSSPercentage.parsePercentage(keyText);
        }
        rule.declarations.sheetStyle.forEach((key, value) {
          final property = _toCamelCase(key);
          keyframes.add(Keyframe(property, value, offset ?? 0, LINEAR));
        });
        return;
      });
      return keyframes;
    }
    return null;
  }

  void beforeRunningAnimation() {
    for (var i = 0; i < animationName.length; i++) {
      final name = animationName[i];
      if (name == NONE) {
        return;
      }
      final fillMode = _toCamelCase(_getSingleString(animationFillMode, i));
      List<Keyframe>? keyframes = _getKeyFrames(name);
      if (keyframes == null) {
        return;
      }
      FillMode mode = FillMode.values.firstWhere((element) {
        return element.toString().split('.').last == fillMode;
      });
      Animation? animation = _runningAnimation[name];
      if (animation != null) {
        return;
      }

      if (mode == FillMode.backwards || mode == FillMode.both) {
        final styles = getAnimationInitStyle(keyframes);

        styles.forEach((property, value) {
          String? originStyle = target.inlineStyle[property];
          if (originStyle != null) {
            _cacheOriginProperties.putIfAbsent(property, () => originStyle);
          }
          target.setInlineStyle(property, value);
        });

        // for (var i = 0; i < keyframes.length; i++) {
        //   Keyframe keyframe = keyframes[i];
        //   String property = keyframe.property;
        //   String? originStyle = target.inlineStyle[property];
        //   if (originStyle == keyframe.value) {
        //     continue;
        //   }
        //   if (originStyle != null) {
        //     _cacheOriginProperties.putIfAbsent(property, () => originStyle);
        //   }
        //   if (keyframe.offset == 0) {
        //     target.setInlineStyle(property, keyframe.value);
        //     target.style.flushPendingProperties();
        //   }
        // }
      }
    }
    target.style.flushPendingProperties();
  }

  void runAnimation() {
    final removeKeys = _runningAnimation.keys
        .where((element) => !animationName.contains(element))
        .toList();

    removeKeys.forEach((key) {
      Animation animation = _runningAnimation[key]!;
      _runningAnimation.remove(key);
      animation.cancel();
    });

    for (var i = 0; i < animationName.length; i++) {
      final name = animationName[i];
      if (name == NONE) {
        continue;
      }

      final duration = _getSingleString(animationDuration, i);
      final delay = _getSingleString(animationDelay, i);
      final direction = _toCamelCase(_getSingleString(animationDirection, i));
      final iterationCount = _getSingleString(animationIterationCount, i);
      final playState = _getSingleString(animationPlayState, i);
      final timingFunction = _getSingleString(animationTimingFunction, i);
      final fillMode = _toCamelCase(_getSingleString(animationFillMode, i));

      EffectTiming? options = EffectTiming(
        duration: CSSTime.parseTime(duration)!.toDouble(),
        easing: timingFunction,
        delay: CSSTime.parseTime(delay)!.toDouble(),
        fill: FillMode.values.firstWhere((element) {
          return element.toString().split('.').last == fillMode;
        },orElse:(){
          return FillMode.both;
        }),
        iterations: iterationCount == 'infinite'
            ? -1
            : (double.tryParse(iterationCount) ?? 1),
        direction: PlaybackDirection.values.firstWhere(
            (element) => element.toString().split('.').last == direction),
      );

      List<Keyframe>? keyframes = _getKeyFrames(name);

      if (keyframes != null) {
        KeyframeEffect effect =
            KeyframeEffect(this, target, keyframes, options);

        Animation? animation = _runningAnimation[name];

        if (animation != null) {
          animation.effect = effect;
        } else {
          animation = Animation(effect, target.ownerDocument.animationTimeline);

          animation.onstart = () {
            target.dispatchEvent(
                AnimationEvent(EVENT_ANIMATION_START, animationName: name));
          };

          animation.oncancel = (AnimationPlaybackEvent event) {
            // target.dispatchEvent(
            //     AnimationEvent(EVENT_ANIMATION_END, animationName: name));
            // _runningAnimation.remove(name);
            // animation?.dispose();
          };

          animation.onfinish = (AnimationPlaybackEvent event) {
            if (isBackwardsFillModeAnimation(animation!)) {
              _revertOriginProperty(_runningAnimation[name]!);
            }

            target.dispatchEvent(
                AnimationEvent(EVENT_ANIMATION_END, animationName: name));
            // animation.dispose();
          };

          _runningAnimation[name] = animation;
        }

        if (playState == 'running' &&
            animation.playState != AnimationPlayState.running &&
            animation.playState != AnimationPlayState.finished) {
          animation.play();
        } else {
          if (playState == 'paused' &&
              animation.playState != AnimationPlayState.paused) {
            animation.pause();
          }
        }
      }
    }
  }

  void cancelRunningAnimation() {
    if (_runningAnimation.isNotEmpty) {
      for (Animation animation in _runningAnimation.values) {
        animation.cancel();
      }
      _runningAnimation.clear();
    }
  }

  void finishRunningAnimation() {
    if (_runningAnimation.isNotEmpty) {
      for (String property in _runningAnimation.keys) {
        _runningAnimation[property]!.finish();
      }
      _runningAnimation.clear();
    }
  }

  void _revertOriginProperty(Animation animation) {
    AnimationEffect? effect = animation.effect;
    if (effect != null && effect is KeyframeEffect) {
      effect.properties.forEach((String property) {
        if (_cacheOriginProperties.containsKey(property)) {
          target.setInlineStyle(property, _cacheOriginProperties[property]!);
        }
        _cacheOriginProperties.remove(property);
      });
    }
  }

  static bool isValidAnimationNameValue(String value) {
    return value == NONE || CSSTextual.isCustomIdent(value);
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

  static bool isValidAnimationFillModeValue(String value) {
    return value == BACKWARDS ||
        value == FORWARDS ||
        value == BOTH ||
        value == NONE;
  }

  static bool isValidAnimationPlayStateValue(String value) {
    return value == RUNNING || value == PAUSED;
  }

  static bool isValidAnimationDirectionValue(String value) {
    return value == NORMAL ||
        value == REVERSE ||
        value == ALTERNATE ||
        value == ALTERNATE_REVERSE;
  }

  static bool isBackwardsFillModeAnimation(Animation animation) {
    final effect = animation.effect;
    if (effect == null) {
      return false;
    }
    final isBackwards = effect.timing?.fill != null &&
        (effect.timing!.fill == FillMode.backwards ||
            effect.timing!.fill == FillMode.both);

    return isBackwards;
  }

  static Map<String, String> getAnimationInitStyle(List<Keyframe> keyframes) {
    Map<String, String> ret = {};
    keyframes.where((element) => element.offset == 0).forEach((element) {
      ret[element.property] = element.value;
    });
    return ret;
  }
}
