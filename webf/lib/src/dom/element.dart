/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ui';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/html.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/bridge/native_types.dart';
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

enum StyleChangeType {
  noStyleChange,
  // This node needs style recalculation, but the changes are of
  // a very limited set:
  //
  //  1. They only touch the node's inline style (style="" attribute).
  //  2. They don't add or remove any properties.
  //  3. They only touch independent properties.
  //
  // If all changes are of this type, we can do incremental style
  // recalculation by reusing the previous style and just applying
  // any modified inline style, which is cheaper than a full recalc.
  // See CanApplyInlineStyleIncrementally() and comments on
  // StyleResolver::ApplyBaseStyle() for more details.
  inlineIndependentStyleChange,
  // This node needs (full) style recalculation.
  localStyleChange,
  // This node and all of its flat-tree descendeants need style recalculation.
  subtreeStyleChange
}

mixin ElementBase on Node {
  RenderLayoutBox? _renderLayoutBox;
  RenderReplaced? _renderReplaced;
  RenderWidget? _renderWidget;

  RenderBoxModel? get renderBoxModel => _renderLayoutBox ?? _renderReplaced ?? _renderWidget;

  set renderBoxModel(RenderBoxModel? value) {
    if (value == null) {
      _renderReplaced = null;
      _renderLayoutBox = null;
      _renderWidget = null;
    } else if (value is RenderReplaced) {
      _renderReplaced = value;
    } else if (value is RenderLayoutBox) {
      _renderLayoutBox = value;
    } else if (value is RenderWidget) {
      _renderWidget = value;
    } else {
      if (!kReleaseMode) throw FlutterError('Unknown RenderBoxModel value.');
    }
  }

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

abstract class Element extends ContainerNode with ElementBase, ElementEventMixin, ElementOverflowMixin {
  // Default to unknown, assign by [createElement], used by inspector.
  String tagName = UNKNOWN;

  String? _id;

  String? get id => _id;

  set id(String? id) {
    final isNeedRecalculate = _checkRecalculateStyle([id, _id]);
    _updateIDMap(id, oldID: _id);
    _id = id;
    setNeedsStyleRecalc(isNeedRecalculate ? StyleChangeType.subtreeStyleChange : StyleChangeType.localStyleChange);
  }

  // Is element an replaced element.
  // https://drafts.csswg.org/css-display/#replaced-element
  bool get isReplacedElement => false;

  bool get isWidgetElement => false;

  // Holding reference if this element are managed by Flutter framework.
  WebFHTMLElementStatefulWidget? flutterWidget_;
  WebFHTMLElementToFlutterElementAdaptor? flutterWidgetElement;

  @override
  WebFHTMLElementStatefulWidget? get flutterWidget => flutterWidget_;

  set flutterWidget(WebFHTMLElementStatefulWidget? value) {
    flutterWidget_ = value;
  }

  HTMLElementState? flutterWidgetState;
  List<Widget> pendingSubWidgets = [];

  // The attrs.
  final Map<String, String> attributes = <String, String>{};

  /// The style of the element, not inline style.
  late CSSStyleDeclaration style;

  /// The default user-agent style.
  Map<String, dynamic> get defaultStyle => {};

  /// The inline style is a map of style property name to style property value.
  final Map<String, dynamic> inlineStyle = {};

  /// The Element.classList is a read-only property that returns a collection of the class attributes of the element.
  final List<String> _classList = [];

  String namespaceURI = '';

  List<String> get classList => _classList;

  set className(String className) {
    List<String> newClassLists = className.split(classNameSplitRegExp);
    if (newClassLists.equals(classList)) return;
    final checkKeys = (_classList + newClassLists).where((key) => !_classList.contains(key) || !classList.contains(key));
    final isNeedRecalculate = _checkRecalculateStyle(List.from(checkKeys));
    _classList.clear();
    if (newClassLists.isNotEmpty) {
      _classList.addAll(newClassLists);
    }
    setNeedsStyleRecalc(isNeedRecalculate ? StyleChangeType.subtreeStyleChange : StyleChangeType.localStyleChange);
  }

  String get className => _classList.join(_ONE_SPACE);

  PseudoElement? _beforeElement;
  PseudoElement? _afterElement;

  final bool isDefaultRepaintBoundary = false;

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

  bool _forceToRepaintBoundary = false;

  set forceToRepaintBoundary(bool value) {
    if (_forceToRepaintBoundary == value) {
      return;
    }
    _forceToRepaintBoundary = value;
    updateRenderBoxModel();
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

  @override
  String get nodeName => tagName;

  @override
  RenderBox? get renderer => renderBoxModel;

  HTMLCollection? _collection;

  HTMLCollection ensureCachedCollection() {
    _collection ??= HTMLCollection(this);
    return _collection!;
  }

  // https://developer.mozilla.org/en-US/docs/Web/API/Element/children
  // The children is defined at interface [ParentNode].
  HTMLCollection get children => ensureCachedCollection();

  @override
  RenderBox createRenderer() {
    updateRenderBoxModel();
    return renderBoxModel!;
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
      setNeedsStyleRecalc(StyleChangeType.inlineIndependentStyleChange);
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

  // https://www.w3.org/TR/cssom-view-1/#extensions-to-the-htmlelement-interface
  // https://www.w3.org/TR/cssom-view-1/#extension-to-the-element-interface
  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    properties['offsetTop'] = BindingObjectProperty(getter: () => offsetTop);
    properties['offsetLeft'] = BindingObjectProperty(getter: () => offsetLeft);
    properties['offsetWidth'] = BindingObjectProperty(getter: () => offsetWidth);
    properties['offsetHeight'] = BindingObjectProperty(getter: () => offsetHeight);

    properties['scrollTop'] =
        BindingObjectProperty(getter: () => scrollTop, setter: (value) => scrollTop = castToType<double>(value));
    properties['scrollLeft'] =
        BindingObjectProperty(getter: () => scrollLeft, setter: (value) => scrollLeft = castToType<double>(value));
    properties['scrollWidth'] = BindingObjectProperty(getter: () => scrollWidth);
    properties['scrollHeight'] = BindingObjectProperty(getter: () => scrollHeight);

    properties['clientTop'] = BindingObjectProperty(getter: () => clientTop);
    properties['clientLeft'] = BindingObjectProperty(getter: () => clientLeft);
    properties['clientWidth'] = BindingObjectProperty(getter: () => clientWidth);
    properties['clientHeight'] = BindingObjectProperty(getter: () => clientHeight);

    properties['id'] = BindingObjectProperty(getter: () => id, setter: (value) => id = castToType<String>(value));
    properties['className'] =
        BindingObjectProperty(getter: () => className, setter: (value) => className = castToType<String>(value));
    properties['classList'] = BindingObjectProperty(getter: () => classList);
    properties['dir'] = BindingObjectProperty(getter: () => dir);
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    methods['getBoundingClientRect'] = BindingObjectMethodSync(call: (_) => getBoundingClientRect());
    methods['scroll'] =
        BindingObjectMethodSync(call: (args) => scroll(castToType<double>(args[0]), castToType<double>(args[1])));
    methods['scrollBy'] =
        BindingObjectMethodSync(call: (args) => scrollBy(castToType<double>(args[0]), castToType<double>(args[1])));
    methods['scrollTo'] =
        BindingObjectMethodSync(call: (args) => scrollTo(castToType<double>(args[0]), castToType<double>(args[1])));
    methods['click'] = BindingObjectMethodSync(call: (_) => click());
    methods['getElementsByClassName'] = BindingObjectMethodSync(call: (args) => getElementsByClassName(args));
    methods['getElementsByTagName'] = BindingObjectMethodSync(call: (args) => getElementsByTagName(args));
    methods['querySelectorAll'] = BindingObjectMethodSync(call: (args) => querySelectorAll(args));
    methods['querySelector'] = BindingObjectMethodSync(call: (args) => querySelector(args));
    methods['matches'] = BindingObjectMethodSync(call: (args) => matches(args));
    methods['closest'] = BindingObjectMethodSync(call: (args) => closest(args));
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

  void updateRenderBoxModel() {
    RenderBoxModel nextRenderBoxModel;
    if (isWidgetElement) {
      nextRenderBoxModel = _createRenderWidget(previousRenderWidget: _renderWidget);
    } else if (isReplacedElement) {
      nextRenderBoxModel =
          _createRenderReplaced(isRepaintBoundary: isRepaintBoundary, previousReplaced: _renderReplaced);
    } else {
      nextRenderBoxModel =
          _createRenderLayout(isRepaintBoundary: isRepaintBoundary, previousRenderLayoutBox: _renderLayoutBox);
    }

    RenderBox? previousRenderBoxModel = renderBoxModel;
    if (nextRenderBoxModel != previousRenderBoxModel) {
      RenderObject? parentRenderObject;
      RenderBox? after;
      if (previousRenderBoxModel != null) {
        parentRenderObject = previousRenderBoxModel.parent;

        if (previousRenderBoxModel.parentData is ContainerParentDataMixin<RenderBox>) {
          after = (previousRenderBoxModel.parentData as ContainerParentDataMixin<RenderBox>).previousSibling;
        }

        RenderBoxModel.detachRenderBox(previousRenderBoxModel);

        if (parentRenderObject != null && parentRenderObject.attached) {
          RenderBoxModel.attachRenderBox(parentRenderObject, nextRenderBoxModel, after: after);
        }
      }
      renderBoxModel = nextRenderBoxModel;
      assert(renderBoxModel!.renderStyle.renderBoxModel == renderBoxModel);

      // Ensure that the event responder is bound.
      ensureEventResponderBound();
    }
  }

  RenderReplaced _createRenderReplaced({RenderReplaced? previousReplaced, bool isRepaintBoundary = false}) {
    RenderReplaced nextReplaced;

    if (previousReplaced == null) {
      if (isRepaintBoundary) {
        nextReplaced = RenderRepaintBoundaryReplaced(
          renderStyle,
        );
      } else {
        nextReplaced = RenderReplaced(
          renderStyle,
        );
      }
    } else {
      if (previousReplaced is RenderRepaintBoundaryReplaced) {
        if (isRepaintBoundary) {
          // RenderRepaintBoundaryReplaced --> RenderRepaintBoundaryReplaced
          nextReplaced = previousReplaced;
        } else {
          // RenderRepaintBoundaryReplaced --> RenderReplaced
          nextReplaced = previousReplaced.toReplaced();
        }
      } else {
        if (isRepaintBoundary) {
          // RenderReplaced --> RenderRepaintBoundaryReplaced
          nextReplaced = previousReplaced.toRepaintBoundaryReplaced();
        } else {
          // RenderReplaced --> RenderReplaced
          nextReplaced = previousReplaced;
        }
      }
    }
    return nextReplaced;
  }

  RenderWidget _createRenderWidget({RenderWidget? previousRenderWidget}) {
    RenderWidget nextReplaced;

    if (previousRenderWidget == null) {
      nextReplaced = RenderWidget(
        renderStyle: renderStyle,
      );
    } else {
      nextReplaced = previousRenderWidget;
    }
    return nextReplaced;
  }

  // Create renderLayoutBox if type changed and copy children if there has previous renderLayoutBox.
  RenderLayoutBox _createRenderLayout(
      {RenderLayoutBox? previousRenderLayoutBox, CSSRenderStyle? renderStyle, bool isRepaintBoundary = false}) {
    renderStyle = renderStyle ?? this.renderStyle;
    CSSDisplay display = this.renderStyle.display;
    RenderLayoutBox? nextRenderLayoutBox;

    if (display == CSSDisplay.flex || display == CSSDisplay.inlineFlex) {
      if (previousRenderLayoutBox == null) {
        if (isRepaintBoundary) {
          nextRenderLayoutBox = RenderRepaintBoundaryFlexLayout(
            renderStyle: renderStyle,
          );
        } else {
          nextRenderLayoutBox = RenderFlexLayout(
            renderStyle: renderStyle,
          );
        }
      } else if (previousRenderLayoutBox is RenderFlowLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlowLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlowLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlexLayout();
          } else {
            // RenderRepaintBoundaryFlowLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlowLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlexLayout();
          } else {
            // RenderFlowLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
          }
        }
      } else if (previousRenderLayoutBox is RenderFlexLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlexLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlexLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          } else {
            // RenderRepaintBoundaryFlexLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlexLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlexLayout();
          } else {
            // RenderFlexLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          }
        }
      } else if (previousRenderLayoutBox is RenderSliverListLayout) {
        // RenderSliverListLayout --> RenderFlexLayout
        nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
      }
    } else if (display == CSSDisplay.block ||
        display == CSSDisplay.none ||
        display == CSSDisplay.inline ||
        display == CSSDisplay.inlineBlock) {
      if (previousRenderLayoutBox == null) {
        if (isRepaintBoundary) {
          nextRenderLayoutBox = RenderRepaintBoundaryFlowLayout(
            renderStyle: renderStyle,
          );
        } else {
          nextRenderLayoutBox = RenderFlowLayout(
            renderStyle: renderStyle,
          );
        }
      } else if (previousRenderLayoutBox is RenderFlowLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlowLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlowLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          } else {
            // RenderRepaintBoundaryFlowLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlowLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlowLayout();
          } else {
            // RenderFlowLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          }
        }
      } else if (previousRenderLayoutBox is RenderFlexLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlexLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlexLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlowLayout();
          } else {
            // RenderRepaintBoundaryFlexLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlexLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlowLayout();
          } else {
            // RenderFlexLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
          }
        }
      } else if (previousRenderLayoutBox is RenderSliverListLayout) {
        // RenderSliverListLayout --> RenderFlowLayout
        nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
      }
    } else if (display == CSSDisplay.sliver) {
      if (previousRenderLayoutBox == null) {
        nextRenderLayoutBox = RenderSliverListLayout(
            renderStyle: renderStyle,
            manager: RenderSliverElementChildManager(this),
            onScroll: _handleScroll,
            currentView: ownerDocument.controller.ownerFlutterView);
      } else if (previousRenderLayoutBox is RenderFlowLayout || previousRenderLayoutBox is RenderFlexLayout) {
        //  RenderFlow/FlexLayout --> RenderSliverListLayout
        nextRenderLayoutBox =
            previousRenderLayoutBox.toSliverLayout(RenderSliverElementChildManager(this), _handleScroll);
      } else if (previousRenderLayoutBox is RenderSliverListLayout) {
        nextRenderLayoutBox = previousRenderLayoutBox;
      }
    } else {
      throw FlutterError('Not supported display type $display');
    }

    // Update scrolling content layout type.
    if (previousRenderLayoutBox != nextRenderLayoutBox && previousRenderLayoutBox?.renderScrollingContent != null) {
      updateScrollingContentBox();
    }

    return nextRenderLayoutBox!;
  }

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    // Init render box model.
    if (renderStyle.display != CSSDisplay.none) {
      createRenderer();
    }
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    // The node attach may affect the whitespace of the nextSibling and previousSibling text node so prev and next node require layout.
    renderBoxModel?.markAdjacentRenderParagraphNeedsLayout();

    // Reconfigure scrollable contents.
    bool needUpdateOverflowRenderBox = false;
    if (renderStyle.overflowX != CSSOverflowType.visible) {
      needUpdateOverflowRenderBox = true;
      updateRenderBoxModelWithOverflowX(_handleScroll);
    }
    if (renderStyle.overflowY != CSSOverflowType.visible) {
      needUpdateOverflowRenderBox = true;
      updateRenderBoxModelWithOverflowY(_handleScroll);
    }
    if (needUpdateOverflowRenderBox) {
      updateOverflowRenderBox();
    }
  }

  @override
  void willDetachRenderer() {
    super.willDetachRenderer();

    // Cancel running transition.
    renderStyle.cancelRunningTransition();

    // Cancel running animation.
    renderStyle.cancelRunningAnimation();

    RenderBoxModel? renderBoxModel = this.renderBoxModel;
    if (renderBoxModel != null) {
      // Remove all intersection change listeners.
      renderBoxModel.clearIntersectionChangeListeners();

      // Remove fixed children from root when element disposed.
      if (ownerDocument.viewport != null && renderStyle.position == CSSPositionType.fixed) {
        _removeFixedChild(renderBoxModel, ownerDocument.viewport!);
      }
      // Remove renderBox.
      renderBoxModel.detachFromContainingBlock();

      // Clear pointer listener
      clearEventResponder(renderBoxModel);

      // Remove scrollable
      renderBoxModel.disposeScrollable();
      disposeScrollable();
    }
  }

  BoundingClientRect getBoundingClientRect() => boundingClientRect;

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

  void _handleScroll(double scrollOffset, AxisDirection axisDirection) {
    if (renderBoxModel == null) return;
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
    RenderViewportBox? viewport = ownerDocument.viewport;
    // Only root element has fixed children.
    if (this == ownerDocument.documentElement && viewport != null) {
      for (RenderBoxModel child in viewport.fixedChildren) {
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
    RenderLayoutBox scrollContainer = renderBoxModel as RenderLayoutBox;
    for (RenderBoxModel stickyChild in scrollContainer.stickyChildren) {
      CSSPositionedLayout.applyStickyChildOffset(scrollContainer, stickyChild);
    }
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

    if (!isRendererAttached) return positionAbsoluteChildren;

    children.forEach((Element child) {
      if (!child.isRendererAttached) return;

      RenderBoxModel childRenderBoxModel = child.renderBoxModel!;
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

    if (!isRendererAttached) return directPositionAbsoluteChildren;

    RenderBox? child = (renderBoxModel as RenderLayoutBox).firstChild;

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

  void _updateRenderBoxModelWithPosition(CSSPositionType oldPosition) {
    CSSPositionType currentPosition = renderStyle.position;

    // No need to detach and reattach renderBoxMode when its position
    // changes between static and relative.
    if (!(oldPosition == CSSPositionType.static && currentPosition == CSSPositionType.relative) &&
        !(oldPosition == CSSPositionType.relative && currentPosition == CSSPositionType.static)) {
      RenderBoxModel _renderBoxModel = renderBoxModel!;
      // Remove fixed children before convert to non repaint boundary renderObject
      if (currentPosition != CSSPositionType.fixed) {
        _removeFixedChild(_renderBoxModel, ownerDocument.viewport!);
      }

      // Find the renderBox of its containing block.
      RenderLayoutBox? containingBlockRenderBox = getContainingBlockRenderBox();
      // Find the previous siblings to insert before renderBoxModel is detached.
      RenderBox? previousSibling = _renderBoxModel.getPreviousSibling();

      // // If previousSibling is a renderBox than represent a fixed element. Should skipped it util reach a renderBox in normal layout tree.
      while (previousSibling != null &&
          _isRenderBoxFixed(previousSibling, ownerDocument.viewport!) &&
          previousSibling is RenderBoxModel) {
        previousSibling = previousSibling.getPreviousSibling(followPlaceHolder: false);
      }

      // Detach renderBoxModel from its original parent.
      _renderBoxModel.detachFromContainingBlock();
      // Change renderBoxModel type in cases such as position changes to fixed which
      // need to create repaintBoundary.
      updateRenderBoxModel();
      // Original parent renderBox.
      RenderBox? parentRenderBox = parentNode!.renderer;
      // Attach renderBoxModel to its containing block.
      renderBoxModel!
          .attachToContainingBlock(containingBlockRenderBox, parent: parentRenderBox, after: previousSibling);

      // Add fixed children after convert to repaint boundary renderObject.
      if (currentPosition == CSSPositionType.fixed) {
        _addFixedChild(renderBoxModel!, ownerDocument.viewport!);
      }
    }

    // Need to change the containing block of nested position absolute children from its upper parent
    // to this element when element's position is changed from static to relative.
    if (oldPosition == CSSPositionType.static) {
      List<Element> positionAbsoluteChildren = findNestedPositionAbsoluteChildren();
      positionAbsoluteChildren.forEach((Element child) {
        child.addToContainingBlock();
      });

      // Need to change the containing block of direct position absolute children from this element
      // to its upper parent when element's position is changed from relative to static.
    } else if (currentPosition == CSSPositionType.static) {
      List<Element> directPositionAbsoluteChildren = findDirectPositionAbsoluteChildren();
      directPositionAbsoluteChildren.forEach((Element child) {
        child.addToContainingBlock();
      });
    }
  }

  PseudoElement _createOrUpdatePseudoElement(
      String contentValue, PseudoKind kind, PseudoElement? previousPseudoElement) {
    var pseudoValue = CSSPseudo.resolveContent(contentValue);

    bool shouldMutateBeforeElement = previousPseudoElement == null ||
        previousPseudoElement.firstChild == null ||
        ((previousPseudoElement.firstChild as TextNode).data == pseudoValue);

    previousPseudoElement ??=
        PseudoElement(kind, this, BindingContext(ownerDocument.controller.view, contextId!, allocateNewBindingObject()));
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
        final textNode = ownerDocument.createTextNode(pseudoValue.value);
        previousPseudoElement.appendChild(textNode);
      }
    }

    return previousPseudoElement;
  }

  void updateBeforePseudoElement() {
    // Add pseudo elements
    String? beforeContent = style.pseudoBeforeStyle?.getPropertyValue('content');
    if (beforeContent != null && beforeContent.isNotEmpty) {
      _beforeElement = _createOrUpdatePseudoElement(beforeContent, PseudoKind.kPseudoBefore, _beforeElement);
    } else if (_beforeElement != null) {
      removeChild(_beforeElement!);
    }
  }

  void updateAfterPseudoElement() {
    String? afterContent = style.pseudoAfterStyle?.getPropertyValue('content');
    if (afterContent != null && afterContent.isNotEmpty) {
      _afterElement = _createOrUpdatePseudoElement(afterContent, PseudoKind.kPseudoAfter, _afterElement);
    } else if (_afterElement != null) {
      removeChild(_afterElement!);
    }
  }

  // Add element to its containing block which includes the steps of detach the renderBoxModel
  // from its original parent and attach to its new containing block.
  void addToContainingBlock() {
    RenderBoxModel _renderBoxModel = renderBoxModel!;
    // Find the renderBox of its containing block.
    RenderLayoutBox? containingBlockRenderBox = getContainingBlockRenderBox();
    // Find the previous siblings to insert before renderBoxModel is detached.
    RenderBox? previousSibling = _renderBoxModel.getPreviousSibling();
    // Detach renderBoxModel from its original parent.
    _renderBoxModel.detachFromContainingBlock();
    // Original parent renderBox.
    RenderBox parentRenderBox = parentNode!.renderer!;
    // Attach renderBoxModel of to its containing block.
    _renderBoxModel.attachToContainingBlock(containingBlockRenderBox, parent: parentRenderBox, after: previousSibling);
  }

  void addChild(RenderBox child) {
    if (_renderLayoutBox != null) {
      RenderLayoutBox? scrollingContentBox = _renderLayoutBox!.renderScrollingContent;
      if (scrollingContentBox != null) {
        scrollingContentBox.add(child);
      } else {
        _renderLayoutBox!.add(child);
      }
    } else if (_renderReplaced != null) {
      _renderReplaced!.child = child;
    }
  }

  @override
  void dispose() async {
    renderStyle.detach();
    style.dispose();
    attributes.clear();
    disposeScrollable();
    _attributeProperties.clear();
    flutterWidget = null;
    flutterWidgetElement = null;
    ownerDocument.inactiveRenderObjects.add(renderer);
    _beforeElement?.dispose();
    _beforeElement = null;
    _afterElement?.dispose();
    _afterElement = null;
    super.dispose();
  }

  // Used for force update layout.
  void flushLayout() {
    if (isRendererAttached) {
      renderer!.owner!.flushLayout();
    }
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Node parent, {RenderBox? after}) {
    if (parentElement?.renderStyle.display == CSSDisplay.sliver) {
      // Sliver should not create renderer here, but need to trigger
      // render sliver list dynamical rebuild child by element tree.
      parentElement?._renderLayoutBox?.markNeedsLayout();
    } else {
      willAttachRenderer();
    }

    if (renderer != null && parent.renderer != null) {
      // If element attach WidgetElement, render object should be attach to render tree when mount.
      if (parent.renderObjectManagerType == RenderObjectManagerType.WEBF_NODE) {
        RenderBoxModel.attachRenderBox(parent.renderer!, renderer!, after: after);
        if (renderStyle.position != CSSPositionType.static) {
          _updateRenderBoxModelWithPosition(CSSPositionType.static);
        }
      }

      didAttachRenderer();
    }
  }

  static bool isRenderObjectOwnedByFlutterFramework(Element element) {
    return element is WidgetElement || element.managedByFlutterWidget;
  }

  /// Unmount [renderBoxModel].
  @override
  void unmountRenderObject(
      {bool deep = true, bool keepFixedAlive = false, bool dispose = true, bool fromFlutterWidget = false}) {
    /// If a node is managed by flutter framework, the ownership of this render object will transferred to Flutter framework.
    /// So we do nothing here.
    if (!fromFlutterWidget && managedByFlutterWidget) {
      return;
    }

    // Ignore the fixed element to unmount render object.
    // It's useful for sliver manager to unmount child render object, but excluding fixed elements.
    if (keepFixedAlive && renderStyle.position == CSSPositionType.fixed) {
      return;
    }

    willDetachRenderer();

    // Dispose all renderObject when deep.
    if (deep) {
      for (Node child in [...childNodes]) {
        child.unmountRenderObject(deep: deep, keepFixedAlive: keepFixedAlive);
      }
    }

    didDetachRenderer();
    if (dispose) {
      // RenderObjects could be owned by Flutter Widget Frameworks.
      if (!isRenderObjectOwnedByFlutterFramework(this)) {
        ownerDocument.inactiveRenderObjects.add(renderer);
      }
    }

    renderBoxModel = null;
  }

  @override
  void ensureChildAttached() {
    if (isRendererAttached || isRendererAttachedToParent(parentElement?.renderer)) {
      final box = renderBoxModel;
      if (box == null) return;
      for (Node child in childNodes) {
        RenderBox? after;
        if (box is RenderLayoutBox) {
          RenderLayoutBox? scrollingContentBox = box.renderScrollingContent;
          if (scrollingContentBox != null) {
            after = scrollingContentBox.lastChild;
          } else {
            after = box.lastChild;
          }
        } else if (box is RenderSVGContainer) {
          after = box.lastChild;
        }
        if (!child.isRendererAttached || !child.isRendererAttachedToParent(renderer)) {
          child.attachTo(this, after: after);
          child.ensureChildAttached();
        }
      }
    }
  }

  @override
  @mustCallSuper
  Node appendChild(Node child) {
    super.appendChild(child);
    // Update renderStyle tree.
    if (child is Element) {
      child.renderStyle.parent = renderStyle;
    }
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
    Node? originalPreviousSibling = referenceNode.previousSibling;
    Node? node = super.insertBefore(child, referenceNode);
    // Update renderStyle tree.
    if (child is Element) {
      child.renderStyle.parent = renderStyle;
    }

    return node;
  }

  @override
  @mustCallSuper
  Node? replaceChild(Node newNode, Node oldNode) {
    // Update renderStyle tree.
    if (newNode is Element) {
      newNode.renderStyle.parent = renderStyle;
    }
    if (oldNode is Element) {
      oldNode.renderStyle.parent = null;
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
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    _updateIDMap(null, oldID: _id);
    _updateNameMap(null, oldName: getAttribute(_NAME));
  }

  RenderLayoutBox? getContainingBlockRenderBox() {
    RenderLayoutBox? containingBlockRenderBox;
    CSSPositionType positionType = renderStyle.position;

    switch (positionType) {
      case CSSPositionType.relative:
      case CSSPositionType.static:
      case CSSPositionType.sticky:
        containingBlockRenderBox = parentNode!.renderer as RenderLayoutBox;
        break;
      case CSSPositionType.absolute:
        // If the element has 'position: absolute', the containing block is established by the nearest ancestor with
        // a 'position' of 'absolute', 'relative' or 'fixed', in the following way:
        //  1. In the case that the ancestor is an inline element, the containing block is the bounding box around
        //    the padding boxes of the first and the last inline boxes generated for that element.
        //    In CSS 2.1, if the inline element is split across multiple lines, the containing block is undefined.
        //  2. Otherwise, the containing block is formed by the padding edge of the ancestor.
        containingBlockRenderBox = _findContainingBlock(this, ownerDocument.documentElement!)?._renderLayoutBox;
        break;
      case CSSPositionType.fixed:
        // If the element has 'position: fixed', the containing block is established by the viewport
        // in the case of continuous media or the page area in the case of paged media.
        containingBlockRenderBox = ownerDocument.documentElement!._renderLayoutBox;
        break;
    }
    return containingBlockRenderBox;
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
    internalSetAttribute(qualifiedName, value);
    ElementAttributeProperty? propertyHandler = _attributeProperties[qualifiedName];
    if (propertyHandler != null && propertyHandler.setter != null) {
      propertyHandler.setter!(value);
    }
    setNeedsStyleRecalc(StyleChangeType.localStyleChange);
  }

  void internalSetAttribute(String qualifiedName, String value) {
    attributes[qualifiedName] = value;
    if (qualifiedName == 'class') {
      className = value;
      return;
    }
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

  void _updateRenderBoxModelWithDisplay() {
    CSSDisplay presentDisplay = renderStyle.display;

    if (parentElement == null || !parentElement!.isConnected) return;

    // Destroy renderer of element when display is changed to none.
    if (presentDisplay == CSSDisplay.none) {
      unmountRenderObject();
      return;
    }

    willAttachRenderer();

    // Update renderBoxModel.
    updateRenderBoxModel();
    // Attach renderBoxModel to parent if change from `display: none` to other values.
    if (!isRendererAttached && parentElement != null && parentElement!.isRendererAttached) {
      // If element attach WidgetElement, render object should be attach to render tree when mount.
      if (parentElement!.renderObjectManagerType == RenderObjectManagerType.WEBF_NODE) {
        RenderBoxModel _renderBoxModel = renderBoxModel!;
        // Find the renderBox of its containing block.
        RenderLayoutBox? containingBlockRenderBox = getContainingBlockRenderBox();
        // Find the previous siblings to insert before renderBoxModel is detached.
        RenderBox? preSibling = previousSibling?.renderer;
        // Original parent renderBox.
        RenderBox parentRenderBox = parentNode!.renderer!;
        _renderBoxModel.attachToContainingBlock(containingBlockRenderBox, parent: parentRenderBox, after: preSibling);
      }
    }

    didAttachRenderer();
  }

  void setRenderStyleProperty(String name, value) {
    dynamic oldValue;

    switch(name) {
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
        if (value != oldValue) {
          _updateRenderBoxModelWithDisplay();
        }
        break;
      case OVERFLOW_X:
        assert(oldValue != null);
        CSSOverflowType oldEffectiveOverflowY = oldValue;
        updateRenderBoxModel();
        updateRenderBoxModelWithOverflowX(_handleScroll);
        // Change overflowX may affect effectiveOverflowY.
        // https://drafts.csswg.org/css-overflow/#overflow-properties
        CSSOverflowType effectiveOverflowY = renderStyle.effectiveOverflowY;
        if (effectiveOverflowY != oldEffectiveOverflowY) {
          updateRenderBoxModelWithOverflowY(_handleScroll);
        }
        updateOverflowRenderBox();
        break;
      case OVERFLOW_Y:
        assert(oldValue != null);
        CSSOverflowType oldEffectiveOverflowX = oldValue;
        updateRenderBoxModel();
        updateRenderBoxModelWithOverflowY(_handleScroll);
        // Change overflowY may affect the effectiveOverflowX.
        // https://drafts.csswg.org/css-overflow/#overflow-properties
        CSSOverflowType effectiveOverflowX = renderStyle.effectiveOverflowX;
        if (effectiveOverflowX != oldEffectiveOverflowX) {
          updateRenderBoxModelWithOverflowX(_handleScroll);
        }
        updateOverflowRenderBox();
        break;
      case POSITION:
        assert(oldValue != null);
        CSSPositionType oldPosition = renderStyle.position;
        renderStyle.position = value;
        if (isRendererAttached) {
          _updateRenderBoxModelWithPosition(oldPosition);
        }
        break;
      case COLOR:
        _updateColorRelativePropertyWithColor(this);
        break;
      case FONT_SIZE:
        _updateFontRelativeLengthWithFontSize();
        break;
      case TRANSFORM:
        updateRenderBoxModel();
        break;
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

    if (renderBoxModel!.isDocumentRootBox) {
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
    if (defaultStyle.isNotEmpty) {
      defaultStyle.forEach((propertyName, value) {
        if (style.contains(propertyName) == false) {
          style.setProperty(propertyName, value);
        }
      });
    }
  }

  void _applyInlineStyle(CSSStyleDeclaration style) {
    if (inlineStyle.isNotEmpty) {
      inlineStyle.forEach((propertyName, value) {
        // Force inline style to be applied as important priority.
        style.setProperty(propertyName, value, isImportant: true);
      });
    }
  }

  void _applySheetStyle(CSSStyleDeclaration style) {
    CSSStyleDeclaration matchRule = _elementRuleCollector.collectionFromRuleSet(ownerDocument.ruleSet, this);
    style.union(matchRule);
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
      renderStyle.beforeRunningAnimation();
      if (renderBoxModel!.hasSize) {
        renderStyle.runAnimation();
      } else {
        SchedulerBinding.instance.addPostFrameCallback((callback) {
          renderStyle.runAnimation();
        });
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
    } else {
      style.setProperty(property, value, isImportant: true);
    }
    setNeedsStyleRecalc(StyleChangeType.inlineIndependentStyleChange);
  }

  void clearInlineStyle() {
    for (var key in inlineStyle.keys) {
      style.removeProperty(key, true);
    }
    inlineStyle.clear();
  }

  void _applyPseudoStyle(CSSStyleDeclaration style) {
    List<CSSStyleRule> pseudoRules = _elementRuleCollector.matchedPseudoRules(ownerDocument.ruleSet, this);
    style.handlePseudoRules(this, pseudoRules);
  }

  void applyStyle(CSSStyleDeclaration style) {
    // Apply default style.
    _applyDefaultStyle(style);
    // Init display from style directly cause renderStyle is not flushed yet.
    renderStyle.initDisplay(style);

    applyAttributeStyle(style);
    _applyInlineStyle(style);
    _applySheetStyle(style);
    _applyPseudoStyle(style);
  }

  void applyAttributeStyle(CSSStyleDeclaration style) {
    // Empty implement
    // Because attribute style is not recommend to use
    // But it's necessary for SVG.
  }

  RenderBox? get previousSiblingRenderer {
    Node? prev = previousSibling;
    while (prev != null) {
      if (prev is Element &&
          (prev.renderStyle.position == CSSPositionType.absolute ||
              prev.renderStyle.position == CSSPositionType.fixed)) {
        RenderPositionPlaceholder? positionHolder = (prev.renderer as RenderBoxModel).renderPositionPlaceholder;
        return positionHolder;
      }

      if (prev.renderer != null) return prev.renderer;

      prev = prev.previousSibling;
    }
    return null;
  }

  // Calculate the styles from stylesheet for this element and apply all pending styles into the renderObject.
  // When this phases was complete, it's ready to layout for this element's renderObject.
  bool recalculateStyle({bool rebuildNested = false, bool forceRecalculate = false}) {
    if (!kReleaseMode) {
      Timeline.startSync('$this recalculateStyle');
    }

    if (this is PseudoElement) {
      // Create and attach renderObject into the renderObject tree when style was ready.
      if (!isRendererAttached && !isRendererAttachedToParent(parentElement!.renderer)) {
        attachTo(parentElement!, after: previousSiblingRenderer);
        ensureChildAttached();
      }
      style.flushPendingProperties();
    } else {
      // Calculate styles from everywhere.
      CSSStyleDeclaration newStyle = CSSStyleDeclaration();
      applyStyle(newStyle);

      // Should take care about the inherited CSS property.
      var hasInheritedPendingProperty = false;
      if (style.merge(newStyle)) {
        hasInheritedPendingProperty = style.hasInheritedPendingProperty;
      }
      // Create and attach renderObject into the renderObject tree when style was ready.
      if (!isRendererAttached && !isRendererAttachedToParent(parentElement!.renderer)) {
        attachTo(parentElement!, after: previousSiblingRenderer);
      }
      // Apply all pending styles into the RenderStyle in renderObject.
      style.flushPendingProperties();

      // Calculate the sub-node's styles when necessary.
      if (rebuildNested || hasInheritedPendingProperty || styleChangeType == StyleChangeType.subtreeStyleChange) {
        childNodes.forEach((node) {
          if (node is CharacterData && !node.isRendererAttached && !node.isRendererAttachedToParent(renderer)) {
            node.attachTo(this, after: node.previousSibling?.renderer);
          } else if (node is Element) {
            node.recalculateStyle(rebuildNested: rebuildNested);
          }
        });
      }
    }
    clearStyleChangeType();

    if (!kReleaseMode) {
      Timeline.finishSync();
    }

    return true;
  }

  void recursiveFlushPendingStyle() {
    style.flushPendingProperties();
    children.forEach((child) {
      child.recursiveFlushPendingStyle();
    });
  }

  void _removeInlineStyle() {
    inlineStyle.forEach((String property, _) {
      _removeInlineStyleProperty(property);
    });
    inlineStyle.clear();
    setNeedsStyleRecalc(StyleChangeType.localStyleChange);
  }

  void _removeInlineStyleProperty(String property) {
    style.removeProperty(property, true);
  }

  // The Element.getBoundingClientRect() method returns a DOMRect object providing information
  // about the size of an element and its position relative to the viewport.
  // https://drafts.csswg.org/cssom-view/#dom-element-getboundingclientrect
  BoundingClientRect get boundingClientRect {
    BoundingClientRect boundingClientRect = BoundingClientRect.zero(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()));
    if (isRendererAttached) {
      ownerDocument.updateStyleIfNeeded();
      flushLayout();
      RenderBoxModel sizedBox = renderBoxModel!;
      // Force flush layout.
      if (!sizedBox.hasSize) {
        sizedBox.markNeedsLayout();
        sizedBox.owner!.flushLayout();
      }

      if (sizedBox.hasSize) {
        Offset offset = _getOffset(sizedBox, ancestor: ownerDocument.documentElement, excludeScrollOffset: true);
        Size size = sizedBox.size;
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
    ownerDocument.updateStyleIfNeeded();
    double offset = 0.0;
    if (!isRendererAttached) {
      return offset;
    }
    Offset relative = _getOffset(renderBoxModel!, ancestor: offsetParent);
    offset += relative.dx;
    return offset;
  }

  // The HTMLElement.offsetTop read-only property returns the distance of the outer border
  // of the current element relative to the inner border of the top of the offsetParent node.
  // https://drafts.csswg.org/cssom-view/#dom-htmlelement-offsettop
  double get offsetTop {
    ownerDocument.updateStyleIfNeeded();
    double offset = 0.0;
    if (!isRendererAttached) {
      return offset;
    }
    Offset relative = _getOffset(renderBoxModel!, ancestor: offsetParent);
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

  // Get the offset of current element relative to specified ancestor element.
  Offset _getOffset(RenderBoxModel renderBox, {Element? ancestor, bool excludeScrollOffset = false}) {
    // Need to flush layout to get correct size.
    flushLayout();

    // Returns (0, 0) when ancestor is null.
    if (ancestor == null || ancestor.renderBoxModel == null) {
      return Offset.zero;
    }
    return renderBox.getOffsetToAncestor(Offset.zero, ancestor.renderBoxModel!,
        excludeScrollOffset: excludeScrollOffset);
  }

  void click() {
    ownerDocument.updateStyleIfNeeded();
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

  Future<Uint8List> toBlob({double? devicePixelRatio}) {
    flushLayout();
    forceToRepaintBoundary = true;

    Completer<Uint8List> completer = Completer();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      Uint8List captured;
      RenderBoxModel _renderBoxModel = renderBoxModel!;

      if (_renderBoxModel.hasSize && _renderBoxModel.size.isEmpty) {
        // Return a blob with zero length.
        captured = Uint8List(0);
      } else {
        Image image = await _renderBoxModel.toImage(
            pixelRatio: devicePixelRatio ?? ownerDocument.controller.ownerFlutterView.devicePixelRatio);
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
      renderBoxModel?.debugShouldPaintOverlay = true;
    }
  }

  void debugHideHighlight() {
    if (isRendererAttached) {
      renderBoxModel?.debugShouldPaintOverlay = false;
    }
  }

  @override
  String toString() {
    return '$tagName Element($hashCode)';
  }

  // Create a new RenderLayoutBox for the scrolling content.
  RenderLayoutBox createScrollingContentLayout() {
    // FIXME: Create an empty renderStyle for do not share renderStyle with element.
    CSSRenderStyle scrollingContentRenderStyle = CSSRenderStyle(target: this);
    // Scrolling content layout need to be share the same display with its outer layout box.
    scrollingContentRenderStyle.display = renderStyle.display;
    RenderLayoutBox scrollingContentLayoutBox = _createRenderLayout(
      isRepaintBoundary: true,
      renderStyle: scrollingContentRenderStyle,
    );
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
    RenderStyle? style = renderBoxModel?.renderStyle;
    if (style == null) {
      recalculateStyle();
      style = renderBoxModel?.renderStyle;
    }
    return style;
  }
}

// https://www.w3.org/TR/css-position-3/#def-cb
Element? _findContainingBlock(Element child, Element viewportElement) {
  Element? parent = child.parentElement;

  while (parent != null) {
    bool isNonStatic = parent.renderStyle.position != CSSPositionType.static;
    bool hasTransform = parent.renderStyle.transform != null;
    bool isSliverItem = parent.renderStyle.parent?.display == CSSDisplay.sliver;
    // https://www.w3.org/TR/CSS2/visudet.html#containing-block-details
    if (parent == viewportElement || isNonStatic || hasTransform || isSliverItem) {
      break;
    }
    parent = parent.parentElement;
  }
  return parent;
}

// Cache fixed renderObject to root element
void _addFixedChild(RenderBoxModel childRenderBoxModel, RenderViewportBox viewport) {
  Set<RenderBoxModel> fixedChildren = viewport.fixedChildren;
  if (!fixedChildren.contains(childRenderBoxModel)) {
    fixedChildren.add(childRenderBoxModel);
  }
}

// Remove non fixed renderObject from root element
void _removeFixedChild(RenderBoxModel childRenderBoxModel, RenderViewportBox viewport) {
  Set<RenderBoxModel> fixedChildren = viewport.fixedChildren;
  if (fixedChildren.contains(childRenderBoxModel)) {
    fixedChildren.remove(childRenderBoxModel);
  }
}

bool _isRenderBoxFixed(RenderBox renderBox, RenderViewportBox viewport) {
  Set<RenderBoxModel> fixedChildren = viewport.fixedChildren;
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
