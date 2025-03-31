/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/widget.dart'; // For AsyncWebF
import 'package:webf/devtools.dart';
import 'package:webf/launcher.dart'; // For WebFControllerManager
import 'package:webf/cupertino.dart';
import 'package:flutter/cupertino.dart';

import 'custom_elements/icon.dart';
import 'custom_elements/search.dart';
import 'custom_elements/select.dart';
import 'custom_elements/button.dart';
import 'custom_elements/bottom_sheet.dart';
import 'custom_elements/tab.dart';
import 'custom_elements/switch.dart';
import 'custom_elements/slider.dart';
import 'custom_elements/svg_img.dart';
import 'custom_elements/shimmer/shimmer.dart';
import 'custom_elements/shimmer/shimmer_items.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class CustomHybridHistoryDelegate extends HybridHistoryDelegate {
  @override
  void back(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  String path(BuildContext context) {
    String? currentPath = ModalRoute.of(context)?.settings.name;
    return currentPath ?? '';
  }

  @override
  void pushState(BuildContext context, state, String name) {
    Navigator.pushNamed(context, name, arguments: state);
  }

  @override
  void replaceState(BuildContext context, state, String name) {
    Navigator.pushReplacementNamed(context, name, arguments: state);
  }

  @override
  state(BuildContext context) {
    var route = ModalRoute.of(context);
    if (route?.settings.arguments != null) {
      return jsonEncode(route!.settings.arguments);
    }
    return '{}';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  // Initialize the controller manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
      maxAliveInstances: 2,
      maxAttachedInstances: 1,
      onControllerDisposed: (String name, WebFController controller) {
        print('controller disposed: $name $controller');
      }));
  WebF.defineCustomElement('flutter-tab', (context) => FlutterTab(context));
  WebF.defineCustomElement('flutter-tab-item', (context) => FlutterTabItem(context));
  WebF.defineCustomElement('flutter-icon', (context) => FlutterIcon(context));
  WebF.defineCustomElement('flutter-search', (context) => FlutterSearch(context));
  WebF.defineCustomElement('flutter-select', (context) => FlutterSelect(context));
  WebF.defineCustomElement('flutter-button', (context) => FlutterButton(context));
  WebF.defineCustomElement('flutter-bottom-sheet', (context) => FlutterBottomSheet(context));
  WebF.defineCustomElement('flutter-slider', (context) => SliderElement(context));
  WebF.defineCustomElement('flutter-switch', (context) => FlutterSwitch(context));
  WebF.defineCustomElement('flutter-svg-img', (context) => FlutterSVGImg(context));
  WebF.defineCustomElement('flutter-shimmer', (context) => FlutterShimmerElement(context));
  WebF.defineCustomElement('flutter-shimmer-avatar', (context) => FlutterShimmerAvatarElement(context));
  WebF.defineCustomElement('flutter-shimmer-text', (context) => FlutterShimmerTextElement(context));
  WebF.defineCustomElement('flutter-shimmer-button', (context) => FlutterShimmerButtonElement(context));
  installWebFCupertino();

  // Add home controller with preloading
  WebFControllerManager.instance.addWithPrerendering(
      name: 'html/css',
      createController: () => WebFController(
            routeObserver: routeObserver,
            devToolsService: kDebugMode ? ChromeDevToolsService() : null,
          ),
      bundle: WebFBundle.fromUrl('assets:///assets/bundle.html'),
      setup: (controller) {
        controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
        controller.darkModeOverride = savedThemeMode?.isDark;
      });

  // Add vue controller with preloading
  WebFControllerManager.instance.addWithPrerendering(
      name: 'vuejs',
      createController: () => WebFController(
            initialRoute: '/',
            routeObserver: routeObserver,
            devToolsService: kDebugMode ? ChromeDevToolsService() : null,
          ),
      bundle: WebFBundle.fromUrl('assets:///vue_project/dist/index.html'),
      routes: {
        '/todomvc': (context, controller) => WebFSubView(path: '/todomvc', controller: controller),
        '/positioned_layout': (context, controller) => WebFSubView(path: '/positioned_layout', controller: controller),
      },
      setup: (controller) {
        controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
        controller.darkModeOverride = savedThemeMode?.isDark;
      });

  WebFControllerManager.instance.addWithPrerendering(
      name: 'cupertino_gallery',
      createController: () => WebFController(
            initialRoute: '/',
            routeObserver: routeObserver,
            devToolsService: kDebugMode ? ChromeDevToolsService() : null,
          ),
      bundle: WebFBundle.fromUrl('assets:///cupertino_gallery/dist/index.html'),
      routes: {
        '/': (context, controller) => WebFSubView(path: '/', controller: controller),
        '/button': (context, controller) => WebFSubView(path: '/button', controller: controller),
        '/switch': (context, controller) => WebFSubView(path: '/switch', controller: controller),
        '/input': (context, controller) => WebFSubView(path: '/input', controller: controller),
        '/icon': (context, controller) => WebFSubView(path: '/icon', controller: controller),
        '/search_input': (context, controller) => WebFSubView(path: '/search_input', controller: controller),
      },
      setup: (controller) {
        controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
        controller.darkModeOverride = savedThemeMode?.isDark;
      });

  // Add vue controller with preloading
  WebFControllerManager.instance.addWithPrerendering(
      name: 'miracle_plus',
      createController: () => WebFController(
            initialRoute: '/home',
            routeObserver: routeObserver,
            devToolsService: kDebugMode ? ChromeDevToolsService() : null,
          ),
      bundle: WebFBundle.fromUrl('assets:///news_miracleplus/dist/index.html'),
      routes: {
        '/home': (context, controller) => WebFSubView(path: '/home', controller: controller),
        '/search': (context, controller) => WebFSubView(path: '/search', controller: controller),
        '/publish': (context, controller) => WebFSubView(path: '/publish', controller: controller),
        '/message': (context, controller) => WebFSubView(path: '/message', controller: controller),
        '/my': (context, controller) => WebFSubView(path: '/my', controller: controller),
        '/register': (context, controller) => WebFSubView(path: '/register', controller: controller),
        '/login': (context, controller) => WebFSubView(path: '/login', controller: controller),
        '/reset_password': (context, controller) => WebFSubView(path: '/reset_password', controller: controller),
        '/share_link': (context, controller) => WebFSubView(path: '/share_link', controller: controller),
        '/comment': (context, controller) => WebFSubView(path: '/comment', controller: controller),
        '/user': (context, controller) => WebFSubView(path: '/user', controller: controller),
        '/edit': (context, controller) => WebFSubView(path: '/edit', controller: controller),
        '/setting': (context, controller) => WebFSubView(path: '/setting', controller: controller),
        '/user_agreement': (context, controller) => WebFSubView(path: '/user_agreement', controller: controller),
        '/privacy_policy': (context, controller) => WebFSubView(path: '/privacy_policy', controller: controller),
        '/answer': (context, controller) => WebFSubView(path: '/answer', controller: controller),
        '/question': (context, controller) => WebFSubView(path: '/question', controller: controller),
        '/topic': (context, controller) => WebFSubView(path: '/topic', controller: controller),
      },
      setup: (controller) {
        controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
        controller.darkModeOverride = savedThemeMode?.isDark;
      });

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class WebFSubView extends StatefulWidget {
  const WebFSubView({super.key, required this.path, required this.controller});

  final WebFController controller;
  final String path;

  @override
  State<StatefulWidget> createState() {
    return WebFSubViewState();
  }
}

