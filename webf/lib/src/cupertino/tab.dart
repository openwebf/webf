import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

class FlutterCupertinoTab extends WidgetElement {
  FlutterCupertinoTab(super.context);


  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap tabSyncMethods = {
    'switchTab': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final tab = castToType<FlutterCupertinoTab>(element);
        if (args.isEmpty) return;
        final index = int.tryParse(args[0].toString());
        if (index != null) {
          tab.state?._currentIndex = index;
          tab.state?.requestUpdateState();
          tab.dispatchEvent(CustomEvent('change', detail: index));
        }
      },
    ),
  };


  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    tabSyncMethods,
  ];

  @override
  FlutterCupertinoTabState? get state => super.state as FlutterCupertinoTabState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoTabState(this);
  }
}

class FlutterCupertinoTabState extends WebFWidgetElementState {
  FlutterCupertinoTabState(super.widgetElement);

  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final items = widgetElement.childNodes.whereType<dom.Element>().toList(growable: false);

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return GestureDetector(
                  onTap: () {
                    _currentIndex = index;
                    widgetElement.dispatchEvent(CustomEvent('change', detail: index));
                    setState(() {});
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: _currentIndex == index
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _currentIndex == index
                          ? CupertinoTheme.of(context).primaryColor
                          : CupertinoColors.label.resolveFrom(context).withAlpha(128),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: Text(item.getAttribute('title') ?? ''),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const SizedBox()
              : items[_currentIndex].toWidget(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class FlutterCupertinoTabItem extends WidgetElement {
  FlutterCupertinoTabItem(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoTabItemState(this);
  }
}

class FlutterCupertinoTabItemState extends WebFWidgetElementState {
  FlutterCupertinoTabItemState(super.widgetElement);

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
