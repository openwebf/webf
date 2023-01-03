# [WebF](https://openwebf.com/) [![pub package](https://img.shields.io/pub/v/webf.svg)](https://pub.dev/packages/webf)

WebF (Web on Flutter) is a W3C standards compliant Web rendering engine based on Flutter, it can run web applications on Flutter natively.

- **W3C Standards Compliant:** WebF use HTML/CSS and JavaScript to render contents on flutter. It can achieve 100% consistency with browser rendering.
- **Front-End Framework Supports:** WebF is W3C standards compliant, so it can be used by many Front-End frameworks, such as [React](https://reactjs.org/), [Vue](https://vuejs.org/).
- **Expand your Web app with Flutter:** WebF is fully customizable. You can define a customized HTML element with Flutter Widget and use it in your application. Or add a JavaScript API for any Dart library from <pub.dev> registry.
- **Web Development Experience:** WebF supports inspecting DOM structure, CSS styles and debugging JavaScript with Chrome DevTools, just like the web development experience of your browser.
- **Write Once, Run Anywhere:** With the power of WebF, You can write your web application and run it on any device flutter supports, and you can still run your apps in Node.js and Web browsers with the same codebase.


## The Relationship between WebF and Kraken

The WebF project is a community support version of [Alibaba's Kraken Project](https://github.com/openkraken/kraken). On May 10, 2022, The Kraken Dev Team was dismissed and the project itself are discontinued. 

The core developer and core architecture: [andycall](https://github.com/andycall), who is from the original Kraken Team. Leave the Alibaba Group and launch this project, to keep following the original ambition of the Kraken project. 

For more details(zh_CN): https://www.zhihu.com/question/534811524/answer/2595510449

## Join the community (Beta)

[![Discord Shield](https://discordapp.com/api/guilds/1008119434688344134/widget.png?style=banner1)](https://discord.gg/DvUBtXZ5rK)

## Version requirement

| WebF                 | Flutter |
| -------------------- | ------- |
| `>= 0.12.0 < 0.14.0` | `3.0.5` |

## How to use

**packages.yaml**

```yaml
dependencies:
  webf: <lastest version>
```

**import**

```dart
import 'package:webf/webf.dart';
```

**Use WebF Widget**

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
          bundle: WebFBundle.fromUrl('https://andycall.oss-cn-beijing.aliyuncs.com/demo/demo-vue.js'), // The page entry point
        ),
      ],
    ),
  ));
}
```

## How it works

WebF provides a rendering engine which follows the W3C standards like web browsers do. It can render HTML/CSS and execute JavaScript. It's built on top of the flutter rendering pipelines and implements its own layout and painting algorithms.

With WebF, Web Apps and Flutter Apps share the same rendering context. It means that you can use Flutter Widgets to define your HTML elements and embed your Web App as a Flutter Widget in your flutter apps.

<img src="https://user-images.githubusercontent.com/4409743/186230941-83b0aa1c-59d1-4d8d-be10-958a3ae64114.jpg" width="800" style="display: block; margin: 0 auto;" />

## 👏 Contributing [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/openwebf/webf/pulls)

By contributing to WebF, you agree that your contributions will be licensed under its Apache-2.0 License.

Read our [contributing guide](https://github.com/openwebf/webf/blob/main/.github/CONTRIBUTING.md) and let's build a better WebF project together.

Thank you to all the people who already contributed to [OpenWebF](https://github.com/openwebf) and [OpenKraken](https://github.com/openkraken)!

Copyright (c) 2022-present, The OpenWebF authors.
