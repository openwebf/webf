/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/dom.dart';

// CSS Animation: https://drafts.csswg.org/css-animations/

const String EVENT_ANIMATION_CANCEL = 'animationcancel';
const String EVENT_ANIMATION_START = 'animationstart';
const String EVENT_ANIMATION_END = 'animationend';
const String EVENT_ANIMATION_ITERATION = 'animationiteration';

class AnimationEvent extends Event {
  AnimationEvent(String type, {String? animationName, double? elapsedTime, String? pseudoElement})
      : animationName = animationName ?? '',
        elapsedTime = elapsedTime ?? 0.0,
        pseudoElement = pseudoElement ?? '',
        super(type) {}

  String animationName;
  double elapsedTime;
  String pseudoElement;
}

const String _0s = '0s';

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
  List<String> get animationTimingFunction => _animationTimingFunction ?? const [EASE];

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
  List<String> get animationPlayState => _animationPlayState ?? ['running']; // paused

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
    CSSKeyframesRule? cssKeyframesRule = target.ownerDocument.ruleSet.keyframesRules[animationName];
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
          final property = camelize(key);
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
      final fillMode = camelize(_getSingleString(animationFillMode, i));
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
    final removeKeys = _runningAnimation.keys.where((element) => !animationName.contains(element)).toList();

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
      final direction = camelize(_getSingleString(animationDirection, i));
      final iterationCount = _getSingleString(animationIterationCount, i);
      final playState = _getSingleString(animationPlayState, i);
      final timingFunction = _getSingleString(animationTimingFunction, i);
      final fillMode = camelize(_getSingleString(animationFillMode, i));

      EffectTiming? options = EffectTiming(
        duration: CSSTime.parseTime(duration)!.toDouble(),
        easing: timingFunction,
        delay: CSSTime.parseTime(delay)!.toDouble(),
        fill: FillMode.values.firstWhere((element) {
          return element.toString().split('.').last == fillMode;
        }, orElse: () {
          return FillMode.both;
        }),
        iterations: iterationCount == 'infinite' ? double.infinity : (double.tryParse(iterationCount) ?? 1),
        direction: PlaybackDirection.values.firstWhere((element) => element.toString().split('.').last == direction),
      );

      List<Keyframe>? keyframes = _getKeyFrames(name);

      if (keyframes != null) {
        KeyframeEffect effect = KeyframeEffect(this, target, keyframes, options);

        Animation? animation = _runningAnimation[name];

        if (animation != null) {
          animation.effect = effect;
        } else {
          animation = Animation(effect, target.ownerDocument.animationTimeline);

          animation.onstart = () {
            target.dispatchEvent(AnimationEvent(EVENT_ANIMATION_START, animationName: name));
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

            target.dispatchEvent(AnimationEvent(EVENT_ANIMATION_END, animationName: name));
            // animation.dispose();
          };

          _runningAnimation[name] = animation;
        }

        if (playState == 'running' &&
            animation.playState != AnimationPlayState.running &&
            animation.playState != AnimationPlayState.finished) {
          animation.play();
        } else {
          if (playState == 'paused' && animation.playState != AnimationPlayState.paused) {
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
    return value == BACKWARDS || value == FORWARDS || value == BOTH || value == NONE;
  }

  static bool isValidAnimationPlayStateValue(String value) {
    return value == RUNNING || value == PAUSED;
  }

  static bool isValidAnimationDirectionValue(String value) {
    return value == NORMAL || value == REVERSE || value == ALTERNATE || value == ALTERNATE_REVERSE;
  }

  static bool isBackwardsFillModeAnimation(Animation animation) {
    final effect = animation.effect;
    if (effect == null) {
      return false;
    }
    final isBackwards = effect.timing?.fill != null &&
        (effect.timing!.fill == FillMode.backwards || effect.timing!.fill == FillMode.both);

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
