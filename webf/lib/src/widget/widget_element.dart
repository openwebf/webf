/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/launcher.dart';
import 'package:webf/src/bridge/binding_object.dart';
import 'package:webf/widget.dart';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

// WidgetElement is the base class for custom elements which rendering details are implemented by Flutter widgets.
abstract class WidgetElement extends dom.Element {
  // An state
  WidgetElementAdapter? _widgetAdapter;

  WidgetElementAdapter get widgetAdapter {
    _widgetAdapter ??= WidgetElementAdapter(this);
    return _widgetAdapter!;
  }

  final Set<WebFWidgetElementState> _states = {};

  WebFWidgetElementState? get state {
    final stateFinder = _states.where((state) => state.mounted == true);
    return stateFinder.isEmpty ? null : stateFinder.first;
  }

  set state(WebFWidgetElementState? newState) {
    if (newState == null) return;
    _states.add(newState);
  }

  WebFWidgetElementState createState() {
    WebFWidgetElementState state = WebFWidgetElementState(this);
    return state;
  }

  @override
  dom.ChildNodeList get childNodes => super.childNodes as dom.ChildNodeList;

  bool isRouterLinkElement = false;

  BuildContext get context {
    return state!.context;
  }

  WidgetElement(BindingContext? context) : super(context) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget toWidget({Key? key}) {
    WidgetElementAdapter widget = WidgetElementAdapter(this);
    return widget;
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  // State methods, proxy called from _state
  void initState() {}

  void didChangeDependencies() {}

  void mount() {}

  void unmount() {}

  bool get mounted => state?.mounted ?? false;

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
    super.didDetachRenderer(flutterWidgetElement);
    detachWidget();
  }

  @nonVirtual
  void setState(VoidCallback callback) {
    if (state != null) {
      state!.requestUpdateState(callback);
    } else {
      callback();
    }
  }

  /// [willAttachRenderer] and [didAttachRenderer] on WidgetElement will be called when this WidgetElement's parent is
  /// standard WebF element.
  /// If this WidgetElement's parent is another WidgetElement, [WebFWidgetElementElement.mount] and [WebFWidgetElementElement.unmount]
  /// place the equivalence altitude to the [willAttachRenderer] and [didAttachRenderer].
  @mustCallSuper
  @override
  RenderObject willAttachRenderer([RenderObjectElement? flutterWidgetElement]) {
    RenderObject renderObject = super.willAttachRenderer(flutterWidgetElement);
    // if (renderStyle.display != CSSDisplay.none && !managedByFlutterWidget) {
      // RenderObject hostedRenderObject = flutterWidgetElement != null
      //     ? renderStyle.getWidgetPairedRenderBoxModel(flutterWidgetElement)!
      //     : renderStyle.domRenderBoxModel!;
      // attachedAdapter = widget;
      // List<Widget> children = [widget, ...positionedElements.map((element) => element.toWidget())];
      // attachedAdapter =
      //     SharedRenderWidgetAdapter(children: children, container: hostedRenderObject, widgetElement: this);
    // }
    return renderObject;
  }

  @mustCallSuper
  @override
  void didAttachRenderer([Element? flutterWidgetElement]) {
    // Children of WidgetElement should insert render object by Flutter Framework.
    attachWidget();
  }

  // Reconfigure renderObjects when already rendered pages reattached to flutter tree
  void reactiveRenderer() {
    if (renderStyle.display != CSSDisplay.none && !managedByFlutterWidget) {
      // Generate a new adapter for this RenderWidget
      willAttachRenderer();

      // Reattach to Flutter
      ownerDocument.controller.onCustomElementAttached!(widgetAdapter);

      parentElement?.ensureChildAttached();
    }
  }

  void reattachWidgetInDOMMode() {
    if (attachedRenderer == null) return;
    assert(!managedByFlutterWidget);
    // RenderWidget hostedRenderObject = renderStyle.attachedRenderBoxModel! as RenderWidget;
    detachWidget();
    willAttachRenderer();
    didAttachRenderer();
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
    if (state != null && shouldRebuild) {
      state!.requestUpdateState();
    }
    styleDidUpdate(property, value);
  }

  @mustCallSuper
  @override
  void removeAttribute(String key) {
    super.removeAttribute(key);
    bool shouldRebuild = shouldElementRebuild(key, getAttribute(key), null);
    if (state != null && shouldRebuild) {
      state!.requestUpdateState();
    }
    attributeDidUpdate(key, '');
  }

  @mustCallSuper
  @override
  void setAttribute(String key, value) {
    super.setAttribute(key, value);
    bool shouldRebuild = shouldElementRebuild(key, getAttribute(key), value);
    if (state != null && shouldRebuild) {
      state!.requestUpdateState();
    }
    attributeDidUpdate(key, value);
  }

  @nonVirtual
  @override
  dom.Node appendChild(dom.Node child) {
    super.appendChild(child);

    // Only trigger update if the child are created by JS. If it's created on Flutter widgets, the flutter framework will handle this.
    if (state != null) {
      state!.requestUpdateState();
    }

    return child;
  }

