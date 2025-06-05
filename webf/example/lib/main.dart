/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:webf/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File;

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
import 'custom_elements/show_case_view.dart';
import 'custom_elements/custom_listview_cupertino.dart';
import 'custom_elements/custom_listview_material.dart';
import 'custom_elements/form.dart';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'custom_hybrid_history_delegate.dart';
import 'custom_listview.dart';
import 'modules/test_array_buffer.dart';
import 'modules/share.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  // Initialize the controller manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
      maxAliveInstances: 4,
      maxAttachedInstances: 1,
      onControllerDisposed: (String name, WebFController controller) {
        print('controller disposed: $name $controller');
      },
      onControllerDetached: (String name, WebFController controller) {
        print('controller detached: $name $controller');
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
  WebF.defineCustomElement('flutter-showcase-view', (context) => FlutterShowCaseView(context));
  WebF.defineCustomElement('flutter-showcase-item', (context) => FlutterShowCaseItem(context));
  WebF.defineCustomElement('flutter-showcase-description', (context) => FlutterShowCaseDescription(context));
  WebF.defineCustomElement('webf-listview-cupertino', (context) => CustomWebFListViewWithCupertinoRefreshIndicator(context));
  WebF.defineCustomElement('webf-listview-material', (context) => CustomWebFListViewWithMeterialRefreshIndicator(context));
  WebF.defineCustomElement('flutter-webf-form', (context) => FlutterWebFForm(context));
  WebF.defineCustomElement('flutter-webf-form-field', (context) => FlutterWebFFormField(context));
  WebF.defineModule((context) => TestModule(context));
  WebF.defineModule((context) => ShareModule(context));

  installWebFCupertino();

  // Add home controller with preloading
  // WebFControllerManager.instance.addWithPreload(
  //     name: 'html/css',
  //     createController: () => WebFController(
  //           routeObserver: routeObserver,
  //           devToolsService: kDebugMode ? ChromeDevToolsService() : null,
  //         ),
  //     bundle: WebFBundle.fromUrl('assets:///assets/bundle.html'),
  //     setup: (controller) {
  //       controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
  //       controller.darkModeOverride = savedThemeMode?.isDark;
  //     });
  //
  // // Add vue controller with preloading
  // WebFControllerManager.instance.addWithPrerendering(
  //     name: 'miracle_plus',
  //     createController: () => WebFController(
  //           initialRoute: '/home',
  //           routeObserver: routeObserver,
  //           devToolsService: kDebugMode ? ChromeDevToolsService() : null,
  //         ),
  //     bundle: WebFBundle.fromUrl('assets:///news_miracleplus/dist/index.html'),
  //     setup: (controller) {
  //       controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
  //       controller.darkModeOverride = savedThemeMode?.isDark;
  //     });

  WebF.overrideCustomElement('webf-listview', (context) => CustomWebFListView(context));

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
                  // Removed call to view.onPlatformBrightnessChanged as it's no longer needed
                  // The darkModeOverride setter now handles updating styles and dispatching events
                },
              )),
        ],
      ),
      body: Stack(
        children: [
          WebFRouterView(controller: controller, path: widget.path),
          WebFInspectorFloatingPanel(),
        ],
      ),
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
  final ValueNotifier<String> webfPageName = ValueNotifier('');

  Route<dynamic>? handleOnGenerateRoute(RouteSettings settings) {
    return CupertinoPageRoute(
      settings: settings,
      builder: (context) {
        return WebFRouterView.fromControllerName(
            controllerName: webfPageName.value,
            path: settings.name!,
            builder: (context, controller) {
              return WebFSubView(controller: controller, path: settings.name!);
            },
            loadingWidget: _WebFDemoState.buildSplashScreen());
      },
    );
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
                return ValueListenableBuilder(
                    valueListenable: webfPageName,
                    builder: (context, value, child) {
                      return FirstPage(title: 'Landing Bay', webfPageName: webfPageName);
                    });
              },
            )
          ];
        },
        onGenerateRoute: handleOnGenerateRoute,
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
  const FirstPage({Key? key, required this.title, required this.webfPageName}) : super(key: key);
  final String title;
  final ValueNotifier<String> webfPageName;

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
      body: Stack(
        children: [
          ListView(children: [
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'html/css';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(
                  webfPageName: 'html/css',
                  initialRoute: '/',
                );
              }));
            },
            child: Text('Open HTML/CSS/JavaScript demo')),
        SizedBox(height: 18),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'vuejs';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(webfPageName: 'vuejs');
              }));
            },
            child: Text('Open Vue.js demo')),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'vuejs';
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
              widget.webfPageName.value = 'reactjs';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(
                  webfPageName: 'reactjs',
                );
              }));
            },
            child: Text('Open React.js demo')),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'reactjs';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(
                  webfPageName: 'reactjs',
                  initialRoute: '/array-buffer-demo',
                );
              }));
            },
            child: Text('Open ArrayBuffer Demo')),
        SizedBox(height: 10),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'tailwind_react';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(
                  webfPageName: 'tailwind_react',
                  initialRoute: '/',
                );
              }));
            },
            child: Text('Open React.js with TailwindCSS 3')),
        SizedBox(height: 10),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'miracle_plus';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(
                  webfPageName: 'miracle_plus',
                  initialRoute: '/home',
                  initialState: {'name': 1},
                );
              }));
            },
            child: Text('Open MiraclePlus App')),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'miracle_plus';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(
                  webfPageName: 'miracle_plus',
                  initialRoute: '/login',
                );
              }));
            },
            child: Text('Open MiraclePlus App Login')),
        SizedBox(height: 18),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'hybrid_router';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(webfPageName: 'hybrid_router');
              }));
            },
            child: Text('Open Hybrid Router Example')),
        SizedBox(height: 18),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'cupertino_gallery';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(webfPageName: 'cupertino_gallery');
              }));
            },
            child: Text('Open Cupertino Gallery')),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'cupertino_gallery';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(
                  webfPageName: 'cupertino_gallery',
                  initialRoute: '/button',
                );
              }));
            },
            child: Text('Open Cupertino Gallery / Button')),
        SizedBox(height: 18),
        ElevatedButton(
            onPressed: () {
              widget.webfPageName.value = 'use_cases';
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(webfPageName: 'use_cases');
              }));
            },
            child: Text('Open Use Cases')),
          ]),
          WebFInspectorFloatingPanel(),
        ],
      ),
    );
  }
}

