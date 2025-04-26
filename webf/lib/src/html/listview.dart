/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:meta/meta.dart';
import 'package:webf/src/css/position.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

/// Tag name for the ListView element in HTML
const LISTVIEW = 'LISTVIEW';

/// Tag name for the WebF-specific ListView element in HTML
const WEBF_LISTVIEW = 'WEBF-LISTVIEW';

/// A custom element that renders a Flutter ListView in WebF
///
/// This element implements a scrollable list view that can be used in HTML with
/// either the <LISTVIEW> or <WEBF-LISTVIEW> tag names. It supports common list
/// features like:
/// - Vertical or horizontal scrolling
/// - Pull-to-refresh functionality
/// - Infinite scrolling with load-more capabilities
/// - Proper handling of absolute/fixed positioned children
///
/// The element supports these JavaScript events:
/// - 'refresh': Triggered when pull-to-refresh is activated
/// - 'loadmore': Triggered when scrolling near the end of the list
class WebFListViewElement extends WidgetElement {
  /// Creates a new FlutterListViewElement
  ///
  /// @param context The binding context for the element
  WebFListViewElement(BindingContext? context) : super(context);

  /// The scroll direction for the list view (vertical by default)
  Axis scrollDirection = Axis.vertical;

  /// Returns the horizontal scroll controller if this is a horizontal list
  @override
  ScrollController? get scrollControllerX {
    return scrollDirection == Axis.horizontal ? _scrollController : null;
  }

  /// Returns the underlying scroll controller from the state
  ScrollController? get _scrollController {
    return state?.mounted == true ? state!.scrollController : null;
  }

