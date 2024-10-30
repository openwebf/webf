import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

class WebFHTMLElement extends MultiChildRenderObjectWidget {
  final String tagName;
  final Map<String, String>? inlineStyle;
  WebFHTMLElement({
    required this.tagName,
    Key? key,
    required List<Widget> children,
    this.inlineStyle,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }
    _WebFElement webfElement = context as _WebFElement;
    WebFContextInheritElement? webfContext = context.getElementForInheritedWidgetOfExactType<WebFContext>() as WebFContextInheritElement;
    context.htmlElement = dom.createElement(tagName, BindingContext(webfContext.controller!.view, webfContext.controller!.view.contextId, allocateNewBindingObject()));
    RenderObject renderObject = webfElement.htmlElement!.createRenderer();

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
    }

    return renderObject;
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return _WebFElement(this);
  }
}

class _WebFElement extends MultiChildRenderObjectElement {
  dom.Element? htmlElement;

  _WebFElement(WebFHTMLElement widget): super(widget);

  @override
  WebFHTMLElement get widget => super.widget as WebFHTMLElement;

  void fullFillInlineStyle(Map<String, String> inlineStyle) {
    inlineStyle.forEach((key, value) {
      htmlElement!.setInlineStyle(key, value);
    });
    htmlElement!.recalculateStyle();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }
    super.mount(parent, newSlot);
    htmlElement!.managedByFlutterWidget = true;
    htmlElement!.createdByFlutterWidget = true;

    dom.Element? parentElement = findClosestAncestorHTMLElement(this);

    if (parentElement != null) {
      parentElement.appendChild(htmlElement!);

      if (parentElement is RouterLinkElement) {
        // Migrate previous childNodes into RouterLinkElement.
        parentElement.cachedChildNodes.forEach((node) {
          htmlElement!.appendChild(node);
        });
      }

      if (widget.inlineStyle != null) {
        fullFillInlineStyle(widget.inlineStyle!);
      }

      htmlElement!.ensureChildAttached();
    }

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
    }
  }

  dom.Element? findClosestAncestorHTMLElement(Element? parent) {
    if (parent == null) return null;
    dom.Element? target;
    parent.visitAncestorElements((Element element) {
      if (element is WebFWidgetElementElement) {
        target = element.widget.widgetElement;
        return false;
      } else if (element is _WebFElement) {
        target = element.htmlElement;
        return false;
      } else if (element is WebFHTMLElementToFlutterElementAdaptor) {
        target = element.webFElement;
        return false;
      }
      return true;
    });
    return target;
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    super.unmount();
    htmlElement!.unmountRenderObject(dispose: false, fromFlutterWidget: true);
  }
}
