# WebF Claude Code Skills

A collection of Claude Code skills for developers building applications with WebF. These skills help you understand WebF's unique architecture and build native mobile/desktop apps using web technologies (React, Vue, Svelte).

## Installation

Install via npm to get access to all WebF Claude Code skills:

```bash
npm install -g @openwebf/claude-code-skills
```

Or add to your project:

```bash
npm install --save-dev @openwebf/claude-code-skills
```

Claude Code will automatically detect and load these skills when working with WebF projects.

## What is WebF?

**WebF** is a W3C/WHATWG-compliant web runtime for Flutter that allows web developers to build native mobile and desktop apps using standard web technologies (HTML, CSS, JavaScript). It's NOT a browser - it's a Flutter application runtime that implements web standards.

## ⚠️ Important: WebF Go vs Production Deployment

**WebF Go is for testing and development ONLY** - it is NOT for production deployment.

### For Development & Testing:
- ✅ Use **WebF Go** (desktop/mobile app) to test your web code
- ✅ Fast iteration with hot reload
- ✅ No Flutter SDK required for web developers

### For Production Deployment:
- ❌ **Do NOT distribute WebF Go to end users**
- ✅ **You MUST build a Flutter app with WebF integration**
- ✅ Requires Flutter SDK and proper app setup
- ✅ Deploy through App Store/Google Play as a native app

**If you're building a production app**, you or your team will need to:
1. Set up a Flutter project
2. Integrate the WebF Flutter package
3. Configure your app (icons, splash screen, permissions, etc.)
4. Build and distribute through official app stores

