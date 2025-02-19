/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ui';

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
import 'package:webf/src/svg/rendering/container.dart';
import 'package:webf/widget.dart';
import 'package:webf/src/css/query_selector.dart' as QuerySelector;

final RegExp classNameSplitRegExp = RegExp(r'\s+');
const String _ONE_SPACE = ' ';
const String _STYLE_PROPERTY = 'style';
const String _ID = 'id';
const String _CLASS_NAME = 'class';
const String _NAME = 'name';

/// Defined by W3C Standard,
/// Most element's default width is 300 in pixel,
/// height is 150 in pixel.
const String ELEMENT_DEFAULT_WIDTH = '300px';
const String ELEMENT_DEFAULT_HEIGHT = '150px';
const String UNKNOWN = 'UNKNOWN';

typedef TestElement = bool Function(Element element);

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
  late CSSRenderStyle renderStyle;
}

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
    with ElementBase, ElementEventMixin, ElementOverflowMixin, ElementAdapterMixin {
  // Default to unknown, assign by [createElement], used by inspector.
  String tagName = UNKNOWN;

  String? _id;

  String? get id => _id;

  set id(String? id) {
    final isNeedRecalculate = _checkRecalculateStyle([id, _id]);
    _updateIDMap(id, oldID: _id);
    _id = id;
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

  @pragma('vm:prefer-inline')
  flutter.Key key = flutter.UniqueKey();

  void updateElementKey() {
    key = flutter.UniqueKey();
  }

  /// The Element.classList is a read-only property that returns a collection of the class attributes of the element.
  final List<String> _classList = [];

  String namespaceURI = '';

  List<String> get classList => _classList;

  @pragma('vm:prefer-inline')
  set className(String className) {
    List<String> classList = className.split(classNameSplitRegExp);
    final checkKeys = (_classList + classList).where((key) => !_classList.contains(key) || !classList.contains(key));
    final isNeedRecalculate = _checkRecalculateStyle(List.from(checkKeys));
    _classList.clear();
    if (classList.isNotEmpty) {
      _classList.addAll(classList);
    }
    recalculateStyle(rebuildNested: isNeedRecalculate);
  }

  String get className => _classList.join(_ONE_SPACE);

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

  @pragma('vm:prefer-inline')
  @override
  bool get isRendererAttachedToSegmentTree => renderStyle.isSelfRenderBoxAttachedToSegmentTree();

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
    style = CSSStyleDeclaration.computedStyle(this, defaultStyle, _onStyleChanged, _onStyleFlushed);

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
  RenderBoxModel? get domRenderer => renderStyle.domRenderBoxModel;

  @pragma('vm:prefer-inline')
  @override
  RenderBoxModel? get attachedRenderer => renderStyle.attachedRenderBoxModel;

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
  RenderBox createRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    return updateOrCreateRenderBoxModel(flutterWidgetElement: flutterWidgetElement)!;
  }

  String? collectElementChildText() {
    StringBuffer buffer = StringBuffer();
    childNodes.forEach((node) {
      if (node is TextNode) {
        buffer.write(node.data);
      }
    });
    if (buffer.isNotEmpty) {
      return buffer.toString();
    } else {
      return null;
    }
  }

  final Map<String, ElementAttributeProperty> _attributeProperties = {};

  @mustCallSuper
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    attributes[_STYLE_PROPERTY] = ElementAttributeProperty(setter: (value) {
      final map = CSSParser(value).parseInlineStyle();
      inlineStyle.addAll(map);
      recalculateStyle();
    }, deleter: () {
      _removeInlineStyle();
    });
    attributes[_CLASS_NAME] = ElementAttributeProperty(
        setter: (value) => className = value,
        deleter: () {
          className = EMPTY_STRING;
        });
    attributes[_ID] = ElementAttributeProperty(
        setter: (value) => id = value,
        deleter: () {
          id = EMPTY_STRING;
        });
    attributes[_NAME] = ElementAttributeProperty(setter: (value) {
      _updateNameMap(value, oldName: getAttribute(_NAME));
    }, deleter: () {
      _updateNameMap(null, oldName: getAttribute(_NAME));
    });
  }

  static bool isElementStaticProperties(StaticDefinedBindingPropertyMap map) {
    return map == _elementProperties;
  }

  // https://www.w3.org/TR/cssom-view-1/#extensions-to-the-htmlelement-interface
  // https://www.w3.org/TR/cssom-view-1/#extension-to-the-element-interface
  static final StaticDefinedBindingPropertyMap _elementProperties = {
    'offsetTop': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).offsetTop),
    'offsetLeft': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).offsetLeft),
    'offsetWidth': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).offsetWidth),
    'offsetHeight': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).offsetHeight),
    'scrollTop': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).scrollTop,
        setter: (element, value) => castToType<Element>(element).scrollTop = castToType<double>(value)),
    'scrollLeft': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).scrollLeft,
        setter: (element, value) => castToType<Element>(element).scrollLeft = castToType<double>(value)),
    'scrollWidth': StaticDefinedBindingProperty(
      getter: (element) => castToType<Element>(element).scrollWidth,
    ),
    'scrollHeight': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).scrollHeight),
    'clientTop': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).clientTop),
    'clientLeft': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).clientLeft),
    'clientWidth': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).clientWidth),
    'clientHeight': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).clientHeight),
    'id': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).id,
        setter: (element, value) => castToType<Element>(element).id = castToType<String>(value)),
    'classList': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).classList),
    'className': StaticDefinedBindingProperty(
        getter: (element) => castToType<Element>(element).className,
        setter: (element, value) => castToType<Element>(element).className = castToType<String>(value)),
    'dir': StaticDefinedBindingProperty(getter: (element) => castToType<Element>(element).dir),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _elementProperties];

  static bool isElementStaticSyncMethods(StaticDefinedSyncBindingObjectMethodMap map) {
    return map == _elementSyncMethods;
  }

  static final StaticDefinedSyncBindingObjectMethodMap _elementSyncMethods = {
    'getBoundingClientRect': StaticDefinedSyncBindingObjectMethod(
        call: (element, _) => castToType<Element>(element).getBoundingClientRect()),
    'getClientRects':
        StaticDefinedSyncBindingObjectMethod(call: (element, _) => castToType<Element>(element).getClientRects()),
    'scroll': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) =>
            castToType<Element>(element).scroll(castToType<double>(args[0]), castToType<double>(args[1]))),
    'scrollBy': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) =>
            castToType<Element>(element).scrollBy(castToType<double>(args[0]), castToType<double>(args[1]))),
    'scrollTo': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) =>
            castToType<Element>(element).scrollTo(castToType<double>(args[0]), castToType<double>(args[1]))),
    'click': StaticDefinedSyncBindingObjectMethod(call: (element, _) => castToType<Element>(element).click()),
    'getElementsByClassName': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) => castToType<Element>(element).getElementsByClassName(args)),
    'getElementsByTagName': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) => castToType<Element>(element).getElementsByTagName(args)),
    'querySelectorAll': StaticDefinedSyncBindingObjectMethod(
        call: (element, args) => castToType<Element>(element).querySelectorAll(args)),
    'querySelector':
        StaticDefinedSyncBindingObjectMethod(call: (element, args) => castToType<Element>(element).querySelector(args)),
    'matches':
        StaticDefinedSyncBindingObjectMethod(call: (element, args) => castToType<Element>(element).matches(args)),
    'closest':
        StaticDefinedSyncBindingObjectMethod(call: (element, args) => castToType<Element>(element).closest(args)),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _elementSyncMethods];

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);
    if (kDebugMode || kProfileMode) {
      methods['__test_global_to_local__'] =
          BindingObjectMethodSync(call: (args) => testGlobalToLocal(args[0], args[1]));
    }
  }

  dynamic getElementsByClassName(List<dynamic> args) {
    return QuerySelector.querySelectorAll(this, '.' + args.first);
  }

  dynamic getElementsByTagName(List<dynamic> args) {
    return QuerySelector.querySelectorAll(this, args.first);
  }

  dynamic querySelector(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return null;
    return QuerySelector.querySelector(this, args.first);
  }

  dynamic querySelectorAll(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return [];
    return QuerySelector.querySelectorAll(this, args.first);
  }

  bool matches(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return false;
    return QuerySelector.matches(this, args.first);
  }

  dynamic closest(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return null;
    return QuerySelector.closest(this, args.first);
  }

  RenderBoxModel? updateOrCreateRenderBoxModel({flutter.RenderObjectElement? flutterWidgetElement}) {
    RenderBoxModel? previousRenderBoxModel = renderStyle.domRenderBoxModel;
    RenderBoxModel nextRenderBoxModel = renderStyle.updateOrCreateRenderBoxModel();

    if (!managedByFlutterWidget && previousRenderBoxModel != nextRenderBoxModel) {
      RenderObject? parentRenderObject;
      RenderBox? after;
      if (previousRenderBoxModel != null) {
        parentRenderObject = previousRenderBoxModel.parent;

        if (previousRenderBoxModel.parentData is ContainerParentDataMixin<RenderBox>) {
          after = (previousRenderBoxModel.parentData as ContainerParentDataMixin<RenderBox>).previousSibling;
        }

        RenderBoxModel.detachRenderBox(previousRenderBoxModel);

        if (parentRenderObject != null) {
          RenderBoxModel.attachRenderBox(parentRenderObject, nextRenderBoxModel, after: after);
        }

        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          if (!previousRenderBoxModel.disposed) {
            previousRenderBoxModel.dispose();
          }
        });
      }
    }

    if (managedByFlutterWidget) {
      assert(flutterWidgetElement != null);
      renderStyle.addOrUpdateWidgetRenderObjects(flutterWidgetElement!, nextRenderBoxModel);
    } else {
      renderStyle.setDomRenderObject(nextRenderBoxModel);
    }

    // Ensure that the event responder is bound.
    renderStyle.ensureEventResponderBound();

    return nextRenderBoxModel;
  }

  RenderBoxModel createRenderSVG({RenderBoxModel? previous, bool isRepaintBoundary = false}) {
    throw UnimplementedError();
  }

  @override
  RenderObject willAttachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    if (renderStyle.display == CSSDisplay.none) {
      return RenderConstrainedBox(additionalConstraints: BoxConstraints.tight(Size.zero));
    }

    // Init render box model.
    return createRenderer(flutterWidgetElement);
  }

  @override
  void didAttachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('$this.didAttachRenderer');
    }
    super.didAttachRenderer(flutterWidgetElement);

    // The node attach may affect the whitespace of the nextSibling and previousSibling text node so prev and next node require layout.
    renderStyle.markAdjacentRenderParagraphNeedsLayout();

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
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

    RenderBoxModel? renderBoxModel = renderStyle.getSelfRenderBox(flutterWidgetElement);

    // Clear pointer listener
    clearEventResponder(renderBoxModel);

    if (renderStyle.position == CSSPositionType.fixed) {
      print(holderAttachedPositionedElement);
    }
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
    _applyStickyChildrenOffset();
    _applyFixedChildrenOffset(scrollOffset, axisDirection);

    if (!_shouldConsumeScrollTicker) {
      // Make sure scroll listener trigger most to 1 time each frame.
      SchedulerBinding.instance.addPostFrameCallback(_consumeScrollTicker);
      SchedulerBinding.instance.scheduleFrame();
    }
    _shouldConsumeScrollTicker = true;
  }

  /// Normally element in scroll box will not repaint on scroll because of repaint boundary optimization
  /// So it needs to manually mark element needs paint and add scroll offset in paint stage
  void _applyFixedChildrenOffset(double scrollOffset, AxisDirection axisDirection) {
    // Only root element has fixed children.
    if (this == ownerDocument.documentElement) {
      for (RenderBoxModel child in ownerDocument.fixedChildren) {
        // Save scrolling offset for paint
        if (axisDirection == AxisDirection.down) {
          child.scrollingOffsetY = scrollOffset;
        } else if (axisDirection == AxisDirection.right) {
          child.scrollingOffsetX = scrollOffset;
        }
      }
    }
  }

  // Calculate sticky status according to scroll offset and scroll direction
  void _applyStickyChildrenOffset() {
    return;
    // RenderLayoutBox scrollContainer = renderStyle.domRenderBoxModel as RenderLayoutBox;
    // for (RenderBoxModel stickyChild in scrollContainer.stickyChildren) {
    //   CSSPositionedLayout.applyStickyChildOffset(scrollContainer, stickyChild);
    // }
  }

  // Find all the nested position absolute elements which need to change the containing block
  // from other element to this element when element's position is changed from static to relative.
  // Take following html for example, div of id=4 should reposition from div of id=1 to div of id=2.
  // <div id="1" style="position: relative">
  //    <div id="2" style="position: relative"> <!-- changed from "static" to "relative" -->
  //        <div id="3">
  //            <div id="4" style="position: absolute">
  //            </div>
  //        </div>
  //    </div>
  // </div>
  List<Element> findNestedPositionAbsoluteChildren() {
    List<Element> positionAbsoluteChildren = [];

    if (!isRendererAttachedToSegmentTree) return positionAbsoluteChildren;

    children.forEach((Element child) {
      if (!child.isRendererAttachedToSegmentTree) return;

      RenderBoxModel childRenderBoxModel = child.renderStyle.domRenderBoxModel!;
      RenderStyle childRenderStyle = childRenderBoxModel.renderStyle;
      if (childRenderStyle.position == CSSPositionType.absolute) {
        positionAbsoluteChildren.add(child);
      }
      // No need to loop layout box whose position is not static.
      if (childRenderStyle.position != CSSPositionType.static) {
        return;
      }
      if (childRenderBoxModel is RenderLayoutBox) {
        List<Element> mergedChildren = child.findNestedPositionAbsoluteChildren();
        for (Element child in mergedChildren) {
          positionAbsoluteChildren.add(child);
        }
      }
    });

    return positionAbsoluteChildren;
  }

  // Find all the direct position absolute elements which need to change the containing block
  // from this element to other element when element's position is changed from relative to static.
  // Take following html for example, div of id=4 should reposition from div of id=2 to div of id=1.
  // <div id="1" style="position: relative">
  //    <div id="2" style="position: static"> <!-- changed from "relative" to "static" -->
  //        <div id="3">
  //            <div id="4" style="position: absolute">
  //            </div>
  //        </div>
  //    </div>
  // </div>
  List<Element> findDirectPositionAbsoluteChildren() {
    List<Element> directPositionAbsoluteChildren = [];

    assert(!managedByFlutterWidget);
    if (!isRendererAttachedToSegmentTree) return directPositionAbsoluteChildren;

    RenderBox? child = (renderStyle.domRenderBoxModel as RenderLayoutBox).firstChild;

    while (child != null) {
      final ContainerParentDataMixin<RenderBox>? childParentData =
          child.parentData as ContainerParentDataMixin<RenderBox>?;
      if (child is! RenderLayoutBox) {
        child = childParentData!.nextSibling;
        continue;
      }
      if (child.renderStyle.position == CSSPositionType.absolute) {
        directPositionAbsoluteChildren.add(child.renderStyle.target);
      }
      child = childParentData!.nextSibling;
    }

    return directPositionAbsoluteChildren;
  }

  void _updateHostingWidgetWithOverflow(CSSOverflowType oldOverflow) {
    renderStyle.requestWidgetToRebuild(AddScrollerUpdateReason());
  }

  void _updateHostingWidgetWithTransform() {
    updateElementKey();
    renderStyle.requestWidgetToRebuild(UpdateTransformReason());
  }

  void _updateHostingWidgetWithPosition(CSSPositionType oldPosition) {
    assert(managedByFlutterWidget);
    CSSPositionType currentPosition = renderStyle.position;

    // No need to detach and reattach renderBoxMode when its position
    // changes between static and relative.
    if (!(oldPosition == CSSPositionType.static && currentPosition == CSSPositionType.relative) &&
        !(oldPosition == CSSPositionType.relative && currentPosition == CSSPositionType.static)) {
      Map<flutter.RenderObjectElement, RenderBoxModel> widgetRenderObjects = renderStyle.widgetRenderObjects;

      // Find the renderBox of its containing block.
      Element? containingBlockElement = getContainingBlockElement();

      if (containingBlockElement == null) return;

      renderStyle.requestWidgetToRebuild(
          ToPositionPlaceHolderUpdateReason(positionedElement: this, containingBlockElement: containingBlockElement));
      containingBlockElement.renderStyle.requestWidgetToRebuild(
          AttachPositionedChild(positionedElement: this, containingBlockElement: containingBlockElement));
    }
  }

  PseudoElement _createOrUpdatePseudoElement(
      String contentValue, PseudoKind kind, PseudoElement? previousPseudoElement) {
    var pseudoValue = CSSPseudo.resolveContent(contentValue);

    bool shouldMutateBeforeElement =
        previousPseudoElement == null || ((previousPseudoElement.firstChild as TextNode).data == pseudoValue);

    previousPseudoElement ??= PseudoElement(
        kind, this, BindingContext(ownerDocument.controller.view, contextId!, allocateNewBindingObject()));
    previousPseudoElement.style
        .merge(kind == PseudoKind.kPseudoBefore ? style.pseudoBeforeStyle! : style.pseudoAfterStyle!);

    if (shouldMutateBeforeElement) {
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
    }

    // We plan to support content values only with quoted strings.
    if (pseudoValue is QuoteStringContentValue) {
      if (previousPseudoElement.firstChild != null) {
        (previousPseudoElement.firstChild as TextNode).data = pseudoValue.value;
      } else {
        final textNode = ownerDocument.createTextNode(
            pseudoValue.value, BindingContext(ownerDocument.controller.view, contextId!, allocateNewBindingObject()));
        previousPseudoElement.appendChild(textNode);
      }
    }

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
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }
    // Add pseudo elements
    String? beforeContent = style.pseudoBeforeStyle?.getPropertyValue('content');
    if (beforeContent != null && beforeContent.isNotEmpty) {
      _beforeElement = _createOrUpdatePseudoElement(beforeContent, PseudoKind.kPseudoBefore, _beforeElement);
    } else if (_beforeElement != null) {
      removeChild(_beforeElement!);
    }
    _shouldBeforePseudoElementNeedsUpdate = false;
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
    }
  }

  bool _shouldAfterPseudoElementNeedsUpdate = false;

  void markAfterPseudoElementNeedsUpdate() {
    if (_shouldAfterPseudoElementNeedsUpdate) return;
    _shouldAfterPseudoElementNeedsUpdate = true;
    Future.microtask(_updateAfterPseudoElement);
  }

  void _updateAfterPseudoElement() {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }
    String? afterContent = style.pseudoAfterStyle?.getPropertyValue('content');
    if (afterContent != null && afterContent.isNotEmpty) {
      _afterElement = _createOrUpdatePseudoElement(afterContent, PseudoKind.kPseudoAfter, _afterElement);
    } else if (_afterElement != null) {
      removeChild(_afterElement!);
    }
    _shouldAfterPseudoElementNeedsUpdate = false;
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
    }
  }

  // Add element to its containing block which includes the steps of detach the renderBoxModel
  // from its original parent and attach to its new containing block.
  void addToContainingBlock(flutter.RenderObjectElement? flutterWidgetElement) {
    assert(!managedByFlutterWidget);
    RenderBoxModel _renderBoxModel = renderStyle.domRenderBoxModel!;
    // Find the renderBox of its containing block.
    Element? containingBlockElement = getContainingBlockElement();
    // Find the previous siblings to insert before renderBoxModel is detached.
    RenderBox? previousSibling = _renderBoxModel.getPreviousSibling();
    // Detach renderBoxModel from its original parent.
    _renderBoxModel.detachFromContainingBlock();
    // Original parent renderBox.
    RenderBox parentRenderBox = parentElement!.renderStyle.domRenderBoxModel!;
    // Attach renderBoxModel of to its containing block.
    _renderBoxModel.attachToContainingBlock(containingBlockElement?.renderStyle.domRenderBoxModel,
        parent: parentRenderBox, after: previousSibling);
  }

  void addChildForDOMMode(RenderBox child) {
    if (renderStyle.isSelfRenderLayoutBox()) {
      RenderLayoutBox _renderLayoutBox = renderStyle.domRenderBoxModel as RenderLayoutBox;
      RenderLayoutBox? scrollingContentBox = _renderLayoutBox.renderScrollingContent;
      if (scrollingContentBox != null) {
        scrollingContentBox.add(child);
      } else {
        _renderLayoutBox.add(child);
      }
    } else if (renderStyle.isSelfRenderReplaced()) {
      RenderReplaced _renderReplaced = renderStyle.domRenderBoxModel as RenderReplaced;
      _renderReplaced.child = child;
    }
  }

  @override
  void dispose() async {
    renderStyle.detach();
    renderStyle.dispose();
    style.dispose();
    attributes.clear();
    _attributeProperties.clear();
    if (!managedByFlutterWidget) {
      ownerDocument.inactiveRenderObjects.add(renderStyle.domRenderBoxModel);
    }
    ownerDocument.clearElementStyleDirty(this);
    positionedElements.clear();
    holderAttachedPositionedElement = null;
    holderAttachedContainingBlockElement = null;
    _beforeElement?.dispose();
    _beforeElement = null;
    _afterElement?.dispose();
    _afterElement = null;
    scrollControllerX?.dispose();
    scrollControllerX = null;
    scrollControllerY?.dispose();
    scrollControllerY = null;
    super.dispose();
  }

  // Used for force update layout.
  void flushLayout() {
    if (isRendererAttached) {
      RendererBinding.instance.rootPipelineOwner.flushLayout();
    } else if (isRendererAttachedToSegmentTree) {
      renderStyle.flushLayout();
    }
  }

  static bool isRenderObjectOwnedByFlutterFramework(Element element) {
    return element is WidgetElement || element.managedByFlutterWidget;
  }

  @override
  void childrenChanged(ChildrenChange change) {
    super.childrenChanged(change);
    if (managedByFlutterWidget) {
      renderStyle.requestWidgetToRebuild(UpdateChildNodeUpdateReason());
    }
  }

  @override
  @mustCallSuper
  Node appendChild(Node child) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('Element.appendChild');
    }

    if (managedByFlutterWidget || this is WidgetElement) {
      child.managedByFlutterWidget = true;
    }

    super.appendChild(child);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
    return child;
  }

  @override
  @mustCallSuper
  Node removeChild(Node child) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('Element.removeChild');
    }
    super.removeChild(child);

    // Update renderStyle tree.
    if (child is Element) {
      child.renderStyle.detach();
    }

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }

    return child;
  }

  @override
  @mustCallSuper
  Node insertBefore(Node child, Node referenceNode) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('Element.insertBefore');
    }

    if (managedByFlutterWidget || this is WidgetElement) {
      child.managedByFlutterWidget = true;
    }

    Node? previousSibling = referenceNode.previousSibling;
    Node? node = super.insertBefore(child, referenceNode);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }

    return node;
  }

  @override
  @mustCallSuper
  Node? replaceChild(Node newNode, Node oldNode) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('Element.replaceChild');
    }
    if (managedByFlutterWidget || this is WidgetElement) {
      newNode.managedByFlutterWidget = true;
    }

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
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

  @override
  void connectedCallback() {
    super.connectedCallback();
    _updateNameMap(getAttribute(_NAME));
    _updateIDMap(_id);

    if (managedByFlutterWidget) {
      applyStyle(style);
      style.flushPendingProperties();
    }
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    _updateIDMap(null, oldID: _id);
    _updateNameMap(null, oldName: getAttribute(_NAME));
    if (renderStyle.position == CSSPositionType.fixed || renderStyle.position == CSSPositionType.absolute) {
      holderAttachedContainingBlockElement!.positionedElements.remove(this);
      holderAttachedContainingBlockElement!.renderStyle.requestWidgetToRebuild(UpdateChildNodeUpdateReason());
    }
  }

  Element? getContainingBlockElement() {
    Element? containingBlockElement;
    CSSPositionType positionType = renderStyle.position;

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

        if (managedByFlutterWidget) {
          // If the element has 'position: fixed', the router link element was behavior as the HTMLElement in DOM mode.
          containingBlockElement = _findRouterLinkElement(this) ?? viewportElement;
        } else {
          // If the element has 'position: fixed', the containing block is established by the viewport
          // in the case of continuous media or the page area in the case of paged media.
          containingBlockElement = viewportElement;
        }

        break;
    }
    return containingBlockElement;
  }

  @mustCallSuper
  String? getAttribute(String qualifiedName) {
    ElementAttributeProperty? propertyHandler = _attributeProperties[qualifiedName];

    if (propertyHandler != null && propertyHandler.getter != null) {
      return propertyHandler.getter!();
    }

    return attributes[qualifiedName];
  }

  @mustCallSuper
  void setAttribute(String qualifiedName, String value) {
    ElementAttributeProperty? propertyHandler = _attributeProperties[qualifiedName];
    if (propertyHandler != null && propertyHandler.setter != null) {
      propertyHandler.setter!(value);
    }
    internalSetAttribute(qualifiedName, value);
  }

  void internalSetAttribute(String qualifiedName, String value) {
    attributes[qualifiedName] = value;
    if (qualifiedName == 'class') {
      className = value;
      return;
    }
    final isNeedRecalculate = _checkRecalculateStyle([qualifiedName]);
    recalculateStyle(rebuildNested: isNeedRecalculate);
  }

  @mustCallSuper
  void removeAttribute(String qualifiedName) {
    ElementAttributeProperty? propertyHandler = _attributeProperties[qualifiedName];

    if (propertyHandler != null && propertyHandler.deleter != null) {
      propertyHandler.deleter!();
    }

    if (hasAttribute(qualifiedName)) {
      attributes.remove(qualifiedName);
      final isNeedRecalculate = _checkRecalculateStyle([qualifiedName]);
      recalculateStyle(rebuildNested: isNeedRecalculate);
    }
  }

  @mustCallSuper
  bool hasAttribute(String qualifiedName) {
    return attributes.containsKey(qualifiedName);
  }

  @deprecated
  void setStyle(String property, value) {
    setRenderStyle(property, value);
  }

  void _updateHostingWidgetWithDisplay(CSSDisplay oldDisplay) {
    CSSDisplay presentDisplay = renderStyle.display;

    if (parentElement == null || !parentElement!.isConnected) return;

    assert(managedByFlutterWidget);

    // Destroy renderer of element when display is changed to none.
    if (presentDisplay == CSSDisplay.none) {
      renderStyle.requestWidgetToRebuild(UpdateDisplayReason());
      return;
    }
    if (oldDisplay == CSSDisplay.none && presentDisplay != oldDisplay) {
      assert(!renderStyle.hasRenderBox());
      parentElement?.renderStyle.requestWidgetToRebuild(UpdateDisplayReason());
      return;
    }

    renderStyle.widgetRenderObjects.forEach((renderObjectElement, renderObject) {
      willAttachRenderer(renderObjectElement);
      didAttachRenderer(renderObjectElement);
    });

    renderStyle.requestWidgetToRebuild(UpdateDisplayReason());
  }

  void setRenderStyleProperty(String name, value) {
    if (renderStyle.target.disposed) return;

    bool uiCommandTracked = false;
    if (enableWebFProfileTracking) {
      if (!WebFProfiler.instance.currentPipeline.containsActiveUICommand()) {
        WebFProfiler.instance.startTrackUICommand();
        uiCommandTracked = true;
      }
      WebFProfiler.instance.startTrackUICommandStep('$this.setRenderStyleProperty[$name]');
    }

    dynamic oldValue;

    switch (name) {
      case DISPLAY:
      case OVERFLOW_X:
      case OVERFLOW_Y:
      case POSITION:
        oldValue = renderStyle.getProperty(name);
        break;
    }

    renderStyle.setProperty(name, value);

    switch (name) {
      case DISPLAY:
        assert(oldValue != null);
        if (value != oldValue && this is! WidgetElement) {
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
        scheduleMicrotask(() {
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

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
      if (uiCommandTracked) {
        WebFProfiler.instance.finishTrackUICommand();
      }
    }
  }

  void setRenderStyle(String property, String present, {String? baseHref}) {
    dynamic value = present.isEmpty ? null : renderStyle.resolveValue(property, present, baseHref: baseHref);
    setRenderStyleProperty(property, value);
  }

  void _updateColorRelativePropertyWithColor(Element element) {
    element.renderStyle.updateColorRelativeProperty();
    if (element.children.isNotEmpty) {
      element.children.forEach((Element child) {
        if (!child.renderStyle.hasColor) {
          _updateColorRelativePropertyWithColor(child);
        }
      });
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
      element.children.forEach((Element child) {
        if (!child.renderStyle.hasFontSize) {
          _updateChildrenFontRelativeLength(child);
        }
      });
    }
  }

  void _updateChildrenRootFontRelativeLength(Element element) {
    element.renderStyle.updateRootFontRelativeLength();
    if (element.children.isNotEmpty) {
      element.children.forEach((Element child) {
        _updateChildrenRootFontRelativeLength(child);
      });
    }
  }

  void _applyDefaultStyle(CSSStyleDeclaration style) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('$this._applyDefaultStyle');
    }
    if (defaultStyle.isNotEmpty) {
      defaultStyle.forEach((propertyName, value) {
        if (style.contains(propertyName) == false) {
          style.setProperty(propertyName, value);
        }
      });
    }
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
  }

  void _applyInlineStyle(CSSStyleDeclaration style) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('$this._applyInlineStyle');
    }
    if (inlineStyle.isNotEmpty) {
      inlineStyle.forEach((propertyName, value) {
        // Force inline style to be applied as important priority.
        style.setProperty(propertyName, value, isImportant: true);
      });
    }
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
  }

  void _applySheetStyle(CSSStyleDeclaration style) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('$this._applySheetStyle');
    }
    CSSStyleDeclaration matchRule = _elementRuleCollector.collectionFromRuleSet(ownerDocument.ruleSet, this);
    style.union(matchRule);
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
  }

  bool _scheduledRunTransitions = false;

  void scheduleRunTransitionAnimations(String propertyName, String? prevValue, String currentValue) {
    if (_scheduledRunTransitions) return;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      renderStyle.runTransition(propertyName, prevValue, currentValue);
      _scheduledRunTransitions = false;
    });
  }

  void _onStyleChanged(String propertyName, String? prevValue, String currentValue, {String? baseHref}) {
    if (renderStyle.shouldTransition(propertyName, prevValue, currentValue)) {
      scheduleRunTransitionAnimations(propertyName, prevValue, currentValue);
    } else {
      setRenderStyle(propertyName, currentValue, baseHref: baseHref);
    }
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
  void setInlineStyle(String property, String value) {
    // Current only for mark property is setting by inline style.
    inlineStyle[property] = value;
    // recalculate matching styles for element when inline styles are removed.
    if (value.isEmpty) {
      style.removeProperty(property, true);
      recalculateStyle();
    } else {
      style.setProperty(property, value, isImportant: true);
    }
  }

  void clearInlineStyle() {
    for (var key in inlineStyle.keys) {
      style.removeProperty(key, true);
    }
    inlineStyle.clear();
  }

  void _applyPseudoStyle(CSSStyleDeclaration style) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('$this._applyPseudoStyle');
    }

    List<CSSStyleRule> pseudoRules = _elementRuleCollector.matchedPseudoRules(ownerDocument.ruleSet, this);
    style.handlePseudoRules(this, pseudoRules);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
  }

  void applyStyle(CSSStyleDeclaration style) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('$this.applyStyle');
    }
    // Apply default style.
    _applyDefaultStyle(style);
    // Init display from style directly cause renderStyle is not flushed yet.
    renderStyle.initDisplay(style);

    applyAttributeStyle(style);
    _applyInlineStyle(style);
    _applySheetStyle(style);
    _applyPseudoStyle(style);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
    }
  }

  void applyAttributeStyle(CSSStyleDeclaration style) {
    // Empty implement
    // Because attribute style is not recommend to use
    // But it's necessary for SVG.
  }

  void recalculateStyle({bool rebuildNested = false, bool forceRecalculate = false}) {
    if (renderStyle.hasRenderBox() || forceRecalculate || renderStyle.display == CSSDisplay.none) {
      if (enableWebFProfileTracking) {
        WebFProfiler.instance.startTrackUICommandStep('$this.recalculateStyle');
      }
      // Diff style.
      CSSStyleDeclaration newStyle = CSSStyleDeclaration();
      applyStyle(newStyle);
      var hasInheritedPendingProperty = false;
      if (style.merge(newStyle)) {
        hasInheritedPendingProperty = style.hasInheritedPendingProperty;
        if (!ownerDocument.controller.shouldBlockingFlushingResolvedStyleProperties) {
          style.flushPendingProperties();
        }
      }

      if (rebuildNested || hasInheritedPendingProperty) {
        // Update children style.
        children.forEach((Element child) {
          child.recalculateStyle(rebuildNested: rebuildNested);
        });
      }
      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackUICommandStep();
      }
    }
  }

  void _removeInlineStyle() {
    inlineStyle.forEach((String property, _) {
      _removeInlineStyleProperty(property);
    });
    inlineStyle.clear();
    if (!ownerDocument.controller.shouldBlockingFlushingResolvedStyleProperties) {
      style.flushPendingProperties();
    }
  }

  void _removeInlineStyleProperty(String property) {
    style.removeProperty(property, true);
  }

  // The Element.getBoundingClientRect() method returns a DOMRect object providing information
  // about the size of an element and its position relative to the viewport.
  // https://drafts.csswg.org/cssom-view/#dom-element-getboundingclientrect
  BoundingClientRect get boundingClientRect {
    BoundingClientRect boundingClientRect =
        BoundingClientRect.zero(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()));
    if (isRendererAttached) {
      ownerDocument.forceRebuild();
      flushLayout();
      // RenderBoxModel sizedBox = renderBoxModel!;
      // Force flush layout.
      if (!renderStyle.isBoxModelHaveSize()) {
        renderStyle.markNeedsLayout();
        renderStyle.flushLayout();
      }

      if (renderStyle.isBoxModelHaveSize()) {
        Offset offset = renderStyle.getOffset(
            ancestorRenderBox: ownerDocument.documentElement!.domRenderer as RenderBoxModel, excludeScrollOffset: true);
        Size size = renderStyle.boxSize()!;
        boundingClientRect = BoundingClientRect(
            context: BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()),
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
    Offset relative = renderStyle.getOffset(ancestorRenderBox: offsetParent?.attachedRenderer);
    offset += relative.dx;
    return offset;
  }

  dynamic testGlobalToLocal(double x, double y) {
    if (!isRendererAttached) {
      return {'x': 0, 'y': 0};
    }

    Offset offset = Offset(x, y);
    Offset result = renderStyle.domRenderBoxModel!.globalToLocal(offset);
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
    Offset relative = renderStyle.getOffset(ancestorRenderBox: offsetParent?.attachedRenderer);
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
      if (parent is BodyElement || isNonStatic) {
        break;
      }
      parent = parent.parentElement;
    }
    return parent;
  }

  void click() {
    ownerDocument.forceRebuild();
    flushLayout();
    Event clickEvent = MouseEvent(EVENT_CLICK, detail: 1, view: ownerDocument.defaultView);
    // If element not in tree, click is fired and only response to itself.
    dispatchEvent(clickEvent);
  }

  /// Moves the focus to the element.
  /// https://html.spec.whatwg.org/multipage/interaction.html#dom-focus
  void focus() {
    // TODO
  }

  /// Moves the focus to the viewport. Use of this method is discouraged;
  /// if you want to focus the viewport, call the focus() method on the Document's document element.
  /// https://html.spec.whatwg.org/multipage/interaction.html#dom-blur
  void blur() {
    // TODO
  }

  Future<Uint8List> toBlob({double? devicePixelRatio, BindingOpItem? currentProfileOp}) {
    forceToRepaintBoundary = true;

    ownerDocument.forceRebuild();

    Completer<Uint8List> completer = Completer();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      flushLayout();

      if (!isRendererAttached) {
        String msg = 'toImage: the element is not attached to document tree.';
        completer.completeError(Exception(msg));
        return;
      }

      Uint8List captured;
      // RenderBoxModel? _renderBoxModel = renderBoxModel;

      if (!renderStyle.hasRenderBox() || renderStyle.isBoxModelHaveSize() && renderStyle.boxSize()!.isEmpty) {
        // Return a blob with zero length.
        captured = Uint8List(0);
      } else {
        Image image =
            await renderStyle.toImage(devicePixelRatio ?? ownerDocument.controller.ownerFlutterView.devicePixelRatio);
        ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
        captured = byteData!.buffer.asUint8List();
      }

      completer.complete(captured);
      forceToRepaintBoundary = false;
      // May be disposed before this callback.
      flushLayout();
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

  // Create a new RenderLayoutBox for the scrolling content.
  RenderLayoutBox createScrollingContentLayout() {
    // FIXME: Create an empty renderStyle for do not share renderStyle with element.
    CSSRenderStyle scrollingContentRenderStyle = CSSRenderStyle(target: this);
    // Scrolling content layout need to be share the same display with its outer layout box.
    scrollingContentRenderStyle.display = renderStyle.display;
    RenderLayoutBox scrollingContentLayoutBox = renderStyle.createRenderLayout(
      isRepaintBoundary: true,
      cssRenderStyle: scrollingContentRenderStyle,
    );
    scrollingContentRenderStyle.setDomRenderObject(scrollingContentLayoutBox);
    scrollingContentLayoutBox.isScrollingContentBox = true;
    return scrollingContentLayoutBox;
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

  RenderStyle? computedStyle(String? pseudoElementSpecifier) {
    recalculateStyle();

    if (!renderStyle.hasRenderBox()) {
      return null;
    }

    return renderStyle;
  }
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
    if (parent == viewportElement || isNonStatic || hasTransform || isRouterLinkElement) {
      break;
    }
    parent = parent.parentElement;
  }
  return parent;
}

// Cache fixed renderObject to root element
void _addFixedChild(RenderBoxModel childRenderBoxModel, Document ownerDocument) {
  Set<RenderBoxModel> fixedChildren = ownerDocument.fixedChildren;
  if (!fixedChildren.contains(childRenderBoxModel)) {
    fixedChildren.add(childRenderBoxModel);
  }
}

bool _isRenderBoxFixed(RenderBox renderBox, Document ownerDocument) {
  Set<RenderBoxModel> fixedChildren = ownerDocument.fixedChildren;
  return fixedChildren.contains(renderBox);
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
