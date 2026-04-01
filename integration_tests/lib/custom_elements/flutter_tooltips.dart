import 'package:flutter/material.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

class FlutterToolTipsElement extends WidgetElement {
  FlutterToolTipsElement(super.context);

  @override
  WebFWidgetElementState createState() => FlutterToolTipsElementState(this);
}

class FlutterToolTipsElementState extends WebFWidgetElementState {
  FlutterToolTipsElementState(super.widgetElement);

  FlutterToolTipsElement get tooltipsElement =>
      widgetElement as FlutterToolTipsElement;

  @override
  Widget build(BuildContext context) {
    dom.Element? firstElementChild;
    for (final dom.Node node in tooltipsElement.childNodes) {
      if (node is dom.Element) {
        firstElementChild = node;
        break;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widgetElement.dispatchEvent(Event('click', bubbles: true));
      },
      child: firstElementChild != null
          ? WebFWidgetElementChild(child: firstElementChild.toWidget())
          : const SizedBox.shrink(),
    );
  }
}

class WebFTestAutoSizeTextElement extends WidgetElement {
  WebFTestAutoSizeTextElement(super.context);

  @override
  WebFWidgetElementState createState() => WebFTestAutoSizeTextElementState(this);
}

class WebFTestAutoSizeTextElementState extends WebFWidgetElementState {
  WebFTestAutoSizeTextElementState(super.widgetElement);

  WebFTestAutoSizeTextElement get autoSizeTextElement =>
      widgetElement as WebFTestAutoSizeTextElement;

  @override
  Widget build(BuildContext context) {
    final String text = autoSizeTextElement.getAttribute('text') ?? '';
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            height: 1,
          ),
        );
      },
    );
  }
}
