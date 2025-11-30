# WebF Developer Guide

This guide is for web developers who want to build applications using the WebF framework.

## Table of Contents

*   [Introduction](#introduction)
    *   [What is WebF?](#what-is-webf)
    *   [Core Principles](#core-principles)
    *   [WebF vs. WebView](#webf-vs-webview)
*   [Getting Started](#getting-started)
    *   [Prerequisites](#prerequisites)
    *   [Installation](#installation)
    *   [Creating your first WebF App](#creating-your-first-webf-app)
    *   [Running the App](#running-the-app)
*   [Development Workflow](#development-workflow)
    *   [Project Structure](#project-structure)
    *   [Hot Reload](#hot-reload)
    *   [Using the DevTools](#using-the-devtools)
*   [Core Concepts](#core-concepts)
    *   [DOM & Elements](#dom--elements)
    *   [Async Rendering](#async-rendering)
    *   [CSS & Styling](#css--styling)
    *   [JavaScript & Events](#javascript--events)
    *   [Networking](#networking)
    *   [Routing](#routing)
    *    [Accessing Native Features](#accessing-native-features)
*   [Using Flutter UI Libraries](#using-flutter-ui-libraries)
*   [Web API Compatibility](#web-api-compatibility)
*   [Using with Web Frameworks](#using-with-web-frameworks)
    *   [React.js](#reactjs)
    *   [Vue.js](#vuejs)
    *   [Preact](#preact)
    *   [Svelte](#svelte)
    *   [Solid](#solid)
    *   [Qwik](#qwik)
*   [State Management](#state-management)
*   [Using with Web Build Tools](#using-with-web-build-tools)
    *   [Vite](#vite)
    *   [Webpack](#webpack)
    *   [esbuild](#esbuild)
    *   [Rollup](#rollup)
*   [Advanced Styling](#advanced-styling)
*   [Networking and Data](#networking-and-data)
    *   [Fetching Data from the Internet](#fetching-data-from-the-internet)
    *   [Working with Local Data](#working-with-local-data)
*   [Using WebF Native Plugins](#using-webf-native-plugins)
    *   [Using Pre-built Plugins](#using-pre-built-plugins)
    *   [Creating a New Plugin](#creating-a-new-plugin)
*   [Testing](#testing)
    *   [Unit Testing](#unit-testing)
    *   [Component Testing](#component-testing)
    *   [Integration Testing](#integration-testing)
    *   [End-to-End (E2E) Testing](#end-to-end-e2e-testing)
*   [Debugging and Performance](#debugging-and-performance)
    *   [Debugging your App](#debugging-your-app)
    *   [Performance Profiling](#performance-profiling)
    *   [Best Practices](#best-practices)
*   [Security](#security)
*   [Deploying Updates](#deploying-updates)
*   [Automation & CI/CD](#automation--cicd)
*   [Advanced Topics](#advanced-topics)
    *   [Animation](#animation)
    *   [Custom Painting](#custom-painting)
    *   [Accessibility](#accessibility)
*   [Resources](#resources)
    *   [API Reference](#api-reference)
    *   [Examples](#examples)
    *   [Community and Support](#community-and-support)
*   [Contributing](#contributing)

---

## Introduction

### What is WebF?

WebF is a new way to build cross-platform applications for mobile and desktop, using the web development ecosystem you already know and love. It's a standards-compliant rendering engine, built on Flutter, that allows you to use your existing web frameworks, build tools, and libraries to create native apps. With WebF, you can build your application using your favorite web framework—like React, Vue, or Svelte—and it will run with high performance on all major platforms, while still giving you access to powerful native capabilities when you need them.

### Core Principles

WebF is designed around a set of core principles to provide a powerful and flexible development experience:
*   **Ecosystem Compatibility**: WebF is designed to make the modern web development stack just work. It aims for seamless compatibility with your existing tools, including popular frameworks (like React and Vue), build tools (like Vite and Webpack), and your favorite libraries.
*   **Performance-First**: With features like an asynchronous rendering model, WebF is architected to deliver high-performance, app-like experiences, avoiding many of the performance bottlenecks of traditional web views.
*   **Hybrid by Design**: WebF embraces a hybrid development model, allowing for deep integration between your application's frontend code (HTML, CSS, and JavaScript) and the native Flutter host. This enables powerful features like embedding native Flutter widgets directly into the DOM.

### WebF vs. WebView

For developers experienced with hybrid apps, the most relevant comparison is between WebF and a standard `WebView`. While both render web code, their architectures and capabilities are fundamentally different.

*   **Custom Rendering Engine vs. System Browser**: A `WebView` uses the device's built-in browser engine (like Chromium or WebKit). WebF uses its own custom rendering engine, built on Flutter, which is specifically optimized for the performance needs of an application, not a general-purpose document viewer.

*   **Deep Integration vs. A Sandboxed Box**: A `WebView` is a black box that is heavily sandboxed. WebF removes this sandbox, enabling true deep integration. The **Native Binding System** provides a direct, high-performance communication channel between JavaScript and native code that is far more powerful than a typical `WebView` bridge.

*   **True Hybrid UI vs. Web-Only UI**: With a `WebView`, your UI is strictly web-based. WebF's key advantage is that it allows you to embed native Flutter widgets directly into your DOM as custom HTML elements, allowing you to build a truly hybrid UI.

*   **Application-First Architecture**: WebF is designed to run a single, cohesive application with a long-lived JavaScript context. This provides a more robust model for state management compared to the page-based lifecycle of content in a `WebView`.

*   **Controlled Navigation**: A `WebView` can often be used to browse the open web. WebF, by contrast, is not a browser; navigating to untrusted or external origins is disallowed by default, ensuring your application remains secure and self-contained.

---

## Getting Started

Getting started with WebF is designed to be as familiar as possible for a web developer. You will use your standard web development tools and a pre-built native shell app called **WebF Go**.

### Prerequisites

To get started with WebF, you only need one tool you likely already have:

*   **Node.js**: Required to create and run your web project with tools like Vite. We recommend the latest LTS (Long-Term Support) version from [nodejs.org](https://nodejs.org/).

That's it. You **do not** need to install the Flutter SDK, Xcode, or Android Studio to start building your app on your desktop.

### Step 1: Download and Run WebF Go

The easiest way to see your application in action is with **WebF Go**, a pre-built native shell that contains the WebF rendering engine.

*   **For Desktop Development**: Download the **WebF Go** application for your desktop OS (macOS, Windows, or Linux) from the official website:
    [**https://openwebf.com/en/go**](https://openwebf.com/en/go)

*   **For Mobile Testing**: Simply download the **WebF Go** app from the App Store (for iOS) or Google Play (for Android) directly onto your physical device.

Launch the WebF Go application. You'll see a simple window with an input field, ready to load your project.

### Step 2: Create Your Web Project with Vite

You can use any modern web build tool, but for this guide, we'll use **Vite**.

To create a new web project, open your terminal and run:

```bash
npm create vite@latest
```

Vite will prompt you to name your project and select a framework like **React, Vue, Svelte,** etc.

### Step 3: Start Your Web Dev Server

Once your project is created, navigate into its directory, install the dependencies, and start the development server.

```bash
# Move into your new project folder
cd <your-project-name>

# Install dependencies
npm install

# Start the dev server
npm run dev
```

The terminal will output a local network URL for your running application, typically something like `http://localhost:5173`. Make sure you use the **Network** URL if you are testing on a physical mobile device.

### Step 4: Load Your App in WebF Go

With your dev server running, the final step is to load it in the WebF Go app (on desktop or mobile).

1.  Copy the local **Network** URL from your terminal.
2.  Paste the URL into the input field at the top of the WebF Go app.
3.  Tap "Go".

Your web application will now render inside the native WebF environment. Any changes you make to your code will instantly update in the app.

### A Note for Hybrid Teams

While this guide focuses on the "WebF Go" app for rapid development, it's important to know that WebF can be embedded into any new or existing Flutter application.

If you are a web developer collaborating with a Flutter team, they may provide you with a custom-built host app instead of using WebF Go. Your development workflow remains the same: run your web project with `npm run dev` and load the local URL into the app they provide.

For more details on how WebF is integrated into a Flutter project from the native side, you can refer to our companion guide: [**Guide for Flutter Developers**](FLUTTER_INTEGRATION_GUIDE.md).

---

## Development Workflow

Your development workflow with WebF is designed to be as close as possible to standard web development.

### Project Structure

Because you are using a standard web tool like Vite to create your project, the project structure is exactly what you would expect. There are no special WebF-specific files or configurations required in your web project.

### Hot Reload

WebF fully supports the Hot Module Replacement (HMR) capabilities of modern web development servers like Vite. Any changes you make to your source code will be instantly reflected in the running WebF application.

### Using the DevTools

WebF integrates with Chrome DevTools for DOM inspection and console logging, and also includes its own built-in tools for performance profiling.

**For DOM and Console Debugging:**

1.  While your app is running, click the **floating action button with the debug icon**. This opens the WebF DevTools panel.
2.  In the panel, click the **"Copy" icon** to get the DevTools URL (`devtools://...`).
3.  Paste this URL into a desktop Google Chrome browser to connect the inspector.

With the Chrome DevTools connected, you can:
*   View `console.log()` messages.
*   Inspect the DOM element tree and CSS styles.
*   Analyze network requests in the "Network" tab.

**Note**: The JavaScript debugger (e.g., setting breakpoints in the "Sources" tab) is not yet supported in the Chrome DevTools integration. For performance metrics, use the dedicated Performance tab in the in-app DevTools panel.

### Reading JS Logs from the Command Line

As an alternative to the DevTools UI, you can view `console.log` messages using platform-specific tools.

*   **macOS (for the desktop app)**:
    ```bash
    /Applications/WebF\ Go.app/Contents/MacOS/WebF\ Go
    ```

*   **Windows**:
    ```powershell
    # Navigate to the installation directory and run the executable
    .\webf_go.exe
    ```

*   **Linux**:
    ```bash
    # Navigate to the installation directory and run the executable
    ./webf_go
    ```

*   **Android**:
    ```bash
    # Use the Android Debug Bridge (adb) to view logs
    adb logcat | grep "WEBF_NATIVE_LOG"
    ```

*   **iOS**:
    1.  Ensure your connected iOS device has **Developer Mode** enabled.
    2.  On your Mac, open the **Console.app**.
    3.  Select your iOS device from the sidebar.
    4.  In the search bar, filter the logs by entering `WEBF_NATIVE_LOG`.

---

## Core Concepts

This section covers the fundamental concepts of WebF. Understanding these will help you use the framework effectively.

### DOM & Elements

The foundation of your application's UI in WebF is the Document Object Model (DOM), just like on the web. While you can use standard DOM APIs directly, you will typically use a UI framework like React, Vue, or Svelte to provide a more declarative way to build your UI.

A simple React component in WebF looks exactly like it would for the web:
```jsx
function HelloWorld() {
  const styles = {
    backgroundColor: 'yellow',
    padding: '10px'
  };
  return <div style={styles}>Hello, from WebF!</div>;
}

// This component would be rendered using ReactDOM.
```

### Async Rendering

A key difference between WebF and a browser is WebF's **asynchronous rendering model**. In a browser, DOM changes can immediately trigger a synchronous and blocking layout and paint. WebF avoids this for better performance.

*   **DOM updates are cheap**: When you call `appendChild()` or change a style, WebF does not immediately re-render the screen. It waits for the next rendering frame.
*   **Batched Updates**: This model allows WebF to batch multiple DOM changes together and process them in a single, optimized pass, avoiding layout thrashing.
*   **Onscreen and Offscreen Events**: To work with the asynchronous renderer, WebF provides two essential, non-standard events: `onscreen` and `offscreen`. Because DOM elements can exist in the tree before they are laid out, you **must** use these events to know when it is safe to access layout-dependent APIs like `element.getBoundingClientRect()` or `window.getComputedStyle()`.
    *   The `onscreen` event fires when an element has been fully laid out and rendered.
    *   The `offscreen` event fires when an element is no longer rendered.

    Attempting to measure an element or get its computed style before the `onscreen` event has fired will result in incorrect or zero-based values.

> **Note for React Developers:** The `@openwebf/react-core-ui` package provides a `useFlutterAttached` hook to handle this. The hook accepts optional `onAttached` and `onDetached` callbacks and returns a `ref` object to pass to your element. The `onAttached` callback is the correct place to perform measurements.
>
> ```jsx
> import { useFlutterAttached } from '@openwebf/react-core-ui';
>
> function MyComponent() {
>   const flutterRef = useFlutterAttached(
>     () => {
>       console.log('Component is now rendered by Flutter.');
>       // It's now safe to perform measurements on the element.
>       if (flutterRef.current) {
>         const rect = flutterRef.current.getBoundingClientRect();
>         console.log('Element position:', rect.top, rect.left);
>       }
>     },
>     () => {
>       console.log('Component is detached from the Flutter render tree.');
>     }
>   );
>
>   return <div ref={flutterRef}>Content</div>;
> }
> ```

### CSS & Styling

WebF supports styling your application using Cascading Style Sheets (CSS), following W3C standards. You can use most of the CSS features you already know to control layout, colors, fonts, and more.

*   **Layout**: WebF supports modern CSS layout techniques. This includes:
    *   Standard flow layout (**block** and **inline**), with full support for Right-to-Left (RTL) text.
    *   **Positioned** layout (using `position: absolute`, `relative`, etc.).
    *   **Flexbox**, which is the recommended approach for building most UIs.
    *   **Unsupported**: Please note that legacy layout models like **`float`** and **`table`** layouts are not supported. **CSS Grid** is also not supported at this time.
*   **Selectors**: You can target elements using a wide range of CSS selectors.
*   **Applying Styles**: Styles can be applied using `<style>` tags, external stylesheets, or inline styles.

For information on integrating popular styling tools like Tailwind CSS or pre-processors like Sass/SCSS, please see the [**Advanced Styling**](#advanced-styling) section.

### JavaScript & Events

WebF provides a modern JavaScript environment and supports the standard W3C event model, including the **capturing** and **bubbling** phases of event propagation.

**Default Interactive Event**

For performance reasons, only the `click` event is enabled on all elements by default. In React, you can use the `onClick` prop as you normally would.

```jsx
function ClickableButton() {
  const handleClick = () => {
    console.log('Button was clicked!');
  };
  return <button onClick={handleClick}>Click Me</button>;
}
```

**Advanced Gestures**

To enable more complex gestures like `double-tap` or `long-press`, you must use a special component. In React, this is the `<FlutterGestureDetector>` component from the `@openwebf/react-core-ui` package.

```jsx
import { FlutterGestureDetector } from '@openwebf/react-core-ui';

function MyInteractiveComponent() {
  const handleDoubleTap = () => {
    console.log('Component was double-tapped!');
  };

  return (
    <FlutterGestureDetector onDoubleTap={handleDoubleTap}>
      <div style={{ padding: '20px', border: '1px solid #ccc' }}>
        Double-tap me!
      </div>
    </FlutterGestureDetector>
  );
}
```

### Networking

WebF provides the standard `fetch` API for making network requests. Here's how you might use it inside a React component to fetch data when the component mounts.

```jsx
import { useState, useEffect } from 'react';

function DataFetcher() {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch('https://api.example.com/data')
      .then(response => response.json())
      .then(data => setData(data));
  }, []); // Empty dependency array means this runs once on mount

  if (!data) {
    return <div>Loading...</div>;
  }

  return <pre>{JSON.stringify(data, null, 2)}</pre>;
}
```

Because the `fetch` API is available, popular data-fetching libraries like `axios` also work out of the box.

### Routing

Routing in WebF is fundamentally different from traditional Single-Page Applications (SPAs). To achieve a truly native navigation experience with proper screen transitions, WebF **does not use the standard History API or hash-based routing**.

Instead, WebF uses a **native routing mechanism**, where each "page" of your web application is rendered on a separate, native Flutter screen.

To manage this, you will use a framework-specific routing package designed for WebF.

**For React Developers:**

The official approach is to use the `@openwebf/react-router` package. This library provides a familiar component-based API. You can include a `title` prop on each `<Route>` to set the text that appears in the center of the native navigation bar for that screen.

```jsx
// A conceptual example of defining routes
import { Route, Routes } from '@openwebf/react-router';
import { HomePage } from './pages/home';
import { ProfilePage } from './pages/profile';

function App() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} title="Home" />
      <Route path="/profile" element={<ProfilePage />} title="My Profile" />
    </Routes>
  );
}
```

This approach is key to making your app feel truly native, with correct screen transitions and lifecycle management.

> **Note for other frameworks:** This example uses the official package for React. If a similar routing package does not yet exist for your framework, please feel free to [open an issue](https://github.com/openwebf/webf/issues) to discuss it with the WebF team.

### Accessing Native Features

WebF allows your application to go beyond the limits of a standard browser by accessing native device capabilities like the camera, system share dialog, or local file system. This is made possible by an internal mechanism called the **Native Binding System**.

As a web developer, you will not use this system directly. Instead, you will consume this functionality through **WebF Native Plugins**—pre-packaged `npm` modules that expose specific native features to your JavaScript code.

For example, after installing the `@openwebf/webf-share` package, you can use its `WebFShare` class inside a React component to trigger the native share dialog:

```jsx
import React from 'react';
import { WebFShare } from '@openwebf/webf-share';

function ShareButton() {
  const handleShare = async () => {
    if (WebFShare.isAvailable()) {
      await WebFShare.shareText({
        url: 'https://openwebf.com',
        text: 'Check out this powerful new way to build apps!',
        title: 'WebF'
      });
    } else {
      console.log('Share API is not available in this environment.');
    }
  };

  return <button onClick={handleShare}>Share This App</button>;
}
```
*The `@openwebf/webf-share` package also provides a `useWebFShare` hook for more advanced use cases.*

To learn how to find and integrate these plugins, please see the **[Using WebF Native Plugins](#using-webf-native-plugins)** section.

---

## Using Flutter UI Libraries

This is one of WebF's most powerful features. It allows you to use high-performance, platform-perfect Flutter widgets directly within your web-based UI, seamlessly mixing native components and web content.

### How It Works

Unlike libraries that emulate a native look with CSS, WebF renders the **actual native widgets**. This is achieved through a powerful custom element bridge:

1.  **Native Widget Wrappers**: In the underlying Flutter engine, a native widget (like Flutter's `CupertinoButton`) is wrapped in a special Dart class.
2.  **Custom Element Binding**: This Dart wrapper is registered with WebF as a custom HTML element (e.g., `<flutter-cupertino-button>`).
3.  **Rendering**: When WebF encounters this custom tag in your application, it instructs the Flutter engine to render the real native widget in its place.
4.  **Props and Styling**: HTML attributes and CSS styles you apply to the custom element are passed down to the native widget, allowing you to configure and style it from your web code.
5.  **Events**: When you interact with the native widget (e.g., by pressing it), the widget emits a standard DOM event (like `click`), which your JavaScript code can listen for.

### Example: Using a Cupertino Button in React

The easiest way to use these native widgets is with a pre-packaged `npm` library that provides convenient wrappers for your chosen framework. The `@openwebf/react-cupertino-ui` package does exactly this for React.

First, install the package:
```bash
npm install @openwebf/react-cupertino-ui
```

Now, you can import and use the components just like any other React component.

```jsx
import React from 'react';
import { FlutterCupertinoButton } from '@openwebf/react-cupertino-ui';

function MyCupertinoApp() {
  const handleClick = () => {
    console.log('Native Cupertino button was clicked!');
  };

  return (
    <div>
      <h2>A real native iOS-style button:</h2>
      <FlutterCupertinoButton
        onClick={handleClick}
        style={{
          width: '200px',
          height: '50px',
          fontSize: '18px',
        }}
      >
        Press Me
      </FlutterCupertinoButton>
    </div>
  );
}
```

When this component renders, you are not seeing a `<div>` styled to look like a button. You are seeing the **actual, high-fidelity `CupertinoButton` widget from Flutter**, rendered right inside your web layout. This ensures perfect visuals, accessibility, and native performance.

> **See More Examples**: For a full collection of examples and use cases for all the components in the `@openwebf/react-cupertino-ui` package, please see our [**Cupertino UI Examples Guide**](CUPERTINO_UI_EXAMPLES.md).

> **Learn More**: Creating your own hybrid UI packages is an advanced and powerful feature of WebF. To learn about the `webf codegen` tool and the process of wrapping your own Flutter widgets for use in WebF, please see our dedicated [**Hybrid UI Development Guide**](HYBRID_UI_DEVELOPMENT_GUIDE.md).

---

## Web API Compatibility

While WebF aims for W3C compliance, it is an application runtime, not a browser. As such, its support for various Web APIs differs. Below is a summary of the compatibility status for common APIs.

| API | Supported | Notes |
| :--- | :---: | :--- |
| **Essential APIs** | | |
| `Timers` | ✅ Yes | `setTimeout`, `setInterval`, and `requestAnimationFrame` are supported. |
| `URL API` | ✅ Yes | `URL` and `URLSearchParams` are fully supported. |
| **Storage** | | |
| `localStorage` | ✅ Yes | Fully supported for persistent key-value storage. |
| `sessionStorage`| ✅ Yes | Fully supported for session-only key-value storage. |
| `IndexedDB` | ❌ No | For complex local data, use a native plugin. |
| **Networking** | | |
| `fetch` | ✅ Yes | Fully supported. |
| `XMLHttpRequest`| ✅ Yes | Supported for legacy use cases. |
| `WebSockets` | ✅ Yes | Fully supported for real-time communication. |
| **Graphics & Animation** | | |
| `CSS Animations & Transitions` | ✅ Yes | Fully supported. |
| `SVG` | ✅ Yes | Rendering of `<svg>` elements is supported. |
| `Canvas (2D)`| ✅ Yes | The 2D canvas context is supported. |
| `WebGL` | ❌ No | |
| `Web Animations API` | ❌ No | The JavaScript API for controlling animations is not yet supported. |
| **Workers** | | |
| `Web Workers` | ❌ No | JavaScript runs on a dedicated thread, so `Web Workers` are not needed. |
| **DOM & UI** | | |
| `Shadow DOM` | ❌ No | Not used for component encapsulation. |
| `Custom Elements`| ✅ Yes | Fundamental to the hybrid UI model. |
| `MutationObserver`| ✅ Yes | Supported for observing DOM changes. |
| `Intersection Observer` | ✅ Yes | The `onscreen` and `offscreen` events provide equivalent functionality. |

---

## Using with Web Frameworks

One of WebF's core principles is **Ecosystem Compatibility**. This means WebF is designed to work with your favorite web framework, not against it. Because WebF provides a standards-compliant DOM and event model, popular frameworks work out of the box.

You can create a project using Vite and select the framework of your choice during setup. The following section provides a specific example for React.js, but the general principles apply to other frameworks like Vue, Svelte, and more.

### React.js

You can use React to build your application's UI just as you would for the web.

Here is a basic example of a counter application built with React:

**`src/main.jsx`**

```jsx
import React, { useState } from 'react';
import ReactDOM from 'react-dom/client';

function App() {
  const [count, setCount] = useState(0);

  return (
    <div style={{ textAlign: 'center', marginTop: '50px' }}>
      <h1>Welcome to React on WebF!</h1>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}

// Standard React entry point
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

**`index.html`**

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>React on WebF</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
```

#### Deeper Integration

For a richer experience, the `@openwebf/react-core-ui` package provides components and hooks that are optimized for the WebF environment.

*   Use `<FlutterGestureDetector>` to handle advanced gestures.
*   Use `useFlutterAttached` to safely measure the layout of your components.

### Vue.js

You can use Vue and its familiar Single-File Component (SFC) structure to build your WebF application. When creating a project with Vite, simply select `vue` as your desired framework.

Here is a basic example of a counter component in Vue:

**`src/App.vue`**
```vue
<script setup>
import { ref } from 'vue'

const count = ref(0)
</script>

<template>
  <div class="container">
    <h1>Welcome to Vue on WebF!</h1>
    <p>You clicked {{ count }} times</p>
    <button @click="count++">
      Click me
    </button>
  </div>
</template>

<style scoped>
.container {
  text-align: center;
  margin-top: 50px;
}
</style>
```

### Preact

For developers who prefer a lightweight alternative to React, Preact is fully compatible with WebF. The component syntax is the same, just with different imports.

**`src/main.jsx`**
```jsx
import { render } from 'preact';
import { useState } from 'preact/hooks';

function App() {
  const [count, setCount] = useState(0);

  return (
    <div style={{ textAlign: 'center', marginTop: '50px' }}>
      <h1>Welcome to Preact on WebF!</h1>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}

render(<App />, document.getElementById('app'));
```

### Svelte

Svelte's compiler-based approach also works perfectly with WebF. When creating a project with Vite, select `svelte`.

Here is a basic counter in a Svelte component:

**`src/App.svelte`**
```svelte
<script>
  let count = 0;

  function handleClick() {
    count += 1;
  }
</script>

<main>
  <h1>Welcome to Svelte on WebF!</h1>
  <p>You clicked {count} times</p>
  <button on:click={handleClick}>
    Click me
  </button>
</main>

<style>
  main {
    text-align: center;
    margin-top: 50px;
  }
</style>
```

### Solid

Solid.js, with its fine-grained reactivity, is another excellent choice for building high-performance UIs in WebF.

**`src/App.jsx`**
```jsx
import { createSignal } from 'solid-js';

function App() {
  const [count, setCount] = createSignal(0);

  return (
    <div style={{ "text-align": 'center', "margin-top": '50px' }}>
      <h1>Welcome to Solid on WebF!</h1>
      <p>You clicked {count()} times</p>
      <button onClick={() => setCount(count() + 1)}>
        Click me
      </button>
    </div>
  );
}

export default App;
```

### Qwik

Qwik's focus on resumability and lazy-loading offers a unique approach to building applications, and it is compatible with the WebF environment.

**`src/routes/index.tsx`**
```tsx
import { component$, useSignal } from '@builder.io/qwik';

export default component$(() => {
  const count = useSignal(0);

  return (
    <div style={{ textAlign: 'center', marginTop: '50px' }}>
      <h1>Welcome to Qwik on WebF!</h1>
      <p>You clicked {count.value} times</p>
      <button onClick$={() => count.value++}>
        Click me
      </button>
    </div>
  );
});
```

---

## State Management

Because WebF is compatible with the modern web ecosystem, you can handle state management using the same tools and patterns you already use for web development.

### Framework-Specific State Management

You can use the built-in state management solutions provided by your chosen UI framework:

*   **React**: `useState` and `useReducer` for local state, and the `Context` API for passing state through the component tree.
*   **Vue**: The reactivity system, including `ref`, `reactive`, and the Composition API.
*   **Svelte**: Svelte's built-in reactive statements and stores.

### Dedicated State Libraries

For more complex application state, you can use any major state management library from the npm ecosystem. These libraries work out of the box with WebF. Popular choices include:

*   **Redux** (with React Redux)
*   **Zustand** (a popular, minimal solution for React)
*   **Pinia** (the recommended solution for Vue)
*   **XState** (for finite state machines)

### Example: Using Zustand with React

Here’s a quick example of how you can use a library like **Zustand** to manage global state.

First, install the library: `npm install zustand`

Then, create a simple store and use it in your components:

**`src/store.js`**
```javascript
import { create } from 'zustand';

export const useStore = create((set) => ({
  count: 0,
  increase: () => set((state) => ({ count: state.count + 1 })),
}));
```

**`src/App.jsx`**
```jsx
import React from 'react';
import { useStore } from './store';

function Counter() {
  const { count, increase } = useStore();

  return (
    <div>
      <p>Global count is: {count}</p>
      <button onClick={increase}>+1</button>
    </div>
  );
}
```

---

## Using with Web Build Tools

Following the core principle of **Ecosystem Compatibility**, WebF is designed to work with the modern web development toolchain, including your preferred build tool.

The development workflow is straightforward:
1.  Use a build tool to start a local development server for your web application.
2.  Load the URL of that server into the WebF Go app.

This means that **any web build tool that can create a local dev server is compatible with WebF**. No special plugins or complex configuration are required to get started.

While you can use any tool, **Vite** is highly recommended for the best development experience due to its fast startup time and excellent Hot Module Replacement (HMR) support, which integrates seamlessly with WebF.

Other popular build tools that work well with this workflow include:
*   **Webpack** (using `webpack-dev-server`)
*   **esbuild** (using its `serve` API)
*   **Rollup** (often used with a separate server plugin)

---

## Advanced Styling

WebF's compatibility with the standard web toolchain means you can use any modern CSS framework, pre-processor, or methodology you are familiar with.

The general process is always the same:
1.  Follow the official setup guide for the styling tool to integrate it with your build tool (e.g., Vite).
2.  Your build tool will process your styles (e.g., converting Sass to CSS, or processing Tailwind directives) and bundle the final CSS.
3.  WebF will render the resulting CSS just like a browser.

### Example: Using Tailwind CSS

[Tailwind CSS](https://tailwindcss.com/) is a popular utility-first CSS framework that works great with WebF.

**Important**: WebF is currently compatible with **Tailwind CSS v3**. You must follow the setup instructions specifically for this version.

To add Tailwind CSS v3 to a Vite project, follow the official guide on their v3 website:

[**Install Tailwind CSS v3 with Vite**](https://v3.tailwindcss.com/docs/guides/vite)

The process involves:
1.  Installing the v3 packages:
    ```bash
    npm install -D tailwindcss@^3.0 postcss autoprefixer
    npx tailwindcss init -p
    ```
2.  Configuring your `tailwind.config.js` to scan your source files.
3.  Adding the `@tailwind` directives to your main CSS file.

After this setup, you can use Tailwind's utility classes in your components, and they will be correctly processed by your dev server and rendered in WebF.

```jsx
// Example of a React component using Tailwind CSS utility classes
function TailwindCard() {
  return (
    <div class="p-6 max-w-sm mx-auto bg-white rounded-xl shadow-lg flex items-center space-x-4">
      <div>
        <div class="text-xl font-medium text-black">WebF App</div>
        <p class="text-slate-500">You're using Tailwind!</p>
      </div>
    </div>
  );
}
```

### Using Sass/SCSS or PostCSS

The same principle applies. For example, to use Sass, you would simply install the `sass` package (`npm install -D sass`) and then create `.scss` files in your project. Vite has built-in support for processing them automatically.

---

## Networking and Data

### Fetching Data from the Internet

WebF provides the standard web APIs for networking, allowing you to connect your application to backend services.

*   **Using `fetch`**: The modern `fetch` API is fully supported for making network requests. You can use it for `GET`, `POST`, and other requests, just like in a browser.

    ```javascript
    async function postData(url = '', data = {}) {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      });
      return response.json();
    }

    postData('https://api.example.com/data', { username: 'webf' })
      .then(data => {
        console.log(data);
      });
    ```

*   **Using Libraries**: Because the underlying APIs are supported, you can use popular networking libraries like [axios](https://axios-http.com/) without any special configuration.

### Working with Local Data

For persisting data locally on the device, WebF provides support for the standard Web Storage API.

*   **`localStorage`**: You can use `localStorage` to store simple key-value pairs that persist even after the application is closed and reopened.

    ```javascript
    // Save data
    localStorage.setItem('username', 'JohnDoe');

    // Retrieve data
    const username = localStorage.getItem('username'); // "JohnDoe"
    ```

*   **`sessionStorage`**: You can use `sessionStorage` for data that should only be available for the current session. This data is cleared when the application is completely closed.

**For Complex Data:**

Please note that **`IndexedDB` is not supported**. For more complex data storage needs, such as managing a local database, the recommended approach is to use a dedicated native plugin that can interface with a native database solution like SQLite or Hive. See the **[Using WebF Native Plugins](#using-webf-native-plugins)** section for more details.

---

## Using WebF Native Plugins

WebF's true power is unlocked when you access native device features. This is done through a system of native plugins, which are published as standard `npm` packages, making them easy for web developers to consume.

### Using Pre-built Plugins

The WebF team and community provide a growing ecosystem of pre-built plugins that expose native capabilities to your JavaScript code.

The workflow is simple and familiar:

**1. Find a Plugin:**
You can discover available plugins on the [npm registry](https://www.npmjs.com/search?q=%40openwebf) or by checking our official list of plugins (we can add a link here). Packages are typically named with the `@openwebf` scope, for example `@openwebf/webf-share`.

**2. Install the Plugin:**
Add the plugin to your project using `npm` or your preferred package manager.
```bash
npm install @openwebf/webf-share
```

**3. Import and Use it in Your Code:**
Once installed, you can import the plugin's functionality directly into your JavaScript or React components.

```jsx
// Continuing the example from the "Accessing Native Features" section:
import React from 'react';
import { WebFShare } from '@openwebf/webf-share';

function ShareButton() {
  const handleShare = async () => {
    if (WebFShare.isAvailable()) {
      await WebFShare.shareText({ text: 'Hello from WebF!' });
    }
  };

  return <button onClick={handleShare}>Share</button>;
}
```

### Creating a New Plugin

Creating a native plugin from scratch is an advanced topic that involves native development with Dart/Flutter and, potentially, platform-specific code (like Swift, Kotlin, or C++). This process allows you to expose any native functionality imaginable to your WebF application.

The high-level steps include:
1.  Writing the native Dart code for your feature.
2.  Using WebF's binding tools to create the connection between Dart and JavaScript.
3.  Publishing the plugin as an `npm` package for other developers to use.

This process is outside the scope of this guide. For a full walkthrough, please refer to our dedicated [**Native Plugin Development Guide**](NATIVE_PLUGIN_DEVELOPMENT_GUIDE.md).

---

## Testing

Because WebF builds upon the standard web technology stack, you can use the same industry-standard tools and methodologies you already know to test your application's logic and components.

### Unit Testing

For testing individual functions, hooks, or business logic in isolation, you can use any standard JavaScript testing framework like [**Jest**](https://jestjs.io/) or [**Vitest**](https://vitest.dev/). These tests run in a Node.js environment and do not require a browser or a WebF instance.

```javascript
// Example using Vitest
import { expect, test } from 'vitest';

function add(a, b) {
  return a + b;
}

test('add function works', () => {
  expect(add(1, 2)).toBe(3);
});
```

### Component Testing

To test your components' behavior and rendering logic without needing to run the full application, you can use a component testing library in a simulated DOM environment (`jsdom`).

*   For React, the recommended tool is [**React Testing Library**](https://testing-library.com/docs/react-testing-library/intro/) combined with a test runner like Vitest.

```jsx
// Example using Vitest and React Testing Library
import { render, screen, fireEvent } from '@testing-library/react';
import { test, expect } from 'vitest';
import MyComponent from './MyComponent';

test('MyComponent updates on click', () => {
  render(<MyComponent />);
  
  const button = screen.getByRole('button');
  fireEvent.click(button);
  
  expect(screen.getByText(/count is 1/i)).toBeInTheDocument();
});
```

### End-to-End (E2E) Testing

**Note**: True End-to-End (E2E) testing, which involves programmatically controlling the final, running application in the native WebF shell, is **not currently supported**. The recommended approach is to focus on thorough unit and component testing.

---

## Debugging and Performance

### Debugging your App

The primary tools for debugging your app are **Chrome DevTools** (for DOM/console/network) and **command-line logging**. For a detailed guide, refer back to the [**Using the DevTools**](#using-the-devtools) and [**Reading JS Logs from the Command Line**](#reading-js-logs-from-the-command-line) sections.

### Performance Profiling

WebF includes a built-in performance profiler, which is accessible directly from the in-app DevTools panel.

1.  While your app is running, click the **floating action button with the debug icon**.
2.  In the panel that appears, select the **"Performance"** tab.

This panel provides real-time insights into your application's rendering performance, such as frames per second (FPS), helping you identify and address performance bottlenecks.

### Best Practices

*   **Leverage Async Rendering**: Use the `onscreen` events or the `useFlutterAttached` hook to defer work on offscreen elements.
*   **Use Native Components**: For performance-critical UI, such as complex animations or large lists, prefer pre-built Flutter UI Components over pure web-based implementations.
*   **Standard Web Performance**: All standard web best practices still apply, including code-splitting, tree-shaking, and optimizing image assets.
*   **Efficient Bindings**: Be mindful of the size and frequency of data passed through the Native Binding System, as this can be a performance bottleneck if overused.

---

## Security

The security model of WebF is fundamentally different from that of a web browser. Understanding this is crucial for building a secure application.

### The Application is the Sandbox

A web browser's primary security feature is the **sandbox**, which strictly isolates web content from the user's operating system to protect against malicious websites.

WebF **removes this sandbox** to enable powerful features like the Native Binding System. The core security principle is that you are running your own trusted application code, not arbitrary code from the internet. Your application bundle itself is the security boundary.

### Best Practices

*   **Do Not Load Untrusted Content**: The most important rule is to only load code and assets that are part of your application. WebF is not designed to safely render arbitrary third-party web pages. Navigation to external origins is disabled by default for this reason.

*   **Vet Your Native Plugins**: When you add a WebF Native Plugin from `npm`, you are adding native code to your application that runs with the full permissions of the app. Only use plugins from authors and sources that you trust.

*   **Secure Your Bindings**: When creating your own native bindings, be careful about the functionality you expose to JavaScript. Avoid exposing powerful, low-level system functions that could be dangerous if a vulnerability was found in your web-layer code.

*   **Handle Data with Care**: Treat any sensitive data passed between the JavaScript and native layers with the same security standards as you would in a fully native application.

---

## Deploying Updates

One of WebF's most powerful features is its ability to support web-like "Over-the-Air" (OTA) updates. This allows you to deploy updates to your application's UI and logic instantly, without requiring users to download a new version from the app store.

The deployment workflow is nearly identical to deploying a standard website.

### Step 1: Build Your Web Application

First, create an optimized, static build of your application using the standard `build` command from your build tool.

```bash
# For projects set up with Vite
npm run build
```
This will compile and minify your HTML, CSS, and JavaScript into a `dist` (or similar) directory.

### Step 2: Deploy Your Web Assets to a CDN

Next, upload the contents of your build output directory (e.g., `dist`) to any static web hosting provider or CDN. Common choices include:

*   [Vercel](https://vercel.com/)
*   [Netlify](https://www.netlify.com/)
*   [AWS S3/CloudFront](https://aws.amazon.com/s3/)
*   Your own web server

Once deployed, you will have a public URL for your application (e.g., `https://my-app.vercel.app`).

### Step 3: Loading the URL in the App

The native host application (like WebF Go or your team's custom app) is configured to load your application from this public URL in a production environment.

When a user opens their app, it will fetch and display the latest version of your web assets from the deployed URL. To push an update, you simply repeat the process: build your web app, upload the new files to your host, and all users will get the update automatically the next time they launch the app.

---

## Automation & CI/CD

Automating your testing and deployment process is a best practice for any serious application. For a WebF project, this typically involves setting up two separate, but related, CI/CD pipelines: one for your web application and one for the native host app.

### CI/CD for Your WebF Application

As a web developer, your primary focus will be on the CI/CD pipeline for your web assets. You can use any standard CI service like [GitHub Actions](https://github.com/features/actions), [GitLab CI](https://docs.gitlab.com/ee/ci/), or [CircleCI](https://circleci.com/).

The workflow is identical to that of a typical modern web application:

1.  **On push or merge to `main`**: The CI server checks out your code.
2.  **Install & Test**: It installs dependencies (`npm ci`) and runs all your tests (`npm test`).
3.  **Build**: If tests pass, it creates a production build of your web assets (`npm run build`).
4.  **Deploy**: The contents of the output `dist` directory are automatically deployed to your CDN or static hosting provider (e.g., Vercel, Netlify, AWS S3).

This ensures that every time you merge a new feature, it is automatically tested and deployed, providing instant "Over-the-Air" updates to your users.

**Conceptual GitHub Actions Workflow:**
```yaml
# .github/workflows/deploy-web.yml
name: Deploy Web Content
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm test
      - run: npm run build
      - name: Deploy to Production
        uses: your-favorite-deploy-action@v1 # Example
        with:
          # ... deploy configuration ...
```

### CI/CD for the Native Host App

The CI/CD pipeline for the native host app (which contains the WebF engine) is a separate process, usually managed by a Flutter development team. It handles building the native code, code signing, and publishing new versions of the app itself to the app stores.

This process is outside the scope of this guide. For details, refer to the [**Guide for Flutter Developers**](FLUTTER_INTEGRATION_GUIDE.md).

---

## Advanced Topics

This section covers more advanced or specialized topics for building rich applications with WebF.

### Animation

WebF supports standard **CSS Transitions** and **CSS Animations**, which are highly performant as they can be run off the main JavaScript thread.

Because this core technology is supported, the recommended best practice for creating animations in WebF is to leverage a utility-class framework like **Tailwind CSS**. This approach allows you to define your animations and transitions declaratively.

The workflow consists of two parts:
1.  Applying utility classes to define the initial state, final state, and the transition/animation properties of an element.
2.  Using JavaScript to toggle a class that triggers the transition between states, usually in response to a user interaction or state change.

**Example: Interactive Scale Animation with React and Tailwind CSS**

This example, adapted from our use cases, demonstrates a high-performance scale animation using CSS transforms. This type of animation is ideal for interactive elements like cards or buttons.

```jsx
import React, { useState } from 'react';

function ScaleAnimationExample() {
  const [isScaled, setIsScaled] = useState(false);

  return (
    <div className="p-6 flex flex-col items-center gap-6">
      <div
        className={[
          'w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg',
          'bg-gradient-to-br from-indigo-500 to-purple-600',
          // The transition utility enables smooth animation for transform changes
          'transition-transform duration-300 ease-out',
          // Toggle between scale classes based on state
          isScaled ? 'scale-110' : 'scale-90',
        ].join(' ')}
      >
        Scale
      </div>

      <button
        className="px-6 py-3 bg-blue-600 text-white rounded-lg font-medium"
        onClick={() => setIsScaled(!isScaled)}
      >
        {isScaled ? 'Scale Down' : 'Scale Up'}
      </button>
    </div>
  );
}
```

In this example, changing the `isScaled` state simply toggles the `scale-110` and `scale-90` classes. WebF's rendering engine handles the interpolation smoothly on the compositor thread, ensuring a jank-free experience.

### Custom Painting

[To be filled in by the user: Describe how developers can create custom-drawn UI elements. Explain if WebF exposes any low-level graphics APIs or integrates with web standards like Canvas for custom drawing.]

### Accessibility

[To be filled in by the user: Explain how to make WebF apps accessible to users with disabilities. Cover any specific WebF features, best practices, or limitations related to ARIA, semantic HTML, screen readers, etc.]

---

## Resources

[To be filled in by the user: This section will contain links to helpful resources such as the API reference, example projects, and community forums.]

---

## Contributing

[To be filled in by the user: This section will explain how developers can contribute to the WebF project, likely linking to a CONTRIBUTING.md file.]
