/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/foundation.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/launcher.dart';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

// WidgetElement is the base class for custom elements which rendering details are implemented by Flutter widgets.
abstract class WidgetElement extends dom.Element {
  // An state
  _WidgetElementAdapter? _widget;

  _WidgetElementAdapter get widget {
    _widget ??= _WidgetElementAdapter(this);
    return _widget!;
  }

  _WebFWidgetElementState? _state;

  set state(_WebFWidgetElementState? newState) {
    _state = newState;
  }

  SharedRenderWidgetAdapter? attachedAdapter;

  bool isRouterLinkElement = false;

  BuildContext get context {
    return _state!.context;
  }

  WidgetElement(BindingContext? context) : super(context) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget toWidget() {
    _widget = _WidgetElementAdapter(this);

    Widget child = WebFRenderWidgetAdaptor(this, child: _widget, key: ObjectKey(this));

    if (isRepaintBoundary) {
      child = RepaintBoundary(child: child);
    }

    return child;
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  // State methods, proxy called from _state
  void initState() {}

  void didChangeDependencies() {}

  bool get mounted => _state?.mounted ?? false;

  // React to properties and attributes changes
  void attributeDidUpdate(String key, String value) {}

  bool shouldElementRebuild(String key, previousValue, nextValue) {
    return previousValue == nextValue;
  }

  void propertyDidUpdate(String key, value) {}

  void styleDidUpdate(String property, String value) {}

  Widget build(BuildContext context, dom.ChildNodeList childNodes);

  // The render object is inserted by Flutter framework when element is WidgetElement.
  @override
  dom.RenderObjectManagerType get renderObjectManagerType => dom.RenderObjectManagerType.FLUTTER_ELEMENT;

  @nonVirtual
  @override
  bool get isWidgetElement => true;

  @mustCallSuper
  @override
  void didDetachRenderer([RenderObjectElement? flutterWidgetElement]) {
    super.didDetachRenderer();
    detachWidget();
  }

  @nonVirtual
  void setState(VoidCallback callback) {
    if (_state != null) {
      _state!.requestUpdateState(callback);
    }
  }

  /// [willAttachRenderer] and [didAttachRenderer] on WidgetElement will be called when this WidgetElement's parent is
  /// standard WebF element.
  /// If this WidgetElement's parent is another WidgetElement, [WebFWidgetElementElement.mount] and [WebFWidgetElementElement.unmount]
  /// place the equivalence altitude to the [willAttachRenderer] and [didAttachRenderer].
  @mustCallSuper
  @override
  RenderObject willAttachRenderer([RenderObjectElement? flutterWidgetElement]) {
    assert(!managedByFlutterWidget);
    RenderObject renderObject = super.willAttachRenderer();
    if (renderStyle.display != CSSDisplay.none && !managedByFlutterWidget) {
      RenderObject hostedRenderObject = flutterWidgetElement != null
          ? renderStyle.getWidgetPairedRenderBoxModel(flutterWidgetElement)!
          : renderStyle.domRenderBoxModel!;
      attachedAdapter = SharedRenderWidgetAdapter(child: widget, container: hostedRenderObject, widgetElement: this);
    }
    return renderObject;
  }

  @mustCallSuper
  @override
  void didAttachRenderer([Element? flutterWidgetElement]) {
    assert(!managedByFlutterWidget);
    // Children of WidgetElement should insert render object by Flutter Framework.
    attachWidget(widget);
  }

  // Reconfigure renderObjects when already rendered pages reattached to flutter tree
  void reactiveRenderer() {
    if (renderStyle.display != CSSDisplay.none && !managedByFlutterWidget) {
      // Generate a new adapter for this RenderWidget
      willAttachRenderer();

      // Reattach to Flutter
      ownerDocument.controller.onCustomElementAttached!(attachedAdapter!);
    }
  }

  @override
  void connectedCallback() {
    super.connectedCallback();
    ownerDocument.aliveWidgetElements.add(this);
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    ownerDocument.aliveWidgetElements.remove(this);
  }

  @override
  void setInlineStyle(String property, String value) {
    super.setInlineStyle(property, value);
    bool shouldRebuild = shouldElementRebuild(property, style.getPropertyValue(property), value);
    if (_state != null && shouldRebuild) {
      _state!.requestUpdateState();
    }
    styleDidUpdate(property, value);
  }

  @mustCallSuper
  @override
  void removeAttribute(String key) {
    super.removeAttribute(key);
    bool shouldRebuild = shouldElementRebuild(key, getAttribute(key), null);
    if (_state != null && shouldRebuild) {
      _state!.requestUpdateState();
    }
    attributeDidUpdate(key, '');
  }

  @mustCallSuper
  @override
  void setAttribute(String key, value) {
    super.setAttribute(key, value);
    bool shouldRebuild = shouldElementRebuild(key, getAttribute(key), value);
    if (_state != null && shouldRebuild) {
      _state!.requestUpdateState();
    }
    attributeDidUpdate(key, value);
  }

  @nonVirtual
  @override
  dom.Node appendChild(dom.Node child) {
    super.appendChild(child);

    // Only trigger update if the child are created by JS. If it's created on Flutter widgets, the flutter framework will handle this.
    if (_state != null) {
      _state!.requestUpdateState();
    }

    return child;
  }

  @nonVirtual
  @override
  dom.Node insertBefore(dom.Node child, dom.Node referenceNode) {
    dom.Node inserted = super.insertBefore(child, referenceNode);

    if (_state != null) {
      _state!.requestUpdateState();
    }

    return inserted;
  }

  @nonVirtual
  @override
  dom.Node? replaceChild(dom.Node newNode, dom.Node oldNode) {
    dom.Node? replaced = super.replaceChild(newNode, oldNode);

    if (_state != null) {
      _state!.requestUpdateState();
    }

    return replaced;
  }

  @nonVirtual
  @override
  dom.Node removeChild(dom.Node child) {
    super.removeChild(child);

    if (_state != null) {
      _state!.requestUpdateState();
    }

    return child;
  }

  void attachWidget(Widget widget) {
    if (attachedAdapter == null) return;

    if (ownerDocument.controller.mode == WebFLoadingMode.standard ||
        ownerDocument.controller.isPreLoadingOrPreRenderingComplete) {
      ownerDocument.controller.onCustomElementAttached!(attachedAdapter!);
    } else {
      ownerDocument.controller.pendingWidgetElements.add(attachedAdapter!);
    }
  }

  void detachWidget() {
    if (attachedAdapter != null && !managedByFlutterWidget) {
      ownerDocument.controller.onCustomElementDetached!(attachedAdapter!);
      attachedAdapter = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    ownerDocument.aliveWidgetElements.remove(this);
  }
}

class _WidgetElementAdapter extends StatefulWidget {
  final WidgetElement widgetElement;

  _WidgetElementAdapter(this.widgetElement, {Key? key}) : super(key: key);

  @override
  StatefulElement createElement() {
    return WebFWidgetElementElement(this);
  }

  @override
  State<StatefulWidget> createState() {
    _WebFWidgetElementState state = _WebFWidgetElementState(widgetElement);
    widgetElement.state = state;
    return state;
  }

  @override
  String toStringShort() {
    return '_WidgetElementAdapter(${widgetElement.tagName.toLowerCase()})';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class WebFWidgetElementElement extends StatefulElement {
  WebFWidgetElementElement(super.widget);

  @override
  _WidgetElementAdapter get widget => super.widget as _WidgetElementAdapter;

  @override
  _WebFWidgetElementState get state => super.state as _WebFWidgetElementState;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
  }
}

class _WebFWidgetElementState extends State<_WidgetElementAdapter> {
  final WidgetElement widgetElement;

  _WebFWidgetElementState(this.widgetElement);

  @override
  void initState() {
    super.initState();
    widgetElement.initState();
  }

  void requestUpdateState([VoidCallback? callback]) {
    if (mounted) {
      setState(callback ?? () {});
    }
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WidgetElement(${widgetElement.tagName.toLowerCase()}) adapterWidgetState';
  }

  @override
  Widget build(BuildContext context) {
    return widgetElement.build(context, widgetElement.childNodes as dom.ChildNodeList);
  }
}

class SharedRenderWidgetAdapter<T extends RenderObject> extends SingleChildRenderObjectWidget {
  SharedRenderWidgetAdapter({
    Widget? child,
    required this.container,
    required this.widgetElement,
    this.debugShortDescription,
  }) : super(key: GlobalObjectKey(container), child: child);

  /// The [RenderObject] that is the parent of the [Element] created by this widget.
  final RenderObject container;

  final WidgetElement widgetElement;

  /// A short description of this widget used by debugging aids.
  final String? debugShortDescription;

  @override
  _SharedRenderWidgetElement<T> createElement() => _SharedRenderWidgetElement<T>(this);

  @override
  RenderObject createRenderObject(BuildContext context) => container;

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {}

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    // WidgetElement can be remounted to the DOM tree and trigger widget adapter updates.
    // We need to check if the widgetElement is actually disconnected before unmounting the renderWidget.
    if (!widgetElement.isConnected) {
      widgetElement.unmountRenderObjectInDOMMode();
    }
  }

  @override
  String toStringShort() => '<${widgetElement.tagName.toLowerCase()} />';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('renderStyle', widgetElement.renderStyle));
    properties.add(DiagnosticsProperty('id', widgetElement.id));
    properties.add(DiagnosticsProperty('className', widgetElement.className));
  }
}

