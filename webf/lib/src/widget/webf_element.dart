import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;

class WebFElement extends MultiChildRenderObjectWidget {
  final dom.Element element;

  WebFElement({
    required String tagName,
    required dom.Element parentElement, Key? key,
    required List<Widget> children,
    Map<String, String>? inlineStyle
  })
      : element = dom.createElement(tagName),
        super(key: key, children: children) {
    element.createRenderer();
    element.managedByFlutterWidget = true;
    element.createdByFlutterWidget = true;
    element.ownerDocument = parentElement.ownerDocument;
    parentElement.appendChild(element);

    if (inlineStyle != null) {
      fullFillInlineStyle(inlineStyle);
    }
  }

  void fullFillInlineStyle(Map<String, String> inlineStyle) {
    inlineStyle.forEach((key, value) {
      element.setInlineStyle(key, value);
    });
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return element.renderer!;
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return _WebFElement(this);
  }
}

class _WebFElement extends MultiChildRenderObjectElement {
  _WebFElement(super.widget);

  @override
  WebFElement get widget => super.widget as WebFElement;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    widget.element.ensureChildAttached();
    widget.element.applyStyle(widget.element.style);
    // Flush pending style before child attached.
    widget.element.style.flushPendingProperties();
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    dom.Element element = widget.element;
    super.unmount();
    element.unmountRenderObject(dispose: false, fromFlutterWidget: true);
  }
}
