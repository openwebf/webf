import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

const LISTVIEW = 'LISTVIEW';
const WEBF_LISTVIEW = 'WEBF-LISTVIEW';

class FlutterListViewElement extends WidgetElement {
  FlutterListViewElement(BindingContext? context) : super(context);

  Axis scrollDirection = Axis.vertical;

  @override
  ScrollController? get scrollControllerX {
    return context != null && scrollDirection == Axis.horizontal ? PrimaryScrollController.maybeOf(context!) : null;
  }

  @override
  ScrollController? get scrollControllerY {
    return context != null && scrollDirection == Axis.vertical ? PrimaryScrollController.maybeOf(context!) : null;
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFChildNodeSize(
        ownerElement: this,
        child: ListView.builder(
          scrollDirection: scrollDirection,
          itemCount: childNodes.length,
          itemBuilder: (context, index) {
            Node? node = childNodes.elementAt(index);
            if (node is dom.Element) {
              return LayoutBoxWrapper(ownerElement: node, child: childNodes.elementAt(index).toWidget());
            }
            return node.toWidget();
          },
          primary: true,
          padding: const EdgeInsets.all(0),
          // controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
        ));
  }
}
