import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

class FlutterTabBar extends WidgetElement {
  FlutterTabBar(super.context);

  final CupertinoTabController _controller = CupertinoTabController();

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap tabBarSyncMethods = {
    'switchTab': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) async {
        final tabBar = castToType<FlutterTabBar>(element);
        if (args.isEmpty) return;

        final targetPath = args[0].toString();
        final paths = tabBar._getTabPaths();
        final targetIndex = paths.indexOf(targetPath);
        print('targetIndex: $targetIndex');
        if (targetIndex != -1) {
          tabBar._controller.index = targetIndex;

          tabBar.setAttribute('currentIndex', targetIndex.toString());
          tabBar.dispatchEvent(CustomEvent('tabchange', detail: targetIndex));
        }
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    tabBarSyncMethods,
  ];

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
      if (child is! FlutterCupertinoTabBarItem) continue;

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
      if (child is! FlutterCupertinoTabBarItem) continue;
      tabViews.add(child.toWidget());
    }
    print('tabViews: ${tabViews.length}');
    return tabViews;
  }

  Color? _parseColor(String? colorStr) {
    if (colorStr == null) return null;
    try {
      return Color(int.parse(colorStr.replaceAll('#', ''), radix: 16) + 0xFF000000);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final customBackgroundColor = _parseColor(getAttribute('backgroundColor'));
    final customActiveColor = _parseColor(getAttribute('activeColor'));
    final customInactiveColor = _parseColor(getAttribute('inactiveColor'));

    final defaultBackgroundColor = isDark 
        ? CupertinoDynamicColor.resolve(
            const CupertinoDynamicColor.withBrightness(
              color: Color(0xFF1C1C1E),
              darkColor: Color(0xFF1C1C1E),
            ),
            context,
          )
        : CupertinoColors.systemBackground;
    
    final defaultActiveColor = isDark
        ? CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context)
        : CupertinoColors.systemBlue;

    final defaultInactiveColor = isDark
        ? CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context)
        : CupertinoColors.systemGrey;

    final paths = _getTabPaths();
    final tabViews = _buildTabViews(childNodes);
    
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: CupertinoTabScaffold(
            controller: _controller,
            tabBar: CupertinoTabBar(
                items: _buildTabItems(),
                currentIndex: int.tryParse(getAttribute('currentIndex') ?? '0') ?? 0,
                backgroundColor: customBackgroundColor ?? defaultBackgroundColor,
                activeColor: customActiveColor ?? defaultActiveColor,
                inactiveColor: customInactiveColor ?? defaultInactiveColor,
                iconSize: double.tryParse(getAttribute('iconSize') ?? '30.0') ?? 30.0,
                height: double.tryParse(getAttribute('height') ?? '50.0') ?? 50.0,
                border: isDark 
                    ? Border(
                        top: BorderSide(
                          color: CupertinoDynamicColor.resolve(
                            CupertinoColors.separator, 
                            context
                          ).withOpacity(0.3)
                        )
                      )
                    : null,
                onTap: (index) {
                  setAttribute('currentIndex', index.toString());
                  dispatchEvent(CustomEvent('tabchange', detail: index));
                }),
            tabBuilder: (BuildContext context, int index) {
              return CupertinoTabView(
                builder: (BuildContext context) {
                  print('tabViews: ${tabViews.length}');
                  if (index < tabViews.length) {
                    return tabViews[index];
                  }
                  return Center(
                    child: Text(
                      'Invalid tab of $index for route ${paths[index]}',
                      style: TextStyle(
                        color: isDark ? CupertinoColors.white : CupertinoColors.black,
                      ),
                    ),
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

class FlutterCupertinoTabBarItem extends WidgetElement {
  FlutterCupertinoTabBarItem(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(
        tagName: 'DIV', controller: ownerDocument.controller, parentElement: this, children: childNodes.toWidgetList());
  }
}
