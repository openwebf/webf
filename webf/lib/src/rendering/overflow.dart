/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/css.dart';

typedef ScrollListener = void Function(
    double scrollOffset, AxisDirection axisDirection);

mixin RenderOverflowMixin on RenderBoxModelBase {
  static const double _kSemanticsScrollFactor = 0.8;

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
    final List<Radius>? borderRadius = renderStyle.borderRadius;

    // The content of replaced elements is always trimmed to the content edge curve.
    // https://www.w3.org/TR/css-backgrounds-3/#corner-clipping
    if (borderRadius != null &&
        renderStyle.isSelfRenderReplaced() &&
        renderStyle.aspectRatio != null) {
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
    final List<Radius>? borderRadius = renderStyle.borderRadius;

    // The content of replaced elements is always trimmed to the content edge curve.
    // https://www.w3.org/TR/css-backgrounds-3/#corner-clipping
    if (borderRadius != null &&
        renderStyle.isSelfRenderReplaced() &&
        renderStyle.aspectRatio != null) {
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
        final double maxX = math.max(
            0.0, (_scrollableSize?.width ?? 0) - (_viewportSize?.width ?? 0));
        renderingLogger.finer(
            '[Overflow-Scroll] <${renderStyle.target.tagName.toLowerCase()}> X pixels='
            '${scrollOffsetX!.pixels.toStringAsFixed(2)} max=${maxX.toStringAsFixed(2)}');
      }
      final AxisDirection dir = (renderStyle.direction == TextDirection.rtl)
          ? AxisDirection.left
          : AxisDirection.right;
      scrollListener!(scrollOffsetX!.pixels, dir);
      if (DebugFlags.debugLogSemanticsEnabled ||
          DebugFlags.debugLogScrollableEnabled) {
        debugPrint('[webf][a11y][scroll] ${renderStyle.target} '
            'scrollX=${scrollOffsetX!.pixels.toStringAsFixed(2)} '
            'viewport=${_viewportSize?.width.toStringAsFixed(1) ?? '?'} '
            'content=${_scrollableSize?.width.toStringAsFixed(1) ?? '?'} '
            '→ markNeedsSemanticsUpdate');
      }
      // Keep semantics tree in sync with new scroll offset so accessibility
      // focus/geometry follows the visible content after programmatic scrolls.
      markNeedsSemanticsUpdate();
      markNeedsPaint();
    }
  }

  void scrollYListener() {
    assert(scrollListener != null);
    if (scrollOffsetY != null) {
      if (DebugFlags.debugLogScrollableEnabled) {
        final double maxY = math.max(
            0.0, (_scrollableSize?.height ?? 0) - (_viewportSize?.height ?? 0));
        renderingLogger.finer(
            '[Overflow-Scroll] <${renderStyle.target.tagName.toLowerCase()}> Y pixels='
            '${scrollOffsetY!.pixels.toStringAsFixed(2)} max=${maxY.toStringAsFixed(2)}');
      }
      scrollListener!(scrollOffsetY!.pixels, AxisDirection.down);
      if (DebugFlags.debugLogSemanticsEnabled ||
          DebugFlags.debugLogScrollableEnabled) {
        debugPrint('[webf][a11y][scroll] ${renderStyle.target} '
            'scrollY=${scrollOffsetY!.pixels.toStringAsFixed(2)} '
            'viewport=${_viewportSize?.height.toStringAsFixed(1) ?? '?'} '
            'content=${_scrollableSize?.height.toStringAsFixed(1) ?? '?'} '
            '→ markNeedsSemanticsUpdate');
      }
      markNeedsSemanticsUpdate();
      markNeedsPaint();
    }
  }

  void _setUpScrollX() {
    _scrollOffsetX!.applyViewportDimension(_viewportSize!.width);
    _scrollOffsetX!.applyContentDimensions(
        0.0, math.max(0.0, _scrollableSize!.width - _viewportSize!.width));
  }

  void _setUpScrollY() {
    _scrollOffsetY!.applyViewportDimension(_viewportSize!.height);
    _scrollOffsetY!.applyContentDimensions(
        0.0, math.max(0.0, _scrollableSize!.height - _viewportSize!.height));
  }

  void setUpOverflowScroller(Size scrollableSize, Size viewportSize) {
    assert(scrollableSize.isFinite);

    _scrollableSize = scrollableSize;
    _viewportSize = viewportSize;
    if (_scrollOffsetX != null) {
      _setUpScrollX();
      // Do not auto-jump scroll position for RTL containers.
      // Per CSS/UA expectations, initial scroll position is the start edge
      // of the scroll range, and user agent should not forcibly move it to
      // the visual right edge for RTL. Keeping 0 preserves expected behavior
      // for cases where overflow content lies entirely to the right.
    }

    if (_scrollOffsetY != null) {
      _setUpScrollY();
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
    final double maxScroll = math.max(
        0.0, (_scrollableSize?.width ?? 0) - (_viewportSize?.width ?? 0));
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
    return paintOffset < Offset.zero ||
        !(Offset.zero & size).contains((paintOffset & childSize).bottomRight);
  }

  final LayerHandle<ClipRRectLayer> _clipRRectLayer =
      LayerHandle<ClipRRectLayer>();
  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();

  void paintOverflow(
      PaintingContext context,
      Offset offset,
      EdgeInsets borderEdge,
      CSSBoxDecoration? decoration,
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
      PaintingContextCallback painter =
          (PaintingContext context, Offset offset) {
        callback(context, offset + paintOffset);
      };

      // If current or its descendants has a compositing layer caused by styles
      // (eg. transform, opacity, overflow...), then it needs to create a new layer
      // or else the clip in the older layer will not work.
      bool needsCompositing = this.needsCompositing;

      if (decoration != null && decoration.hasBorderRadius) {
        BorderRadius radius = decoration.borderRadius!;
        Rect rect = Offset.zero & size;
        RRect borderRRect = radius.toRRect(rect);
        // A borderRadius can only be given for a uniform Border in Flutter.
        // https://github.com/flutter/flutter/issues/12583
        double? borderTop = renderStyle.borderTopWidth?.computedValue;
        // The content of overflow is trimmed to the padding edge curve.
        // https://www.w3.org/TR/css-backgrounds-3/#corner-clipping
        RRect clipRRect =
            borderTop != null ? borderRRect.deflate(borderTop) : borderRRect;

        // The content of replaced elements is trimmed to the content edge curve.
        if (renderStyle.isSelfRenderReplaced()) {
          // @TODO: Currently only support clip uniform padding for replaced element.
          double paddingTop = renderStyle.paddingTop.computedValue;
          clipRRect = clipRRect.deflate(paddingTop);
        }
        if (DebugFlags.enableBorderRadiusLogs) {
          try {
            final el = renderStyle.target;
            renderingLogger.finer(
                '[BorderRadius] overflow clip <${el.tagName.toLowerCase()}> clipRect=${clipRect.size} '
                'tl=(${clipRRect.tlRadiusX.toStringAsFixed(2)},${clipRRect.tlRadiusY.toStringAsFixed(2)})');
          } catch (_) {}
        }
        _clipRRectLayer.layer = context.pushClipRRect(
            needsCompositing, offset, clipRect, clipRRect, painter,
            oldLayer: _clipRRectLayer.layer);
      } else {
        _clipRectLayer.layer = context.pushClipRect(
            needsCompositing, offset, clipRect, painter,
            oldLayer: _clipRectLayer.layer);
      }
    } else {
      _clipRectLayer.layer = null;
      _clipRRectLayer.layer = null;
      callback(context, offset);
    }
  }

  // For position fixed render box, should reduce the outer scroll offsets.
  void applyPositionFixedPaintTransform(
      RenderBoxModel child, Matrix4 transform) {
    // Keep `applyPaintTransform` in sync with the scroll-compensation applied in
    // RenderBoxModel.paintBoxModel.
    final Offset o = child.getFixedScrollCompensation();
    if (o.dx != 0.0 || o.dy != 0.0) transform.translate(o.dx, o.dy);
  }

  void applyOverflowPaintTransform(RenderBox child, Matrix4 transform) {
    final Offset paintOffset = Offset(_paintOffsetX, _paintOffsetY);

    if (child is RenderBoxModel &&
        child.renderStyle.position == CSSPositionType.fixed) {
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

  @override
  Rect? describeSemanticsClip(RenderObject child) {
    // By default, Flutter derives the semantics clip from the paint clip. For
    // scrolling containers this causes offscreen descendants to get their
    // semantics rect clipped to empty, making them "invisible" and dropped
    // from the semantics tree. That breaks iOS VoiceOver focus geometry updates
    // when the focused node scrolls off-screen.
    //
    // Mirror RenderViewport.describeSemanticsClip by expanding the semantics
    // clip beyond the viewport so offscreen nodes remain in the tree and are
    // instead marked hidden via the paint clip.
    final CSSOverflowType overflowX = renderStyle.effectiveOverflowX;
    final CSSOverflowType overflowY = renderStyle.effectiveOverflowY;

    final Size? viewport = _viewportSize;
    final Size? content = _scrollableSize;

    final bool xScrollable = (overflowX == CSSOverflowType.scroll ||
            overflowX == CSSOverflowType.auto) &&
        scrollOffsetX != null &&
        viewport != null &&
        content != null;
    final bool yScrollable = (overflowY == CSSOverflowType.scroll ||
            overflowY == CSSOverflowType.auto) &&
        scrollOffsetY != null &&
        viewport != null &&
        content != null;

    if (!xScrollable && !yScrollable) {
      return super.describeSemanticsClip(child);
    }

    final double maxX =
        xScrollable ? math.max(0.0, content.width - viewport.width) : 0.0;
    final double maxY =
        yScrollable ? math.max(0.0, content.height - viewport.height) : 0.0;

    final Rect bounds = semanticBounds;
    if (maxX == 0.0 && maxY == 0.0) {
      return bounds;
    }

    // Match Flutter's _RenderSingleChildViewport.describeSemanticsClip:
    // expand the semantics clip by the already scrolled distance and the
    // remaining scrollable distance, so offscreen descendants remain in the
    // semantics tree (and become hidden via paint clip instead of dropped).
    double left = bounds.left;
    double right = bounds.right;
    double top = bounds.top;
    double bottom = bounds.bottom;

    if (xScrollable) {
      final double posX = scrollLeft.clamp(0.0, maxX).toDouble();
      final double remainingX = maxX - posX;
      if (renderStyle.direction == TextDirection.rtl) {
        // Equivalent to AxisDirection.left.
        left -= remainingX;
        right += posX;
      } else {
        // AxisDirection.right.
        left -= posX;
        right += remainingX;
      }
    }

    if (yScrollable) {
      final double posY = scrollTop.clamp(0.0, maxY).toDouble();
      final double remainingY = maxY - posY;
      // AxisDirection.down.
      top -= posY;
      bottom += remainingY;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  void describeOverflowSemantics(SemanticsConfiguration config) {
    final CSSOverflowType overflowX = renderStyle.effectiveOverflowX;
    final CSSOverflowType overflowY = renderStyle.effectiveOverflowY;

    final bool xScrollable = (overflowX == CSSOverflowType.scroll ||
            overflowX == CSSOverflowType.auto) &&
        scrollOffsetX != null;
    final bool yScrollable = (overflowY == CSSOverflowType.scroll ||
            overflowY == CSSOverflowType.auto) &&
        scrollOffsetY != null;

    if (!xScrollable && !yScrollable) {
      return;
    }

    // Mirror Flutter's _RenderScrollSemantics: scrolling regions are semantic
    // boundaries with explicit child nodes, and expose scroll metrics.
    config.isSemanticBoundary = true;
    config.explicitChildNodes = true;
    config.hasImplicitScrolling = true;

    final Size? viewport = _viewportSize;
    final Size? content = _scrollableSize;
    if (viewport == null || content == null) {
      return;
    }

    final double maxX = math.max(0.0, content.width - viewport.width);
    final double maxY = math.max(0.0, content.height - viewport.height);

    // Expose primary-axis scroll metrics (prefer vertical when available).
    if (yScrollable) {
      config.scrollExtentMin = 0.0;
      config.scrollExtentMax = maxY;
      config.scrollPosition = scrollTop.clamp(0.0, maxY).toDouble();
    } else if (xScrollable) {
      config.scrollExtentMin = 0.0;
      config.scrollExtentMax = maxX;
      config.scrollPosition = scrollLeft.clamp(0.0, maxX).toDouble();
    }

    // Best-effort child count: used by some platforms to provide "x of y".
    try {
      config.scrollChildCount = renderStyle.target.childNodes.length;
    } catch (_) {}

    final bool canScroll =
        (yScrollable && maxY > 0.0) || (xScrollable && maxX > 0.0);
    if (!canScroll) {
      return;
    }

    // Semantic scroll-to-offset for implicit scrolling.
    config.onScrollToOffset = (Offset targetOffset) {
      if (yScrollable && scrollOffsetY != null) {
        final double targetY = targetOffset.dy.clamp(0.0, maxY).toDouble();
        scrollOffsetY!.jumpTo(targetY);
      }
      if (xScrollable && scrollOffsetX != null) {
        final double targetX = targetOffset.dx.clamp(0.0, maxX).toDouble();
        scrollOffsetX!.jumpTo(targetX);
      }
    };

    // Semantic scroll actions (RenderSemanticsGestureHandler-like behavior).
    if (yScrollable && scrollOffsetY != null && maxY > 0.0 && hasSize) {
      config.onScrollUp = () {
        final double delta = size.height * -_kSemanticsScrollFactor;
        final double next = (scrollTop + delta).clamp(0.0, maxY).toDouble();
        scrollOffsetY!.jumpTo(next);
      };
      config.onScrollDown = () {
        final double delta = size.height * _kSemanticsScrollFactor;
        final double next = (scrollTop + delta).clamp(0.0, maxY).toDouble();
        scrollOffsetY!.jumpTo(next);
      };
    }

    if (xScrollable && scrollOffsetX != null && maxX > 0.0 && hasSize) {
      config.onScrollLeft = () {
        final double delta = size.width * -_kSemanticsScrollFactor;
        final double next = (scrollLeft + delta).clamp(0.0, maxX).toDouble();
        scrollOffsetX!.jumpTo(next);
      };
      config.onScrollRight = () {
        final double delta = size.width * _kSemanticsScrollFactor;
        final double next = (scrollLeft + delta).clamp(0.0, maxX).toDouble();
        scrollOffsetX!.jumpTo(next);
      };
    }
  }

  @override
  void assembleSemanticsNode(SemanticsNode node, SemanticsConfiguration config,
      Iterable<SemanticsNode> children) {
    final CSSOverflowType overflowX = renderStyle.effectiveOverflowX;
    final CSSOverflowType overflowY = renderStyle.effectiveOverflowY;

    final bool xScrollable = (overflowX == CSSOverflowType.scroll ||
            overflowX == CSSOverflowType.auto) &&
        scrollOffsetX != null;
    final bool yScrollable = (overflowY == CSSOverflowType.scroll ||
            overflowY == CSSOverflowType.auto) &&
        scrollOffsetY != null;

    if (!xScrollable && !yScrollable) {
      super.assembleSemanticsNode(node, config, children);
      return;
    }

    final List<SemanticsNode> childList = children is List<SemanticsNode>
        ? children
        : children.toList(growable: false);

    int? firstVisibleIndex;
    for (final SemanticsNode child in childList) {
      if (!child.hasFlag(SemanticsFlag.isHidden)) {
        firstVisibleIndex ??= child.indexInParent;
      }
    }

    config.scrollIndex = firstVisibleIndex;
    config.scrollChildCount = childList.length;
    node.updateWith(config: config, childrenInInversePaintOrder: childList);
  }

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    final CSSOverflowType overflowX = renderStyle.effectiveOverflowX;
    final CSSOverflowType overflowY = renderStyle.effectiveOverflowY;

    final bool xScrollable = (overflowX == CSSOverflowType.scroll ||
            overflowX == CSSOverflowType.auto) &&
        scrollOffsetX != null;
    final bool yScrollable = (overflowY == CSSOverflowType.scroll ||
            overflowY == CSSOverflowType.auto) &&
        scrollOffsetY != null;

    if ((!xScrollable && !yScrollable) ||
        !hasSize ||
        descendant == null ||
        descendant is! RenderBox) {
      return super.showOnScreen(
          descendant: descendant, rect: rect, duration: duration, curve: curve);
    }

    final Size? viewport = _viewportSize;
    final Size? content = _scrollableSize;
    if (viewport == null || content == null) {
      return super.showOnScreen(
          descendant: descendant, rect: rect, duration: duration, curve: curve);
    }

    final Rect targetRect = rect ?? descendant.paintBounds;
    final Matrix4 transform = descendant.getTransformTo(this as RenderObject);
    final Rect bounds = MatrixUtils.transformRect(transform, targetRect);

    if (yScrollable && scrollOffsetY != null) {
      final double maxY = math.max(0.0, content.height - viewport.height);
      double targetScrollTop = scrollTop;
      if (bounds.top < 0.0) {
        targetScrollTop += bounds.top;
      } else if (bounds.bottom > size.height) {
        targetScrollTop += (bounds.bottom - size.height);
      }
      targetScrollTop = targetScrollTop.clamp(0.0, maxY).toDouble();
      if (duration == Duration.zero) {
        scrollOffsetY!.jumpTo(targetScrollTop);
      } else {
        scrollOffsetY!
            .animateTo(targetScrollTop, duration: duration, curve: curve);
      }
    }

    if (xScrollable && scrollOffsetX != null) {
      final double maxX = math.max(0.0, content.width - viewport.width);
      double targetScrollLeft = scrollLeft;

      final AxisDirection axisDirectionX =
          (renderStyle.direction == TextDirection.rtl)
              ? AxisDirection.left
              : AxisDirection.right;

      switch (axisDirectionX) {
        case AxisDirection.right:
          if (bounds.left < 0.0) {
            targetScrollLeft += bounds.left;
          } else if (bounds.right > size.width) {
            targetScrollLeft += (bounds.right - size.width);
          }
          break;
        case AxisDirection.left:
          if (bounds.right > size.width) {
            targetScrollLeft -= (bounds.right - size.width);
          } else if (bounds.left < 0.0) {
            targetScrollLeft -= bounds.left;
          }
          break;
        case AxisDirection.up:
        case AxisDirection.down:
          break;
      }

      targetScrollLeft = targetScrollLeft.clamp(0.0, maxX).toDouble();
      if (duration == Duration.zero) {
        scrollOffsetX!.jumpTo(targetScrollLeft);
      } else {
        scrollOffsetX!
            .animateTo(targetScrollLeft, duration: duration, curve: curve);
      }
    }

    // Let ancestors handle any additional scrolling (e.g. nested scroll views).
    super.showOnScreen(
        descendant: this as RenderObject,
        rect: null,
        duration: duration,
        curve: curve);
  }

  void debugOverflowProperties(DiagnosticPropertiesBuilder properties) {
    if (_scrollableSize != null)
      properties.add(DiagnosticsProperty('scrollableSize', _scrollableSize));
    if (_viewportSize != null)
      properties.add(DiagnosticsProperty('viewportSize', _viewportSize));
    properties.add(DiagnosticsProperty('clipX', clipX));
    properties.add(DiagnosticsProperty('clipY', clipY));
  }
}
