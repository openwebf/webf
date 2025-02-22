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
  void scroll(double x, double y, [bool withAnimation = false]) {
    ScrollController? scrollController = PrimaryScrollController.maybeOf(context);
    scrollController?.position.moveTo(
      scrollDirection == Axis.vertical ? y : x,
      duration: null,
      curve: null,
    );
  }

  @override
  set scrollTop(double value) {
    scroll(0, value);
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
