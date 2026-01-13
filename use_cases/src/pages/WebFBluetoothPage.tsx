import React, { useState, useEffect, useCallback } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  WebFBluetooth,
  BluetoothScanResultPayload,
  BluetoothConnectionStatePayload,
  BluetoothNotificationPayload,
} from '@openwebf/webf-bluetooth';

// Local types for parsed service/characteristic data
interface BluetoothService {
  uuid: string;
  isPrimary: boolean;
  characteristics: BluetoothCharacteristic[];
}

interface BluetoothCharacteristic {
  uuid: string;
  serviceUuid: string;
  deviceId: string;
  properties: {
    read: boolean;
    write: boolean;
    writeWithoutResponse: boolean;
    notify: boolean;
    indicate: boolean;
  };
}

export const WebFBluetoothPage: React.FC = () => {
  const [adapterState, setAdapterState] = useState<string>('unknown');
  const [isScanning, setIsScanning] = useState(false);
  const [devices, setDevices] = useState<BluetoothScanResultPayload[]>([]);
  const [connectedDeviceId, setConnectedDeviceId] = useState<string | null>(null);
  const [services, setServices] = useState<BluetoothService[]>([]);
  const [logs, setLogs] = useState<string[]>([]);
  const [isProcessing, setIsProcessing] = useState<{[key: string]: boolean}>({});
  const [subscriptionIds, setSubscriptionIds] = useState<string[]>([]);

  const addLog = useCallback((message: string) => {
    const timestamp = new Date().toLocaleTimeString();
    setLogs(prev => [`[${timestamp}] ${message}`, ...prev.slice(0, 49)]);
  }, []);

  useEffect(() => {
    checkAdapterState();

    // Set up event listeners using WebFBluetooth.addListener API
    const unsubscribeScan = WebFBluetooth.addListener('scanResult', (_event, device) => {
      addLog(`Found: ${device.name || device.localName || 'Unknown'} (${device.rssi} dBm)`);
      setDevices(prev => {
        const existing = prev.find(d => d.deviceId === device.deviceId);
        if (existing) {
          return prev.map(d => d.deviceId === device.deviceId ? device : d);
        }
        return [...prev, device];
      });
    });

    const unsubscribeConnection = WebFBluetooth.addListener('connectionState', (_event, detail) => {
      addLog(`Connection state: ${detail.deviceId} -> ${detail.state}`);
      if (detail.state === 'disconnected') {
        setConnectedDeviceId(null);
        setServices([]);
      }
    });

    const unsubscribeNotification = WebFBluetooth.addListener('notification', (_event, detail) => {
      addLog(`Notification from ${detail.characteristicUuid}: ${detail.value}`);
    });

    return () => {
      // Cleanup: unsubscribe from events
      unsubscribeScan();
      unsubscribeConnection();
      unsubscribeNotification();
      // Stop scanning and disconnect
      WebFBluetooth.stopScan().catch(() => {});
      if (connectedDeviceId) {
        WebFBluetooth.disconnect(connectedDeviceId).catch(() => {});
      }
    };
  }, []);

  const checkAdapterState = async () => {
    if (!WebFBluetooth.isAvailable()) {
      addLog('WebFBluetooth is not available. Make sure the module is registered.');
      return;
    }

    try {
      const result = await WebFBluetooth.getAdapterState();
      if (result.success === 'true') {
        setAdapterState(result.state || 'unknown');
        addLog(`Adapter state: ${result.state}`);
      } else {
        addLog(`Failed to get adapter state: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error checking adapter state: ${error}`);
    }
  };

  const startScan = async () => {
    setIsProcessing(prev => ({ ...prev, scan: true }));
    setDevices([]);

    try {
      const result = await WebFBluetooth.startScan({ timeout: 10000 });
      if (result.success === 'true') {
        setIsScanning(true);
        addLog('Scanning started (10s timeout)');

        // Auto-stop after timeout
        setTimeout(async () => {
          await stopScan();
        }, 10000);
      } else {
        addLog(`Failed to start scan: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error starting scan: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, scan: false }));
    }
  };

  const stopScan = async () => {
    try {
      const result = await WebFBluetooth.stopScan();
      if (result.success === 'true') {
        setIsScanning(false);
        addLog('Scan stopped');
      }
    } catch (error) {
      addLog(`Error stopping scan: ${error}`);
    }
  };

  const connectToDevice = async (deviceId: string) => {
    setIsProcessing(prev => ({ ...prev, [`connect_${deviceId}`]: true }));

    try {
      // Stop scanning first
      await stopScan();

      const result = await WebFBluetooth.connect({
        deviceId,
        timeout: 15000,
      });

      if (result.success === 'true') {
        setConnectedDeviceId(deviceId);
        addLog(`Connected to ${deviceId}! MTU: ${result.mtu || 'default'}`);

        // Auto-discover services
        await discoverServices(deviceId);
      } else {
        addLog(`Failed to connect: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error connecting: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, [`connect_${deviceId}`]: false }));
    }
  };

  const disconnectDevice = async () => {
    if (!connectedDeviceId) return;

    setIsProcessing(prev => ({ ...prev, disconnect: true }));

    try {
      // Unsubscribe from all notifications
      for (const subId of subscriptionIds) {
        await WebFBluetooth.unsubscribeFromNotifications(subId);
      }
      setSubscriptionIds([]);

      const result = await WebFBluetooth.disconnect(connectedDeviceId);
      if (result.success === 'true') {
        setConnectedDeviceId(null);
        setServices([]);
        addLog('Disconnected');
      } else {
        addLog(`Failed to disconnect: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error disconnecting: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, disconnect: false }));
    }
  };

  const discoverServices = async (deviceId: string) => {
    setIsProcessing(prev => ({ ...prev, discover: true }));

    try {
      const result = await WebFBluetooth.discoverServices(deviceId);
      if (result.success === 'true' && result.services) {
        const parsedServices = JSON.parse(result.services) as BluetoothService[];
        setServices(parsedServices);
        addLog(`Discovered ${parsedServices.length} services`);
      } else {
        addLog(`Failed to discover services: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error discovering services: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, discover: false }));
    }
  };

  const readCharacteristic = async (serviceUuid: string, charUuid: string) => {
    if (!connectedDeviceId) return;

    try {
      const result = await WebFBluetooth.readCharacteristic({
        deviceId: connectedDeviceId,
        serviceUuid,
        characteristicUuid: charUuid,
      });

      if (result.success === 'true') {
        addLog(`Read ${charUuid}: ${result.value}`);
      } else {
        addLog(`Read failed: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error reading: ${error}`);
    }
  };

  const subscribeToCharacteristic = async (serviceUuid: string, charUuid: string) => {
    if (!connectedDeviceId) return;

    try {
      const result = await WebFBluetooth.subscribeToNotifications({
        deviceId: connectedDeviceId,
        serviceUuid,
        characteristicUuid: charUuid,
      });

      if (result.success === 'true') {
        setSubscriptionIds(prev => [...prev, result.subscriptionId!]);
        addLog(`Subscribed to ${charUuid}`);
      } else {
        addLog(`Subscribe failed: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error subscribing: ${error}`);
    }
  };

  const getSignalStrengthColor = (rssi: number) => {
    if (rssi >= -50) return 'text-green-500';
    if (rssi >= -70) return 'text-yellow-500';
    return 'text-red-500';
  };

  return (
    <div id="main">
      <WebFListView className="flex-1 p-0 m-0">
        <div className="p-5 bg-gray-100 dark:bg-gray-900 min-h-screen max-w-4xl mx-auto">
          <h1 className="text-2xl font-bold text-gray-800 dark:text-white mb-6 text-center">
            WebF Bluetooth Module
          </h1>

          {/* Adapter Status */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Bluetooth Adapter</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Bluetooth Low Energy device scanning and connection
            </p>
            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
              <div className="flex items-center justify-between mb-3">
                <span className="font-semibold text-gray-700 dark:text-gray-300">Status: </span>
                <span className={`font-medium ${adapterState === 'on' ? 'text-green-600' : 'text-red-600'}`}>
                  {adapterState.toUpperCase()}
                </span>
              </div>
              <button
                onClick={checkAdapterState}
                className="px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg font-medium transition-colors"
              >
                Refresh Status
              </button>
            </div>
          </div>

          {/* Scanning */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Device Scanning</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Scan for nearby BLE devices
            </p>
            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
              <div className="flex gap-2 mb-4">
                <button
                  onClick={isScanning ? stopScan : startScan}
                  disabled={isProcessing.scan || adapterState !== 'on'}
                  className={`px-4 py-2 rounded-lg text-white font-medium transition-all ${
                    isProcessing.scan || adapterState !== 'on'
                      ? 'bg-gray-400 cursor-not-allowed'
                      : isScanning
                        ? 'bg-red-500 hover:bg-red-600'
                        : 'bg-blue-500 hover:bg-blue-600'
                  }`}
                >
                  {isProcessing.scan ? 'Starting...' : isScanning ? 'Stop Scan' : 'Start Scan'}
                </button>
              </div>

              {/* Scan Results */}
              <div className="max-h-64 overflow-y-auto">
                {devices.length === 0 ? (
                  <div className="text-gray-500 text-center py-5">
                    {isScanning ? 'Scanning...' : 'No devices found. Start scanning!'}
                  </div>
                ) : (
                  <div className="space-y-2">
                    {devices.sort((a, b) => b.rssi - a.rssi).map(device => (
                      <div
                        key={device.deviceId}
                        className="flex items-center justify-between p-3 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600"
                      >
                        <div className="flex-1">
                          <div className="font-semibold text-gray-800 dark:text-white">
                            {device.name || device.localName || 'Unknown Device'}
                          </div>
                          <div className="text-xs text-gray-500 dark:text-gray-400 font-mono">
                            {device.deviceId}
                          </div>
                        </div>
                        <div className="flex items-center gap-3">
                          <span className={`font-mono text-sm ${getSignalStrengthColor(device.rssi)}`}>
                            {device.rssi} dBm
                          </span>
                          {device.connectable !== false && (
                            <button
                              onClick={() => connectToDevice(device.deviceId)}
                              disabled={isProcessing[`connect_${device.deviceId}`] || connectedDeviceId !== null}
                              className={`px-3 py-1 rounded-md text-white text-sm font-medium transition-colors ${
                                isProcessing[`connect_${device.deviceId}`] || connectedDeviceId !== null
                                  ? 'bg-gray-400 cursor-not-allowed'
                                  : 'bg-blue-500 hover:bg-blue-600'
                              }`}
                            >
                              {isProcessing[`connect_${device.deviceId}`] ? '...' : 'Connect'}
                            </button>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Connected Device */}
          {connectedDeviceId && (
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
              <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Connected Device</h2>
              <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
                {connectedDeviceId}
              </p>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                <div className="flex gap-2 mb-4">
                  <button
                    onClick={disconnectDevice}
                    disabled={isProcessing.disconnect}
                    className={`px-4 py-2 rounded-lg text-white font-medium transition-all ${
                      isProcessing.disconnect
                        ? 'bg-gray-400 cursor-not-allowed'
                        : 'bg-red-500 hover:bg-red-600'
                    }`}
                  >
                    {isProcessing.disconnect ? 'Disconnecting...' : 'Disconnect'}
                  </button>
                  <button
                    onClick={() => discoverServices(connectedDeviceId)}
                    disabled={isProcessing.discover}
                    className={`px-4 py-2 rounded-lg text-white font-medium transition-all ${
                      isProcessing.discover
                        ? 'bg-gray-400 cursor-not-allowed'
                        : 'bg-blue-500 hover:bg-blue-600'
                    }`}
                  >
                    {isProcessing.discover ? 'Discovering...' : 'Refresh Services'}
                  </button>
                </div>

                {/* Services List */}
                {services.length > 0 && (
                  <div className="max-h-64 overflow-y-auto">
                    <div className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                      Services ({services.length})
                    </div>
                    <div className="space-y-3">
                      {services.map(service => (
                        <div
                          key={service.uuid}
                          className="bg-white dark:bg-gray-800 rounded-lg p-3 border border-gray-200 dark:border-gray-600"
                        >
                          <div className="font-mono text-xs text-blue-600 dark:text-blue-400 mb-2">
                            {service.uuid}
                          </div>
                          <div className="pl-3 space-y-1">
                            {service.characteristics.map(char => (
                              <div
                                key={char.uuid}
                                className="flex items-center justify-between py-1 border-b border-gray-100 dark:border-gray-700 last:border-0"
                              >
                                <div>
                                  <div className="font-mono text-xs text-gray-600 dark:text-gray-400">
                                    {char.uuid}
                                  </div>
                                  <div className="text-xs text-gray-400">
                                    {[
                                      char.properties.read && 'R',
                                      char.properties.write && 'W',
                                      char.properties.notify && 'N',
                                      char.properties.indicate && 'I',
                                    ].filter(Boolean).join(' ')}
                                  </div>
                                </div>
                                <div className="flex gap-1">
                                  {char.properties.read && (
                                    <button
                                      onClick={() => readCharacteristic(service.uuid, char.uuid)}
                                      className="px-2 py-1 bg-blue-500 hover:bg-blue-600 text-white text-xs rounded"
                                    >
                                      Read
                                    </button>
                                  )}
                                  {(char.properties.notify || char.properties.indicate) && (
                                    <button
                                      onClick={() => subscribeToCharacteristic(service.uuid, char.uuid)}
                                      className="px-2 py-1 bg-purple-500 hover:bg-purple-600 text-white text-xs rounded"
                                    >
                                      Subscribe
                                    </button>
                                  )}
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Logs */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Operation Logs</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Real-time Bluetooth operation logs
            </p>
            <div className="bg-gray-900 rounded-lg p-3 border border-gray-700 max-h-72 overflow-y-auto font-mono text-xs text-gray-300">
              {logs.length === 0 ? (
                <div className="text-gray-500">No logs yet...</div>
              ) : (
                logs.map((log, index) => (
                  <div key={index} className="mb-1 break-all">
                    {log}
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
