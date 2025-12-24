/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:webf/css.dart';
import 'package:webf/src/css/position.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;
import 'package:easy_refresh/easy_refresh.dart';
import 'listview_bindings_generated.dart';

class _WebFListViewNoScrollbarScrollBehavior extends ScrollBehavior {
  static final Set<PointerDeviceKind> _kDragDevices = PointerDeviceKind.values.toSet();

  final ScrollPhysics? _physics;

  const _WebFListViewNoScrollbarScrollBehavior([this._physics]);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics ?? super.getScrollPhysics(context);
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => _kDragDevices;
}

/// Tag name for the ListView element in HTML
const listView = 'LISTVIEW';

/// Tag name for the WebF-specific ListView element in HTML
const webfListView = 'WEBF-LISTVIEW';
const webfListView2 = 'WEBF-LIST-VIEW';

/// A custom element that renders a Flutter ListView in WebF
///
/// This element implements a scrollable list view that can be used in HTML with
/// either the `<LISTVIEW>` or `<WEBF-LISTVIEW>` tag names. It supports common list
/// features like:
/// - Vertical or horizontal scrolling
/// - Pull-to-refresh functionality
/// - Infinite scrolling with load-more capabilities
/// - Proper handling of absolute/fixed positioned children
///
/// The element supports these JavaScript events:
/// - 'refresh': Triggered when pull-to-refresh is activated
/// - 'loadmore': Triggered when scrolling near the end of the list
class WebFListViewElement extends WebFListViewBindings {
  /// Creates a new FlutterListViewElement
  ///
  /// @param context The binding context for the element
  WebFListViewElement(BindingContext? context) : super(context) {
    if (context != null) {
      ownerView.window.watchViewportSizeChangeForElement(this);
    }
  }

  @override
  bool get allowsInfiniteWidth =>
      // Only loosen horizontal constraints when the list scrolls horizontally;
      // vertical lists need a bounded cross-axis width to satisfy Flutter's
      // shrink-wrapping viewport requirements.
      axis == Axis.horizontal;

  /// Internal Flutter scroll axis (vertical by default)
  Axis _axis = Axis.vertical;

  /// Expose Flutter axis for internal engine usage
  Axis get axis => _axis;

  @override
  WebFListViewScrollDirection? get scrollDirection =>
      _axis == Axis.horizontal ? WebFListViewScrollDirection.horizontal : WebFListViewScrollDirection.vertical;

  @override
  set scrollDirection(value) {
    // Accept enum or string for robustness
    WebFListViewScrollDirection? dir;
    if (value == null) {
      dir = null;
    } else if (value is WebFListViewScrollDirection) {
      dir = value;
    } else if (value is String) {
      dir = WebFListViewScrollDirection.parse(value);
    }

    if (dir != null) {
      final nextAxis = dir == WebFListViewScrollDirection.horizontal ? Axis.horizontal : Axis.vertical;
      if (nextAxis != _axis) {
        _axis = nextAxis;
        state?.requestUpdateState();
      }
    }
  }

  bool _shrinkWrap = true;

  @override
  bool get shrinkWrap => _shrinkWrap;

  @override
  set shrinkWrap(value) {
    if (value is bool) {
      _shrinkWrap = value;
    } else if (value is String) {
      _shrinkWrap = value == 'true' || value == '';
    } else {
      _shrinkWrap = true; // default value
    }
    state?.requestUpdateState();
  }

  /// Returns the horizontal scroll controller if this is a horizontal list
  @override
  ScrollController? get scrollControllerX {
    return _axis == Axis.horizontal ? _scrollController : null;
  }

  /// Returns the underlying scroll controller from the state
  ScrollController? get _scrollController {
    return state?.mounted == true ? state!.scrollController : null;
  }

  /// Returns the vertical scroll controller if this is a vertical list
  @override
  ScrollController? get scrollControllerY {
    return _axis == Axis.vertical ? _scrollController : null;
  }

