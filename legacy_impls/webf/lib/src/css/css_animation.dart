/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/dom.dart';

// CSS Animation: https://drafts.csswg.org/css-animations/

const String _0s = '0s';

mixin CSSAnimationMixin on RenderStyle {
  List<String>? _animationName;

  @override
  List<String> get animationName => _animationName ?? [NONE];

  set animationName(List<String>? value) {
    _animationName = value;
  }

  List<String>? _animationDuration;

  @override
  List<String> get animationDuration => _animationDuration ?? const [_0s];

  set animationDuration(List<String>? value) {
    _animationDuration = value;
  }

  List<String>? _animationTimingFunction;

  @override
  List<String> get animationTimingFunction => _animationTimingFunction ?? const [EASE];

  set animationTimingFunction(List<String>? value) {
    _animationTimingFunction = value;
  }

  List<String>? _animationDelay;

  @override
  List<String> get animationDelay => _animationDelay ?? const [_0s];

  set animationDelay(List<String>? value) {
    _animationDelay = value;
  }

  List<String>? _animationIterationCount;

  @override
  List<String> get animationIterationCount => _animationIterationCount ?? ['1'];

  set animationIterationCount(List<String>? value) {
    _animationIterationCount = value;
  }

  List<String>? _animationDirection;

  @override
  List<String> get animationDirection => _animationDirection ?? ['normal'];

  set animationDirection(List<String>? value) {
    _animationDirection = value;
  }

  List<String>? _animationFillMode;

  @override
  List<String> get animationFillMode => _animationFillMode ?? ['none'];

  set animationFillMode(List<String>? value) {
    _animationFillMode = value;
  }

  List<String>? _animationPlayState;

  @override
  List<String> get animationPlayState => _animationPlayState ?? ['running']; // paused

  set animationPlayState(List<String>? value) {
    _animationPlayState = value;
  }

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
  final Map<String, String> _cacheOriginProperties = {};

  String _getSingleString(List<String> list, int index) {
    return list[index];
  }

  List<Keyframe>? _getKeyFrames(String animationName) {
    CSSKeyframesRule? cssKeyframesRule = target.ownerDocument.ruleSet.keyframesRules[animationName];
    return cssKeyframesRule?.keyframes;
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
        duration: CSSTime.parseNotNegativeTime(duration)!.toDouble(),
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
            target.dispatchEvent(AnimationEvent(EVENT_ANIMATION_END, animationName: name));
            _runningAnimation.remove(name);
            animation?.dispose();
          };

          animation.onfinish = (AnimationPlaybackEvent event) {
            if (isBackwardsFillModeAnimation(animation!)) {
              _revertOriginProperty(_runningAnimation[name]!);
            }

            target.dispatchEvent(AnimationEvent(EVENT_ANIMATION_END, animationName: name));
            animation.dispose();
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
      List<Animation> animations = _runningAnimation.values.toList();
      animations.forEach((animation) {
        animation.cancel();
      });
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
