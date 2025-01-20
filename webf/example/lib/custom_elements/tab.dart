import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'package:dynamic_tabbar/dynamic_tabbar.dart';

class FlutterTab extends WidgetElement {
  FlutterTab(super.context);

  bool isScrollable = false;
  bool showNextIcon = true;
  bool showBackIcon = true;

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    List<TabData> tabs = childNodes.whereType<dom.Element>().map((element) {
      return TabData(
        index: 0,
        title: Tab(
          child: Text(element.getAttribute('title') ?? ''),
        ),
        content: element.toWidget(key: ObjectKey(element)),
      );
    }).toList(growable: false);

    return DynamicTabBarWidget(
      dynamicTabs: tabs,
      isScrollable: isScrollable,
      onTabControllerUpdated: (controller) {},
      onTabChanged: (index) {},
      onAddTabMoveTo: MoveToTab.last,
      showBackIcon: showBackIcon,
      showNextIcon: showNextIcon,
    );
  }
}

class FlutterTabItem extends WidgetElement {
  FlutterTabItem(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(tagName: 'DIV', controller: ownerDocument.controller, children: childNodes.toWidgetList());
  }
}
