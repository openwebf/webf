/// WebF Bluetooth module for Bluetooth Low Energy (BLE) operations
///
/// This module provides functionality to:
/// - Scan for BLE devices
/// - Connect and disconnect from devices
/// - Discover services and characteristics
/// - Read and write characteristic values
/// - Subscribe to characteristic notifications
///
/// Example usage:
/// ```dart
/// // Register module globally (in main function)
/// WebF.defineModule((context) => BluetoothModule(context));
/// ```
///
/// JavaScript usage with npm package (Recommended):
/// ```bash
/// npm install @openwebf/webf-bluetooth
/// ```
///
/// ```javascript
/// import { WebFBluetooth } from '@openwebf/webf-bluetooth';
///
/// // Listen for scan results
/// webf.on('Bluetooth:scanResult', (event) => {
///   const device = event.detail;
///   console.log('Found:', device.name, device.rssi);
/// });
///
/// // Start scanning
/// await WebFBluetooth.startScan({ timeout: 10000 });
///
/// // Connect to device
/// const result = await WebFBluetooth.connect({
///   deviceId: 'AA:BB:CC:DD:EE:FF'
/// });
///
/// // Discover services
/// const services = await WebFBluetooth.discoverServices('AA:BB:CC:DD:EE:FF');
///
/// // Subscribe to notifications
/// webf.on('Bluetooth:notification', (event) => {
///   console.log('Value:', event.detail.value);
/// });
/// await WebFBluetooth.subscribeToNotifications({
///   deviceId: 'AA:BB:CC:DD:EE:FF',
///   serviceUuid: '180D',
///   characteristicUuid: '2A37'
/// });
/// ```
///
/// Direct module invocation (Legacy):
/// ```javascript
/// await webf.invokeModuleAsync('Bluetooth', 'startScan', { timeout: 10000 });
/// ```
library webf_bluetooth;

export 'src/bluetooth_module.dart';
