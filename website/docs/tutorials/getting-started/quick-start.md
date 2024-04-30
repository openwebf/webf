# Quick Start

This guide will walk you through the process of creating a HelloWorld App with Vue.js and running it in WebF.

By the end of this tutorial, your app will be functioning on both desktop and mobile platforms with the same behavior.

:::caution

Since Flutter for Web is not compatible with WebF, ensure that you set your running platform to either mobile or desktop
systems, rather than Chrome.

:::

## Prerequisites

To use WebF, you need a Flutter environment. Each version of Flutter has its own range of compatible WebF versions,
Ensure that you select the correct Flutter version that matches both WebF and Flutter.

| WebF               | Flutter                      |
|--------------------|------------------------------|
| >= 0.12.0 < 0.14.0 | 3.0.x                        |
| >= 0.14.0 < 0.15.0 | 3.3.x and 3.7.x              |
| >= 0.15.0 < 0.16.0 | 3.10.x                       |
| >= 0.16.0 < 0.17.0 | 3.13.x and 3.16.x and 3.19.x |

:::tip

For more info how to install the Flutter environment, please refer to https://docs.flutter.dev/get-started/install.

:::

In this tutorial, we will use webf `0.16.0` and flutter `3.19.3` as an example.

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
  webf: ^0.16.0
```

Now in your Dart code:

```dart
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
```

And initialize the WebFWebSocket plugin before initialize flutter framework.

```dart
void main() {
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
build tools
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

## Initialize the WebF Controller

:::tip
If you're unsure how to create and run a Flutter app, you can find more information at
Flutter's [Getting Started Guide](https://docs.flutter.dev/get-started/test-drive).
:::

The WebFController is the main controller class that manages the lifecycle of WebF pages. Before using WebF, it is
necessary to initialize the WebFController and maintain its instance.

In this demo, we create a `StatefulWidget` called FirstPage to initialize the WebF instance within the
`didChangeDependencies()` callback.

We can then call `controller.preload()` to fetch external resources before we actually navigate to our page.

:::caution

Do not initialize the WebFController class inside the `build()` function, as this function executes every time the
widget
tree updates, which would create multiple duplicate WebFController instances.

:::

```dart
class FirstPageState extends State<FirstPage> {
  late WebFController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = WebFController(
      context,
      devToolsService: ChromeDevToolsService(),
    );
    controller.preload(WebFBundle.fromUrl('http://<yourip>:8080/')); // The page entry point
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return WebFDemo(title: 'SecondPage', controller: controller);
            }));
          },
          child: const Text('Open WebF Page'),
        ),
      ),
    );
  }
}
```

:::tip

Remember to dispose of the controller when this widget state is disposed of to prevent memory leaks.

:::

```dart
@override
void dispose() {
  super.dispose();
  controller.dispose();
}
```

## Initialize the WebF Widget with a Controller

Use the WebF widget as the entry point for your web apps, and pass the controller as the primary parameter.


```dart
class WebFDemo extends StatelessWidget {
  final WebFController controller;

  WebFDemo({ required this.controller });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('WebF Demo'),
        ),
        body: Center(
          child: WebF(controller: controller),
        ));
  }
}
```

:::tip
There are multiple ways to load a web app: from the network, assets, disk, or even a sequence of strings. For more info,
please refer
to [loading-web-contents-from-disk](/docs/tutorials/guides-for-flutter-developer/loading-web-contents-from-disk).
:::

## Build and run your Flutter app

> Checkout the full demo: https://github.com/openwebf/webf/tree/main/webf/example

Now it's time to build and try.

:::tip
If you're unsure how to create and run a Flutter app, you can find more information at
Flutter's [Getting Started Guide](https://docs.flutter.dev/get-started/test-drive).
:::

After the app build completes, you’ll see your vue web app is running on your device.

<video src="/videos/quick_start.mov" controls style={{width: "300px", margin: '0 auto', display: 'block'}} />

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

+ If you're a Flutter developers, visit
  the [Guides for Flutter developer](/docs/tutorials/guides-for-flutter-developer/overview)
  to learn how to customize and extend WebF with Flutter.
