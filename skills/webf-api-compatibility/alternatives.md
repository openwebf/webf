# WebF API Alternatives & Native Plugins

When WebF doesn't support a browser API, you have several options: use a simpler supported API, use an official WebF plugin, or work with the Flutter team to create a custom native plugin.

## Storage Alternatives

### IndexedDB → localStorage or Native Plugin

**IndexedDB is NOT supported in WebF.** Here are your alternatives:

#### Option 1: Use localStorage (Recommended for Simple Cases)

For most applications, `localStorage` provides sufficient storage:

```javascript
// ✅ Simple key-value storage with JSON
const user = {
  id: 123,
  name: 'Alice',
  preferences: {
    theme: 'dark',
    language: 'en'
  }
};

// Store
localStorage.setItem('user', JSON.stringify(user));

// Retrieve
const storedUser = JSON.parse(localStorage.getItem('user'));

// Remove
localStorage.removeItem('user');

// Clear all
localStorage.clear();

// Check existence
if (localStorage.getItem('user') !== null) {
  console.log('User data exists');
}
```

**Advantages**:
- ✅ Synchronous API (simple to use)
- ✅ Supported everywhere
- ✅ No external dependencies
- ✅ ~5-10MB storage limit (platform-dependent)

**Limitations**:
- ❌ No indexing or queries
- ❌ No transactions
- ❌ String-only storage (must serialize)
- ❌ Synchronous (blocks thread for large data)

#### Option 2: Request Custom Native Plugin (For Complex Needs)

For complex database requirements (SQL queries, large datasets, relationships), work with the Flutter team to create a custom plugin using WebF's module system.

**When to use native plugins**:
- Large datasets (> 10MB)
- Complex queries (JOIN, WHERE, ORDER BY)
- Relational data
- High-performance requirements
- Offline-first applications

**Example workflow**:
1. **Flutter team creates native plugin** using `sqflite`, `Hive`, or `Isar`
2. **Plugin exposed to JavaScript** via WebF module system
3. **JavaScript code uses plugin** through simple async API

```javascript
// Example of custom storage plugin (created by Flutter team)
// This is NOT a real package, just an example pattern

import { AppStorage } from '@yourapp/storage-plugin';

// Initialize
await AppStorage.init({ dbName: 'myapp', version: 1 });

// Save data
await AppStorage.save('users', {
  id: 123,
  name: 'Alice',
  email: 'alice@example.com'
});

// Query data
const users = await AppStorage.query('users', {
  where: { age: { gte: 18 } },
  orderBy: 'name',
  limit: 10
});

// Update
await AppStorage.update('users', { id: 123 }, { name: 'Alicia' });

// Delete
await AppStorage.delete('users', { id: 123 });
```

**Resources**:
- WebF Module System: https://openwebf.com/en/docs/add-webf-to-flutter/bridge-modules
- Popular Flutter storage options:
  - `sqflite` - SQLite database
  - `Hive` - Fast key-value store
  - `Isar` - High-performance NoSQL database

## Graphics Alternatives

### WebGL → Canvas 2D (Limited) or Flutter Rendering

**WebGL is NOT supported in WebF.** No WebGL alternative exists within the JavaScript environment.

#### Option 1: Use Canvas 2D (Limited Graphics)

For simple 2D graphics, use Canvas 2D:

```javascript
const canvas = document.getElementById('myCanvas');
const ctx = canvas.getContext('2d');

// Draw shapes
ctx.fillStyle = '#FF0000';
ctx.fillRect(10, 10, 100, 100);

ctx.beginPath();
ctx.arc(75, 75, 50, 0, Math.PI * 2);
ctx.fill();

// Draw images
const img = new Image();
img.onload = () => {
  ctx.drawImage(img, 0, 0);
};
img.src = 'image.png';
```

**What Canvas 2D can do**:
- ✅ Draw shapes (rectangles, circles, paths)
- ✅ Draw images and sprites
- ✅ Apply transformations (rotate, scale, translate)
- ✅ Gradients and patterns
- ✅ Text rendering
- ✅ Pixel manipulation

**What Canvas 2D cannot do**:
- ❌ 3D graphics
- ❌ Hardware-accelerated shaders
- ❌ Complex lighting and textures
- ❌ High-performance game rendering

#### Option 2: Use SVG

For vector graphics and icons:

```javascript
// Create SVG dynamically
const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
svg.setAttribute('width', '200');
svg.setAttribute('height', '200');

const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
circle.setAttribute('cx', '100');
circle.setAttribute('cy', '100');
circle.setAttribute('r', '50');
circle.setAttribute('fill', 'blue');

svg.appendChild(circle);
document.body.appendChild(svg);
```

#### Option 3: Flutter Rendering (Flutter Team)

For complex graphics requirements (3D, games, custom rendering), the Flutter team can render directly using Flutter's rendering engine and expose controls to JavaScript.

