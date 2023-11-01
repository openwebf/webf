---
sidebar_position: 4
title: Flutter Widgets as HTMLElement
---

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
  Widget build(BuildContext context, List<Widget> children) {
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
you can let
you easily communicate with JavaScript.

### Defining Properties

To enhance your custom element with additional properties, override the `initializeProperties` method
within `WidgetElement`.

```dart
@override
void initializeProperties(Map<String, BindingObjectProperty> properties) {
  super.initializeProperties(properties);
  properties['src'] = BindingObjectProperty(getter: () => '[VIDEO SRC]', setter: (src) {
    // Action to be taken when JavaScript attempts to update the `src` property of your custom element instance.
  });
}
```

`BindingObjectProperty` provides both getter and setter callbacks.

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

### Defining Methods

Incorporation methods to your custom elements in WebF closely parallels the approach for adding properties. WebF's
binding
system auto-generates the relevant JavaScript functions corresponding to your Dart methods.

To equip your custom element with additional methods, override the `initializeMethods` methods within `WidgetElement`:

```dart
@override
void initializeMethods(Map<String, BindingObjectMethod> methods) {
  super.initializeMethods(methods);
  // Here, we're defining a method named 'play' that returns a Promise.
  // For synchronous execution, opt for the `BindingObjectMethodSync` class.
  methods['play'] = AsyncBindingObjectMethod(call: (args) async {
    // This is the action that occurs when JavaScript invokes the `play()` method.
    // 'args' will contain parameters passed from the JavaScript side.

    // Implement your desired functionality for this method.
    // For instance: await _controller.play();
    // ...

    // Dispatch an event to the JavaScript side to activate a callback.
    dispatchEvent(Event('play'));
  });
}
```

Post initialization, the custom element instance on the JavaScript side will possess a `play()` that returns a Promise.

If directly interacting with the DOM element, these methods can be invoked with ease:

```javascript
// JavaScript Code
const videoPlayerElement = document.createElement('video-player');

// Invoke the `play` method, as crafted in Dart.
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

**Synchronous & Asynchronous Functions**

WebF's binding system accommodates both synchronous and asynchronous functions.

Depending on your requirements, you can tailor your functions accordingly.

Here's comparative illustrating Dart methods and their corresponding JavaScript counterparts:

| Dart                       | JavaScript          |
|----------------------------|---------------------|
| `AsyncBindingObjectMethod` | async function() {} |
| `BindingObjectMethodSync`  | function() { }      |

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

Custom elements can be styled with CSS. This includes setting width and height, arranging them alongside other regular
elements, and using positioning to place them in specific locations.

For instance, to ensure the video player always remains visible on the screen, you can use `position: fixed`.

<video src="/videos/video_player.mov" controls style={{width: "300px", margin: '0 auto', display: 'block'}} />

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

## Embedding HTMLElements as Children of Custom Elements

Custom elements can seamlessly integrate with standard HTMLElements to construct more intricate components.

For instance, if you wish to design a complex component where the outer framework is crafted using Flutter widgets,
while the inner content is structured using HTML and CSS, this combination allows for such versatility.

### Another Demo

The demo below highlights the potential of blended embedding. When designing the UI, you're not confined to a single
technical framework. If you possess a collection of existing Flutter widget components, you can seamlessly integrate
them with WebF, making them accessible for web applications.

<video src="/videos/widget_elements.mov" controls style={{width: "500px", margin: '0 auto', display: 'block'}} />

<br />

Standard HTML elements can be set as children within custom elements.

WebF's Flutter widget adapter will translate these child elements into a list of Flutter widgets, which are then passed
to the `build()` function within the WidgetElement
class.

Consider a scenario where we've implemented a `FlutterButton` class using Flutter widgets and registered it with WebF
under the tag name `flutter-button`.

We might want this button to exhibit different behaviors for varied purposes, such as a red warning button or a green
success button.

Consequently, this button element should accept both properties and attributes as well as children parameters.

```html
// The success button
<flutter-button type="primary">Success</flutter-button>

// The error button
<flutter-button type="default">Fail</flutter-button>
```

On the Dart side, the text "Success" and "Fail" are converted into widget children and stored in
the `List<Widget> children` parameter.

In this demonstration, we set these widgets as children of either the `ElevatedButton` or the `OutlinedButton` widget.
Thus, the text will be displayed within the Flutter buttons.

We also use the `initializeProperties` method to register a type property, which allows for the customization of the
Flutter button based on its style.

For the Flutter button's `onPressed` event handler, we dispatch a click event to JavaScript, enabling the web app to
process the click gesture and execute further actions.

```dart
class FlutterButton extends WidgetElement {
  FlutterButton(BindingContext? context) : super(context);

  handlePressed(BuildContext context) {
    dispatchEvent(Event(EVENT_CLICK));
  }

  @override
  Map<String, dynamic> get defaultStyle => {'display': 'inline-block'};

  Widget buildButton(BuildContext context, String type, Widget child) {
    switch (type) {
      case 'primary':
        return ElevatedButton(
            onPressed: () => handlePressed(context), child: child);
      case 'default':
      default:
        return OutlinedButton(
            onPressed: () => handlePressed(context), child: child);
    }
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    properties['type'] = BindingObjectProperty(
        getter: () => type, setter: (value) => type = value);
  }

  String get type => getAttribute('type') ?? 'default';

  set type(value) {
    internalSetAttribute('type', value?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return buildButton(context, type,
        children.isNotEmpty ? children[0] : SizedBox.fromSize(size: Size.zero));
  }
}
```