  /// Returns the vertical scroll controller if this is a vertical list
  @override
  ScrollController? get scrollControllerY {
    return scrollDirection == Axis.vertical ? _scrollController : null;
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
  final ScrollController? scrollController = ScrollController();

  /// Returns the widget element as a FlutterListViewElement
  ///
  /// This provides type-safe access to the parent element properties and methods.
  @override
  WebFListViewElement get widgetElement => super.widgetElement as WebFListViewElement;

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

  /// Tracks whether the list is currently loading more items
  ///
  /// When true, the loading indicator is shown at the bottom of the list and
  /// additional 'loadmore' events are prevented until loading completes.
  bool _isLoadingMore = false;
  
  /// Returns whether the list is currently loading more items
  bool get isLoadingMore => _isLoadingMore;

  /// Listens to scroll events from the ScrollController
  ///
  /// This method is called whenever the scroll position changes. It performs these tasks:
  /// - Checks if the scroll controller is valid and has clients
  /// - Calls widgetElement.handleScroll() to notify the base element of scroll position
  /// - Calls handleScroll() to potentially trigger load-more functionality
  ///
  /// The method includes error handling to prevent crashes if the scroll position
  /// becomes invalid during scrolling.
  void _scrollListener() {
    if (!mounted || !(scrollController?.hasClients == true) || (scrollController?.positions.isEmpty == true)) {
      return;
    }

    try {
      // Handle load more
      final position = scrollController!.position;
      widgetElement.handleScroll(position.pixels, position.axisDirection);
      handleScroll();
    } catch (e) {
      return;
    }
  }

  /// The style of refresh control to use
  ///
  /// - [RefreshControlStyle.platform]: Use platform default style
  /// - [RefreshControlStyle.material]: Force Material style
  /// - [RefreshControlStyle.cupertino]: Force Cupertino style
  ///
  /// This property can be overridden by subclasses to customize the refresh control style.
  @protected
  RefreshControlStyle get refreshControlStyle => RefreshControlStyle.platform;

  /// Builds the refresh indicator widget
  ///
  /// Override this method to provide custom refresh indicator UI.
  /// The default implementation returns null, which means using platform default.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Widget? buildRefreshIndicator() {
  ///   return CupertinoSliverRefreshControl(
  ///     builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
  ///       return Container(
  ///         height: refreshIndicatorExtent,
  ///         alignment: Alignment.center,
  ///         child: Image.asset('assets/logo.png'),
  ///       );
  ///     },
  ///     onRefresh: () async {
  ///       if (widgetElement.hasEventListener('refresh')) {
  ///         widgetElement.dispatchEvent(dom.Event('refresh'));
  ///         await Future.delayed(const Duration(seconds: 2));
  ///       }
  ///     },
  ///   );
  /// }
  /// ```
  @protected
  Widget? buildRefreshIndicator() {
    return null;
  }

  /// Builds the loading indicator widget for load more functionality
  ///
  /// Override this method to customize the loading indicator UI.
  /// The default implementation shows a CupertinoActivityIndicator.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Widget buildLoadMoreIndicator() {
  ///   return Image.asset('assets/logo.png');
  /// }
  /// ```
  @protected
  Widget buildLoadMoreIndicator() {
    return const CupertinoActivityIndicator();
  }

  /// Builds a widget that displays a loading indicator when loading more items
  ///
  /// This method handles the event listener check and delegates the actual loading indicator
  /// building to buildLoadMoreIndicator().
  ///
  /// This method is internal and should not be overridden by subclasses.
  /// To customize the loading indicator, override buildLoadMoreIndicator() instead.
  @nonVirtual
  @protected
  Widget buildLoadMore() {
    return widgetElement.hasEventListener('loadmore') ? Container(
      height: 50,
      alignment: Alignment.center,
      child: isLoadingMore ? buildLoadMoreIndicator() : const SizedBox.shrink(),
    ) : const SizedBox.shrink();
  }

  /// Handles scroll events from the list view
  @nonVirtual
  @protected
  void handleScroll() {
    final position = scrollController!.position;
    if (position.extentAfter < 50 && !isLoadingMore && widgetElement.hasEventListener('loadmore')) {
      _isLoadingMore = true;
      widgetElement.dispatchEvent(dom.Event('loadmore'));
      setState(() {});
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          _isLoadingMore = false;
          setState(() {});
        }
      });
    }
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
    if (index == widgetElement.childNodes.length) {
      return buildLoadMore();
    }

    Node? node = widgetElement.childNodes.elementAt(index);
    if (node is dom.Element) {
      CSSPositionType positionType = node.renderStyle.position;
      if (positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed) {
        return PositionPlaceHolder(node.holderAttachedPositionedElement!, node);
      }

      return LayoutBoxWrapper(ownerElement: node, child: widgetElement.childNodes.elementAt(index).toWidget());
    }
    return node.toWidget();
  }

  /// Builds the list view widget
  ///
  /// This method creates a CustomScrollView with the following components:
  /// - A scroll controller for managing scroll position and listening to scroll events
  /// - The scroll physics configured for the list
  /// - The configured scroll direction (vertical or horizontal)
  /// - A sliver list containing all child nodes plus the load-more indicator
  /// - A refresh control for pull-to-refresh functionality
  ///
  /// The resulting scroll view is wrapped in a WebFChildNodeSize widget to properly
  /// size it according to the parent element, and conditionally wrapped in a
  /// platform-specific refresh indicator based on the hasRefreshIndicator() result.
  @override
  Widget build(BuildContext context) {
    Widget scrollView = CustomScrollView(
      controller: scrollController,
      physics: scrollPhysics,
      scrollDirection: widgetElement.scrollDirection,
      slivers: [
        _buildRefreshControl(),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return buildListViewItemByIndex(index);
            },
            childCount: widgetElement.childNodes.length + 1,
          ),
        ),
      ],
    );

    // If custom refresh indicator is provided, use it
    final customIndicator = buildRefreshIndicator();
    if (customIndicator != null) {
      return WebFChildNodeSize(
        ownerElement: widgetElement,
        child: scrollView,
      );
    }

    final isCupertinoStyle = refreshControlStyle == RefreshControlStyle.cupertino ||
        (refreshControlStyle == RefreshControlStyle.platform &&
            (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS));

    if (isCupertinoStyle) {
      return WebFChildNodeSize(
        ownerElement: widgetElement,
        child: scrollView,
      );
    } else {
      // Material style
      return WebFChildNodeSize(
        ownerElement: widgetElement,
        child: RefreshIndicator(
          onRefresh: () async {
            if (widgetElement.hasEventListener('refresh')) {
              widgetElement.dispatchEvent(dom.Event('refresh'));
              await Future.delayed(const Duration(seconds: 2));
            }
          },
          child: scrollView,
        ),
      );
    }
  }

  Widget _buildRefreshControl() {
    // If custom refresh indicator is provided, use it
    final customIndicator = buildRefreshIndicator();
    if (customIndicator != null) {
      return customIndicator;
    }

    final isCupertinoStyle = refreshControlStyle == RefreshControlStyle.cupertino ||
        (refreshControlStyle == RefreshControlStyle.platform &&
            (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS));

    if (isCupertinoStyle) {
      return CupertinoSliverRefreshControl(
        onRefresh: () async {
          if (widgetElement.hasEventListener('refresh')) {
            widgetElement.dispatchEvent(dom.Event('refresh'));
            await Future.delayed(const Duration(seconds: 2));
          }
        },
      );
    } else {
      // Material style doesn't need a sliver refresh control
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  /// Defines the scroll physics to use for the list view
  ///
  /// Returns a BouncingScrollPhysics with AlwaysScrollableScrollPhysics as parent,
  /// which provides iOS-style bouncing overscroll effect and ensures the list view
  /// is always scrollable even when content fits within the viewport.
  ///
  /// The bounce effect provides visual feedback to users when they reach the edges of
  /// the content and enhances the pull-to-refresh experience.
  ScrollPhysics get scrollPhysics =>
      const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
}

/// The style of refresh control to use
enum RefreshControlStyle {
  /// Use platform default style (Material on Android, Cupertino on iOS/macOS)
  platform,
  
  /// Force Material style
  material,
  
  /// Force Cupertino style
  cupertino,
}
