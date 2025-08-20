/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';

class FlutterTabBar extends WidgetElement {
  FlutterTabBar(super.context);

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap tabBarSyncMethods = {
    'switchTab': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) async {
        final tabBar = castToType<FlutterTabBar>(element);
        if (args.isEmpty) return;

        final targetPath = args[0].toString();
        final paths = tabBar._getTabPaths();
        final targetIndex = paths.indexOf(targetPath);
        if (targetIndex != -1) {
          tabBar.state?._controller.index = targetIndex;

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
    // Common navigation icons
    'home': CupertinoIcons.home,
    'house': CupertinoIcons.house,
    'house_fill': CupertinoIcons.house_fill,
    'search': CupertinoIcons.search,
    'search_circle': CupertinoIcons.search_circle,
    'search_circle_fill': CupertinoIcons.search_circle_fill,

    // Action icons
    'add': CupertinoIcons.add,
    'add_circled': CupertinoIcons.add_circled,
    'add_circled_solid': CupertinoIcons.add_circled_solid,
    'plus': CupertinoIcons.plus,
    'plus_circle': CupertinoIcons.plus_circle,
    'plus_circle_fill': CupertinoIcons.plus_circle_fill,

    // User/Account icons
    'person': CupertinoIcons.person,
    'person_fill': CupertinoIcons.person_fill,
    'person_circle': CupertinoIcons.person_circle,
    'person_circle_fill': CupertinoIcons.person_circle_fill,
    'profile_circled': CupertinoIcons.profile_circled,

    // Communication icons
    'bell': CupertinoIcons.bell,
    'bell_fill': CupertinoIcons.bell_fill,
    'bell_circle': CupertinoIcons.bell_circle,
    'bell_circle_fill': CupertinoIcons.bell_circle_fill,
    'chat_bubble': CupertinoIcons.chat_bubble,
    'chat_bubble_fill': CupertinoIcons.chat_bubble_fill,
    'chat_bubble_2': CupertinoIcons.chat_bubble_2,
    'chat_bubble_2_fill': CupertinoIcons.chat_bubble_2_fill,
    'mail': CupertinoIcons.mail,
    'mail_solid': CupertinoIcons.mail_solid,
    'envelope': CupertinoIcons.envelope,
    'envelope_fill': CupertinoIcons.envelope_fill,
    'phone': CupertinoIcons.phone,
    'phone_fill': CupertinoIcons.phone_fill,

    // Navigation/Direction icons
    'compass': CupertinoIcons.compass,
    'compass_fill': CupertinoIcons.compass_fill,
    'location': CupertinoIcons.location,
    'location_fill': CupertinoIcons.location_fill,
    'map': CupertinoIcons.map,
    'map_fill': CupertinoIcons.map_fill,

    // Media icons
    'photo': CupertinoIcons.photo,
    'photo_fill': CupertinoIcons.photo_fill,
    'camera': CupertinoIcons.camera,
    'camera_fill': CupertinoIcons.camera_fill,
    'video_camera': CupertinoIcons.video_camera,
    'video_camera_solid': CupertinoIcons.video_camera_solid,
    'play': CupertinoIcons.play,
    'play_fill': CupertinoIcons.play_fill,
    'play_circle': CupertinoIcons.play_circle,
    'play_circle_fill': CupertinoIcons.play_circle_fill,

    // Settings/System icons
    'gear': CupertinoIcons.gear,
    'gear_solid': CupertinoIcons.gear_solid,
    'settings': CupertinoIcons.settings,
    'settings_solid': CupertinoIcons.settings_solid,
    'ellipsis': CupertinoIcons.ellipsis,
    'ellipsis_circle': CupertinoIcons.ellipsis_circle,
    'ellipsis_circle_fill': CupertinoIcons.ellipsis_circle_fill,

    // Business/Finance icons
    'creditcard': CupertinoIcons.creditcard,
    'creditcard_fill': CupertinoIcons.creditcard_fill,
    'cart': CupertinoIcons.cart,
    'cart_fill': CupertinoIcons.cart_fill,
    'bag': CupertinoIcons.bag,
    'bag_fill': CupertinoIcons.bag_fill,

    // Document/File icons
    'doc': CupertinoIcons.doc,
    'doc_fill': CupertinoIcons.doc_fill,
    'doc_text': CupertinoIcons.doc_text,
    'doc_text_fill': CupertinoIcons.doc_text_fill,
    'folder': CupertinoIcons.folder,
    'folder_fill': CupertinoIcons.folder_fill,
    'book': CupertinoIcons.book,
    'book_fill': CupertinoIcons.book_fill,

    // Social/Interaction icons
    'heart': CupertinoIcons.heart,
    'heart_fill': CupertinoIcons.heart_fill,
    'star': CupertinoIcons.star,
    'star_fill': CupertinoIcons.star_fill,
    'hand_thumbsup': CupertinoIcons.hand_thumbsup,
    'hand_thumbsup_fill': CupertinoIcons.hand_thumbsup_fill,
    'bookmark': CupertinoIcons.bookmark,
    'bookmark_fill': CupertinoIcons.bookmark_fill,

    // Currency icons (using money_dollar as bitcoin alternative)
    'money_dollar': CupertinoIcons.money_dollar,
    'money_dollar_circle': CupertinoIcons.money_dollar_circle,
    'money_dollar_circle_fill': CupertinoIcons.money_dollar_circle_fill,

    // Utility icons
    'info': CupertinoIcons.info,
    'info_circle': CupertinoIcons.info_circle,
    'info_circle_fill': CupertinoIcons.info_circle_fill,
    'question': CupertinoIcons.question,
    'question_circle': CupertinoIcons.question_circle,
    'question_circle_fill': CupertinoIcons.question_circle_fill,
    'exclamationmark': CupertinoIcons.exclamationmark,
    'exclamationmark_circle': CupertinoIcons.exclamationmark_circle,
    'exclamationmark_circle_fill': CupertinoIcons.exclamationmark_circle_fill,
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
      if (child is! dom.Element || child.tagName != 'FLUTTER-CUPERTINO-TAB-BAR-ITEM') continue;
      paths.add(child.getAttribute('path') ?? '/');
    }
    return paths;
  }

