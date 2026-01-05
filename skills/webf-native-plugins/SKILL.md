---
name: webf-native-plugins
description: Install WebF native plugins to access platform capabilities like sharing, payment, camera, geolocation, and more. Use when building features that require native device APIs beyond standard web APIs.
---

# WebF Native Plugins

When building WebF apps, you often need access to native platform capabilities like sharing content, accessing the camera, handling payments, or using geolocation. WebF provides **native plugins** that bridge JavaScript code with native platform APIs.

## What Are Native Plugins?

Native plugins are packages that:
- **Provide native platform capabilities** (share, camera, payments, sensors, etc.)
- **Work across iOS, Android, macOS, and other platforms**
- **Use JavaScript APIs** in your code
- **Require both Flutter and npm package installation**
- **Bridge to native platform APIs** through Flutter

## When to Use Native Plugins

Use native plugins when you need capabilities that aren't available in standard web APIs:

### Use Native Plugins For:
- Sharing content to other apps
- Accessing device camera or photo gallery
- Processing payments
- Getting geolocation with native accuracy
- Push notifications
- Biometric authentication (Face ID, fingerprint)
- Device sensors (accelerometer, gyroscope)
- File system access beyond web storage
- Native calendar/contacts integration

### Standard Web APIs Work Without Plugins:
- `fetch()` for HTTP requests
- `localStorage` for local storage
- Canvas 2D for graphics
- Geolocation API (basic)
- Media queries for responsive design

## Finding Available Plugins

Before implementing a feature, **always check** if a pre-built native plugin exists:

1. Visit the official plugin registry: **https://openwebf.com/en/native-plugins**
2. Browse available plugins by category
3. Check the plugin documentation for installation steps

## Installation Process

Every native plugin requires **TWO installations**:

1. **Flutter side** (in your Flutter host app)
2. **JavaScript side** (in your web project)

### Step 1: Check Plugin Availability

Visit https://openwebf.com/en/native-plugins and search for the capability you need:
- Click on the plugin to view details
- Note the Flutter package name (e.g., `webf_share`)
- Note the npm package name (e.g., `@openwebf/webf-share`)

### Step 2: Install Flutter Package

If you have access to the Flutter project hosting your WebF app:

1. Open the Flutter project's `pubspec.yaml`
2. Add the plugin dependency:
   ```yaml
   dependencies:
     webf_share: ^1.0.0  # Replace with actual plugin name
   ```
3. Run `flutter pub get`
4. Register the plugin in your main Dart file:
   ```dart
   import 'package:webf/webf.dart';
   import 'package:webf_share/webf_share.dart';  // Import the plugin

   void main() {
     // Initialize WebFControllerManager
     WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
       maxAliveInstances: 2,
       maxAttachedInstances: 1,
     ));

     // Register the native plugin module
     WebF.defineModule((context) => ShareModule(context));

     runApp(MyApp());
   }
   ```

### Step 3: Install npm Package

In your JavaScript/TypeScript project:

```bash
# For the Share plugin example
npm install @openwebf/webf-share

# Or with yarn
yarn add @openwebf/webf-share
```

### Step 4: Use in Your JavaScript Code

Import and use the plugin in your application:

```typescript
import { WebFShare } from '@openwebf/webf-share';

// Use the plugin API
const success = await WebFShare.shareText({
  title: 'My App',
  text: 'Check out this amazing content!',
  url: 'https://example.com'
});
```

## Available Plugins

### Share Plugin (webf_share)

**Description**: Share content, text, and images through native platform sharing

**Capabilities**:
- Share text, URLs, and titles to other apps
- Share images using native sharing mechanisms
- Save screenshots to device storage
- Create preview images for temporary display

**Flutter Package**: `webf_share: ^1.0.0`

**npm Package**: `@openwebf/webf-share`

**Example Usage**:
```typescript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

// Share text content
await WebFShare.shareText({
  title: 'Article Title',
  text: 'Check out this article!',
  url: 'https://example.com/article'
});

// Share an image from canvas
const canvas = document.getElementById('myCanvas');
const imageData = ShareHelpers.canvasToArrayBuffer(canvas);
await WebFShare.shareImage(imageData);

// Save screenshot
await WebFShare.saveScreenshot(imageData);
```

**Storage Locations**:
- Android: Downloads folder (`/storage/emulated/0/Download/`)
- iOS: App documents directory (accessible via Files app)
- macOS: Application documents directory (accessible via Finder)

See the [Native Plugins Reference](./reference.md) for more available plugins.

## Common Patterns

### 1. Feature Detection

Always check if a plugin is available before using it:

```typescript
// Check if plugin is loaded
if (typeof WebFShare !== 'undefined') {
  await WebFShare.shareText({ text: 'Hello' });
} else {
  // Fallback or show message
  console.log('Share plugin not available');
}
```

