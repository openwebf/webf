/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' show RenderObjectElement;
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/foundation.dart';
import 'package:webf/src/svg/rendering/text.dart';

const String WHITE_SPACE_CHAR = ' ';
const String NEW_LINE_CHAR = '\n';
const String RETURN_CHAR = '\r';
const String TAB_CHAR = '\t';

class TextNode extends CharacterData {
  static const String NORMAL_SPACE = '\u0020';

  TextNode(this._data, [BindingContext? context]) : super(NodeType.TEXT_NODE, context);

  // Must be existed after text node is attached, and all text update will after text attached.
  RenderTextBox? _domRenderTextBox;
  final Map<RenderObjectElement, RenderTextBox?> _widgetRenderObjects = {};

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
      parentNode?.childrenChanged(ChildrenChange.forInsertion(this, previousSibling, nextSibling, ChildrenChangeSource.API));
    }
  }

  @override
  String get nodeName => '#text';

  @override
  RenderTextBox? get renderer {
    if (managedByFlutterWidget) {
      return _widgetRenderObjects[flutterWidgetElement!];
    }
    return _domRenderTextBox;
  }

  set renderer(RenderTextBox? value) {
    if (managedByFlutterWidget) {
      _widgetRenderObjects[flutterWidgetElement!] = value;
    } else {
      _domRenderTextBox = value;
    }
  }

  void _applyTextStyle() {
    if (isRendererAttachedToSegmentTree) {
      Element _parentElement = parentElement!;

      // The parentNode must be an element.
      renderer!.renderStyle = _parentElement.renderStyle;
      renderer!.data = data;

      WebFRenderParagraph renderParagraph = renderer!.child as WebFRenderParagraph;
      renderParagraph.markNeedsLayout();

      RenderBoxModel parentRenderLayoutBox = _parentElement.renderBoxModel!;
      if (parentRenderLayoutBox is RenderLayoutBox) {
        parentRenderLayoutBox = parentRenderLayoutBox.renderScrollingContent ?? parentRenderLayoutBox;
      }
      _setTextSizeType(parentRenderLayoutBox.widthSizeType, parentRenderLayoutBox.heightSizeType);
    }
  }

  void _setTextSizeType(BoxSizeType width, BoxSizeType height) {
    // Migrate element's size type to RenderTextBox.
    renderer!.widthSizeType = width;
    renderer!.heightSizeType = height;
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, {RenderBox? after}) {
    // Empty string of TextNode should not attach to render tree.
    if (_data.isEmpty) return;

    createRenderer();

    // If element attach WidgetElement, render object should be attach to render tree when mount.
    if (parent.renderObjectManagerType == RenderObjectManagerType.WEBF_NODE && parent.renderBoxModel != null) {
      ContainerRenderObjectMixin? parentRenderBox;
      if (parent.renderer is RenderLayoutBox) {
        final layoutBox = parent.renderBoxModel as RenderLayoutBox;
        parentRenderBox = layoutBox.renderScrollingContent ?? layoutBox;
      } else if (parent.renderer is RenderSVGText) {
        (parent.renderer as RenderSVGText).child = renderer;
      }
      if (parentRenderBox != null) {
        parentRenderBox.insert(renderer!, after: after);
      }
    }

    _applyTextStyle();
  }

  // Detach renderObject of current node from parent
  void _detachRenderTextBox() {
    if (isRendererAttachedToSegmentTree) {
      RenderTextBox renderTextBox = renderer!;
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
  void unmountRenderObject({bool deep = false, bool keepFixedAlive = false}) {
    /// If a node is managed by flutter framework, the ownership of this render object will transferred to Flutter framework.
    /// So we do nothing here.
    if (managedByFlutterWidget) {
      return;
    }
    _detachRenderTextBox();
    renderer = null;
  }

  @override
  RenderBox createRenderer() {
    RenderTextBox textBox = RenderTextBox(data, renderStyle: parentElement!.renderStyle);
    if (!managedByFlutterWidget) {
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
