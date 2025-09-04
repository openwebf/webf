/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

enum ScreenEventType { onScreen, offScreen }

class ScreenEvent {
  final ScreenEventType type;
  final OnScreenEvent? onScreenEvent;
  final OffScreenEvent? offScreenEvent;
  final DateTime timestamp;

  ScreenEvent.onScreen(this.onScreenEvent)
      : type = ScreenEventType.onScreen,
        offScreenEvent = null,
        timestamp = DateTime.now();

  ScreenEvent.offScreen(this.offScreenEvent)
      : type = ScreenEventType.offScreen,
        onScreenEvent = null,
        timestamp = DateTime.now();
}

mixin ElementAdapterMixin on ElementBase {
  final List<Element> _fixedPositionElements = [];

  // Track the screen state and event queue
  final List<ScreenEvent> _screenEventQueue = [];
  bool _isProcessingQueue = false;

  @flutter.immutable
  List<Element> get fixedPositionElements => _fixedPositionElements;

  void addFixedPositionedElement(Element newElement) {
    assert(() {
      if (_fixedPositionElements.contains(newElement)) {
        throw FlutterError('Found repeat element in $_fixedPositionElements for $newElement');
      }

      return true;
    }());
    _fixedPositionElements.add(newElement);
  }

  Element? getFixedPositionedElementByIndex(int index) {
    return (index >= 0 && index < _fixedPositionElements.length ? _fixedPositionElements[index] : null);
  }

  void removeFixedPositionedElement(Element element) {
    _fixedPositionElements.remove(element);
  }

  void clearFixedPositionedElements() {
    _fixedPositionElements.clear();
  }

  // Rendering this element as an RenderPositionHolder
  Element? holderAttachedPositionedElement;
  Element? holderAttachedContainingBlockElement;

  flutter.ScrollController? _scrollControllerX;

  flutter.ScrollController? get scrollControllerX => _scrollControllerX;

  flutter.ScrollController? _scrollControllerY;

  flutter.ScrollController? get scrollControllerY => _scrollControllerY;

  final Set<flutter.RenderObjectElement> positionHolderElements = {};

  bool hasEvent = false;
  bool hasScroll = false;

  void enqueueScreenEvent(ScreenEvent event) {
    // If we're enqueuing an onScreen event, remove any pending offScreen events
    if (event.type == ScreenEventType.onScreen) {
      _screenEventQueue.removeWhere((e) => e.type == ScreenEventType.offScreen);
    }

    _screenEventQueue.add(event);
    _processEventQueue();
  }

  void _processEventQueue() {
    if (_isProcessingQueue || _screenEventQueue.isEmpty) return;

    _isProcessingQueue = true;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      while (_screenEventQueue.isNotEmpty) {
        final event = _screenEventQueue.removeAt(0);

        // Process events based on current state and event type
        if (event.type == ScreenEventType.offScreen) {
          await (this as Element).dispatchEvent(event.offScreenEvent!);
        } else if (event.type == ScreenEventType.onScreen) {
          // Only dispatch onScreen if we're not already on screen
          await (this as Element).dispatchEventUtilAdded(event.onScreenEvent!);
        }
      }
      _isProcessingQueue = false;
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  @override
  flutter.Widget toWidget({Key? key}) {
    return WebFElementWidget(this as Element, key: key ?? (this as Element).key);
  }
}

class WebFElementWidget extends flutter.StatefulWidget {
  final Element webFElement;

  WebFElementWidget(this.webFElement, {super.key}) : super() {
    webFElement.managedByFlutterWidget = true;
  }

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return WebFElementWidgetState();
  }

  @override
  String toStringShort() {
    String attributes = '';
    if (webFElement.id != null) {
      attributes += 'id="${webFElement.id!}"';
    }
    if (webFElement.className.isNotEmpty) {
      attributes += 'class="${webFElement.className}"';
    }

    return '<${webFElement.tagName.toLowerCase()}#$hashCode $attributes>';
  }
}