  /// Indicates that this element can be scrolled
  @override
  bool get isScrollingElement => true;

  /// Returns the element's state as a WebFListViewState
  @override
  WebFListViewState? get state => super.state as WebFListViewState?;

  /// Creates the state object for this element
  @override
  WebFWidgetElementState createState() {
    return WebFListViewState(this);
  }

  // Accept style/attribute updates to control scroll direction for this custom element.
  // Supports both 'scroll-direction' and 'scrollDirection'. Values: 'horizontal' | 'vertical'.
  void _updateScrollDirectionFromValue(String value) {
    final v = value.trim().toLowerCase();
    if (v == 'horizontal' || v == 'row' || v == 'x' || v == 'h') {
      scrollDirection = WebFListViewScrollDirection.horizontal;
    } else {
      scrollDirection = WebFListViewScrollDirection.vertical;
    }
  }

  @override
  void attributeDidUpdate(String key, String value) {
    super.attributeDidUpdate(key, value);
    if (key == 'scroll-direction' || key == 'scrollDirection') {
      _updateScrollDirectionFromValue(value);
    }
  }

  /// Parses a string indicator result to the corresponding EasyRefresh IndicatorResult enum
  ///
  /// @param result The result string, can be 'success', 'fail', 'noMore' or any other value
  /// @return The corresponding IndicatorResult enum value
  ///   - IndicatorResult.success for 'success'
  ///   - IndicatorResult.fail for 'fail'
  ///   - IndicatorResult.noMore for 'noMore'
  ///   - IndicatorResult.none for any other value
  IndicatorResult _parseIndicatorResult(String result) {
    IndicatorResult indicatorResult;
    switch (result) {
      case 'success':
        indicatorResult = IndicatorResult.success;
        break;
      case 'fail':
        indicatorResult = IndicatorResult.fail;
        break;
      case 'noMore':
        indicatorResult = IndicatorResult.noMore;
        break;
      default:
        indicatorResult = IndicatorResult.none;
    }
    return indicatorResult;
  }

  /// Completes a refresh operation with the specified result
  ///
  /// This method finishes the current pull-to-refresh operation and displays
  /// the appropriate indicator based on the result parameter.
  ///
  /// @param result The result of the refresh operation, can be:
  ///   - 'success': The refresh was successful (default)
  ///   - 'fail': The refresh operation failed
  ///   - 'noMore': There is no more data to refresh
  ///   - Any other value: No specific result indicator is shown
  void finishRefresh(String result) {
    state?.refreshController.finishRefresh(_parseIndicatorResult(result));
    state?._isRefreshing = false;
  }

  /// Completes a load-more operation with the specified result
  ///
  /// This method finishes the current load-more operation and displays
  /// the appropriate indicator based on the result parameter.
  ///
  /// @param result The result of the load-more operation, can be:
  ///   - 'success': The load operation was successful (default)
  ///   - 'fail': The load operation failed
  ///   - 'noMore': There is no more data to load
  ///   - Any other value: No specific result indicator is shown
  void finishLoad(String result) {
    state?.refreshController.finishLoad(_parseIndicatorResult(result));
    state?._isLoading = false;
  }

  /// Resets the refresh header to its initial state
  ///
  /// This method programmatically resets the pull-to-refresh header to its
  /// initial state, canceling any ongoing refresh operation and hiding any
  /// refresh indicators. This is useful when you need to abort a refresh
  /// operation without completing it.
  void resetHeader() {
    state?.refreshController.resetHeader();
    state?._isRefreshing = false;
  }

  /// Resets the load-more footer to its initial state
  ///
  /// This method programmatically resets the load-more footer to its
  /// initial state, canceling any ongoing load operation and hiding any
  /// load indicators. This is useful when you need to abort a load-more
  /// operation without completing it.
  void resetFooter() {
    state?.refreshController.resetFooter();
    state?._isLoading = false;
  }

