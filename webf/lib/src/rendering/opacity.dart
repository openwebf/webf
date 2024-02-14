/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

mixin RenderOpacityMixin on RenderBoxModelBase {
  bool opacityAlwaysNeedsCompositing() => alpha != 0 && alpha != 255;

  int? _alpha;

  int get alpha {
    _alpha ??= ui.Color.getAlphaFromOpacity(renderStyle.opacity);
    return _alpha ?? ui.Color.getAlphaFromOpacity(1.0);
  }

  set alpha(int? value) {
    _alpha = value;
  }

  final LayerHandle<OpacityLayer> _opacityLayer = LayerHandle<OpacityLayer>();

  void disposeOpacityLayer() {
    _opacityLayer.layer = null;
  }

  static void paintOpacity(WebFPaintingPipeline pipeline, Offset offset, [WebFPaintingContextCallback? callback]) {
    RenderBoxModel renderBoxModel = pipeline.renderBoxModel;

    if (!kReleaseMode) {
      WebFProfiler.instance.startTrackPaintStep('paintOpacity', {
        'alpha': renderBoxModel.alpha
      });
    }

    int alpha = renderBoxModel.alpha;
    LayerHandle<OpacityLayer> opacityLayer = renderBoxModel._opacityLayer;

    if (alpha == 255) {
      renderBoxModel._opacityLayer.layer = null;
      if (!kReleaseMode) {
        WebFProfiler.instance.finishTrackPaintStep();
      }

      // No need to keep the layer. We'll create a new one if necessary.
      pipeline.paintDecoration(pipeline, offset);
      return;
    }

    opacityLayer.layer = pipeline.context.pushOpacity(offset, alpha, (PaintingContext context, Offset offset) {
      if (!kReleaseMode) {
        WebFProfiler.instance.finishTrackPaintStep();
      }
      pipeline.paintDecoration(pipeline, offset);
    }, oldLayer: opacityLayer.layer);
  }

  void debugOpacityProperties(DiagnosticPropertiesBuilder properties) {
    if (alpha != 0 && alpha != 255) properties.add(DiagnosticsProperty('alpha', alpha));
  }
}
