/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/css.dart';
import 'package:webf/gesture.dart';

typedef ScrollListener = void Function(double scrollOffset, AxisDirection axisDirection);

mixin RenderOverflowMixin on RenderBoxModelBase {
  ScrollListener? scrollListener;
  void Function(PointerEvent)? scrollablePointerListener;

  void disposeScrollable() {
    scrollListener = null;
    scrollablePointerListener = null;
    _scrollOffsetX = null;
    _scrollOffsetY = null;
    // Dispose clip layer.
    _clipRRectLayer.layer = null;
    _clipRectLayer.layer = null;
  }

  bool get clipX {
    RenderBoxModel renderBoxModel = this as RenderBoxModel;

    List<Radius>? borderRadius = renderBoxModel.renderStyle.borderRadius;

    // The content of replaced elements is always trimmed to the content edge curve.
    // https://www.w3.org/TR/css-backgrounds-3/#corner-clipping
    if (borderRadius != null && renderStyle.isSelfRenderReplaced() && renderStyle.aspectRatio != null) {
      return true;
    }

    // Per spec, overflow other than 'visible' establishes a clipping context at the
    // padding edge. Always clip in this case so translated scroll contents (non-zero
    // paint offset) cannot bleed outside the container, even when the content size
    // currently fits within the viewport. This also ensures inner padding is honored.
    // https://www.w3.org/TR/css-overflow-3/#overflow-properties
    CSSOverflowType effectiveOverflowX = renderStyle.effectiveOverflowX;
    if (effectiveOverflowX != CSSOverflowType.visible) {
      return true;
    }

    return false;
  }

  bool get clipY {
    RenderBoxModel renderBoxModel = this as RenderBoxModel;

    List<Radius>? borderRadius = renderStyle.borderRadius;

    // The content of replaced elements is always trimmed to the content edge curve.
    // https://www.w3.org/TR/css-backgrounds-3/#corner-clipping
    if (borderRadius != null && renderStyle.isSelfRenderReplaced() && renderStyle.aspectRatio != null) {
      return true;
    }

    // Always clip when overflow is not 'visible' to enforce the padding-edge
    // clipping boundary regardless of current content size. This prevents text
    // or children from painting outside the container when scrolled and ensures
    // padding acts as the inner clip inset.
    // https://www.w3.org/TR/css-overflow-3/#overflow-properties
    CSSOverflowType effectiveOverflowY = renderStyle.effectiveOverflowY;
    if (effectiveOverflowY != CSSOverflowType.visible) {
      return true;
    }
    return false;
  }

  Size? _scrollableSize;
  Size? _viewportSize;

  ViewportOffset? get scrollOffsetX => _scrollOffsetX;
  ViewportOffset? _scrollOffsetX;

  set scrollOffsetX(ViewportOffset? value) {
    if (value == _scrollOffsetX) return;
    _scrollOffsetX?.removeListener(scrollXListener);
    _scrollOffsetX = value;
    _scrollOffsetX?.addListener(scrollXListener);
    markNeedsLayout();
  }

  ViewportOffset? get scrollOffsetY => _scrollOffsetY;
  ViewportOffset? _scrollOffsetY;

  set scrollOffsetY(ViewportOffset? value) {
    if (value == _scrollOffsetY) return;
    _scrollOffsetY?.removeListener(scrollYListener);
    _scrollOffsetY = value;
    _scrollOffsetY?.addListener(scrollYListener);
    markNeedsLayout();
  }

  void scrollXListener() {
    assert(scrollListener != null);
    // If scroll is happening, that element has been unmounted, prevent null usage.
    if (scrollOffsetX != null) {
      if (DebugFlags.debugLogScrollableEnabled) {
        final double maxX = math.max(0.0, (_scrollableSize?.width ?? 0) - (_viewportSize?.width ?? 0));
        renderingLogger.finer('[Overflow-Scroll] <${renderStyle.target.tagName.toLowerCase()}> X pixels='
            '${scrollOffsetX!.pixels.toStringAsFixed(2)} max=${maxX.toStringAsFixed(2)}');
      }
      final AxisDirection dir = (renderStyle.direction == TextDirection.rtl) ? AxisDirection.left : AxisDirection.right;
      scrollListener!(scrollOffsetX!.pixels, dir);
      markNeedsPaint();
    }
  }

  void scrollYListener() {
    assert(scrollListener != null);
    if (scrollOffsetY != null) {
      if (DebugFlags.debugLogScrollableEnabled) {
        final double maxY = math.max(0.0, (_scrollableSize?.height ?? 0) - (_viewportSize?.height ?? 0));
        renderingLogger.finer('[Overflow-Scroll] <${renderStyle.target.tagName.toLowerCase()}> Y pixels='
            '${scrollOffsetY!.pixels.toStringAsFixed(2)} max=${maxY.toStringAsFixed(2)}');
      }
      scrollListener!(scrollOffsetY!.pixels, AxisDirection.down);
      markNeedsPaint();
    }
  }

  void _setUpScrollX() {
    _scrollOffsetX!.applyViewportDimension(_viewportSize!.width);
    _scrollOffsetX!.applyContentDimensions(0.0, math.max(0.0, _scrollableSize!.width - _viewportSize!.width));
  }

  void _setUpScrollY() {
    _scrollOffsetY!.applyViewportDimension(_viewportSize!.height);
    _scrollOffsetY!.applyContentDimensions(0.0, math.max(0.0, _scrollableSize!.height - _viewportSize!.height));
  }

  void setUpOverflowScroller(Size scrollableSize, Size viewportSize) {
    assert(scrollableSize.isFinite);

    _scrollableSize = scrollableSize;
    _viewportSize = viewportSize;
    if (_scrollOffsetX != null) {
      _setUpScrollX();
      final double maxX = math.max(0.0, _scrollableSize!.width - _viewportSize!.width);
      // Do not auto-jump scroll position for RTL containers.
      // Per CSS/UA expectations, initial scroll position is the start edge
      // of the scroll range, and user agent should not forcibly move it to
      // the visual right edge for RTL. Keeping 0 preserves expected behavior
      // for cases where overflow content lies entirely to the right.
    }

    if (_scrollOffsetY != null) {
      _setUpScrollY();
      final double maxY = math.max(0.0, _scrollableSize!.height - _viewportSize!.height);
    }

    // After computing viewport/content dimensions, update sticky descendants so their
    // initial paint offsets honor top/bottom/left/right clamps before any scroll occurs.
    try {
      final Element el = renderStyle.target;
      el.updateStickyOffsets();
    } catch (_) {}
  }
  double get _paintOffsetX {
    if (_scrollOffsetX == null) return 0.0;
    // Compute logical left-edge position within the scrollable content.
    // LTR: logical distance from left is the raw pixels.
    // RTL: logical distance from left is (maxScroll - pixels) so that
    // an initial pixels=0 aligns the visual viewport to the right edge.
    final double maxScroll = math.max(0.0, (_scrollableSize?.width ?? 0) - (_viewportSize?.width ?? 0));
    final double logicalLeft = (renderStyle.direction == TextDirection.rtl)
        ? (maxScroll - _scrollOffsetX!.pixels)
        : _scrollOffsetX!.pixels;
    // Translate content left by the logical left distance.
    return -logicalLeft;
  }

  double get _paintOffsetY {
    if (_scrollOffsetY == null) return 0.0;
    return -_scrollOffsetY!.pixels;
  }

  // Expose effective paint scroll offset for use in hit testing
  Offset get paintScrollOffset => Offset(_paintOffsetX, _paintOffsetY);

  double get scrollTop {
    if (_scrollOffsetY == null) return 0.0;
    return _scrollOffsetY!.pixels;
  }

  double get scrollLeft {
    if (_scrollOffsetX == null) return 0.0;
    return _scrollOffsetX!.pixels;
  }

  bool _shouldClipAtPaintOffset(Offset paintOffset, Size childSize) {
    return paintOffset < Offset.zero || !(Offset.zero & size).contains((paintOffset & childSize).bottomRight);
  }

  final LayerHandle<ClipRRectLayer> _clipRRectLayer = LayerHandle<ClipRRectLayer>();
  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();

  void paintOverflow(PaintingContext context, Offset offset, EdgeInsets borderEdge, CSSBoxDecoration? decoration,
      PaintingContextCallback callback) {
    if (clipX == false && clipY == false) return callback(context, offset);

    final double paintOffsetX = _paintOffsetX;
    final double paintOffsetY = _paintOffsetY;
    final Offset paintOffset = Offset(paintOffsetX, paintOffsetY);
    // Overflow should not cover border.
    Rect clipRect = Offset(borderEdge.left, borderEdge.top) &
        Size(
          size.width - borderEdge.right - borderEdge.left,
          size.height - borderEdge.bottom - borderEdge.top,
        );
    if (_shouldClipAtPaintOffset(paintOffset, size)) {
      // ignore: prefer_function_declarations_over_variables
      PaintingContextCallback painter = (PaintingContext context, Offset offset) {
        callback(context, offset + paintOffset);
      };

      // If current or its descendants has a compositing layer caused by styles
      // (eg. transform, opacity, overflow...), then it needs to create a new layer
      // or else the clip in the older layer will not work.
      bool _needsCompositing = needsCompositing;

      if (decoration != null && decoration.hasBorderRadius) {
        BorderRadius radius = decoration.borderRadius!;
        Rect rect = Offset.zero & size;
        RRect borderRRect = radius.toRRect(rect);
        // A borderRadius can only be given for a uniform Border in Flutter.
        // https://github.com/flutter/flutter/issues/12583
        double? borderTop = renderStyle.borderTopWidth?.computedValue;
        // The content of overflow is trimmed to the padding edge curve.
        // https://www.w3.org/TR/css-backgrounds-3/#corner-clipping
        RRect clipRRect = borderTop != null ? borderRRect.deflate(borderTop) : borderRRect;

        // The content of replaced elements is trimmed to the content edge curve.
        if (renderStyle.isSelfRenderReplaced()) {
          // @TODO: Currently only support clip uniform padding for replaced element.
          double paddingTop = renderStyle.paddingTop.computedValue;
          clipRRect = clipRRect.deflate(paddingTop);
        }
        if (DebugFlags.enableBorderRadiusLogs) {
          try {
            final el = renderStyle.target;
            renderingLogger.finer('[BorderRadius] overflow clip <${el.tagName.toLowerCase()}> clipRect=${clipRect.size} '
                'tl=(${clipRRect.tlRadiusX.toStringAsFixed(2)},${clipRRect.tlRadiusY.toStringAsFixed(2)})');
          } catch (_) {}
        }
        _clipRRectLayer.layer = context.pushClipRRect(_needsCompositing, offset, clipRect, clipRRect, painter,
            oldLayer: _clipRRectLayer.layer);
      } else {
        _clipRectLayer.layer =
            context.pushClipRect(_needsCompositing, offset, clipRect, painter, oldLayer: _clipRectLayer.layer);
      }
    } else {
      _clipRectLayer.layer = null;
      _clipRRectLayer.layer = null;
      callback(context, offset);
    }
  }

  // For position fixed render box, should reduce the outer scroll offsets.
  void applyPositionFixedPaintTransform(RenderBoxModel child, Matrix4 transform) {
    Offset totalScrollOffset = child.getTotalScrollOffset();
    transform.translate(totalScrollOffset.dx, totalScrollOffset.dy);
  }

  void applyOverflowPaintTransform(RenderBox child, Matrix4 transform) {
    final Offset paintOffset = Offset(_paintOffsetX, _paintOffsetY);

    if (child is RenderBoxModel && child.renderStyle.position == CSSPositionType.fixed) {
      applyPositionFixedPaintTransform(child, transform);
    }

    transform.translate(paintOffset.dx, paintOffset.dy);
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) {
    final Offset paintOffset = Offset(_paintOffsetX, _paintOffsetY);
    if (_shouldClipAtPaintOffset(paintOffset, size)) return Offset.zero & size;
    return null;
  }

  void debugOverflowProperties(DiagnosticPropertiesBuilder properties) {
    if (_scrollableSize != null) properties.add(DiagnosticsProperty('scrollableSize', _scrollableSize));
    if (_viewportSize != null) properties.add(DiagnosticsProperty('viewportSize', _viewportSize));
    properties.add(DiagnosticsProperty('clipX', clipX));
    properties.add(DiagnosticsProperty('clipY', clipY));
  }
}
