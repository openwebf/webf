/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:webf/css.dart';
import 'package:webf/src/css/position.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;
import 'package:easy_refresh/easy_refresh.dart';

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
  }

  /// Resets the refresh header to its initial state
  ///
  /// This method programmatically resets the pull-to-refresh header to its
  /// initial state, canceling any ongoing refresh operation and hiding any
  /// refresh indicators. This is useful when you need to abort a refresh
  /// operation without completing it.
  void resetHeader() {
    state?.refreshController.resetHeader();
  }

  /// Resets the load-more footer to its initial state
  ///
  /// This method programmatically resets the load-more footer to its
  /// initial state, canceling any ongoing load operation and hiding any
  /// load indicators. This is useful when you need to abort a load-more
  /// operation without completing it.
  void resetFooter() {
    state?.refreshController.resetFooter();
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

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, listViewMethods];
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
    if (node is dom.Element) {
      CSSPositionType positionType = node.renderStyle.position;
      if (positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed) {
        return PositionPlaceHolder(node.holderAttachedPositionedElement!, node);
      }

      return LayoutBoxWrapper(ownerElement: node, child: widgetElement.childNodes.elementAt(index).toWidget());
    }
    return node.toWidget();
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
    return EasyRefresh(
        header: buildEasyRefreshHeader(),
        footer: buildEasyRefreshFooter(),
        onLoad: widgetElement.hasEventListener('loadmore') ? onLoad : null,
        onRefresh: widgetElement.hasEventListener('refresh') ? onRefresh : null,
        controller: refreshController,
        child: ListView.builder(
            controller: scrollController,
            scrollDirection: widgetElement.scrollDirection,
            shrinkWrap: true,
            itemCount: widgetElement.childNodes.length,
            itemBuilder: (context, index) {
              return buildListViewItemByIndex(index);
            }));
  }
}
