/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

class WebFRenderObjectToWidgetAdapter<T extends RenderObject> extends SingleChildRenderObjectWidget {
  WebFRenderObjectToWidgetAdapter({
    Widget? child,
    required this.container,
    this.debugShortDescription,
  }) : super(key: GlobalObjectKey(container), child: child);

  /// The [RenderObject] that is the parent of the [Element] created by this widget.
  final RenderObject container;

  /// A short description of this widget used by debugging aids.
  final String? debugShortDescription;

  @override
  WebFRenderObjectToWidgetElement<T> createElement() => WebFRenderObjectToWidgetElement<T>(this);

  @override
  RenderObject createRenderObject(BuildContext context) => container;

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {}

  @override
  String toStringShort() => debugShortDescription ?? super.toStringShort();
}

/// Creates an element that is hosted by a [RenderObject].
class WebFRenderObjectToWidgetElement<T extends RenderObject> extends SingleChildRenderObjectElement {
  WebFRenderObjectToWidgetElement(WebFRenderObjectToWidgetAdapter<T> widget) : super(widget);

  @override
  WebFRenderObjectToWidgetAdapter get widget => super.widget as WebFRenderObjectToWidgetAdapter<T>;

  @override
  RenderObjectWithChildMixin<RenderObject> get renderObject => super.renderObject as RenderObjectWithChildMixin<RenderObject>;

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    renderObject.child = null;
  }
}

abstract class WidgetElement extends dom.Element {
  late Widget _widget;
  _WebFAdapterWidgetState? _state;
  WebFRenderObjectToWidgetAdapter? attachedAdapter;

  WidgetElement(
    BindingContext? context, {
    Map<String, dynamic>? defaultStyle,
    bool isReplacedElement = false,
  }) : super(
          context,
          defaultStyle: defaultStyle,
          isReplacedElement: true,
        ) {
    WidgetsFlutterBinding.ensureInitialized();
    _widget = _WebFAdapterWidget(this);
  }

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
    WebFRenderObjectToWidgetAdapter adaptor = attachedAdapter = WebFRenderObjectToWidgetAdapter(
        child: widget,
        container: renderBoxModel!);
    ownerDocument.controller.onCustomElementAttached!(adaptor);
  }

  void _detachWidget() {
    ownerDocument.controller.onCustomElementDetached!(attachedAdapter!);
  }
}

class _WebFAdapterWidget extends StatefulWidget {
  final WidgetElement widgetElement;

  _WebFAdapterWidget(this.widgetElement, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    _WebFAdapterWidgetState state = _WebFAdapterWidgetState(widgetElement);
    widgetElement._state = state;
    return state;
  }
}

class _WebFAdapterWidgetState extends State<_WebFAdapterWidget> {
  final WidgetElement widgetElement;

  _WebFAdapterWidgetState(this.widgetElement);

  void requestUpdateState([VoidCallback? callback]) {
    if (mounted) {
      setState(callback ?? () {});
    }
  }

  List<Widget> convertNodeListToWidgetList(List<dom.Node> childNodes) {
    List<Widget> children = List.generate(childNodes.length, (index) {
      if (childNodes[index] is WidgetElement) {
        return (childNodes[index] as WidgetElement)._widget;
      } else {
        return childNodes[index].flutterWidget ??
            WebFNodeToWidgetAdaptor(childNodes[index], key: Key(index.toString()));
      }
    });

    return children;
  }

  void onChildrenChanged() {
    if (mounted) {
      requestUpdateState();
    }
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WidgetElement(${widgetElement.tagName}) adapterWidgetState';
  }

  @override
  Widget build(BuildContext context) {
    return widgetElement.build(context, convertNodeListToWidgetList(widgetElement.childNodes));
  }
}
