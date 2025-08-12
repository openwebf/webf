/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:io';

import 'package:cronet_http/cronet_http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:flutter/cupertino.dart';
import 'package:webf_example/cronet_adapter.dart';
import 'custom_elements/icon.dart';
import 'custom_elements/search.dart';
import 'custom_elements/select.dart';
import 'custom_elements/button.dart';
import 'custom_elements/bottom_sheet.dart';
import 'custom_elements/tab.dart';
import 'custom_elements/switch.dart';
import 'custom_elements/slider.dart';
import 'custom_elements/svg_img.dart';
import 'custom_elements/show_case_view.dart';
import 'custom_elements/custom_listview_cupertino.dart';
import 'custom_elements/custom_listview_material.dart';
import 'custom_elements/flutter_sliver_listview.dart';
import 'keyboard_case/popup.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:app_links/app_links.dart';

import 'custom_hybrid_history_delegate.dart';
import 'custom_listview.dart';
import 'modules/test_array_buffer.dart';
import 'modules/share.dart';
import 'modules/deeplink.dart';
import 'flutter_ui_handler.dart';
import 'flutter_interaction_handler.dart';
import 'custom_elements/nested_scrollable.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  installWebFCupertinoUI();

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
  WebF.defineCustomElement('test-flutter-popup', (context) => FlutterPopup(context));
  WebF.defineCustomElement('test-flutter-popup-item', (context) => FlutterPopupItem(context));
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
  WebF.defineCustomElement('flutter-showcase-view', (context) => FlutterShowCaseView(context));
  WebF.defineCustomElement('flutter-showcase-item', (context) => FlutterShowCaseItem(context));
  WebF.defineCustomElement('flutter-showcase-description', (context) => FlutterShowCaseDescription(context));
  WebF.defineCustomElement('webf-listview-cupertino', (context) => CustomWebFListViewWithCupertinoRefreshIndicator(context));
  WebF.defineCustomElement('webf-listview-material', (context) => CustomWebFListViewWithMeterialRefreshIndicator(context));

  WebF.defineCustomElement('flutter-nest-scroller-skeleton', (context) => FlutterNestScrollerSkeleton(context));
  WebF.defineCustomElement(
      'flutter-nest-scroller-item-top-area', (context) => FlutterNestScrollerSkeletonItemTopArea(context));
  WebF.defineCustomElement('flutter-nest-scroller-item-persistent-header',
      (context) => FlutterNestScrollerSkeletonItemPersistentHeader(context));
  WebF.defineCustomElement('flutter-sliver-listview', (context) => FlutterSliverListview(context));
  WebF.defineModule((context) => TestModule(context));
  WebF.defineModule((context) => ShareModule(context));
  WebF.defineModule((context) => DeepLinkModule(context));

  // Add home controller with preloading
  WebFControllerManager.instance.addWithPreload(
      name: 'miracle_plus',
      createController: () => WebFController(
          routeObserver: routeObserver,
          initialRoute: '/',
          networkOptions: WebFNetworkOptions(
            android: WebFNetworkOptions(
                httpClientAdapter: () async {
                  String cacheDirectory =
                      await HttpCacheController.getCacheDirectory(Uri.parse('https://miracleplus.openwebf.com/'));
                  CronetEngine cronetEngine = CronetEngine.build(
                      cacheMode: (kReleaseMode || kProfileMode) ? CacheMode.disk : CacheMode.memory,
                      cacheMaxSize: 24 * 1024 * 1024,
                      enableBrotli: true,
                      enableHttp2: true,
                      enableQuic: true,
                      storagePath: (kReleaseMode || kProfileMode) ? cacheDirectory : null);
                  return CronetAdapter(cronetEngine);
                },
                enableHttpCache: false // Cronet have it's own http cache impls
                ),
          ),
          // dioHttpClientAdapterAndroid: CronetAdapter(cronetEngine),
          // dioHttpClientAdapter: NativeAdapter(),
          onLCP: (time, isEvaluated) {
            print('LCP time: $time, evaluated: $isEvaluated');
          },
          onLCPContentVerification: (contentInfo, routePath) {
            print('contentInfo: $contentInfo');
          },
          httpLoggerOptions: HttpLoggerOptions(
            requestHeader: true,
            requestBody: true,
          ),
          onControllerInit: (controller) async {
            // Built-in once-only error dump with debounce and per-load reset
            controller.loadingState.onFinalLargestContentfulPaint((event) {
              final dump = controller.dumpLoadingState(
                options: LoadingStateDumpOptions.html |
                    LoadingStateDumpOptions.api |
                    LoadingStateDumpOptions.scripts |
                    LoadingStateDumpOptions.networkDetailed,
              );
              debugPrint(dump.toStringFiltered());
            });

            // controller.loadingState.onFinalLargestContentfulPaint((_) {
            //   if (!hasReported) {
            //     LoadingStateDump dump = controller.dumpLoadingState(
            //         options: LoadingStateDumpOptions.html |
            //             LoadingStateDumpOptions.api |
            //             LoadingStateDumpOptions.scripts |
            //             LoadingStateDumpOptions.networkDetailed);
            //     print(dump.toString());
            //   }
            //   hasReported = true;
            // });
          }),
      bundle: WebFBundle.fromUrl('https://miracleplus.openwebf.com/'),
      setup: (controller) {
        controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
        controller.darkModeOverride = savedThemeMode?.isDark;
      });

  // // Add vue controller with preloading
  // WebFControllerManager.instance.addWithPrerendering(
  //     name: 'miracle_plus',
  //     createController: () => WebFController(
  //           initialRoute: '/home',
  //           routeObserver: routeObserver,
  //         ),
  //     bundle: WebFBundle.fromUrl('https://miracleplus.openwebf.com/'),
  //     setup: (controller) {
  //       controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
  //       controller.darkModeOverride = savedThemeMode?.isDark;
  //     });
  //
  // // Add vue controller with preloading
  // WebFControllerManager.instance.addWithPrerendering(
  //     name: 'cupertino_gallery',
  //     createController: () => WebFController(
  //       initialRoute: '/',
  //       routeObserver: routeObserver,
  //     ),
  //     bundle: WebFBundle.fromUrl('https://vue-cupertino-gallery.openwebf.com/'),
  //     setup: (controller) {
  //       controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
  //       controller.darkModeOverride = savedThemeMode?.isDark;
  //     });
  //
  // // Add react use cases controller with preloading for image preload test
  // WebFControllerManager.instance.addWithPreload(
  //     name: 'react_use_cases',
  //     createController: () => WebFController(
  //           routeObserver: routeObserver,
  //           // devToolsService: kDebugMode ? ChromeDevToolsService() : null,
  //         ),
  //     bundle: WebFBundle.fromUrl('http://localhost:3000/'),
  //     setup: (controller) {
  //       controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
  //       controller.darkModeOverride = savedThemeMode?.isDark;
  //
  //       // Set up method call handler for FlutterInteractionPage using dedicated handler
  //       controller.javascriptChannel.onMethodCall = FlutterInteractionHandler().handleMethodCall;
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
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();

    // Initialize app links
    _appLinks = AppLinks();

    // Set up deep link navigation callback - but don't use Navigator in initState
    DeepLinkModule.setNavigationCallback((String target, Map<String, String> params) async {
      if (target == 'react_use_cases') {
        // Get the page parameter to determine route
        final page = params['page'];
        String targetRoute = '/';

        // Map page parameter to specific routes
        if (page != null) {
          switch (page) {
            case 'deeplink':
              targetRoute = '/deeplink';
              break;
            case 'animation':
              targetRoute = '/animation';
              break;
            case 'video':
              targetRoute = '/video';
              break;
            case 'network':
              targetRoute = '/network';
              break;
            default:
              targetRoute = '/';
          }
        }

        // Check if react_use_cases controller already exists
        WebFController? existingController = await WebFControllerManager.instance.getController('react_use_cases');

        if (existingController != null && webfPageName.value == 'react_use_cases') {
          // If controller exists and we're already on the react_use_cases page,
          // use hybridHistory to navigate within the existing page
          print('Using existing controller, navigating to: $targetRoute');
          existingController.hybridHistory.pushState(params, targetRoute);
        } else {
          // Set page name and navigate after a short delay to ensure UI is ready
          webfPageName.value = 'react_use_cases';
          print('Set page to react_use_cases with route: $targetRoute');

          // Use a delayed navigation to ensure the Navigator is ready
          Future.delayed(Duration(milliseconds: 100), () async {
            final context = navigatorKey.currentContext;
            if (context != null && mounted) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebFDemo(
                  webfPageName: 'react_use_cases',
                  initialRoute: targetRoute,
                );
              }));
            }
          });
        }
      }
    });

    // Listen for incoming app links when app is already running
    _appLinks.uriLinkStream.listen((Uri uri) {
      print('Received app link: $uri');
      _handleIncomingLink(uri.toString());
    });

    // Handle initial deep link when app is launched from closed state
    _handleInitialLink();
  }

  void _handleInitialLink() async {
    // Add a small delay to ensure the app is fully initialized
    await Future.delayed(Duration(milliseconds: 500));

    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        print('App launched with link: $initialLink');
        _handleIncomingLink(initialLink.toString());
      }
    } catch (e) {
      print('Failed to get initial app link: $e');
    }
  }

  void _handleIncomingLink(String url) async {
    final result = await DeepLinkModule.processDeepLink(url);
    print('Deep link processing result: $result');
  }

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
        navigatorKey: navigatorKey,
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
                  widget.webfPageName.value = 'esm_demo';
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return WebFDemo(
                      webfPageName: 'esm_demo',
                      initialRoute: '/',
                    );
                  }));
                },
                child: Text('Open ES Module Demo')),
            SizedBox(height: 18),
            ElevatedButton(
                onPressed: () {
                  widget.webfPageName.value = 'import_meta_demo';
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return WebFDemo(
                      webfPageName: 'import_meta_demo',
                      initialRoute: '/',
                    );
                  }));
                },
                child: Text('Open ES Module Import Meta Demo')),
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
                      initialRoute: '/',
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
                child: Text('Open Use Cases (Vue.js)')),
            SizedBox(height: 18),
            ElevatedButton(
                onPressed: () {
                  widget.webfPageName.value = 'react_use_cases';
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return WebFDemo(webfPageName: 'react_use_cases');
                  }));
                },
                child: Text('Open Use Cases (React.js)')),
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
    // return WebFBundle.fromUrl('http://127.0.0.1:3300/kraken_debug_server.js');
    case 'esm_demo':
      return WebFBundle.fromUrl('assets:///assets/esm_demo.html');
    case 'import_meta_demo':
      return WebFBundle.fromUrl('assets:///assets/import_meta_demo.html');
    case 'vuejs':
      return WebFBundle.fromUrl('assets:///vue_project/dist/index.html');
    case 'reactjs':
      return WebFBundle.fromUrl('http://localhost:3000/react_project/build');
    case 'miracle_plus':
      return WebFBundle.fromUrl('https://miracleplus.openwebf.com/');
    case 'hybrid_router':
      return WebFBundle.fromUrl('assets:///hybrid_router/build/index.html');
    case 'tailwind_react':
      return WebFBundle.fromUrl('assets:///tailwind_react/build/index.html');
    case 'cupertino_gallery':
      return WebFBundle.fromUrl('https://vue-cupertino-gallery.openwebf.com/');
    case 'use_cases':
      return WebFBundle.fromUrl('assets:///use_cases/dist/index.html');
    case 'react_use_cases':
      return WebFBundle.fromUrl('https://usecase.openwebf.com/');
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
    // Set context for FlutterUIHandler
    FlutterUIHandler().setContext(context);

    bool darkModeOverride = AdaptiveTheme.of(context).theme.brightness == Brightness.dark;
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
                      initialRoute: widget.initialRoute,
                      onControllerInit: (controller) async {},
                      httpLoggerOptions: HttpLoggerOptions(
                        requestHeader: true,
                        requestBody: true,
                      ),
                    networkOptions: WebFNetworkOptions(
                      android: WebFNetworkOptions(
                          httpClientAdapter: () async {
                            String cacheDirectory =
                            await HttpCacheController.getCacheDirectory(_getBundleForControllerName(widget.webfPageName)!.resolvedUri!);
                            CronetEngine cronetEngine = CronetEngine.build(
                                cacheMode: (kReleaseMode || kProfileMode) ? CacheMode.disk : CacheMode.memory,
                                cacheMaxSize: 24 * 1024 * 1024,
                                enableBrotli: true,
                                enableHttp2: true,
                                enableQuic: true,
                                storagePath: (kReleaseMode || kProfileMode) ? cacheDirectory : null);
                            return CronetAdapter(cronetEngine);
                          },
                          enableHttpCache: false // Cronet have it's own http cache impls
                      ),
                    ),
                      onLCPContentVerification: (ContentInfo contentInfo, String routePath) {
                        print('contentInfo: $contentInfo $routePath');
                      },
                      onLCP: (time, isEvaluated) {
                        print('LCP time: $time ms, evaluated: $isEvaluated');
                      },
                    ),
                setup: (controller) {
                  controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
                  controller.darkModeOverride = darkModeOverride;

                  // Register event listeners for all main phases
                  controller.loadingState.onConstructor((event) {
                    print('🏗️ Constructor at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onInit((event) {
                    print('🚀 Initialize at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onPreload((event) {
                    print('📦 Preload at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onResolveEntrypointStart((event) {
                    print('🔍 Resolve Entrypoint Start at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onResolveEntrypointEnd((event) {
                    print('✅ Resolve Entrypoint End at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onParseHTMLStart((event) {
                    print('📄 Parse HTML Start at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onParseHTMLEnd((event) {
                    print('✅ Parse HTML End at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onScriptQueue((event) {
                    print('📋 Script Queue at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onScriptLoadStart((event) {
                    print('📥 Script Load Start at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onScriptLoadComplete((event) {
                    print('✅ Script Load Complete at ${event.elapsed.inMilliseconds}ms ${event.parameters}');
                  });

                  controller.loadingState.onAttachToFlutter((event) {
                    print('🔗 Attach to Flutter at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onScriptExecuteStart((event) {
                    print('▶️ Script Execute Start at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onScriptExecuteComplete((event) {
                    print('✅ Script Execute Complete at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onDOMContentLoaded((event) {
                    print('📄 DOM Content Loaded at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onWindowLoad((event) {
                    print('🪟 Window Load at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onBuildRootView((event) {
                    print('🏗️ Build Root View at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onFirstPaint((event) {
                    print('🎨 First Paint (FP) at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onFirstContentfulPaint((event) {
                    print('🖼️ First Contentful Paint (FCP) at ${event.elapsed.inMilliseconds}ms');
                  });

                  controller.loadingState.onLargestContentfulPaint((event) {
                    final isCandidate = event.parameters['isCandidate'] ?? false;
                    final isFinal = event.parameters['isFinal'] ?? false;
                    final status = isFinal ? 'FINAL' : (isCandidate ? 'CANDIDATE' : 'UNKNOWN');
                    print(
                        '📊 Largest Contentful Paint (LCP) ($status) at ${event.parameters['timeSinceNavigationStart']}ms');
                  });
                }),
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