class WebFElementWidgetState extends flutter.State<WebFElementWidget> with flutter.AutomaticKeepAliveClientMixin {
  late final Element webFElement;

  @override
  void initState() {
    super.initState();
    webFElement = widget.webFElement;
    webFElement.addState(this);
  }

  void requestForChildNodeUpdate(AdapterUpdateReason reason) {
    setState(() {});
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    super.build(context);

    WebFState? webFState;
    WebFRouterViewState? routerViewState;

    if (this is WidgetElement || webFElement.renderStyle.display == CSSDisplay.none) {
      return flutter.SizedBox.shrink();
    }

    List<flutter.Widget> children = [];
    if (webFElement.childNodes.isEmpty) {
      children = [];
    } else {
      for (final node in webFElement.childNodes) {
        if (node is Element &&
            (node.renderStyle.position == CSSPositionType.absolute ||
                node.renderStyle.position == CSSPositionType.sticky)) {
          if (node.holderAttachedPositionedElement != null) {
            children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
          }

          children.add(node.toWidget());
          continue;
        } else if (node is Element && node.renderStyle.position == CSSPositionType.fixed) {
          children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
        } else if (node is RouterLinkElement) {
          webFState ??= context.findAncestorStateOfType<WebFState>();
          String routerPath = node.path;
          if (webFState != null && (webFState.widget.controller.initialRoute ?? '/') == routerPath) {
            children.add(node.toWidget());
            continue;
          }

          routerViewState ??= context.findAncestorStateOfType<WebFRouterViewState>();
          if (routerViewState != null) {
            children.add(node.toWidget());
            continue;
          }

          children.add(flutter.SizedBox.shrink());
          continue;
        } else {
          children.add(node.toWidget());
        }
      }
      for (final positionedElement in webFElement.fixedPositionElements) {
        children.add(positionedElement.toWidget());
      }
    }

    flutter.Widget widget;

    if (webFElement.hasScroll) {
      CSSOverflowType overflowX = webFElement.renderStyle.overflowX;
      CSSOverflowType overflowY = webFElement.renderStyle.overflowY;

      flutter.Widget? scrollableX;
      if (overflowX == CSSOverflowType.scroll ||
          overflowX == CSSOverflowType.auto ||
          overflowX == CSSOverflowType.hidden) {
        webFElement._scrollControllerX ??= flutter.ScrollController();
        final bool xScrollable = overflowX != CSSOverflowType.hidden;
        scrollableX = LayoutBoxWrapper(
            ownerElement: webFElement,
            child: NestedScrollCoordinator(
                axis: flutter.Axis.horizontal,
                controller: webFElement.scrollControllerX!,
                enabled: xScrollable,
                child: flutter.Scrollable(
                    controller: webFElement.scrollControllerX,
                    axisDirection: AxisDirection.right,
                    physics: xScrollable ? null : const flutter.NeverScrollableScrollPhysics(),
                    viewportBuilder: (flutter.BuildContext context, ViewportOffset position) {
                      flutter.Widget adapter = WebFRenderLayoutWidgetAdaptor(
                        webFElement: webFElement,
                        key: webFElement.key,
                        scrollListener: webFElement.handleScroll,
                        positionX: position,
                        children: children,
                      );

                      return adapter;
                    })));
      }

      if (overflowY == CSSOverflowType.scroll ||
          overflowY == CSSOverflowType.auto ||
          overflowY == CSSOverflowType.hidden) {
        webFElement._scrollControllerY ??= flutter.ScrollController();
        final bool yScrollable = overflowY != CSSOverflowType.hidden;
        widget = LayoutBoxWrapper(
            ownerElement: webFElement,
            child: NestedScrollCoordinator(
                axis: flutter.Axis.vertical,
                controller: webFElement.scrollControllerY!,
                enabled: yScrollable,
                child: flutter.Scrollable(
                    axisDirection: AxisDirection.down,
                    physics: yScrollable ? null : const flutter.NeverScrollableScrollPhysics(),
                    controller: webFElement.scrollControllerY,
                    viewportBuilder: (flutter.BuildContext context, ViewportOffset positionY) {
                      if (scrollableX != null) {
                        return NestedScrollCoordinator(
                            axis: flutter.Axis.horizontal,
                            controller: webFElement.scrollControllerX!,
                            enabled: (webFElement.renderStyle.overflowX != CSSOverflowType.hidden),
                            child: flutter.Scrollable(
                                controller: webFElement.scrollControllerX,
                                axisDirection: AxisDirection.right,
                                viewportBuilder: (flutter.BuildContext context, ViewportOffset positionX) {
                                  flutter.Widget adapter = WebFRenderLayoutWidgetAdaptor(
                                    webFElement: webFElement,
                                    key: webFElement.key,
                                    scrollListener: webFElement.handleScroll,
                                    positionX: positionX,
                                    positionY: positionY,
                                    children: children,
                                  );
                                  return adapter;
                                }));
                      }

                      return WebFRenderLayoutWidgetAdaptor(
                        webFElement: webFElement,
                        key: webFElement.key,
                        scrollListener: webFElement.handleScroll,
                        positionY: positionY,
                        children: children,
                      );
                    })));
      } else {
        widget = scrollableX ??
            WebFRenderLayoutWidgetAdaptor(webFElement: webFElement, key: webFElement.key, children: children);
      }
    } else {
      widget = WebFRenderLayoutWidgetAdaptor(webFElement: webFElement, key: webFElement.key, children: children);
    }

    // Expose this element's scroll controllers to descendants to enable nested scrolling.
    final wrapped = NestedScrollForwarder(
      verticalController: webFElement.scrollControllerY,
      horizontalController: webFElement.scrollControllerX,
      child: widget,
    );

    return WebFEventListener(
        ownerElement: webFElement,
        hasEvent: webFElement.hasEvent,
        enableTouchEvent: webFElement is WebFTouchAreaElement,
        child: wrapped);
  }

