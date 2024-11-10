/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:webf/webf.dart';
import 'package:webf_integration_tests/bridge/match_snapshots.dart';

String? pass = (AnsiPen()..green())('[TEST PASS]');
String? err = (AnsiPen()..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
final String testDirectory = Platform.environment['WEBF_TEST_DIR'] ?? __dirname;
final GlobalKey<RootPageState> rootPageKey = GlobalKey();

final bool isPreloadMode = Platform.environment['LOAD_MODE'] == 'preload';
final String specFolder =
    isPreloadMode ? 'preload_page_specs' : 'prerendering_page_specs';
final specDir = Directory(path.join(testDirectory, specFolder));
final List<FileSystemEntity> specs = specDir.listSync();
final List<CodeUnit> codes =
    specs.where((element) => !element.path.contains('.DS_Store')).map((spec) {
  final fileName = getFileName(spec.path);
  final List<FileSystemEntity> files = Directory(spec.path).listSync();

  bool haveEntry = files.any((entity) => entity.path.contains('index.html'));
  if (!haveEntry) {
    throw FlutterError('Can not find index.html in spec dir');
  }

  return CodeUnit(fileName, path.join(spec.path, 'index.html'));
}).toList();

PageController pageController = PageController();

// Test for UriParser.
class IntegrationTestUriParser extends UriParser {
  @override
  Uri resolve(Uri base, Uri relative) {
    if (base.toString().isEmpty && relative.path.startsWith('assets/')) {
      return Uri.file(relative.path);
    } else {
      return super.resolve(base, relative);
    }
  }
}

class PreRenderingPageState extends State<PreRenderingPage> {
  late WebFController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('Loading ${widget.name}');
    controller = WebFController(context,
        viewportWidth: 360,
        viewportHeight: 640, onDOMContentLoaded: (controller) async {
      await sleep(Duration(seconds: 1));
      Uint8List snapshot = await controller.view.document.documentElement!
          .toBlob(devicePixelRatio: 1);
      bool isMatch = await matchImageSnapshot(snapshot, widget.path);
      if (!isMatch) {
        throw FlutterError('Snapshot of ${widget.name} is not match');
      }
      Navigator.pop(context);
    }, uriParser: IntegrationTestUriParser());
  }

  void navigateBack() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  WebF? webf;

  @override
  Widget build(BuildContext context) {
    WebFBundle entrypoint = WebFBundle.fromUrl('file://${widget.path}?time=${DateTime.now().microsecondsSinceEpoch}');
    return FutureBuilder(
        future: isPreloadMode
            ? controller.preload(entrypoint)
            : controller.preRendering(entrypoint),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print('Current Load mode: ${controller.mode}');
            return WebF(controller: controller);
          }

          return Container();
        });
  }
}

class WaitingBayState extends State<WaitingBay> {
  @override
  void didUpdateWidget(covariant WaitingBay oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class WaitingBay extends StatefulWidget {
  final String path;

  WaitingBay(this.path);

  @override
  State<StatefulWidget> createState() {
    return WaitingBayState();
  }
}

class PreRenderingPage extends StatefulWidget {
  final String path;
  final String name;

  PreRenderingPage(this.name, this.path, {super.key});

  @override
  State<StatefulWidget> createState() {
    var state = PreRenderingPageState();
    return state;
  }
}

class MultiplePageKey extends LabeledGlobalKey<PreRenderingPageState> {
  final String name;

  MultiplePageKey(this.name) : super('$name');

  @override
  bool operator ==(other) {
    return other is MultiplePageKey && other.name == name;
  }

  @override
  int get hashCode => super.hashCode;
}

class PageController {
  Map<String, MultiplePageKey> _keys = {};

  MultiplePageKey createKey(String name) {
    MultiplePageKey key = MultiplePageKey(name);
    _keys[name] = key;
    return key;
  }

  PreRenderingPageState? state(String name) => _keys[name]!.currentState;

  WebFController getWebF(String name) {
    return _keys[name]!.currentState!.webf!.controller!;
  }
}

class RootPage extends StatefulWidget {
  RootPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return RootPageState();
  }
}

class RootPageState extends State<RootPage> {
  BuildContext? _context;

  Future<void> navigateToPage(String nextPage) {
    return Navigator.pushNamed(_context!, '/$nextPage');
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Center(child: Text('root'));
  }
}

class CodeUnit {
  final String name;
  final String path;

  CodeUnit(this.name, this.path);

  @override
  String toString() {
    return 'CodeUnit($name)';
  }
}

Map<String, WidgetBuilder> buildRoutes(
    PageController pageController, List<CodeUnit> codes) {
  Map<String, WidgetBuilder> routes = {};
  codes.forEach((code) {
    routes['/${code.name}'] = (context) => Scaffold(
          body: Scaffold(
              appBar: AppBar(title: Text(code.name)),
              body: PreRenderingPage(code.name, code.path,
                  key: pageController.createKey(code.name))),
        );
  });
  routes['/'] = (context) => Scaffold(body: FirstRoute(key: rootPageKey));
  return routes;
}

String getFileName(String path) {
  return path.split('/').last;
}

ContentType getFileContentType(String fileName) {
  if (fileName.contains('.html')) {
    return htmlContentType;
  }
  if (fileName.contains('.kbc')) {
    return webfBc1ContentType;
  }
  return javascriptContentType;
}

Future<void> sleep(Duration duration) {
  Completer completer = Completer();
  Timer(duration, () async {
    completer.complete();
  });
  return completer.future;
}

Future<void> runWithMultiple(AsyncCallback callback, int multipleTime) async {
  for (int i = 0; i < multipleTime; i++) {
    await callback();
  }
}

class HomePageElement extends StatelessElement {
  HomePageElement(super.widget);

  static CodeUnit current = codes.first;
  static int currentIndex = 0;

  @override
  void mount(Element? parent, Object? newSlot) async {
    super.mount(parent, newSlot);

    await runWithMultiple(() async {
      await runWithMultiple(() async {
        await sleep(Duration(seconds: 1));
        await Navigator.pushNamed(this, '/' + current.name);
      }, 1);

      if (currentIndex < codes.length - 1) {
        current = codes[currentIndex + 1];
        currentIndex = currentIndex + 1;
      }

      await sleep(Duration(seconds: 1));
    }, codes.length);

    exit(0);
  }
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  StatelessElement createElement() {
    return HomePageElement(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Leak Home'),
      ),
      body: Center(
        child: ListView(
            children: codes.map((code) {
          return Container(
            padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: ElevatedButton(
              style: ButtonStyle(),
              child: Text('Open ${code.name}'),
              onPressed: () {
                Navigator.pushNamed(context, '/' + code.name);
              },
            ),
          );
        }).toList()),
      ),
    );
  }
}

typedef onPushCallback = void Function();
typedef onPopCallback = void Function();

class PreRenderingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
  }

// Add other overrides if you need them, like didReplace or didRemove
}

class PreRenderingTester extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [PreRenderingNavigatorObserver()],
      routes: buildRoutes(pageController, codes),
    );
  }
}

void main() {
  runZonedGuarded(() {
    runApp(PreRenderingTester());
  }, (error, stacktrace) {
    print('$error\n$stacktrace');
    exit(1);
  });
}
