---
sidebar_position: 8
title: Events
---

Events in web development refer to the interactions or occurrences that take place in the webf/browser, often triggered
by users interacting with a page, or by other sources like external data loading, the webf/browser itself, or APIs.

Events play a crucial role in creating interactive web applications.

## The Event Sources

In web application development, the term "event sources" primarily refers to the originators or triggers of various
interactions or occurrences within the browser environment.

The categorization and description of these sources can help developers design and implement interactive web
experiences.

### User Interaction Events

These are events that are triggered directly by user actions and supported by WebF:

- **Mouse Events**: Includes `click`, `dblclick` (double-click),
  ~~`mousedown`, `mouseup`, `mousemove`, `mouseover`, `mouseout`, and `mouseenter`, `mouseleave`~~.

- ~~**Keyboard Events**: Triggered by keyboard actions and include `keydown`, `keyup`, and `keypress`~~.

- **Touch Events**: Designed for touch devices and include `touchstart`, `touchmove`, `touchend`, and `touchcancel`.

- **Form Events**: Occur on form elements, such as ~~`submit`~~, `change`, `focus`, `blur`, `input`, and ~~`reset`~~.

### Window & Document Events

These events relate to the broader webf environment:

- **Window Events**: Include ~~`resize`~~, `scroll`, `load`, ~~`unload`~~, ~~`beforeunload` (before the window closes or
  navigates to another page), and `offline/online` (when the browser goes offline or comes back online)~~.

- **Document Events**: Examples are `DOMContentLoaded` (fired when the initial HTML document is completely loaded and
  parsed, without waiting for stylesheets, images, and subframes to finish loading) and `readystatechange`.

### Media Events

WebF does not offer built-in support for media elements and events. If you wish to embed media content into your WebF
app, consider searching for relevant plugins within the Flutter ecosystem on pub.dev. Once you've found the right
plugin, you can wrap it into your WebF app.

To learn how to wrap any Flutter plugin or widget into your WebF apps, please refer
to [Add Flutter Widgets Into WebF](/).

### Web API and Communication Events

These are related APIs with external data interactions:

- **AJAX (XMLHttpRequest) Events**: Such as `readystatechange`, `abort`, `loadstart` and `error`.
- **WebSocket Events**: For real-time web communication, like `open`, `message`, `error`, and `close`.

### Animation & Transition Events

Events related to CSS animations and transitions:

- `animationstart`, `animationend`, `animationiteration` for animations.
- `transitionstart`, `transitionrun`, `transitioncancel`, `transitionend` for transitions.

### Custom Events

Developers can create and dispatch their own events for specific application needs using the CustomEvent interface.

```javascript
const event = new CustomEvent('myCustomEvent', {detail: 'data'});
document.dispatchEvent(event);
```

## Event Listeners

Event listeners in web development are fundamental to creating interactive applications.

They allow developers to define specific reactions to certain events, such as a user clicking a button or a page
finishing loading.

At its core, an event listener "listens" for a specified event to occur and then responds by executing a given function
or callback.

### Basics of Event Listeners

Event listeners can be added to any DOM element, not just HTML elements. The Window and Document objects can have
listeners too.

The general format for attaching an event listener:

```javascript
element.addEventListener(event, function, useCapture);
```

+ element is the target element.
+ event is the name of the event (e.g., 'click').
+ function is the callback function to be executed when the event occurs.
+ useCapture is an optional boolean value that specifies the event phase.

### Event Propagation: Capturing and Bubbling

Events in the DOM can propagate in two phases:

+ Capturing (or Capture) Phase: The event starts from the window object and trickles down the DOM tree to the target
  element.
+ Bubbling Phase: After reaching the target element, the event bubbles up again to the window object.

By default, event listeners are added to the bubbling phase. If you set the useCapture parameter to true, the event
listener will be added to the capturing phase.

### Removing Event Listeners

To prevent memory leaks or unwanted behavior, you might need to remove an event listener:

```javascript
function handleClick() {
    console.log('Button clicked!');
}

document.getElementById('myButton').addEventListener('click', handleClick);

// Later in the code, when you want to remove it:
document.getElementById('myButton').removeEventListener('click', handleClick);
```

