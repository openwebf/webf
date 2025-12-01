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
  <b>Glue everything between Web, Flutter and Native</b><br/>
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

## Why OpenWebF?

**Build Fast. Ship Fast. Run Fast.**

OpenWebF is the browser like runtime that brings web development's speed and flexibility directly to Flutter. Seamlessly glues Web, Flutter, and Native platforms together, enabling you to:

- **Build Fast:** Dev with React or Vue + TailwindCSS, build with Vite, and deploy to Vercel - it all just works in WebF
- **Ship Fast:** Deploy once across all Flutter-supported platforms from a single codebase  
- **Run Fast:** Experience native-like performance that outpaces traditional WebView solutions

## Key Features

✅ **Optimized Rendering Architecture** - We solved browser engine bottlenecks - the magic that brings your React/Vue UI's LCP times to less than 100ms  
✅ **DOM, Window, Document, CSS Selectors** - `document.querySelector()`, `window.localStorage`, `MutationObserver` - hundreds of web APIs just work  
✅ **Core CSS Support** - Standard CSS Box Model, CSS inline formatting context, CSS Flexbox, Animations - these features make TailwindCSS just work in WebF  
✅ **Framework Ready** - Your existing React hooks, Vue components, and npm packages work without modification  
✅ **Modern Build Tools Support** - Vite and Webpack builds just work in WebF - HMR, tree-shaking, code splitting all supported  
✅ **Popular Web Stack Ready** - Vercel, React, Next.js - the most popular web development workflows are ready for developing Flutter apps  
✅ **Flutter Widget Integration** - Use our code_gen tools to generate a ready-to-use React or Vue UI component library from your Flutter widget components in just one click  
✅ **Flutter Economy Access** - All Flutter plugins are available in WebF. Just tell us which Flutter packages you want from the [thousands available](https://fluttergems.dev/)  
✅ **Core DevTools Support** - Element panel inspection and network debugging with Chrome DevTools  
✅ **True Cross-Platform** - Same codebase runs on iOS, Android, Windows, macOS, Linux (web browser support coming soon)


## How It Works

WebF uses **QuickJS** as its JavaScript runtime to execute your web code. On top of this, we’ve implemented **hundreds of essential DOM APIs**, ensuring that popular web frameworks and modern build tools work out of the box.

We’ve also created a **custom layout engine** that extends Flutter’s capabilities. This enables support for the **CSS box model, block/inline formatting contexts, and flexbox layouts** to align closely with W3C CSS specifications.

Your JavaScript runs in a **dedicated thread** and supports **headless mode** without attaching to the Flutter rendering context. The JavaScript runtime persists throughout the app’s entire lifecycle, starting up in sync with the Dart VM for optimal performance.

Additionally, your **DOM elements and CSS UI share the same rendering context as Flutter widgets**, allowing you to **seamlessly blend Flutter widgets with HTML elements**. This unified approach creates a native-like development experience where web technologies and Flutter coexist naturally.

🚀 **Native-Like Speed** - No WebView overhead, runs directly on Flutter's rendering pipeline  
⚡ **Fast Startup** - Lightweight runtime loads instantly compared to heavy browser engines  
🎯 **Optimized Memory** - Efficient resource usage with shared rendering context  
📱 **Smooth Animations** - 60fps performance across all platforms

<img width="4452" height="3601" alt="Browser Engine Pipeline" src="https://github.com/user-attachments/assets/5f945b66-fbcd-47b8-9eba-078ee3417610" />


## Sponsors

<p style="font-size:21px; color:black;">Browser testing via 
  <a href="https://www.lambdatest.com/?utm_source=openwebf&utm_medium=sponsor" target="_blank">
      <img src="https://www.lambdatest.com/blue-logo.png" style="vertical-align: middle;" width="250" height="45" />
  </a>
</p>