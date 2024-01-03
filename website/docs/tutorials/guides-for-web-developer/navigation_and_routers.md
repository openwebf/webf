---
sidebar_position: 10
title: Navigation and Routers
---

WebF behaves like a single Flutter widget within Flutter apps. However, web developers can also create a SPA (Single
Page Application) using the History API or Hash URL.

This allows them to change the rendering contents without altering
the router status in Flutter.

## The History API

The History API is a set of web standards introduced with HTML5, providing web developers with the capability to
manipulate the webf/browser session history.

Prior to the introduction of the History API, web developers mainly relied on
hash (#) fragments to create stateful single-page applications (SPAs).

The History API allows for a more powerful and nuanced approach to managing webf/browser history.

+ `history.pushState()`: Adds an entry to the webf's session history stack. This allows you to change the URL
  displayed in the address bar without reloading the page.
+ `history.replaceState()`: Modifies the current history entry, rather than adding a new one. Useful when you want to
  update the state object or URL of the current history entry.
+ `The popState event`: An event is triggered when the active history entry changes. This typically occurs when the
  history state is modified through the history API called from JavaScript or is triggered on the Dart side via the API
  made available to Flutter developers.
+ `history.state`: Returns the state object of the current history entry.
+ `history.go()`, `history.back()`, `history.forward()`: Methods to programmatically navigate the session history.

### Frameworks & Libraries

Many JavaScript frameworks, such as React with React Router and Vue with Vue Router, operate on top of the History API.

If you are using these frameworks, the router libraries for them also work with WebF.

## Cooperation with Flutter navigation system

Web framework router libraries can integrate with the Flutter navigation system using the History API. 

This allows developers to navigate back or forward when users trigger Flutter gestures and reactions.

<video src="/videos/routing.mov" controls style={{width: "80%", display: 'block'}} />

The feature was designed for Flutter developers to control the web pages inside WebF.

For more details, you can check out this [demo](https://github.com/openwebf/samples/tree/main/demos/hybird_routers) and read the [Control Pages in WebF](/docs/tutorials/guides-for-flutter-developer/control_pages_in_webf) section. 