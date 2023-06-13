# Quick Start

This guide will walk you through the process of creating a HelloWorld App with Vue.js and running it in WebF.

By the end of this tutorial, your app will be functioning on both desktop and mobile platforms with the same behavior.

## Prerequisites

To use WebF, you need a Flutter environment. Each version of Flutter has its own range of compatible WebF versions,
Ensure that you select the correct Flutter version that matches both WebF and Flutter.

| WebF               | Flutter         |
|--------------------|-----------------|
| >= 0.12.0 < 0.14.0 | 3.0.x           |
| >= 0.14.0 < 0.15.0 | 3.3.x and 3.7.x |
| >= 0.15.0 < 0.16.0 | 3.10.x          |

:::tip

For more info how to install the Flutter environment, please refer to https://docs.flutter.dev/get-started/install.

:::

In this tutorial, we will use webf `0.14.0` and flutter `3.7.3` as an example.

:::info

If you are a Web developer, you may encounter problems trying to install the Flutter environment.
WebF offers a prebuilt desktop app allow you to quickly examine the HTML/CSS and JavaScript abilities without needing
to install any Flutter developer environments.

Read more at https://www.npmjs.com/package/@openwebf/cli

:::

## Install WebF

Add the following code to your package's pubspec.yaml file and run `flutter pub get`.

```yaml
dependencies:
  webf: ^0.14.0
  webf_websocket: ^1.3.0
```

Now in your Dart code:

```dart
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:webf_websocket/webf_websocket.dart';
```

And initialize the WebFWebSocket plugin before initialize flutter framework.

```dart
void main() {
  WebFWebSocket.initialize();
  runApp(MyApp());
}
```

## Set up a Web app develop environment

The runtime capabilities for Web apps provided by WebF follow by WhatWG/W3C standards, which are the same
standards for Web browsers. Once the necessary required browser features are supported by WebF, the framework or library
originally designed
for Web browsers can be run in WebF.

In this example, We will set up a Vue app let it running in WebF.

To create a Vue app, you need to install [Node.js](https://nodejs.org/en). We recommend that you use the latest LTS
version available.

```bash
npm install -g @vue/cli
```

:::info
If you are a Web developers, you might be curious why we use vue-cli instead of [Vite](https://vitejs.dev/) (Another
buildtools
released by the Vue.js team) to create the App.
The app created by Vite requires ESM module support, which is not currently supported by WebF. However, we plan to
support
this in the future versions of WebF.
:::

:::info Can I use React instead of Vue?

Absolutely, both React.js and Vue.js have been thoroughly tested and can run in WebF without any configuration. You can
use create-react-app to create a React.js app and run it in WebF.

:::

Run the following command to create and start a vue web app:

```bash
vue create app
cd app
npm run serve
```

Once the Vue development server has started, you can open your web apps in a browser at `http://<yourip>:8080/`.

## Add WebF to your Flutter app

:::tip
If you're unsure how to create and run a Flutter app, you can find more information at
Flutter's [Getting Started Guide](https://docs.flutter.dev/get-started/test-drive).
:::

The WebF widget is a stateful Flutter Widget that allows you to embed web content rendered by WebF into your Flutter
apps. Add it to your flutter app to enable build your UI with HTML/CSS and JavaScript.

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

:::tip
There are multiple ways to load a web app: from the network, assets, disk, or even a sequence of strings. For more info,
please refer
to [loading-web-contents-from-disk](/docs/tutorials/guides-for-flutter-developer/loading-web-contents-from-disk).
:::

## Build and run your Flutter app

Now it's time to build and try.

:::tip
If you're unsure how to create and run a Flutter app, you can find more information at
Flutter's [Getting Started Guide](https://docs.flutter.dev/get-started/test-drive).
:::

After the app build completes, you’ll see your vue web app is running on your device.

![img](/img/helloworld.png)

## Use Hot-Restart instead Hot-Reload

Flutter offers a fast development cycle with Hot Reload and Hot-Restart, the ability to reload the code of a live
running app without restarting or losing app state.

Unfortunately, you cannot use the Hot Reload feature when you make any changes to your web app.

Instead, Hot Restart is available to reload Web contents rendered by WebF.

<p>
Click the <img src="/img/hot-restart@2x.png" alt="hot-restart" style={{'line-height': '10px', 'vertical-align': 'middle', 'width': '25px'}} /> icon to see changes in your simulator, emulator or device when you make any modifications to your Web app.
</p>

## Measure performance

:::caution
Avoid testing your app's performance in debug mode.
:::

Up until now, you’ve been running your app in debug mode. Debug mode in Flutter trades performance for useful developer
features and can be 3x-4x slower than Profile or Release builds.

Once you are ready to analyze performance or release your app,
consult [Flutter's build modes](https://docs.flutter.dev/testing/build-modes) for more details.

## Integration and Deployment

The integration and deployment of WebF are no different from standard Flutter apps.

Refer to the documentation at https://docs.flutter.dev/reference/supported-platforms for more details.

:::note
Not all platforms supported by Flutter are supported by WebF.

Here are the platforms supported by WebF:

1. iOS
2. Android
3. macOS
4. Linux
5. Windows

The following platform is currently not supported, but will be added in the future:

1. Web

:::

## What's Next

Now that you have an app built with Vue.js and running on both mobile and desktop platforms with Flutter,
you might be wondering about the next steps.

+ If you're a Web developer, you might be curious about the extent of Web features that can be used in WebF. Learn more
  by visiting the [Guides for Web Developer](/docs/tutorials/guides-for-web-developer/overview).

+ If you're a Flutter developers, visit the [Guides for Flutter developer](/docs/tutorials/guides-for-flutter-developer/overview)
  to learn how to customize and extend WebF with Flutter.
