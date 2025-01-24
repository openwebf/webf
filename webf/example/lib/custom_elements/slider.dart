import 'package:flutter/widgets.dart';
import 'package:webf/webf.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class SliderElement extends WidgetElement {
  SliderElement(super.context);

  @override
  Map<String, dynamic> get defaultStyle => {
    'height': '100px',
    'width': '100%'
  };

  double value = 0;

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return FlutterSlider(
      values: [double.parse(getAttribute('val') ?? '0')],
      tooltip: null,
      max: double.parse(getAttribute('max') ?? '100'),
      min: double.parse(getAttribute('min') ?? '-100'),
      disabled: getAttribute('disabled') != 'true',
      onDragging: (handlerIndex, lowerValue, upperValue) {
        setState(() {
          value = lowerValue;
        });
        dispatchEvent(CustomEvent('change', detail: lowerValue));
      },
    );
  }
}