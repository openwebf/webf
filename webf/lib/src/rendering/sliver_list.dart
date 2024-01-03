/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/dom/sliver_manager.dart';

class RenderSliverListLayout extends RenderLayoutBox {
  // Expose viewport for sliver mixin.
  RenderViewport get viewport => _renderViewport;
  // The viewport for sliver.
  late RenderViewport _renderViewport;

  // The sliver list render object reference.
  WebFRenderSliverList? _renderSliverList;

  // The scrollable context to handle gestures.
  late WebFScrollable scrollable;

  // Called if scrolling pixel has moved.
  final ScrollListener? _scrollListener;

  // The main axis for sliver list layout.
  Axis axis = Axis.vertical;

  // The sliver box child manager
  final RenderSliverBoxChildManager _renderSliverBoxChildManager;

  RenderSliverListLayout({
    required CSSRenderStyle renderStyle,
    required RenderSliverElementChildManager manager,
    required FlutterView currentView,
    ScrollListener? onScroll,
  })  : _renderSliverBoxChildManager = manager,
        _scrollListener = onScroll,
        super(renderStyle: renderStyle) {
    scrollable = WebFScrollable(axisDirection: getAxisDirection(axis), currentView: currentView);
    axis = renderStyle.sliverDirection;

    switch (axis) {
      case Axis.horizontal:
        scrollOffsetX = scrollable.position;
        scrollOffsetY = null;
        break;
      case Axis.vertical:
        scrollOffsetX = null;
        scrollOffsetY = scrollable.position;
        break;
    }

    WebFRenderSliverList renderSliverList = _renderSliverList = _buildRenderSliverList();
    _renderViewport = RenderViewport(
      offset: scrollable.position!,
      axisDirection: scrollable.axisDirection,
      crossAxisDirection: getCrossAxisDirection(axis),
      children: [renderSliverList],
    );
    manager.setupSliverListLayout(this);
    super.insert(_renderViewport);
  }

  // Override the scrollable pointer listener.
  @override
  void Function(PointerEvent event) get scrollablePointerListener => _scrollablePointerListener;

  @override
  ScrollListener? get scrollListener => _scrollListener;

  @override
  bool get isRepaintBoundary => true;

  // Override box model methods, give the control right to sliver list.
  @override
  void add(RenderBox child) {}

  @override
  void insert(RenderBox child, {RenderBox? after}) {}

  @override
  void addAll(List<RenderBox>? children) {}

  // Insert render box child as sliver child.
  void insertSliverChild(RenderBox child, {RenderBox? after}) {
    setupParentData(child);
    _renderSliverList?.insert(child, after: after);
  }

  @override
  void remove(RenderBox child) {
    if (child == _renderViewport) {
      super.remove(child);
    } else if (child.parent == _renderSliverList) {
      _renderSliverList?.remove(child);
    }
  }

  @override
  void removeAll() {
    _renderSliverList?.removeAll();
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    if (child.parent == _renderSliverList) {
      _renderSliverList?.move(child, after: after);
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child == _renderViewport && child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    } else if (child.parentData is! SliverMultiBoxAdaptorParentData) {
      child.parentData = SliverMultiBoxAdaptorParentData();
    }
  }

  void _scrollablePointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      scrollable.handlePointerDown(event);
    } else if (event is PointerSignalEvent) {
      scrollable.handlePinterSignal(event);
    } else if (event is PointerPanZoomStartEvent) {
      scrollable.handlePointerPanZoomStart(event);
    }
  }

  @protected
  WebFRenderSliverList _buildRenderSliverList() {
    return _renderSliverList = WebFRenderSliverList(childManager: _renderSliverBoxChildManager);
  }

  // Trigger sliver list to rebuild children.
  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    _renderSliverList?.markNeedsLayout();
  }

  /// Child count should rely on element's childNodes, the real
  /// child renderObject count is not exactly.
  @override
  int get childCount => _renderSliverBoxChildManager.childCount;

  Size get _screenSize => renderStyle.currentFlutterView.physicalSize / renderStyle.currentFlutterView.devicePixelRatio;

  @override
  void performLayout() {
    doingThisLayout = true;
    beforeLayout();

    // If width is given, use exact width; or expand to parent extent width.
    // If height is given, use exact height; or use 0.
    // Only layout [renderViewport] as only-child.
    RenderBox? child = _renderViewport;
    late BoxConstraints childConstraints;

    double? width = renderStyle.width.isAuto ? null : renderStyle.width.computedValue;
    double? height = renderStyle.height.isAuto ? null : renderStyle.height.computedValue;
    Axis sliverAxis = renderStyle.sliverDirection;

    switch (sliverAxis) {
      case Axis.horizontal:
        childConstraints = BoxConstraints(
          maxWidth: width ?? 0.0,
          maxHeight: height ?? _screenSize.height,
        );
        break;
      case Axis.vertical:
        childConstraints = BoxConstraints(
          maxWidth: width ?? _screenSize.width,
          maxHeight: height ?? 0.0,
        );
        break;
    }

    child.layout(childConstraints, parentUsesSize: true);

    size = getBoxSize(child.size);

    didLayout();

    // init overflowLayout size
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

    // TODO not process child overflowLayout
    doingThisLayout = false;
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    offset += Offset(renderStyle.paddingLeft.computedValue, renderStyle.paddingTop.computedValue);

    offset +=
        Offset(renderStyle.effectiveBorderLeftWidth.computedValue, renderStyle.effectiveBorderTopWidth.computedValue);

    if (firstChild != null) {
      context.paintChild(firstChild!, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    // Get the sliver content scrolling offset.
    final Offset currentOffset = Offset(scrollLeft, scrollTop);

    // The z-index needs to be sorted, and higher-level nodes are processed first.
    for (int i = paintingOrder.length - 1; i >= 0; i--) {
      RenderBox child = paintingOrder[i];
      // Ignore detached render object.
      if (!child.attached) continue;

      final ContainerBoxParentData childParentData = child.parentData as ContainerBoxParentData<RenderBox>;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset + currentOffset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;
    }

    return false;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    super.applyPaintTransform(child, transform);
    transform.translate(scrollLeft, scrollTop);
  }

  Offset getChildScrollOffset(RenderObject child, Offset offset) {
    final RenderLayoutParentData? childParentData = child.parentData as RenderLayoutParentData?;
    bool isChildFixed = child is RenderBoxModel ? child.renderStyle.position == CSSPositionType.fixed : false;
    // Fixed elements always paint original offset
    Offset scrollOffset = isChildFixed ? childParentData!.offset : childParentData!.offset + offset;
    return scrollOffset;
  }

  static Axis resolveAxis(CSSStyleDeclaration style) {
    String? sliverDirection = style[SLIVER_DIRECTION];
    switch (sliverDirection) {
      case ROW:
        return Axis.horizontal;

      case COLUMN:
      default:
        return Axis.vertical;
    }
  }

  static AxisDirection getAxisDirection(Axis sliverAxis) {
    switch (sliverAxis) {
      case Axis.horizontal:
        return AxisDirection.right;
      case Axis.vertical:
      default:
        return AxisDirection.down;
    }
  }

  static AxisDirection getCrossAxisDirection(Axis sliverAxis) {
    switch (sliverAxis) {
      case Axis.horizontal:
        return AxisDirection.down;
      case Axis.vertical:
      default:
        return AxisDirection.right;
    }
  }
}
