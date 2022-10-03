library webf;

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/foundation.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'webf_adapter_widget.dart';
import 'render_object_to_widget_adaptor.dart';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

abstract class WidgetElement extends dom.Element {
  // An state
  late WebFWidgetElementWidget _widget;
  WebFWidgetElementWidget get widget => _widget;

  WebFWidgetElementState? _state;
  set state(WebFWidgetElementState? newState) {
    _state = newState;
  }
  WebFWidgetElementToWidgetAdapter? attachedAdapter;

  WidgetElement(
    BindingContext? context, {
    Map<String, dynamic>? defaultStyle,
  }) : super(
          context,
          defaultStyle: {
            ..._defaultStyle,
            ...?defaultStyle
          }) {
    WidgetsFlutterBinding.ensureInitialized();
    _widget = WebFWidgetElementWidget(this);
  }

  void initState() {}

  Widget build(BuildContext context, List<Widget> children);

  // The render object is inserted by Flutter framework when element is WidgetElement.
  @override
  dom.RenderObjectManagerType get renderObjectManagerType => dom.RenderObjectManagerType.FLUTTER_ELEMENT;

  @override
  bool get isWidgetElement => true;

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    _detachWidget();
  }

  void setState(VoidCallback callback) {
    if (_state != null) {
      _state!.requestUpdateState(callback);
    }
  }

  @override
  void didAttachRenderer() {
    // Children of WidgetElement should insert render object by Flutter Framework.
    _attachWidget(_widget);
  }

  @override
  void setBindingProperty(String key, value) {
    super.setBindingProperty(key, value);
    if (_state != null) {
      _state!.requestUpdateState();
    }
  }

  @override
  void removeAttribute(String key) {
    super.removeAttribute(key);
    if (_state != null) {
      _state!.requestUpdateState();
    }
  }

  @override
  void setAttribute(String key, value) {
    super.setAttribute(key, value);
    if (_state != null) {
      _state!.requestUpdateState();
    }
  }

  @override
  dom.Node appendChild(dom.Node child) {
    super.appendChild(child);

    if (_state != null) {
      _state!.requestUpdateState();
    }

    return child;
  }

  @override
  dom.Node insertBefore(dom.Node child, dom.Node referenceNode) {
    dom.Node inserted = super.insertBefore(child, referenceNode);

    if (_state != null) {
      _state!.requestUpdateState();
    }

    return inserted;
  }

  @override
  dom.Node? replaceChild(dom.Node newNode, dom.Node oldNode) {
    dom.Node? replaced = super.replaceChild(newNode, oldNode);

    if (_state != null) {
      _state!.requestUpdateState();
    }

    return replaced;
  }

  @override
  dom.Node removeChild(dom.Node child) {
    super.removeChild(child);

    if (_state != null) {
      _state!.requestUpdateState();
    }

    return child;
  }

  static dom.Node? getAncestorWidgetNode(WidgetElement element) {
    dom.Node? parent = element.parentNode;

    while(parent != null) {
      if (parent.flutterWidget != null) {
        return parent;
      }

      parent = parent.parentNode;
    }

    return null;
  }

  void _attachWidget(Widget widget) {
    dom.Node? ancestorWidgetNode = getAncestorWidgetNode(this);
    WebFWidgetElementToWidgetAdapter adapter = attachedAdapter = WebFWidgetElementToWidgetAdapter(child: widget, container: renderBoxModel!);
    if (ancestorWidgetNode != null) {
      (ancestorWidgetNode as dom.Element).flutterWidgetState!.addWidgetChild(adapter);
    } else {
      ownerDocument.controller.onCustomElementAttached!(adapter);
    }
  }

  void _detachWidget() {
    if (attachedAdapter != null) {
      dom.Node? ancestorWidgetNode = getAncestorWidgetNode(this);
      if (ancestorWidgetNode != null) {
        (ancestorWidgetNode as dom.Element).flutterWidgetState!.removeWidgetChild(attachedAdapter!);
      } else {
        ownerDocument.controller.onCustomElementDetached!(attachedAdapter!);
      }
    }
  }
}
