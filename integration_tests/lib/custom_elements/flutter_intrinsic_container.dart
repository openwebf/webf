import 'package:webf/webf.dart';
import 'package:flutter/material.dart';

/// A widget element that adopts the intrinsic size of its HTML children.
///
/// This wraps a `WebFHTMLElement` with both `IntrinsicWidth` and
/// `IntrinsicHeight` so Flutter queries the WebF render object's
/// intrinsic sizing protocol for layout.
class FlutterIntrinsicContainer extends WidgetElement {
  FlutterIntrinsicContainer(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => {
    // Make the element shrink to its content by default.
    'display': 'inline-block'
  };

  @override
  WebFWidgetElementState createState() => _FlutterIntrinsicContainerState(this);
}

class _FlutterIntrinsicContainerState extends WebFWidgetElementState {
  _FlutterIntrinsicContainerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // HTML subtree that determines intrinsic size based on its children.
    final htmlRoot = WebFHTMLElement(
      tagName: 'DIV',
      inlineStyle: const {
        'display': 'inline-block'
      },
      children: widgetElement.childNodes.toWidgetList(),
      controller: widgetElement.ownerDocument.controller,
      parentElement: widgetElement,
    );

    // Mix native Flutter widgets with the HTML subtree. We choose
    // fixed-size Flutter indicators to make intrinsic sizing predictable
    // and testable, while keeping the HTML side unconstrained.
    const double indicator = 10.0; // fixed square size
    const double gap = 8.0; // horizontal spacing on both sides

    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left indicator
            SizedBox(
              width: indicator,
              height: indicator,
              child: ColoredBox(color: Color(0xFF00AAFF)),
            ),
            const SizedBox(width: gap),
            // HTML content
            htmlRoot,
            const SizedBox(width: gap),
            // Right indicator
            SizedBox(
              width: indicator,
              height: indicator,
              child: ColoredBox(color: Color(0xFFFFAA00)),
            ),
          ],
        ),
      ),
    );
  }
}
