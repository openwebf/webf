# webf_bluetooth

WebF native plugin for Bluetooth Low Energy (BLE) operations. This plugin wraps the [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) Flutter package to provide BLE device scanning, connection management, service discovery, and GATT operations for WebF applications.

## Features

- Scan for nearby BLE devices with optional filters
- Connect and disconnect from BLE devices
- Discover services and characteristics
- Read and write characteristic values
- Subscribe to characteristic notifications
- Monitor connection state changes
- Request MTU size (Android)

## Installation

### Flutter Side

Add the dependency to your Flutter app's `pubspec.yaml`:

```yaml
dependencies:
  webf: ^0.24.0
  webf_bluetooth: ^1.0.0
```

Register the module in your `main.dart`:

```dart
import 'package:webf/webf.dart';
import 'package:webf_bluetooth/webf_bluetooth.dart';

void main() {
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
    maxAliveInstances: 2,
    maxAttachedInstances: 1,
  ));

  // Register Bluetooth module
  WebF.defineModule((context) => BluetoothModule(context));

  runApp(MyApp());
}
```

### JavaScript Side

Install the npm package:

```bash
npm install @openwebf/webf-bluetooth
```

## Usage

### Basic Scanning

```typescript
import { WebFBluetooth } from '@openwebf/webf-bluetooth';

// Listen for scan results (module events)
const unsubscribeScan = WebFBluetooth.addListener('scanResult', (_event, device) => {
  console.log(`Found: ${device.name || 'Unknown'} (${device.deviceId})`);
  console.log(`RSSI: ${device.rssi} dBm`);
});

// Start scanning
const result = await WebFBluetooth.startScan({
  timeout: 10000,  // 10 seconds
  serviceUuids: ['180D'],  // Filter by Heart Rate service
});

if (result.success === 'true') {
  console.log('Scanning started');
}

// Stop scanning when done
await WebFBluetooth.stopScan();

// Stop listening
unsubscribeScan();
```

### Connect to Device

```typescript
// Connect to a device
const connectResult = await WebFBluetooth.connect({
  deviceId: 'AA:BB:CC:DD:EE:FF',
  timeout: 15000,
  autoConnect: false,
});

if (connectResult.success === 'true') {
  console.log('Connected! MTU:', connectResult.mtu);
}

// Listen for connection state changes
WebFBluetooth.addListener('connectionState', (_event, detail) => {
  console.log(`Device ${detail.deviceId}: ${detail.state}`);
});
```

### Discover Services

```typescript
const servicesResult = await WebFBluetooth.discoverServices('AA:BB:CC:DD:EE:FF');

if (servicesResult.success === 'true') {
  const services = JSON.parse(servicesResult.services!);

  services.forEach(service => {
    console.log(`Service: ${service.uuid}`);
    service.characteristics.forEach(char => {
      console.log(`  Characteristic: ${char.uuid}`);
      console.log(`    Properties:`, char.properties);
    });
  });
}
```

### Read/Write Characteristics

```typescript
// Read a characteristic
const readResult = await WebFBluetooth.readCharacteristic({
  deviceId: 'AA:BB:CC:DD:EE:FF',
  serviceUuid: '180D',
  characteristicUuid: '2A37',
});

if (readResult.success === 'true') {
  console.log('Value (hex):', readResult.value);
  console.log('Value (base64):', readResult.valueBase64);
}

// Write to a characteristic
const writeResult = await WebFBluetooth.writeCharacteristic({
  deviceId: 'AA:BB:CC:DD:EE:FF',
  serviceUuid: 'custom-service-uuid',
  characteristicUuid: 'custom-char-uuid',
  value: '0102030405',  // hex string
  withoutResponse: false,
});
```

### Subscribe to Notifications

