/**
 * Type-safe JavaScript API for the WebF Bluetooth module.
 *
 * This interface is used by the WebF CLI (`webf module-codegen`) to generate:
 * - An npm package wrapper that forwards calls to `webf.invokeModuleAsync`
 * - Dart bindings that map module `invoke` calls to strongly-typed methods
 */

// ============================================================================
// Adapter State
// ============================================================================

/**
 * Result from getting adapter state.
 */
interface AdapterStateResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Adapter state: 'unknown', 'on', 'off', 'turningOn', 'turningOff', 'unavailable'. */
  state?: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Result from checking if Bluetooth is on.
 */
interface IsBluetoothOnResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** "true" if Bluetooth is on, "false" otherwise. */
  isOn?: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Result from turning on Bluetooth.
 */
interface TurnOnResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Error message if the operation failed. */
  error?: string;
}

// ============================================================================
// Scanning
// ============================================================================

/**
 * Options for starting a BLE scan.
 */
interface ScanOptions {
  /** Service UUIDs to filter by (optional). */
  serviceUuids?: string[];
  /** Scan timeout in milliseconds. 0 means scan indefinitely. */
  timeout?: number;
  /** Whether to allow duplicates in scan results. */
  allowDuplicates?: boolean;
  /** Android: Scan mode (0=low power, 1=balanced, 2=low latency). */
  androidScanMode?: number;
}

/**
 * Result from starting a scan.
 */
interface ScanStartResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Unique scan session ID. */
  scanId?: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Result from stopping a scan.
 */
interface ScanStopResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Result from checking if scanning.
 */
interface IsScanningResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** "true" if scanning, "false" otherwise. */
  isScanning?: string;
  /** Error message if the operation failed. */
  error?: string;
}

// ============================================================================
// Connection Management
// ============================================================================

/**
 * Options for connecting to a device.
 */
interface ConnectOptions {
  /** Device identifier to connect to. */
  deviceId: string;
  /** Connection timeout in milliseconds. */
  timeout?: number;
  /** Whether to automatically reconnect on disconnect. */
  autoConnect?: boolean;
  /** MTU size to request (Android only). */
  mtu?: number;
}

/**
 * Result from connecting to a device.
 */
interface ConnectResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Connection ID for subsequent operations. */
  connectionId?: string;
  /** Negotiated MTU size. */
  mtu?: number;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Result from disconnecting.
 */
interface DisconnectResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Result from getting connection state.
 */
interface ConnectionStateResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Connection state: 'disconnected', 'connecting', 'connected', 'disconnecting'. */
  state?: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Result from getting connected devices.
 */
interface ConnectedDevicesResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** JSON array of connected device info. */
  devices?: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Result from requesting MTU.
 */
interface RequestMtuResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Negotiated MTU size. */
  mtu?: number;
  /** Error message if the operation failed. */
  error?: string;
}

// ============================================================================
// Service Discovery
// ============================================================================

/**
 * Result from discovering services.
 */
interface DiscoverServicesResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** JSON array of service info objects. */
  services?: string;
  /** Error message if the operation failed. */
  error?: string;
}

// ============================================================================
// Data Transfer
// ============================================================================

/**
 * Options for reading a characteristic.
 */
interface ReadCharacteristicOptions {
  /** Device ID. */
  deviceId: string;
  /** Service UUID. */
  serviceUuid: string;
  /** Characteristic UUID. */
  characteristicUuid: string;
}

/**
 * Result from reading a characteristic.
 */
interface ReadCharacteristicResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Value as hex string. */
  value?: string;
  /** Value as raw bytes (base64 encoded). */
  valueBase64?: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Options for writing to a characteristic.
 */
interface WriteCharacteristicOptions {
  /** Device ID. */
  deviceId: string;
  /** Service UUID. */
  serviceUuid: string;
  /** Characteristic UUID. */
  characteristicUuid: string;
  /** Value to write as hex string. */
  value?: string;
  /** Value to write as base64 encoded bytes. */
  valueBase64?: string;
  /** Whether to write without response. */
  withoutResponse?: boolean;
}

