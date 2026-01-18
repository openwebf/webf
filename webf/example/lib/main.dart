/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// ignore_for_file: avoid_print

import 'package:cronet_http/cronet_http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:flutter/cupertino.dart';
import 'package:webf_example/cronet_adapter.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'custom_hybrid_history_delegate.dart';

import 'package:webf_share/webf_share.dart';
import 'package:webf_sqflite/webf_sqflite.dart';
import 'package:webf_camera/webf_camera.dart';
import 'package:webf_video_player/webf_video_player.dart';
import 'package:webf_bluetooth/webf_bluetooth.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String demoEntryUrl = 'http://localhost:5173';
const String demoControllerName = 'demo';
const String demoInitialRoute = '/features';
const Map<String, dynamic>? demoInitialState = null;

bool? _resolveWebFDarkModeOverride(AdaptiveThemeMode mode) {
  if (mode.isSystem) return null;
  return mode.isDark;
}

void _syncAllWebFControllersDarkModeOverride(bool? darkModeOverride) {
  final controllerManager = WebFControllerManager.instance;
  for (final controllerName in controllerManager.controllerNames) {
    controllerManager.getControllerSync(controllerName)?.darkModeOverride = darkModeOverride;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final initialThemeMode = savedThemeMode ?? AdaptiveThemeMode.light;

  installWebFCupertinoUI();
  installWebFCamera();
  installWebFVideoPlayer();

  WebF.defineModule((context) => ShareModule(context));
  WebF.defineModule((context) => SQFliteModule(context));
  WebF.defineModule((context) => BluetoothModule(context));

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
      createController: () =>
          WebFController(
            enableBlink: false,
            routeObserver: routeObserver,
            initialRoute: demoInitialRoute,
            initialState: demoInitialState
          ),
      bundle: WebFBundle.fromUrl(demoEntryUrl),
      setup: (controller) {
        controller.hybridHistory.delegate = CustomHybridHistoryDelegate();
        controller.darkModeOverride = _resolveWebFDarkModeOverride(initialThemeMode);
      });

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class WebFSubView extends StatefulWidget {
  const WebFSubView({
    super.key,
    required this.path,
    required this.controller,
    this.pathParameters = const {},
    this.queryParameters = const {},
  });

  final WebFController controller;
  final String path;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

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
    final String baseTitle = routerLinkElement?.getAttribute('title') ?? '';
    final String paramsSummary = [
      ...widget.pathParameters.entries.map((e) => '${e.key}=${e.value}'),
      ...widget.queryParameters.entries.map((e) => '${e.key}=${e.value}'),
    ].join(', ');
    final String title = paramsSummary.isEmpty
        ? baseTitle
        : baseTitle.isEmpty
        ? paramsSummary
        : '$baseTitle ($paramsSummary)';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: DayNightSwitcherIcon(
                isDarkModeEnabled: AdaptiveTheme
                    .of(context)
                    .theme
                    .brightness == Brightness.dark,
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
  @override
  void initState() {
    super.initState();
  }

  Object? _buildHybridRouteArguments(GoRouterState state, {
    required Map<String, String> pathParameters,
    required Map<String, String> queryParameters,
  }) {
    if (state.extra is Map) {
      final merged = <String, dynamic>{};
      for (final entry in (state.extra as Map).entries) {
        merged[entry.key.toString()] = entry.value;
      }
      return <String, dynamic>{
        ...merged,
        if (pathParameters.isNotEmpty) 'pathParameters': pathParameters,
        if (queryParameters.isNotEmpty) 'queryParameters': queryParameters,
      };
    }
    if (state.extra != null) return state.extra;
    if (pathParameters.isEmpty && queryParameters.isEmpty) return null;
    return <String, dynamic>{
      'pathParameters': pathParameters,
      'queryParameters': queryParameters,
    };
  }

  late final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    observers: [routeObserver],
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const FirstPage(title: 'Landing Bay'),
      ),
      GoRoute(
        path: '/demo',
        pageBuilder: (context, state) =>
            MaterialPage<void>(
              key: state.pageKey,
              name: state.uri.toString(),
              child: const WebFDemo(
                webfPageName: demoControllerName,
                initialRoute: demoInitialRoute,
                initialState: demoInitialState,
              ),
            ),
      ),
      // Example of explicit dynamic routing with parameters.
      GoRoute(
        path: '/profile/:userId',
        name: 'webf-profile',
        pageBuilder: (context, state) => _buildWebFHybridRoutePage(state),
      ),
      // Universal catch-all for WebF hybrid router routes.
      GoRoute(
        path: '/:webfPath(.*)',
        name: 'universal-webf-route',
        pageBuilder: (context, state) => _buildWebFHybridRoutePage(state),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(
          appBar: AppBar(title: const Text('Route not found')),
          body: Center(child: Text(state.error?.toString() ?? 'Unknown routing error')),
        ),
  );

  Page<void> _buildWebFHybridRoutePage(GoRouterState state) {
    // Use the actual location path (not the matched pattern) so WebF can resolve dynamic hybrid routes.
    final String path = state.uri.path;

    // Avoid passing the universal catch-all param into the demo UI.
    final pathParameters = Map<String, String>.from(state.pathParameters)
      ..remove('webfPath');
    final queryParameters = state.uri.queryParameters;

    return MaterialPage<void>(
        key: state.pageKey,
        name: state.uri.toString(),
        arguments: _buildHybridRouteArguments(
          state,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        ),
        child: WebFRouterView.fromControllerName(
          controllerName: demoControllerName,
          path: path,
          builder: (context, controller) => WebFSubView(
            controller: controller,
            path: path,
            pathParameters: pathParameters,
            queryParameters: queryParameters,
          ),
          loadingWidget: _WebFDemoState.buildSplashScreen(),
        ),
        // child: WebFSubView(path: path, controller: controller, queryParameters: queryParameters,
        //     pathParameters: pathParameters)
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) =>
          _SystemThemeSync(
            child: MaterialApp.router(
                title: 'WebF Example App',
                theme: theme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.system,
                routerConfig: _router,
                debugShowCheckedModeBanner: false),
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key, required this.title});

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
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
                onPressed: () {
                  context.push('/demo');
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
    final themeManager = AdaptiveTheme.of(context);
    final bool? darkModeOverride = _resolveWebFDarkModeOverride(themeManager.mode);
    // bool isDarkModeEnabled = AdaptiveTheme.of(context).
    return Scaffold(
        appBar: AppBar(
          title: Text('WebF Demo'),
          actions: [
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: DayNightSwitcherIcon(
                  isDarkModeEnabled: AdaptiveTheme
                      .of(context)
                      .theme
                      .brightness == Brightness.dark,
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
                createController: () =>
                    WebFController(
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
                                  WebFBundle
                                      .fromUrl(demoEntryUrl)
                                      .resolvedUri!);
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
                        '📊 Largest Contentful Paint (LCP) ($status) at ${event
                            .parameters['timeSinceNavigationStart']}ms');
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
            'assets/webf.png',
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

class _SystemThemeSync extends StatefulWidget {
  const _SystemThemeSync({
    required this.child,
  });

  final Widget child;

  @override
  State<_SystemThemeSync> createState() => _SystemThemeSyncState();
}

class _SystemThemeSyncState extends State<_SystemThemeSync> with WidgetsBindingObserver {
  AdaptiveThemeManager<ThemeData>? _themeManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final nextThemeManager = AdaptiveTheme.maybeOf(context);
    if (nextThemeManager == null || _themeManager == nextThemeManager) return;

    _themeManager?.modeChangeNotifier.removeListener(_handleThemeModeChanged);
    _themeManager = nextThemeManager;
    _themeManager!.modeChangeNotifier.addListener(_handleThemeModeChanged);

    _syncAllWebFControllersDarkModeOverride(_resolveWebFDarkModeOverride(_themeManager!.mode));
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    // System theme switch: reset app theme to follow system and let WebF follow system.
    final themeManager = _themeManager ?? AdaptiveTheme.maybeOf(context);
    if (themeManager == null) return;

    if (!themeManager.mode.isSystem) {
      themeManager.setSystem();
    }
    _syncAllWebFControllersDarkModeOverride(null);
  }

  void _handleThemeModeChanged() {
    final themeManager = _themeManager;
    if (themeManager == null) return;

    _syncAllWebFControllersDarkModeOverride(_resolveWebFDarkModeOverride(themeManager.mode));
  }

  @override
  void dispose() {
    _themeManager?.modeChangeNotifier.removeListener(_handleThemeModeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
