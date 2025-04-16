/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
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
  final Set<WebFWidgetElementState> _widgetElementStates = {};

  void _addWidgetElementState(WebFWidgetElementState newState) {
    _widgetElementStates.add(newState);
  }

  void _removeWidgetElementState(WebFWidgetElementState oldState) {
    _widgetElementStates.remove(oldState);
  }

  WebFController get controller => ownerDocument.controller;

  WebFWidgetElementState? get state {
    final stateFinder = _widgetElementStates.where((state) => state.mounted == true);
    return stateFinder.isEmpty ? null : stateFinder.last;
  }

  WebFWidgetElementState createState();

  @override
  dom.ChildNodeList get childNodes => super.childNodes as dom.ChildNodeList;
  bool isRouterLinkElement = false;

  WidgetElement(BindingContext? context) : super(context) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget toWidget({Key? key}) {
    WidgetElementAdapter widget = WidgetElementAdapter(this, key: key ?? this.key);
    return widget;
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  // React to properties and attributes changes
  void attributeDidUpdate(String key, String value) {}

  bool shouldElementRebuild(String key, previousValue, nextValue) {
    return previousValue != nextValue;
  }

  void propertyDidUpdate(String key, value) {}

  void styleDidUpdate(String property, String value) {}

  // The render object is inserted by Flutter framework when element is WidgetElement.
  @override
  dom.RenderObjectManagerType get renderObjectManagerType => dom.RenderObjectManagerType.FLUTTER_ELEMENT;

  @nonVirtual
  @override
  bool get isWidgetElement => true;

  bool get isScrollingElement => false;

  @mustCallSuper
  @override
  void didDetachRenderer([RenderObjectElement? flutterWidgetElement]) {
    super.didDetachRenderer(flutterWidgetElement);
  }

  /// [willAttachRenderer] and [didAttachRenderer] on WidgetElement will be called when this WidgetElement's parent is
  /// standard WebF element.
  /// If this WidgetElement's parent is another WidgetElement, [WebFWidgetElementAdapterElement.mount] and [WebFWidgetElementAdapterElement.unmount]
  /// place the equivalence altitude to the [willAttachRenderer] and [didAttachRenderer].
  @mustCallSuper
  @override
  RenderObject willAttachRenderer([RenderObjectElement? flutterWidgetElement]) {
    RenderObject renderObject = super.willAttachRenderer(flutterWidgetElement);
    return renderObject;
  }

  @mustCallSuper
  @override
  void didAttachRenderer([Element? flutterWidgetElement]) {}

  @override
  void setInlineStyle(String property, String value) {
    bool shouldRebuild = shouldElementRebuild(property, style.getPropertyValue(property), value);
    super.setInlineStyle(property, value);
    if (state != null && shouldRebuild) {
      state!.requestUpdateState();
    }
    styleDidUpdate(property, value);
  }

  @mustCallSuper
  @override
  void removeAttribute(String key) {
    bool shouldRebuild = shouldElementRebuild(key, getAttribute(key), null);
    super.removeAttribute(key);
    if (state != null && shouldRebuild) {
      state!.requestUpdateState();
    }
    attributeDidUpdate(key, '');
  }

  @mustCallSuper
  @override
  void setAttribute(String key, value) {
    bool shouldRebuild = shouldElementRebuild(key, getAttribute(key), value);
    super.setAttribute(key, value);
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
}

class WidgetElementAdapter extends dom.WebFElementWidget {
  WidgetElement get widgetElement => super.webFElement as WidgetElement;

  WidgetElementAdapter(WidgetElement widgetElement, {Key? key}) : super(widgetElement, key: key);

  @override
  StatefulElement createElement() {
    return WebFWidgetElementAdapterElement(this);
  }

  @override
  State<StatefulWidget> createState() {
    return WebFWidgetElementAdapterState(widgetElement);
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

class WebFWidgetElementAdapterElement extends StatefulElement {
  WebFWidgetElementAdapterElement(super.widget);

  @override
  WidgetElementAdapter get widget => super.widget as WidgetElementAdapter;

  @override
  WebFWidgetElementAdapterState get state => super.state as WebFWidgetElementAdapterState;
}

class WebFWidgetElement extends StatefulWidget {
  final WidgetElement widgetElement;

  WebFWidgetElement(this.widgetElement);

  @override
  State<StatefulWidget> createState() {
    WebFWidgetElementState state = widgetElement.createState();
    widgetElement._addWidgetElementState(state);
    return state;
  }
}

abstract class WebFWidgetElementState extends State<WebFWidgetElement> {
  final WidgetElement widgetElement;

  WebFWidgetElementState(this.widgetElement);

  void requestUpdateState([VoidCallback? callback, AdapterUpdateReason? reason]) {
    if (mounted) {
      setState(() {
        if (callback != null) {
          callback();
        }
      });
    }
  }

  String? getRenderObjectTree() {
    return context.findRenderObject()?.toStringDeep();
  }

  @override
  void dispose() {
    widgetElement._removeWidgetElementState(this);
    super.dispose();
  }
}

class WebFWidgetElementAdapterState extends dom.WebFElementWidgetState {
  WebFWidgetElementAdapterState(WidgetElement widgetElement): super(widgetElement);

  WidgetElement get widgetElement => super.webFElement as WidgetElement;

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
    super.build(context);

    if (widgetElement.renderStyle.display == CSSDisplay.none) {
      return SizedBox.shrink();
    }

    Widget child = WebFWidgetElement(widgetElement);

    if (widgetElement.isRepaintBoundary) {
      child = RepaintBoundary(child: child);
    }
    if (widgetElement.hasEvent) {
      child = WebFEventListener(ownerElement: widgetElement, child: child);
    }

    final positionedElements = widgetElement.childNodes.where((node) {
      return node is dom.Element && (node.renderStyle.isSelfPositioned());
    });

    List<Widget> children = [child, ...positionedElements.map((element) => element.toWidget())];

    return WebFRenderWidgetAdaptor(widgetElement, children: children);
  }
}

class WebFRenderWidgetAdaptor extends MultiChildRenderObjectWidget {
  WebFRenderWidgetAdaptor(this.widgetElement, {required List<Widget> children, Key? key})
      : super(children: children, key: key);

  final WidgetElement widgetElement;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return widgetElement.renderStyle.getWidgetPairedRenderBoxModel(context as RenderObjectElement)!;
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
    widget.widgetElement.forEachState((state) {
      if (!state.mounted) return;
      (state as WebFWidgetElementAdapterState).requestUpdateState(null, reason);
    });
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    widget.widgetElement.willAttachRenderer(this);
    super.mount(parent, newSlot);
    widget.widgetElement.didAttachRenderer(this);

    ModalRoute? route = ModalRoute.of(this);
    dom.OnScreenEvent event = dom.OnScreenEvent(state: route?.settings.arguments, path: route?.settings.name ?? '');

    WidgetElement widgetElement = widget.widgetElement;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      widgetElement.dispatchEvent(event);
    });
  }

  @override
  void deactivate() {
    ModalRoute? route = ModalRoute.of(this);
    dom.OffScreenEvent event = dom.OffScreenEvent(state: route?.settings.arguments, path: route?.settings.name ?? '');
    WidgetElement widgetElement = widget.widgetElement;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widgetElement.dispatchEvent(event);
    });
    super.deactivate();
  }

  @override
  void unmount() {
    dom.Element widgetElement = widget.widgetElement;
    widgetElement.willDetachRenderer(this);
    super.unmount();
    widgetElement.didDetachRenderer(this);
  }
}
