<h1 align="center">
<a href="https://openwebf.com" alt="openwebf-site">OpenWebF</a>
</h1>
<p align="center">
  <b>Bring JavaScript and Web Dev to <strong>Flutter</strong></b><br/>
</p>
<p align="center">
  <a href="https://openwebf.com/en/docs/learn-webf">
    <b>Learn WebF</b>
  </a>
  |
  <a href="https://openwebf.com/en/docs/developer-guide">
    <b>Developer Guide</b>
  </a>
  |
  <a href="https://openwebf.com/en/docs/add-webf-to-flutter/overview">
    <b>Add WebF to Flutter</b>
  </a>
</p>
<p align="center">
  <a aria-label="X" href="https://x.com/openwebf" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Twitter-black?style=for-the-badge&logo=Twitter">
  </a>
  <a aria-label="Discord-Link" href="https://discord.gg/DvUBtXZ5rK" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Discord-black?style=for-the-badge&logo=discord">
  </a>
  <a aria-label="Pub Package" href="https://pub.dev/packages/webf">
    <img alt="" src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  </a>
</p>

## What is WebF?

**WebF is a W3C/WHATWG-compliant web runtime for Flutter** that implements HTML, CSS, and the DOM, running JavaScript in a browser-like environment. It's not a browser—it's an **application runtime optimized for building native apps** using web technologies.

Unlike traditional WebViews, WebF features:
- A **custom Flutter-based rendering engine** rather than relying on system browsers
- **Direct JavaScript-to-native communication** without traditional bridge limitations
- Ability to **embed Flutter widgets as HTML elements** within the app UI
- An **application-first design** with a persistent JavaScript context

## Why WebF?

**Build Fast. Ship Fast. Run Fast.**

WebF seamlessly glues Web, Flutter, and Native platforms together, enabling you to:

- **🚀 Build Fast:** Develop with React, Vue, Svelte, Solid + TailwindCSS, build with Vite or Webpack, and leverage the entire npm ecosystem - it all just works in WebF
- **📦 Ship Fast:** Deploy once across all Flutter-supported platforms (iOS, Android, Windows, macOS, Linux) from a single codebase
- **⚡ Run Fast:** Experience native-like performance with sub-100ms cold starts and 60fps animations that outpaces traditional WebView solutions

## Key Features

### Web Standards Compliance

- **🔷 Modern JavaScript (ES6+)** - QuickJS runtime with async/await, Promises, modules, optional chaining, and template literals
- **🔷 Essential DOM APIs** - Element creation/manipulation, event listeners (capture/bubble), query selectors, classList, custom elements, MutationObserver
- **🔷 Comprehensive CSS Support** - Flexbox layouts, positioned layouts (absolute/relative/fixed/sticky), flow layouts, colors, gradients, transforms (2D/3D), transitions, animations, CSS variables, media queries, pseudo-classes
- **🔷 Web APIs** - `fetch`, `XMLHttpRequest`, `WebSockets`, `localStorage`, `sessionStorage`, `Canvas 2D`, `SVG`, URL parsing, timers

### Framework & Tooling Compatibility

- **⚛️ Frameworks:** React, Vue, Svelte, Preact, Solid, Qwik - your existing components and hooks work without modification
- **🛠️ Build Tools:** Vite (recommended), Webpack, esbuild, Rollup, Parcel - HMR, tree-shaking, code splitting all supported
- **🎨 Styling:** Tailwind CSS v3, Sass/SCSS, PostCSS, CSS Modules, Styled Components, Emotion
- **📦 npm Ecosystem:** Access to thousands of npm packages and the entire JavaScript ecosystem

### Flutter Integration

- **🔗 Hybrid UI** - Embed Flutter widgets as HTML custom elements with native performance and platform-appropriate appearance
- **🎯 Advanced Gestures** - Handle complex touch interactions with native precision via `FlutterGestureDetector`
- **📱 Native Plugins** - Access Flutter plugins (Share, Deep linking, and more) as npm packages
- **🏗️ Cupertino Components** - iOS-style native components without CSS emulation

### Developer Experience

- **🔍 Chrome DevTools** - Console, DOM inspection, and network monitoring
- **📊 In-App DevTools** - FPS, frame timing, and memory monitoring
- **🔥 Hot Module Replacement** - Full HMR support that preserves state across updates
- **⚡ Async Rendering** - Batched DOM updates that are 20x cheaper than browser implementations

