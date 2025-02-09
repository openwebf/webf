import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

class FlutterCupertinoSegmentedTab extends WidgetElement {
  FlutterCupertinoSegmentedTab(super.context);

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final tabs = <int, Widget>{};
    final contents = <Widget>[];

    int index = 0;
    for (var element in childNodes.whereType<dom.Element>()) {
      tabs[index] = Text(
        element.getAttribute('title') ?? '',
        style: const TextStyle(fontSize: 14),
      );
      contents.add(element.toWidget(key: ObjectKey(element)));
      index++;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CupertinoSlidingSegmentedControl<int>(
            children: tabs,
            groupValue: _currentIndex,
            onValueChanged: (value) {
              if (value != null) {
                setState(() {
                  _currentIndex = value;
                });
                dispatchEvent(CustomEvent('change', detail: value));
              }
            },
          ),
        ),
        Expanded(
          child: contents.isEmpty 
              ? const SizedBox() 
              : contents[_currentIndex],
        ),
      ],
    );
  }
}

class FlutterCupertinoSegmentedTabItem extends WidgetElement {
  FlutterCupertinoSegmentedTabItem(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(
      tagName: 'DIV',
      parentElement: this,
      controller: ownerDocument.controller,
      children: childNodes.toWidgetList(),
    );
  }
}