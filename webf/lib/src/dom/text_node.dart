/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/bridge.dart';
import 'package:webf/src/rendering/text.dart';

typedef EveryRenderTextBoxHandler = void Function(RenderTextBox? textBox);

class TextNode extends CharacterData {
  TextNode(this._data, [BindingContext? context]) : super(NodeType.TEXT_NODE, context);

  final flutter.Key key = flutter.UniqueKey();

  @override
  flutter.Widget toWidget({Key? key}) {
    return TextNodeAdapter(this, _data, key: this.key);
  }

  final Set<TextNodeAdapterElement> _attachedFlutterWidgetElements = {};

  // The text string.
  String _data = '';

  String get data => _data;

  set data(String newData) {
    String oldData = data;
    if (oldData == newData) return;

    _data = newData;


    // Notify attached widgets to rebuild
    for (var element in _attachedFlutterWidgetElements) {
      if (element.mounted) {
        element.markNeedsBuild();
      }
    }

    // Notify parent about text content changes to allow elements (e.g., textarea)
    // to react to CharacterData mutations.
    if (parentNode != null) {
      parentNode!.childrenChanged(ChildrenChange(
        type: ChildrenChangeType.TEXT_CHANGE,
        byParser: ChildrenChangeSource.API,
        affectsElements: ChildrenChangeAffectsElements.NO,
        siblingChanged: this,
        oldText: oldData,
      ));
    }
  }

  @override
  String get nodeName => '#text';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('data', data));
  }

  @override
  String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'TextNode($data)';
  }

  @override
  RenderBox createRenderer([flutter.Element? flutterWidgetElement]) {
    RenderTextBox textBox = RenderTextBox(data, renderStyle: parentElement!.renderStyle);
    _attachedFlutterWidgetElements.add(flutterWidgetElement as TextNodeAdapterElement);

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

  String get data => textNode.data;

  const TextNodeAdapter(this.textNode, String initialData, {super.key});

  @override
  TextNodeAdapterElement createElement() {
    return TextNodeAdapterElement(this);
  }

  @override
  RenderObject createRenderObject(flutter.BuildContext context) {
    RenderTextBox renderTextBoxNext = textNode.createRenderer(context as flutter.RenderObjectElement) as RenderTextBox;
    renderTextBoxNext.data = data;
    return renderTextBoxNext;
  }

  @override
  void updateRenderObject(flutter.BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
    (renderObject as RenderTextBox).data = data;
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

class TextNodeAdapterElement extends flutter.SingleChildRenderObjectElement {
  TextNodeAdapterElement(TextNodeAdapter super.widget);

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
