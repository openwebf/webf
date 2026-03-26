# WebF Native Plugins Reference

This document provides detailed information about all available WebF native plugins.

## How to Use This Reference

For each plugin, you'll find:
- **Description**: What the plugin does
- **Flutter Package**: Package name to add to `pubspec.yaml`
- **npm Package**: Package name to install with npm
- **Platforms**: Supported platforms (iOS, Android, macOS, Windows, Linux)
- **API Reference**: Methods and types available
- **Example Usage**: Code examples
- **Installation Steps**: Complete setup instructions

## Quick Installation Template

For any plugin, follow this pattern:

**Flutter side (pubspec.yaml)**:
```yaml
dependencies:
  PLUGIN_NAME: ^VERSION
```

**Flutter side (main.dart)**:
```dart
import 'package:PLUGIN_NAME/PLUGIN_NAME.dart';

void main() {
  WebF.defineModule((context) => PluginModule(context));
  runApp(MyApp());
}
```

**JavaScript side**:
```bash
npm install @openwebf/PLUGIN_NAME
```

---

## Available Plugins

### 1. Share Plugin

**Description**: Share content, text, and images through native platform sharing mechanisms. Save screenshots to device storage and create preview images.

**Flutter Package**: `webf_share`

**npm Package**: `@openwebf/webf-share`

**Latest Version**: 1.0.0

**Platforms**:
- iOS
- Android
- macOS

**Installation**:

1. Add to Flutter `pubspec.yaml`:
   ```yaml
   dependencies:
     webf_share: ^1.0.0
   ```

2. Register in Flutter `main.dart`:
   ```dart
   import 'package:webf/webf.dart';
   import 'package:webf_share/webf_share.dart';

   void main() {
     WebF.defineModule((context) => ShareModule(context));
     runApp(MyApp());
   }
   ```

3. Install npm package:
   ```bash
   npm install @openwebf/webf-share
   ```

**API Reference**:

```typescript
interface ShareTextOptions {
  title?: string;
  text: string;
  url?: string;
}

class WebFShare {
  // Share text content with optional title and URL
  static shareText(options: ShareTextOptions): Promise<boolean>;

  // Share an image using platform native sharing
  static shareImage(imageData: ArrayBuffer): Promise<boolean>;

  // Save screenshot to device storage
  static saveScreenshot(imageData: ArrayBuffer): Promise<boolean>;
}

class ShareHelpers {
  // Convert canvas element to ArrayBuffer for sharing
  static canvasToArrayBuffer(canvas: HTMLCanvasElement): ArrayBuffer;
}
```

**Example Usage**:

```typescript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

// Example 1: Share text with URL
async function shareArticle() {
  try {
    const success = await WebFShare.shareText({
      title: 'Amazing Article',
      text: 'Check out this amazing article about WebF!',
      url: 'https://openwebf.com/articles/amazing'
    });

    if (success) {
      console.log('Shared successfully!');
    }
  } catch (error) {
    console.error('Share failed:', error);
  }
}

// Example 2: Share a canvas as image
async function shareCanvas() {
  const canvas = document.getElementById('myCanvas') as HTMLCanvasElement;
  const imageData = ShareHelpers.canvasToArrayBuffer(canvas);

  try {
    await WebFShare.shareImage(imageData);
  } catch (error) {
    console.error('Failed to share image:', error);
  }
}

// Example 3: Save screenshot
async function saveScreenshot() {
  const canvas = document.getElementById('screenshot') as HTMLCanvasElement;
  const imageData = ShareHelpers.canvasToArrayBuffer(canvas);

  try {
    const saved = await WebFShare.saveScreenshot(imageData);
    if (saved) {
      alert('Screenshot saved to device!');
    }
  } catch (error) {
    console.error('Failed to save screenshot:', error);
  }
}

// Example 4: Feature detection
function setupShareButton() {
  const shareBtn = document.getElementById('shareBtn');

  if (typeof WebFShare !== 'undefined') {
    shareBtn.onclick = () => shareArticle();
  } else {
    // Fallback for environments without the plugin
    shareBtn.onclick = () => {
      navigator.clipboard.writeText('https://example.com');
      alert('Link copied to clipboard!');
    };
  }
}
```

**Platform-Specific Behavior**:

| Platform | Share Behavior | Screenshot Save Location |
|----------|----------------|-------------------------|
| **Android** | Opens system share sheet | `/storage/emulated/0/Download/` |
| **iOS** | Opens system share sheet | App documents directory (accessible via Files app) |
| **macOS** | Opens system share dialog | Application documents directory |

**Common Use Cases**:
- Share blog posts or articles to social media
- Share app content with friends
- Save generated images or charts
- Export user-created content
- Share deep links to specific app content

---

## Coming Soon

The following plugins are under development or planned:

### Camera & Photos Plugin
Access device camera and photo library for capturing and selecting images.

### Payment Plugin
Process payments using platform-native payment systems (Apple Pay, Google Pay).

### Geolocation Plugin
Enhanced geolocation with background tracking and geofencing.

### Push Notifications Plugin
Send and receive push notifications with rich media support.

### Biometric Authentication Plugin
Use Face ID, Touch ID, or fingerprint authentication.

### File Picker Plugin
Select files from device storage with platform-native file pickers.

### Deep Link Plugin
Handle deep links and universal links for app navigation.

---

## Plugin Development

Want to create your own plugin? Follow these resources:

1. **Plugin Development Guide**: https://openwebf.com/en/docs/developer-guide/native-plugins
2. **Example Plugins**: https://github.com/openwebf/webf/tree/main/webf_modules
3. **WebF Module API**: Study existing plugins to understand the module system

### Plugin Architecture

A WebF native plugin consists of:

1. **Flutter Package** (native side):
   - Implements native platform functionality
   - Extends WebF's module system
   - Handles platform-specific code

2. **npm Package** (JavaScript side):
   - Exposes JavaScript/TypeScript APIs
   - Provides type definitions
   - Documents usage

3. **Bridge Layer**:
   - WebF's module system connects Flutter and JavaScript
   - Handles data serialization between platforms
   - Manages async communication

### Best Practices for Plugin Development

- Follow WebF module conventions
- Provide TypeScript definitions
- Support multiple platforms when possible
- Handle errors gracefully
- Document all APIs clearly
- Include usage examples
- Test on real devices
- Keep APIs simple and consistent

---

## Plugin Compatibility Matrix

| Plugin | iOS | Android | macOS | Windows | Linux | Web |
|--------|-----|---------|-------|---------|-------|-----|
| Share | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ |

Legend:
- ✅ Fully supported
- ⏳ Coming soon
- ❌ Not applicable

---

## Getting Help

- **Plugin Issues**: Report on GitHub at https://github.com/openwebf/webf/issues
- **Plugin Requests**: Open a feature request on GitHub
- **Documentation**: Visit https://openwebf.com/en/docs
- **Community**: Join discussions on GitHub Discussions

---

## Contributing Plugins

Want to contribute a plugin to the WebF ecosystem?

1. Review the Plugin Development Guide
2. Follow WebF coding standards
3. Include comprehensive tests
4. Document all APIs
5. Submit a pull request to the WebF repository

We welcome community contributions!

---

**Last Updated**: 2026-01-04

**Plugin Registry**: https://openwebf.com/en/native-plugins