// Helper method to determine the appropriate bundle based on controller name
WebFBundle? _getBundleForControllerName(String controllerName) {
  switch (controllerName) {
    case 'html/css':
      return WebFBundle.fromUrl('assets:///assets/bundle.html');
    case 'vuejs':
      return WebFBundle.fromUrl('assets:///vue_project/dist/index.html');
    case 'reactjs':
      return WebFBundle.fromUrl('assets:///react_project/build/index.html');
    case 'miracle_plus':
      return WebFBundle.fromUrl('assets:///news_miracleplus/dist/index.html');
    case 'hybrid_router':
      return WebFBundle.fromUrl('assets:///hybrid_router/build/index.html');
    case 'tailwind_react':
      return WebFBundle.fromUrl('http://192.168.50.228:3000/tailwind_react/build');
    case 'cupertino_gallery':
      return WebFBundle.fromUrl('assets:///cupertino_gallery/dist/index.html');
    case 'use_cases':
      return WebFBundle.fromUrl('assets:///use_cases/dist/index.html');
    default:
      // Return null if the controller name is not recognized
      return null;
  }
}

class WebFDemo extends StatefulWidget {
  final String webfPageName;
  final String initialRoute;
  final Map<String, dynamic>? initialState;

  WebFDemo({required this.webfPageName, this.initialRoute = '/', this.initialState});

  @override
  _WebFDemoState createState() => _WebFDemoState();
}

class _WebFDemoState extends State<WebFDemo> {
  @override
  Widget build(BuildContext context) {
    bool darkModeOverride =  AdaptiveTheme.of(context).theme.brightness == Brightness.dark;
    // bool isDarkModeEnabled = AdaptiveTheme.of(context).
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
                    // Removed call to view.didChangePlatformBrightness as it's no longer needed
                    // The darkModeOverride setter now handles updating styles and dispatching events
                  },
                )),
          ],
        ),
        body: Stack(
          children: [
            WebF.fromControllerName(
              controllerName: widget.webfPageName,
              loadingWidget: buildSplashScreen(),
              initialRoute: widget.initialRoute,
              initialState: widget.initialState,
              bundle: _getBundleForControllerName(widget.webfPageName),
              createController: () => WebFController(
                routeObserver: routeObserver,
                devToolsService: kDebugMode ? ChromeDevToolsService() : null,
                initialRoute: widget.initialRoute,
              ),
              setup: (controller) {
                controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
                controller.darkModeOverride = darkModeOverride;
              }
            ),
            WebFInspectorFloatingPanel(),
          ],
        ));
  }

  static Widget buildSplashScreen() {
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
