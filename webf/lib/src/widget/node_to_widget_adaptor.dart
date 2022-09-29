library webf;

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
import 'node_to_flutter_element_adapter.dart';

class WebFNodeToWidgetAdaptor extends RenderObjectWidget {
  final dom.Node _webFNode;
  dom.Node get webFNode => _webFNode;

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
