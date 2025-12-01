/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:webf/foundation.dart';

const Offset _DEFAULT_TRANSFORM_OFFSET = Offset.zero;
const Alignment _DEFAULT_TRANSFORM_ALIGNMENT = Alignment.center;

// A temporary value
class TransformAnimationValue {
  // The parsed transform functions list (e.g., [translateX(100%), ...]).
  dynamic value;
  // Optional snapshot of the computed transform matrix captured at
  // animation setup time. When present, transition ticks will prefer this
  // frozen matrix to ensure stable interpolation for values that do not
  // depend on the evolving reference box (e.g., absolute lengths and
  // var()-driven resolutions where we want start/end snapshots).
  Matrix4? frozenMatrix;

  TransformAnimationValue(this.value, {this.frozenMatrix});
}

// CSS Transforms: https://drafts.csswg.org/css-transforms/
mixin CSSTransformMixin on RenderStyle {
  // https://drafts.csswg.org/css-transforms-1/#propdef-transform
  // Name: transform
  // Value: none | <transform-list>
  // Initial: none
  // Applies to: transformable elements
  // Inherited: no
  // Percentages: refer to the size of reference box
  // Computed value: as specified, but with lengths made absolute
  // Canonical order: per grammar
  // Animation type: transform list, see interpolation rules
  List<CSSFunctionalNotation>? _transform;
  @override
  List<CSSFunctionalNotation>? get transform => _transform;
  set transform(List<CSSFunctionalNotation>? value) {
    // Even if the transform value has not changed, ensure the cached
    // transformMatrix is cleared so any animation-driven state is dropped
    // and the effective transform recomputes from the current value.
    if (_transform == value) {
      // If a transform transition is currently running, let the
      // animation own matrix updates.
      if (this is CSSRenderStyle && (this as CSSRenderStyle).isTransitionRunning(TRANSFORM)) {
        return;
      }
      // Otherwise, clear cached matrix and repaint so the effective transform
      // recomputes from the current value (handles var()/percent changes).
      _transformMatrix = null;
      markNeedsPaint();
      return;
    }
    _transform = value;
    _transformMatrix = null;

    // Mark the compositing state for this render object as dirty
    // cause it will create new layer when transform is valid.
    if (value != null) {
      markNeedsCompositingBitsUpdate();
    }

    // Transform effect the stacking context.
    if (isParentRenderLayoutBox()) {
      markParentNeedsSort();
    }

    // Transform stage are applied at paint stage, should avoid re-layout.
    markNeedsPaint();
  }

  static List<CSSFunctionalNotation>? resolveTransform(String present) {
    if (present == 'none') return null;
    return CSSFunction.parseFunction(present);
  }

  // Heuristic: only freeze when the transform does NOT contain percentage- or
  // var()-based arguments that should track layout changes during the
  // transition. Percentage-based translations should resolve against the
  // current reference box on each tick to match browser behavior.
  static bool _shouldFreeze(List<CSSFunctionalNotation>? notation) {
    if (notation == null) return false;
    for (final CSSFunctionalNotation fn in notation) {
      final String name = fn.name.toLowerCase();
      // Only translation-related functions can meaningfully use percentages.
      // translate(), translateX(), translateY(), translate3d() (x/y may be %).
      final bool isTranslate = name == 'translate' || name == 'translatex' ||
          name == 'translatey' || name == 'translate3d';

      for (final String rawArg in fn.args) {
        final String arg = rawArg.trim();
        // If any argument contains var(), avoid freezing since var() could
        // resolve to percentage or dynamic lengths tied to layout.
        if (arg.contains('var(')) return false;
        // If any argument contains an explicit percentage, avoid freezing to
        // allow it to follow the changing reference box.
        if (arg.contains('%') && isTranslate) return false;
        // calc() may include percentages; take the conservative path and do
        // not freeze when calc is present in a translate function.
        if (arg.contains('calc(') && isTranslate) return false;
      }
    }
    return true;
  }

  static TransformAnimationValue resolveTransformForAnimation(String present, RenderStyle renderStyle) {
    final List<CSSFunctionalNotation>? notation = resolveTransform(present);
    Matrix4? frozen;
    if (_shouldFreeze(notation)) {
      // Snapshot the matrix so absolute-length or variable-driven transforms
      // interpolate deterministically between start/end.
      frozen = notation != null ? CSSMatrix.computeTransformMatrix(notation, renderStyle) : null;
    } else {
      // Leave unfrozen so percentage-based transforms (or calc/var that may
      // include percentages) re-resolve against the current reference box.
      frozen = null;
    }
    return TransformAnimationValue(notation, frozenMatrix: frozen);
  }

  Matrix4? _transformMatrix;
  Matrix4? get transformMatrix {
    if (_transformMatrix == null && _transform != null) {
      // Illegal transform syntax will return null.
      _transformMatrix = CSSMatrix.computeTransformMatrix(_transform!, this);
      if (_transformMatrix != null) {
        assert(_transformMatrix!.storage.every((element) => element.isFinite));
      }
    }
    return _transformMatrix;
  }

  void markTransformMatrixNeedsUpdate() {
    // If a transform transition is running, do not clobber the per‑tick
    // animation-driven transformMatrix; let the transition own updates.
    // When no transform transition is active, invalidate cached matrix so
    // percentage-based transforms recompute after layout size changes.
    if (this is CSSRenderStyle) {
      final CSSRenderStyle rs = this as CSSRenderStyle;
      if (rs.isTransitionRunning(TRANSFORM)) {
        return;
      }
    }
    _transformMatrix = null;
    if (DebugFlags.enableCssVarAndTransitionLogs) {
      cssLogger.info('[transform][clear-matrix]');
    }
  }

  // Transform animation drived by transformMatrix.
  set transformMatrix(Matrix4? value) {
    if (value == null || _transformMatrix == value) return;
    _transformMatrix = value;
    markNeedsPaint();
  }

  // Effective transform matrix after renderBoxModel has been layouted.
  // Copy from flutter [RenderTransform._effectiveTransform]
  @override
  Matrix4 get effectiveTransformMatrix {
    assert(hasRenderBox());
    // Make sure it is used after renderBoxModel been created.
    final Matrix4 result = Matrix4.identity();
    result.translate(transformOffset.dx, transformOffset.dy);
    late Offset translation;
    if (transformAlignment != Alignment.topLeft) {
      // Use boxSize instead of size to avoid Flutter cannot access size beyond parent access warning
      translation = transformAlignment.alongSize(boxSize()!);
      // translation =
      result.translate(translation.dx, translation.dy);
    }

    if (transformMatrix != null) {
      result.multiply(transformMatrix!);
    }

    if (transformAlignment != Alignment.topLeft) result.translate(-translation.dx, -translation.dy);

    result.translate(-transformOffset.dx, -transformOffset.dy);

    assert(result.storage.every((double component) => component.isFinite));
    return result;
  }

  // Effective transform offset after renderBoxModel has been layouted.
  Offset? get effectiveTransformOffset {
    // Make sure it is used after renderBoxModel been created.
    assert(hasRenderBox());
    Vector3 translation = effectiveTransformMatrix.getTranslation();
    return Offset(translation[0], translation[1]);
  }

  // Effective transform scale after renderBoxModel has been layouted.
  @override
  double get effectiveTransformScale {
    assert(hasRenderBox());
    double scale = effectiveTransformMatrix.getMaxScaleOnAxis();
    return scale;
  }

  Offset get transformOffset => _transformOffset;
  Offset _transformOffset = _DEFAULT_TRANSFORM_OFFSET;
  set transformOffset(Offset value) {
    if (_transformOffset == value) return;
    _transformOffset = value;
    markNeedsPaint();
  }

  Alignment get transformAlignment => _transformAlignment;
  Alignment _transformAlignment = _DEFAULT_TRANSFORM_ALIGNMENT;
  set transformAlignment(Alignment value) {
    if (_transformAlignment == value) return;
    _transformAlignment = value;
    markNeedsPaint();
  }

  CSSOrigin? _transformOrigin;
  @override
  CSSOrigin get transformOrigin =>
      _transformOrigin ?? const CSSOrigin(_DEFAULT_TRANSFORM_OFFSET, _DEFAULT_TRANSFORM_ALIGNMENT);
  set transformOrigin(CSSOrigin? value) {
    if (_transformOrigin == value) return;
    _transformOrigin = value;

    Offset oldOffset = transformOffset;
    Offset offset = transformOrigin.offset;
    // Transform origin transition by offset
    if (offset.dx != oldOffset.dx || offset.dy != oldOffset.dy) {
      transformOffset = offset;
    }

    Alignment alignment = transformOrigin.alignment;
    Alignment oldAlignment = transformAlignment;
    // Transform origin transition by alignment
    if (alignment.x != oldAlignment.x || alignment.y != oldAlignment.y) {
      transformAlignment = alignment;
    }
  }
}
