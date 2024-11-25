import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

/// A simple widget to compute the total height of the childNodes of a given HTMLElement in a flow layout.
/// This is useful for building a WidgetElement whose height depends on the HTML/CSS layout height.
/// Note: The margin space between the childNodes is ignored because the parentData does not belong to WebF's RenderObjectModel.
class WebFChildNodeSize extends SingleChildRenderObjectWidget {
  WebFChildNodeSize({
    required this.ownerElement,
    super.child,
    super.key,
  });

  final dom.Element ownerElement;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderChildSize(ownerElement: ownerElement);
  }
}
