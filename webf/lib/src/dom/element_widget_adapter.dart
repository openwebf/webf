/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi' as ffi;

import 'package:flutter/material.dart' as flutter;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'package:webf/gesture.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';


mixin ElementAdapterMixin on ElementBase {
  final List<Element> _fixedPositionElements = [];

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

  @override
  flutter.Widget toWidget({Key? key}) {
    return WebFElementWidget(this as Element, key: key ?? (this as Element).key);
  }
}

class WebFElementWidget extends flutter.StatefulWidget {
  final Element webFElement;

  WebFElementWidget(this.webFElement, {flutter.Key? key}) : super(key: key) {
    webFElement.managedByFlutterWidget = true;
  }

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return WebFElementWidgetState(webFElement);
  }

  @override
  String toStringShort() {
    String attributes = '';
    if (webFElement.id != null) {
      attributes += 'id="' + webFElement.id! + '"';
    }
    if (webFElement.className.isNotEmpty) {
      attributes += 'class="' + webFElement.className + '"';
    }

    return '<${webFElement.tagName.toLowerCase()}#$hashCode $attributes>';
  }
}

class WebFElementWidgetState extends flutter.State<WebFElementWidget> with flutter.AutomaticKeepAliveClientMixin {
  final Element webFElement;

  WebFElementWidgetState(this.webFElement) {
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
      webFElement.childNodes.forEach((node) {
        if (node is Element &&
            (node.renderStyle.position == CSSPositionType.sticky ||
                node.renderStyle.position == CSSPositionType.absolute)) {
          children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
          children.add(node.toWidget());
          return;
        } else if (node is Element && node.renderStyle.position == CSSPositionType.fixed) {
          children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
        } else if (node is RouterLinkElement) {
          webFState ??= context.findAncestorStateOfType<WebFState>();
          String routerPath = node.path;
          if (webFState != null && webFState?.widget.controller.initialRoute == routerPath) {
            children.add(node.toWidget());
            return;
          }

          routerViewState ??= context.findAncestorStateOfType<WebFRouterViewState>();
          if (routerViewState != null) {
            children.add(node.toWidget());
            return;
          }

          children.add(flutter.SizedBox.shrink());
          return;
        } else {
          children.add(node.toWidget());
        }
      });
      webFElement.fixedPositionElements.forEach((positionedElement) {
        children.add(positionedElement.toWidget());
      });
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
        scrollableX = LayoutBoxWrapper(
            child: flutter.Scrollable(
                controller: webFElement.scrollControllerX,
                axisDirection: AxisDirection.right,
                viewportBuilder: (flutter.BuildContext context, ViewportOffset position) {
                  flutter.Widget adapter = WebFRenderLayoutWidgetAdaptor(
                    webFElement: webFElement,
                    children: children,
                    key: webFElement.key,
                    scrollListener: webFElement.handleScroll,
                    positionX: position,
                  );

                  return adapter;
                }),
            ownerElement: webFElement);
      }

      if (overflowY == CSSOverflowType.scroll ||
          overflowY == CSSOverflowType.auto ||
          overflowY == CSSOverflowType.hidden) {
        webFElement._scrollControllerY ??= flutter.ScrollController();
        widget = LayoutBoxWrapper(
            child: flutter.Scrollable(
                axisDirection: AxisDirection.down,
                controller: webFElement.scrollControllerY,
                viewportBuilder: (flutter.BuildContext context, ViewportOffset positionY) {
                  if (scrollableX != null) {
                    return flutter.Scrollable(
                        controller: webFElement.scrollControllerX,
                        axisDirection: AxisDirection.right,
                        viewportBuilder: (flutter.BuildContext context, ViewportOffset positionX) {
                          flutter.Widget adapter = WebFRenderLayoutWidgetAdaptor(
                            webFElement: webFElement,
                            children: children,
                            key: webFElement.key,
                            scrollListener: webFElement.handleScroll,
                            positionX: positionX,
                            positionY: positionY,
                          );

                          return adapter;
                        });
                  }

                  return WebFRenderLayoutWidgetAdaptor(
                    webFElement: webFElement,
                    children: children,
                    key: webFElement.key,
                    scrollListener: webFElement.handleScroll,
                    positionY: positionY,
                  );
                }),
            ownerElement: webFElement);
      } else {
        widget = scrollableX ??
            WebFRenderLayoutWidgetAdaptor(webFElement: webFElement, children: children, key: webFElement.key);
      }
    } else {
      widget = WebFRenderLayoutWidgetAdaptor(webFElement: webFElement, children: children, key: webFElement.key);
    }

    return WebFEventListener(ownerElement: webFElement, child: widget, hasEvent: webFElement.hasEvent);
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

class WebFReplacedElementWidget extends flutter.SingleChildRenderObjectWidget {
  final Element webFElement;

  WebFReplacedElementWidget({required this.webFElement, flutter.Key? key, flutter.Widget? child})
      : super(key: key, child: child);

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
    return 'RenderObjectAdapter(${webFElement.tagName.toLowerCase()})';
  }
}

class WebFRenderReplacedRenderObjectElement extends flutter.SingleChildRenderObjectElement {
  WebFRenderReplacedRenderObjectElement(super.widget);

