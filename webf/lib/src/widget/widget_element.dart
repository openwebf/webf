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
  late Widget _widget;
  Widget get widget => _widget;

  WebFAdapterWidgetState? _state;
  set state(WebFAdapterWidgetState? newState) {
    _state = newState;
  }
  WebFRenderObjectToWidgetAdapter? attachedAdapter;

  WidgetElement(
    BindingContext? context, {
    Map<String, dynamic>? defaultStyle,
  }) : super(
          context,
          defaultStyle: {
            ..._defaultStyle,
            ...?defaultStyle
          },
          isReplacedElement: true,
        ) {
    WidgetsFlutterBinding.ensureInitialized();
    _widget = WebFAdapterWidget(this);
  }

  void initState() {}

  Widget build(BuildContext context, List<Widget> children);

  // The render object is inserted by Flutter framework when element is WidgetElement.
  @override
  dom.RenderObjectManagerType get renderObjectManagerType => dom.RenderObjectManagerType.FLUTTER_ELEMENT;

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

  void _attachWidget(Widget widget) {
    WebFRenderObjectToWidgetAdapter adaptor =
        attachedAdapter = WebFRenderObjectToWidgetAdapter(child: widget, container: renderBoxModel!);
    ownerDocument.controller.onCustomElementAttached!(adaptor);
  }

  void _detachWidget() {
    if (attachedAdapter != null) {
      ownerDocument.controller.onCustomElementDetached!(attachedAdapter!);
    }
  }
}
