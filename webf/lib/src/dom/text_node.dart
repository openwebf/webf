/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/bridge.dart';


const String WHITE_SPACE_CHAR = ' ';
const String NEW_LINE_CHAR = '\n';
const String RETURN_CHAR = '\r';
const String TAB_CHAR = '\t';

typedef EveryRenderTextBoxHandler = void Function(RenderTextBox? textBox);

class TextNode extends CharacterData {
  static const String NORMAL_SPACE = '\u0020';

  TextNode(this._data, [BindingContext? context]) : super(NodeType.TEXT_NODE, context);

  final flutter.Key key = flutter.UniqueKey();

  @override
  flutter.Widget toWidget({Key? key}) {
    return TextNodeAdapter(this, key: this.key);
  }

  final Set<_TextNodeAdapterElement> _attachedFlutterWidgetElements = {};

  void everyRenderTextBox(EveryRenderTextBoxHandler handler) {
    if (managedByFlutterWidget) {
      for (var textNode in _attachedFlutterWidgetElements) {
        handler(textNode.renderObject);
      }
    }
  }

  // The text string.
  String _data = '';

  String get data => _data;

  set data(String newData) {
    String oldData = data;
    if (oldData == newData) return;

    _data = newData;

    if (managedByFlutterWidget) {
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
  RenderBox? get attachedRenderer {
    if (managedByFlutterWidget) {
      return _attachedFlutterWidgetElements
          .firstWhereOrNull((flutterElement) => flutterElement.mounted)
          ?.renderObject;
    }
    return null;
  }

  @override
  bool get isRendererAttached {
    return attachedRenderer?.attached == true;
  }

  @override
  bool get isRendererAttachedToSegmentTree {
    if (managedByFlutterWidget) {
      for (var renderText in _attachedFlutterWidgetElements) {
        if (renderText.mounted) return true;
      }
      return false;
    }

    return false;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('data', data));
  }

  void _applyTextStyle() {
    if (isRendererAttachedToSegmentTree) {
      Element _parentElement = parentElement!;

      everyRenderTextBox((textNode) {
        if (textNode == null) return;

        // The parentNode must be an element.
        textNode.renderStyle = _parentElement.renderStyle;
        textNode.data = data;

        WebFRenderParagraph renderParagraph = textNode.child as WebFRenderParagraph;
        renderParagraph.markNeedsLayout();

        RenderStyle parentElementRenderStyle = _parentElement.renderStyle;

        _setTextSizeType(textNode, parentElementRenderStyle.widthSizeType(), parentElementRenderStyle.heightSizeType());
      });
    }
  }

  void _setTextSizeType(RenderTextBox renderTextBox, BoxSizeType width, BoxSizeType height) {
    // Migrate element's size type to RenderTextBox.
    renderTextBox.widthSizeType = width;
    renderTextBox.heightSizeType = height;
  }

  @override
  String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'TextNode($data)';
  }

  @override
  RenderBox createRenderer([flutter.Element? flutterWidgetElement]) {
    RenderTextBox textBox = RenderTextBox(data, renderStyle: parentElement!.renderStyle);
    _attachedFlutterWidgetElements.add(flutterWidgetElement as _TextNodeAdapterElement);

    return textBox;
  }

  @override
  void willDetachRenderer(flutter.RenderObjectElement? flutterWidgetElement) {
    super.willDetachRenderer(flutterWidgetElement);
    _attachedFlutterWidgetElements.remove(flutterWidgetElement);
  }

  @override
  Future<void> dispose() async {
    _attachedFlutterWidgetElements.clear();
    super.dispose();
  }
}

// Flutter adapters, controlled the renderObject by flutter frameworks when wrapped TextNode into any WidgetElements.
class TextNodeAdapter extends flutter.SingleChildRenderObjectWidget {
  final TextNode textNode;

  TextNodeAdapter(this.textNode, {Key? key}) : super(key: key) {
    textNode.managedByFlutterWidget = true;
  }

  @override
  _TextNodeAdapterElement createElement() {
    return _TextNodeAdapterElement(this);
  }

  @override
  RenderObject createRenderObject(flutter.BuildContext context) {
    return textNode.createRenderer(context as flutter.RenderObjectElement);
  }

  @override
  String toStringShort() {
    return '"${textNode.data}"';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('data', AttributedString(textNode.data)));
  }
}

class _TextNodeAdapterElement extends flutter.SingleChildRenderObjectElement {
  _TextNodeAdapterElement(TextNodeAdapter widget) : super(widget);

  @override
  RenderTextBox get renderObject => super.renderObject as RenderTextBox;

  @override
  TextNodeAdapter get widget => super.widget as TextNodeAdapter;

  @override
  void unmount() {
    TextNode textNode = widget.textNode;
    textNode.willDetachRenderer(this);
    super.unmount();
    textNode.didDetachRenderer(this);
  }
}