  @nonVirtual
  @override
  dom.Node insertBefore(dom.Node child, dom.Node referenceNode) {
    dom.Node inserted = super.insertBefore(child, referenceNode);

    if (state != null) {
      state!.requestUpdateState();
    }

    return inserted;
  }

  @nonVirtual
  @override
  dom.Node? replaceChild(dom.Node newNode, dom.Node oldNode) {
    dom.Node? replaced = super.replaceChild(newNode, oldNode);

    if (state != null) {
      state!.requestUpdateState();
    }

    return replaced;
  }

  @nonVirtual
  @override
  dom.Node removeChild(dom.Node child) {
    super.removeChild(child);

    if (state != null) {
      state!.requestUpdateState();
    }

    return child;
  }

  void attachWidget() {
    if (managedByFlutterWidget) return;

    if (ownerDocument.controller.mode == WebFLoadingMode.standard ||
        ownerDocument.controller.isPreLoadingOrPreRenderingComplete) {
      ownerDocument.controller.onCustomElementAttached!(widgetAdapter);
    } else {
      ownerDocument.controller.pendingWidgetElements.add(widgetAdapter);
    }
  }

  void detachWidget() {
    if (!managedByFlutterWidget &&
        ownerDocument.controller.onCustomElementDetached != null) {
      ownerDocument.controller.onCustomElementDetached!(widgetAdapter);
      _widgetAdapter = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _states.clear();
    _widgetAdapter = null;
    ownerDocument.aliveWidgetElements.remove(this);
  }
}

class WidgetElementAdapter extends StatefulWidget {
  final WidgetElement widgetElement;

  WidgetElementAdapter(this.widgetElement, {Key? key}) : super(key: key);

  @override
  StatefulElement createElement() {
    return WebFWidgetElementElement(this);
  }

  @override
  State<StatefulWidget> createState() {
    WebFWidgetElementState state = widgetElement.createState();
    widgetElement.state = state;
    return state;
  }

  @override
  String toStringShort() {
    return 'WidgetElementAdapter(${widgetElement.tagName.toLowerCase()})';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class WebFWidgetElementElement extends StatefulElement {
  WebFWidgetElementElement(super.widget);

  @override
  WidgetElementAdapter get widget => super.widget as WidgetElementAdapter;

  @override
  WebFWidgetElementState get state => super.state as WebFWidgetElementState;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    widget.widgetElement.mount();
  }

  @override
  void unmount() {
    WidgetElement widgetElement = widget.widgetElement;
    super.unmount();
    widgetElement.unmount();
  }
}

class WebFWidgetElementState extends State<WidgetElementAdapter> {
  final WidgetElement widgetElement;

  WebFWidgetElementState(this.widgetElement);

  @override
  void initState() {
    super.initState();
    widgetElement.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widgetElement.didChangeDependencies();
  }

  void requestUpdateState([VoidCallback? callback, AdapterUpdateReason? reason]) {
    if (mounted) {
      setState(() {
        if (callback != null) {
          callback();
        }
      });
    }
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WidgetElementState(${widgetElement.tagName.toLowerCase()})#${shortHash(this)}';
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widgetElement.build(context, widgetElement.childNodes);

    if (widgetElement.isRepaintBoundary) {
      child = RepaintBoundary(child: child);
    }
    if (widgetElement.hasEvent) {
      child = Portal(ownerElement: widgetElement, child: child);
    }

    List<Widget> children = [child, ...widgetElement.positionedElements.map((element) => element.toWidget())];

    return WebFRenderWidgetAdaptor(widgetElement, children: children, key: Key(widgetElement.hashKey));
  }

  @override
  void dispose() {
    widgetElement._widgetAdapter = null;
    widgetElement._states.remove(this);
    super.dispose();
  }
}

class WebFRenderWidgetAdaptor extends MultiChildRenderObjectWidget {
  WebFRenderWidgetAdaptor(this.widgetElement, {required List<Widget> children, Key? key})
      : super(children: children, key: key);

  final WidgetElement widgetElement;

  @override
  RenderObject createRenderObject(BuildContext context) {
    if (widgetElement.managedByFlutterWidget) {
      return widgetElement.renderStyle.getWidgetPairedRenderBoxModel(context as RenderObjectElement)!;
    }
    return widgetElement.domRenderer!;
  }

  @override
  String toStringShort() => '<${widgetElement.tagName.toLowerCase()} />';

  @override
  MultiChildRenderObjectElement createElement() {
    return RenderWidgetElement(this);
  }
}

class RenderWidgetElement extends MultiChildRenderObjectElement {
  RenderWidgetElement(super.widget);

  @override
  WebFRenderWidgetAdaptor get widget => super.widget as WebFRenderWidgetAdaptor;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild(AdapterUpdateReason reason) {
    visitChildElements((element) {
      if (element is WebFWidgetElementElement) {
        element.state.requestUpdateState(null, reason);
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
    dom.Element widgetElement = widget.widgetElement;
    widgetElement.willDetachRenderer(this);
    super.unmount();
    widgetElement.didDetachRenderer(this);
  }
}
