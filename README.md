<p align="center">
  <a href="https://openwebf.com">
    <picture>
      <img src="./website/static/img/openwebf.png" width="200"/>
    </picture>
  </a>
</p>
<h1 align="center">
<a href="https://openwebf.com" alt="openwebf-site">OpenWebF</a>
</h1>
<p align="center">
  <b>A Web Rendering Engine Optimized for the Client.</b><br/>
  Built using React/Vue and Tailwind CSS, rendered through Flutter.
</p>
<p align="center">
  <a href="https://openwebf.com/docs/tutorials/getting-started/quick-start">
    <b>Getting Started</b>
  </a>
  |
  <a href="https://openwebf.com/docs/tutorials/guides-for-web-developer/overview">
    <b>Guides For Web Developers</b>
  </a>
  |
  <a href="https://openwebf.com/docs/tutorials/guides-for-flutter-developer/overview">
    <b>Guides For Flutter/Mobile Developers</b>
  </a>
</p>
<p align="center">
  <a aria-label="X" href="https://x.com/HelloAndyCall" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Twitter-black?style=for-the-badge&logo=Twitter">
  </a>
  <a aria-label="Discord-Link" href="https://discord.gg/DvUBtXZ5rK" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Discord-black?style=for-the-badge&logo=discord">
  </a>
  <a aria-label="Pub Package" href="https://pub.dev/packages/webf">
    <img alt="" src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  </a>
</p>

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

![Browser Engine Pipeline](https://github.com/user-attachments/assets/82b2ed53-f0d6-4f14-b22a-2fca50c697a5)




## Contributors

<a href="https://github.com/openwebf/webf/graphs/contributors"><img src="https://opencollective.com/webf/contributors.svg?width=890&button=false" /></a>

## 👏 Contributing [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/openwebf/webf/pulls)

By contributing to WebF, you agree that your contributions will be licensed under its Apache-2.0 License.

Read our [contributing guide](https://github.com/openwebf/webf/blob/main/.github/CONTRIBUTING.md) and let's build a better WebF project together.

Thank you to all the people who already contributed to [OpenWebF](https://github.com/openwebf) and [OpenKraken](https://github.com/openkraken)!

Copyright (c) 2022-present, The OpenWebF authors.
