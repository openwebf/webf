/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';

import 'custom_elements/icon.dart';
import 'custom_elements/search.dart';
import 'custom_elements/select.dart';
import 'custom_elements/button.dart';
import 'custom_elements/bottom_sheet.dart';
import 'custom_elements/tab.dart';
import 'custom_elements/switch.dart';
import 'custom_elements/slider.dart';
import 'custom_elements/cupertino/tab_bar.dart';
import 'custom_elements/cupertino/button.dart';
import 'custom_elements/cupertino/input.dart';
import 'custom_elements/cupertino/tab.dart';
import 'custom_elements/cupertino/segmented_tab.dart';
import 'custom_elements/cupertino/switch.dart';
import 'custom_elements/cupertino/picker.dart';
import 'custom_elements/cupertino/date_picker.dart';
import 'custom_elements/cupertino/modal_popup.dart';
import 'custom_elements/cupertino/icon.dart';
import 'custom_elements/cupertino/search_input.dart';
import 'custom_elements/cupertino/alert.dart';
import 'custom_elements/cupertino/toast.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  WebF.defineCustomElement('flutter-tab', (context) => FlutterTab(context));
  WebF.defineCustomElement('flutter-tab-item', (context) => FlutterTabItem(context));
  WebF.defineCustomElement('flutter-icon', (context) => FlutterIcon(context));
  WebF.defineCustomElement('flutter-search', (context) => FlutterSearch(context));
  WebF.defineCustomElement('flutter-select', (context) => FlutterSelect(context));
  WebF.defineCustomElement('flutter-button', (context) => FlutterButton(context));
  WebF.defineCustomElement('flutter-bottom-sheet', (context) => FlutterBottomSheet(context));
  WebF.defineCustomElement('flutter-slider', (context) => SliderElement(context));
  WebF.defineCustomElement('flutter-switch', (context) => FlutterSwitch(context));
  WebF.defineCustomElement('flutter-tab-bar', (context) => FlutterTabBar(context));
  WebF.defineCustomElement('flutter-tab-bar-item', (context) => FlutterTabBarItem(context));
  WebF.defineCustomElement('flutter-cupertino-button', (context) => FlutterCupertinoButton(context));
  WebF.defineCustomElement('flutter-cupertino-input', (context) => FlutterCupertinoInput(context));
  WebF.defineCustomElement('flutter-cupertino-tab', (context) => FlutterCupertinoTab(context));
  WebF.defineCustomElement('flutter-cupertino-tab-item', (context) => FlutterCupertinoTabItem(context));
  WebF.defineCustomElement('flutter-cupertino-segmented-tab', (context) => FlutterCupertinoSegmentedTab(context));
  WebF.defineCustomElement('flutter-cupertino-segmented-tab-item', (context) => FlutterCupertinoSegmentedTabItem(context));
  WebF.defineCustomElement('flutter-cupertino-switch', (context) => FlutterCupertinoSwitch(context));
  WebF.defineCustomElement('flutter-cupertino-picker', (context) => FlutterCupertinoPicker(context));
  WebF.defineCustomElement('flutter-cupertino-picker-item', (context) => FlutterCupertinoPickerItem(context));
  WebF.defineCustomElement('flutter-cupertino-date-picker', (context) => FlutterCupertinoDatePicker(context));
  WebF.defineCustomElement('flutter-cupertino-modal-popup', (context) => FlutterCupertinoModalPopup(context));
  WebF.defineCustomElement('flutter-cupertino-icon', (context) => FlutterCupertinoIcon(context));
  WebF.defineCustomElement('flutter-cupertino-search-input', (context) => FlutterCupertinoSearchInput(context));
  WebF.defineCustomElement('flutter-cupertino-alert', (context) => FlutterCupertinoAlert(context));
  WebF.defineCustomElement('flutter-cupertino-toast', (context) => FlutterCupertinoToast(context));
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class WebFSubView extends StatelessWidget {
  const WebFSubView({super.key, required this.title, required this.path, required this.controller});

  final WebFController controller;
  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: DayNightSwitcherIcon(
                isDarkModeEnabled: AdaptiveTheme.of(context).theme.brightness == Brightness.dark,
                onStateChanged: (isDarkModeEnabled) async {
                  // sets theme mode to dark
                  !isDarkModeEnabled ? AdaptiveTheme.of(context).setLight()
                      : AdaptiveTheme.of(context).setDark();
                  controller.darkModeOverride = isDarkModeEnabled;
                  controller.view.onPlatformBrightnessChanged();
                },
              )),
        ],
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   print(context.findRenderObject()?.toStringDeep());
      // }),
      body: WebFRouterView(controller: controller, path: path),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first screen when tapped.
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  MyApp({required this.savedThemeMode});

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  WebFController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // bool isDark = AdaptiveTheme.of(context).theme.brightness == Brightness.dark;
    controller = controller ??
        WebFController(
          context,
          initialRoute: '/home',
          devToolsService: kDebugMode ? ChromeDevToolsService() : null,
        );
    controller!.darkModeOverride = widget.savedThemeMode == AdaptiveThemeMode.dark;
    // controller!.preload(WebFBundle.fromUrl('assets:///assets/bundle.html'));
    // controller!.preload(WebFBundle.fromUrl('http://localhost:8080/'), viewportSize: MediaQuery.of(context).size);
    controller!.preload(WebFBundle.fromUrl('assets:///vue_project/dist/index.html'));
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'WebF Example App',
        initialRoute: '/',
        theme: theme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routes: {
          '/todomvc': (context) => WebFSubView(title: 'TodoMVC', path: '/todomvc', controller: controller!),
          '/positioned_layout': (context) =>
              WebFSubView(title: 'CSS Positioned Layout', path: '/positioned_layout', controller: controller!),
          '/home': (context) => WebFSubView(title: '首页', path: '/home', controller: controller!),
          '/search': (context) => WebFSubView(title: '搜索', path: '/search', controller: controller!),
          '/publish': (context) => WebFSubView(title: '发布', path: '/publish', controller: controller!),
          '/message': (context) => WebFSubView(title: '消息', path: '/message', controller: controller!),
          '/my': (context) => WebFSubView(title: '我的', path: '/my', controller: controller!),
          '/register': (context) => WebFSubView(title: '注册', path: '/register', controller: controller!),
          '/login': (context) => WebFSubView(title: '登录', path: '/login', controller: controller!),
          '/share_link': (context) => WebFSubView(title: '详情', path: '/share_link', controller: controller!),
          '/user': (context) => WebFSubView(title: '用户', path: '/user', controller: controller!),
          '/edit': (context) => WebFSubView(title: '编辑', path: '/edit', controller: controller!),
          '/setting': (context) => WebFSubView(title: '设置', path: '/setting', controller: controller!),
          '/user_agreement': (context) => WebFSubView(title: '用户服务协议', path: '/user_agreement', controller: controller!),
          '/privacy_policy': (context) => WebFSubView(title: '隐私政策', path: '/privacy_policy', controller: controller!),
        },
        debugShowCheckedModeBanner: false,
        home: FirstPage(title: 'Landing Bay', controller: controller!),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key, required this.title, required this.controller}) : super(key: key);
  final String title;
  final WebFController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return WebFDemo(controller: controller!);
            }));
          },
          child: const Text('Open WebF Page'),
        ),
      ),
    );
  }
}

class WebFDemo extends StatelessWidget {
  final WebFController controller;

  WebFDemo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('WebF Demo'),
          actions: [
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: DayNightSwitcherIcon(
                  isDarkModeEnabled: AdaptiveTheme.of(context).theme.brightness == Brightness.dark,
                  onStateChanged: (isDarkModeEnabled) async {
                    // sets theme mode to dark
                    !isDarkModeEnabled ? AdaptiveTheme.of(context).setLight()
                        : AdaptiveTheme.of(context).setDark();
                    controller.darkModeOverride = isDarkModeEnabled;
                    controller.view.onPlatformBrightnessChanged();
                  },
                )),
          ],
        ),
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   print(controller.view.getRootRenderObject()!.toStringDeep());
        // }),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: WebF(controller: controller),
        ));
  }
}
