import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';

import 'flutter_button.dart';
import 'flutter_image.dart';
import 'flutter_listview.dart';
import 'flutter_text.dart';
import 'flutter_container.dart';
import 'sample_element.dart';
import 'flutter_layout_box.dart';
import 'flutter_swiper.dart';
import 'multiple_rendering.dart';

void defineWebFCustomElements() {
  WebF.defineCustomElement('flutter-button',
      (BindingContext? context) => FlutterButtonElement(context));
  WebF.defineCustomElement(
      'flutter-listview', (context) => FlutterListViewElement(context));
  WebF.defineCustomElement(
      'sample-element', (context) => SampleElement(context));
  WebF.defineCustomElement('flutter-container', (context) => FlutterContainerElement(context));
  WebF.defineCustomElement('flutter-text', (BindingContext? context) {
    return TextWidgetElement(context);
  });
  WebF.defineCustomElement('flutter-layout-box', (context) => FlutterLayoutBox(context));
  WebF.defineCustomElement('flutter-asset-image', (BindingContext? context) {
    return ImageWidgetElement(context);
  });
  WebF.defineCustomElement('flutter-swiper', (context) => SwiperElement(context));
  WebF.defineCustomElement('multiple-rendering', (context) => MultipleRenderElement(context));
}
