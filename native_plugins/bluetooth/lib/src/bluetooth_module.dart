import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:webf/dom.dart';
import 'bluetooth_module_bindings_generated.dart';

/// WebF module for Bluetooth Low Energy (BLE) operations.
///
/// This module provides functionality to:
/// - Scan for BLE devices
/// - Connect/disconnect to devices
/// - Discover services and characteristics
/// - Read/write characteristic values
/// - Subscribe to characteristic notifications
///
/// Events emitted by this module:
/// - 'scanResult' - Emitted for each device found during scanning
/// - 'connectionState' - Emitted when connection state changes
/// - 'notification' - Emitted when a subscribed characteristic value changes
/// - 'adapterState' - Emitted when Bluetooth adapter state changes
class BluetoothModule extends BluetoothModuleBindings {
  BluetoothModule(super.moduleManager);

  // ============================================================================
  // State Management
  // ============================================================================

  /// Active scan session subscription
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  /// Scan session dedupe state to avoid re-emitting the same results repeatedly.
  final Set<String> _scanDiscoveredDeviceIds = <String>{};
  final Map<String, int> _scanLastEmittedAtMs = <String, int>{};
  final Map<String, int> _scanLastRssi = <String, int>{};

  /// Adapter state subscription
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  /// Map of deviceId -> BluetoothDevice for connected devices
  final Map<String, BluetoothDevice> _connectedDevices = {};

  /// Map of deviceId -> discovered services
  final Map<String, List<BluetoothService>> _discoveredServices = {};

  /// Map of subscriptionId -> StreamSubscription for notifications
  final Map<String, StreamSubscription<List<int>>> _notificationSubscriptions =
      {};

  /// Map of subscriptionId -> characteristic info for cleanup
  final Map<String, BluetoothCharacteristic> _notificationCharacteristics = {};

  /// Map of deviceId -> connection state subscription
  final Map<String, StreamSubscription<BluetoothConnectionState>>
      _connectionStateSubscriptions = {};

  /// Counter for generating unique subscription IDs
  int _subscriptionCounter = 0;

  // ============================================================================
  // Lifecycle
  // ============================================================================

  @override
  void dispose() {
    // Cancel scan subscription
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _scanDiscoveredDeviceIds.clear();
    _scanLastEmittedAtMs.clear();
    _scanLastRssi.clear();

    // Cancel adapter state subscription
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;

    // Cancel all notification subscriptions
    for (final sub in _notificationSubscriptions.values) {
      sub.cancel();
    }
    _notificationSubscriptions.clear();
    _notificationCharacteristics.clear();

    // Cancel all connection state subscriptions
    for (final sub in _connectionStateSubscriptions.values) {
      sub.cancel();
    }
    _connectionStateSubscriptions.clear();

    // Disconnect all devices
    for (final device in _connectedDevices.values) {
      try {
        device.disconnect();
      } catch (_) {
        // Ignore errors during cleanup
      }
    }
    _connectedDevices.clear();
    _discoveredServices.clear();
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  String _generateSubscriptionId() {
    return 'sub_${DateTime.now().millisecondsSinceEpoch}_${_subscriptionCounter++}';
  }

  BluetoothDevice? _getConnectedDevice(String deviceId) {
    return _connectedDevices[deviceId];
  }

  BluetoothCharacteristic? _findCharacteristic(
    String deviceId,
    String serviceUuid,
    String characteristicUuid,
  ) {
    final services = _discoveredServices[deviceId];
    if (services == null) return null;

    final normalizedServiceUuid = serviceUuid.toLowerCase();
    final normalizedCharUuid = characteristicUuid.toLowerCase();

    for (final service in services) {
      if (service.uuid.toString().toLowerCase() == normalizedServiceUuid ||
          service.uuid.toString().toLowerCase().contains(normalizedServiceUuid)) {
        for (final char in service.characteristics) {
          if (char.uuid.toString().toLowerCase() == normalizedCharUuid ||
              char.uuid.toString().toLowerCase().contains(normalizedCharUuid)) {
            return char;
          }
        }
      }
    }
    return null;
  }

  BluetoothDescriptor? _findDescriptor(
    String deviceId,
    String serviceUuid,
    String characteristicUuid,
    String descriptorUuid,
  ) {
    final char = _findCharacteristic(deviceId, serviceUuid, characteristicUuid);
    if (char == null) return null;

    final normalizedDescUuid = descriptorUuid.toLowerCase();

    for (final desc in char.descriptors) {
      if (desc.uuid.toString().toLowerCase() == normalizedDescUuid ||
          desc.uuid.toString().toLowerCase().contains(normalizedDescUuid)) {
        return desc;
      }
    }
    return null;
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      if (i + 2 <= hex.length) {
        result.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
    }
    return result;
  }

  String _mapAdapterState(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.on:
        return 'on';
      case BluetoothAdapterState.off:
        return 'off';
      case BluetoothAdapterState.turningOn:
        return 'turningOn';
      case BluetoothAdapterState.turningOff:
        return 'turningOff';
      case BluetoothAdapterState.unavailable:
        return 'unavailable';
      default:
        return 'unknown';
    }
  }

