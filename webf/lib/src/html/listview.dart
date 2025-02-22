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
  double get scrollLeft {
    if (scrollDirection != Axis.horizontal) return 0.0;
    ScrollController? scrollController = PrimaryScrollController.maybeOf(context);
    return scrollController?.position.pixels ?? 0;
  }

  @override
  set scrollLeft(double value) {
    scroll(value, scrollTop);
  }

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
  void scrollBy(double x, double y, [bool withAnimation = false]) {
    if (scrollDirection == Axis.horizontal) {
      scroll(scrollLeft + x, scrollTop, withAnimation);
    } else {
      scroll(scrollLeft, scrollTop + y, withAnimation);
    }
  }

  @override
  double get scrollTop {
    if (scrollDirection != Axis.vertical) return 0.0;
    ScrollController? scrollController = PrimaryScrollController.maybeOf(context);

    return scrollController?.position.pixels ?? 0;
  }

  @override
  set scrollTop(double value) {
    scroll(scrollLeft, value);
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
