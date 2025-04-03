---
sidebar_position: 4
title: Flutter Widgets as HTMLElement
---

:::caution
The Flutter widget adapter in the open-source version of WebF is a demo version with lower performance and known bugs,
making it unsuitable for production use in business applications.

In contrast, [the enterprise version of WebF](/docs/enterprise/flutter_widget_element) includes a completely redesigned Flutter widget adapter
with deeper integration with flutter widget and economy and significantly better performance compared to the open-source version.
:::

In a WebF application, any Flutter Widget can be transformed into its foundational unit — an HTMLElement. Web pages are
fundamentally built from HTMLElement nodes.

Utilizing the WebF Widget Adaptor, any Flutter Widget can be converted into
an HTMLElement node, allowing it to be seamlessly integrated into a WebF page.

## Explore the Demo

[Checkout this demo](https://github.com/openwebf/samples/tree/main/demos/video_player) that illustrates how to
construct a video player using the `video_player` Flutter plugin, and use it as a custom element into the web page.

<video src="/videos/video_player.mov" controls style={{width: "300px", margin: '0 auto', display: 'block'}} />

## Defining a Custom Element for the Web

### Introduction to the `WidgetElement` Class

The `WidgetElement` class plays an instrumental role by bridging the gap between Flutter's Widgets and the web's
HTMLElements.

In the Dart ecosystem, when you create a subclass of `WidgetElement` and use Flutter Widgets inside its `build` method,
you're essentially designing a custom HTMLElement. This offers a unique advantage: the ability to seamlessly integrate a
Flutter Widget into web applications using this custom HTMLElement tag.

These custom elements behave analogously to standard Web Components in modern browsers. For web developers, these
Flutter widget-based custom elements can be regarded as
pre-defined [Web Components](https://developer.mozilla.org/en-US/docs/Web/API/Web_components).

### Example 1: Implementing a Video Player in WebF

This demonstration elucidates the process of incorporating the video_player package from pub.dev into web applications
built with WebF. Here's a step-by-step guide:

1. **Adding the Dependency**: First and foremost, include the `video_player` package in your pubspec.yaml file.

2. **Creating the Subclass**: Subsequently, define a new class named `VideoElement` that extends WidgetElement.

  ```dart
  class VideoPlayerElement extends WidgetElement {
  VideoPlayerElement(super.context);

  // Additional attributes and methods...

  @override
  Widget build(BuildContext context, ChildNodeList children) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 20.0),
          ),
          const Text('With assets mp4'),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  ```

Interestingly, the WidgetElement shares many similarities with the State associated with StatefulWidget in Flutter.
So, if you're already acquainted with typical Flutter app development, working with WidgetElement should come naturally.

3. **Incorporate Custom Elements in Your Web App**

To register your class as a custom element within the WebF environment, utilize the `WebF.defineCustomElement` method.
This not only registers the class but also associates a custom element tag with it.

  ```dart
  // Dart code
void main() {
  WebF.defineCustomElement(
      'video-player', (context) => VideoPlayerElement(context));
}
  ```

After this step, your Web app can conveniently spawn instances of your widget element class using either
the `document.createElement` method or directly in HTML, based on the logic within your `build` method.

**Instantiating the Custom Element in JavaScript**

In a web application, your custom element can be instantiated through JavaScript:

  ```javascript
  // JavaScript Code
const videoPlayerElement = document.createElement('video-player');
document.body.appendChild(videoPlayerElement);
  ```

Alternatively, directly employ the custom element within your HTML:

  ```html
  <!-- HTML Code -->
<div class="container">
    <h3>Video Title</h3>
    <video-player id="video_player"/>
</div>
  ```

For developers using frameworks like Vue, the custom element—crafted from a Flutter widget—can be utilized just like any
standard HTML element:

  ```vue
  <!-- Vue.js Code -->
<template>
  <img alt="Vue logo" src="./assets/logo.png">
  <video-player
      ref="videoPlayer"
      src="https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
      @canplay="handleCanPlay"
      @playing="handlePlaying"
      @paused="handlePaused"
  >
  </video-player>
  <div class="status-bar">
    Player Status: {{state}}
  </div>
</template>
<script>
  export default {
    name: 'App',
    methods: {
      handleCanPlay() {
        this.state = 'canplay';
      },
      handlePlaying() {
        this.state = 'playing';
      },
      handlePaused() {
        this.state = 'paused';
      }
    }
  }
</script>
  ```

## Define API and Events

Methods and properties for custom elements can be 100% defined and implemented in Dart. Once you have defined your
properties and methods for your custom element, WebF's binding system will create the corresponding JavaScript API for
you can let you easily communicate with JavaScript.

### Defining Properties

To enhance your custom element with additional properties, declare a `StaticDefinedBindingPropertyMap` to define the extended properties for your `WidgetElement`, and append it to the `properties` getter.

```dart
static StaticDefinedBindingPropertyMap videoPlayerProperties = {
  'src': StaticDefinedBindingProperty(
    getter: (element) => castToType<VideoPlayerElement>(element).src,
    setter: (element, value) => 
        castToType<VideoPlayerElement>(element).src = value,
  ),
};

@override
List<StaticDefinedBindingPropertyMap> get properties => [
      ...super.properties,
      videoPlayerProperties,
    ];
```

The `StaticDefinedBindingProperty` class provides both getter and setter callbacks, enabling you to manage the property's value dynamically. Ensure that the `getter` and `setter` implementations correctly cast the element type and handle the property's behavior as intended.

When JavaScript seeks to retrieve a value using this property, the `getter` callback gets activated.

Conversely, when JavaScript intends to assign a value to this property, the `setter` callback comes into play.

On the JavaScript side, if you're manipulating the DOM element directly, you can effortlessly interact with these
properties on the DOM instance:

```javascript
// JavaScript Implementation
const videoPlayerElement = document.createElement('video-player');

// Retrieve the value returned from Dart
console.log(videoPlayerElement.src); // Outputs: [VIDEO SRC]

// Assign a value to Dart
videoPlayerElement.src = 'NEW VIDEO SRC'; // This action will activate the setter callback in Dart.
```

For those utilizing specific frameworks, it's advisable to access the DOM instance through the respective framework's
provided API.

As an illustration, Vue developers can employ the `ref()` function to fetch the DOM instance and then extract the value
sourced from Dart.

```vue

<template>
  <video-player
      ref="videoPlayer"
  ></video-player>
</template>
<script>
  export default {
    name: 'App',
    mounted() {
      console.log(this.$refs['videoPlayer'].src); // Outputs: [VIDEO SRC]
    }
  }
</script>
```

**Use an Asynchronous Approach to Read Properties**

In dedicated thread mode, accessing properties blocks the JavaScript thread while waiting for the property getter to
return. For better performance optimization, JavaScript developers are encouraged to use a more efficient approach to
access properties on `widgetElement` without blocking the JavaScript thread.

By appending the `_async` suffix to the synchronous property, a Promise object is returned to JavaScript, enabling an
asynchronous approach:

```javascript
console.log(this.$refs['videoPlayer'].src); // The synchronous approach
console.log(this.$refs['videoPlayer'].src_async); // The asynchronous approach, which returns a Promise instead of the actual value.
```

Use the `.then` method or the `async`/`await` keywords to handle asynchronous access:

```javascript
async function getSrc() {
  return await this.$refs['videoPlayer'].src_async;
}
```

### Defining Methods

Incorporation methods to your custom elements in WebF closely parallels the approach for adding properties. WebF's
binding
system auto-generates the relevant JavaScript functions corresponding to your Dart methods.

### Defining Methods

To equip your custom element with additional methods, declare a `StaticDefinedSyncBindingObjectMethodMap` to define the extended synchronous methods for your `WidgetElement` and append it to the `methods` getter. Similarly, declare a `StaticDefinedAsyncBindingObjectMethodMap` for asynchronous methods and append it to the `asyncMethods` getter.

```dart
static StaticDefinedSyncBindingObjectMethodMap videoPlayerSyncMethods = {
  'status': StaticDefinedSyncBindingObjectMethod(
    call: (element, args) {
      return castToType<VideoPlayerElement>(element).status(args);
    },
  ),
};

@override
List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
      ...super.methods,
      videoPlayerSyncMethods,
    ];

static StaticDefinedAsyncBindingObjectMethodMap videoPlayerAsyncMethods = {
  'play': StaticDefinedAsyncBindingObjectMethod(
    call: (element, args) async {
      return castToType<VideoPlayerElement>(element).play(args);
    },
  ),
};

@override
List<StaticDefinedAsyncBindingObjectMethodMap> get asyncMethods => [
      ...super.asyncMethods,
      videoPlayerAsyncMethods,
    ];
```


Post initialization, the custom element instance on the JavaScript side will possess a `play()` that returns a Promise.

If directly interacting with the DOM element, these methods can be invoked with ease:

```javascript
// JavaScript Code
const videoPlayerElement = document.createElement('video-player');

// Invoke the `status` method, returned in sync results, as crafted in Dart.
videoPlayerElement.status();

// Invoke the `play` method, returned with a Promise object, as corresponding to the Future in Dart.
await videoPlayerElement.play();
```

For developers working within distinct frameworks, it's recommended to fetch the DOM instance using the framework's
native API.

For instance, in Vue, the `ref()` function allows developers to obtain the DOM instance, subsequently facilitating the
invocation of functions defined in Dart.

```vue

<template>
  <video-player
      ref="videoPlayer"
      src="https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
  ></video-player>
  <div class="video-player-control">
    <div class="control-button" @click="handlePlay">Play</div>
    <div class="control-button" @click="handlePause">Pause</div>
  </div>
</template>

<script>
  export default {
    name: 'App',
    methods: {
      handlePlay() {
        this.$refs['videoPlayer'].play();
      },
      handlePause() {
        this.$refs['videoPlayer'].pause();
      }
    }
  }
</script>
```

**Use an Asynchronous Approach to Synchronous Functions**

In dedicated thread mode, calling synchronous methods blocks the JavaScript thread while waiting for the Dart synchronous methods to return. For better performance optimization, JavaScript developers are encouraged to use a more efficient approach to call the same Dart synchronous method on `widgetElement` without blocking the JavaScript thread.

By appending the `_async` suffix to the synchronous Dart method name, a Promise object is returned to JavaScript, enabling an asynchronous approach:

```javascript
this.$refs['videoPlayer'].status(); // This function is synchronous
this.$refs['videoPlayer'].status_async(); // Calls the same synchronous `status` method in Dart but returns a Promise object.
```

Use the `.then` method or the `async`/`await` keywords to handle asynchronous execution:

```javascript
async function play() {
  await this.$refs['videoPlayer'].status_async();
}
```

### Handling Events from Dart

Events are essential when Dart aims to inform the JavaScript side and initiate a callback for specific purposes.

In the `WidgetElement` class, the `dispatchEvent` function allows you to send events to the JavaScript side and invoke
an event listener callback.

```dart
onCanPlay() {
  // Dispatch an event to the JavaScript side to trigger a callback.
  dispatchEvent(Event('canplay'));
}
```

If you wish to embed additional data within the event, consider using the `CustomEvent` class rather than the `Event`
class.

```dart
onCanPlay() {
  CustomEvent customEvent = CustomEvent('canplay', detail: 'YOUR DATA');
  // Dispatch this custom event to the JavaScript side to trigger a callback.
  dispatchEvent(customEvent);
}
```

On the JavaScript side, when interacting directly with the DOM element, the `addEventListener` function allows you to
register a callback that awaits notification from Dart.

For web developers, the events triggered by WidgetElement align seamlessly within standard W3C Event events, Hence
handling these events remains consistent.

```javascript
// JavaScript Code
const videoPlayerElement = document.createElement('video-player');

// Register a callback for the `play` event dispatched from the Dart side.
videoPlayerElement.addEventListener('play', (e) => {
  // If the event object is a CustomEvent, access e.detail to retrieve the data sent from Dart.
});
```

For those working with specific frameworks, the majority provide built-in methods to handle these event callbacks and
invoke associated methods.

For example, in Vue, simply prefix the event name with @ to register the event handler for your custom element tags.

```vue

<template>
  <video-player
      ref="videoPlayer"
      src="https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
      @canplay="handleCanPlay"
      @playing="handlePlaying"
      @paused="handlePaused"
  ></video-player>
</template>

<script>
  export default {
    name: 'App',
    methods: {
      handleCanPlay() {
        this.state = 'canplay';
      },
      handlePlaying() {
        this.state = 'playing';
      },
      handlePaused() {
        this.state = 'paused';
      },
    }
  }
</script>
```

## Use CSS Styles to Control Your Customized UI

Custom elements can be styled with CSS. This includes setting width and height, arranging them alongside other regular elements, and using positioning to place them in specific locations.

For instance, to ensure the video player always remains visible on the screen, you can use `position: fixed`.

<video src="/videos/float_video.mov" controls style={{width: "300px", margin: '0 auto', display: 'block'}} />

```vue

<template>
  <video-player
      id="video-player"
      ref="videoPlayer"
  />
</template>
<style>

  #video-player {
    width: 300px;
    position: fixed;
    left: 0;
    top: 0;
    right: 0;
    margin: auto;
  }
</style>
```

### Use CSS Properties to Customize the Behavior of Your Widget Elements

Matched CSS properties for your custom elements can be accessed via the `renderStyle` object in your `build()` methods. These properties allow you to adjust the layout and visual effects based on the CSS values.

For example, consider a custom element called `<flutter-search />` that accepts the CSS properties `font-size` and `border-radius` to customize its appearance:

```dart
WebF.defineCustomElement('flutter-search', (context) => FlutterSearch(context));
```

```dart
class FlutterSearch extends WidgetElement {
  FlutterSearch(super.context);

  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return Container(
      child: TextField(
        maxLines: 1,
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _controller.clear(); // Clear the input
                  },
                )
              : null,
          hintText: 'Search', // Placeholder text
          hintStyle: TextStyle(color: Colors.grey, fontSize: 12), // Placeholder style
          border: OutlineInputBorder(
            borderRadius: renderStyle.borderRadius != null
                ? BorderRadius.only(
                    topLeft: renderStyle.borderRadius![0],
                    topRight: renderStyle.borderRadius![1],
                    bottomRight: renderStyle.borderRadius![2],
                    bottomLeft: renderStyle.borderRadius![3],
                  )
                : BorderRadius.zero,
            borderSide: BorderSide.none, // No default border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: renderStyle.borderRadius != null
                ? BorderRadius.only(
                    topLeft: renderStyle.borderRadius![0],
                    topRight: renderStyle.borderRadius![1],
                    bottomRight: renderStyle.borderRadius![2],
                    bottomLeft: renderStyle.borderRadius![3],
                  )
                : BorderRadius.zero, // Rounded corners
            borderSide: BorderSide(color: Colors.blue, width: 1.0), // Outline when focused
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.0), // Vertical padding
        ),
        style: TextStyle(
          overflow: TextOverflow.visible, // Handles text overflow
          fontSize: renderStyle.fontSize.computedValue, // Adjust font size dynamically
        ),
      ),
    );
  }
}
```

With this setup, the internal font size and border radius of the `<flutter-search />` element can be customized using the following HTML and CSS:

```html
<flutter-search id="search"></flutter-search>
```

```css
#search {
  font-size: 16px; /* Adjusts the font size for the input text */
  border-radius: 8px; /* Changes the radius of the input's corners */
}
```


## Embedding HTML Elements as Children of Custom Elements

Custom elements can seamlessly integrate with standard HTML elements to construct more intricate components. 

For example, you can design a complex component where the outer framework is created using Flutter widgets, while the inner content is structured using HTML and CSS. This combination provides exceptional flexibility and power.

### Demo

In this demo, we define two custom elements using Flutter: `<flutter-tab>` and `<flutter-tab-item>`.

```dart
WebF.defineCustomElement('flutter-tab', (context) => FlutterTab(context));
WebF.defineCustomElement('flutter-tab-item', (context) => FlutterTabItem(context));
```

The following code converts the `childNodes` of the DOM tree into a list of `TabData` widgets, which form the basic tab items of the `DynamicTabBarWidget`:

```dart
List<TabData> tabs = childNodes.whereType<dom.Element>().map((element) {
  return TabData(
    index: _index++,
    title: Tab(
      child: Text(element.getAttribute('title') ?? ''),
    ),
    content: element.toWidget(key: ObjectKey(element)),
  );
}).toList(growable: false);
```

### Full Implementation

```dart
import 'package:dynamic_tabbar/dynamic_tabbar.dart';

class FlutterTab extends WidgetElement {
  FlutterTab(super.context);

  bool isScrollable = false;
  bool showNextIcon = true;
  bool showBackIcon = true;

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    int _index = 0;
    List<TabData> tabs = childNodes.whereType<dom.Element>().map((element) {
      return TabData(
        index: _index++,
        title: Tab(
          child: Text(element.getAttribute('title') ?? ''),
        ),
        content: element.toWidget(key: ObjectKey(element)),
      );
    }).toList(growable: false);

    return DynamicTabBarWidget(
      dynamicTabs: tabs,
      isScrollable: isScrollable,
      onTabControllerUpdated: (controller) {
        controller.index = 0;
      },
      onTabChanged: (index) {},
      onAddTabMoveTo: MoveToTab.last,
      showBackIcon: showBackIcon,
      showNextIcon: showNextIcon,
    );
  }
}

class FlutterTabItem extends WidgetElement {
  FlutterTabItem(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(
      tagName: 'DIV',
      controller: ownerDocument.controller,
      children: childNodes.toWidgetList(),
    );
  }
}
```

### HTML Usage

Once the custom elements are defined in Dart, you can use them in your HTML as follows:

```html
<flutter-tab>
  <flutter-tab-item title="Relative">
    <div>This is Relative</div>
  </flutter-tab-item>
  <flutter-tab-item title="Absolute">
    <div>This is Absolute</div>
  </flutter-tab-item>
  <flutter-tab-item title="Fixed">
    <div>This is Fixed</div>
  </flutter-tab-item>
  <flutter-tab-item title="Sticky">
    <div>This is Sticky</div>
  </flutter-tab-item>
</flutter-tab>
```