  String _mapConnectionState(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.disconnected:
        return 'disconnected';
      case BluetoothConnectionState.connecting:
        return 'connecting';
      case BluetoothConnectionState.connected:
        return 'connected';
      case BluetoothConnectionState.disconnecting:
        return 'disconnecting';
    }
  }

  // ============================================================================
  // Adapter Management Implementation
  // ============================================================================

  @override
  Future<AdapterStateResult> getAdapterState() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return AdapterStateResult(
        success: 'true',
        state: _mapAdapterState(state),
      );
    } catch (e) {
      return AdapterStateResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<IsBluetoothOnResult> isBluetoothOn() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return IsBluetoothOnResult(
        success: 'true',
        isOn: (state == BluetoothAdapterState.on).toString(),
      );
    } catch (e) {
      return IsBluetoothOnResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<TurnOnResult> turnOn() async {
    try {
      await FlutterBluePlus.turnOn();
      return const TurnOnResult(success: 'true');
    } catch (e) {
      return TurnOnResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  // ============================================================================
  // Scanning Implementation
  // ============================================================================

  @override
  Future<ScanStartResult> startScan(ScanOptions? options) async {
    try {
      // Stop any existing scan
      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      _scanDiscoveredDeviceIds.clear();
      _scanLastEmittedAtMs.clear();
      _scanLastRssi.clear();

      // Parse options
      final timeout = options?.timeout != null
          ? Duration(milliseconds: options!.timeout!.toInt())
          : Duration.zero;
      final List<Guid> serviceUuids = () {
        final raw = options?.serviceUuids;
        if (raw == null) return <Guid>[];
        if (raw is List<Guid>) return raw;
        if (raw is List) {
          return raw.map((uuid) => Guid(uuid.toString())).toList(growable: false);
        }
        return <Guid>[];
      }();
      final allowDuplicates = options?.allowDuplicates ?? false;

      // Start scan
      await FlutterBluePlus.startScan(
        withServices: serviceUuids,
        timeout: timeout == Duration.zero ? null : timeout,
        continuousUpdates: allowDuplicates,
      );

      // Listen for scan results and emit events
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final seenInBatch = <String>{};
        for (final result in results) {
          final deviceId = result.device.remoteId.toString();
          if (!seenInBatch.add(deviceId)) continue;

          if (!allowDuplicates) {
            if (_scanDiscoveredDeviceIds.contains(deviceId)) continue;
            _scanDiscoveredDeviceIds.add(deviceId);
          } else {
            final lastAt = _scanLastEmittedAtMs[deviceId];
            final lastRssi = _scanLastRssi[deviceId];

            // When duplicates are allowed, avoid spamming identical updates:
            // - always emit first time
            // - otherwise emit if RSSI changed OR enough time passed
            const minIntervalMs = 500;
            final shouldEmit = lastAt == null ||
                lastRssi == null ||
                lastRssi != result.rssi ||
                nowMs - lastAt >= minIntervalMs;
            if (!shouldEmit) continue;

            _scanLastEmittedAtMs[deviceId] = nowMs;
            _scanLastRssi[deviceId] = result.rssi;
          }

          final deviceInfo = _mapScanResult(result);
          // Emit event to JavaScript
          moduleManager!.emitModuleEvent(
            name,
            event: Event('scanResult'),
            data: deviceInfo,
          );
        }
      });

      final scanId = _generateSubscriptionId();

      return ScanStartResult(
        success: 'true',
        scanId: scanId,
      );
    } catch (e) {
      return ScanStartResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  Map<String, dynamic> _mapScanResult(ScanResult result) {
    return {
      'deviceId': result.device.remoteId.toString(),
      'remoteId': result.device.remoteId.toString(),
      'name': result.device.platformName.isNotEmpty
          ? result.device.platformName
          : null,
      'localName': result.advertisementData.advName.isNotEmpty
          ? result.advertisementData.advName
          : null,
      'rssi': result.rssi,
      'serviceUuids':
          result.advertisementData.serviceUuids.map((g) => g.toString()).toList(),
      'manufacturerData': result.advertisementData.manufacturerData.isNotEmpty
          ? jsonEncode(result.advertisementData.manufacturerData.map(
              (key, value) => MapEntry(key.toString(), _bytesToHex(value)),
            ))
          : null,
      'connectable': result.advertisementData.connectable,
      'txPowerLevel': result.advertisementData.txPowerLevel,
    };
  }

  @override
  Future<ScanStopResult> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      _scanSubscription = null;
      _scanDiscoveredDeviceIds.clear();
      _scanLastEmittedAtMs.clear();
      _scanLastRssi.clear();

      return const ScanStopResult(success: 'true');
    } catch (e) {
      return ScanStopResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<IsScanningResult> isScanning() async {
    try {
      final scanning = FlutterBluePlus.isScanningNow;
      return IsScanningResult(
        success: 'true',
        isScanning: scanning.toString(),
      );
    } catch (e) {
      return IsScanningResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  // ============================================================================
  // Connection Management Implementation
  // ============================================================================

  @override
  Future<ConnectResult> connect(ConnectOptions? options) async {
    try {
      if (options?.deviceId == null) {
        return const ConnectResult(
          success: 'false',
          error: 'deviceId is required',
        );
      }

      final deviceId = options!.deviceId!;
      final device = BluetoothDevice.fromId(deviceId);
      final timeout = options.timeout != null
          ? Duration(milliseconds: options.timeout!.toInt())
          : const Duration(seconds: 15);
      final autoConnect = options.autoConnect ?? false;

      await device.connect(
        timeout: timeout,
        autoConnect: autoConnect,
      );

      // Store connected device
      _connectedDevices[deviceId] = device;

      // Request MTU if specified (Android)
      int? mtu;
      if (options.mtu != null) {
        mtu = await device.requestMtu(options.mtu!.toInt());
      }

      // Subscribe to connection state changes
      final connectionId = _generateSubscriptionId();
      final subscription = device.connectionState.listen((state) {
        moduleManager!.emitModuleEvent(
          name,
          event: Event('connectionState'),
          data: {
            'deviceId': deviceId,
            'state': _mapConnectionState(state),
          },
        );

        // Clean up if disconnected
        if (state == BluetoothConnectionState.disconnected) {
          _connectedDevices.remove(deviceId);
          _discoveredServices.remove(deviceId);
          _connectionStateSubscriptions.remove(deviceId)?.cancel();
        }
      });
      _connectionStateSubscriptions[deviceId] = subscription;

      return ConnectResult(
        success: 'true',
        connectionId: connectionId,
        mtu: mtu,
      );
    } catch (e) {
      return ConnectResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<DisconnectResult> disconnect(dynamic deviceId) async {
    try {
      final id = deviceId.toString();
      final device = _getConnectedDevice(id);
      if (device == null) {
        return DisconnectResult(
          success: 'false',
          error: 'Device not connected: $id',
        );
      }

      await device.disconnect();
      _connectedDevices.remove(id);
      _discoveredServices.remove(id);
      _connectionStateSubscriptions.remove(id)?.cancel();

      return const DisconnectResult(success: 'true');
    } catch (e) {
      return DisconnectResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<ConnectionStateResult> getConnectionState(dynamic deviceId) async {
    try {
      final id = deviceId.toString();
      final device = _getConnectedDevice(id);
      if (device == null) {
        return const ConnectionStateResult(
          success: 'true',
          state: 'disconnected',
        );
      }

      final state = await device.connectionState.first;
      return ConnectionStateResult(
        success: 'true',
        state: _mapConnectionState(state),
      );
    } catch (e) {
      return ConnectionStateResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<ConnectedDevicesResult> getConnectedDevices() async {
    try {
      final devices = _connectedDevices.entries.map((entry) {
        return {
          'deviceId': entry.key,
          'name': entry.value.platformName,
        };
      }).toList();

      return ConnectedDevicesResult(
        success: 'true',
        devices: jsonEncode(devices),
      );
    } catch (e) {
      return ConnectedDevicesResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<RequestMtuResult> requestMtu(dynamic deviceId, dynamic mtu) async {
    try {
      final id = deviceId.toString();
      final device = _getConnectedDevice(id);
      if (device == null) {
        return RequestMtuResult(
          success: 'false',
          error: 'Device not connected: $id',
        );
      }

      final mtuValue = mtu is num ? mtu.toInt() : int.parse(mtu.toString());
      final negotiatedMtu = await device.requestMtu(mtuValue);

      return RequestMtuResult(
        success: 'true',
        mtu: negotiatedMtu,
      );
    } catch (e) {
      return RequestMtuResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  // ============================================================================
  // Service Discovery Implementation
  // ============================================================================

  @override
  Future<DiscoverServicesResult> discoverServices(dynamic deviceId) async {
    try {
      final id = deviceId.toString();
      final device = _getConnectedDevice(id);
      if (device == null) {
        return DiscoverServicesResult(
          success: 'false',
          error: 'Device not connected: $id',
        );
      }

      final services = await device.discoverServices();
      _discoveredServices[id] = services;

      final servicesJson = services.map((service) {
        return {
          'uuid': service.uuid.toString(),
          'isPrimary': service.isPrimary,
          'characteristics': service.characteristics.map((char) {
            return {
              'uuid': char.uuid.toString(),
              'serviceUuid': service.uuid.toString(),
              'deviceId': id,
              'properties': {
                'broadcast': char.properties.broadcast,
                'read': char.properties.read,
                'writeWithoutResponse': char.properties.writeWithoutResponse,
                'write': char.properties.write,
                'notify': char.properties.notify,
                'indicate': char.properties.indicate,
                'authenticatedSignedWrites':
                    char.properties.authenticatedSignedWrites,
                'extendedProperties': char.properties.extendedProperties,
              },
              'descriptors': char.descriptors.map((desc) {
                return {
                  'uuid': desc.uuid.toString(),
                  'characteristicUuid': char.uuid.toString(),
                  'serviceUuid': service.uuid.toString(),
                  'deviceId': id,
                };
              }).toList(),
            };
          }).toList(),
        };
      }).toList();

      return DiscoverServicesResult(
        success: 'true',
        services: jsonEncode(servicesJson),
      );
    } catch (e) {
      return DiscoverServicesResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  // ============================================================================
  // Data Transfer Implementation
  // ============================================================================

  @override
  Future<ReadCharacteristicResult> readCharacteristic(
    ReadCharacteristicOptions? options,
  ) async {
    try {
      if (options == null ||
          options.deviceId == null ||
          options.serviceUuid == null ||
          options.characteristicUuid == null) {
        return const ReadCharacteristicResult(
          success: 'false',
          error: 'deviceId, serviceUuid, and characteristicUuid are required',
        );
      }

      final char = _findCharacteristic(
        options.deviceId!,
        options.serviceUuid!,
        options.characteristicUuid!,
      );

      if (char == null) {
        return const ReadCharacteristicResult(
          success: 'false',
          error: 'Characteristic not found',
        );
      }

      final value = await char.read();

      return ReadCharacteristicResult(
        success: 'true',
        value: _bytesToHex(value),
        valueBase64: base64Encode(value),
      );
    } catch (e) {
      return ReadCharacteristicResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<WriteCharacteristicResult> writeCharacteristic(
    WriteCharacteristicOptions? options,
  ) async {
    try {
      if (options == null ||
          options.deviceId == null ||
          options.serviceUuid == null ||
          options.characteristicUuid == null) {
        return const WriteCharacteristicResult(
          success: 'false',
          error: 'deviceId, serviceUuid, and characteristicUuid are required',
        );
      }

      final char = _findCharacteristic(
        options.deviceId!,
        options.serviceUuid!,
        options.characteristicUuid!,
      );

      if (char == null) {
        return const WriteCharacteristicResult(
          success: 'false',
          error: 'Characteristic not found',
        );
      }

      List<int> bytes;
      if (options.valueBase64 != null) {
        bytes = base64Decode(options.valueBase64!);
      } else if (options.value != null) {
        bytes = _hexToBytes(options.value!);
      } else {
        return const WriteCharacteristicResult(
          success: 'false',
          error: 'Value is required (value or valueBase64)',
        );
      }

      final withoutResponse = options.withoutResponse ?? false;

      await char.write(
        bytes,
        withoutResponse: withoutResponse,
      );

      return const WriteCharacteristicResult(success: 'true');
    } catch (e) {
      return WriteCharacteristicResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<ReadDescriptorResult> readDescriptor(
    ReadDescriptorOptions? options,
  ) async {
    try {
      if (options == null ||
          options.deviceId == null ||
          options.serviceUuid == null ||
          options.characteristicUuid == null ||
          options.descriptorUuid == null) {
        return const ReadDescriptorResult(
          success: 'false',
          error:
              'deviceId, serviceUuid, characteristicUuid, and descriptorUuid are required',
        );
      }

      final desc = _findDescriptor(
        options.deviceId!,
        options.serviceUuid!,
        options.characteristicUuid!,
        options.descriptorUuid!,
      );

      if (desc == null) {
        return const ReadDescriptorResult(
          success: 'false',
          error: 'Descriptor not found',
        );
      }

      final value = await desc.read();

      return ReadDescriptorResult(
        success: 'true',
        value: _bytesToHex(value),
        valueBase64: base64Encode(value),
      );
    } catch (e) {
      return ReadDescriptorResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<WriteDescriptorResult> writeDescriptor(
    WriteDescriptorOptions? options,
  ) async {
    try {
      if (options == null ||
          options.deviceId == null ||
          options.serviceUuid == null ||
          options.characteristicUuid == null ||
          options.descriptorUuid == null) {
        return const WriteDescriptorResult(
          success: 'false',
          error:
              'deviceId, serviceUuid, characteristicUuid, and descriptorUuid are required',
        );
      }

      final desc = _findDescriptor(
        options.deviceId!,
        options.serviceUuid!,
        options.characteristicUuid!,
        options.descriptorUuid!,
      );

      if (desc == null) {
        return const WriteDescriptorResult(
          success: 'false',
          error: 'Descriptor not found',
        );
      }

      List<int> bytes;
      if (options.valueBase64 != null) {
        bytes = base64Decode(options.valueBase64!);
      } else if (options.value != null) {
        bytes = _hexToBytes(options.value!);
      } else {
        return const WriteDescriptorResult(
          success: 'false',
          error: 'Value is required (value or valueBase64)',
        );
      }

      await desc.write(bytes);

      return const WriteDescriptorResult(success: 'true');
    } catch (e) {
      return WriteDescriptorResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  // ============================================================================
  // Notifications Implementation
  // ============================================================================

  @override
  Future<SubscribeResult> subscribeToNotifications(
    SubscribeOptions? options,
  ) async {
    try {
      if (options == null ||
          options.deviceId == null ||
          options.serviceUuid == null ||
          options.characteristicUuid == null) {
        return const SubscribeResult(
          success: 'false',
          error: 'deviceId, serviceUuid, and characteristicUuid are required',
        );
      }

      final char = _findCharacteristic(
        options.deviceId!,
        options.serviceUuid!,
        options.characteristicUuid!,
      );

      if (char == null) {
        return const SubscribeResult(
          success: 'false',
          error: 'Characteristic not found',
        );
      }

      // Enable notifications
      await char.setNotifyValue(true);

      // Subscribe to value changes
      final subscriptionId = _generateSubscriptionId();
      final subscription = char.onValueReceived.listen((value) {
        moduleManager!.emitModuleEvent(
          name,
          event: Event('notification'),
          data: {
            'subscriptionId': subscriptionId,
            'deviceId': options.deviceId,
            'serviceUuid': options.serviceUuid,
            'characteristicUuid': options.characteristicUuid,
            'value': _bytesToHex(value),
            'valueBase64': base64Encode(value),
          },
        );
      });

      _notificationSubscriptions[subscriptionId] = subscription;
      _notificationCharacteristics[subscriptionId] = char;

      return SubscribeResult(
        success: 'true',
        subscriptionId: subscriptionId,
      );
    } catch (e) {
      return SubscribeResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<UnsubscribeResult> unsubscribeFromNotifications(
    dynamic subscriptionId,
  ) async {
    try {
      final id = subscriptionId.toString();
      final subscription = _notificationSubscriptions.remove(id);
      final char = _notificationCharacteristics.remove(id);

      if (subscription != null) {
        await subscription.cancel();
      }

      // Disable notifications on the characteristic
      if (char != null) {
        try {
          await char.setNotifyValue(false);
        } catch (_) {
          // Ignore errors when disabling notifications
        }
      }

      return const UnsubscribeResult(success: 'true');
    } catch (e) {
      return UnsubscribeResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }
}
