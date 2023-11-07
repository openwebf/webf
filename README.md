# [WebF](https://openwebf.com/) [![pub package](https://img.shields.io/pub/v/webf.svg)](https://pub.dev/packages/webf)

WebF presents a high-performance, cutting-edge web rendering engine built on top of Flutter, empowering web applications to operate natively within the Flutter ecosystem.

- **Adherence to W3C Standards:** By leveraging HTML/CSS and JavaScript, WebF renders content on Flutter, ensuring impeccable alignment with standard browser rendering.

- **Compatible with Leading Front-End Frameworks:** Given its compliance with W3C standards, WebF seamlessly integrates with popular front-end frameworks, including [React](https://reactjs.org/) and [Vue](https://vuejs.org/).

- **Amplify Your Web Applications with Flutter:** WebF's adaptability shines through its customization capabilities. Craft bespoke HTML elements using Flutter Widgets or enhance your application by integrating a JavaScript API sourced from any Dart library on the `pub.dev` registry.

- **Authentic Web Development Environment:** Experience a traditional web development setting with WebF. It facilitates DOM structure inspection, CSS style evaluations, and JavaScript debugging via Chrome DevTools.

- **Craft Once, Deploy Everywhere:** Harness the versatility of WebF to design your web application and launch it across any Flutter-compatible device. What's more, maintain the flexibility to execute your apps within Node.js or web browsers, all from a unified codebase.

## Join Our Mission

We envision providing web developers with an innovative web rendering engine, surpassing WebView in performance and adaptability across both mobile and desktop platforms.

WebF's journey is ambitious and enduring. We believe in the strength of collective effort. If you share our dream of a superior alternative to WebView for the future, your expertise could be invaluable to us.

Further, financial contributions can pave the way for erstwhile members of the Kraken team to rejoin our mission, bolstering our developmental pace and potential.

If you or your team are interested in supporting us, please contact @andycall on our Discord channel.

## Join the community (Beta)

[![Discord Shield](https://discordapp.com/api/guilds/1008119434688344134/widget.png?style=banner1)](https://discord.gg/DvUBtXZ5rK)

## The update and maintenance policy for WebF versions

Each version of WebF will be maintained for the lifespan of three minor WebF releases. For instance, WebF 0.15.0 was released to be compatible with Flutter 3.10.x. Its support will conclude once WebF 0.18.0 is introduced. Any updates applied to versions 0.16.x and 0.17.x will be cherry-picked for the subsequent update of 0.15.x.

This ensures that users can reliably receive updates for three minor WebF versions without the necessity to upgrade the Flutter version in their app.

| WebF                 | Flutter |
| -------------------- | ------- |
| `>= 0.12.0 < 0.14.0` | `3.0.5` |
| `>= 0.14.0 < 0.15.0` | `3.3.10` and `3.7.3` |
| `>= 0.15.0 < 0.16.0` | `3.10.x` |
| `>= 0.16.0 < 0.17.0` | `3.13.x` |
| `>= 0.17.0 < 0.18.0` | `3.16.x` |


<img width="817" alt="image" src="https://github.com/openwebf/webf/assets/4409743/2d5cf5a1-e670-424b-8766-324f475bbc0a">

Below is the relationship between the various Flutter and WebF versions:

<img width="627" alt="image" src="https://github.com/openwebf/webf/assets/4409743/8cace8da-ac97-4908-b970-6b52450cb4cc">


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
```

**import**

```dart
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
```

**init**

```dart
void main() {
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

## Contributors

<a href="https://github.com/openwebf/webf/graphs/contributors"><img src="https://opencollective.com/webf/contributors.svg?width=890&button=false" /></a>

## 👏 Contributing [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/openwebf/webf/pulls)

By contributing to WebF, you agree that your contributions will be licensed under its Apache-2.0 License.

Read our [contributing guide](https://github.com/openwebf/webf/blob/main/.github/CONTRIBUTING.md) and let's build a better WebF project together.

Thank you to all the people who already contributed to [OpenWebF](https://github.com/openwebf) and [OpenKraken](https://github.com/openkraken)!

Copyright (c) 2022-present, The OpenWebF authors.
