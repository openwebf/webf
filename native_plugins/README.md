# WebF Native Plugins

This directory contains WebF-specific Flutter packages that extend WebF functionality with additional modules.

## Available Modules

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
  webf_share: ^1.0.0  # Available on pub.dev
```

## Quick Start

```dart
import 'package:webf/webf.dart';
import 'package:webf_share/webf_share.dart';

// Register modules globally (in main function)
WebF.defineModule((context) => ShareModule(context));
```

## JavaScript Usage

Install the npm packages for better TypeScript support:

```bash
npm install @openwebf/webf-share
```

```javascript
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
- **WebF**: ^0.23.0 (available on pub.dev)

## License

These packages are part of the WebF project. See the main WebF license for details.