/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Widget buildSplashScreen() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6B5B95),
          Color(0xFF88B0D3),
        ],
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // WebF Logo or Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'WebF',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B5B95),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          // Loading indicator
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading WebF Application',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installWebFCupertinoUI();

  // Initialize the controller manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
    maxAliveInstances: 4,
    maxAttachedInstances: 2,
    onControllerDisposed: (String name, WebFController controller) {
      print('controller disposed: $name $controller');
    },
    onControllerDetached: (String name, WebFController controller) {
      print('controller detached: $name $controller');
    },
  ));

  // Add default test controller with preloading
  WebFControllerManager.instance.addWithPreload(
    name: 'react_use_case',
    createController: () => WebFController(
      routeObserver: routeObserver,
      initialRoute: '/',
    ),
    bundle: WebFBundle.fromUrl('https://usecase.openwebf.com/'),
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  final ValueNotifier<String> webfPageName = ValueNotifier('react_use_case');

  Route<dynamic>? handleOnGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return WebFRouterView.fromControllerName(
            controllerName: webfPageName.value,
            path: settings.name!,
            builder: (context, controller) {
              return WebFSubView(
                  controller: controller,
                  path: settings.name!,
                  onAppBarCreated: (title, routeLinkElement) => AppBar(title: Text(title)));
            },
            loadingWidget: buildSplashScreen());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebF Integration Test',
      initialRoute: '/',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      onGenerateRoute: handleOnGenerateRoute,
      themeMode: ThemeMode.system,
      home: TestHomePage(webfPageName: webfPageName),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key, required this.webfPageName});
  final ValueNotifier<String> webfPageName;

  @override
  State<StatefulWidget> createState() {
    return TestHomePageState();
  }
}

class TestHomePageState extends State<TestHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebF Integration Test Home'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.webfPageName.value = 'react_use_case';
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return WebFTestPage(
                        webfPageName: 'react_use_case',
                        initialRoute: '/',
                      );
                    }));
                  },
                  child: Text('Open React Show Case'),
                )
              ],
            ),
          ),
          if (kDebugMode) WebFInspectorFloatingPanel(),
        ],
      ),
    );
  }
}

class WebFTestPage extends StatefulWidget {
  final String webfPageName;
  final String initialRoute;
  final Map<String, dynamic>? initialState;

  const WebFTestPage({super.key, 
    required this.webfPageName,
    this.initialRoute = '/',
    this.initialState,
  });

  @override
  _WebFTestPageState createState() => _WebFTestPageState();
}

class _WebFTestPageState extends State<WebFTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebF Show Case'),
      ),
      body: Stack(
        children: [
          WebF.fromControllerName(
            controllerName: widget.webfPageName,
            loadingWidget: buildSplashScreen(),
          ),
          if (kDebugMode) WebFInspectorFloatingPanel(),
        ],
      ),
    );
  }
}
