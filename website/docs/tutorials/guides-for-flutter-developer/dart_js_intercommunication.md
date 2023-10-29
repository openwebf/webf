---
sidebar_position: 3
title: Dart and JavaScript Intercommunication
---

WebF offers a streamlined and optimized method for facilitating communication between Dart and JavaScript.

## Explore the Demo

[Check out this demo](https://github.com/openwebf/samples/tree/main/demos/js_dart_communicate) that illustrates how to
construct a music player using the `audio_player` Flutter plugin, while employing HTML/CSS and JavaScript for the user
interface.

<video src="/videos/music_player.mov" controls style={{width: "500px", margin: '0 auto', display: 'block'}} />

## The `WebFJavaScriptChannel` Class

The `WebFJavaScriptChannel` class is an essential component that facilitates the communication between Dart and JavaScript when using the WebF widget.

By initializing an instance of `WebFJavaScriptChannel`, you establish a bi-directional communication channel between Dart and JS. 

This allows you to send data from Dart to JS, and vice versa. Additionally, you can set up a callback to monitor and process data coming from JS.

Here's how to use it:

```dart
// Create a new instance of WebFJavaScriptChannel
final WebFJavaScriptChannel javaScriptChannel = WebFJavaScriptChannel();

// Use the javaScriptChannel as a parameter in the WebF widget
WebF(
  bundle: WebFBundle.fromUrl('assets:///assets/bundle.html'),
  javaScriptChannel: javaScriptChannel,
)
```

With this setup, you're now ready to enjoy seamless communication between your Dart and JavaScript environments.

### Dart to JavaScript Communication

When you're aiming for two-way communication between Dart and JavaScript, you can set up JavaScript to listen for method calls from Dart and respond accordingly.

**Setting Up Callbacks in JavaScript**

On the JavaScript side, WebF provides a method channel that listens for method invocations from Dart. This channel can have handlers associated with specific method name.

For instance, to handle a method named 'setPlayerState' invoked from Dart:

```javascript
// In your JavaScript code
webf.methodChannel.addMethodCallHandler('setPlayerState', function(state) {
  // Here, 'state' holds the data sent from Dart.

  // You can use the 'state' as needed in your JavaScript logic.
  this.playerState = state;

  // If there's a listener setup for player state changes, notify it.
  if (typeof this.onPlayerStateChanged === 'function') {
    this.onPlayerStateChanged(this.playerState);
  }
  
  // You can also send back a response to Dart, if needed.
  return 'Received state: ' + state;
});
```

**Invoking JavaScript Methods from Dart**

From the Dart side, you can invoke the aforementioned JavaScript method and send data using the invokeMethod function of the WebFJavaScriptChannel object:

```dart
// Dart code
// Invoke the 'setPlayerState' method in JavaScript and send the player's state.
final response = await javaScriptChannel.invokeMethod('setPlayerState', PlayerState.stopped.toString());

// 'response' now contains the return value from the JavaScript function, if any.
print(response);  // Outputs: Received state: stopped
```
By using this mechanism, Dart can seamlessly call JavaScript functions and pass along data, and vice versa. 

This ensures a fluid interaction between the Dart and JavaScript realms within a WebF application, allowing you to harness the strengths of both ecosystems.

### JavaScript to Dart Communication

Often, you might find the need for JavaScript to initiate communication, sending data to Dart and even triggering certain Dart functions in response.

Below is a breakdown of how you can establish this communication seamlessly:

**Setting Up Callbacks in Dart**

Before JavaScript can communicate with Dart, Dart needs to be "listening". This is accomplished with the `onMethodCall` property of the `WebFJavaScriptChannel`.

```dart
// Dart Code

final WebFJavaScriptChannel javaScriptChannel = WebFJavaScriptChannel();

@override
void initState() {
  super.initState();
  // Here, we tell Dart to use 'handleJSCall' whenever a method call is received from JavaScript.
  javaScriptChannel.onMethodCall = handleJSCall;
}

Future<dynamic> handleJSCall(String method, dynamic args) async {
  // Depending on the method name provided by JavaScript, execute relevant Dart code.
  switch(method) {
    case 'playAudio':
      await playAudio(args[0]); // Assumes playAudio is a method defined elsewhere in your Dart code.
      return true;
    default:
      return null; // Return null if the method name doesn't match any expected methods.
  }
}
```

**Calling Dart Methods from JavaScript**

Once Dart is set up to listen, you can have JavaScript send messages or invoke methods in Dart. WebF makes this task straightforward with the invokeMethod function.

```javascript
// JavaScript Code
class AudioPlayer {
  play(audioPath) {
      // This line asks WebF to call the 'playAudio' method in Dart with the provided audioPath as an argument.
      return webf.methodChannel.invokeMethod('playAudio', audioPath);
  }
}
```

In certain scenarios, especially when Dart's response is asynchronous (a Future), JavaScript will receive a Promise from the invokeMethod function.

Then you can use the `await` to make sure the async task on the dart was completed.

```javascript
// JavaScript Code
// Use 'await' to ensure JavaScript waits for Dart's task to complete before moving on.
await window.audioPlayer.play();
console.log('Music playback has started.');
```


## Efficient Data Communication and Transformation

WebF stands as the bridge that connects Dart and JavaScript, ensuring that data flows smoothly and effectively between them.

A pivotal aspect that guarantees this uninterrupted flow is WebF's capability to auto-convert data types.


### Data Type Equivalents Between Dart and JavaScript

WebF shoulders the responsibility of data type conversion when data is shuffled between Dart and JavaScript.

Below is a table that displays the corresponding data types across both environments:

| Dart    | JavaScript |
|---------|------------|
| `String`  | `string`   |
| `int`     | `number`   |
| `double`  | `number`   |
| `bool`    | `boolean`  |
| `Map`     | `Object`   |
| `List`    | `Array`    |

### Modes of Data Exchange

Although the standard way to transfer data is by copying — which meets the requirements of most scenarios, certain situations, especially those involving voluminous data, call for a more expedited mode of data transfer.

WebF introduces specialized modes of data transmission that sidestep the traditional copying procedure. Instead of replicating the data, references to the actual data are utilized.

Adopting this approach considerably slashes the overhead associated with data transfers, promising enhanced performance.

For an in-depth understanding of this streamlined data exchange approach and its impact on boosting performance, please consult the [Zero-copy data transmission](/docs/tutorials/performance_optimization/zero_copy_data_transmission) guide.