  @override
  WebFReplacedElementWidget get widget => super.widget as WebFReplacedElementWidget;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild(AdapterUpdateReason reason) {
    if (reason is UpdateChildNodeUpdateReason) return;

    visitChildElements((flutter.Element childElement) {
      if (childElement is flutter.StatefulElement) {
        childElement.markNeedsBuild();
      }
    });
  }

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    Element webFElement = widget.webFElement;
    webFElement.willAttachRenderer(this);

    super.mount(parent, newSlot);
    webFElement.didAttachRenderer();

    webFElement.style.flushPendingProperties();

    flutter.ModalRoute route = flutter.ModalRoute.of(this)!;
    OnScreenEvent event = OnScreenEvent(state: route.settings.arguments, path: route.settings.name ?? '');
    // Should dispatch onscreen event after did build and layout
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      webFElement.dispatchEventUtilAdded(event);
    });

    if (webFElement is ImageElement && webFElement.shouldLazyLoading) {
      (renderObject as RenderReplaced)
        ..intersectPadding = Rect.fromLTRB(0, 0, webFElement.ownerDocument.viewport!.viewportSize.width,
            webFElement.ownerDocument.viewport!.viewportSize.height)
        ..addIntersectionChangeListener(webFElement.handleIntersectionChange);
    }
  }

  @override
  void deactivate() {
    flutter.ModalRoute route = flutter.ModalRoute.of(this)!;
    Element element = widget.webFElement;
    OffScreenEvent event = OffScreenEvent(state: route.settings.arguments, path: route.settings.name ?? '');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      element.dispatchEvent(event);
    });

    super.deactivate();
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    Element element = widget.webFElement;
    element.willDetachRenderer(this);
    super.unmount();
    element.didDetachRenderer(this);
  }
}

class WebFRenderLayoutWidgetAdaptor extends flutter.MultiChildRenderObjectWidget {
  WebFRenderLayoutWidgetAdaptor(
      {this.webFElement,
      flutter.Key? key,
      this.positionX,
      this.positionY,
      this.scrollListener,
      required List<flutter.Widget> children})
      : super(key: key, children: children) {}

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
    webFElement!.positionHolderElements.forEach((positionHolder) {
      if (positionHolder.mounted) {
        renderBoxModel.renderPositionPlaceholder = positionHolder.renderObject as RenderPositionPlaceholder;
        (positionHolder.renderObject as RenderPositionPlaceholder).positioned = renderBoxModel;
      }
    });

    if (scrollListener != null) {
      renderBoxModel.scrollOffsetX = positionX;
      renderBoxModel.scrollOffsetY = positionY;
      renderBoxModel.scrollListener = scrollListener;
    }

    return renderBoxModel;
  }

  @override
  void updateRenderObject(flutter.BuildContext context, RenderBoxModel renderBoxModel) {
    if (scrollListener != null) {
      renderBoxModel.scrollOffsetX = positionX;
      renderBoxModel.scrollOffsetY = positionY;
      renderBoxModel.scrollListener = scrollListener;
    }
  }

  @override
  String toStringShort() {
    return 'RenderObjectAdapter(${webFElement?.tagName.toLowerCase()})';
  }
}

abstract class WebRenderLayoutRenderObjectElement extends flutter.MultiChildRenderObjectElement {
  WebRenderLayoutRenderObjectElement(WebFRenderLayoutWidgetAdaptor widget) : super(widget);

  @override
  WebFRenderLayoutWidgetAdaptor get widget => super.widget as WebFRenderLayoutWidgetAdaptor;

  Element get webFElement;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild(AdapterUpdateReason reason) {
    webFElement.forEachState((state) {
      state.requestForChildNodeUpdate(reason);
    });
  }

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    webFElement.willAttachRenderer(this);
    super.mount(parent, newSlot);
    webFElement.didAttachRenderer();

    if (webFElement.renderStyle.position == CSSPositionType.fixed) {
      webFElement.ownerDocument.fixedChildren.add(renderObject as RenderBoxModel);
    }

    webFElement.style.flushPendingProperties();
  }

  @override
  void unmount() {
    webFElement.ownerDocument.fixedChildren.remove(renderObject as RenderBoxModel);
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

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    flutter.ModalRoute? route = flutter.ModalRoute.of(this);
    OnScreenEvent event = OnScreenEvent(state: route?.settings.arguments, path: route?.settings.name ?? '');
    Element webfElement = webFElement;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      webfElement.dispatchEventUtilAdded(event);
    });
  }

  @override
  void deactivate() {
    flutter.ModalRoute? route = flutter.ModalRoute.of(this);
    Element element = webFElement;
    OffScreenEvent event = OffScreenEvent(state: route?.settings.arguments, path: route?.settings.name ?? '');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      element.dispatchEvent(event);
    });
    super.deactivate();
  }

  @override
  void unmount() {
    super.unmount();
  }

  @override
  Element get webFElement => _webfElement;
}

class PositionPlaceHolder extends flutter.SingleChildRenderObjectWidget {
  final Element positionedElement;
  final Element selfElement;

  PositionPlaceHolder(this.positionedElement, this.selfElement, {Key? key}) : super(key: key);

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
