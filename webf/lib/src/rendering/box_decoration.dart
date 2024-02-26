/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

mixin RenderBoxDecorationMixin on RenderBoxModelBase {
  BoxDecorationPainter? _painter;

  BoxDecorationPainter? get boxPainter => _painter;

  set boxPainter(BoxDecorationPainter? painter) {
    _painter = painter;
  }

  void disposePainter() {
    _painter?.dispose();
    _painter = null;
  }

  void invalidateBoxPainter() {
    _painter?.dispose();
    _painter = null;
  }

  static void paintBackground(WebFPaintingPipeline pipeline, Offset offset, [WebFPaintingContextCallback? callback]) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackPaintStep('paintBackground');
    }

    RenderBoxModel renderBoxModel = pipeline.renderBoxModel;
    CSSRenderStyle renderStyle = renderBoxModel.renderStyle;

    EdgeInsets resolvedPadding = renderStyle.padding.resolve(TextDirection.ltr);
    CSSBoxDecoration? decoration = renderStyle.decoration;
    DecorationPosition decorationPosition = renderStyle.decorationPosition;
    ImageConfiguration imageConfiguration = renderStyle.imageConfiguration;

    if (decoration == null) {
      return;
    }

    renderBoxModel._painter ??= BoxDecorationPainter(resolvedPadding, renderStyle, renderBoxModel.markNeedsPaint);
    PaintingContext context = pipeline.context;

    final ImageConfiguration filledConfiguration = imageConfiguration.copyWith(size: renderBoxModel.size);
    if (decorationPosition == DecorationPosition.background) {
      int? debugSaveCount;
      assert(() {
        debugSaveCount = pipeline.context.canvas.getSaveCount();
        return true;
      }());
      renderBoxModel._painter!.paintBackground(context.canvas, offset, filledConfiguration);
      assert(() {
        if (debugSaveCount != context.canvas.getSaveCount()) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('${decoration.runtimeType} painter had mismatching save and restore calls.'),
            ErrorDescription('Before painting the decoration, the canvas save count was $debugSaveCount. '
                'After painting it, the canvas save count was ${context.canvas.getSaveCount()}. '
                'Every call to save() or saveLayer() must be matched by a call to restore().'),
            DiagnosticsProperty<Decoration>('The decoration was', decoration,
                style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<BoxPainter>('The painter was', renderBoxModel._painter, style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (decoration.isComplex) context.setIsComplexHint();
    }

    if (decorationPosition == DecorationPosition.foreground) {
      renderBoxModel._painter!.paint(context.canvas, offset, filledConfiguration);
      if (decoration.isComplex) context.setIsComplexHint();
    }

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackPaintStep();
    }
  }

  static void paintDecoration(WebFPaintingPipeline pipeline, Offset offset, [WebFPaintingContextCallback? callback]) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackPaintStep('paintDecoration');
    }

    RenderBoxModel renderBoxModel = pipeline.renderBoxModel;
    CSSRenderStyle renderStyle = renderBoxModel.renderStyle;
    PaintingContext context = pipeline.context;
    CSSBoxDecoration? decoration = renderStyle.decoration;
    DecorationPosition decorationPosition = renderStyle.decorationPosition;
    ImageConfiguration imageConfiguration = renderStyle.imageConfiguration;

    if (decoration == null) {
      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackPaintStep();
      }
      return pipeline.paintOverflow(pipeline, offset);
    }

    EdgeInsets? padding = renderStyle.padding.resolve(TextDirection.ltr);
    renderBoxModel._painter ??= BoxDecorationPainter(padding, renderStyle, renderBoxModel.markNeedsPaint);

    final ImageConfiguration filledConfiguration = imageConfiguration.copyWith(size: renderBoxModel.size);

    if (decorationPosition == DecorationPosition.background) {
      int? debugSaveCount;
      assert(() {
        debugSaveCount = pipeline.context.canvas.getSaveCount();
        return true;
      }());

      renderBoxModel._painter!.paint(context.canvas, offset, filledConfiguration);
      assert(() {
        if (debugSaveCount != context.canvas.getSaveCount()) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('${decoration.runtimeType} painter had mismatching save and restore calls.'),
            ErrorDescription('Before painting the decoration, the canvas save count was $debugSaveCount. '
                'After painting it, the canvas save count was ${context.canvas.getSaveCount()}. '
                'Every call to save() or saveLayer() must be matched by a call to restore().'),
            DiagnosticsProperty<Decoration>('The decoration was', decoration,
                style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<BoxPainter>('The painter was', renderBoxModel._painter, style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (decoration.isComplex) context.setIsComplexHint();
    }
    if (decorationPosition == DecorationPosition.foreground) {
      renderBoxModel._painter!.paint(context.canvas, offset, filledConfiguration);
      if (decoration.isComplex) context.setIsComplexHint();
    }

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackPaintStep();
    }

    pipeline.paintOverflow(pipeline, offset);
  }

  void debugBoxDecorationProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty('borderEdge', renderStyle.border));
    if (renderStyle.backgroundClip != null)
      properties.add(DiagnosticsProperty('backgroundClip', renderStyle.backgroundClip));
    if (renderStyle.backgroundOrigin != null)
      properties.add(DiagnosticsProperty('backgroundOrigin', renderStyle.backgroundOrigin));
    CSSBoxDecoration? _decoration = renderStyle.decoration;
    if (_decoration != null && _decoration.hasBorderRadius)
      properties.add(DiagnosticsProperty('borderRadius', _decoration.borderRadius));
    if (_decoration != null && _decoration.image != null)
      properties.add(DiagnosticsProperty('backgroundImage', _decoration.image));
    if (_decoration != null && _decoration.boxShadow != null)
      properties.add(DiagnosticsProperty('boxShadow', _decoration.boxShadow));
    if (_decoration != null && _decoration.gradient != null)
      properties.add(DiagnosticsProperty('gradient', _decoration.gradient));
  }
}
