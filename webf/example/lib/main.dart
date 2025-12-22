/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cronet_http/cronet_http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:flutter/cupertino.dart';
import 'package:webf_example/cronet_adapter.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'custom_hybrid_history_delegate.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String demoEntryUrl = 'http://localhost:5173';
const String demoControllerName = 'demo';
const String demoInitialRoute = '/';
const Map<String, dynamic>? demoInitialState = null;

void main() async {
  DebugFlags.enableImageLogs = true;
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

  // Add react use cases controller with preloading for image preload test
  WebFControllerManager.instance.addWithPrerendering(
      name: demoControllerName,
      createController: () => WebFController(
        enableBlink: false,
            routeObserver: routeObserver,
          ),
      bundle: WebFBundle.fromUrl(demoEntryUrl),
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

  const MyApp({super.key, required this.savedThemeMode});

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  final ValueNotifier<String> webfPageName = ValueNotifier('');
  @override
  void initState() {
    super.initState();
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
  const FirstPage({super.key, required this.title, required this.webfPageName});

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
          Center(
            child: ElevatedButton(
                onPressed: () {
                  widget.webfPageName.value = demoControllerName;
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return WebFDemo(
                      webfPageName: demoControllerName,
                      initialRoute: demoInitialRoute,
                      initialState: demoInitialState,
                    );
                  }));
                },
                child: Text('Open demo')),
          ),
          WebFInspectorFloatingPanel(),
        ],
      ),
    );
  }
}

class WebFDemo extends StatefulWidget {
  final String webfPageName;
  final String initialRoute;
  final Map<String, dynamic>? initialState;

  const WebFDemo({super.key, required this.webfPageName, this.initialRoute = '/', this.initialState});

  @override
  State<WebFDemo> createState() => _WebFDemoState();
}

class _WebFDemoState extends State<WebFDemo> {
  @override
  Widget build(BuildContext context) {
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
                bundle: WebFBundle.fromUrl(demoEntryUrl),
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
                              String cacheDirectory = await HttpCacheController.getCacheDirectory(
                                  WebFBundle.fromUrl(demoEntryUrl).resolvedUri!);
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
            'Loading...',
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
