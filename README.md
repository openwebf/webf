# [WebF](https://openwebf.com/) [![pub package](https://img.shields.io/pub/v/webf.svg)](https://pub.dev/packages/webf)

WebF (Web on Flutter) is a W3C standards-compliant web rendering engine based on Flutter, allowing web applications to run natively on Flutter.

- **W3C Standards Compliant:** WebF uses HTML/CSS and JavaScript to render content on Flutter, achieving 100% consistency with browser rendering.
- **Front-End Framework Supports:** As WebF is W3C standards compliant, it can be used with many front-end frameworks, such as [React](https://reactjs.org/), [Vue](https://vuejs.org/).
- **Expand your Web App with Flutter:** WebF is fully customizable. You can define a customized HTML element with Flutter Widgets and use it in your application or add a JavaScript API for any Dart library from <pub.dev> registry.
- **Web Development Experience:** WebF supports inspecting DOM structure, CSS styles and debugging JavaScript with Chrome DevTools, providing a browser-like web development experience.
- **Write Once, Run Anywhere:** With the power of WebF, You can write your web application and run it on any device that Flutter supports. Additionally, you can still run your apps in Node.js and web browsers with the same codebase.

## Check if a Web API or CSS is available in WebF

Check [this yaml](https://github.com/openwebf/webf-available-apis/blob/main/data.yaml)


## The Relationship between WebF and Kraken

The WebF project is a community support version of [Alibaba's Kraken Project](https://github.com/openkraken/kraken). On May 10, 2022, The Kraken Dev Team was dismissed and the project itself are discontinued. 

The core developer and architector: [andycall](https://github.com/andycall), who is from the original Kraken Team. Leave the Alibaba Group and launch this project, to keep following the original ambition of the Kraken project. 

For more details(zh_CN): https://www.zhihu.com/question/534811524/answer/2595510449

## Join the community (Beta)

[![Discord Shield](https://discordapp.com/api/guilds/1008119434688344134/widget.png?style=banner1)](https://discord.gg/DvUBtXZ5rK)

## Version requirement

| WebF                 | Flutter |
| -------------------- | ------- |
| `>= 0.12.0 < 0.14.0` | `3.0.5` |
| `>= 0.14.0` | `3.3.10` and `3.7.3` |

## How to use

> All front-end frameworks based on the WhatWG DOM standard are supported; this time, we are using Vue as an example.

### 1. Use vue-cli to generate your front-end project

> ES6 modules are not supported yet, so Vite is not supported.

```bash
vue create app
cd app
npm run serve
```

And the Vue development server will be hosted at `http://<yourip>:8080/`.

### 2. Add webf as a dependency for your flutter apps.

**packages.yaml**

```yaml
dependencies:
  webf: <lastest version>
  webf_websocket: <lastest version>
```

**import**

```dart
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:webf_websocket/webf_websocket.dart';
```

**init**

```dart
void main() {
  WebFWebSocket.initialize();
  runApp(MyApp());
}
```


### 3. Add the WebF widget to run your web applications.

```dart
@override
Widget build(BuildContext context) {
  final MediaQueryData queryData = MediaQuery.of(context);
  final Size viewportSize = queryData.size;

  return Scaffold(
      body: Center(
    child: Column(
      children: [
        WebF(
          devToolsService: ChromeDevToolsService(), // Enable Chrome DevTools Services
          viewportWidth: viewportSize.width - queryData.padding.horizontal, // Adjust the viewportWidth
          viewportHeight: viewportSize.height - queryData.padding.vertical, // Adjust the viewportHeight
          bundle: WebFBundle.fromUrl('http://<yourip>:8080/'), // The page entry point
        ),
      ],
    ),
  ));
}
```

### 4. Run

```bash
flutter run
```

<img src="https://user-images.githubusercontent.com/4409743/217754470-697b6998-4451-483c-b26e-bdb2740f3ea1.png" width="800" style="display: block; margin: 0 auto;" />


## How it works

WebF provides a rendering engine which follows the W3C standards like web browsers do. It can render HTML/CSS and execute JavaScript. It's built on top of the flutter rendering pipelines and implements its own layout and painting algorithms.

With WebF, Web Apps and Flutter Apps share the same rendering context. It means that you can use Flutter Widgets to define your HTML elements and embed your Web App as a Flutter Widget in your flutter apps.

<img src="https://user-images.githubusercontent.com/4409743/186230941-83b0aa1c-59d1-4d8d-be10-958a3ae64114.jpg" width="800" style="display: block; margin: 0 auto;" />

## 👏 Contributing [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/openwebf/webf/pulls)

By contributing to WebF, you agree that your contributions will be licensed under its Apache-2.0 License.

Read our [contributing guide](https://github.com/openwebf/webf/blob/main/.github/CONTRIBUTING.md) and let's build a better WebF project together.

Thank you to all the people who already contributed to [OpenWebF](https://github.com/openwebf) and [OpenKraken](https://github.com/openkraken)!

Copyright (c) 2022-present, The OpenWebF authors.
