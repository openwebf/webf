/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ui';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/html.dart';
import 'package:webf/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';
import 'package:webf/src/css/query_selector.dart' as query_selector;
import 'intersection_observer.dart';
import 'intersection_observer_entry.dart';

final RegExp classNameSplitRegExp = RegExp(r'\s+');
const String _oneSpace = ' ';
const String _styleProperty = 'style';
const String _idAttr = 'id';
const String _classNameAttr = 'class';
const String _nameAttr = 'name';

/// Defined by W3C Standard,
/// Most element's default width is 300 in pixel,
/// height is 150 in pixel.
const String elementDefaultWidth = '300px';
const String elementDefaultHeight = '150px';
const String unknown = 'UNKNOWN';

typedef TestElement = bool Function(Element element);
typedef ElementVisitor = void Function(Node child);

enum StickyPositionType {
  relative,
  fixed,
}

enum BoxSizeType {
  // Element which have intrinsic before layout. Such as <img /> and <video />
  intrinsic,

  // Element which have width or min-width properties defined.
  specified,

  // Element which neither have intrinsic or predefined size.
  automatic,
}

mixin ElementBase on Node {
  @pragma('vm:prefer-inline')
  late CSSRenderStyle renderStyle;
}

typedef ForeachStateFunction = void Function(flutter.State state);
typedef BeforeRendererAttach = RenderObject Function();
typedef GetTargetId = int Function();
typedef GetRootElementFontSize = double Function();
typedef GetChildNodes = List<Node> Function();

/// Get the viewport size of current element.
typedef GetViewportSize = Size Function();

/// Get the render box model of current element.
typedef GetRenderBoxModel = RenderBoxModel? Function();

typedef ElementAttributeGetter = String? Function();
typedef ElementAttributeSetter = void Function(String value);
typedef ElementAttributeDeleter = void Function();

class ElementAttributeProperty {
  ElementAttributeProperty({this.getter, this.setter, this.deleter});

  final ElementAttributeGetter? getter;
  final ElementAttributeSetter? setter;
  final ElementAttributeDeleter? deleter;
}