### Deployment & Performance

- **🚀 Over-the-Air Updates** - Deploy instantly via CDN without app store reviews (compliant with Apple App Store and Google Play Store policies)
- **⚡ Fast Startup** - Production cold start < 100ms, development 200-300ms
- **🎮 Smooth Animations** - 60fps/120fps CSS transform animations with hardware acceleration
- **💾 Optimized Memory** - Typical 10-30MB JavaScript heap with shared rendering context
- **🔒 Security** - Application sandbox, keychain/keystore encrypted storage with biometric protection, HTTPS enforcement

## How It Works

### Architecture Overview

WebF combines two complementary layers to deliver a complete web runtime:

#### 1. Web Standards Layer
- **QuickJS JavaScript Runtime** - Lightweight engine supporting ES6+ with a single, persistent context per instance
- **W3C/WHATWG DOM Implementation** - Essential DOM APIs with event handling (capture/bubble phases)
- **CSSOM Implementation** - CSS parsing and rule calculation following web standards

#### 2. Custom Rendering Engine
- **Flutter-Based Layout Engine** - Supports Flexbox (recommended), positioned layouts, and flow layouts
- **Hardware-Accelerated Rendering** - Direct integration with Flutter's rendering pipeline
- **No System Dependencies** - Independent of system WebViews or browser engines

### Rendering Pipeline

1. **JavaScript Execution** → Modifies the DOM
2. **CSS Calculation** → Rules are calculated and applied
3. **Layout** → Element positions and sizes determined
4. **Paint** → Visual representation created
5. **Composite** → Flutter widgets composite the final output

