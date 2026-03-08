import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

/// A test-only custom element that reproduces the RenderWidget loose-height bug.
///
/// The hosted Flutter subtree uses a [Column] with the default
/// `mainAxisSize: MainAxisSize.max`. When RenderWidget incorrectly converts an
/// unbounded CSS block axis into a finite viewport/maxHeight constraint, the
/// Column expands to that height. When the constraint remains unbounded, the
/// Column shrink-wraps to its child.
class FlutterLooseHeightColumnHostElement extends WidgetElement {
  FlutterLooseHeightColumnHostElement(BindingContext? context) : super(context);

  @override
  String get tagName => 'FLUTTER-LOOSE-HEIGHT-COLUMN-HOST';

  @override
  WebFWidgetElementState createState() => FlutterLooseHeightColumnHostState(this);
}

class FlutterLooseHeightColumnHostState extends WebFWidgetElementState {
  FlutterLooseHeightColumnHostState(super.widgetElement);

  @override
  FlutterLooseHeightColumnHostElement get widgetElement =>
      super.widgetElement as FlutterLooseHeightColumnHostElement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {},
          child: WebFWidgetElementChild(
            child: WebFHTMLElement(
              tagName: 'DIV',
              controller: widgetElement.controller,
              parentElement: widgetElement,
              children: widgetElement.childNodes.toWidgetList(),
            ),
          ),
        ),
      ],
    );
  }
}
