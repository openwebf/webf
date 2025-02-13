import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

class FlutterTabBar extends WidgetElement {
  FlutterTabBar(super.context);

  final CupertinoTabController _controller = CupertinoTabController();

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);

    methods['switchTab'] = BindingObjectMethodSync(call: (args) async {
      if (args.isEmpty) return;

      final targetPath = args[0].toString();
      final paths = _getTabPaths();
      final targetIndex = paths.indexOf(targetPath);
      print('targetIndex: $targetIndex');
      if (targetIndex != -1) {
        _controller.index = targetIndex;

        setAttribute('currentIndex', targetIndex.toString());
        dispatchEvent(CustomEvent('tabchange', detail: targetIndex));
      }
    });
  }

  static final Map<String, IconData> _iconMap = {
    'home': CupertinoIcons.home,
    'search': CupertinoIcons.search,
    'add': CupertinoIcons.add,
    'bell': CupertinoIcons.bell,
    'person': CupertinoIcons.person,
    'add_circled_solid': CupertinoIcons.add_circled_solid,
    // ...
  };

  List<BottomNavigationBarItem> _buildTabItems() {
    List<BottomNavigationBarItem> items = [];

    for (var child in childNodes) {
      if (child is! dom.Element || child.tagName != 'FLUTTER-TAB-BAR-ITEM') continue;

      final title = child.getAttribute('title') ?? '';
      final icon = child.getAttribute('icon') ?? '';

      items.add(BottomNavigationBarItem(
        icon: Icon(_iconMap[icon] ?? CupertinoIcons.home),
        label: title,
      ));
    }

    return items;
  }

  List<String> _getTabPaths() {
    List<String> paths = [];
    for (var child in childNodes) {
      if (child is! dom.Element || child.tagName != 'FLUTTER-TAB-BAR-ITEM') continue;
      paths.add(child.getAttribute('path') ?? '/');
    }
    return paths;
  }

  List<Widget> _buildTabViews(ChildNodeList childNodes) {
    final tabViews = <Widget>[];
    for (var child in childNodes) {
      if (child is! dom.Element || child.tagName != 'FLUTTER-TAB-BAR-ITEM') continue;
      tabViews.add(child.toWidget(key: ObjectKey(child)));
    }
    print('tabViews: ${tabViews.length}');
    return tabViews;
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final paths = _getTabPaths();
    final tabViews = _buildTabViews(childNodes);
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: CupertinoTabScaffold(
            controller: _controller,
            tabBar: CupertinoTabBar(
                items: _buildTabItems(),
                currentIndex: int.tryParse(getAttribute('currentIndex') ?? '0') ?? 0,
                backgroundColor: getAttribute('backgroundColor') != null
                    ? Color(int.parse(getAttribute('backgroundColor')!.replaceAll('#', ''), radix: 16) + 0xFF000000)
                    : null,
                activeColor: getAttribute('activeColor') != null
                    ? Color(int.parse(getAttribute('activeColor')!.replaceAll('#', ''), radix: 16) + 0xFF000000)
                    : null,
                inactiveColor: getAttribute('inactiveColor') != null
                    ? Color(int.parse(getAttribute('inactiveColor')!.replaceAll('#', ''), radix: 16) + 0xFF000000)
                    : CupertinoColors.inactiveGray,
                iconSize: double.tryParse(getAttribute('iconSize') ?? '30.0') ?? 30.0,
                height: double.tryParse(getAttribute('height') ?? '50.0') ?? 50.0,
                onTap: (index) {
                  setAttribute('currentIndex', index.toString());
                  print('index: $index');
                }),
            tabBuilder: (BuildContext context, int index) {
              return CupertinoTabView(
                builder: (BuildContext context) {
                  print('tabViews: ${tabViews.length}');
                  if (index < tabViews.length) {
                    return tabViews[index];
                  }
                  return Center(
                    child: Text('Invalid tab of $index for route ${paths[index]}'),
                  );
                },
              );
            }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FlutterTabBarItem extends WidgetElement {
  FlutterTabBarItem(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(
        tagName: 'DIV', controller: ownerDocument.controller, parentElement: this, children: childNodes.toWidgetList());
  }
}
