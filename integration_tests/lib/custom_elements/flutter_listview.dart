import 'package:flutter/material.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';

class FlutterListViewElement extends WidgetElement {
  FlutterListViewElement(BindingContext? context) : super(context);

  late ScrollController controller;

  @override
  Map<String, dynamic> get defaultStyle => {'display': 'block'};

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
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: WebFChildNodeSize(
          ownerElement: this,
          child: ListView(
            children: childNodes.toWidgetList(),
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
          ),
        ));

    ;
  }
}
