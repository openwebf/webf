/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/foundation.dart';
import 'package:webf/src/svg/rendering/text.dart';

const String WHITE_SPACE_CHAR = ' ';
const String NEW_LINE_CHAR = '\n';
const String RETURN_CHAR = '\r';
const String TAB_CHAR = '\t';

typedef EveryRenderTextBoxHandler = void Function(RenderTextBox? textBox);

class TextNode extends CharacterData {
  static const String NORMAL_SPACE = '\u0020';

  TextNode(this._data, [BindingContext? context]) : super(NodeType.TEXT_NODE, context);

  // Must be existed after text node is attached, and all text update will after text attached.
  RenderTextBox? _domRenderTextBox;
  final Map<flutter.Element, RenderTextBox?> _widgetRenderObjects = {};

  void everyRenderTextBox(EveryRenderTextBoxHandler handler) {
    if (managedByFlutterWidget) {
      for (var textNode in _widgetRenderObjects.values) {
        handler(textNode);
      }
    } else {
      handler(_domRenderTextBox);
    }
  }


  // The text string.
  String _data = '';

  String get data => _data;

  set data(String newData) {
    String oldData = data;
    if (oldData == newData) return;

    _data = newData;

    // Empty string of textNode should not attach to render tree.
    if (oldData.isNotEmpty && newData.isEmpty) {
      _detachRenderTextBox();
    } else if (oldData.isEmpty && newData.isNotEmpty) {
      attachTo(parentElement!);
    } else {
      _applyTextStyle();

      // To replace data of node node with offset offset, count count, and data data, run step 12 from the spec:
      // 12. If node’s parent is non-null, then run the children changed steps for node’s parent.
      // https://dom.spec.whatwg.org/#concept-cd-replace
      parentNode
          ?.childrenChanged(ChildrenChange.forInsertion(this, previousSibling, nextSibling, ChildrenChangeSource.API));
    }
  }

  @override
  String get nodeName => '#text';

  @override
  RenderBox? getRenderer([flutter.Element? flutterWidgetElement]) {
    if (managedByFlutterWidget) {
      return _widgetRenderObjects[flutterWidgetElement];
    }
    return _domRenderTextBox;
  }

  @override
  bool get isRendererAttached {
    if (managedByFlutterWidget) {
      for (var renderText in _widgetRenderObjects.values) {
        if (renderText?.attached == true) return true;
      }
      return false;
    }

    return _domRenderTextBox?.attached == true;
  }

  @override
  bool get isRendererAttachedToSegmentTree {
    if (managedByFlutterWidget) {
      for (var renderText in _widgetRenderObjects.values) {
        if (renderText?.parent != null) return true;
      }
      return false;
    }

    return _domRenderTextBox?.parent != null;
  }

  void _applyTextStyle() {
    if (isRendererAttachedToSegmentTree) {
      Element _parentElement = parentElement!;

      everyRenderTextBox((textNode) {
        // The parentNode must be an element.
        textNode!.renderStyle = _parentElement.renderStyle;
        textNode.data = data;


        WebFRenderParagraph renderParagraph = textNode.child as WebFRenderParagraph;
        renderParagraph.markNeedsLayout();

        RenderStyle parentElementRenderStyle = _parentElement.renderStyle;

        if (parentElementRenderStyle.isSelfRenderLayoutBox()) {
          parentElementRenderStyle = parentElementRenderStyle.isScrollingContentBox()
              ? parentElementRenderStyle.getScrollContentRenderStyle()!
              : parentElementRenderStyle;
        }
        _setTextSizeType(textNode, parentElementRenderStyle.widthSizeType(), parentElementRenderStyle.heightSizeType());
      });
    }
  }

  void _setTextSizeType(RenderTextBox renderTextBox, BoxSizeType width, BoxSizeType height) {
    // Migrate element's size type to RenderTextBox.
    renderTextBox.widthSizeType = width;
    renderTextBox.heightSizeType = height;
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, {flutter.Element? flutterWidgetElement, Node? previousSibling}) {
    // Empty string of TextNode should not attach to render tree.
    if (_data.isEmpty) return;

    createRenderer(flutterWidgetElement);

    // If element attach WidgetElement, render object should be attach to render tree when mount.
    if (parent.renderObjectManagerType == RenderObjectManagerType.WEBF_NODE && parent.renderStyle.hasRenderBox()) {
      RenderBox renderBox = getRenderer(flutterWidgetElement)!;

      RenderBox? afterRenderObject = Node.findMostClosedSiblings(previousSibling, flutterWidgetElement: flutterWidgetElement);

      RenderBoxModel.attachRenderBox(parent.getRenderer(flutterWidgetElement)!, renderBox, after: afterRenderObject);
    }

    _applyTextStyle();
  }

  // Detach renderObject of current node from parent
  void _detachRenderTextBox() {
    if (isRendererAttachedToSegmentTree && !managedByFlutterWidget) {
      RenderTextBox renderTextBox = _domRenderTextBox!;
      RenderBox parent = renderTextBox.parent as RenderBox;
      if (parent is ContainerRenderObjectMixin) {
        (parent as ContainerRenderObjectMixin).remove(renderTextBox);
      } else if (parent is RenderObjectWithChildMixin<RenderBox>) {
        (parent as RenderObjectWithChildMixin).child = null;
      }
    }
  }

  @override
  String toString() {
    return 'TextNode($data)';
  }

  // Detach renderObject of current node from parent
  @override
  void unmountRenderObject({bool keepFixedAlive = false, flutter.Element? flutterWidgetElement}) {
    /// If a node is managed by flutter framework, the ownership of this render object will transferred to Flutter framework.
    /// So we do nothing here.
    if (managedByFlutterWidget) {
      _widgetRenderObjects.remove(flutterWidgetElement);
      return;
    }
    _detachRenderTextBox();
    _domRenderTextBox = null;
  }

  @override
  RenderBox createRenderer([flutter.Element? flutterWidgetElement]) {
    RenderTextBox textBox = RenderTextBox(data, renderStyle: parentElement!.renderStyle);
    if (managedByFlutterWidget) {
      _widgetRenderObjects[flutterWidgetElement!] = textBox;
    } else {
      _domRenderTextBox = textBox;
    }
    return textBox;
  }

  @override
  Future<void> dispose() async {
    unmountRenderObject();
    super.dispose();
  }
}