**Key Optimization:** WebF tracks "dirty" nodes to recalculate only affected subtrees (similar to React's reconciliation), and batches DOM updates to process them in the next frame, preventing layout thrashing.

### Performance Benefits

- **Native-Like Speed** - No WebView overhead, runs directly on Flutter's rendering pipeline
- **Fast Startup** - Sub-100ms cold starts with lightweight runtime
- **Optimized Memory** - Efficient resource usage with shared rendering context
- **Smooth Animations** - 60fps/120fps performance across all platforms
- **Dedicated Thread** - JavaScript runs in a dedicated thread without blocking UI

## Getting Started

### For Web Developers

Get started quickly using **WebF Go** - a preview app that lets you test WebF applications on real devices without building a custom Flutter app.

#### Prerequisites
- Node.js (latest LTS recommended)

#### Quick Start

**1. Download WebF Go**
   - **Desktop**: Download from [https://openwebf.com/en/go](https://openwebf.com/en/go) (macOS, Windows, or Linux)
   - **Mobile**: Download from App Store (iOS) or Google Play (Android)

**2. Create Your Project**
   ```bash
   npm create vite@latest
   ```
   Select your preferred framework (React, Vue, Svelte, etc.) when prompted.

**3. Start Development Server**
   ```bash
   cd <your-project-name>
   npm install
   npm run dev
   ```

**4. Load in WebF Go**
   - Copy the Network URL from your terminal (typically `http://localhost:5173`)
   - Paste it into the WebF Go app's input field
   - Tap "Go"

Your application will render in the native WebF environment with hot-reload support for instant code changes!

### For Flutter Developers

Add WebF to your existing Flutter app to enable web content rendering.

#### Installation

1. Add WebF dependency to your `pubspec.yaml`:
   ```yaml
   dependencies:
     webf: ^0.23.10  # Check pub.dev for latest version
   ```

2. Run `flutter pub get`

#### Basic Setup

```dart
import 'package:webf/webf.dart';

void main() {
  // Initialize WebF controller manager
  WebFControllerManager.instance.initialize(
    WebFControllerManagerConfig(
      maxAliveInstances: 5,
      maxAttachedInstances: 3,
    ),
  );

  // Add a controller with prerendering
  WebFControllerManager.instance.addWithPrerendering(
    name: 'home',
    createController: () => WebFController(),
    bundle: WebFBundle.fromUrl('https://example.com/'),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: WebF.fromControllerName(
          controllerName: 'home',
          loadingWidget: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
```

#### Loading Content

WebF supports multiple content sources:
- **Remote URLs:** `WebFBundle.fromUrl('https://example.com/')`
- **Local assets:** `WebFBundle.fromUrl('assets:///assets/web/index.html')`
- **Development servers:** `WebFBundle.fromUrl('http://localhost:3000/')`
- **Inline HTML:** `WebFBundle.fromContent('<!DOCTYPE html>...')`

## Documentation

📚 **[Complete Documentation](https://openwebf.com/en/docs)** - Learn WebF architecture, developer guides, and Flutter integration

- **[Learn WebF](https://openwebf.com/en/docs/learn-webf)** - Overview, architecture, and key features
- **[Developer Guide](https://openwebf.com/en/docs/developer-guide)** - Getting started, frameworks, CSS, debugging, deployment
- **[Add WebF To Flutter](https://openwebf.com/en/docs/add-webf-to-flutter)** - Integration guide for Flutter engineers

## Use Cases

WebF is ideal for:

- **✅ Content-Heavy Applications** - Apps with dynamic, frequently-updated content
- **✅ Rapid Prototyping** - Leverage web development speed for fast iteration
- **✅ Cross-Platform Apps** - Single codebase for iOS, Android, and desktop
- **✅ Hybrid Native-Web UIs** - Mix Flutter widgets with web content seamlessly
- **✅ Over-the-Air Updates** - Deploy features and fixes without app store review delays

## Sponsors


<p style="font-size:21px; color:black;">
  <a href="https://www.testmu.ai" target="_blank">
    <img style="vertical-align: middle;" width="250" alt="black-logo" src="https://github.com/user-attachments/assets/45b689e1-e1f9-45c2-896b-1097e6220617" />
  </a>
</p>

## License

WebF is dual-licensed to provide flexibility for different use cases:

### Open Source License (GPL-3.0)

WebF is licensed under the **GNU General Public License version 3 (GPL-3.0)** with the OpenWebF Enterprise Exception.

**What this means:**
- ✅ **Free for open-source projects** - Use WebF freely in open-source applications under GPL-3.0 terms
- ✅ **Source code available** - Full access to the source code on [GitHub](https://github.com/openwebf/webf)
- ✅ **Community contributions welcome** - Join the community and contribute to the project
- ✅ **Package developers exemption** - Published open-source packages (npm/Flutter packages) that depend on WebF can use any license
- ⚠️ **GPL requirements apply to applications** - Applications using WebF must comply with GPL-3.0 terms (open source your application code)

### Enterprise License

For commercial applications that cannot comply with GPL-3.0 requirements, we offer the **OpenWebF Enterprise License**:

- ✅ **Commercial use** - Use WebF in closed-source commercial applications
- ✅ **No GPL restrictions** - Freedom from GPL copyleft requirements
- ✅ **Enterprise support** - Priority technical support and assistance
- ✅ **Additional features** - Access to enterprise-only features and early releases

**Enterprise Installation:**
```yaml
dependencies:
  webf: ^0.23.10  # Enterprise version available on pub.dev
```

### Choosing the Right License

| Use Case | Recommended License | Notes |
|----------|---------------------|-------|
| Open-source applications | GPL-3.0 (Open Source) | Your app must be GPL-3.0 compatible |
| Published npm/Flutter packages | Apache-2.0 or MIT | Your package can use permissive licenses |
| Internal/non-distributed apps | GPL-3.0 (Open Source) | No distribution = no GPL obligations |
| Commercial closed-source apps | Enterprise License | Required for proprietary applications |
| Apps distributed via app stores | Enterprise License | Required unless app is open source |
| Educational/research projects | GPL-3.0 (Open Source) | Free for academic use |

### Contact

For licensing questions or to obtain an Enterprise License:
- **Email:** support@openwebf.com
- **Website:** [https://openwebf.com](https://openwebf.com)
- **Software Agreement:** [https://openwebf.com/en/software-agreement](https://openwebf.com/en/software-agreement)

See the [LICENSE](LICENSE) file for the full GPL-3.0 license text and OpenWebF Enterprise Exception.

## Community & Support

- **Discord:** [Join our community](https://discord.gg/DvUBtXZ5rK)
- **Twitter/X:** [@openwebf](https://x.com/openwebf)
- **GitHub:** [github.com/openwebf/webf](https://github.com/openwebf/webf)
- **Email:** support@openwebf.com
