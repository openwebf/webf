import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

/// A WidgetElement used as modal popup content for reproducing width resolution bugs.
///
/// This element renders its children through a nested WebF subtree so it participates
/// in WebF's box model sizing (RenderWidget) while being hosted inside a Flutter
/// modal popup (portal subtree).
class FlutterPortalPopupItem extends WidgetElement {
  FlutterPortalPopupItem(super.context);

  @override
  Map<String, dynamic> get defaultStyle => const {
        'display': 'block',
      };

  @override
  WebFWidgetElementState createState() => FlutterPortalPopupItemState(this);
}

class FlutterPortalPopupItemState extends WebFWidgetElementState {
  FlutterPortalPopupItemState(super.widgetElement);

  @override
  FlutterPortalPopupItem get widgetElement => super.widgetElement as FlutterPortalPopupItem;

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'DIV',
        controller: widgetElement.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}