  static StaticDefinedSyncBindingObjectMethodMap listViewMethods = {
    'finishRefresh': StaticDefinedSyncBindingObjectMethod(
        call: (bindingObject, args) =>
            castToType<WebFListViewElement>(bindingObject).finishRefresh(args.isNotEmpty ? args[0] : 'success')),
    'finishLoad': StaticDefinedSyncBindingObjectMethod(
        call: (bindingObject, args) =>
            castToType<WebFListViewElement>(bindingObject).finishLoad(args.isNotEmpty ? args[0] : 'success')),
    'resetHeader': StaticDefinedSyncBindingObjectMethod(
        call: (bindingObject, args) => castToType<WebFListViewElement>(bindingObject).resetHeader()),
    'resetFooter': StaticDefinedSyncBindingObjectMethod(
        call: (bindingObject, args) => castToType<WebFListViewElement>(bindingObject).resetFooter())
  };

  static final StaticDefinedAsyncBindingObjectMethodMap listViewAsyncMethods = {
    'scrollByIndex': StaticDefinedAsyncBindingObjectMethod(call: (bindingObject, args) async {
      final element = castToType<WebFListViewElement>(bindingObject);
      if (args.isEmpty) return false;
      final int? index = _coerceInt(args[0]);
      if (index == null) return false;

      final dynamic options = args.length > 1 ? args[1] : null;
      bool animated = true;
      int durationMs = 250;
      double? alignment;

      if (options is bool) {
        animated = options;
      } else if (options is num) {
        durationMs = options.toInt();
      } else if (options is Map) {
        final dynamic animatedOption = options['animated'];
        if (animatedOption is bool) animated = animatedOption;

        final dynamic durationOption = options['duration'];
        if (durationOption is num) durationMs = durationOption.toInt();

        final dynamic alignmentOption = options['alignment'];
        if (alignmentOption is num) alignment = alignmentOption.toDouble();
      }

      return element.scrollByIndex(
        index,
        animated: animated,
        duration: Duration(milliseconds: durationMs),
        alignment: alignment,
      );
    }),
  };

  /// Scrolls this ListView until the item at [index] is visible.
  ///
  /// This is designed for lazily-built lists where the total scroll extent can't be
  /// known up front. For the last item (`index == childNodes.length - 1`), this will
  /// repeatedly scroll to the current `maxScrollExtent` until the end stabilizes.
  Future<bool> scrollByIndex(
    int index, {
    bool animated = true,
    Duration duration = const Duration(milliseconds: 250),
    double? alignment,
  }) async {
    final WebFListViewState? currentState = state;
    if (currentState == null) return false;
    return await currentState.scrollByIndex(
      index,
      animated: animated,
      duration: duration,
      alignment: alignment,
    );
  }

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, listViewMethods];

  @override
  List<StaticDefinedAsyncBindingObjectMethodMap> get asyncMethods => [...super.asyncMethods, listViewAsyncMethods];
}

/// State class for the FlutterListViewElement
///
/// This class manages the state for the ListView element, including:
/// - Scroll controller management
/// - Scroll event handling
/// - Load-more functionality
/// - Refresh control rendering
/// - ListView item building
class WebFListViewState extends WebFWidgetElementState {
  /// Creates a new WebFListViewState
  ///
  /// @param widgetElement The FlutterListViewElement this state belongs to
  WebFListViewState(super.widgetElement);

  /// A dedicated ScrollController to manage scrolling for this list
  ///
  /// This controller provides access to scroll position, enables programmatic
  /// scrolling, and allows listening to scroll events.
  /// When in a nested scroll context (e.g., inside NestedScrollView), this may
  /// be null if using the parent's scroll controller.
  ScrollController? scrollController;