abstract class Element extends ContainerNode
    with
        ElementBase,
        ElementEventMixin,
        ElementOverflowMixin,
        ElementAdapterMixin {
  // Default to unknown, assign by [createElement], used by inspector.
  String tagName = unknown;

  final Set<IntersectionObserver> _intersectionObserverList = {};
  List<double> _thresholds = [0.0];

  String? _id;

  String? get id => _id;

  set id(String? id) {
    final isNeedRecalculate = _checkRecalculateStyle([id, _id]);
    _updateIDMap(id, oldID: _id);
    _id = id;
    // Maintain attribute presence index for [id] selectors.
    // Treat any non-null assignment (including empty string) as presence=true.
    _updateAttrPresenceIndex(_idAttr, present: id != null);
    if (DebugFlags.enableCssBatchRecalc) {
      ownerDocument.markElementStyleDirty(this, reason: 'batch:id');

      return;
    }
    recalculateStyle(rebuildNested: isNeedRecalculate);
  }

  // Is element an replaced element.
  // https://drafts.csswg.org/css-display/#replaced-element
  @pragma('vm:prefer-inline')
  bool get isReplacedElement => false;

  @pragma('vm:prefer-inline')
  bool get isWidgetElement => false;

  @pragma('vm:prefer-inline')
  bool get isSVGElement => false;

  // The attrs.
  final Map<String, String> attributes = <String, String>{};

  /// The style of the element, not inline style.
  late CSSStyleDeclaration style;

  /// The default user-agent style.
  Map<String, dynamic> get defaultStyle => {};

  /// The inline style is a map of style property name to style property value.
  final Map<String, dynamic> inlineStyle = {};

  /// The StatefulElements that holding the reference of this elements
  @flutter.protected
  final Set<flutter.State> _states = {};

  @pragma('vm:prefer-inline')
  flutter.Key key = flutter.UniqueKey();

  void updateElementKey() {
    key = flutter.UniqueKey();
  }

  @nonVirtual
  void forEachState(ForeachStateFunction fn) {
    for (var state in _states) {
      if (state.mounted) {
        fn(state);
      }
    }
  }

  @nonVirtual
  void addState(flutter.State state) {
    _states.add(state);
  }

  @nonVirtual
  void removeState(flutter.State state) {
    _states.remove(state);
  }

  /// The Element.classList is a read-only property that returns a collection of the class attributes of the element.
  final List<String> _classList = [];

  String namespaceURI = '';

  List<String> get classList => _classList;

  @pragma('vm:prefer-inline')
  set className(String className) {
    final List<String> classList = className
        .split(classNameSplitRegExp)
        .where((e) => e.isNotEmpty)
        .toList();
    final List<String> oldClasses = List.from(_classList);
    final Iterable<String> checkKeys = (oldClasses + classList)
        .where((key) => !oldClasses.contains(key) || !classList.contains(key));
    final bool isNeedRecalculate = _checkRecalculateStyle(List.from(checkKeys));

    // Update internal class list
    _classList
      ..clear()
      ..addAll(classList);

    // Maintain document indices for classes when connected
    _updateClassIndex(oldClasses, _classList);
    // Maintain attribute presence index for [class] selectors.
    _updateAttrPresenceIndex(_classNameAttr, present: true);
    if (DebugFlags.enableCssBatchRecalc) {
      ownerDocument.markElementStyleDirty(this, reason: 'batch:class');

      return;
    }
    recalculateStyle(rebuildNested: isNeedRecalculate);
  }

  String get className => _classList.join(_oneSpace);

  PseudoElement? _beforeElement;
  PseudoElement? _afterElement;

  final bool isDefaultRepaintBoundary = false;

  @pragma('vm:prefer-inline')

  /// Whether should as a repaintBoundary for this element when style changed
  bool get isRepaintBoundary {
    // Following cases should always convert to repaint boundary for performance consideration.
    // Intrinsic element such as <canvas>.
    if (isDefaultRepaintBoundary || _forceToRepaintBoundary) return true;

    // Overflow style.
    bool hasOverflowScroll = renderStyle.overflowX == CSSOverflowType.scroll ||
        renderStyle.overflowX == CSSOverflowType.auto ||
        renderStyle.overflowY == CSSOverflowType.scroll ||
        renderStyle.overflowY == CSSOverflowType.auto;
    // Transform style.
    bool hasTransform = renderStyle.transformMatrix != null;
    // Fixed position style.
    bool hasPositionedFixed = renderStyle.position == CSSPositionType.fixed;

    return hasOverflowScroll || hasTransform || hasPositionedFixed;
  }

  @pragma('vm:prefer-inline')
  @override
  bool get isRendererAttached => renderStyle.isSelfRenderBoxAttached();

  bool _forceToRepaintBoundary = false;

  @pragma('vm:prefer-inline')
  set forceToRepaintBoundary(bool value) {
    if (_forceToRepaintBoundary == value || isRepaintBoundary) {
      return;
    }
    _forceToRepaintBoundary = value;
    renderStyle.requestWidgetToRebuild(ToRepaintBoundaryUpdateReason());
    updateElementKey();
  }

  final ElementRuleCollector _elementRuleCollector = ElementRuleCollector();

  Element(BindingContext? context) : super(NodeType.ELEMENT_NODE, context) {
    // Init style and add change listener.
    style = CSSStyleDeclaration.computedStyle(
        this, defaultStyle, _onStyleChanged, _onStyleFlushed);

    // Init render style.
    renderStyle = CSSRenderStyle(target: this);

    // Init attribute getter and setter.
    initializeAttributes(_attributeProperties);
  }

  @pragma('vm:prefer-inline')
  @override
  String get nodeName => tagName;

  @pragma('vm:prefer-inline')
  @override
  RenderBoxModel? get attachedRenderer => renderStyle.attachedRenderBoxModel;

  RenderLayoutBoxWrapper? get attachedRendererWrapper {
    if (attachedRenderer == null) {
      return null;
    }

    RenderObject? parent = attachedRenderer?.parent;
    while (parent is! RenderLayoutBoxWrapper) {
      parent = parent?.parent;
    }

    return parent;
  }

  RenderEventListener? get attachedRendererEventListener {
    if (attachedRenderer == null) {
      return null;
    }

    RenderObject? parent = attachedRenderer?.parent;
    while (parent is! RenderEventListener) {
      parent = parent?.parent;
    }

    return parent;
  }

  HTMLCollection? _collection;

  @pragma('vm:prefer-inline')
  HTMLCollection ensureCachedCollection() {
    _collection ??= HTMLCollection(this);
    return _collection!;
  }

  @pragma('vm:prefer-inline')
  // https://developer.mozilla.org/en-US/docs/Web/API/Element/children
  // The children is defined at interface [ParentNode].
  HTMLCollection get children => ensureCachedCollection();

  @override
  RenderBox createRenderer(
      [flutter.RenderObjectElement? flutterWidgetElement]) {
    return createRenderBoxModel(flutterWidgetElement: flutterWidgetElement)!;
  }

  String? collectElementChildText() {
    StringBuffer buffer = StringBuffer();
    for (final node in childNodes) {
      if (node is TextNode) {
        buffer.write(node.data);
      }
    }
    if (buffer.isNotEmpty) {
      return buffer.toString();
    } else {
      return null;
    }
  }

  final Map<String, ElementAttributeProperty> _attributeProperties = {};

  @mustCallSuper
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    attributes[_styleProperty] = ElementAttributeProperty(setter: (value) {
      final map = CSSParser(value).parseInlineStyle();
      inlineStyle.addAll(map);
      recalculateStyle();
    }, deleter: () {
      _removeInlineStyle();
    });
    attributes[_classNameAttr] = ElementAttributeProperty(
        setter: (value) => className = value,
        deleter: () {
          className = EMPTY_STRING;
        });
    attributes[_idAttr] = ElementAttributeProperty(
        setter: (value) => id = value,
        deleter: () {
          id = EMPTY_STRING;
        });
    attributes[_nameAttr] = ElementAttributeProperty(setter: (value) {
      _updateNameMap(value, oldName: getAttribute(_nameAttr));
    }, deleter: () {
      _updateNameMap(null, oldName: getAttribute(_nameAttr));
    });
  }

  static bool isElementStaticProperties(StaticDefinedBindingPropertyMap map) {
    return map == _elementProperties;
  }

  // https://www.w3.org/TR/cssom-view-1/#extensions-to-the-htmlelement-interface
  // https://www.w3.org/TR/cssom-view-1/#extension-to-the-element-interface
  static final StaticDefinedBindingPropertyMap _elementProperties = {
    'offsetTop': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).offsetTop),
    'offsetLeft': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).offsetLeft),
    'offsetWidth': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).offsetWidth),
    'offsetHeight': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).offsetHeight),
    'scrollTop': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).scrollTop,
        setter: (element, value) =>
            castToType<Element>(element).scrollTop = castToType<double>(value)),
    'scrollLeft': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).scrollLeft,
        setter: (element, value) => castToType<Element>(element).scrollLeft =
            castToType<double>(value)),
    'scrollWidth': StaticDefinedBindingProperty(
      getter: (element) => castToType<Element>(element).scrollWidth,
    ),
    'scrollHeight': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).scrollHeight),
    'clientTop': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).clientTop),
    'clientLeft': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).clientLeft),
    'clientWidth': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).clientWidth),
    'clientHeight': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).clientHeight),
    'id': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).id,
        setter: (element, value) =>
            castToType<Element>(element).id = castToType<String>(value)),
    'classList': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).classList),
    'className': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).className,
        setter: (element, value) =>
            castToType<Element>(element).className = castToType<String>(value)),
    'dir': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).dir),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties =>
      [...super.properties, _elementProperties];

  static bool isElementStaticSyncMethods(
      StaticDefinedSyncBindingObjectMethodMap map) {
    return map == _elementSyncMethods;
  }

  static final StaticDefinedSyncBindingObjectMethodMap _elementSyncMethods = {
    'getBoundingClientRect': StaticDefinedSyncBindingObjectMethod(
        call: (element, _) =>
            castToType<Element>(element).getBoundingClientRect()),
    'getClientRects': StaticDefinedSyncBindingObjectMethod(
        call: (element, _) => castToType<Element>(element).getClientRects()),
    'scroll': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) => castToType<Element>(element)
            .scroll(castToType<double>(args[0]), castToType<double>(args[1]))),
    'scrollBy': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) => castToType<Element>(element).scrollBy(
            castToType<double>(args[0]), castToType<double>(args[1]))),
    'scrollTo': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) => castToType<Element>(element).scrollTo(
            castToType<double>(args[0]), castToType<double>(args[1]))),
    'click': StaticDefinedSyncBindingObjectMethod(
        call: (element, _) => castToType<Element>(element).click()),
    'getElementsByClassName': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) =>
            castToType<Element>(element).getElementsByClassName(args)),
    'getElementsByTagName': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) =>
            castToType<Element>(element).getElementsByTagName(args)),
    'querySelectorAll': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) =>
            castToType<Element>(element).querySelectorAll(args)),
    'querySelector': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) =>
            castToType<Element>(element).querySelector(args)),
    'matches': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) => castToType<Element>(element).matches(args)),
    'closest': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) => castToType<Element>(element).closest(args)),
  };

  static final StaticDefinedSyncBindingObjectMethodMap _debugElementMethods = {
    '__test_global_to_local__': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) =>
            castToType<Element>(element).testGlobalToLocal(args[0], args[1])),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods {
    final list = <StaticDefinedSyncBindingObjectMethodMap>[
      ...super.methods,
      _elementSyncMethods
    ];
    if (kDebugMode || kProfileMode) list.add(_debugElementMethods);
    return list;
  }

  dynamic getElementsByClassName(List<dynamic> args) {
    return query_selector.querySelectorAll(this, '.${args.first}');
  }

  dynamic getElementsByTagName(List<dynamic> args) {
    return query_selector.querySelectorAll(this, args.first);
  }

  dynamic querySelector(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) {
      return null;
    }
    return query_selector.querySelector(this, args.first);
  }

  dynamic querySelectorAll(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return [];
    return query_selector.querySelectorAll(this, args.first);
  }

  bool matches(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) {
      return false;
    }
    return query_selector.matches(this, args.first);
  }

  dynamic closest(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) {
      return null;
    }
    return query_selector.closest(this, args.first);
  }

  RenderBoxModel? createRenderBoxModel(
      {flutter.RenderObjectElement? flutterWidgetElement}) {
    RenderBoxModel nextRenderBoxModel = renderStyle.createRenderBoxModel();

    assert(flutterWidgetElement != null);
    renderStyle.addOrUpdateWidgetRenderObjects(
        flutterWidgetElement!, nextRenderBoxModel);

    // Ensure that the event responder is bound.
    renderStyle.ensureEventResponderBound();

    // Ensure IntersectionObserver when renderBoxModel change.
    ensureAddIntersectionObserver();

    return nextRenderBoxModel;
  }

  RenderBoxModel createRenderSVG(
      {RenderBoxModel? previous, bool isRepaintBoundary = false}) {
    throw UnimplementedError();
  }

  @override
  RenderObject willAttachRenderer(
      [flutter.RenderObjectElement? flutterWidgetElement]) {
    if (renderStyle.display == CSSDisplay.none) {
      return RenderConstrainedBox(
          additionalConstraints: BoxConstraints.tight(Size.zero));
    }

    // Init render box model.
    return createRenderer(flutterWidgetElement);
  }

  @override
  void didAttachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    super.didAttachRenderer(flutterWidgetElement);

    // The node attach may affect the whitespace of the nextSibling and previousSibling text node so prev and next node require layout.
    // renderStyle.markAdjacentRenderParagraphNeedsLayout();
  }

  @override
  void willDetachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    super.willDetachRenderer(flutterWidgetElement);

    if (!renderStyle.hasRenderBox()) {
      // Cancel running transition.
      renderStyle.cancelRunningTransition();

      // Cancel running animation.
      renderStyle.cancelRunningAnimation();

      ownerView.window.unwatchViewportSizeChangeForElement(this);
    }

    // Remove all intersection change listeners.
    renderStyle.clearIntersectionChangeListeners(flutterWidgetElement);
    renderStyle.removeRenderObject(flutterWidgetElement);
  }

  BoundingClientRect getBoundingClientRect() => boundingClientRect;

  List<BoundingClientRect> getClientRects() {
    return [boundingClientRect];
  }

  bool _shouldConsumeScrollTicker = false;

  void _consumeScrollTicker(_) {
    if (_shouldConsumeScrollTicker && hasEventListener(EVENT_SCROLL)) {
      _dispatchScrollEvent();
    }
    _shouldConsumeScrollTicker = false;
  }

  /// https://drafts.csswg.org/cssom-view/#scrolling-events
  void _dispatchScrollEvent() {
    dispatchEvent(Event(EVENT_SCROLL));
  }

  void handleScroll(double scrollOffset, AxisDirection axisDirection) {
    if (!renderStyle.hasRenderBox()) return;
    _applyFixedChildrenOffset(scrollOffset, axisDirection);

    // Update sticky descendants' paint offsets when this element scrolls.
    _applyStickyChildrenOffsets();

    if (!_shouldConsumeScrollTicker) {
      // Make sure scroll listener trigger most to 1 time each frame.
      SchedulerBinding.instance.addPostFrameCallback(_consumeScrollTicker);
      SchedulerBinding.instance.scheduleFrame();
    }
    _shouldConsumeScrollTicker = true;
  }

  // Traverse subtree to update paint offsets for sticky elements constrained by this scroll container.
  void _applyStickyChildrenOffsets() {
    if (!isConnected) return;
    final RenderBoxModel? defaultScroller = attachedRenderer;
    if (defaultScroller == null) return;

    RenderBoxModel? nearestScrollContainer(RenderObject start) {
      RenderObject? current = start;
      while (current != null) {
        if (current is RenderBoxModel) {
          if (current.clipX || current.clipY) return current;
        }
        current = current.parent;
      }
      return null;
    }

    void visit(Element el) {
      for (final Node node in el.childNodes) {
        if (node is! Element) continue;
        final Element childEl = node;
        if (childEl.renderStyle.position == CSSPositionType.sticky) {
          final RenderBoxModel? rbm = childEl.attachedRenderer;
          final RenderBoxModel? cb =
              childEl.holderAttachedContainingBlockElement?.attachedRenderer;
          if (rbm != null) {
            // Use the child's own nearest scroll container so nested scrollers don't get
            // overridden by outer viewport updates (e.g., <html> / <body> setups).
            final RenderBoxModel scForChild =
                nearestScrollContainer(rbm) ?? defaultScroller;
            CSSPositionedLayout.applyStickyChildOffset(cb ?? scForChild, rbm,
                scrollContainer: scForChild);
          }
        }
        visit(childEl);
      }
    }

    visit(this);
  }

  /// Normally element in scroll box will not repaint on scroll because of repaint boundary optimization
  /// So it needs to manually mark element needs paint and add scroll offset in paint stage
  void _applyFixedChildrenOffset(
      double scrollOffset, AxisDirection axisDirection) {
    // Only apply scroll-compensation to fixed-positioned descendants.
    for (Element positioned in outOfFlowPositionedElements) {
      if (positioned.renderStyle.position != CSSPositionType.fixed) continue;
      if (axisDirection == AxisDirection.down) {
        positioned.attachedRenderer?.additionalPaintOffsetY = scrollOffset;
      } else if (axisDirection == AxisDirection.right) {
        positioned.attachedRenderer?.additionalPaintOffsetX = scrollOffset;
      }
    }
  }

  // Public hook to recompute sticky offsets for descendants constrained by this element
  // (typically called after scroll container viewport is established during layout).
  void updateStickyOffsets() {
    _applyStickyChildrenOffsets();
  }

  void _updateHostingWidgetWithOverflow(CSSOverflowType oldOverflow) {
    renderStyle.requestWidgetToRebuild(AddScrollerUpdateReason());
  }

  void _updateHostingWidgetWithTransform() {
    if (!renderStyle.isRepaintBoundary()) {
      updateElementKey();
      renderStyle.requestWidgetToRebuild(UpdateTransformReason());
    }
    // A transformed element establishes a fixed-position containing block per spec.
    // When transform toggles, out-of-flow positioned descendants may need to be
    // rehomed to a different containing block (e.g., fixed elements moving
    // between viewport and this element).
    _reattachOutOfFlowDescendantsToCorrectContainingBlocks();
  }

  void _updateHostingWidgetWithPosition(CSSPositionType oldPosition) {
    CSSPositionType currentPosition = renderStyle.position;
    if (oldPosition == currentPosition) return;

    // No need to detach and reattach renderBoxMode when its position
    // changes between static and relative.
    if (currentPosition == CSSPositionType.absolute ||
        currentPosition == CSSPositionType.sticky) {
      // Determine new containing block and attach there.
      Element? newContainingBlockElement = getContainingBlockElement();
      if (newContainingBlockElement == null) return;

      // If previously attached to a different containing block as positioned, remove it.
      if (holderAttachedContainingBlockElement != null &&
          holderAttachedContainingBlockElement != newContainingBlockElement) {
        holderAttachedContainingBlockElement!
            .removeOutOfFlowPositionedElement(this);
        holderAttachedContainingBlockElement!.renderStyle
            .requestWidgetToRebuild(UpdateChildNodeUpdateReason());
      }

      // Keep placeholder at original location for static-position anchor.
      renderStyle.requestWidgetToRebuild(ToPositionPlaceHolderUpdateReason(
          positionedElement: this,
          containingBlockElement: newContainingBlockElement));

      // Ensure the actual positioned renderObject is a direct child of the containing block.
      // Avoid duplicate attachment if it already exists.
      if (!newContainingBlockElement.outOfFlowPositionedElements
          .contains(this)) {
        newContainingBlockElement.renderStyle.requestWidgetToRebuild(
            AttachPositionedChild(
                positionedElement: this,
                containingBlockElement: newContainingBlockElement));
      }
    } else if (currentPosition == CSSPositionType.fixed) {
      // Find the renderBox of its containing block.
      Element? containingBlockElement = getContainingBlockElement();
      if (containingBlockElement == null) return;

      renderStyle.requestWidgetToRebuild(ToPositionPlaceHolderUpdateReason(
          positionedElement: this,
          containingBlockElement: containingBlockElement));
      if (!containingBlockElement.outOfFlowPositionedElements.contains(this)) {
        containingBlockElement.renderStyle.requestWidgetToRebuild(
            AttachPositionedChild(
                positionedElement: this,
                containingBlockElement: containingBlockElement));
      }
    } else if (currentPosition == CSSPositionType.static) {
      Element? elementNeedsToRebuild;

      if (oldPosition == CSSPositionType.fixed ||
          oldPosition == CSSPositionType.absolute ||
          oldPosition == CSSPositionType.sticky) {
        // Remove from the (previous) containing block's positioned list.
        Element? containingBlockElement =
            getContainingBlockElement(positionType: oldPosition);
        containingBlockElement?.removeOutOfFlowPositionedElement(this);
        elementNeedsToRebuild = containingBlockElement;
      } else {
        elementNeedsToRebuild = parentElement;
      }

      elementNeedsToRebuild?.renderStyle
          .requestWidgetToRebuild(ToStaticLayoutUpdateReason());

      // If this element no longer establishes a containing block (e.g., relative -> static),
      // rehome any out-of-flow positioned descendants whose containing block was this element.
      _reattachOutOfFlowDescendantsToCorrectContainingBlocks();
      updateElementKey();
    } else if (currentPosition == CSSPositionType.relative) {
      // When becoming a positioned ancestor (static -> relative), some absolutely-positioned
      // descendants may now use this element as their nearest containing block.
      _reattachOutOfFlowDescendantsToCorrectContainingBlocks();
    }
  }

  // Walk subtree and ensure any out-of-flow positioned descendants are attached under
  // the correct containing block after this element's position change.
  void _reattachOutOfFlowDescendantsToCorrectContainingBlocks() {
    // Fast-exit if not connected; no render objects to update yet.
    if (!isConnected) return;

    void visit(Element el) {
      for (final Node node in el.childNodes) {
        if (node is! Element) continue;
        final Element child = node;
        final CSSPositionType pos = child.renderStyle.position;
        // Only consider out-of-flow positioned descendants.
        if (pos == CSSPositionType.absolute ||
            pos == CSSPositionType.fixed ||
            pos == CSSPositionType.sticky) {
          // New containing block after our position change.
          final Element? newCB = child.getContainingBlockElement();
          final Element? oldCB = child.holderAttachedContainingBlockElement;

          if (newCB != oldCB) {
            // Detach from old containing block list if present.
            if (oldCB != null) {
              oldCB.removeOutOfFlowPositionedElement(child);
              oldCB.renderStyle
                  .requestWidgetToRebuild(UpdateChildNodeUpdateReason());
            }

            if (newCB != null) {
              // Update child's placeholder mapping so parents render the placeholder correctly.
              child.renderStyle.requestWidgetToRebuild(
                ToPositionPlaceHolderUpdateReason(
                    positionedElement: child, containingBlockElement: newCB),
              );

              // Attach positioned child under its new containing block for actual renderObject placement.
              if (!newCB.outOfFlowPositionedElements.contains(child)) {
                newCB.renderStyle.requestWidgetToRebuild(
                  AttachPositionedChild(
                      positionedElement: child, containingBlockElement: newCB),
                );
              } else {
                // Still ensure the new containing block rebuilds to reflect placeholder/offset updates.
                newCB.renderStyle
                    .requestWidgetToRebuild(UpdateChildNodeUpdateReason());
              }
            } else {
              // Fallback: no valid containing block; treat as static layout for safety.
              child.renderStyle
                  .requestWidgetToRebuild(ToStaticLayoutUpdateReason());
            }
          }
        }

        // Continue traversal for deeper descendants.
        visit(child);
      }
    }

    visit(this);
  }

  // Parse 'counter-*' shorthand values into a simple map: name -> integer
  Map<String, int> _parseCounterList(String value) {
    Map<String, int> result = {};
    // Split by whitespace, treat pairs of (ident [number]?)
    final parts = value.trim().split(RegExp(r"\s+"));
    int i = 0;
    while (i < parts.length) {
      final name = parts[i];
      if (name.isEmpty) {
        i++;
        continue;
      }
      int step = 0;
      // Default for reset is 0; for increment, caller may override default=1
      if (i + 1 < parts.length) {
        final next = parts[i + 1];
        final n = int.tryParse(next);
        if (n != null) {
          step = n;
          i += 2;
          result[name] = step;
          continue;
        }
      }
      result[name] = step;
      i++;
    }
    return result;
  }

  Map<String, int> _parseCounterIncrementList(String value) {
    Map<String, int> result = {};
    final parts = value.trim().split(RegExp(r"\s+"));
    int i = 0;
    while (i < parts.length) {
      final name = parts[i];
      if (name.isEmpty) {
        i++;
        continue;
      }
      int step = 1; // default increment is 1
      if (i + 1 < parts.length) {
        final next = parts[i + 1];
        final n = int.tryParse(next);
        if (n != null) {
          step = n;
          i += 2;
          result[name] = step;
          continue;
        }
      }
      result[name] = step;
      i++;
    }
    return result;
  }

  // Compute the current counter value for a given name at this element's point
  int _computeCounterValue(String name) {
    String getProp(CSSStyleDeclaration style, String camel, String kebab) {
      final v1 = style.getPropertyValue(camel);
      if (v1.isNotEmpty) return v1;
      return style.getPropertyValue(kebab);
    }

    // 1) Find nearest ancestor that resets the counter
    Element? scope = this;
    int initial = 0;
    while (scope != null) {
      final reset = getProp(scope.style, 'counterReset', 'counter-reset');
      if (reset.isNotEmpty && reset != 'none') {
        final map = _parseCounterList(reset);
        if (map.containsKey(name)) {
          initial = map[name] ?? 0;
          if (DebugFlags.enableDomLogs) {
            domLogger.fine(
                '[Counter] reset at <${scope.tagName.toLowerCase()}> $name=$initial raw="$reset"');
          }
          break;
        }
      }
      scope = scope.parentElement;
    }

    // 2) Walk document order from scope to this, summing increments
    int value = initial;
    scope ??= ownerDocument.documentElement;
    bool reached = false;

    void walk(Node node) {
      if (reached) return;
      if (node is Element) {
        // increments on element itself
        final incEl =
            getProp(node.style, 'counterIncrement', 'counter-increment');
        if (incEl.isNotEmpty && incEl != 'none') {
          final map = _parseCounterIncrementList(incEl);
          final add = (map[name] ?? 0);
          value += add;
          if (add != 0 && DebugFlags.enableDomLogs) {
            domLogger.fine(
                '[Counter] element <${node.tagName.toLowerCase()}> inc $name += $add (raw="$incEl") → $value');
          }
        }
        // increments on ::before pseudo only for the current element being evaluated
        if (identical(node, this)) {
          final incBefore = node.style.pseudoBeforeStyle == null
              ? ''
              : getProp(node.style.pseudoBeforeStyle!, 'counterIncrement',
                  'counter-increment');
          if (incBefore.isNotEmpty && incBefore != 'none') {
            final map = _parseCounterIncrementList(incBefore);
            final add = (map[name] ?? 0);
            value += add;
            if (add != 0 && DebugFlags.enableDomLogs) {
              domLogger.fine(
                  '[Counter] ::before of <${node.tagName.toLowerCase()}> inc $name += $add (raw="$incBefore") → $value');
            }
          }
        }
        if (identical(node, this)) {
          if (DebugFlags.enableDomLogs) {
            domLogger.fine(
                '[Counter] reached target <${node.tagName.toLowerCase()}> $name = $value');
          }
          reached = true;
          return;
        }
      }
      for (final child in node.childNodes) {
        if (reached) return;
        walk(child);
      }
    }

    if (scope != null) walk(scope);
    if (DebugFlags.enableDomLogs) {
      domLogger.fine(
          '[Counter] final for <${tagName.toLowerCase()}> $name = $value');
    }
    return value;
  }

  String _evaluateContent(String content) {
    StringBuffer out = StringBuffer();
    int i = 0;
    while (i < content.length) {
      final ch = content[i];
      if (ch == '"' || ch == '\'') {
        final quote = ch;
        i++;
        int start = i;
        while (i < content.length && content[i] != quote) {
          i++;
        }
        out.write(content.substring(start, i));
        if (i < content.length && content[i] == quote) i++;
        if (i < content.length && content[i] == ' ') i++;
        continue;
      }
      // try function: counter(name)
      // read identifier
      int startIdent = i;
      while (i < content.length && RegExp(r'[a-zA-Z_-]').hasMatch(content[i])) {
        i++;
      }
      final ident = content.substring(startIdent, i);
      if (ident.isNotEmpty && i < content.length && content[i] == '(') {
        // parse args until ')'
        i++; // skip '('
        int argStart = i;
        while (i < content.length && content[i] != ')') {
          i++;
        }
        String args = content.substring(argStart, i).trim();
        if (i < content.length && content[i] == ')') i++;
        if (ident == 'counter') {
          // args: name [ , style ]? (we handle only name)
          String counterName = args.split(',')[0].trim();
          if (counterName.startsWith('"') || counterName.startsWith('\'')) {
            counterName = counterName.substring(1, counterName.length - 1);
          }
          final v = _computeCounterValue(counterName);
          if (DebugFlags.enableDomLogs) {
            domLogger.fine('[Content] counter($counterName) → $v');
          }
          out.write(v.toString());
        }
        // skip optional spaces
        while (i < content.length && content[i] == ' ') {
          i++;
        }
        continue;
      }
      // otherwise skip or write char
      out.write(ch);
      i++;
    }
    return out.toString();
  }

  PseudoElement _createOrUpdatePseudoElement(String contentValue,
      PseudoKind kind, PseudoElement? previousPseudoElement) {
    // Resolve CSS content value first so we can update text correctly.
    final pseudoValue = CSSPseudo.resolveContent(contentValue);

    // Ensure we have a pseudo element instance to work with.
    previousPseudoElement ??= PseudoElement(
        kind,
        this,
        BindingContext(ownerDocument.controller.view, contextId!,
            allocateNewBindingObject()));

    // Merge pseudo-specific style rules collected on the parent onto the pseudo element.
    previousPseudoElement.style.merge(kind == PseudoKind.kPseudoBefore
        ? style.pseudoBeforeStyle!
        : style.pseudoAfterStyle!);

    // Attach the pseudo element to the correct position in the DOM tree if not already attached.
    switch (kind) {
      case PseudoKind.kPseudoBefore:
        if (previousPseudoElement.parentNode == null) {
          if (firstChild != null) {
            insertBefore(previousPseudoElement, firstChild!);
          } else {
            appendChild(previousPseudoElement);
          }
        }
        break;
      case PseudoKind.kPseudoAfter:
        if (previousPseudoElement.parentNode == null) {
          appendChild(previousPseudoElement);
        }
        break;
    }

    // Support quoted strings and minimal function handling for counter().
    String? textContent;
    if (pseudoValue is QuoteStringContentValue) {
      textContent = pseudoValue.value;
    } else if (pseudoValue is FunctionContentValue ||
        pseudoValue is KeywordContentValue) {
      // Evaluate a composite content string with counter() and quoted strings.
      textContent = _evaluateContent(contentValue);
    }

    if (textContent != null) {
      if (previousPseudoElement.firstChild != null) {
        (previousPseudoElement.firstChild as TextNode).data = textContent;
      } else {
        final textNode = ownerDocument.createTextNode(
            textContent,
            BindingContext(ownerDocument.controller.view, contextId!,
                allocateNewBindingObject()));
        previousPseudoElement.appendChild(textNode);
      }
    }

    // Flush style changes so renderStyle picks up the new properties.
    previousPseudoElement.style.flushPendingProperties();

    return previousPseudoElement;
  }

  bool _shouldBeforePseudoElementNeedsUpdate = false;

  void markBeforePseudoElementNeedsUpdate() {
    if (_shouldBeforePseudoElementNeedsUpdate) return;
    _shouldBeforePseudoElementNeedsUpdate = true;
    Future.microtask(_updateBeforePseudoElement);
  }

  void _updateBeforePseudoElement() {
    // Add pseudo elements
    String? beforeContent =
        style.pseudoBeforeStyle?.getPropertyValue('content');
    if (beforeContent != null && beforeContent.isNotEmpty) {
      _beforeElement = _createOrUpdatePseudoElement(
          beforeContent, PseudoKind.kPseudoBefore, _beforeElement);
    } else if (_beforeElement != null) {
      removeChild(_beforeElement!);
    }
    _shouldBeforePseudoElementNeedsUpdate = false;
  }

  bool _shouldAfterPseudoElementNeedsUpdate = false;

  void markAfterPseudoElementNeedsUpdate() {
    if (_shouldAfterPseudoElementNeedsUpdate) return;
    _shouldAfterPseudoElementNeedsUpdate = true;
    Future.microtask(_updateAfterPseudoElement);
  }

  void _updateAfterPseudoElement() {
    String? afterContent = style.pseudoAfterStyle?.getPropertyValue('content');
    if (afterContent != null && afterContent.isNotEmpty) {
      _afterElement = _createOrUpdatePseudoElement(
          afterContent, PseudoKind.kPseudoAfter, _afterElement);
    } else if (_afterElement != null) {
      removeChild(_afterElement!);
    }
    _shouldAfterPseudoElementNeedsUpdate = false;
  }

  // ::first-letter pseudo update trigger
  bool _shouldFirstLetterPseudoNeedsUpdate = false;
  void markFirstLetterPseudoNeedsUpdate() {
    if (_shouldFirstLetterPseudoNeedsUpdate) return;
    _shouldFirstLetterPseudoNeedsUpdate = true;
    Future.microtask(_updateFirstLetterPseudo);
  }

  void _updateFirstLetterPseudo() {
    // Rebuild layout/paragraph for this element so IFC can apply ::first-letter styling
    renderStyle.requestWidgetToRebuild(UpdateChildNodeUpdateReason());
    _shouldFirstLetterPseudoNeedsUpdate = false;
  }

  // ::first-line pseudo update trigger
  bool _shouldFirstLinePseudoNeedsUpdate = false;
  void markFirstLinePseudoNeedsUpdate() {
    if (_shouldFirstLinePseudoNeedsUpdate) return;
    _shouldFirstLinePseudoNeedsUpdate = true;
    Future.microtask(_updateFirstLinePseudo);
  }

  void _updateFirstLinePseudo() {
    renderStyle.requestWidgetToRebuild(UpdateChildNodeUpdateReason());
    _shouldFirstLinePseudoNeedsUpdate = false;
  }

  @override
  void dispose() async {
    renderStyle.detach();
    renderStyle.dispose();
    _states.clear();
    style.dispose();
    attributes.clear();
    _connectedCompleter = null;
    _attributeProperties.clear();
    ownerDocument.clearElementStyleDirty(this);
    holderAttachedPositionedElement = null;
    holderAttachedContainingBlockElement = null;
    clearOutOfFlowPositionedElements();
    _beforeElement?.dispose();
    _beforeElement = null;
    _afterElement?.dispose();
    _afterElement = null;
    renderStyle.removeIntersectionChangeListener(_handleIntersectionObserver);
    super.dispose();
  }

  @override
  void childrenChanged(ChildrenChange change) {
    super.childrenChanged(change);
    renderStyle.requestWidgetToRebuild(UpdateChildNodeUpdateReason());
    // Children mutations (e.g., text nodes inserted or updated) can alter the
    // accessible name/description. Ensure semantics pick up the change.
    final renderBoxModel = renderStyle.attachedRenderBoxModel;
    if (renderBoxModel != null) {
      renderBoxModel.markNeedsSemanticsUpdate();
    }
  }

  @override
  @mustCallSuper
  Node appendChild(Node child) {
    super.appendChild(child);
    return child;
  }

  @override
  @mustCallSuper
  Node removeChild(Node child) {
    super.removeChild(child);

    // Update renderStyle tree.
    if (child is Element) {
      child.renderStyle.detach();
    }

    return child;
  }

  @override
  @mustCallSuper
  Node insertBefore(Node child, Node referenceNode) {
    Node? node = super.insertBefore(child, referenceNode);
    return node;
  }

  @override
  @mustCallSuper
  Node? replaceChild(Node newNode, Node oldNode) {
    return super.replaceChild(newNode, oldNode);
  }

  void _updateIDMap(String? newID, {String? oldID}) {
    if (oldID != null && oldID.isNotEmpty) {
      final elements = ownerDocument.elementsByID[oldID];
      if (elements != null) {
        elements.remove(this);
        ownerDocument.elementsByID[oldID] = elements;
      }
    }
    if (newID?.isNotEmpty == true && isConnected) {
      final elements = ownerDocument.elementsByID[newID!] ?? [];
      if (!elements.contains(this)) {
        elements.add(this);
      }
      ownerDocument.elementsByID[newID] = elements;
    }
  }

  void _updateClassIndex(List<String> oldClasses, List<String> newClasses) {
    // Remove old classes no longer present
    if (oldClasses.isNotEmpty) {
      for (final cls in oldClasses) {
        if (!newClasses.contains(cls)) {
          final list = ownerDocument.elementsByClass[cls];
          if (list != null) {
            list.remove(this);
            ownerDocument.elementsByClass[cls] = list;
          }
        }
      }
    }
    // Add new classes
    if (isConnected && newClasses.isNotEmpty) {
      for (final cls in newClasses) {
        if (!oldClasses.contains(cls)) {
          final list = ownerDocument.elementsByClass[cls] ?? <Element>[];
          if (!list.contains(this)) list.add(this);
          ownerDocument.elementsByClass[cls] = list;
        }
      }
    }
  }

  void _updateAttrPresenceIndex(String attrName, {required bool present}) {
    // Indexing is keyed by uppercase attribute name to align with RuleSet.attributeRules
    final String key = attrName.toUpperCase();
    if (present && isConnected) {
      final list = ownerDocument.elementsByAttr[key] ?? <Element>[];
      if (!list.contains(this)) list.add(this);
      ownerDocument.elementsByAttr[key] = list;
    } else {
      final list = ownerDocument.elementsByAttr[key];
      if (list != null) {
        list.remove(this);
        ownerDocument.elementsByAttr[key] = list;
      }
    }
  }

  void _updateNameMap(String? newName, {String? oldName}) {
    if (oldName != null && oldName.isNotEmpty) {
      final elements = ownerDocument.elementsByName[oldName];
      if (elements != null) {
        elements.remove(this);
        ownerDocument.elementsByName[oldName] = elements;
      }
    }
    if (newName != null && newName.isNotEmpty && isConnected) {
      final elements = ownerDocument.elementsByName[newName] ?? [];
      if (!elements.contains(this)) {
        elements.add(this);
      }
      ownerDocument.elementsByName[newName] = elements;
    }
  }

  Completer<void>? _connectedCompleter;
  Future<void> whenConnected() async {
    if (isConnected) return;

    _connectedCompleter ??= Completer();
    return _connectedCompleter!.future;
  }

  @override
  void connectedCallback() {
    applyStyle(style);
    style.flushPendingProperties();
    if (_connectedCompleter != null) {
      _connectedCompleter!.complete();
    }

    super.connectedCallback();
    _updateNameMap(getAttribute(_nameAttr));
    _updateIDMap(_id);
    // Index classes for connected element
    _updateClassIndex(const <String>[], _classList);
    // Index all present attributes for connected element
    if (attributes.isNotEmpty) {
      for (final name in attributes.keys) {
        _updateAttrPresenceIndex(name, present: true);
      }
    }
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    _updateIDMap(null, oldID: _id);
    _updateNameMap(null, oldName: getAttribute(_nameAttr));
    // Remove from class index
    if (_classList.isNotEmpty) {
      _updateClassIndex(List.from(_classList), const <String>[]);
    }
    // Remove all attribute presence indices
    if (attributes.isNotEmpty) {
      for (final name in attributes.keys) {
        _updateAttrPresenceIndex(name, present: false);
      }
    }
    if (renderStyle.position == CSSPositionType.fixed ||
        renderStyle.position == CSSPositionType.absolute ||
        renderStyle.position == CSSPositionType.sticky) {
      holderAttachedContainingBlockElement
          ?.removeOutOfFlowPositionedElement(this);
      holderAttachedContainingBlockElement?.renderStyle
          .requestWidgetToRebuild(UpdateChildNodeUpdateReason());
    }
    _connectedCompleter = null;

    // Notify controller that this element was removed (for LCP tracking)
    ownerDocument.controller.notifyElementRemoved(this);
  }

  RenderViewportBox? getRootViewport() {
    return ownerDocument.controller.currentBuildContext?.context
        .findRenderObject() as RenderViewportBox?;
  }

  RenderBoxModel? getRootRenderBoxModel() {
    return getRootViewport()?.firstChild as RenderBoxModel?;
  }

  Element? getContainingBlockElement({CSSPositionType? positionType}) {
    Element? containingBlockElement;
    positionType ??= renderStyle.position;

    switch (positionType) {
      case CSSPositionType.relative:
      case CSSPositionType.static:
      case CSSPositionType.sticky:
        containingBlockElement = parentElement;
        break;
      case CSSPositionType.absolute:
        Element viewportElement = ownerDocument.documentElement!;

        // If the element has 'position: absolute', the containing block is established by the nearest ancestor with
        // a 'position' of 'absolute', 'relative' or 'fixed', in the following way:
        //  1. In the case that the ancestor is an inline element, the containing block is the bounding box around
        //    the padding boxes of the first and the last inline boxes generated for that element.
        //    In CSS 2.1, if the inline element is split across multiple lines, the containing block is undefined.
        //  2. Otherwise, the containing block is formed by the padding edge of the ancestor.
        containingBlockElement = _findContainingBlock(this, viewportElement);
        break;
      case CSSPositionType.fixed:
        Element viewportElement = ownerDocument.documentElement!;

        // For fixed positioning, the containing block is the viewport unless an
        // ancestor establishes a fixed-position containing block (e.g. transform).
        // https://drafts.csswg.org/css-position/#fixedpos-containing-block
        containingBlockElement =
            _findFixedContainingBlock(this, viewportElement) ?? viewportElement;

        break;
    }
    return containingBlockElement;
  }

  @mustCallSuper
  String? getAttribute(String qualifiedName) {
    ElementAttributeProperty? propertyHandler =
        _attributeProperties[qualifiedName];

    if (propertyHandler != null && propertyHandler.getter != null) {
      return propertyHandler.getter!();
    }

    return attributes[qualifiedName];
  }

  @mustCallSuper
  void setAttribute(String qualifiedName, String value) {
    ElementAttributeProperty? propertyHandler =
        _attributeProperties[qualifiedName];
    final bool invokedByPropertyHandler =
        propertyHandler != null && propertyHandler.setter != null;
    if (invokedByPropertyHandler) {
      // Let the property handler perform the actual mutation (e.g., className setter)
      propertyHandler.setter!(value);
    }
    // Persist attribute map + emit DevTools events exactly once and avoid
    // redundant style work when the property handler already did it.
    internalSetAttribute(qualifiedName, value,
        invokedByAttributeSetter: invokedByPropertyHandler);
  }

  void internalSetAttribute(String qualifiedName, String value,
      {bool invokedByAttributeSetter = false}) {
    // Track previous value to avoid redundant DevTools events
    final String? oldValue = attributes[qualifiedName];
    final bool changed = oldValue != value;

    attributes[qualifiedName] = value;
    if (qualifiedName == 'class') {
      // When called from setAttribute() and a property handler already ran
      // (i.e., className setter), skip re-entering className to avoid double
      // recalculation and duplicate index updates.
      if (!invokedByAttributeSetter) {
        // className setter performs necessary style recalculation
        className = value;
      }
    } else {
      final isNeedRecalculate = _checkRecalculateStyle([qualifiedName]);
      if (DebugFlags.enableCssBatchRecalc) {
        ownerDocument.markElementStyleDirty(this,
            reason: 'batch:attr:$qualifiedName');
      } else {
        recalculateStyle(rebuildNested: isNeedRecalculate);
      }
    }

    // Maintain attribute presence index for presence selectors like [attr].
    // Include class/id/name as well so stylesheet invalidation can target them.
    _updateAttrPresenceIndex(qualifiedName, present: true);

    // Emit CDP DOM.attributeModified for DevTools if something actually changed
    if (changed) {
      try {
        final cb = ownerDocument.controller.view.devtoolsAttributeModified;
        if (cb != null) {
          cb(this, qualifiedName, value);
        } else {
          // Fallback to full tree refresh when incremental hooks are not set
          ownerDocument.controller.view.debugDOMTreeChanged?.call();
        }
      } catch (_) {}
    }

    // Mark semantics dirty for accessibility-relevant attributes.
    if (changed) _markSemanticsDirtyIfNeeded(qualifiedName);
  }

  @mustCallSuper
  void removeAttribute(String qualifiedName) {
    ElementAttributeProperty? propertyHandler =
        _attributeProperties[qualifiedName];

    if (propertyHandler != null && propertyHandler.deleter != null) {
      propertyHandler.deleter!();
    }

    if (hasAttribute(qualifiedName)) {
      attributes.remove(qualifiedName);
      final isNeedRecalculate = _checkRecalculateStyle([qualifiedName]);
      if (DebugFlags.enableCssBatchRecalc) {
        ownerDocument.markElementStyleDirty(this,
            reason: 'batch:remove:$qualifiedName');
      } else {
        recalculateStyle(rebuildNested: isNeedRecalculate);
      }

      // Maintain attribute presence index
      _updateAttrPresenceIndex(qualifiedName, present: false);

      // Emit CDP DOM.attributeRemoved for DevTools
      try {
        final cb = ownerDocument.controller.view.devtoolsAttributeRemoved;
        if (cb != null) {
          cb(this, qualifiedName);
        } else {
          // Fallback to full tree refresh when incremental hooks are not set
          ownerDocument.controller.view.debugDOMTreeChanged?.call();
        }
      } catch (_) {}

      // Mark semantics dirty for accessibility-relevant attributes.
      _markSemanticsDirtyIfNeeded(qualifiedName);
    }
  }

  void _markSemanticsDirtyIfNeeded(String qualifiedName) {
    // Common accessibility attributes that affect semantics
    const Set<String> a11yAttrs = {
      'role',
      'aria-label',
      'aria-labelledby',
      'aria-describedby',
      'aria-hidden',
      'aria-disabled',
      'aria-checked',
      'aria-pressed',
      'aria-selected',
      'aria-current',
      'title',
      'alt',
      // Form+interactive hints
      'type',
      'href',
      'value',
      'tabindex',
      'disabled',
    };
    if (!a11yAttrs.contains(qualifiedName)) return;
    final render = renderStyle.attachedRenderBoxModel;
    if (render != null) {
      render.markNeedsSemanticsUpdate();
    }
  }

  @mustCallSuper
  bool hasAttribute(String qualifiedName) {
    return attributes.containsKey(qualifiedName);
  }

  @Deprecated('Use setRenderStyleProperty or setRenderStyle instead')
  void setStyle(String property, value) {
    setRenderStyle(property, value);
  }

  void _updateHostingWidgetWithDisplay(CSSDisplay oldDisplay) {
    CSSDisplay presentDisplay = renderStyle.display;

    if (parentElement == null || !parentElement!.isConnected) return;
    // Destroy renderer of element when display is changed to none.
    if (presentDisplay == CSSDisplay.none) {
      renderStyle.requestWidgetToRebuild(UpdateDisplayReason());
      return;
    }
    if (oldDisplay == CSSDisplay.none && presentDisplay != oldDisplay) {
      Element? targetElement =
          holderAttachedContainingBlockElement ?? parentElement;
      targetElement?.renderStyle.requestWidgetToRebuild(UpdateDisplayReason());
      return;
    }

    renderStyle.requestWidgetToRebuild(UpdateDisplayReason());
    // Changing display may require swapping the underlying RenderBoxModel type.
    // Only force a Flutter element remount when this element already has a
    // mounted render object; otherwise, the upcoming first build will create
    // the correct renderer without extra key churn.
    if (renderStyle.hasRenderBox()) {
      updateElementKey();
    }

    // When display changes (e.g., block <-> inline), ancestor containers may need
    // to rebuild to re-evaluate anonymous block wrapping and inline formatting.
    // For example, when an inline element previously had a block child which turned
    // to inline, its block parent must rebuild to drop anonymous blocks.
    // Propagate a lightweight child-update rebuild up to two ancestor levels.
    Element? ancestor = parentElement;
    int hops = 0;
    while (ancestor != null && hops < 2) {
      ancestor.renderStyle
          .requestWidgetToRebuild(UpdateChildNodeUpdateReason());
      ancestor = ancestor.parentElement;
      hops++;
    }
  }

  void setRenderStyleProperty(String name, value) {
    if (renderStyle.target.disposed) return;

    dynamic oldValue;

    switch (name) {
      case DISPLAY:
      case OVERFLOW_X:
      case OVERFLOW_Y:
      case POSITION:
        oldValue = renderStyle.getProperty(name);
        break;
    }

    if (DebugFlags.shouldLogTransitionForProp(name)) {
      cssLogger.info(
          '[style][apply-prop] $tagName.$name value=${value is CSSColor ? (value).cssText() : value}');
    }
    if (DebugFlags.enableBackgroundLogs &&
        (name == BACKGROUND_POSITION_X || name == BACKGROUND_POSITION_Y)) {
      try {
        final CSSBackgroundPosition p = value as CSSBackgroundPosition;
        renderingLogger.finer('[Background] apply $name cssText=${p.cssText()} '
            '(len=${p.length != null} pct=${p.percentage != null} calc=${p.calcValue != null})');
      } catch (_) {}
    }
    renderStyle.setProperty(name, value);

    switch (name) {
      case DISPLAY:
        assert(oldValue != null);
        if (value != oldValue) {
          _updateHostingWidgetWithDisplay(oldValue);
        }
        break;
      case OVERFLOW_X:
        if (this is WidgetElement) return;
        _updateHostingWidgetWithOverflow(oldValue);
        break;
      case OVERFLOW_Y:
        if (this is WidgetElement) return;
        _updateHostingWidgetWithOverflow(oldValue);
        break;
      case POSITION:
        assert(oldValue != null);
        whenConnected().then((_) {
          _updateHostingWidgetWithPosition(oldValue);
        });
        break;
      case COLOR:
        _updateColorRelativePropertyWithColor(this);
        break;
      case FONT_SIZE:
        _updateFontRelativeLengthWithFontSize();
        break;
      case TRANSFORM:
        _updateHostingWidgetWithTransform();
        break;
    }
  }

  void setRenderStyle(String property, String present, {String? baseHref}) {
    if (DebugFlags.shouldLogTransitionForProp(property)) {
      cssLogger.info(
          '[style][apply] $tagName.$property present="$present" baseHref=${baseHref ?? 'null'}');
    }
    dynamic value = present.isEmpty
        ? null
        : renderStyle.resolveValue(property, present, baseHref: baseHref);

    setRenderStyleProperty(property, value);
  }

  void _updateColorRelativePropertyWithColor(Element element) {
    element.renderStyle.updateColorRelativeProperty();
    if (element.children.isNotEmpty) {
      for (final Element child in element.children) {
        if (!child.renderStyle.hasColor) {
          _updateColorRelativePropertyWithColor(child);
        }
      }
    }
  }

  void _updateFontRelativeLengthWithFontSize() {
    // Update all the children's length value.
    _updateChildrenFontRelativeLength(this);

    if (renderStyle.isDocumentRootBox()) {
      // Update all the document tree.
      _updateChildrenRootFontRelativeLength(this);
    }
  }

  void _updateChildrenFontRelativeLength(Element element) {
    element.renderStyle.updateFontRelativeLength();
    if (element.children.isNotEmpty) {
      for (final Element child in element.children) {
        if (!child.renderStyle.hasFontSize) {
          _updateChildrenFontRelativeLength(child);
        }
      }
    }
  }

  void _updateChildrenRootFontRelativeLength(Element element) {
    element.renderStyle.updateRootFontRelativeLength();
    if (element.children.isNotEmpty) {
      for (final Element child in element.children) {
        _updateChildrenRootFontRelativeLength(child);
      }
    }
  }

  void applyDefaultStyle(CSSStyleDeclaration style) {
    if (defaultStyle.isNotEmpty) {
      defaultStyle.forEach((propertyName, value) {
        if (style.contains(propertyName) == false) {
          style.setProperty(propertyName, value);
        }
      });
    }
  }

  void applyInlineStyle(CSSStyleDeclaration style) {
    if (inlineStyle.isNotEmpty) {
      inlineStyle.forEach((propertyName, value) {
        // Force inline style to be applied as important priority.
        style.setProperty(propertyName, value, isImportant: true);
      });
    }
  }

  void _applySheetStyle(CSSStyleDeclaration style) {
    CSSStyleDeclaration matchRule = _collectMatchedRulesWithCache();
    style.union(matchRule);
  }

  // Lightweight memoization for matched rules (per-element LRU cache).
  // Guarded by DebugFlags.enableCssMemoization.
  // Capacity kept intentionally tiny to bound memory (default via DebugFlags).
  LinkedHashMap<_MatchFingerprint, _MatchedRulesCacheEntry>? _matchedRulesLRU;

  CSSStyleDeclaration _collectMatchedRulesWithCache() {
    final RuleSet ruleSet = ownerDocument.ruleSet;
    if (!DebugFlags.enableCssMemoization) {
      _matchedRulesLRU = null;
      return _elementRuleCollector.collectionFromRuleSet(ruleSet, this);
    }

    final int version = ownerDocument.ruleSetVersion;
    final _MatchFingerprint fingerprint = _computeMatchFingerprint(ruleSet);
    final LinkedHashMap<_MatchFingerprint, _MatchedRulesCacheEntry> cache =
        _matchedRulesLRU ??=
            LinkedHashMap<_MatchFingerprint, _MatchedRulesCacheEntry>();

    // Prune stale entries from previous RuleSet versions (capacity is tiny).
    if (cache.isNotEmpty) {
      final List<_MatchFingerprint> toRemove = <_MatchFingerprint>[];
      cache.forEach((fp, entry) {
        if (entry.version != version) toRemove.add(fp);
      });
      for (final fp in toRemove) {
        cache.remove(fp);
      }
    }

    final _MatchedRulesCacheEntry? hitEntry = cache[fingerprint];
    if (hitEntry != null && hitEntry.version == version) {
      // LRU refresh: move to most-recent by reinserting.
      cache.remove(fingerprint);
      cache[fingerprint] = hitEntry;
      return hitEntry.style;
    }

    // Cache miss: compute and insert, enforce capacity with LRU eviction.
    final CSSStyleDeclaration computed =
        _elementRuleCollector.collectionFromRuleSet(ruleSet, this);
    final int capRaw = DebugFlags.cssMatchedRulesCacheCapacity;
    final int capacity = capRaw <= 0 ? 1 : capRaw;
    if (cache.length >= capacity) {
      final _MatchFingerprint oldest = cache.keys.first;
      cache.remove(oldest);
    }
    cache[fingerprint] = _MatchedRulesCacheEntry(
      version: version,
      fingerprint: fingerprint,
      style: computed,
    );
    return computed;
  }

  _MatchFingerprint _computeMatchFingerprint(RuleSet ruleSet) {
    final List<String> sortedClasses = _classList.isEmpty
        ? const <String>[]
        : List.unmodifiable((List<String>.from(_classList)..sort()));

    final Map<String, String> attrs = attributes;
    final Map<String, List<CSSRule>> attributeRules = ruleSet.attributeRules;
    List<_AttributeFingerprint> attributeKeys = const <_AttributeFingerprint>[];

    if (attrs.isNotEmpty && attributeRules.isNotEmpty) {
      final List<_AttributeFingerprint> collected = [];
      attrs.forEach((name, value) {
        if (name == _idAttr || name == _classNameAttr) return;
        final String upperName = name.toUpperCase();
        if (attributeRules.containsKey(upperName)) {
          collected.add(_AttributeFingerprint(name: upperName, value: value));
        }
      });
      if (collected.isNotEmpty) {
        collected.sort();
        attributeKeys = List.unmodifiable(collected);
      }
    }

    return _MatchFingerprint(
      tagName: tagName,
      id: id ?? '',
      classes: sortedClasses,
      attributes: attributeKeys,
    );
  }

  // Whether a post-frame callback has been queued to run transition batch.
  bool _queuedTransitionBatch = false;
  // Track per-property pending schedules to avoid duplicate schedules within the same frame.
  final Set<String> _pendingTransitionProps = <String>{};
  // Collect transition requests arriving in the same frame so we can start
  // all of them together on the next frame.
  final List<({String property, String? prev, String curr})>
      _pendingTransitionQueue =
      <({String property, String? prev, String curr})>[];

  void scheduleRunTransitionAnimations(
      String propertyName, String? prevValue, String currentValue) {
    if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
      cssLogger.info(
          '[transition][queue] $tagName.$propertyName prev=${prevValue ?? 'null'} -> curr=$currentValue');
    }
    if (_pendingTransitionProps.contains(propertyName)) {
      // Already scheduled this property in current frame; coalesce by updating
      // the pending item's current (end) value so we run once with the latest
      // destination. For color properties, prefer the most recent, fully
      // resolved previous value (from computed style) instead of the earlier
      // raw serialized text (which may still contain var(...)).
      for (int i = _pendingTransitionQueue.length - 1; i >= 0; i--) {
        final item = _pendingTransitionQueue[i];
        if (item.property == propertyName) {
          String? mergedPrev = item.prev;
          // Color-bearing properties where we want the last, concrete
          // previous value (e.g., 'rgb(...)' or 'rgba(...)') to win
          // over earlier var(...) strings like 'rgb(... / null)'.
          final bool isColorProp = propertyName == COLOR ||
              propertyName == BACKGROUND_COLOR ||
              propertyName == TEXT_DECORATION_COLOR ||
              propertyName == BORDER_LEFT_COLOR ||
              propertyName == BORDER_TOP_COLOR ||
              propertyName == BORDER_RIGHT_COLOR ||
              propertyName == BORDER_BOTTOM_COLOR;
          if (isColorProp && prevValue != null && prevValue.isNotEmpty) {
            mergedPrev = prevValue;
          }
          _pendingTransitionQueue[i] =
              (property: propertyName, prev: mergedPrev, curr: currentValue);
          if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
            cssLogger.info(
                '[transition][queue] coalesce property=$propertyName prevOld=${item.prev ?? 'null'} prevNew=${prevValue ?? 'null'} mergedPrev=${mergedPrev ?? 'null'} new-curr=$currentValue');
          }

          break;
        }
      }
      return;
    }
    _pendingTransitionProps.add(propertyName);
    _pendingTransitionQueue
        .add((property: propertyName, prev: prevValue, curr: currentValue));

    if (_queuedTransitionBatch) return;
    _queuedTransitionBatch = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Drain queue in insertion order so related properties (e.g., width, left, transform)
      // start in the same frame, improving sync.
      final items = List<({String property, String? prev, String curr})>.from(
          _pendingTransitionQueue);
      _pendingTransitionQueue.clear();
      _queuedTransitionBatch = false;
      for (final item in items) {
        if (DebugFlags.shouldLogTransitionForProp(item.property)) {
          cssLogger.info(
              '[transition][drain] run property=${item.property} prev=${item.prev ?? 'null'} curr=${item.curr}');
        }
        renderStyle.runTransition(item.property, item.prev, item.curr);
        _pendingTransitionProps.remove(item.property);
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void _onStyleChanged(
      String propertyName, String? prevValue, String currentValue,
      {String? baseHref}) {
    // Identify color-bearing properties up front so we can normalize
    // both the previous and current values to concrete colors for
    // transition decisions, independent of any var(...) indirection.
    final bool isColorProp = propertyName == COLOR ||
        propertyName == BACKGROUND_COLOR ||
        propertyName == TEXT_DECORATION_COLOR ||
        propertyName == BORDER_LEFT_COLOR ||
        propertyName == BORDER_TOP_COLOR ||
        propertyName == BORDER_RIGHT_COLOR ||
        propertyName == BORDER_BOTTOM_COLOR;

    if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
      cssLogger.info(
          '[style][change] $tagName.$propertyName prev=${prevValue ?? 'null'} curr=$currentValue');
    }

    // For color properties, prefer the previous *computed* color from
    // renderStyle as the transition's begin value rather than the
    // raw serialized CSS text (which may still contain var(...)).
    String? prevForTransition = prevValue;
    if (isColorProp) {
      final dynamic prevComputed = renderStyle.getProperty(propertyName);
      if (prevComputed is CSSColor) {
        prevForTransition = prevComputed.cssText();
        if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
          cssLogger.info(
              '[style][prev-computed] $tagName.$propertyName prevSerialized=${prevValue ?? 'null'} prevComputed=$prevForTransition');
        }
      }
    }

    // Eagerly expand var() for color-bearing properties so that downstream
    // parsing and color caches see concrete values after variable changes
    // (e.g., hsl(var(--x)) -> hsl(12 100% 50%)). This complements the
    // variable-notify path and also covers normal stylesheet flushes.
    if (currentValue.contains('var(') && isColorProp) {
      try {
        currentValue = CSSWritingModeMixin.expandInlineVars(
            currentValue, renderStyle, propertyName);
      } catch (_) {}
    }

    final bool shouldTrans = renderStyle.shouldTransition(
        propertyName, prevForTransition, currentValue);
    if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
      cssLogger.info(
          '[style][route] $tagName.$propertyName shouldTransition=$shouldTrans');
    }
    if (shouldTrans) {
      scheduleRunTransitionAnimations(
          propertyName, prevForTransition, currentValue);
      return;
    }
    // If a transition for this property is pending in this frame or currently
    // running, avoid applying the immediate setRenderStyle which would clobber
    // the animation-driven value. The scheduled/active transition will drive
    // updates.
    final bool pending = _pendingTransitionProps.contains(propertyName);
    final bool running = renderStyle.isTransitionRunning(propertyName);
    if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
      cssLogger.info(
          '[style][route] $tagName.$propertyName pending=$pending running=$running');
    }
    if (pending || running) {
      return;
    }
    if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
      cssLogger.info(
          '[style][apply] $tagName.$propertyName direct-set value=$currentValue');
    }
    setRenderStyle(propertyName, currentValue, baseHref: baseHref);
  }

  void _onStyleFlushed(List<String> properties) {
    if (renderStyle.shouldAnimation(properties)) {
      runAnimation() {
        renderStyle.beforeRunningAnimation();
        if (renderStyle.isBoxModelHaveSize()) {
          renderStyle.runAnimation();
        } else {
          SchedulerBinding.instance.addPostFrameCallback((callback) {
            renderStyle.runAnimation();
          });
          SchedulerBinding.instance.scheduleFrame();
        }
      }

      if (ownerDocument.ownerView.isAnimationTimelineStopped) {
        ownerDocument.ownerView.addPendingAnimationTimeline(runAnimation);
      } else {
        runAnimation();
      }
    }
  }

  // Set inline style property.
  void setInlineStyle(String property, String value,
      {String? baseHref, bool fromNative = false}) {
    final bool enableBlink = ownerDocument.ownerView.enableBlink;
    final bool validate = !(fromNative && enableBlink);
    // Current only for mark property is setting by inline style.
    inlineStyle[property] = value;

    // recalculate matching styles for element when inline styles are removed.
    if (value.isEmpty) {
      style.removeProperty(property, true);
      // When Blink CSS is enabled, style cascading and validation happen on
      // the native side. Avoid expensive Dart-side recalculation here.
      if (!(fromNative && enableBlink)) {
        recalculateStyle();
      }
    } else {
      style.setProperty(property, value,
          isImportant: true, baseHref: baseHref, validate: validate);
    }
  }

  void clearInlineStyle() {
    for (var key in inlineStyle.keys) {
      style.removeProperty(key, true);
    }
    inlineStyle.clear();
  }

  // Set pseudo element (::before, ::after, ::first-letter, ::first-line) style.
  void setPseudoStyle(String type, String property, String value,
      {String? baseHref, bool fromNative = false}) {
    final bool enableBlink = ownerDocument.ownerView.enableBlink;
    final bool validate = !(fromNative && enableBlink);
    style.setPseudoProperty(type, property, value,
        baseHref: baseHref, validate: validate);
  }

  // Remove pseudo element (::before, ::after, ::first-letter, ::first-line) style.
  void removePseudoStyle(String type, String property) {
    style.removePseudoProperty(type, property);
  }

  // Clear all inline pseudo styles for a specific pseudo element.
  void clearPseudoStyle(String type) {
    style.clearPseudoStyle(type);
  }

  void _applyPseudoStyle(CSSStyleDeclaration style) {
    List<CSSStyleRule> pseudoRules =
        _elementRuleCollector.matchedPseudoRules(ownerDocument.ruleSet, this);
    style.handlePseudoRules(this, pseudoRules);
  }

  void applyStyle(CSSStyleDeclaration style) {
    // Apply default style.
    applyDefaultStyle(style);
    // Init display from style directly cause renderStyle is not flushed yet.
    renderStyle.initDisplay(style);

    applyAttributeStyle(style);
    applyInlineStyle(style);
    _applySheetStyle(style);
    _applyPseudoStyle(style);
  }

  void applyAttributeStyle(CSSStyleDeclaration style) {
    // Map the dir attribute to CSS direction so inline layout picks up RTL/LTR hints.
    final String? dirAttr = attributes['dir'];
    if (dirAttr != null) {
      final String normalized = dirAttr.trim().toLowerCase();
      final TextDirection? resolved = CSSTextMixin.resolveDirection(normalized);
      if (resolved != null) {
        style.setProperty(DIRECTION, normalized);
      }
    }
  }

  void recalculateStyle(
      {bool rebuildNested = false, bool forceRecalculate = false}) {
    // Pseudo elements (::before/::after) are styled via their parent's
    // matched pseudo rules. A full recalc using the standard element
    // pipeline would discard those properties (only defaults/inline apply).
    // Skip full recalc here to preserve pseudo-specific styles, which are
    // refreshed via markBefore/AfterPseudoElementNeedsUpdate on the parent.
    if (this is PseudoElement) {
      // Still flush any pending inline or merged properties if present.
      style.flushPendingProperties();
      return;
    }
    // Always update CSS variables even for display:none elements when rebuilding nested
    bool shouldUpdateCSSVariables =
        rebuildNested && renderStyle.display == CSSDisplay.none;

    if (forceRecalculate ||
        renderStyle.display != CSSDisplay.none ||
        shouldUpdateCSSVariables) {
      // Diff style.
      CSSStyleDeclaration newStyle = CSSStyleDeclaration();
      applyStyle(newStyle);
      var hasInheritedPendingProperty = false;
      if (style.merge(newStyle)) {
        hasInheritedPendingProperty = style.hasInheritedPendingProperty;
        style.flushPendingProperties();
      }

      if (rebuildNested || hasInheritedPendingProperty) {
        // Update children style.
        for (final Element child in children) {
          child.recalculateStyle(
              rebuildNested: rebuildNested, forceRecalculate: forceRecalculate);
        }
      }
    }
  }

  void _removeInlineStyle() {
    inlineStyle.forEach((String property, _) {
      _removeInlineStyleProperty(property);
    });
    inlineStyle.clear();
    style.flushPendingProperties();
  }

  void _removeInlineStyleProperty(String property) {
    style.removeProperty(property, true);
  }

  // The Element.getBoundingClientRect() method returns a DOMRect object providing information
  // about the size of an element and its position relative to the viewport.
  // https://drafts.csswg.org/cssom-view/#dom-element-getboundingclientrect
  BoundingClientRect get boundingClientRect {
    BoundingClientRect boundingClientRect = BoundingClientRect.zero(
        BindingContext(
            ownerView, ownerView.contextId, allocateNewBindingObject()));
    if (isRendererAttached) {
      // RenderBoxModel sizedBox = renderBoxModel!;
      if (!renderStyle.isBoxModelHaveSize()) {
        return boundingClientRect;
      }

      // Special handling for inline elements that participate in inline formatting context
      if (renderStyle.display == CSSDisplay.inline &&
          !renderStyle.isSelfRenderReplaced()) {
        // Check if this element participates in an inline formatting context
        RenderObject? parent = renderStyle.attachedRenderBoxModel?.parent;
        while (parent != null) {
          if (parent is RenderFlowLayout &&
              parent.establishIFC &&
              parent.inlineFormattingContext != null) {
            // Get bounds from the inline formatting context
            final ifcBounds = parent.inlineFormattingContext!
                .getBoundsForRenderBox(renderStyle.attachedRenderBoxModel!);
            if (ifcBounds != null) {
              // Convert IFC-relative bounds to viewport-relative bounds
              RenderBoxModel? rootRenderBox = getRootRenderBoxModel();
              Offset containerOffset = Offset.zero;
              if (rootRenderBox != null) {
                containerOffset =
                    parent.localToGlobal(Offset.zero, ancestor: rootRenderBox);
              }

              // Add container's content offset (padding and border)
              final contentOffset = Offset(
                parent.renderStyle.paddingLeft.computedValue +
                    parent.renderStyle.effectiveBorderLeftWidth.computedValue,
                parent.renderStyle.paddingTop.computedValue +
                    parent.renderStyle.effectiveBorderTopWidth.computedValue,
              );

              final absoluteOffset =
                  containerOffset + contentOffset + ifcBounds.topLeft;

              boundingClientRect = BoundingClientRect(
                  context: BindingContext(ownerView, ownerView.contextId,
                      allocateNewBindingObject()),
                  x: absoluteOffset.dx,
                  y: absoluteOffset.dy,
                  width: ifcBounds.width,
                  height: ifcBounds.height,
                  top: absoluteOffset.dy,
                  right: absoluteOffset.dx + ifcBounds.width,
                  bottom: absoluteOffset.dy + ifcBounds.height,
                  left: absoluteOffset.dx);
              return boundingClientRect;
            }
            break;
          }
          parent = (parent).parent;
        }
      }

      // Default handling for block elements and replaced elements
      if (renderStyle.isBoxModelHaveSize()) {
        RenderBoxModel? currentRenderBox = renderStyle.attachedRenderBoxModel;
        Offset offset = Offset.zero;

        if (currentRenderBox != null) {
          // Get the WebF viewport
          RenderBox? viewport = getRootViewport();

          // First, try to get offset using the normal ancestor-based approach
          // This will work for elements in the main document tree
          RenderBoxModel? rootRenderBox = getRootRenderBoxModel();
          if (rootRenderBox != null) {
            offset = currentRenderBox.localToGlobal(Offset.zero,
                ancestor: rootRenderBox);
          } else if (viewport != null) {
            // No root render box (shouldn't happen normally)
            // Use global coordinate calculation
            Offset elementGlobal = currentRenderBox.localToGlobal(Offset.zero);
            Offset viewportGlobal = viewport.localToGlobal(Offset.zero);
            offset = elementGlobal - viewportGlobal;
          }
        }

        Size size = renderStyle.boxSize()!;
        boundingClientRect = BoundingClientRect(
            context: BindingContext(
                ownerView, ownerView.contextId, allocateNewBindingObject()),
            x: offset.dx,
            y: offset.dy,
            width: size.width,
            height: size.height,
            top: offset.dy,
            right: offset.dx + size.width,
            bottom: offset.dy + size.height,
            left: offset.dx);
      }
    }

    return boundingClientRect;
  }

  // The HTMLElement.offsetLeft read-only property returns the number of pixels that the upper left corner
  // of the current element is offset to the left within the HTMLElement.offsetParent node.
  // https://drafts.csswg.org/cssom-view/#dom-htmlelement-offsetleft
  double get offsetLeft {
    double offset = 0.0;
    if (!isRendererAttached) {
      return offset;
    }
    Element? offsetParent = this.offsetParent;
    RenderBoxModel? ancestor = offsetParent?.attachedRenderer;
    if (offsetParent?.hasScroll == true) {
      ancestor = offsetParent?.attachedRendererWrapper;
    }

    // For sticky positioned elements with body as offsetParent,
    // we need to account for scroll position
    if (renderStyle.position == CSSPositionType.sticky &&
        offsetParent is BodyElement) {
      // For sticky elements, we need to calculate their position including scroll
      // Get total scroll offset by checking all scroll containers
      double totalScrollX = 0.0;

      // Check if documentElement has scroll
      Element? docElement = ownerDocument.documentElement;
      if (docElement != null && docElement.attachedRenderer != null) {
        totalScrollX = docElement.scrollLeft;
      }

      // If no scroll on documentElement, check body
      if (totalScrollX == 0.0) {
        Element? body = ownerDocument.documentElement?.querySelector(['body']);
        if (body != null && body.attachedRenderer != null) {
          totalScrollX = body.scrollLeft;
        }
      }

      // Get the sticky element's current position relative to the viewport
      RenderBoxModel? renderer = attachedRenderer;
      if (renderer != null && renderer.hasSize) {
        // For sticky elements, we need to calculate their actual visual position
        // Get the position placeholder to find original position
        RenderPositionPlaceholder? placeholder =
            renderStyle.getSelfPositionPlaceHolder();
        if (placeholder != null && placeholder.attached) {
          // Get the placeholder's position (original position before sticky)
          Offset placeholderOffset = placeholder.getOffsetToAncestor(
              Offset.zero, offsetParent.attachedRenderer!,
              excludeScrollOffset: true);

          // Calculate where the element should be without sticky
          double naturalPosition = placeholderOffset.dx - totalScrollX;

          // Get sticky constraints
          double stickyLeft = renderStyle.left.computedValue;

          // Check if element should be stuck
          if (naturalPosition < stickyLeft) {
            // Element should be stuck at sticky position
            return totalScrollX + stickyLeft;
          } else {
            // Element is in its natural position
            return placeholderOffset.dx;
          }
        }

        // Fallback: calculate based on current visual position
        RenderBox? viewport = getRootViewport();
        if (viewport != null) {
          // Get position relative to viewport
          Offset viewportOffset =
              renderer.localToGlobal(Offset.zero, ancestor: viewport);

          // For sticky elements, we need to handle the case where they're stuck
          // If the element is at its sticky position (e.g., left: 50px), it's stuck
          if (viewportOffset.dx == renderStyle.left.computedValue) {
            // Element is stuck at its sticky position
            return totalScrollX + viewportOffset.dx;
          } else {
            // Element is not stuck, calculate its natural position
            return viewportOffset.dx + totalScrollX;
          }
        }
      }
    }

    Offset relative = renderStyle.getOffset(
        ancestorRenderBox: ancestor, excludeScrollOffset: true);
    offset += relative.dx;
    return offset;
  }

  dynamic testGlobalToLocal(double x, double y) {
    if (!isRendererAttached) {
      return {'x': 0, 'y': 0};
    }

    Offset offset = Offset(x, y);
    Offset result = renderStyle.attachedRenderBoxModel!.globalToLocal(offset);
    return {'x': result.dx, 'y': result.dy};
  }

  // The HTMLElement.offsetTop read-only property returns the distance of the outer border
  // of the current element relative to the inner border of the top of the offsetParent node.
  // https://drafts.csswg.org/cssom-view/#dom-htmlelement-offsettop
  double get offsetTop {
    double offset = 0.0;
    if (!isRendererAttached) {
      return offset;
    }
    Element? offsetParent = this.offsetParent;
    RenderBoxModel? ancestor = offsetParent?.attachedRenderer;
    if (offsetParent?.hasScroll == true) {
      ancestor = offsetParent?.attachedRendererWrapper;
    }

    // For sticky positioned elements with body as offsetParent,
    // we need to account for scroll position
    if (renderStyle.position == CSSPositionType.sticky &&
        offsetParent is BodyElement) {
      // For sticky elements, we need to calculate their position including scroll
      // Get total scroll offset by checking all scroll containers
      double totalScrollY = 0.0;

      // Check if documentElement has scroll
      Element? docElement = ownerDocument.documentElement;
      if (docElement != null && docElement.attachedRenderer != null) {
        totalScrollY = docElement.scrollTop;
      }

      // If no scroll on documentElement, check body
      if (totalScrollY == 0.0) {
        Element? body = ownerDocument.documentElement?.querySelector(['body']);
        if (body != null && body.attachedRenderer != null) {
          totalScrollY = body.scrollTop;
        }
      }

      // Get the sticky element's current position relative to the viewport
      RenderBoxModel? renderer = attachedRenderer;
      if (renderer != null && renderer.hasSize) {
        // For sticky elements, we need to calculate their actual visual position
        // Get the position placeholder to find original position
        RenderPositionPlaceholder? placeholder =
            renderStyle.getSelfPositionPlaceHolder();
        if (placeholder != null && placeholder.attached) {
          // Get the placeholder's position (original position before sticky)
          Offset placeholderOffset = placeholder.getOffsetToAncestor(
              Offset.zero, offsetParent.attachedRenderer!,
              excludeScrollOffset: true);

          // Calculate where the element should be without sticky
          double naturalPosition = placeholderOffset.dy - totalScrollY;

          // Get sticky constraints
          double stickyTop = renderStyle.top.computedValue;

          // Check if element should be stuck
          if (naturalPosition < stickyTop) {
            // Element should be stuck at sticky position
            return totalScrollY + stickyTop;
          } else {
            // Element is in its natural position
            return placeholderOffset.dy;
          }
        }

        // Fallback: calculate based on current visual position
        RenderBox? viewport = getRootViewport();
        if (viewport != null) {
          // Get position relative to viewport
          Offset viewportOffset =
              renderer.localToGlobal(Offset.zero, ancestor: viewport);

          // For sticky elements, we need to handle the case where they're stuck
          // If the element is at its sticky position (50px from top), it's stuck
          if (viewportOffset.dy == renderStyle.top.computedValue) {
            // Element is stuck at its sticky position
            return totalScrollY + viewportOffset.dy;
          } else {
            // Element is not stuck, calculate its natural position
            return viewportOffset.dy + totalScrollY;
          }
        }
      }
    }

    Offset relative = renderStyle.getOffset(
        ancestorRenderBox: ancestor, excludeScrollOffset: true);
    offset += relative.dy;
    return offset;
  }

  // The HTMLElement.offsetParent read-only property returns a reference to the element
  // which is the closest (nearest in the containment hierarchy) positioned ancestor element.
  //  https://drafts.csswg.org/cssom-view/#dom-htmlelement-offsetparent
  Element? get offsetParent {
    // Returns null in the following cases.
    // https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/offsetParent
    if (renderStyle.display == CSSDisplay.none ||
        renderStyle.position == CSSPositionType.fixed ||
        this is BodyElement ||
        this == ownerDocument.documentElement) {
      return null;
    }

    Element? parent = parentElement;

    while (parent != null) {
      bool isNonStatic = parent.renderStyle.position != CSSPositionType.static;
      if (parent is BodyElement || parent is RouterLinkElement || isNonStatic) {
        break;
      }
      parent = parent.parentElement;
    }
    return parent;
  }

  void click() {
    Event clickEvent =
        MouseEvent(EVENT_CLICK, detail: 1, view: ownerDocument.defaultView);
    // If element not in tree, click is fired and only response to itself.
    dispatchEvent(clickEvent);
  }

  Future<Uint8List> toBlob({double? devicePixelRatio}) {
    forceToRepaintBoundary = true;

    Completer<Uint8List> completer = Completer();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!renderStyle.isRepaintBoundary()) {
        String msg = 'toImage: the element is not repaintBoundary.';
        completer.completeError(Exception(msg));
        return;
      }

      if (!isRendererAttached) {
        String msg = 'toImage: the element is not attached to document tree.';
        completer.completeError(Exception(msg));
        return;
      }

      Uint8List captured;
      // RenderBoxModel? _renderBoxModel = renderBoxModel;

      if (!renderStyle.hasRenderBox() ||
          renderStyle.isBoxModelHaveSize() && renderStyle.boxSize()!.isEmpty) {
        // Return a blob with zero length.
        captured = Uint8List(0);
      } else {
        if (this is HTMLElement) {
          Image image = await ownerDocument.viewport!.toImage(
              devicePixelRatio ??
                  ownerDocument.controller.ownerFlutterView!.devicePixelRatio);
          ByteData? byteData =
              await image.toByteData(format: ImageByteFormat.png);
          captured = byteData!.buffer.asUint8List();
        } else {
          Image image = await renderStyle.toImage(devicePixelRatio ??
              ownerDocument.controller.ownerFlutterView!.devicePixelRatio);
          ByteData? byteData =
              await image.toByteData(format: ImageByteFormat.png);
          captured = byteData!.buffer.asUint8List();
        }
      }

      completer.complete(captured);
      forceToRepaintBoundary = false;
    });
    SchedulerBinding.instance.scheduleFrame();

    return completer.future;
  }

  void debugHighlight() {
    if (isRendererAttached) {
      renderStyle.setDebugShouldPaintOverlay(true);
    }
  }

  void debugHideHighlight() {
    if (isRendererAttached) {
      renderStyle.setDebugShouldPaintOverlay(false);
    }
  }

  void visitChildren(ElementVisitor visitor) {
    Node? child = firstChild;
    while (child != null) {
      visitor(child);
      child = child.nextSibling;
    }
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    String printText = '$tagName Element(${shortHash(this)})';
    if (className.isNotEmpty) {
      printText += ' className(.$className)';
    }
    if (id != null) {
      printText += ' id($id)';
    }
    return printText;
  }

  bool _checkRecalculateStyle(List<String?> keys) {
    if (keys.isEmpty) {
      return false;
    }
    if (keys.isEmpty) {
      return false;
    }
    return keys.any((element) => selectorKeySet.contains(element));
  }

  CSSRenderStyle? computedStyle(String? pseudoElementSpecifier) {
    return renderStyle;
  }

  bool _handleIntersectionObserver(IntersectionObserverEntry entry) {
    if (enableWebFCommandLog) {
      domLogger.fine(
          '[IntersectionObserver] notify target=$pointer tag=$tagName isIntersecting=${entry.isIntersecting} ratio=${entry.intersectionRatio} observers=${_intersectionObserverList.length}');
    }
    // If there are multiple IntersectionObservers, they cannot be distributed accurately
    final Rect intersectionRect =
        entry.boundingClientRect.overlaps(entry.rootBounds)
            ? entry.boundingClientRect.intersect(entry.rootBounds)
            : Rect.zero;
    for (var observer in _intersectionObserverList) {
      observer.addEntry(DartIntersectionObserverEntry(
        entry.isIntersecting,
        entry.intersectionRatio,
        this,
        entry.boundingClientRect,
        entry.rootBounds,
        intersectionRect,
      ));
    }

    return _intersectionObserverList.isNotEmpty;
  }

  bool addIntersectionObserver(
      IntersectionObserver observer, List<double> thresholds) {
    if (_intersectionObserverList.contains(observer)) {
      return false;
    }
    if (enableWebFCommandLog) {
      domLogger.fine(
          '[IntersectionObserver] attach target=$pointer observer=${observer.pointer} thresholds=$thresholds');
    }
    renderStyle.addIntersectionChangeListener(
        _handleIntersectionObserver, thresholds);
    _intersectionObserverList.add(observer);
    _thresholds = thresholds;
    return true;
  }

  void removeIntersectionObserver(IntersectionObserver observer) {
    if (enableWebFCommandLog) {
      domLogger.fine(
          '[IntersectionObserver] detach target=$pointer observer=${observer.pointer}');
    }
    _intersectionObserverList.remove(observer);

    if (_intersectionObserverList.isEmpty) {
      renderStyle.removeIntersectionChangeListener(_handleIntersectionObserver);
    }
  }

  void ensureAddIntersectionObserver() {
    if (_intersectionObserverList.isEmpty) {
      return;
    }
    if (enableWebFCommandLog) {
      domLogger.fine(
          '[IntersectionObserver] ensureAttach target=$pointer observers=${_intersectionObserverList.length}');
    }
    renderStyle.addIntersectionChangeListener(
        _handleIntersectionObserver, _thresholds);
  }
}

