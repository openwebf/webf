import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

const LISTVIEW = 'LISTVIEW';
const WEBF_LISTVIEW = 'WEBF-LISTVIEW';

class FlutterListViewElement extends WidgetElement {
  FlutterListViewElement(BindingContext? context) : super(context);

  late ScrollController controller;

  @override
  void initState() {
    super.initState();
  }

  void _scrollListener() {
    if (controller.position.atEdge) {
      bool isReachBottom = controller.position.pixels != 0;
      if (isReachBottom) {
        dispatchEvent(Event('loadmore'));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didAttachRenderer();
    controller = PrimaryScrollController.maybeOf(context)!..addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFChildNodeSize(
        ownerElement: this,
        child: ListView(
          children: childNodes.toWidgetList(),
          padding: const EdgeInsets.all(0),
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
        ));
  }
}