  @override
  void deactivate() {
    super.deactivate();
    webFElement._scrollControllerY?.dispose();
    webFElement._scrollControllerY = null;
    webFElement._scrollControllerX?.dispose();
    webFElement._scrollControllerX = null;
    webFElement.removeState(this);
  }

  @override
  void activate() {
    super.activate();
    webFElement.addState(this);
  }

  @override
  void dispose() {
    webFElement.removeState(this);
    webFElement._scrollControllerY?.dispose();
    webFElement._scrollControllerY = null;
    webFElement._scrollControllerX?.dispose();
    webFElement._scrollControllerX = null;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class WebFReplacedElementWidget extends flutter.StatefulWidget {
  const WebFReplacedElementWidget({required this.webFElement, required this.child, super.key});

  final Element webFElement;
  final flutter.Widget child;

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return WebFReplacedElementWidgetState();
  }
}

class WebFReplacedElementWidgetState extends flutter.State<WebFReplacedElementWidget>
    with flutter.AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    webFElement.addState(this);
  }

  Element get webFElement => widget.webFElement;

  void requestForChildNodeUpdate(AdapterUpdateReason reason) {
    if (reason is UpdateChildNodeUpdateReason) return;

    setState(() {});
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    super.build(context);

    if (webFElement.renderStyle.display == CSSDisplay.none) {
      return flutter.SizedBox.shrink();
    }

    flutter.Widget child = WebFEventListener(
      ownerElement: webFElement,
      hasEvent: true,
      child: WebFRenderReplacedRenderObjectWidget(webFElement: webFElement, key: webFElement.key, child: widget.child),
    );

    return child;
  }

  @override
  void deactivate() {
    super.deactivate();
    webFElement.removeState(this);
  }

  @override
  void activate() {
    super.activate();
    webFElement.addState(this);
  }

  @override
  void dispose() {
    super.dispose();
    webFElement.removeState(this);
  }
}

