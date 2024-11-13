import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

const LISTVIEW = 'LISTVIEW';

class FlutterListViewElement extends WidgetElement {
  FlutterListViewElement(BindingContext? context) : super(context);

  late ScrollController controller;

  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
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
  Widget build(BuildContext context, List<Widget> children) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (BuildContext context, int index) {
         final key = GlobalKey();
        _itemKeys[index] = key;
        return Container(
          key: key,
          child: children[index],
        );
      },
      padding: const EdgeInsets.all(0),
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}
