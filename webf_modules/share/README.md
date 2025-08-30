# WebF Share Module

A WebF module for sharing content, text, and images in Flutter applications.

## Features

- ✅ Share images with text and subject
- ✅ Share text content and URLs
- ✅ Save screenshots to device storage
- ✅ Create preview images for display
- ✅ Cross-platform support (iOS, Android, macOS)
- ✅ Platform-specific storage handling

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  webf_share: ^1.0.0
    hosted: https://dart.cloudsmith.io/openwebf/webf-enterprise/
```

## Usage

### 1. Register the Module

```dart
import 'package:webf/webf.dart';
import 'package:webf_share/webf_share.dart';

// Register module globally (in main function)
WebF.defineModule((context) => ShareModule(context));
```

### 2. JavaScript API

#### Using the npm package (Recommended)

```bash
npm install @openwebf/webf-share
```

```javascript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

// Share text
const success = await WebFShare.shareText({
  title: 'My App',
  text: 'Check out this amazing content!',
  url: 'https://example.com'
});

// Share image
const canvas = document.querySelector('canvas');
const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);

await WebFShare.shareImage({
  imageData,
  text: 'Check out this amazing content!',
  subject: 'My App - Amazing Content'
});

// Save screenshot
const result = await WebFShare.saveScreenshot({
  imageData,
  filename: 'my_screenshot'
});

if (result.success) {
  console.log('Saved to:', result.filePath);
}

// Save for preview
const previewResult = await WebFShare.saveForPreview({
  imageData,
  filename: 'preview_image'
});

// Display the preview
const img = document.createElement('img');
img.src = previewResult.filePath;
document.body.appendChild(img);
```

#### Direct module invocation (Legacy)

```javascript
// Share image
const success = await webf.invokeModuleAsync('Share', 'share',
  imageData,
  'Check out this amazing content!',
  'My App - Amazing Content'
);

// Share text
const success = await webf.invokeModuleAsync('Share', 'shareText', {
  title: 'My App',
  text: 'Check out this amazing content!',
  url: 'https://example.com'
});

// Save screenshot
const result = await webf.invokeModuleAsync('Share', 'save',
  imageData,
  'my_screenshot'
);

// Save for preview
const result = await webf.invokeModuleAsync('Share', 'saveForPreview',
  imageData,
  'preview_image'
);
```

## Platform-Specific Behavior

### File Storage Locations

#### Android
- **Downloads**: `/storage/emulated/0/Download/` (when accessible)
- **External Storage**: App-specific external storage directory
- **Access**: Files saved to Downloads are accessible system-wide

#### iOS
- **App Documents**: App's documents directory
- **Access**: Files are accessible through the Files app

#### macOS
- **Application Documents**: App's documents directory
- **Access**: Files are accessible through Finder

### Share Targets

The module uses the platform's native sharing mechanism:
- **iOS**: UIActivityViewController
- **Android**: Android Share Intent
- **macOS**: NSSharingService

## API Reference

### `share(imageData, text, subject)`

Shares an image with optional text and subject.

**Parameters:**
- `imageData` (ArrayBuffer): Binary image data
- `text` (string): Text to include with the share
- `subject` (string): Subject line for the share

**Returns:** `Promise<boolean>` - true if successful

### `shareText(params)`

Shares text content with optional URL.

**Parameters:**
- Format 1: `[title, text]` (legacy)
- Format 2: `[{title, text, url}]` (recommended)

**Returns:** `Promise<boolean>` - true if successful

### `save(imageData, filename?)`

Saves image to device storage.

**Parameters:**
- `imageData` (ArrayBuffer): Binary image data
- `filename` (string, optional): Custom filename without extension

**Returns:** `Promise<Object>` with save details

### `saveForPreview(imageData, filename?)`

Saves image for temporary preview display.

**Parameters:**
- `imageData` (ArrayBuffer): Binary image data  
- `filename` (string, optional): Custom filename for preview

**Returns:** `Promise<Object>` with file path for display

## License

This package is part of the WebF project. See the main WebF license for details.