class WebFRenderReplacedRenderObjectWidget extends flutter.SingleChildRenderObjectWidget {
  final Element webFElement;

  const WebFRenderReplacedRenderObjectWidget({required this.webFElement, super.key, super.child});

  @override
  RenderObject createRenderObject(flutter.BuildContext context) {
    return webFElement.renderStyle.getWidgetPairedRenderBoxModel(context as flutter.RenderObjectElement)!;
  }

  @override
  flutter.SingleChildRenderObjectElement createElement() {
    return WebFRenderReplacedRenderObjectElement(this);
  }

  @override
  String toStringShort() {
    return webFElement.attachedRenderer?.toStringShort() ?? '';
  }
}

class WebFRenderReplacedRenderObjectElement extends flutter.SingleChildRenderObjectElement {
  WebFRenderReplacedRenderObjectElement(super.widget);


  @override
  WebFRenderReplacedRenderObjectWidget get widget => super.widget as WebFRenderReplacedRenderObjectWidget;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild(AdapterUpdateReason reason) {
    if (reason is UpdateChildNodeUpdateReason) return;

    widget.webFElement.forEachState((state) {
      (state as WebFReplacedElementWidgetState).requestForChildNodeUpdate(reason);
    });
  }

  flutter.RouteSettings? _currentRouteSettings;

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    Element webFElement = widget.webFElement;
    webFElement.willAttachRenderer(this);

    super.mount(parent, newSlot);
    webFElement.didAttachRenderer();

    webFElement.style.flushPendingProperties();

    flutter.ModalRoute? route = flutter.ModalRoute.of(this);

    _currentRouteSettings = route?.settings;

    // Queue the onscreen event
    OnScreenEvent event =
        OnScreenEvent(state: _currentRouteSettings?.arguments, path: _currentRouteSettings?.name ?? '');
    webFElement.enqueueScreenEvent(ScreenEvent.onScreen(event));

    if (webFElement is ImageElement && webFElement.shouldLazyLoading) {
      (renderObject as RenderReplaced)
        ..intersectPadding = Rect.fromLTRB(0, 0, webFElement.ownerDocument.viewport!.viewportSize.width,
            webFElement.ownerDocument.viewport!.viewportSize.height)
        ..addIntersectionChangeListener(webFElement.handleIntersectionChange);
    }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    Element element = widget.webFElement;

    // Queue the offscreen event
    OffScreenEvent event =
        OffScreenEvent(state: _currentRouteSettings?.arguments, path: _currentRouteSettings?.name ?? '');
    element.enqueueScreenEvent(ScreenEvent.offScreen(event));

    _currentRouteSettings = null;
    element.willDetachRenderer(this);
    super.unmount();
    element.didDetachRenderer(this);
  }
}

class WebFRenderLayoutWidgetAdaptor extends flutter.MultiChildRenderObjectWidget {
  const WebFRenderLayoutWidgetAdaptor(
      {this.webFElement,
      this.positionX,
      this.positionY,
      this.scrollListener,
      required super.children,
      super.key});

  final Element? webFElement;
  final ViewportOffset? positionX;
  final ViewportOffset? positionY;
  final ScrollListener? scrollListener;

  @override
  WebRenderLayoutRenderObjectElement createElement() {
    WebRenderLayoutRenderObjectElement element = ExternalWebRenderLayoutWidgetElement(webFElement!, this);
    return element;
  }

  @override
  flutter.RenderObject createRenderObject(flutter.BuildContext context) {
    RenderBoxModel renderBoxModel =
        webFElement!.renderStyle.getWidgetPairedRenderBoxModel(context as flutter.RenderObjectElement)!;

    // Attach position holder to apply offsets based on original layout.
    for (final positionHolder in webFElement!.positionHolderElements) {
      if (positionHolder.mounted) {
        renderBoxModel.renderPositionPlaceholder = positionHolder.renderObject as RenderPositionPlaceholder;
        (positionHolder.renderObject as RenderPositionPlaceholder).positioned = renderBoxModel;
      }
    }

    if (scrollListener != null) {
      renderBoxModel.scrollOffsetX = positionX;
      renderBoxModel.scrollOffsetY = positionY;
      renderBoxModel.scrollListener = scrollListener;
    }

    return renderBoxModel;
  }

