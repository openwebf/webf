import 'package:flutter/material.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';

class FlutterListViewElement extends WidgetElement {
  FlutterListViewElement(BindingContext? context) : super(context);
  @override
  Map<String, dynamic> get defaultStyle => {'display': 'block'};

  @override
  WebFWidgetElementState createState() {
    return FlutterListViewElementState(this);
  }
}

class FlutterListViewElementState extends WebFWidgetElementState {
  FlutterListViewElementState(super.widgetElement);

  late ScrollController controller;

  void _scrollListener() {
    if (controller.position.atEdge) {
      bool isReachBottom = controller.position.pixels != 0;
      if (isReachBottom) {
        widgetElement.dispatchEvent(Event('loadmore'));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: WebFChildNodeSize(
          ownerElement: widgetElement,
          child: ListView(
            children: widgetElement.childNodes.toWidgetList(),
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
          ),
        ));
  }
}