See [WebF Integration Guide](https://openwebf.com/en/docs/developer-guide/integration) for production setup.

## Available Skills

### 1. webf-quickstart
**Use when**: Starting a new WebF project, onboarding developers, or setting up development environment

**What it covers**:
- Downloading and setting up WebF Go (for testing ONLY)
- Creating projects with Vite (React/Vue/Svelte)
- Network configuration for mobile testing
- Chrome DevTools setup
- Understanding WebF Go vs production deployment

**Trigger examples**:
- "How do I get started with WebF?"
- "Setup WebF development environment"
- "Create a new WebF app"

**Important**: WebF Go is for development/testing only. Production apps require a Flutter app with WebF integration.

---

### 2. webf-async-rendering
**Use when**: getBoundingClientRect returns zeros, computed styles are incorrect, measurements fail, or elements don't layout as expected

**What it covers**:
- Understanding WebF's async rendering model
- Using `onscreen`/`offscreen` events
- React `useFlutterAttached` hook
- When to measure elements safely

**Trigger examples**:
- "Why is getBoundingClientRect returning 0?"
- "Element measurements are wrong"
- "How to wait for layout in WebF?"

**This is the #1 most important concept** - WebF batches DOM updates and processes them asynchronously (20x faster than browsers), but you must wait for the `onscreen` event before measuring elements.

---

### 3. webf-api-compatibility
**Use when**: Planning features, debugging why APIs don't work, or finding alternatives for unsupported features

**What it covers**:
- JavaScript API compatibility (fetch ✅, IndexedDB ❌, WebGL ❌)
- CSS feature support (Flexbox ✅, float ❌, Grid ⏳)
- Framework compatibility (React, Vue, Svelte, Tailwind CSS)
- Native plugin alternatives (@openwebf/webf-share, custom plugins)

**Trigger examples**:
- "Does WebF support IndexedDB?"
- "Can I use CSS Grid in WebF?"
- "Is Tailwind CSS compatible?"
- "How to use float layout?"

---

### 4. webf-routing-setup
**Use when**: Setting up navigation, implementing multi-screen apps, or when react-router-dom doesn't work as expected

**What it covers**:
- Hybrid routing (each route = separate Flutter screen)
- Using @openwebf/react-router (NOT react-router-dom)
- Passing data between screens
- Cross-platform routing (WebF + browser)

**Trigger examples**:
- "How to setup routing in WebF?"
- "react-router-dom doesn't work"
- "Navigate between screens"
- "How to pass data between routes?"

---

### 5. webf-infinite-scrolling
**Use when**: Building scrollable lists, feeds, catalogs, or any UI with many items that needs optimal performance

**What it covers**:
- Using WebFListView for high-performance scrolling
- Pull-to-refresh functionality
- Infinite scrolling with load-more
- Critical structure requirement (direct children)
- Flutter-optimized rendering (60fps with thousands of items)

**Trigger examples**:
- "How to build an infinite scrolling list?"
- "Create a social media feed"
- "Build a product catalog with lazy loading"
- "My scrolling list is slow"
- "How to add pull-to-refresh?"

---

### 6. webf-native-ui
**Use when**: Building iOS-style apps, need native-looking components, want better performance than HTML/CSS

**What it covers**:
- Cupertino UI library (iOS-style components)
- Setting up Flutter packages and npm packages
- Using native components in React and Vue
- Mixing native UI with HTML/CSS
- Component reference and examples

**Trigger examples**:
- "How to use native UI components in WebF?"
- "Build an iOS-style form"
- "Use Cupertino UI components"
- "Setup Cupertino UI"
- "Better performance than HTML/CSS?"

---

### 7. webf-native-plugins
**Use when**: Need native platform capabilities like sharing, camera, payments, geolocation, or other device features beyond standard web APIs

**What it covers**:
- Finding available native plugins
- Installing Flutter packages and npm packages
- Using native platform capabilities in JavaScript
- Share plugin for content sharing
- Creating custom plugins
- Feature detection and error handling

**Trigger examples**:
- "How to share content in WebF?"
- "Access native platform features"
- "Use device camera in WebF"
- "Install native plugins"
- "Share images or text"

---

### 8. webf-hybrid-ui-dev
**Use when**: Building custom native/hybrid UI libraries by wrapping Flutter widgets as web-accessible custom elements

**What it covers**:
- Creating hybrid UI component libraries from Flutter widgets
- Writing TypeScript definition files (.d.ts)
- Writing Dart widget wrappers (WebFWidgetElement)
- Using WebF CLI for code generation
- Publishing npm packages for React/Vue
- Complete development workflow

**Trigger examples**:
- "How to create a custom UI library for WebF?"
- "Wrap a Flutter widget for web use"
- "Build a component library with Flutter widgets"
- "Create hybrid UI components"
- "Develop native UI library"

---

### 9. webf-native-plugin-dev
**Use when**: Building custom native plugins to expose Flutter packages or platform capabilities as JavaScript APIs

**What it covers**:
- Creating native plugin modules (functional capabilities, not UI)
- Wrapping existing Flutter packages as WebF modules
- Writing TypeScript definition files for module APIs
- Using WebF CLI for npm package generation
- Handling binary data, streams, and permissions
- Publishing Flutter packages and npm packages
- Difference between native plugins and hybrid UI

**Trigger examples**:
- "How to create a native plugin for WebF?"
- "Wrap a Flutter package as WebF plugin"
- "Build a camera/payment/sensor plugin"
- "Create custom WebF module"
- "Expose native capabilities to JavaScript"
- "What's the difference between plugin and UI component?"

## Quick Problem Solver

### "My measurements are all zeros"
→ Use **webf-async-rendering** skill
- You're measuring before layout completes
- Wait for `onscreen` event or use `useFlutterAttached`

### "This API/CSS feature doesn't work"
→ Use **webf-api-compatibility** skill
- Check if the API/CSS feature is supported
- Find native plugin alternatives

### "Routing doesn't work like in my browser app"
→ Use **webf-routing-setup** skill
- WebF uses hybrid routing, not SPA routing
- Use @openwebf/react-router, not react-router-dom

### "How do I get started?"
→ Use **webf-quickstart** skill
- Step-by-step setup guide
- WebF Go installation and configuration

### "How do I build a scrolling list/feed?"
→ Use **webf-infinite-scrolling** skill
- WebFListView for high-performance scrolling
- Pull-to-refresh and infinite scroll patterns
- Critical: Items must be direct children

### "How do I use native UI components?"
→ Use **webf-native-ui** skill
- Setup Cupertino UI (iOS-style components)
- Build native iOS forms and navigation
- Better performance than HTML/CSS

### "How do I access native platform features?"
→ Use **webf-native-plugins** skill
- Find available native plugins
- Install Share plugin for content sharing
- Access camera, payments, and other native APIs

### "How do I create a custom UI library?"
→ Use **webf-hybrid-ui-dev** skill
- Wrap Flutter widgets as web custom elements
- Write TypeScript definitions and Dart wrappers
- Generate React/Vue components with WebF CLI
- Publish component libraries to npm

### "How do I create a custom native plugin?"
→ Use **webf-native-plugin-dev** skill
- Build functional plugins (camera, sensors, payments)
- Wrap Flutter packages as WebF modules
- Write TypeScript definitions for module APIs
- Generate npm packages with WebF CLI

## Common Error Messages

| Error/Issue | Skill to Use | Solution |
|------------|--------------|----------|
| `getBoundingClientRect()` returns `{width: 0, height: 0}` | webf-async-rendering | Wait for `onscreen` event |
| `getComputedStyle()` returns incorrect values | webf-async-rendering | Wait for `onscreen` event |
| "IndexedDB is not defined" | webf-api-compatibility | Use localStorage or native plugin |
| "WebGL not supported" | webf-api-compatibility | Use Canvas 2D or Flutter rendering |
| Float layout not working | webf-api-compatibility | Use Flexbox instead |
| react-router-dom not navigating correctly | webf-routing-setup | Use @openwebf/react-router |
| Can't access localhost on mobile | webf-quickstart | Use Network URL with `--host` flag |
| Scrolling list is slow/laggy | webf-infinite-scrolling | Use WebFListView with direct children |
| finishLoad/finishRefresh not working | webf-infinite-scrolling | Ensure you call these methods after async operations |
| Want to use native UI components | webf-native-ui | Install Cupertino UI package |
| Need iOS-style buttons/forms | webf-native-ui | Use FlutterCupertinoButton and Cupertino form components |
| Need to share content/access camera | webf-native-plugins | Install native plugins from https://openwebf.com/en/native-plugins |
| "Plugin module not found" | webf-native-plugins | Register plugin with WebF.defineModule() in main.dart |

## Development Workflow

### Building WebF Apps = Building Web Apps

**Good news**: Building WebF apps is nearly identical to building regular web applications!

The workflow is the same as Vite + React/Vue/Svelte development:
- ✅ Use Vite to create and build projects
- ✅ Use any project structure you prefer (standard Vite structure recommended)
- ✅ Use the same testing tools (Vitest, Jest, etc.)
- ✅ Deploy to any web hosting service (Vercel, Netlify, etc.)
- ✅ All React.js and Vue.js features are fully supported

**The only difference**: Replace your browser with **WebF Go** for testing during development.

### The 3 Key Differences to Check

When building WebF apps, check these 3 areas:

1. **Async Rendering** → Use `webf-async-rendering` skill
   - WebF batches DOM updates (20x faster than browsers)
   - Must wait for `onscreen` event before measuring elements

2. **API Compatibility** → Use `webf-api-compatibility` skill
   - Most web APIs work (fetch, localStorage, Canvas 2D, etc.)
   - Some don't (IndexedDB, WebGL, float layout)
   - Check before implementing features

3. **Routing** → Use `webf-routing-setup` skill
   - Use `@openwebf/react-router` instead of `react-router-dom`
   - Each route is a separate native screen (not SPA-style)

### Performance Optimizations

WebF provides performance optimizations that are automatically applied:

**Infinite Scrolling Lists** → Use `webf-infinite-scrolling` skill
- WebFListView component for high-performance scrolling
- Flutter-level optimization (view recycling, 60fps scrolling)
- Pull-to-refresh and load-more built-in
- Critical: Each item must be a direct child of WebFListView

**Native UI Components** → Use `webf-native-ui` skill
- Pre-built Cupertino UI components (iOS-style)
- Native iOS buttons, forms, dialogs, pickers
- Better performance than HTML/CSS for complex UIs
- Full React and Vue support

### Development Process

**1. Setup (Day 1)**
```bash
# Create project (same as web development)
npm create vite@latest my-app
cd my-app
npm install

# Start dev server
npm run dev -- --host

# Open in WebF Go (instead of browser)
# http://192.168.x.x:5173
```

**2. Build Your App (Ongoing)**
```javascript
// Write React/Vue/Svelte code as usual
// Just check these 3 things:

// ✅ Check 1: Async Rendering
element.addEventListener('onscreen', () => {
  const rect = element.getBoundingClientRect(); // Safe to measure
});

// ✅ Check 2: API Compatibility
if (typeof IndexedDB !== 'undefined') {
  // Use IndexedDB
} else {
  // Use localStorage or native plugin
}

// ✅ Check 3: Routing
import { WebFRouter } from '@openwebf/react-router'; // Not react-router-dom
WebFRouter.pushState({}, '/next-page');
```

**3. Test (Same as Web)**
```bash
# Use any JS testing framework
npm install -D vitest
npm run test
```

**4. Build for Production**
```bash
# Build your web bundle
npm run build
```

**For Production Deployment**:
- ⚠️ **Do NOT use WebF Go for production** - it's for testing only
- ✅ Host your web bundle (Vercel, Netlify, CDN, etc.)
- ✅ Build a Flutter app with WebF integration that loads your bundle
- ✅ Deploy the Flutter app to App Store/Google Play

```bash
# Deploy your web bundle to hosting
vercel deploy

# Your Flutter app will load the bundle from the URL
# See: https://openwebf.com/en/docs/developer-guide/integration
```

### Project Structure

Use any structure you prefer. Standard Vite structure works great:

```
my-webf-app/
├── src/
│   ├── main.jsx          # Entry point
│   ├── App.jsx           # Root component
│   ├── components/       # Your components
│   ├── pages/           # Page components
│   └── styles/          # CSS files
├── public/              # Static assets
├── index.html           # HTML template
├── package.json         # Dependencies
└── vite.config.js       # Vite config
```

### When to Use Each Skill

**Starting a project?**
→ Use `webf-quickstart` - Setup WebF Go and dev environment

**Getting measurement errors?**
→ Use `webf-async-rendering` - Learn to wait for layout

**Planning a new feature?**
→ Use `webf-api-compatibility` - Check if APIs are supported

**Adding navigation?**
→ Use `webf-routing-setup` - Setup hybrid routing

**Building scrollable lists?**
→ Use `webf-infinite-scrolling` - High-performance lists with pull-to-refresh

**Want native UI components?**
→ Use `webf-native-ui` - Setup and use Cupertino UI (iOS-style components)

**Need native platform features?**
→ Use `webf-native-plugins` - Install plugins for sharing, camera, payments, etc.

**Want to create your own UI library?**
→ Use `webf-hybrid-ui-dev` - Build custom hybrid UI libraries from Flutter widgets

### Integration Patterns

_(Placeholder for future skills about Flutter integration patterns)_

## Key Differences from Browser Development

| Aspect | Browser | WebF |
|--------|---------|------|
| **Layout** | Synchronous (immediate) | Asynchronous (batched) |
| **Routing** | SPA (History API) | Hybrid (native screens) |
| **Storage** | IndexedDB, localStorage | localStorage, native plugins |
| **Graphics** | WebGL, Canvas 2D | Canvas 2D only |
| **CSS Layout** | Float, Table, Grid, Flexbox | Flexbox, Grid (coming soon) |
| **Transitions** | CSS animations | Native platform animations |
| **JavaScript** | V8/SpiderMonkey | QuickJS (ES6+) |

## Essential Knowledge for WebF Developers

### 1. Async Rendering (Most Important!)
```javascript
// ❌ WRONG - Measures too early
const div = document.createElement('div');
document.body.appendChild(div);
const rect = div.getBoundingClientRect(); // Returns zeros!

// ✅ CORRECT - Wait for layout
div.addEventListener('onscreen', () => {
  const rect = div.getBoundingClientRect(); // Real dimensions!
}, { once: true });
document.body.appendChild(div);
```

### 2. Use Correct Router
```bash
# ❌ WRONG
npm install react-router-dom

# ✅ CORRECT
npm install @openwebf/react-router
```

### 3. Check API Compatibility
```javascript
// Always check before using browser APIs
if (typeof IndexedDB !== 'undefined') {
  // Use IndexedDB
} else {
  // Use alternative (localStorage, native plugin)
}
```

### 4. Mobile Network Setup
```bash
# ❌ WRONG - Won't work on mobile
npm run dev
# Use: http://localhost:5173

# ✅ CORRECT - Works on mobile
npm run dev -- --host
# Use: http://192.168.x.x:5173
```

## Supported Frameworks

All these frameworks work with WebF out-of-the-box:

- ✅ React (16, 17, 18, 19)
- ✅ Vue (2, 3)
- ✅ Svelte
- ✅ Preact
- ✅ Solid
- ✅ Qwik
- ✅ Vanilla JavaScript

## Official WebF Packages

### Development Tools
- `@openwebf/react-router` - React routing for WebF
- `@openwebf/vue-router` - Vue routing for WebF
- `@openwebf/react-core-ui` - React utilities (useFlutterAttached, WebFListView)
- `@openwebf/vue-core-ui` - Vue utilities (useFlutterAttached, webf-list-view types)

### Native UI Components
- `@openwebf/react-cupertino-ui` - iOS-style Cupertino UI for React
- `@openwebf/vue-cupertino-ui` - iOS-style Cupertino UI for Vue
- `webf_cupertino_ui` - Flutter Cupertino UI package

### Native Plugins
- `@openwebf/webf-share` - Native share dialog (text, URLs, images)
- `webf_share` - Flutter package for Share plugin
- More plugins: https://openwebf.com/en/native-plugins

## Resources

### Documentation
- **Official Docs**: https://openwebf.com/en/docs
- **WebF Go**: https://openwebf.com/en/go
- **GitHub**: https://github.com/openwebf/webf

### Skill Files Location
All skills are in `/Users/andycall/workspace/webf/skills/`:
- `webf-quickstart/` - Getting started guide
- `webf-async-rendering/` - Async rendering patterns
- `webf-api-compatibility/` - API/CSS compatibility tables
- `webf-routing-setup/` - Routing setup and examples
- `webf-infinite-scrolling/` - High-performance scrolling lists
- `webf-native-ui/` - Native UI components (Cupertino UI for iOS)
- `webf-native-plugins/` - Native platform plugins (Share, Camera, etc.)
- `webf-hybrid-ui-dev/` - Developing custom hybrid UI libraries

### Each Skill Includes
- `SKILL.md` - Main skill definition with instructions
- Supporting files (examples, reference tables, alternatives)

## Getting Help

1. **Start with webf-quickstart** if you're new
2. **Use webf-async-rendering** for measurement issues
3. **Check webf-api-compatibility** before using new APIs
4. **Setup webf-routing-setup** for navigation
5. **Use webf-infinite-scrolling** for scrollable lists and feeds
6. **Use webf-native-ui** for native UI components
7. **Use webf-native-plugins** for native platform features

## Next Steps

After reading this README:

1. **New to WebF?** → Start with `webf-quickstart/SKILL.md`
2. **Building an app?** → Read `webf-async-rendering/SKILL.md` (most important!)
3. **Planning features?** → Check `webf-api-compatibility/reference.md`
4. **Adding navigation?** → Follow `webf-routing-setup/SKILL.md`
5. **Building scrollable lists?** → Follow `webf-infinite-scrolling/SKILL.md`
6. **Want native UI components?** → Follow `webf-native-ui/SKILL.md`
7. **Need native platform features?** → Follow `webf-native-plugins/SKILL.md`
8. **Creating your own UI library?** → Follow `webf-hybrid-ui-dev/SKILL.md`

## Contributing

These skills are designed for developers **using WebF** to build applications (not for contributors to the WebF runtime itself).

If you find issues or want to improve these skills, please open an issue or PR in the WebF repository.

---

**Built for**: Web developers building native apps with WebF
**Maintained by**: WebF team
**Last updated**: 2026-01-03