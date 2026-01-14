import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

/// A test-only custom element that constrains its child with a bounded-but-not-tight
/// max height (0 <= h <= maxHeight).
///
/// This is used to reproduce a sizing bug where `height:auto` elements incorrectly
/// treated a bounded maxHeight as a definite CSS height when hosted under a RenderWidget.
class FlutterMaxHeightContainerElement extends WidgetElement {
  FlutterMaxHeightContainerElement(BindingContext? context) : super(context);

  @override
  String get tagName => 'FLUTTER-MAX-HEIGHT-CONTAINER';

  double _maxHeight = 260;

  double get maxHeight => _maxHeight;

  set maxHeight(dynamic value) {
    final double? next = value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
    if (next == null || !next.isFinite || next <= 0) return;
    if ((next - _maxHeight).abs() < 0.5) return;
    _maxHeight = next;
    state?.requestUpdateState();
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['max-height'] = ElementAttributeProperty(
      getter: () => _maxHeight.toString(),
      setter: (value) => maxHeight = value,
      deleter: () => maxHeight = 260,
    );
  }

  @override
  WebFWidgetElementState createState() => FlutterMaxHeightContainerState(this);
}

class FlutterMaxHeightContainerState extends WebFWidgetElementState {
  FlutterMaxHeightContainerState(super.widgetElement);

  @override
  FlutterMaxHeightContainerElement get widgetElement =>
      super.widgetElement as FlutterMaxHeightContainerElement;

  @override
  Widget build(BuildContext context) {
    // Only bound maxHeight (no minHeight), to produce non-tight constraints.
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widgetElement.maxHeight),
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'DIV',
          controller: widgetElement.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}