## Native Feature Plugins

**IMPORTANT**: Always check the official plugins list first: https://openwebf.com/en/native-plugins

### Finding Available Plugins

Before implementing native features, follow these steps:

1. **Visit https://openwebf.com/en/native-plugins** - Check the complete list of available plugins
2. **Ask the user about their environment** - Setup differs significantly based on where the app runs
3. **Follow the plugin's installation guide** for their specific environment

### Step 1: Determine Your Environment

**IMPORTANT**: Setup differs based on where you're developing.

**Question**: "Are you testing in WebF Go, or working on a production app?"

**Option 1: Testing in WebF Go** (Most web developers)
- ✅ Just install npm package
- ✅ No additional setup needed
- ✅ WebF Go already has Flutter plugins included

**Example**:
```bash
# Just install npm package
npm install @openwebf/webf-share
```

**Option 2: Production app with Flutter team**
- ⚠️ Your Flutter developer must add the Flutter plugin first
- ⚠️ Once they confirm it's added, you can install npm package
- ⚠️ Give them the plugin documentation link

**What to tell your Flutter developer**:
```
"We need the webf_share plugin. Please add it to pubspec.yaml:
See: https://openwebf.com/en/native-plugins/webf-share"
```

**After Flutter developer confirms**:
```bash
# Then you install npm package in your JS project
npm install @openwebf/webf-share
```

### Example Plugin: @openwebf/webf-share

Native share dialog for sharing content.

**Installation:**

**If using WebF Go:**
```bash
# Just install npm package
npm install @openwebf/webf-share
```

**If integrating with Flutter app:**
```bash
# 1. First add to pubspec.yaml (see plugin docs)
# 2. Run: flutter pub get
# 3. Then install npm package:
npm install @openwebf/webf-share
```

```javascript
import { WebFShare } from '@openwebf/webf-share';

// Check if sharing is available
if (WebFShare.isAvailable()) {
  // Share text and URL
  await WebFShare.shareText({
    text: 'Check out this awesome app!',
    url: 'https://example.com',
    title: 'My App'
  });
}

// Share files (if supported by platform)
await WebFShare.shareFiles({
  files: [{ uri: 'file:///path/to/image.png', mimeType: 'image/png' }],
  text: 'Check out this image'
});
```

**React Hook**:

```jsx
import { useWebFShare } from '@openwebf/webf-share';

function ShareButton() {
  const { share, isAvailable } = useWebFShare();

  if (!isAvailable) {
    return null; // Share not available on this platform
  }

  const handleShare = async () => {
    try {
      await share({
        text: 'Hello from WebF!',
        url: 'https://openwebf.com'
      });
      console.log('Shared successfully');
    } catch (error) {
      console.error('Share failed:', error);
    }
  };

  return (
    <button onClick={handleShare}>
      Share
    </button>
  );
}
```

### @openwebf/webf-deeplink - Deep Linking

Handle deep links and universal links to integrate with other apps.

```bash
npm install @openwebf/webf-deeplink
```

```javascript
import { WebFDeepLink } from '@openwebf/webf-deeplink';

// Open a deep link with fallback
await WebFDeepLink.openDeepLink({
  url: 'whatsapp://send?text=Hello',
  fallbackUrl: 'https://wa.me/?text=Hello' // Used if app not installed
});

// Open app settings
await WebFDeepLink.openDeepLink({
  url: 'app-settings://'
});

// Listen for incoming deep links (when your app is opened via deep link)
WebFDeepLink.onDeepLink((url) => {
  console.log('Received deep link:', url);

  // Parse and handle the link
  if (url.startsWith('myapp://product/')) {
    const productId = url.split('/').pop();
    // Navigate to product page
    WebFRouter.pushState({}, `/product/${productId}`);
  }
});

// Remove listener when done
WebFDeepLink.removeDeepLinkListener();
```

**Use cases**:
- Open external apps (WhatsApp, Maps, Phone dialer)
- Handle incoming deep links from other apps
- Navigate to app settings
- Universal links for app-web integration

## Creating Custom Native Plugins

For features not covered by official plugins, you can create custom plugins using WebF's module system.

### Common Plugin Use Cases

- **Camera & Media**:
  - Photo/video capture
  - Gallery access
  - Image processing

- **Sensors**:
  - GPS/Location
  - Accelerometer
  - Gyroscope
  - Barcode scanning

- **System Integration**:
  - Notifications
  - Contacts
  - Calendar
  - File system access
  - Bluetooth

- **Advanced Storage**:
  - SQLite database
  - Secure storage
  - File encryption

### Plugin Development Process

1. **Flutter Team Creates Plugin**:
   - Implements feature using Flutter packages
   - Exposes API via WebF module system
   - Packages as npm module