class _MatchedRulesCacheEntry {
  final int version;
  final _MatchFingerprint fingerprint;
  final CSSStyleDeclaration style;

  _MatchedRulesCacheEntry({
    required this.version,
    required this.fingerprint,
    required this.style,
  });

  bool matches({required int version, required _MatchFingerprint fingerprint}) {
    return this.version == version && this.fingerprint == fingerprint;
  }
}

class _MatchFingerprint {
  final String tagName;
  final String id;
  final List<String> classes;
  final List<_AttributeFingerprint> attributes;

  const _MatchFingerprint({
    required this.tagName,
    required this.id,
    required this.classes,
    required this.attributes,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _MatchFingerprint) return false;
    return tagName == other.tagName &&
        id == other.id &&
        listEquals(classes, other.classes) &&
        listEquals(attributes, other.attributes);
  }

  @override
  int get hashCode => Object.hash(
      tagName, id, Object.hashAll(classes), Object.hashAll(attributes));
}

class _AttributeFingerprint implements Comparable<_AttributeFingerprint> {
  final String name;
  final String value;

  const _AttributeFingerprint({required this.name, required this.value});

  @override
  int compareTo(_AttributeFingerprint other) {
    final int nameCompare = name.compareTo(other.name);
    if (nameCompare != 0) return nameCompare;
    return value.compareTo(other.value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _AttributeFingerprint) return false;
    return name == other.name && value == other.value;
  }

