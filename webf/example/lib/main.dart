/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:webf_websocket/webf_websocket.dart';

void main() {
  WebFWebSocket.initialize();
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
                bundle: WebFBundle.fromContent('''
                const a = document.createElement('div');
                a.style.height = '100px';
                   a.style.width = '200px';

                   const ele = document.createElement('div');

                   ele.style.backgroundImage = 'linear-gradient(135deg, red, red 10%, blue 75%, yellow 75%)';
                   ele.style.backgroundRepeat = 'repeat';
                   ele.style.backgroundSize = '200px 5px';
                   ele.style.height = '100px';
                   ele.style.width = '200px';

                   ele.style.position = 'absolute';
                   // ele.style.top = '60rpx';
                    ele.style.left = '60rpx';
                   // ele.style.padding = '60rpx 60rpx';
                   // const transX = ele.transPosX + ele.transPosWidth / 2;
                   // ele.appendChild(document.createTextNode(`第 1 个元素`));
                   a.appendChild(ele);
                   document.body.appendChild(a);
                '''),
              ),
            ],
          ),
        ));
  }
}
