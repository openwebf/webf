# WebF Deep Link Module

A WebF module for handling deep links and URL scheme navigation in Flutter applications.

## Features

- ✅ Open deep links in external applications
- ✅ Handle fallback URLs when primary links fail
- ✅ Register deep link handlers for custom URL schemes
- ✅ Cross-platform support (iOS, Android, macOS)
- ✅ Platform-specific scheme validation

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  webf_deeplink: ^0.1.0  # Available on pub.dev
```

## Usage

### 1. Register the Module

```dart
import 'package:webf/webf.dart';
import 'package:webf_deeplink/webf_deeplink.dart';

// Register module globally (in main function)
WebF.defineModule((context) => DeepLinkModule(context));
```

### 2. JavaScript API

#### Using the npm package (Recommended)

```bash
npm install @openwebf/webf-deeplink
```

```javascript
import { WebFDeepLink, DeepLinkHelpers } from '@openwebf/webf-deeplink';

// Open email
await DeepLinkHelpers.openEmail({
  to: 'demo@example.com',
  subject: 'Hello from WebF',
  body: 'This is a test email'
});

// Open phone dialer
await DeepLinkHelpers.openPhone('+1234567890');

// Open maps with location
await DeepLinkHelpers.openMaps({
  latitude: 37.7749,
  longitude: -122.4194,
  query: 'San Francisco'
});

// Custom deep link with fallback
const result = await WebFDeepLink.openDeepLink({
  url: 'whatsapp://send?text=Hello%20World',
  fallbackUrl: 'https://wa.me/?text=Hello%20World'
});

if (result.success) {
  console.log('Deep link opened successfully');
} else {
  console.error('Failed:', result.error);
}
```

#### Direct module invocation (Legacy)

```javascript
// Basic deep link
const result = await webf.invokeModuleAsync('DeepLink', 'openDeepLink', {
  url: 'whatsapp://send?text=Hello%20World'
});

// With fallback URL
const result = await webf.invokeModuleAsync('DeepLink', 'openDeepLink', {
  url: 'spotify://track/4iV5W9uYEdYUVa79Axb7Rh',
  fallbackUrl: 'https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh'
});

// Register a custom URL scheme handler
const result = await webf.invokeModuleAsync('DeepLink', 'registerDeepLinkHandler', {
  scheme: 'myapp',
  host: 'action'
});
```

## Platform Configuration

### iOS/macOS

Add URL schemes to your `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.example.myapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

### Android

Add intent filters to your `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    
    <!-- Regular launch intent -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Deep link intent -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myapp" />
    </intent-filter>
</activity>
```

## Supported URL Schemes

### Common App Schemes
- `whatsapp://` - WhatsApp
- `spotify://` - Spotify
- `instagram://` - Instagram
- `twitter://` - Twitter
- `mailto:` - Email
- `tel:` - Phone calls
- `sms:` - SMS messages
- `maps://` - Maps application
- `geo:` - Geographic coordinates

### Web Fallbacks
When app-specific schemes aren't available, the module will attempt to use fallback URLs:
- WhatsApp: `https://wa.me/`
- Spotify: `https://open.spotify.com/`
- Instagram: `https://instagram.com/`
- App Store (iOS): `https://apps.apple.com/app/id{appId}`
- Play Store (Android): `https://play.google.com/store/apps/details?id={appId}`

## API Reference

### `openDeepLink(params)`

Opens a deep link URL in an external application.

**Parameters:**
- `url` (string): The deep link URL to open
- `fallbackUrl` (string, optional): Fallback URL if the primary URL fails

**Returns:** `Promise<Object>` with success status and details

### `registerDeepLinkHandler(params)`

Registers a deep link handler configuration.

**Parameters:**
- `scheme` (string): The URL scheme to register
- `host` (string, optional): The host part of the URL

**Returns:** `Promise<Object>` with registration status and platform notes

## License

This package is part of the WebF project. See the main WebF license for details.