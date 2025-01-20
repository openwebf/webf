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

void main() {
  WebF.defineCustomElement('flutter-tab', (context) => FlutterTab(context));
  WebF.defineCustomElement('flutter-tab-item', (context) => FlutterTabItem(context));
  WebF.defineCustomElement('flutter-icon', (context) => FlutterIcon(context));
  WebF.defineCustomElement('flutter-search', (context) => FlutterSearch(context));
  WebF.defineCustomElement('flutter-select', (context) => FlutterSelect(context));
  WebF.defineCustomElement('flutter-button', (context) => FlutterButton(context));
  WebF.defineCustomElement('flutter-bottom-sheet', (context) => FlutterBottomSheet(context));
  runApp(MyApp());
}

class TodoMVCPage extends StatelessWidget {
  const TodoMVCPage({super.key, required this.title, required this.controller});
  final WebFController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: WebFRouterView(controller: controller, path: '/todomvc'),
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
    controller = controller ?? WebFController(
      context,
      devToolsService: kDebugMode ? ChromeDevToolsService() : null,
    );
    controller!.preload(WebFBundle.fromUrl('http://localhost:8080/'), viewportSize: MediaQuery.of(context).size);
    // controller!.preload(WebFBundle.fromUrl('assets:///vue_project/dist/index.html'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebF Example App',
      initialRoute: '/',
      routes: {
        '/todomvc': (context) => TodoMVCPage(title: 'TodoMVC', controller: controller!),
      },
      // theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: FirstPage(title: 'Landing Bay', controller: controller!),
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

  WebFDemo({ required this.controller });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('WebF Demo'),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          print(controller.view.getRootRenderObject()!.toStringDeep());
        }),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: WebF(controller: controller),
        ));
  }
}
