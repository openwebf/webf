/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:webf_websocket/webf_websocket.dart';

import 'text_element.dart';
import 'custom-elements/flutter_input.dart';
import 'custom-elements/flutter_listview.dart';

void main() {
  WebFWebSocket.initialize();
  WebF.defineCustomElement('flutter-text', (context) => TextElement(context));
  WebF.defineCustomElement('flutter-checkbox', (context) => CheckboxElement(context));
  WebF.defineCustomElement('flutter-listview', (context) => ListViewElement(context));
  WebF.defineCustomElement('flutter-input', (context) => FlutterInputElement(context));
  WebF.defineCustomElement('flutter-container', (context) => ContainerElement(context));
  WebF.defineCustomElement('input', (context) => FlutterInputElement(context));
  runApp(MaterialApp(
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final MediaQueryData queryData = MediaQuery.of(context);
    final TextEditingController textEditingController = TextEditingController();
    AppBar appBar = AppBar(
      title: const Text('First Route'),
    );
    final Size viewportSize = queryData.size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: WebF(
        devToolsService: ChromeDevToolsService(),
        viewportWidth: viewportSize.width - queryData.padding.horizontal,
        viewportHeight: viewportSize.height - appBar.preferredSize.height - queryData.padding.vertical,
        bundle: WebFBundle.fromUrl('assets:assets/bundle.html'),
        // bundle: WebFBundle.fromUrl('http://127.0.0.1:3300/kraken_debug_server.js'),
      ),
    );
  }
}

class SecondRouteState extends State<SecondRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: null
    );
  }

}

class SecondRoute extends StatefulWidget {
  const SecondRoute({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SecondRouteState();
  }
}