/**
 * Result from writing to a characteristic.
 */
interface WriteCharacteristicResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Options for reading a descriptor.
 */
interface ReadDescriptorOptions {
  /** Device ID. */
  deviceId: string;
  /** Service UUID. */
  serviceUuid: string;
  /** Characteristic UUID. */
  characteristicUuid: string;
  /** Descriptor UUID. */
  descriptorUuid: string;
}

/**
 * Result from reading a descriptor.
 */
interface ReadDescriptorResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Value as hex string. */
  value?: string;
  /** Value as base64 encoded bytes. */
  valueBase64?: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Options for writing to a descriptor.
 */
interface WriteDescriptorOptions {
  /** Device ID. */
  deviceId: string;
  /** Service UUID. */
  serviceUuid: string;
  /** Characteristic UUID. */
  characteristicUuid: string;
  /** Descriptor UUID. */
  descriptorUuid: string;
  /** Value as hex string. */
  value?: string;
  /** Value as base64 encoded bytes. */
  valueBase64?: string;
}

/**
 * Result from writing to a descriptor.
 */
interface WriteDescriptorResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Error message if the operation failed. */
  error?: string;
}

// ============================================================================
// Notifications
// ============================================================================

/**
 * Options for subscribing to characteristic notifications.
 */
interface SubscribeOptions {
  /** Device ID. */
  deviceId: string;
  /** Service UUID. */
  serviceUuid: string;
  /** Characteristic UUID. */
  characteristicUuid: string;
}

/**
 * Result from subscribing to notifications.
 */
interface SubscribeResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Subscription ID for unsubscribing. */
  subscriptionId?: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Result from unsubscribing from notifications.
 */
interface UnsubscribeResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Error message if the operation failed. */
  error?: string;
}

// ============================================================================
// Module Interface
// ============================================================================

/**
 * Extra data payloads emitted by the Bluetooth module.
 */
interface BluetoothScanResultPayload {
  deviceId: string;
  remoteId: string;
  name?: string;
  localName?: string;
  rssi: number;
  serviceUuids: string[];
  manufacturerData?: string;
  connectable: boolean;
  txPowerLevel?: number;
}

interface BluetoothConnectionStatePayload {
  deviceId: string;
  state: 'disconnected' | 'connecting' | 'connected' | 'disconnecting';
}

interface BluetoothNotificationPayload {
  subscriptionId: string;
  deviceId: string;
  serviceUuid: string;
  characteristicUuid: string;
  value: string;
  valueBase64: string;
}

/**
 * Module events emitted via Dart `moduleManager.emitModuleEvent(name, event: Event('<type>'), data: <payload>)`.
 *
 * Keys must match the runtime `event.type` string.
 */
interface WebFBluetoothModuleEvents {
  scanResult: [Event, BluetoothScanResultPayload];
  connectionState: [Event, BluetoothConnectionStatePayload];
  notification: [Event, BluetoothNotificationPayload];
}

/**
 * Public WebF Bluetooth module interface.
 *
 * Methods here map 1:1 to the Dart `BluetoothModule` methods.
 *
 * Events emitted by this module:
 * - 'scanResult' - Emitted for each device found during scanning
 * - 'connectionState' - Emitted when connection state changes
 * - 'notification' - Emitted when a subscribed characteristic value changes
 *
 * Module name: "Bluetooth"
 */
interface WebFBluetooth {
  // ============================================================================
  // Adapter Management
  // ============================================================================

  /**
   * Get the current Bluetooth adapter state.
   *
   * @returns Promise with adapter state ('unknown', 'on', 'off', 'turningOn', 'turningOff', 'unavailable').
   */
  getAdapterState(): Promise<AdapterStateResult>;

  /**
   * Check if Bluetooth is currently on.
   *
   * @returns Promise with isOn flag.
   */
  isBluetoothOn(): Promise<IsBluetoothOnResult>;