  /// Controller for the EasyRefresh widget that manages refresh and loading states
  ///
  /// This controller provides programmatic control over refresh and load operations,
  /// including the ability to manually trigger or finish these operations from code.
  /// The controlFinishLoad and controlFinishRefresh flags are set to true to enable
  /// manual control over when refresh and load operations complete.
  final EasyRefreshController refreshController =
      EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);

  /// Returns the widget element as a FlutterListViewElement
  ///
  /// This provides type-safe access to the parent element properties and methods.
  @override
  WebFListViewElement get widgetElement => super.widgetElement as WebFListViewElement;

  @override
  void initState() {
    super.initState();
    // Only create our own ScrollController if we're not in a nested scroll context
    // This will be checked and potentially overridden in didChangeDependencies
    scrollController = ScrollController();
  }

  /// Cleans up resources when the state is disposed
  ///
  /// This method is called when the element is removed from the DOM or when the widget
  /// is removed from the widget tree. It:
  /// - Removes scroll event listeners to prevent memory leaks
  /// - Disposes the scroll controller to free resources
  @override
  void dispose() {
    super.dispose();
    scrollController?.removeListener(_scrollListener);
    scrollController?.dispose();
    refreshController.dispose();
  }

  /// Sets up dependencies when the state is initialized or dependencies change
  ///
  /// This method is called when the state is first created and whenever the
  /// widget's dependencies change. It sets up the scroll listener to track
  /// scroll events.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scrollController?.addListener(_scrollListener);
  }

  /// Listens to scroll events from the ScrollController
  ///
  /// This method is called whenever the scroll position changes. It performs these tasks:
  /// - Checks if the scroll controller is valid and has clients
  /// - Calls widgetElement.handleScroll() to notify the base element of scroll position
  ///
  /// The method includes error handling to prevent crashes if the scroll position
  /// becomes invalid during scrolling.
  /// Note: This is only used when we have our own controller (non-nested case)
  void _scrollListener() {
    if (!mounted || scrollController == null || !scrollController!.hasClients || scrollController!.positions.isEmpty) {
      return;
    }

    try {
      // Handle scroll events from our own controller
      final position = scrollController!.position;
      widgetElement.handleScroll(position.pixels, position.axisDirection);
    } catch (e) {
      return;
    }
  }

  /// Flag that tracks whether a refresh operation is currently in progress
  ///
  /// This is used to implement an automatic timeout for refresh operations
  /// that aren't explicitly completed by calling finishRefresh()
  bool _isRefreshing = false;

  /// Flag that tracks whether a load-more operation is currently in progress
  ///
  /// This is used to implement an automatic timeout for load operations
  /// that aren't explicitly completed by calling finishLoad()
  bool _isLoading = false;

  final Map<int, BuildContext> _mountedItemContexts = {};

  void _registerItemContext(int index, BuildContext context) {
    _mountedItemContexts[index] = context;
  }

  void _unregisterItemContext(int index) {
    _mountedItemContexts.remove(index);
  }

  static bool _isUsableContext(BuildContext context) {
    final RenderObject? ro = context.findRenderObject();
    return ro != null && ro.attached;
  }

  ({int min, int max})? _mountedIndexRange() {
    if (_mountedItemContexts.isEmpty) return null;
    int minIndex = _mountedItemContexts.keys.first;
    int maxIndex = minIndex;
    for (final i in _mountedItemContexts.keys) {
      if (i < minIndex) minIndex = i;
      if (i > maxIndex) maxIndex = i;
    }
    return (min: minIndex, max: maxIndex);
  }

  Future<void> _scrollTo(
    double offset, {
    required bool animated,
    required Duration duration,
    Curve curve = Curves.ease,
  }) async {
    final ScrollController? controller = scrollController;
    if (!mounted || controller == null || !controller.hasClients) return;

    final position = controller.position;
    final double target = offset.clamp(position.minScrollExtent, position.maxScrollExtent);
    if (!animated || duration == Duration.zero) {
      controller.jumpTo(target);
      return;
    }
    await controller.animateTo(target, duration: duration, curve: curve);
  }

  Future<void> _scrollToStableExtent({
    required bool toMax,
    required bool animated,
    required Duration duration,
    Curve curve = Curves.ease,
    int maxAttempts = 24,
  }) async {
    final ScrollController? controller = scrollController;
    if (!mounted || controller == null || !controller.hasClients) return;

    double lastPixels = controller.position.pixels;
    double lastExtent = toMax ? controller.position.maxScrollExtent : controller.position.minScrollExtent;
    int stableCount = 0;

    for (int i = 0; i < maxAttempts; i++) {
      final position = controller.position;
      final double target = toMax ? position.maxScrollExtent : position.minScrollExtent;
      await _scrollTo(target, animated: animated, duration: duration, curve: curve);
      await SchedulerBinding.instance.endOfFrame;

      final double pixels = controller.position.pixels;
      final double extent = toMax ? controller.position.maxScrollExtent : controller.position.minScrollExtent;
      final bool moved = (pixels - lastPixels).abs() > 0.5;
      final bool extentChanged = (extent - lastExtent).abs() > 0.5;

      if (!moved && !extentChanged) {
        stableCount++;
      } else {
        stableCount = 0;
      }
      if (stableCount >= 2) {
        return;
      }
      lastPixels = pixels;
      lastExtent = extent;
    }
  }

  /// Scrolls the ListView until the item at [index] is mounted, then ensures it's visible.
  ///
  /// Returns `true` if the item was found and scrolled into view.
  Future<bool> scrollByIndex(
    int index, {
    bool animated = true,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.ease,
    double? alignment,
    int maxAttempts = 80,
  }) async {
    final ScrollController? controller = scrollController;
    if (!mounted || controller == null || !controller.hasClients) return false;

    final int itemCount = widgetElement.childNodes.length;
    if (itemCount == 0) return false;

    final int targetIndex = index.clamp(0, itemCount - 1);
    final bool isLast = targetIndex == itemCount - 1;
    final bool isFirst = targetIndex == 0;
    final double effectiveAlignment = alignment ?? (isLast ? 1.0 : 0.0);

    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return false;

    BuildContext? targetContext = _mountedItemContexts[targetIndex];
    if (targetContext != null && targetContext.mounted && _isUsableContext(targetContext)) {
      await WebFEnsureVisible.acrossScrollables(
        targetContext,
        duration: duration,
        curve: curve,
        alignment: effectiveAlignment,
        axis: widgetElement.axis,
      );
      return true;
    }

    // Fast path for the edges: keep scrolling to the extent until it stabilizes,
    // then try to reveal the target item.
    if (isLast) {
      await _scrollToStableExtent(toMax: true, animated: animated, duration: duration, curve: curve);
    } else if (isFirst) {
      await _scrollToStableExtent(toMax: false, animated: animated, duration: duration, curve: curve);
    } else {
      // Jump close to the estimated offset to reduce the number of viewport steps.
      try {
        final position = controller.position;
        final double ratio = itemCount <= 1 ? 0.0 : targetIndex / (itemCount - 1);
        final double estimate = position.minScrollExtent + (position.maxScrollExtent - position.minScrollExtent) * ratio;
        await _scrollTo(estimate, animated: false, duration: Duration.zero);
      } catch (_) {
        // Ignore transient errors while layout is changing.
      }
    }

    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return false;
    targetContext = _mountedItemContexts[targetIndex];
    if (targetContext != null && targetContext.mounted && _isUsableContext(targetContext)) {
      await WebFEnsureVisible.acrossScrollables(
        targetContext,
        duration: duration,
        curve: curve,
        alignment: effectiveAlignment,
        axis: widgetElement.axis,
      );
      return true;
    }

    // Progressive scrolling: step by viewport size until the target index is mounted.
    double lastPixels = controller.position.pixels;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final range = _mountedIndexRange();
      final int direction;
      if (range == null) {
        direction = isLast ? 1 : -1;
      } else if (targetIndex > range.max) {
        direction = 1;
      } else if (targetIndex < range.min) {
        direction = -1;
      } else {
        // Target is within mounted range but we don't have a usable context yet.
        requestUpdateState();
        await SchedulerBinding.instance.endOfFrame;
        if (!mounted) return false;
        targetContext = _mountedItemContexts[targetIndex];
        if (targetContext != null && targetContext.mounted && _isUsableContext(targetContext)) {
          await WebFEnsureVisible.acrossScrollables(
            targetContext,
            duration: duration,
            curve: curve,
            alignment: effectiveAlignment,
            axis: widgetElement.axis,
          );
          return true;
        }
        break;
      }

      final position = controller.position;
      final double viewport = position.viewportDimension > 0 ? position.viewportDimension : 200;
      final double next = position.pixels + direction * viewport * 0.85;

      try {
        await _scrollTo(
          next,
          animated: animated,
          duration: Duration(milliseconds: math.min(250, duration.inMilliseconds)),
          curve: curve,
        );
      } catch (_) {
        // Ignore transient errors while layout is changing.
      }

      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return false;

      targetContext = _mountedItemContexts[targetIndex];
      if (targetContext != null && targetContext.mounted && _isUsableContext(targetContext)) {
        await WebFEnsureVisible.acrossScrollables(
          targetContext,
          duration: duration,
          curve: curve,
          alignment: effectiveAlignment,
          axis: widgetElement.axis,
        );
        return true;
      }

      final double pixels = controller.position.pixels;
      final bool moved = (pixels - lastPixels).abs() > 0.5;
      if (!moved && controller.position.atEdge) {
        // We can't make progress anymore.
        break;
      }
      lastPixels = pixels;
    }

    // If we were asked to scroll to the last index, consider reaching the end sufficient,
    // even if the target widget isn't mounted (e.g. removed mid-scroll).
    if (isLast) {
      return controller.hasClients && controller.position.pixels >= controller.position.maxScrollExtent - 0.5;
    }

    return false;
  }

  /// Builds a widget for a specific index in the list view
  ///
  /// This method handles the creation of list item widgets based on their index:
  /// - If the index is equal to the number of child nodes, it returns the load-more indicator
  /// - For DOM elements with absolute or fixed positioning, it creates a PositionPlaceHolder
  /// - For regular DOM elements, it wraps them in a LayoutBoxWrapper
  /// - For non-element nodes, it directly converts them to widgets
  ///
  /// This method is marked as @nonVirtual and should not be overridden by subclasses.
  @nonVirtual
  @protected
  Widget buildListViewItemByIndex(int index) {
    Node? node = widgetElement.childNodes.elementAt(index);
    Widget child;
    if (node is dom.Element) {
      CSSPositionType positionType = node.renderStyle.position;
      if (positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed) {
        child = PositionPlaceHolder(node.holderAttachedPositionedElement!, node);
      } else {
        child = LayoutBoxWrapper(ownerElement: node, child: widgetElement.childNodes.elementAt(index).toWidget());
      }
    } else {
      child = node.toWidget();
    }

    // Track mounted item contexts so we can scroll to an index in a lazily-built list.
    return KeyedSubtree(
      key: ValueKey<int>(index),
      child: _WebFListViewIndexMarker(
        index: index,
        onMountOrUpdate: _registerItemContext,
        onUnmount: _unregisterItemContext,
        child: child,
      ),
    );
  }

  /// Builds the header widget for pull-to-refresh functionality
  ///
  /// This method can be overridden by subclasses to customize the pull-to-refresh header.
  /// By default, it returns null, which causes EasyRefresh to use its default header.
  ///
  /// @return A custom Header widget, or null to use the default
  Header? buildEasyRefreshHeader() {
    return null;
  }

  /// Builds the footer widget for load-more functionality
  ///
  /// This method can be overridden by subclasses to customize the load-more footer.
  /// By default, it returns null, which causes EasyRefresh to use its default footer.
  ///
  /// @return A custom Footer widget, or null to use the default
  Footer? buildEasyRefreshFooter() {
    return null;
  }

  onLoad() async {
    await widgetElement.dispatchEvent(Event('loadmore'));
    _isLoading = true;

    await Future.delayed(Duration(seconds: 4));
    if (_isLoading) {
      refreshController.finishLoad();
      _isLoading = false;
    }
  }

  onRefresh() async {
    await widgetElement.dispatchEvent(Event('refresh'));
    _isRefreshing = true;
    await Future.delayed(Duration(seconds: 4));
    if (_isRefreshing) {
      refreshController.finishRefresh();
      _isRefreshing = false;
    }
  }

  /// Builds the list view widget
  ///
  /// This method creates an EasyRefresh widget with the following components:
  /// - Custom header and footer components (if provided by buildEasyRefreshHeader/Footer)
  /// - Event handlers for refresh and load-more operations
  /// - Automatic timeout handling for refresh and load operations
  /// - A ListView.builder as the main content with:
  ///   - A scroll controller for managing scroll position and listening to scroll events
  ///   - The configured scroll direction (vertical or horizontal)
  ///   - Dynamic item building based on child nodes
  ///
  /// The EasyRefresh widget provides pull-to-refresh and load-more functionality with
  /// customizable indicators and behavior. It dispatches 'refresh' and 'loadmore' events
  /// that can be handled in JavaScript.
  @override
  Widget build(BuildContext context) {
    // Build the ListView
    Widget listView = ListView.builder(
        controller: scrollController,
        scrollDirection: widgetElement.axis,
        shrinkWrap: widgetElement.shrinkWrap,
        itemCount: widgetElement.childNodes.length,
        itemBuilder: (context, index) {
          return buildListViewItemByIndex(index);
        });

    // Honor CSS 'direction' for horizontal lists by providing a Directionality
    // so Flutter computes axisDirection = left for RTL and right for LTR.
    if (widgetElement.axis == Axis.horizontal) {
      listView = Directionality(
        textDirection: widgetElement.renderStyle.direction,
        child: listView,
      );
    }

    // Wrap the ListView with NestedScrollCoordinator to handle incoming scroll from nested elements
    // This allows the ListView to receive scroll events from nested overflow containers or ListViews
    Widget result = listView;
    if (scrollController != null) {
      result = NestedScrollCoordinator(
        axis: widgetElement.axis,
        controller: scrollController!,
        child: result,
      );
    }

    // Wrap with EasyRefresh for pull-to-refresh functionality
    // Use the configured scroll behavior
    result = EasyRefresh(
        header: buildEasyRefreshHeader(),
        footer: buildEasyRefreshFooter(),
        onLoad: widgetElement.hasEventListener('loadmore') ? onLoad : null,
        onRefresh: widgetElement.hasEventListener('refresh') ? onRefresh : null,
        controller: refreshController,
        scrollBehaviorBuilder: (physics) => _WebFListViewNoScrollbarScrollBehavior(physics),
        child: result);

    // Finally, wrap with NestedScrollForwarder to provide scroll controller to nested elements
    // This allows nested overflow containers and ListViews to find this controller
    if (scrollController != null) {
      result = NestedScrollForwarder(
        verticalController: widgetElement.axis == Axis.vertical ? scrollController : null,
        horizontalController: widgetElement.axis == Axis.horizontal ? scrollController : null,
        child: result,
      );
    }

    return result;
  }
}

int? _coerceInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class _WebFListViewIndexMarker extends StatefulWidget {
  const _WebFListViewIndexMarker({
    required this.index,
    required this.onMountOrUpdate,
    required this.onUnmount,
    required this.child,
  });

  final int index;
  final void Function(int index, BuildContext context) onMountOrUpdate;
  final void Function(int index) onUnmount;
  final Widget child;

  @override
  State<_WebFListViewIndexMarker> createState() => _WebFListViewIndexMarkerState();
}

class _WebFListViewIndexMarkerState extends State<_WebFListViewIndexMarker> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onMountOrUpdate(widget.index, context);
  }

  @override
  Widget build(BuildContext context) {
    widget.onMountOrUpdate(widget.index, context);
    return widget.child;
  }

  @override
  void dispose() {
    widget.onUnmount(widget.index);
    super.dispose();
  }
}
