import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

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