  List<Widget> _buildTabViews(ChildNodeList childNodes) {
    final tabViews = <Widget>[];
    for (var child in childNodes) {
      if (child is! FlutterCupertinoTabBarItem) continue;
      tabViews.add(WebFWidgetElementChild(child: child.toWidget()));
    }
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
  FlutterTabBarState? get state => super.state as FlutterTabBarState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterTabBarState(this);
  }
}

class FlutterTabBarState extends WebFWidgetElementState {
  FlutterTabBarState(super.widgetElement);

  @override
  FlutterTabBar get widgetElement => super.widgetElement as FlutterTabBar;

  final CupertinoTabController _controller = CupertinoTabController();

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final customBackgroundColor = widgetElement._parseColor(widgetElement.getAttribute('backgroundColor'));
    final customActiveColor = widgetElement._parseColor(widgetElement.getAttribute('activeColor'));
    final customInactiveColor = widgetElement._parseColor(widgetElement.getAttribute('inactiveColor'));

    final defaultBackgroundColor = isDark
        ? CupertinoDynamicColor.resolve(
            const CupertinoDynamicColor.withBrightness(
              color: Color(0xFF1C1C1E),
              darkColor: Color(0xFF1C1C1E),
            ),
            context,
          )
        : CupertinoColors.systemBackground;

    final defaultActiveColor =
        isDark ? CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context) : CupertinoColors.systemBlue;

    final defaultInactiveColor =
        isDark ? CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context) : CupertinoColors.systemGrey;

    final paths = widgetElement._getTabPaths();
    final tabViews = widgetElement._buildTabViews(widgetElement.childNodes);

    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: CupertinoTabScaffold(
            controller: _controller,
            tabBar: CupertinoTabBar(
                items: widgetElement._buildTabItems(),
                currentIndex: int.tryParse(widgetElement.getAttribute('currentIndex') ?? '0') ?? 0,
                backgroundColor: customBackgroundColor ?? defaultBackgroundColor,
                activeColor: customActiveColor ?? defaultActiveColor,
                inactiveColor: customInactiveColor ?? defaultInactiveColor,
                iconSize: double.tryParse(widgetElement.getAttribute('iconSize') ?? '30.0') ?? 30.0,
                height: double.tryParse(widgetElement.getAttribute('height') ?? '50.0') ?? 50.0,
                border: isDark
                    ? Border(
                        top: BorderSide(
                            color: CupertinoDynamicColor.resolve(CupertinoColors.separator, context)
                                .withValues(alpha: 0.3)))
                    : null,
                onTap: (index) {
                  widgetElement.setAttribute('currentIndex', index.toString());
                  widgetElement.dispatchEvent(CustomEvent('tabchange', detail: index));
                }),
            tabBuilder: (BuildContext context, int index) {
              return CupertinoTabView(
                builder: (BuildContext context) {
                  if (index < tabViews.length) {
                    return WebFWidgetElementChild(child: tabViews[index]);
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
  WebFWidgetElementState createState() {
    return FlutterCupertinoTabBarItemState(this);
  }
}

class FlutterCupertinoTabBarItemState extends WebFWidgetElementState {
  FlutterCupertinoTabBarItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.map((node) => WebFWidgetElementChild(child: node.toWidget())).toList()));
  }
}
