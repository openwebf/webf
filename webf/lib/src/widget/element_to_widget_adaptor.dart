/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';

class WebFNodeToWidgetAdaptor extends RenderObjectWidget {
  final dom.Node _webFNode;

  WebFNodeToWidgetAdaptor(this._webFNode, {Key? key}) : super(key: key) {
    _webFNode.flutterWidget = this;
  }

  @override
  RenderObjectElement createElement() {
    _webFNode.flutterElement = WebFNodeToFlutterElementAdaptor(this);
    return _webFNode.flutterElement as RenderObjectElement;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    // Children of custom element need RenderFlowLayout nesting,
    // otherwise the parent render layout will not be called when setting properties.
    if (_webFNode is dom.Element) {
      CSSRenderStyle renderStyle = CSSRenderStyle(target: _webFNode as dom.Element);
      RenderFlowLayout renderFlowLayout = RenderFlowLayout(renderStyle: renderStyle);
      renderFlowLayout.insert(_webFNode.renderer!);
      return renderFlowLayout;
    } else {
      return _webFNode.renderer!;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('WebFNodeType', AttributedString(_webFNode.nodeType.toString())));
    properties.add(AttributedStringProperty('WebFNodeName', AttributedString(_webFNode.nodeName.toString())));
  }
}

class WebFNodeToFlutterElementAdaptor extends RenderObjectElement {
  WebFNodeToFlutterElementAdaptor(RenderObjectWidget widget) : super(widget);

  @override
  WebFNodeToWidgetAdaptor get widget => super.widget as WebFNodeToWidgetAdaptor;

  @override
  void mount(Element? parent, Object? newSlot) {
    widget._webFNode.createRenderer();
    super.mount(parent, newSlot);

    widget._webFNode.ensureChildAttached();

    if (widget._webFNode is dom.Element) {
      dom.Element element = (widget._webFNode as dom.Element);
      element.applyStyle(element.style);

      if (element.renderer != null) {
        // Flush pending style before child attached.
        element.style.flushPendingProperties();
      }
    }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    dom.Node node = widget._webFNode;

    super.unmount();

    if (node is dom.Element) {
      node.unmountRenderObject(dispose: false);
    }
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {}

  @override
  void moveRenderObjectChild(covariant RenderObject child, covariant Object? oldSlot, covariant Object? newSlot) {}
}