  @override
  void updateRenderObject(flutter.BuildContext context, RenderBoxModel renderObject) {
    if (scrollListener != null) {
      renderObject.scrollOffsetX = positionX;
      renderObject.scrollOffsetY = positionY;
      renderObject.scrollListener = scrollListener;
    }
  }

  @override
  String toStringShort() {
    return webFElement?.attachedRenderer?.toStringShort() ?? '';
  }
}

abstract class WebRenderLayoutRenderObjectElement extends flutter.MultiChildRenderObjectElement {
  WebRenderLayoutRenderObjectElement(super.widget) : super();

  @override
  WebFRenderLayoutWidgetAdaptor get widget => super.widget as WebFRenderLayoutWidgetAdaptor;

  Element get webFElement;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild(AdapterUpdateReason reason) {
    webFElement.forEachState((state) {
      (state as WebFElementWidgetState).requestForChildNodeUpdate(reason);
    });
  }

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    webFElement.willAttachRenderer(this);
    super.mount(parent, newSlot);
    webFElement.didAttachRenderer();

    webFElement.style.flushPendingProperties();
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    Element element = webFElement;
    element.willDetachRenderer(this);

    super.unmount();
    element.didDetachRenderer(this);
  }
}

class ExternalWebRenderLayoutWidgetElement extends WebRenderLayoutRenderObjectElement {
  final Element _webfElement;

  ExternalWebRenderLayoutWidgetElement(this._webfElement, WebFRenderLayoutWidgetAdaptor widget) : super(widget);

  flutter.RouteSettings? _currentRouteSettings;

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    flutter.ModalRoute? route = flutter.ModalRoute.of(this);

    _currentRouteSettings = route?.settings;

    // Queue the onscreen event
    OnScreenEvent event =
        OnScreenEvent(state: _currentRouteSettings?.arguments, path: _currentRouteSettings?.name ?? '');
    webFElement.enqueueScreenEvent(ScreenEvent.onScreen(event));
  }

  @override
  void unmount() {
    Element element = webFElement;

    // Queue the offscreen event
    OffScreenEvent event =
        OffScreenEvent(state: _currentRouteSettings?.arguments, path: _currentRouteSettings?.name ?? '');
    element.enqueueScreenEvent(ScreenEvent.offScreen(event));

    _currentRouteSettings = null;

    super.unmount();
  }

  @override
  Element get webFElement => _webfElement;
}

class PositionPlaceHolder extends flutter.SingleChildRenderObjectWidget {
  final Element positionedElement;
  final Element selfElement;

  const PositionPlaceHolder(this.positionedElement, this.selfElement, {super.key}) : super();

  @override
  RenderObject createRenderObject(flutter.BuildContext context) {
    return RenderPositionPlaceholder(preferredSize: Size.zero);
  }

  @override
  flutter.SingleChildRenderObjectElement createElement() {
    return _PositionedPlaceHolderElement(this);
  }
}

class _PositionedPlaceHolderElement extends flutter.SingleChildRenderObjectElement {
  _PositionedPlaceHolderElement(super.widget);

  @override
  PositionPlaceHolder get widget => super.widget as PositionPlaceHolder;

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    widget.selfElement.positionHolderElements.add(this);
  }

  @override
  void unmount() {
    widget.selfElement.positionHolderElements.remove(this);

    // Remove the reference for this in paired render box model.
    RenderBoxModel? pairedRenderBoxModel = widget.positionedElement.renderStyle.attachedRenderBoxModel;
    if (pairedRenderBoxModel?.renderPositionPlaceholder == renderObject) {
      pairedRenderBoxModel?.renderPositionPlaceholder = null;
    }

    super.unmount();
  }
}