/// Sharing the RenderWidget renderObject beween Flutter element and WebF DOM Elements.
class _SharedRenderWidgetElement<T extends RenderObject> extends SingleChildRenderObjectElement {
  _SharedRenderWidgetElement(SharedRenderWidgetAdapter<T> widget) : super(widget);

  @override
  SharedRenderWidgetAdapter get widget => super.widget as SharedRenderWidgetAdapter<T>;

  @override
  RenderObjectWithChildMixin<RenderObject> get renderObject =>
      super.renderObject as RenderObjectWithChildMixin<RenderObject>;

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

class WebFRenderWidgetAdaptor extends SingleChildRenderObjectWidget {
  WebFRenderWidgetAdaptor(this.widgetElement, {Widget? child, Key? key}) : super(child: child, key: key);

  final WidgetElement widgetElement;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return widgetElement.renderStyle.getWidgetPairedRenderBoxModel(context as RenderObjectElement)!;
  }

  @override
  String toStringShort() => '<${widgetElement.tagName.toLowerCase()} />';

  @override
  SingleChildRenderObjectElement createElement() {
    return RenderWidgetElement(this);
  }
}

class RenderWidgetElement extends SingleChildRenderObjectElement {
  RenderWidgetElement(super.widget);

  @override
  WebFRenderWidgetAdaptor get widget => super.widget as WebFRenderWidgetAdaptor;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild() {
    visitChildElements((element) {
      if (element is WebFWidgetElementElement) {
        element.state.requestUpdateState();
      }
    });
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    widget.widgetElement.willAttachRenderer(this);
    super.mount(parent, newSlot);
    widget.widgetElement.didAttachRenderer(this);
  }

  @override
  void unmount() {
    super.unmount();
  }

}