class WebFSubViewState extends State<WebFSubView> {
  @override
  Widget build(BuildContext context) {
    WebFController controller = widget.controller;
    RouterLinkElement? routerLinkElement = controller.view.getHybridRouterView(widget.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(routerLinkElement?.getAttribute('title') ?? ''),
        actions: [
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: DayNightSwitcherIcon(
                isDarkModeEnabled: AdaptiveTheme.of(context).theme.brightness == Brightness.dark,
                onStateChanged: (isDarkModeEnabled) async {
                  // sets theme mode to dark
                  !isDarkModeEnabled ? AdaptiveTheme.of(context).setLight() : AdaptiveTheme.of(context).setDark();
                  controller.darkModeOverride = isDarkModeEnabled;
                  controller.view.onPlatformBrightnessChanged();
                },
              )),
        ],
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   print(context.findRenderObject()?.toStringDeep());
      // }),
      body: WebFRouterView(controller: controller, path: widget.path),
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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        navigatorObservers: [routeObserver],
        themeMode: ThemeMode.system,
        onGenerateInitialRoutes: (initialRoute) {
          return [
            CupertinoPageRoute(
              builder: (context) {
                return FirstPage(title: 'Landing Bay');
              },
            )
          ];
        },
        onGenerateRoute: (settings) {
          return CupertinoPageRoute(
            settings: settings,
            builder: (context) {
              Widget? entry = WebFControllerManager.instance.getRouterBuilderBySettings(context, settings);
              return entry ??
                  Scaffold(appBar: AppBar(title: Text('Error')), body: Center(child: Text('Page not found')));
            },
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() {
    return FirstPageState();
  }
}

class FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(children: [
        ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(webfPageName: 'html/css');
              }));
            },
            child: Text('Open HTML/CSS/JavaScript demo')),
        SizedBox(height: 18),
        ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(webfPageName: 'vuejs');
              }));
            },
            child: Text('Open Vue.js demo')),
        ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(
                  webfPageName: 'vuejs',
                  initialRoute: '/positioned_layout',
                );
              }));
            },
            child: Text('Open Vue.js demo Positioned Layout')),
        SizedBox(height: 18),
        ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(webfPageName: 'miracle_plus');
              }));
            },
            child: Text('Open MiraclePlus App')),
        ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(webfPageName: 'miracle_plus', initialRoute: '/login',);
              }));
            },
            child: Text('Open MiraclePlus App Login')),
        ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(webfPageName: 'cupertino_gallery');
              }));
            },
            child: Text('Open Cupertino Gallery')),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () {
        WebFControllerManager.instance.disposeAll();
      }),
    );
  }
}

class WebFDemo extends StatefulWidget {
  final String webfPageName;
  final String initialRoute;

  WebFDemo({required this.webfPageName, this.initialRoute = '/'});

  @override
  _WebFDemoState createState() => _WebFDemoState();
}

class _WebFDemoState extends State<WebFDemo> {
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
                    !isDarkModeEnabled ? AdaptiveTheme.of(context).setLight() : AdaptiveTheme.of(context).setDark();
                    WebFController? controller =
                        await WebFControllerManager.instance.getController(widget.webfPageName);
                    controller?.darkModeOverride = isDarkModeEnabled;
                    controller?.view.onPlatformBrightnessChanged();
                  },
                )),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          // WidgetsBinding.instance.performReassemble();
          // print(controller.view.getRootRenderObject()!.toStringDeep());
        }),
        body: Stack(
          children: [
            WebF.fromControllerName(
                controllerName: widget.webfPageName,
                loadingWidget: _buildSplashScreen(),
                initialRoute: widget.initialRoute)
          ],
        ));
  }

  Widget _buildSplashScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            width: 150,
            height: 150,
          ),
          SizedBox(height: 24),
          CupertinoActivityIndicator(
            radius: 14,
          ),
          SizedBox(height: 16),
          Text(
            '正在加载...',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