### 2. Error Handling

Wrap plugin calls in try-catch blocks:

```typescript
try {
  const success = await WebFShare.shareText({
    title: 'My App',
    text: 'Check this out!'
  });

  if (success) {
    console.log('Content shared successfully');
  }
} catch (error) {
  console.error('Failed to share:', error);
  // Show error message to user
}
```

### 3. TypeScript Type Safety

All plugins include TypeScript definitions:

```typescript
import type { ShareTextOptions } from '@openwebf/webf-share';

const shareOptions: ShareTextOptions = {
  title: 'Article',
  text: 'Read this article',
  url: 'https://example.com'
};

await WebFShare.shareText(shareOptions);
```

## Creating Custom Plugins

If you need capabilities not provided by existing plugins, you can create your own:

1. **Read the Plugin Development Guide**: https://openwebf.com/en/docs/developer-guide/native-plugins
2. **Study existing plugins**: https://github.com/openwebf/webf/tree/main/webf_modules
3. **Follow the plugin architecture**:
   - Create a Flutter package implementing the native functionality
   - Create an npm package exposing JavaScript APIs
   - Use WebF's module system to bridge between them

## Troubleshooting

### Issue: Plugin Not Found in JavaScript

**Cause**: Flutter package not installed or module not registered

**Solution**:
1. Check that the Flutter package is in `pubspec.yaml`
2. Verify the module is registered with `WebF.defineModule()` in main.dart
3. Run `flutter pub get`
4. Rebuild the Flutter app
5. Restart WebF Go or your app

### Issue: TypeScript Errors

**Cause**: npm package not installed correctly

**Solution**:
```bash
# Reinstall the package
npm install @openwebf/webf-share --save

# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Issue: Plugin Works on iOS but Not Android

**Cause**: Platform-specific permissions or configuration missing

**Solution**:
1. Check the plugin documentation for required permissions
2. Add necessary permissions to `AndroidManifest.xml` or `Info.plist`
3. Some plugins require additional native configuration

### Issue: "Module is not defined" Error

**Cause**: Plugin module not registered in Flutter

**Solution**:
Make sure you're calling `WebF.defineModule()` in your Flutter `main()` function before `runApp()`:

```dart
void main() {
  WebF.defineModule((context) => ShareModule(context));
  runApp(MyApp());
}
```

## Best Practices

### 1. Check Plugin Availability First

Before implementing a feature, visit https://openwebf.com/en/native-plugins to see if a plugin already exists. Don't reinvent the wheel.

### 2. Test on Multiple Platforms

Native plugins may behave differently on iOS vs Android vs macOS:
- Test on all target platforms
- Handle platform-specific behavior gracefully
- Read plugin docs for platform differences

### 3. Provide Fallbacks

Not all users may have the plugin installed (especially during development):

```typescript
if (typeof WebFShare !== 'undefined') {
  // Use native sharing
  await WebFShare.shareText({ text: 'Hello' });
} else {
  // Fallback: copy to clipboard or show a link
  navigator.clipboard.writeText('Hello');
}
```

### 4. Handle Permissions Properly

Some plugins require user permissions (camera, location, etc.):
- Request permissions at appropriate times
- Explain why you need the permission
- Handle permission denial gracefully
- Check plugin docs for permission requirements

### 5. Keep Plugins Updated

Native plugins are updated to support new platform features and fix bugs:
- Check for plugin updates regularly
- Read changelogs before updating
- Test thoroughly after updating

## Production Deployment

When deploying to production:

1. **Flutter App**: Make sure all required plugins are in `pubspec.yaml`
2. **npm Packages**: Include all plugin packages in `package.json`
3. **Permissions**: Configure all required permissions in app manifests
4. **Testing**: Test on real devices for all target platforms
5. **Documentation**: Document which plugins your app requires

## Resources

- **Plugin Registry**: https://openwebf.com/en/native-plugins
- **Plugin Development Guide**: https://openwebf.com/en/docs/developer-guide/native-plugins
- **Example Plugins**: https://github.com/openwebf/webf/tree/main/webf_modules
- **WebF Documentation**: https://openwebf.com/en/docs

## Next Steps

After installing native plugins:

1. **Read plugin documentation**: Each plugin has specific APIs and requirements
2. **Test on devices**: Native features work differently than web APIs
3. **Handle errors**: Native calls can fail due to permissions or platform limitations
4. **Consider alternatives**: Check `webf-api-compatibility` for web API alternatives

## Summary

- Native plugins provide access to platform capabilities beyond web APIs
- Check https://openwebf.com/en/native-plugins for available plugins
- Install BOTH Flutter package (pubspec.yaml) AND npm package
- Register plugins with `WebF.defineModule()` in main.dart
- Use feature detection and error handling in JavaScript
- Test on all target platforms
- Create custom plugins if needed using the Plugin Development Guide
