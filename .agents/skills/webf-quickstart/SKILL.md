---
name: webf-quickstart
description: Get started with WebF development - setup WebF Go, create a React/Vue/Svelte project with Vite, and load your first app. Use when starting a new WebF project, onboarding new developers, or setting up development environment.
---

# WebF Quickstart

> **Note**: Building WebF apps is nearly identical to building regular web apps with Vite + React/Vue/Svelte. The only difference is you replace your browser with **WebF Go** for testing during development. Everything else - project structure, build tools, testing frameworks, and deployment - works the same way.

> **⚠️ IMPORTANT**: WebF Go is for **development and testing ONLY**. For production, you must build a Flutter app with WebF integration. Do NOT distribute WebF Go to end users.

Get up and running with WebF in minutes. This skill guides you through setting up your development environment, creating your first project, and loading it in WebF Go.

## What You Need

**Only Node.js is required** - that's it!

- Node.js (LTS version recommended) from [nodejs.org](https://nodejs.org/)
- **You do NOT need**: Flutter SDK, Xcode, or Android Studio

WebF lets web developers build native apps using familiar web tools.

## Step-by-Step Setup

### 1. Download WebF Go (For Testing Only)

WebF Go is a pre-built native app containing the WebF rendering engine. It's designed for **development and testing purposes only** - not for production deployment.

**For Desktop Development:**
- Download WebF Go for your OS (macOS, Windows, Linux)
- Get it from: **https://openwebf.com/en/go**

**For Mobile Testing:**
- iOS: Download from App Store
- Android: Download from Google Play

**Remember**: WebF Go is a testing tool. For production apps, you'll need to build a Flutter app with WebF integration.

Launch WebF Go - you'll see an input field ready to load your app.

### 2. Create Your Project with Vite

Open your terminal and create a new project:

```bash
npm create vite@latest my-webf-app
```

Vite will prompt you to:
1. Choose a framework: **React**, **Vue**, **Svelte**, etc.
2. Choose a variant (JavaScript or TypeScript)

### 3. Install Dependencies and Start Dev Server

```bash
# Move into your project
cd my-webf-app

# Install dependencies
npm install

# Start the dev server
npm run dev
```

Your terminal will show URLs like:
```
  VITE v5.0.0  ready in 123 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.1.100:5173/
```

### 4. Load in WebF Go

**For Desktop:**
1. Copy the `http://localhost:5173/` URL
2. Paste into WebF Go's input field
3. Press Enter or click "Go"

**For Mobile Device:**
⚠️ **IMPORTANT**: Mobile devices cannot access `localhost`

You MUST use the Network URL instead:
1. Make sure your computer and mobile device are on the **same WiFi network**
2. Use `--host` flag to expose the dev server:
   ```bash
   npm run dev -- --host
   ```
3. Copy the **Network** URL (e.g., `http://192.168.1.100:5173/`)
4. Type it into WebF Go on your mobile device
5. Press "Go"

Your app will now render in WebF! 🎉

### 5. Verify Hot Reload

Make a quick change to your code and save. The app should automatically update - this is Vite's Hot Module Replacement (HMR) working with WebF.

### 6. (Optional) Setup Chrome DevTools

To debug your app:
1. Click the floating debug button in WebF Go
2. Click "Copy" to get the DevTools URL (`devtools://...`)
3. Paste into desktop Google Chrome browser
4. You can now use Console, Elements, Network tabs

**Note**: JavaScript breakpoints don't work yet - use `console.log()` instead.

## Common Issues and Solutions

### Issue: "Cannot connect" on mobile device

**Causes & Solutions:**
- ✗ Using `localhost` → ✓ Use Network URL (`http://192.168.x.x:5173`)
- ✗ Different WiFi networks → ✓ Put both devices on same network
- ✗ Missing `--host` flag → ✓ Use `npm run dev -- --host`
- ✗ Firewall blocking port → ✓ Allow port 5173 through firewall

### Issue: "Connection refused"

- Dev server not running → Run `npm run dev`
- Wrong port number → Check terminal output for correct port
- Firewall blocking → Temporarily disable to test

### Issue: App loads but doesn't update

- HMR not working → Refresh the page manually
- Dev server error → Check terminal for errors
- Network connection lost → Reconnect WiFi

## Production Deployment

⚠️ **WebF Go is NOT for production use**. It's a testing tool for developers.

### For Production Apps

When you're ready to deploy to end users, you need to:

**1. Build Your Web Bundle**
```bash
npm run build
```

**2. Host Your Bundle**
- Deploy to any web hosting (Vercel, Netlify, CDN, etc.)
- Your bundle will be accessible via URL (e.g., `https://your-app.com`)

**3. Create a Flutter App with WebF Integration**

You or your Flutter team needs to:
- Set up a Flutter project
- Add the WebF Flutter package to `pubspec.yaml`
- Configure the app (name, icon, splash screen, permissions)
- Load your web bundle URL in the WebF widget

**Example Flutter Integration:**
```dart
import 'package:webf/webf.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebF(
      bundle: WebFBundle.fromUrl('https://your-app.com'),
    );
  }
}
```

**4. Build and Deploy Flutter App**
- Build for iOS and Android
- Submit to App Store and Google Play

**Resources:**
- [WebF Integration Guide](https://openwebf.com/en/docs/developer-guide/integration)
- [Flutter App Setup](https://openwebf.com/en/docs/developer-guide/app-setup)

### Development vs Production

| Aspect | Development | Production |
|--------|------------|------------|
| **Tool** | WebF Go | Custom Flutter app |
| **Purpose** | Testing & iteration | End-user distribution |
| **Setup** | Download and run | Build Flutter app |
| **Distribution** | Don't distribute | App Store/Google Play |
| **Requirements** | Node.js only | Flutter SDK required |

## Next Steps

Now that you have a working dev environment:

1. **Learn the #1 difference**: WebF uses async rendering - see the `webf-async-rendering` skill
2. **Check API compatibility**: Not all web APIs work in WebF - see `webf-api-compatibility` skill
3. **Add navigation**: Multi-screen apps use WebF routing - see `webf-routing-setup` skill

## Quick Reference

```bash
# Create new project
npm create vite@latest my-app

# Start dev server (desktop)
npm run dev

# Start dev server (mobile - with network access)
npm run dev -- --host

# Install dependencies
npm install

# Build for production
npm run build
```

## Resources

- **Getting Started Guide**: https://openwebf.com/en/docs/developer-guide/getting-started
- **WebF Go Guide**: https://openwebf.com/en/docs/learn-webf/webf-go
- **Development Workflow**: https://openwebf.com/en/docs/developer-guide/development-workflow
- **Download WebF Go**: https://openwebf.com/en/go
- **Full Documentation**: https://openwebf.com/en/docs