Note: You can't remove an anonymous function as an event listener since you can't reference it later.

### Event Delegation

Instead of adding event listeners to individual elements, you can add a single listener to a common ancestor due to the
bubbling nature of events.

By checking the `event.target`, you can handle the event accordingly.

This technique is especially useful when working with a dynamic list of elements, like a to-do list where items can be
added or removed.

Example:

```javascript
document.querySelector('ul').addEventListener('click', function (e) {
    if (e.target.tagName === 'LI') {
        console.log('List item clicked!');
    }
});
```

### The Event Object

Every event listener receives an event object as its first parameter.

This object contains information about the event, such as which element triggered it, the state of the touches, and so
on.

Example:

```javascript
document.getElementById('myButton').addEventListener('click', function (e) {
    console.log(e.target); // The element that triggered the event
    console.log(e.type);   // The type of the event (e.g., "click")
});
```

### `this` in Event Listeners

Inside the callback function of an event listener, the `this` keyword refers to the DOM element the event was attached
to:

```javascript
document.getElementById('myButton').addEventListener('click', function () {
    console.log(this.id);  // Outputs: "myButton"
});
```

However, if you use arrow functions, the value of this will be different because arrow functions do not have their own
this context:

```javascript
document.getElementById('myButton').addEventListener('click', () => {
    console.log(this);  // Will not point to the button element
});
```

### Preventing Default Behavior

WebF currently does not support the `preventDefault()` behavior for the Event object.

### Event Listener Options

While the third argument to addEventListener is commonly known as useCapture, it can also accept an options object:

```javascript
element.addEventListener('click', handlerFunction, {
    capture: true,        // equivalent to `useCapture`. Defaults to false.
    once: true,           // Currently not supported
    passive: true         // Currently not supported
});
```

+ capture: Determines whether the listener is added for the capture or bubbling phase.
+ ~~once: The listener will be removed automatically after it's invoked once.~~
+ ~~passive: Useful for performance improvements in certain scenarios, like touch and scroll event listeners.~~

### Frameworks & Libraries

When working with web frameworks and libraries like React, Vue, etc., the way you handle events might differ slightly
from the vanilla JavaScript approach.

Each framework has its own system for event handling, although the underlying principles remain the same.

## Event propagation

Event propagation in web app development refers to the order in which events are received in the Document Object Model (DOM).

Understanding this process is crucial when building interactive web applications, as it allows developers to control the
flow of events and ensure the appropriate handlers are triggered at the right time.

There are three main phases in event propagation:

![img](./imgs/eventflow.svg)


### Capturing (or Capture) Phase

+ It begins at the root and travels down the DOM hierarchy.
+ The event starts from the window object and progresses towards the target element, moving through its ancestors.
+ This phase is the opposite of the more commonly used bubbling phase.

### Target Phase

+ Once the event reaches the target element (the element on which the event was dispatched), it's in the target phase.
+ Handlers attached directly to the element and set for this phase are executed.

### Bubbling Phase

+ After the target phase, if the event is a bubbling event, it begins to bubble up through the DOM.
+ It starts from the target element itself and bubbles up to the root of the DOM tree (typically the window object).
+ This is the phase where most event handlers are set to act, as it's the default phase for the commonly used addEventListener method.

### Practical Implications

**Multiple Handlers**:

An event can have multiple handlers on a single element and on its ancestors. Understanding propagation ensures you know the order in which these handlers are executed.

**Stopping Propagation**:

Using the stopPropagation method on the event object, you can prevent the event from traveling any further, either in the capturing or bubbling phase. 

This is useful when you want to ensure an event is handled by a specific listener and not any others up or down the DOM tree.

```javascript
element.addEventListener('click', function(e) {
    console.log('This will stop all further event listeners after it.');
    e.stopPropagation();
});
```

**Event Delegation**:

Understanding event propagation is fundamental for implementing event delegation. 

Since events bubble, you can set a single event listener on a common ancestor of multiple elements. 

This technique is beneficial for improving performance and handling events on dynamically generated elements.


## Event Object