  /**
   * Turn on Bluetooth (Android only, requires permission).
   *
   * @returns Promise with success status.
   */
  turnOn(): Promise<TurnOnResult>;

  // ============================================================================
  // Scanning
  // ============================================================================

  /**
   * Start scanning for BLE devices.
   * Scan results are emitted as 'scanResult' events.
   *
   * @param options Optional scan configuration.
   * @returns Promise with scan session ID.
   */
  startScan(options?: ScanOptions): Promise<ScanStartResult>;

  /**
   * Stop an active scan.
   *
   * @returns Promise with success status.
   */
  stopScan(): Promise<ScanStopResult>;

  /**
   * Check if a scan is currently in progress.
   *
   * @returns Promise with isScanning flag.
   */
  isScanning(): Promise<IsScanningResult>;

  // ============================================================================
  // Connection Management
  // ============================================================================

  /**
   * Connect to a BLE device.
   *
   * @param options Connection options including deviceId.
   * @returns Promise with connection result.
   */
  connect(options: ConnectOptions): Promise<ConnectResult>;

  /**
   * Disconnect from a device.
   *
   * @param deviceId Device identifier.
   * @returns Promise with success status.
   */
  disconnect(deviceId: string): Promise<DisconnectResult>;

  /**
   * Get connection state for a device.
   *
   * @param deviceId Device identifier.
   * @returns Promise with connection state.
   */
  getConnectionState(deviceId: string): Promise<ConnectionStateResult>;

  /**
   * Get list of currently connected devices.
   *
   * @returns Promise with JSON array of connected devices.
   */
  getConnectedDevices(): Promise<ConnectedDevicesResult>;

  /**
   * Request a specific MTU size (Android).
   *
   * @param deviceId Device identifier.
   * @param mtu Desired MTU size.
   * @returns Promise with negotiated MTU.
   */
  requestMtu(deviceId: string, mtu: number): Promise<RequestMtuResult>;

  // ============================================================================
  // Service Discovery
  // ============================================================================

  /**
   * Discover services on a connected device.
   *
   * @param deviceId Device identifier.
   * @returns Promise with JSON array of discovered services.
   */
  discoverServices(deviceId: string): Promise<DiscoverServicesResult>;

  // ============================================================================
  // Data Transfer
  // ============================================================================

  /**
   * Read a characteristic value.
   *
   * @param options Read options with device, service, and characteristic UUIDs.
   * @returns Promise with value as hex and base64.
   */
  readCharacteristic(options: ReadCharacteristicOptions): Promise<ReadCharacteristicResult>;

  /**
   * Write a value to a characteristic.
   *
   * @param options Write options with device, service, characteristic UUIDs and value.
   * @returns Promise with success status.
   */
  writeCharacteristic(options: WriteCharacteristicOptions): Promise<WriteCharacteristicResult>;

  /**
   * Read a descriptor value.
   *
   * @param options Read options with device, service, characteristic, and descriptor UUIDs.
   * @returns Promise with value as hex and base64.
   */
  readDescriptor(options: ReadDescriptorOptions): Promise<ReadDescriptorResult>;

  /**
   * Write a value to a descriptor.
   *
   * @param options Write options with device, service, characteristic, descriptor UUIDs and value.
   * @returns Promise with success status.
   */
  writeDescriptor(options: WriteDescriptorOptions): Promise<WriteDescriptorResult>;

  // ============================================================================
  // Notifications
  // ============================================================================

  /**
   * Subscribe to characteristic notifications.
   * Notifications are emitted as 'notification' events.
   *
   * @param options Subscribe options with device, service, and characteristic UUIDs.
   * @returns Promise with subscription ID.
   */
  subscribeToNotifications(options: SubscribeOptions): Promise<SubscribeResult>;

  /**
   * Unsubscribe from characteristic notifications.
   *
   * @param subscriptionId Subscription ID from subscribeToNotifications.
   * @returns Promise with success status.
   */
  unsubscribeFromNotifications(subscriptionId: string): Promise<UnsubscribeResult>;
}
