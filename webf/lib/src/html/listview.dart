import 'package:flutter/material.dart';
import 'package:webf/src/css/position.dart';
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

  void _scrollListener() {
    ScrollController? scrollController = context != null ? PrimaryScrollController.maybeOf(context!) : null;
    if (scrollController != null) {
      if (scrollController.position.extentAfter < 50) {
        dispatchEvent(dom.Event('end'));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScrollController? scrollController = PrimaryScrollController.maybeOf(context!);
    scrollController?.addListener(_scrollListener);
  }

  @override
  void stateDispose() {
    if (context == null) return;
    ScrollController? scrollController = PrimaryScrollController.maybeOf(context!);
    scrollController?.removeListener(_scrollListener);
    super.stateDispose();
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
              CSSPositionType positionType = node.renderStyle.position;
              if (positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed) {
                return PositionPlaceHolder(node.holderAttachedPositionedElement!, node);
              }

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