The Event Object plays a pivotal role in web application development. Whenever an event occurs, the webf/browser creates an event object that carries information about that event.

This object is passed as the first parameter to the event handler. Understanding its properties and methods is essential for creating interactive and responsive web applications.

### Properties and Methods of the Event Object

+ **type:**

  Specifies the type of event (e.g., "click", "keydown", "submit").
  
  ```javascript
  button.addEventListener('click', function(event) {
      console.log(event.type);  // Outputs: "click"
  });
  ```

+ **target:** References the object that dispatched the event, i.e., the element on which the event was originally fired.
+ **currentTarget:** References the object on which the event listener is currently processing. It's especially useful when dealing with event delegation.
+ **stopPropagation():** Prevents further propagation of the event in the capturing and bubbling phases.
+ ~~**preventDefault():** Cancels the event if it is cancelable, meaning any default action normally done by the webf as a result of the event won't occur.~~.
+ **bubbles:** A boolean that indicates if the event bubbles up through the DOM or not.
+ **cancelable:** A boolean indicating whether the event's default 
+ **detail:** Returns some details about the event. Only available in CustomEvent.
+ ~~**isTrusted:**: A boolean indicating whether the event was initiated by a user action (true) or by script code (false)~~
+ ~~**eventPhase:**: Returns the phase in which the event is being evaluated. Useful values include Event.CAPTURING_PHASE, Event.AT_TARGET, and Event.BUBBLING_PHASE~~
+ ~~**Keyboard Event Properties**: (for keydown, keyup, keypress events):~~
+ Mouse Event Properties (for mouse-related events):
  + clientX, clientY: Position of the mouse pointer relative to the visible part of the web page (viewport).
  + ~~pageX, pageY: Position of the mouse pointer relative to the whole document.~~
  + ~~screenX, screenY: Position of the mouse pointer relative to the screen.~~
+ ~~**relatedTarget:**~~  
  + ~~for mouseover and mouseout events, this property references the element the mouse just left or entered, respectively.~~
+ **timeStamp**: 
  + Indicates the time (in milliseconds) when the event was created.
+ ~~**composed**:~~ 
  + ~~A boolean value indicating whether the event will propagate across the shadow DOM boundary into the main DOM.~~

### Custom Properties

Developers can also create custom events that carry their own data:

```javascript
let customEvent = new CustomEvent("userLogin", {
    detail: {
        username: "JohnDoe",
        timestamp: Date.now()
    }
});
element.dispatchEvent(customEvent);
```

When handling this custom event, `event.detail` would contain the custom data ({username: "JohnDoe", timestamp: [some timestamp]}).


## Using custom events with custom elements in React.js

React doesn't provide out-of-the-box support for listening to custom events on JSX elements. 

If you are using custom elements that were implemented using Flutter widgets, you'll need to attach an event listener to the actual DOM element:

```javascript
import React, { useEffect, useRef } from 'react';

function App() {
  const buttonRef = useRef(null);

  useEffect(() => {
    const handleCustomClick = (e) => {
      console.log(e.detail.message);
    };

    // Attach the event listener to the real DOM element
    const btn = buttonRef.current;
    btn.addEventListener('customClick', handleCustomClick);

    // Cleanup after the component is unmounted
    return () => {
      btn.removeEventListener('customClick', handleCustomClick);
    };
  }, []);

  return <custom-button ref={buttonRef}>Click me</custom-button>;
}

export default App;
```

In the example above:

+ We have implemented custom elements using Flutter widgets, called `custom-button`.
+ We're using a ref to get a reference to the real DOM element (custom-button).
+ Inside useEffect, we add the customClick event listener to the element.
+ Before the component unmounts, the event listener is cleaned up to prevent potential memory leaks.

**Important Considerations:**

+ Bubbling: Ensure that the `bubbles` property of the CustomEvent is set to true to enable the event to bubble up the DOM tree. 
  In this example, the `customClick` event was created on the Dart side. Ensure you set bubbles to true when initializing the CustomClick event.
  ```dart
  dispatchEvent(CustomEvent('customClick', detail: {
    'message': 'helloworld'
  }, bubbles: true));
  ```