2. **JavaScript Integration**:
   ```javascript
   // Example custom plugin pattern
   import { CameraPlugin } from '@yourapp/camera-plugin';

   // Take photo
   const photo = await CameraPlugin.takePicture({
     quality: 80,
     cameraDirection: 'back'
   });

   // Use the photo
   const img = document.createElement('img');
   img.src = photo.uri;
   document.body.appendChild(img);
   ```

3. **TypeScript Types** (optional but recommended):
   ```typescript
   declare module '@yourapp/camera-plugin' {
     export interface CameraOptions {
       quality?: number;
       cameraDirection?: 'front' | 'back';
       maxWidth?: number;
       maxHeight?: number;
     }

     export interface Photo {
       uri: string;
       width: number;
       height: number;
     }

     export class CameraPlugin {
       static takePicture(options?: CameraOptions): Promise<Photo>;
       static requestPermission(): Promise<boolean>;
     }
   }
   ```

### Module System Documentation

**Complete guide**: https://openwebf.com/en/docs/add-webf-to-flutter/bridge-modules

**Key concepts**:
- Plugins are Dart classes exposed to JavaScript
- Async/await supported
- Callbacks supported
- Type conversion automatic (JSON, primitives)
- Error handling built-in

## Web Workers → Not Needed

**Web Workers are NOT supported and NOT needed in WebF.**

### Why Web Workers Aren't Needed

In browsers, JavaScript runs on the main UI thread. Web Workers allow offloading work to background threads to keep the UI responsive.

**In WebF, JavaScript already runs on a dedicated thread**, separate from the Flutter UI thread. This means:

- ✅ JavaScript doesn't block the UI
- ✅ Heavy computations don't freeze the app
- ✅ Async operations are naturally non-blocking
- ✅ No performance benefit from Web Workers

### Alternative Pattern

Instead of Web Workers, use standard async patterns:

```javascript
// Browser pattern (Web Workers)
// ❌ Not needed in WebF

// WebF pattern (async/await)
// ✅ Works perfectly
async function heavyComputation() {
  const data = await fetch('/api/large-dataset');
  const processed = await processData(data);
  return processed;
}

// Use in component
async function handleClick() {
  const result = await heavyComputation();
  updateUI(result);
}
```

## Comparison Table: Alternatives

| Browser API | WebF Status | Alternative | Complexity |
|-------------|-------------|-------------|------------|
| IndexedDB | ❌ | localStorage | Easy |
| IndexedDB | ❌ | Native plugin (SQLite/Hive) | Medium |
| WebGL | ❌ | Canvas 2D (limited) | Easy |
| WebGL | ❌ | Flutter rendering | Hard |
| Web Workers | ❌ | Not needed (JS on dedicated thread) | N/A |
| Web Share API | ❌ | @openwebf/webf-share | Easy |
| Geolocation | ⚠️ | Native plugin | Medium |
| Camera API | ❌ | Native plugin | Medium |
| Notifications | ❌ | Native plugin | Medium |
| Bluetooth | ❌ | Native plugin | Hard |
| File System Access | ❌ | Native plugin | Medium |

## Decision Tree

```
Need storage?
├─ Simple key-value (< 5MB)
│  └─ Use localStorage ✅
├─ Complex queries, large data
│  └─ Request native plugin (SQLite/Hive) ✅
└─ IndexedDB specifically required
   └─ ❌ Not available - refactor to use alternative

Need graphics?
├─ 2D drawing, charts, sprites
│  └─ Use Canvas 2D ✅
├─ Vector graphics, icons
│  └─ Use SVG ✅
├─ 3D graphics, WebGL
│  └─ ❌ Not available - discuss with Flutter team

Need native features?
├─ Share content
│  └─ @openwebf/webf-share ✅
├─ Deep linking
│  └─ @openwebf/webf-deeplink ✅
├─ Camera, GPS, notifications, etc.
│  └─ Request custom plugin ✅

Need background threads?
└─ Web Workers
   └─ ❌ Not needed - JS runs on dedicated thread
```

## Resources

- **Official Plugins List**: https://openwebf.com/en/native-plugins (Check here first!)
- **WebF Plugins on npm**: https://www.npmjs.com/search?q=%40openwebf
- **Module System Guide**: https://openwebf.com/en/docs/add-webf-to-flutter/bridge-modules
- **Flutter Packages**: https://pub.dev (for Flutter team to use when building plugins)
- **GitHub Discussions**: Ask about plugin development

## Summary

When you encounter an unsupported API:

1. **Check if a simpler API works** (e.g., localStorage instead of IndexedDB)
2. **Look for official WebF plugins** (@openwebf/webf-share, @openwebf/webf-deeplink)
3. **Request custom plugin** for complex native features
4. **Consider if the feature is truly needed** (e.g., Web Workers aren't necessary)

Most web applications can be built with the supported APIs. For native features, WebF's plugin system provides a bridge between JavaScript and native capabilities.