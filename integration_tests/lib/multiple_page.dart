/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:webf/css.dart';
import 'package:webf/webf.dart';
import 'package:test/test.dart';

import 'custom/custom_element.dart';
import 'local_http_server.dart';
import 'plugin.dart';
import 'modules/unresponsive_module.dart';

String? pass = (AnsiPen()..green())('[TEST PASS]');
String? err = (AnsiPen()..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
final String testDirectory = Platform.environment['WEBF_TEST_DIR'] ?? __dirname;
final GlobalKey<RootPageState> rootPageKey = GlobalKey();

class MultiplePageState extends State<MultiplePage> {
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
      bundle: WebFBundle.fromContent(widget.bundle, contentType: widget.contentType),
      disableViewportWidthAssertion: true,
      disableViewportHeightAssertion: true,
      uriParser: IntegrationTestUriParser(),
    );
  }
}

class MultiplePage extends StatefulWidget {
  final String bundle;
  final String name;
  final ContentType contentType;

  MultiplePage(this.name, this.bundle, this.contentType, {super.key});

  @override
  State<StatefulWidget> createState() {
    var state = MultiplePageState();
    return state;
  }
}

class MultiplePageKey extends LabeledGlobalKey<MultiplePageState> {
  final String name;
  MultiplePageKey(this.name): super('$name');

  @override
  bool operator ==(other) {
    return other is MultiplePageKey && other.name == name;
  }

  @override
  int get hashCode => super.hashCode;
}

class MultiplePageController {
  Map<String, MultiplePageKey> _keys = {};

  MultiplePageKey createKey(String name) {
    MultiplePageKey key = MultiplePageKey(name);
    _keys[name] = key;
    return key;
  }

  MultiplePageState? state(String name) => _keys[name]!.currentState;

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
  final String code;
  final ContentType contentType;
  CodeUnit(this.name, this.code, this.contentType);
}

Map<String, WidgetBuilder> buildRoutes(MultiplePageController pageController, List<CodeUnit> codes) {
  Map<String, WidgetBuilder> routes = {};
  codes.forEach((code) {
    routes['/${code.name}'] = (context) => Scaffold(
      appBar: AppBar(title: Text('WebF Multiple Page Tests')),
      body: MultiplePage(code.name, code.code, code.contentType, key: pageController.createKey(code.name)),
    );
  });
  routes['/'] = (context) => Scaffold(
    appBar: AppBar(title: Text('WebF Multiple Page Tests')),
    body: RootPage(key: rootPageKey)
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

void main() {
  // Overrides library name.
  WebFDynamicLibrary.libName = 'libwebf_test';
  defineWebFCustomElements();

  ModuleManager.defineModule((moduleManager) => UnresponsiveModule(moduleManager));

  // Start local HTTP server.
  var httpServer = LocalHttpServer.getInstance();
  print('Local HTTP server started at: ${httpServer.getUri()}');

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  final String specFolder = 'multiple_page_specs';
  final dir = Directory(path.join(testDirectory, specFolder));
  List<FileSystemEntity> specs = dir.listSync();
  WebFJavaScriptChannel javaScriptChannel = WebFJavaScriptChannel();
  javaScriptChannel.onMethodCall = (String method, dynamic arguments) async {
    dynamic returnedValue = await javaScriptChannel.invokeMethod(method, arguments);
    return 'method: $method, return_type: ${returnedValue.runtimeType.toString()}, return_value: ${returnedValue.toString()}';
  };

  MultiplePageController pageController = MultiplePageController();
  List<CodeUnit> codes = specs.map((spec) {
    String fileName = getFileName(spec.path);
    return CodeUnit(fileName, File(spec.path).readAsStringSync(), getFileContentType(fileName));
  }).toList();
  runApp(MaterialApp(
    title: 'WebF Multiple Page Tests',
    debugShowCheckedModeBanner: false,
    initialRoute:  '/',
    routes: buildRoutes(pageController, codes),
  ));

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    group('Multiple page switching', () {
      tearDown(() {
        Completer completer = Completer();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          completer.complete();
        });
        return completer.future;
      });

      specs.forEach((spec) {
        String specName = getFileName(spec.path);

        test(specName, () async {
          Completer completer = Completer();
          rootPageKey.currentState!.navigateToPage(specName);


          WidgetsBinding.instance.addPostFrameCallback((_) {
            MultiplePageState state = pageController.state(specName)!;
            state.webf!.controller!.onLoad = (_) {
              Timer(Duration(milliseconds: 500), () async {
                await state.webf!.controller!.reload();
                Timer(Duration(milliseconds: 500), () async {
                  await state.webf!.controller!.reload();
                  state.navigateBack();
                  completer.complete();
                });
              });
            };
          });

          return completer.future;
        });
      });

      tearDownAll(() {
        print('test done');
        exit(0);
      });
    });
  });
}
