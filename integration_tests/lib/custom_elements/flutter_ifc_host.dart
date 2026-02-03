import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

const Map<String, dynamic> _flutterIFCHostDefaultStyle = {
  'display': 'block',
  // Keep size style unset by default; specs can decide whether to constrain.
};

/// A WidgetElement that mounts its first *element* child directly under RenderWidget.
///
/// This is useful for exercising WebF layout behavior when an inline element
/// (e.g. <span>) is not inside any ancestor IFC, which can happen under RenderWidget.
class FlutterIFCHostElement extends WidgetElement {
  FlutterIFCHostElement(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _flutterIFCHostDefaultStyle;

  @override
  WebFWidgetElementState createState() => FlutterIFCHostElementState(this);
}

class FlutterIFCHostElementState extends WebFWidgetElementState {
  FlutterIFCHostElementState(super.widgetElement);

  FlutterIFCHostElement get host => widgetElement as FlutterIFCHostElement;

  @override
  Widget build(BuildContext context) {
    dom.Element? firstElementChild;
    for (final node in host.childNodes) {
      if (node is dom.Element) {
        firstElementChild = node;
        break;
      }
    }

    return WebFWidgetElementChild(
      child: firstElementChild != null ? firstElementChild.toWidget() : const SizedBox.shrink(),
    );
  }
}
