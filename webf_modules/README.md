# WebF Modules

This directory contains WebF-specific Flutter packages that extend WebF functionality with additional modules.

## Available Modules

### 🔗 [webf_deeplink](./deeplink/)
**Deep link and URL scheme handling**
- Open deep links in external applications
- Handle fallback URLs when primary links fail
- Register deep link handlers for custom URL schemes
- Cross-platform support (iOS, Android, macOS)

```dart
WebF.defineModule((context) => DeepLinkModule(context));
```

### 📤 [webf_share](./share/)
**Content and image sharing functionality**
- Share images with text and subject
- Share text content and URLs
- Save screenshots to device storage
- Create preview images for display

```dart
WebF.defineModule((context) => ShareModule(context));
```

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  webf_deeplink: ^1.0.0
    hosted: https://dart.cloudsmith.io/openwebf/webf-enterprise/
  webf_share: ^1.0.0
    hosted: https://dart.cloudsmith.io/openwebf/webf-enterprise/
```

## Quick Start

```dart
import 'package:webf/webf.dart';
import 'package:webf_deeplink/webf_deeplink.dart';
import 'package:webf_share/webf_share.dart';

// Register modules globally (in main function)
WebF.defineModule((context) => DeepLinkModule(context));
WebF.defineModule((context) => ShareModule(context));
```

## JavaScript Usage

Install the npm packages for better TypeScript support:

```bash
npm install @openwebf/webf-deeplink @openwebf/webf-share
```

```javascript
// Deep link example
import { WebFDeepLink, DeepLinkHelpers } from '@openwebf/webf-deeplink';

// Simple deep link
const result = await WebFDeepLink.openDeepLink({
  url: 'whatsapp://send?text=Hello',
  fallbackUrl: 'https://wa.me/?text=Hello'
});

// Helper methods
await DeepLinkHelpers.openEmail({
  to: 'demo@example.com',
  subject: 'Hello from WebF',
  body: 'This is a test email'
});

// Share example
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

// Share text
const success = await WebFShare.shareText({
  title: 'My App',
  text: 'Check this out!',
  url: 'https://example.com'
});

// Share image from canvas
const canvas = document.querySelector('canvas');
const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);
await WebFShare.shareImage({
  imageData,
  text: 'Check out this amazing content!',
  subject: 'WebF Demo Screenshot'
});

// Save screenshot
const result = await WebFShare.saveScreenshot({
  imageData,
  filename: 'my_screenshot'
});
```

## Requirements

- **Flutter**: >=3.0.0
- **Dart SDK**: >=3.0.0 <4.0.0
- **WebF**: ^0.22.0 (from Cloudsmith)

## License

These packages are part of the WebF project. See the main WebF license for details.