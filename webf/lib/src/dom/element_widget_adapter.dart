/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

mixin ElementAdapterMixin on ElementBase {
  final Set<Element> positionedElements = {};
  // Rendering this element as an RenderPositionHolder
  Element? holderAttachedPositionedElement;
  Element? holderAttachedContainingBlockElement;
  bool hasEvent = false;

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
    return _WebFElementWidgetState(webFElement);
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

class _WebFElementWidgetState extends flutter.State<WebFElementWidget> with flutter.AutomaticKeepAliveClientMixin {
  final Element _webFElement;

  _WebFElementWidgetState(this._webFElement);

  Element get webFElement => _webFElement;

  void requestForChildNodeUpdate(AdapterUpdateReason reason) {
    setState(() {});
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    super.build(context);

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
        } else {
          return node.toWidget();
        }
      }).toList();
    }

    children.addAll(webFElement.positionedElements.map((element) {
      return element.toWidget();
    }));

    flutter.Widget widget = WebFRenderLayoutWidgetAdaptor(webFElement: _webFElement, children: children);

    if (webFElement.hasEvent) {
      widget = Portal(ownerElement: _webFElement, child: widget);
    }

    return widget;
  }

  @override
  void dispose() {
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
  WebFRenderLayoutWidgetAdaptor({this.webFElement, flutter.Key? key, required List<flutter.Widget> children})
      : super(key: key, children: children) {}

  final Element? webFElement;

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

    return renderBoxModel;
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
    _WebFElementWidgetState state = findAncestorStateOfType<_WebFElementWidgetState>()!;
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
      renderPositionPlaceholder.positioned!.renderPositionPlaceholder = renderPositionPlaceholder;
      renderPositionPlaceholder.markNeedsLayout();
      renderPositionPlaceholder.positioned!.markNeedsLayout();
    });
  }
}
