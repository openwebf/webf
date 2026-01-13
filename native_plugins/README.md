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

### 🔵 [webf_bluetooth](./bluetooth/)
**Bluetooth Low Energy (BLE) operations**
- Scan for nearby BLE devices
- Connect and disconnect from devices
- Discover services and characteristics
- Read and write characteristic values
- Subscribe to characteristic notifications

```dart
WebF.defineModule((context) => BluetoothModule(context));
```

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  webf_share: ^1.0.0      # Share content
  webf_bluetooth: ^1.0.0  # Bluetooth BLE
```

## Quick Start

```dart
import 'package:webf/webf.dart';
import 'package:webf_share/webf_share.dart';
import 'package:webf_bluetooth/webf_bluetooth.dart';

// Register modules globally (in main function)
WebF.defineModule((context) => ShareModule(context));
WebF.defineModule((context) => BluetoothModule(context));
```

## JavaScript Usage

Install the npm packages for better TypeScript support:

```bash
npm install @openwebf/webf-share @openwebf/webf-bluetooth
```

### Share Example

```javascript
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
```

### Bluetooth Example

```javascript
import { WebFBluetooth } from '@openwebf/webf-bluetooth';

// Listen for scan results
webf.on('Bluetooth:scanResult', (event) => {
  const device = event.detail;
  console.log(`Found: ${device.name} (${device.rssi} dBm)`);
});

// Start scanning
await WebFBluetooth.startScan({ timeout: 10000 });

// Connect to device
const result = await WebFBluetooth.connect({
  deviceId: 'AA:BB:CC:DD:EE:FF'
});

// Discover services
const services = await WebFBluetooth.discoverServices('AA:BB:CC:DD:EE:FF');
```

## Requirements

- **Flutter**: >=3.0.0
- **Dart SDK**: >=3.0.0 <4.0.0
- **WebF**: ^0.23.0 (available on pub.dev)

## License

These packages are part of the WebF project. See the main WebF license for details.