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
import 'utils/mem_leak_detector.dart';

String? pass = (AnsiPen()..green())('[TEST PASS]');
String? err = (AnsiPen()..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
final String testDirectory = Platform.environment['WEBF_TEST_DIR'] ?? __dirname;
final GlobalKey<RootPageState> rootPageKey = GlobalKey();

final String specFolder = 'memory_leak_specs';
final specDir = Directory(path.join(testDirectory, specFolder));
final List<FileSystemEntity> specs = specDir.listSync();
final List<CodeUnit> codes = specs.map((spec) {
  final fileName = getFileName(spec.path);
  final List<FileSystemEntity> files = Directory(spec.path).listSync();

  bool haveEntry = files.any((entity) => entity.path.contains('index.html'));
  if (!haveEntry) {
    throw FlutterError('Can not find index.html in spec dir');
  }

  return CodeUnit(fileName, path.join(spec.path, 'index.html'));
}).toList();
PageController pageController = PageController();

List<double> mems = [];

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

class MemoryLeakPageState extends State<MemoryLeakPage> {
  BuildContext? _context;

  void navigateBack() {
    Navigator.pop(_context!);
  }

  WebF? webf;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return webf = WebF(
      viewportWidth: 360,
      viewportHeight: 640,
      bundle: WebFBundle.fromUrl('file://${widget.path}'),
      disableViewportWidthAssertion: true,
      disableViewportHeightAssertion: true,
      uriParser: IntegrationTestUriParser(),
    );
  }
}

class MemoryLeakPage extends StatefulWidget {
  final String path;
  final String name;

  MemoryLeakPage(this.name, this.path, {super.key});

  @override
  State<StatefulWidget> createState() {
    var state = MemoryLeakPageState();
    return state;
  }
}

class MultiplePageKey extends LabeledGlobalKey<MemoryLeakPageState> {
  final String name;
  MultiplePageKey(this.name): super('$name');

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

  MemoryLeakPageState? state(String name) => _keys[name]!.currentState;

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
}

Map<String, WidgetBuilder> buildRoutes(PageController pageController, List<CodeUnit> codes) {
  Map<String, WidgetBuilder> routes = {};
  codes.forEach((code) {
    routes['/${code.name}'] = (context) => Scaffold(
      body: Scaffold(
        appBar: AppBar(title: Text(code.name)),
        body: MemoryLeakPage(code.name, code.path, key: pageController.createKey(code.name))
      ),
    );
  });
  routes['/'] = (context) => Scaffold(
      body: FirstRoute(key: rootPageKey)
  );
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


Future<void> run(AsyncCallback callback) async {
  await callback();
}

Future<void> runWithMultiple(AsyncCallback callback, int multipleTime) async {
  for (int i = 0; i < multipleTime; i ++) {
    await run(callback);
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
        await run(() async {
          Completer completer = Completer();
          Timer(Duration(seconds: 1), () async {
            Navigator.pushNamed(this, '/' + current.name);
            completer.complete();
          });
          return completer.future;
        });
        await run(() async {
          Completer completer = Completer();
          Timer(Duration(seconds: 1), () async {
            Navigator.pop(this);
            completer.complete();
          });
          return completer.future;
        });
      }, 1);

      if (currentIndex < codes.length - 1) {
        current = codes[currentIndex + 1];
        currentIndex = currentIndex + 1;
      }
    }, codes.length);

    print(mems);
    print(isMemLeaks(mems));

    print('done');
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
        child: ElevatedButton(
          child: const Text('Open route'),
          onPressed: () {
            Navigator.pushNamed(context, '/' + codes.first.name);
          },
        ),
      ),
    );
  }
}

typedef onPushCallback = void Function();
typedef onPopCallback = void Function();

class MemoryLeakNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    mems.add(ProcessInfo.currentRss / 1024);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    Timer(Duration(seconds: 1), () {
      mems.add(ProcessInfo.currentRss / 1024);
    });
  }

// Add other overrides if you need them, like didReplace or didRemove
}

class MemoryLeakDetector extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        MemoryLeakNavigatorObserver()
      ],
      routes: buildRoutes(pageController, codes),
    );
  }
}

void main() {
  runApp(MemoryLeakDetector());
}
