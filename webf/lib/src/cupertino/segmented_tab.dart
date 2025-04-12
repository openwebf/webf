import 'package:flutter/cupertino.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

class FlutterCupertinoSegmentedTab extends WidgetElement {
  FlutterCupertinoSegmentedTab(super.context);

  @override
  FlutterCupertinoSegmentedTabState? get state => super.state as FlutterCupertinoSegmentedTabState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSegmentedTabState(this);
  }
}

class FlutterCupertinoSegmentedTabState extends WebFWidgetElementState {
  FlutterCupertinoSegmentedTabState(super.widgetElement);

  int _currentIndex = 0;

  @override
  FlutterCupertinoSegmentedTab get widgetElement => super.widgetElement as FlutterCupertinoSegmentedTab;

  @override
  Widget build(BuildContext context) {
    final tabs = <int, Widget>{};
    final contents = <Widget>[];

    // Default dimensions if not specified
    final double defaultWidth = 80.0;
    final double defaultHeight = 30.0;
    final CSSRenderStyle renderStyle = widgetElement.renderStyle;

    int index = 0;
    for (var element in widgetElement.childNodes.whereType<dom.Element>()) {
      tabs[index] = Container(
        width: renderStyle.width.isAuto ? defaultWidth : renderStyle.width.computedValue,
        height: renderStyle.height.isAuto ? defaultHeight : renderStyle.height.computedValue,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: renderStyle.paddingLeft.computedValue,
          vertical: renderStyle.paddingTop.computedValue,
        ),
        child: Text(
          element.getAttribute('title') ?? '',
          style: TextStyle(
            fontSize: renderStyle.fontSize.computedValue,
            // color: renderStyle.color,
            fontWeight: renderStyle.fontWeight,
            // fontFamily: renderStyle.fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
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
                widgetElement.dispatchEvent(CustomEvent('change', detail: value));
              }
            },
          ),
        ),
        Expanded(
          child: contents.isEmpty ? const SizedBox() : contents[_currentIndex],
        ),
      ],
    );
  }
}

class FlutterCupertinoSegmentedTabItem extends WidgetElement {
  FlutterCupertinoSegmentedTabItem(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSegmentedTabItemState(this);
  }
}

class FlutterCupertinoSegmentedTabItemState extends WebFWidgetElementState {
  FlutterCupertinoSegmentedTabItemState(super.widgetElement);

  @override
  WidgetElement get widgetElement => super.widgetElement as FlutterCupertinoSegmentedTabItem;

  @override
  Widget build(BuildContext context) {
    return WebFHTMLElement(
      tagName: 'DIV',
      parentElement: widgetElement,
      controller: widgetElement.ownerDocument.controller,
      children: widgetElement.childNodes.toWidgetList(),
    );
  }
}