  @override
  int get hashCode => Object.hash(name, value);
}

Element? _findRouterLinkElement(Element child) {
  Element? parent = child.parentElement;

  while (parent != null) {
    if (parent is RouterLinkElement) {
      break;
    }
    parent = parent.parentElement;
  }
  return parent;
}

// https://www.w3.org/TR/css-position-3/#def-cb
Element? _findContainingBlock(Element child, Element viewportElement) {
  Element? parent = child.parentElement;

  while (parent != null) {
    bool isNonStatic = parent.renderStyle.position != CSSPositionType.static;
    bool hasTransform = parent.renderStyle.transform != null;
    bool isRouterLinkElement = parent is RouterLinkElement;
    // https://www.w3.org/TR/CSS2/visudet.html#containing-block-details
    if (parent == viewportElement ||
        isNonStatic ||
        hasTransform ||
        isRouterLinkElement) {
      break;
    }
    parent = parent.parentElement;
  }
  return parent;
}

// https://drafts.csswg.org/css-position/#fixedpos-containing-block
Element? _findFixedContainingBlock(Element child, Element viewportElement) {
  Element? parent = child.parentElement;

  while (parent != null) {
    final bool hasTransform = parent.renderStyle.transform != null;
    // Filter also creates a containing block for fixed-position descendants per spec.
    final bool hasFilter = parent.renderStyle.filter != null;
    final bool isRouterLinkElement = parent is RouterLinkElement;

    if (parent == viewportElement ||
        hasTransform ||
        hasFilter ||
        isRouterLinkElement) {
      break;
    }
    parent = parent.parentElement;
  }

  return parent;
}

// Reflect attribute type as property.
// String: Any input.
// Bool: Any input is true.
// Int: Any valid input, or 0.
// Double: Any valid input, or 0.0.
T attributeToProperty<T>(String value) {
  // The most using type.
  if (T == String) {
    return value as T;
  } else if (T == bool) {
    return true as T;
  } else if (T == int) {
    return (int.tryParse(value) ?? 0) as T;
  } else if (T == double) {
    return (double.tryParse(value) ?? 0.0) as T;
  } else {
    return value as T;
  }
}
