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
      home: MyBrowser(),
    );
  }
}

class LogoApp extends StatefulWidget {
  const LogoApp({super.key});

  @override
  State<LogoApp> createState() => _LogoAppState();
}

class _LogoAppState extends State<LogoApp> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween<double>(begin: 0, end: 100).animate(controller)
      ..addListener(() {
        if (controller.isCompleted) {
          controller.repeat();
        }
        setState(() {
          // The state that has changed here is the animation object's value.
        });
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 300,
        width: animation.value,
        child: const FlutterLogo(),
      ),
    );
  }
}

class MyBrowser extends StatefulWidget {
  MyBrowser({Key? key, this.title}) : super(key: key);

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
    final MediaQueryData queryData = MediaQuery.of(context);
    final TextEditingController textEditingController = TextEditingController();

    WebF? _kraken;
    AppBar appBar = AppBar(
      backgroundColor: Colors.black87,
      titleSpacing: 10.0,
      title: Container(
        height: 40.0,
        child: TextField(
          controller: textEditingController,
          onSubmitted: (value) {
            textEditingController.text = value;
            _kraken?.load(WebFBundle.fromUrl(value));
          },
          decoration: InputDecoration(
            hintText: 'Enter URL',
            hintStyle: TextStyle(color: Colors.black54, fontSize: 16.0),
            contentPadding: const EdgeInsets.all(10.0),
            filled: true,
            fillColor: Colors.grey,
            border: outlineBorder,
            focusedBorder: outlineBorder,
            enabledBorder: outlineBorder,
          ),
          style: TextStyle(color: Colors.black, fontSize: 16.0),
        ),
      ),
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
    );

    final Size viewportSize = queryData.size;
    return Scaffold(
        appBar: appBar,
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            children: [
              _kraken = WebF(
                devToolsService: ChromeDevToolsService(),
                viewportWidth: viewportSize.width - queryData.padding.horizontal,
                viewportHeight: viewportSize.height - appBar.preferredSize.height - queryData.padding.vertical,
                bundle: WebFBundle.fromUrl('assets:assets/bundle.html'),
              ),
            ],
          ),
        ));
  }
}