```typescript
// Listen for notifications
WebFBluetooth.addListener('notification', (_event, detail) => {
  const { characteristicUuid, value, valueBase64 } = detail;
  console.log(`Notification from ${characteristicUuid}: ${value}`);
});

// Subscribe to Heart Rate Measurement
const subResult = await WebFBluetooth.subscribeToNotifications({
  deviceId: 'AA:BB:CC:DD:EE:FF',
  serviceUuid: '180D',
  characteristicUuid: '2A37',
});

if (subResult.success === 'true') {
  console.log('Subscribed! ID:', subResult.subscriptionId);
}

// Unsubscribe when done
await WebFBluetooth.unsubscribeFromNotifications(subResult.subscriptionId);
```

### Check Adapter State

```typescript
// Check if Bluetooth is on
const stateResult = await WebFBluetooth.getAdapterState();
console.log('Adapter state:', stateResult.state);

// Check if scanning
const scanningResult = await WebFBluetooth.isScanning();
console.log('Is scanning:', scanningResult.isScanning);

// Get connected devices
const devicesResult = await WebFBluetooth.getConnectedDevices();
const devices = JSON.parse(devicesResult.devices!);
console.log('Connected devices:', devices);
```

### Low-level Event Listener (without the wrapper)

If you don't want to use `WebFBluetooth.addListener(...)`, you can listen to module events directly:

```ts
webf.addWebfModuleListener('Bluetooth', (event, extra) => {
  if (event.type === 'scanResult') {
    console.log('scanResult', extra);
  }
});
```

## API Reference

### Adapter Management

| Method | Description |
|--------|-------------|
| `getAdapterState()` | Get current Bluetooth adapter state |
| `isBluetoothOn()` | Check if Bluetooth is enabled |
| `turnOn()` | Turn on Bluetooth (Android only) |

### Scanning

| Method | Description |
|--------|-------------|
| `startScan(options?)` | Start scanning for BLE devices |
| `stopScan()` | Stop active scan |
| `isScanning()` | Check if currently scanning |

### Connection Management

| Method | Description |
|--------|-------------|
| `connect(options)` | Connect to a BLE device |
| `disconnect(deviceId)` | Disconnect from a device |
| `getConnectionState(deviceId)` | Get connection state |
| `getConnectedDevices()` | List connected devices |
| `requestMtu(deviceId, mtu)` | Request MTU size (Android) |

### Service Discovery

| Method | Description |
|--------|-------------|
| `discoverServices(deviceId)` | Discover services and characteristics |

### Data Transfer

| Method | Description |
|--------|-------------|
| `readCharacteristic(options)` | Read characteristic value |
| `writeCharacteristic(options)` | Write to characteristic |
| `readDescriptor(options)` | Read descriptor value |
| `writeDescriptor(options)` | Write to descriptor |

### Notifications

| Method | Description |
|--------|-------------|
| `subscribeToNotifications(options)` | Subscribe to characteristic notifications |
| `unsubscribeFromNotifications(subscriptionId)` | Unsubscribe from notifications |

## Events

| Event | Description |
|-------|-------------|
| `scanResult` | Emitted for each device found during scanning |
| `connectionState` | Emitted when connection state changes |
| `notification` | Emitted when a subscribed characteristic value changes |

## Platform Support

| Platform | Support |
|----------|---------|
| Android | Yes |
| iOS | Yes |
| macOS | Yes |
| Linux | Yes (via BlueZ) |

## Platform Permissions

### Android

Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS

Add to `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to BLE devices.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to connect to BLE devices.</string>
```

## Limitations

- **BLE Central Role only**: This plugin supports scanning and connecting to peripherals. It does not support acting as a BLE peripheral.
- **No Bluetooth Classic**: Devices using Bluetooth Classic (HC-05, speakers, headphones, mice, keyboards) are not supported.
- **No iBeacon on iOS**: iBeacons require CoreLocation on iOS.

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Related

- [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) - The underlying BLE plugin
- [WebF Documentation](https://openwebf.com/en/docs)
- [WebF Native Plugins](https://openwebf.com/en/native-plugins)
