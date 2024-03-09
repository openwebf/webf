/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kraken Browser',
      // theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: FirstPage(title: 'Landing Bay'),
    );
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
  late WebFController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WebFJavaScriptChannel methodChannel = WebFJavaScriptChannel();
    methodChannel.onMethodCall = (String method, dynamic argments) {
      if (method == 'openPage') {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MyBrowser(title: 'SecondPage1', controller: controller);
        }));
      }
      return Future.value('');
    };

    controller = WebFController(
      context,
      methodChannel: methodChannel,
      devToolsService: ChromeDevToolsService(),
    );
    controller.preload(WebFBundle.fromUrl('assets:assets/bundle.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MyBrowser(title: 'SecondPage', controller: controller);
              }));
            },
            child: const Text('Open WebF Page'),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MyBrowser(title: 'SecondPage', controller: controller);
              }));
            },
            child: const Text('Open WebF Page2'),
          ),
        )
      ]),
    );
  }
}

class MyBrowser extends StatefulWidget {
  MyBrowser({Key? key, this.title, required this.controller}) : super(key: key);

  final WebFController controller;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyBrowser> {
  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: const BorderRadius.all(
      Radius.circular(20.0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'webfDemo'),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: WebF(controller: widget.controller),
        ));
  }
}
