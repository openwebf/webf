import 'package:flutter/widgets.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/dom.dart' show ElementAttributeProperty;
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

class FlutterFixedHeightSlotElement extends WidgetElement {
  FlutterFixedHeightSlotElement(BindingContext? context) : super(context) {
    final initialWidth = getAttribute('width');
    if (initialWidth != null) {
      width = initialWidth;
    }
    final initialHeight = getAttribute('height');
    if (initialHeight != null) {
      height = initialHeight;
    }
  }

  @override
  String get tagName => 'FLUTTER-FIXED-HEIGHT-SLOT';

  double _width = 402;
  double _height = 636;

  double get width => _width;
  set width(dynamic value) {
    final parsed = _coerceDouble(value);
    if (parsed != null) {
      _width = parsed;
      state?.requestUpdateState();
    }
  }

  double get height => _height;
  set height(dynamic value) {
    final parsed = _coerceDouble(value);
    if (parsed != null) {
      _height = parsed;
      state?.requestUpdateState();
    }
  }

  @override
  Map<String, dynamic> get defaultStyle => {'display': 'block'};

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['width'] = ElementAttributeProperty(
      setter: (value) => width = value,
    );
    attributes['height'] = ElementAttributeProperty(
      setter: (value) => height = value,
    );
  }

  @override
  FlutterFixedHeightSlotState? get state =>
      super.state as FlutterFixedHeightSlotState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterFixedHeightSlotState(this);
  }
}

class FlutterFixedHeightSlotState extends WebFWidgetElementState {
  FlutterFixedHeightSlotState(super.widgetElement);

  @override
  FlutterFixedHeightSlotElement get widgetElement =>
      super.widgetElement as FlutterFixedHeightSlotElement;

  @override
  Widget build(BuildContext context) {
    final dom.Element? slotElement = widgetElement.childNodes
        .whereType<dom.Element>()
        .cast<dom.Element?>()
        .firstWhere((_) => true, orElse: () => null);

    final Widget child = slotElement?.toWidget() ?? const SizedBox.shrink();

    return SizedBox(
      width: widgetElement.width,
      height: widgetElement.height,
      child: WebFWidgetElementChild(
        child: child,
      ),
    );
  }
}

double? _coerceDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
