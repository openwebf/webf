/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

mixin RenderTransformMixin on RenderBoxModelBase {
  final LayerHandle<TransformLayer> _transformLayer = LayerHandle<TransformLayer>();

  void disposeTransformLayer() {
    _transformLayer.layer = null;
  }

  void paintTransform(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (renderStyle.transformMatrix != null) {
      if (!kReleaseMode) {
        WebFProfiler.instance.startTrackPaintStep('paintTransform');
        WebFProfiler.instance.startTrackPaintSubStep('renderStyle.effectiveTransformMatrix');
      }

      final Matrix4 transform = renderStyle.effectiveTransformMatrix;

      if (!kReleaseMode) {
        WebFProfiler.instance.finishTrackPaintSubStep(transform.toString());
      }

      finishPaintTransform(PaintingContext context, Offset offset) {
        if (!kReleaseMode) {
          WebFProfiler.instance.finishTrackPaintStep();
        }
        callback(context, offset);
      }

      final Offset? childOffset = MatrixUtils.getAsTranslation(transform);
      if (childOffset == null) {
        _transformLayer.layer = context.pushTransform(
          needsCompositing,
          offset,
          transform,
          finishPaintTransform,
          oldLayer: _transformLayer.layer,
        );
      } else {
        finishPaintTransform(context, offset + childOffset);
        _transformLayer.layer = null;
      }
    } else {
      callback(context, offset);
    }
  }

  void applyEffectiveTransform(RenderBox child, Matrix4 transform) {
    if (renderStyle.transformMatrix != null) {
      transform.multiply(renderStyle.effectiveTransformMatrix);
    }
  }

  bool hitTestLayoutChildren(BoxHitTestResult result, RenderBox? child, Offset position) {
    while (child != null) {
      final RenderLayoutParentData? childParentData = child.parentData as RenderLayoutParentData?;
      final bool isHit = result.addWithPaintTransform(
        transform: renderStyle.effectiveTransformMatrix,
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          return result.addWithPaintOffset(
            offset: childParentData!.offset,
            position: position,
            hitTest: (BoxHitTestResult result, Offset transformed) {
              assert(transformed == position - childParentData.offset);
              return child!.hitTest(result, position: transformed);
            },
          );
        },
      );
      if (isHit) return true;
      child = childParentData!.previousSibling;
    }
    return false;
  }

  bool hitTestIntrinsicChild(BoxHitTestResult result, RenderBox? child, Offset position) {
    final bool isHit = result.addWithPaintTransform(
      transform: renderStyle.effectiveTransformMatrix,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        if (child?.hasSize == false) return false;

        return child?.hitTest(result, position: position) ?? false;
      },
    );
    if (isHit) return true;
    return false;
  }

  void debugTransformProperties(DiagnosticPropertiesBuilder properties) {
    Offset transformOffset = renderStyle.transformOffset;
    Alignment transformAlignment = renderStyle.transformAlignment;
    properties.add(DiagnosticsProperty('transformOrigin', transformOffset));
    properties.add(DiagnosticsProperty('transformAlignment', transformAlignment));
  }
}
