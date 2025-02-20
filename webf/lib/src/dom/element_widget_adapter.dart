/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'package:webf/gesture.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

mixin ElementAdapterMixin on ElementBase {
  final Set<Element> positionedElements = {};

  // Rendering this element as an RenderPositionHolder
  Element? holderAttachedPositionedElement;
  Element? holderAttachedContainingBlockElement;
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
  final Element _webFElement;

  WebFElementWidgetState(this._webFElement) {
    _webFElement.states.add(this);
  }

  Element get webFElement => _webFElement;

  flutter.ScrollController? scrollControllerX;
  flutter.ScrollController? scrollControllerY;

  void requestForChildNodeUpdate(AdapterUpdateReason reason) {
    setState(() {});
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    super.build(context);

    WebFState? webFState;
    WebFRouterViewState? routerViewState;

    if (webFElement.renderStyle.effectiveDisplay == CSSDisplay.none) {
      return flutter.SizedBox.shrink();
    }

    List<flutter.Widget> children;
    if (webFElement.childNodes.isEmpty) {
      children = [];
    } else {
      children = (webFElement.childNodes as ChildNodeList).map((node) {
        if (node is Element &&
            (node.renderStyle.position == CSSPositionType.absolute ||
                node.renderStyle.position == CSSPositionType.fixed)) {
          return PositionPlaceHolder(node.holderAttachedPositionedElement!);
        } else if (node is RouterLinkElement) {
          webFState ??= context.findAncestorStateOfType<WebFState>();
          String routerPath = node.path;
          if (webFState != null && webFState!.widget.controller.initialRoute == routerPath) {
            return node.toWidget();
          }

          routerViewState ??= context.findAncestorStateOfType<WebFRouterViewState>();
          if (routerViewState != null) {
            return node.toWidget();
          }

          return flutter.SizedBox.shrink();
        } else {
          return node.toWidget();
        }
      }).toList();
    }

    children.addAll(webFElement.positionedElements.map((element) {
      return element.toWidget();
    }));

    flutter.Widget widget;

    if (webFElement.hasScroll) {
      CSSOverflowType overflowX = webFElement.renderStyle.overflowX;
      CSSOverflowType overflowY = webFElement.renderStyle.overflowY;

      flutter.Scrollable? scrollableX;
      if (overflowX == CSSOverflowType.scroll ||
          overflowX == CSSOverflowType.auto ||
          overflowX == CSSOverflowType.hidden) {
        scrollControllerX ??= flutter.ScrollController();
        scrollableX = flutter.Scrollable(
            controller: scrollControllerX,
            viewportBuilder: (flutter.BuildContext context, ViewportOffset position) {
              return WebFRenderLayoutWidgetAdaptor(
                webFElement: _webFElement,
                children: children,
                key: _webFElement.key,
                scrollListener: webFElement.handleScroll,
                positionX: position,
                direction: Axis.horizontal,
              );
              // return renderLayoutWidgetAdaptor;
            });
      }

      if (overflowY == CSSOverflowType.scroll ||
          overflowY == CSSOverflowType.auto ||
          overflowY == CSSOverflowType.hidden) {
        scrollControllerY ??= flutter.ScrollController();
        widget = flutter.Scrollable(
          controller: scrollControllerY,
          viewportBuilder: (flutter.BuildContext context, ViewportOffset positionY) {
            if (scrollableX != null) {
              return flutter.Scrollable(
                  controller: scrollControllerX,
                  viewportBuilder: (flutter.BuildContext context, ViewportOffset positionX) {
                    return WebFRenderLayoutWidgetAdaptor(
                      webFElement: _webFElement,
                      children: children,
                      key: _webFElement.key,
                      scrollListener: webFElement.handleScroll,
                      positionX: positionX,
                      positionY: positionY,
                      direction: Axis.horizontal,
                    );
                    // return renderLayoutWidgetAdaptor;
                  });
            }

            return WebFRenderLayoutWidgetAdaptor(
              webFElement: _webFElement,
              children: children,
              key: _webFElement.key,
              scrollListener: webFElement.handleScroll,
              positionY: positionY,
              direction: Axis.horizontal,
            );
          },
        );
      } else {
        widget = scrollableX ?? WebFRenderLayoutWidgetAdaptor(webFElement: _webFElement, children: children, key: _webFElement.key);
      }
    } else {
      widget = WebFRenderLayoutWidgetAdaptor(webFElement: _webFElement, children: children, key: _webFElement.key);
    }

    if (webFElement.hasEvent) {
      widget = Portal(ownerElement: _webFElement, child: widget);
    }

    return widget;
  }

  @override
  void dispose() {
    webFElement.states.remove(this);
    super.dispose();
    scrollControllerX?.dispose();
    scrollControllerY?.dispose();
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
      required List<flutter.Widget> children,
      this.direction = Axis.vertical})
      : super(key: key, children: children) {}

  final Element? webFElement;
  final ViewportOffset? positionX;
  final ViewportOffset? positionY;
  final Axis direction;
  final ScrollListener? scrollListener;

  @override
  WebRenderLayoutRenderObjectElement createElement() {
    WebRenderLayoutRenderObjectElement element = ExternalWebRenderLayoutWidgetElement(webFElement!, this);
    return element;
  }

  @override
  flutter.RenderObject createRenderObject(flutter.BuildContext context) {
    RenderLayoutParentData parentData = RenderLayoutParentData();
    RenderBoxModel renderBoxModel =
        webFElement!.renderStyle.getWidgetPairedRenderBoxModel(context as flutter.RenderObjectElement)!;
    renderBoxModel.parentData = CSSPositionedLayout.getPositionParentData(renderBoxModel, parentData);

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
    WebFElementWidgetState state = findAncestorStateOfType<WebFElementWidgetState>()!;
    state.requestForChildNodeUpdate(reason);
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

  @override
  Element get webFElement => _webfElement;
}

class PositionPlaceHolder extends flutter.SingleChildRenderObjectWidget {
  final Element positionedElement;

  PositionPlaceHolder(this.positionedElement, {Key? key}) : super(key: key);

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
    scheduleMicrotask(() {
      RenderPositionPlaceholder renderPositionPlaceholder = renderObject as RenderPositionPlaceholder;
      renderPositionPlaceholder.positioned = widget.positionedElement.renderStyle.attachedRenderBoxModel;
      renderPositionPlaceholder.positioned?.renderPositionPlaceholder = renderPositionPlaceholder;
      renderPositionPlaceholder.markNeedsLayout();
      renderPositionPlaceholder.positioned?.markNeedsLayout();
    });
  }
}
