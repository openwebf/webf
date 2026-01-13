<script setup lang="ts">
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue';
import {
  WebFBluetooth,
  type BluetoothScanResultPayload,
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

const adapterState = ref<string>('unknown');
const isScanning = ref(false);
const devices = ref<BluetoothScanResultPayload[]>([]);
const connectedDeviceId = ref<string | null>(null);
const services = ref<BluetoothService[]>([]);
const logs = ref<string[]>([]);
const subscriptionIds = ref<string[]>([]);
const isProcessing = reactive<Record<string, boolean>>({});

// Cleanup functions for event listeners
let unsubscribeScan: (() => void) | null = null;
let unsubscribeConnection: (() => void) | null = null;
let unsubscribeNotification: (() => void) | null = null;

function addLog(message: string) {
  const timestamp = new Date().toLocaleTimeString();
  logs.value = [`[${timestamp}] ${message}`, ...logs.value.slice(0, 49)];
}

function isBluetoothAvailable() {
  return WebFBluetooth.isAvailable();
}

async function checkAdapterState() {
  if (!isBluetoothAvailable()) {
    addLog('WebFBluetooth is not available. Make sure the module is registered.');
    return;
  }

  try {
    const result = await WebFBluetooth.getAdapterState();
    if (result.success === 'true') {
      adapterState.value = result.state || 'unknown';
      addLog(`Adapter state: ${result.state}`);
    } else {
      addLog(`Failed to get adapter state: ${result.error}`);
    }
  } catch (error) {
    addLog(`Error checking adapter state: ${error}`);
  }
}

async function startScan() {
  isProcessing.scan = true;
  devices.value = [];

  try {
    const result = await WebFBluetooth.startScan({ timeout: 10000 });
    if (result.success === 'true') {
      isScanning.value = true;
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
    isProcessing.scan = false;
  }
}

async function stopScan() {
  try {
    const result = await WebFBluetooth.stopScan();
    if (result.success === 'true') {
      isScanning.value = false;
      addLog('Scan stopped');
    }
  } catch (error) {
    addLog(`Error stopping scan: ${error}`);
  }
}

async function connectToDevice(deviceId: string) {
  isProcessing[`connect_${deviceId}`] = true;

  try {
    // Stop scanning first
    await stopScan();

    const result = await WebFBluetooth.connect({
      deviceId,
      timeout: 15000,
    });

    if (result.success === 'true') {
      connectedDeviceId.value = deviceId;
      addLog(`Connected to ${deviceId}! MTU: ${result.mtu || 'default'}`);

      // Auto-discover services
      await discoverServices(deviceId);
    } else {
      addLog(`Failed to connect: ${result.error}`);
    }
  } catch (error) {
    addLog(`Error connecting: ${error}`);
  } finally {
    isProcessing[`connect_${deviceId}`] = false;
  }
}

async function disconnectDevice() {
  if (!connectedDeviceId.value) return;

  isProcessing.disconnect = true;

  try {
    // Unsubscribe from all notifications
    for (const subId of subscriptionIds.value) {
      await WebFBluetooth.unsubscribeFromNotifications(subId);
    }
    subscriptionIds.value = [];

    const result = await WebFBluetooth.disconnect(connectedDeviceId.value);
    if (result.success === 'true') {
      connectedDeviceId.value = null;
      services.value = [];
      addLog('Disconnected');
    } else {
      addLog(`Failed to disconnect: ${result.error}`);
    }
  } catch (error) {
    addLog(`Error disconnecting: ${error}`);
  } finally {
    isProcessing.disconnect = false;
  }
}

async function discoverServices(deviceId: string) {
  isProcessing.discover = true;

  try {
    const result = await WebFBluetooth.discoverServices(deviceId);
    if (result.success === 'true' && result.services) {
      const parsedServices = JSON.parse(result.services) as BluetoothService[];
      services.value = parsedServices;
      addLog(`Discovered ${parsedServices.length} services`);
    } else {
      addLog(`Failed to discover services: ${result.error}`);
    }
  } catch (error) {
    addLog(`Error discovering services: ${error}`);
  } finally {
    isProcessing.discover = false;
  }
}

async function readCharacteristic(serviceUuid: string, charUuid: string) {
  if (!connectedDeviceId.value) return;

  try {
    const result = await WebFBluetooth.readCharacteristic({
      deviceId: connectedDeviceId.value,
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
}

async function subscribeToCharacteristic(serviceUuid: string, charUuid: string) {
  if (!connectedDeviceId.value) return;

  try {
    const result = await WebFBluetooth.subscribeToNotifications({
      deviceId: connectedDeviceId.value,
      serviceUuid,
      characteristicUuid: charUuid,
    });

    if (result.success === 'true') {
      subscriptionIds.value = [...subscriptionIds.value, result.subscriptionId!];
      addLog(`Subscribed to ${charUuid}`);
    } else {
      addLog(`Subscribe failed: ${result.error}`);
    }
  } catch (error) {
    addLog(`Error subscribing: ${error}`);
  }
}

function getSignalStrengthClass(rssi: number): string {
  if (rssi >= -50) return 'text-green-500';
  if (rssi >= -70) return 'text-yellow-500';
  return 'text-red-500';
}

function getCharacteristicProperties(char: BluetoothCharacteristic): string {
  return [
    char.properties.read && 'R',
    char.properties.write && 'W',
    char.properties.notify && 'N',
    char.properties.indicate && 'I',
  ]
    .filter(Boolean)
    .join(' ');
}

// Sort devices by signal strength
const sortedDevices = computed(() => {
  return [...devices.value].sort((a, b) => b.rssi - a.rssi);
});

onMounted(() => {
  checkAdapterState();

  // Set up event listeners using WebFBluetooth.addListener API
  unsubscribeScan = WebFBluetooth.addListener('scanResult', (_event, device) => {
    addLog(`Found: ${device.name || device.localName || 'Unknown'} (${device.rssi} dBm)`);
    const existing = devices.value.find((d) => d.deviceId === device.deviceId);
    if (existing) {
      devices.value = devices.value.map((d) => (d.deviceId === device.deviceId ? device : d));
    } else {
      devices.value = [...devices.value, device];
    }
  });

  unsubscribeConnection = WebFBluetooth.addListener('connectionState', (_event, detail) => {
    addLog(`Connection state: ${detail.deviceId} -> ${detail.state}`);
    if (detail.state === 'disconnected') {
      connectedDeviceId.value = null;
      services.value = [];
    }
  });

  unsubscribeNotification = WebFBluetooth.addListener('notification', (_event, detail) => {
    addLog(`Notification from ${detail.characteristicUuid}: ${detail.value}`);
  });
});

onUnmounted(() => {
  // Cleanup: unsubscribe from events
  unsubscribeScan?.();
  unsubscribeConnection?.();
  unsubscribeNotification?.();

  // Stop scanning and disconnect
  WebFBluetooth.stopScan().catch(() => {});
  if (connectedDeviceId.value) {
    WebFBluetooth.disconnect(connectedDeviceId.value).catch(() => {});
  }
});
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">WebF Bluetooth Module</h1>
      <p class="text-fg-secondary mb-6">
        Bluetooth Low Energy device scanning, connection, and GATT operations.
      </p>

      <!-- Module availability notice -->
      <div v-if="!isBluetoothAvailable()" class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-fg-secondary">This page requires the WebF Bluetooth module registered in the WebF runtime.</div>
        <div class="mt-2 text-fg-tertiary font-mono text-xs">WebF.defineModule((context) =&gt; BluetoothModule(context))</div>
      </div>

      <div class="flex flex-col gap-4">
        <!-- Adapter Status -->
        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary mb-1">Bluetooth Adapter</div>
          <div class="text-sm text-fg-secondary mb-4">Check and refresh adapter status</div>
          <div class="flex items-center gap-4 mb-3">
            <span class="text-fg-secondary">Status:</span>
            <span :class="['font-semibold', adapterState === 'on' ? 'text-green-500' : 'text-red-500']">
              {{ adapterState.toUpperCase() }}
            </span>
          </div>
          <button
            class="px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600 disabled:opacity-50"
            @click="checkAdapterState"
          >
            Refresh Status
          </button>
        </div>

        <!-- Scanning -->
        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary mb-1">Device Scanning</div>
          <div class="text-sm text-fg-secondary mb-4">Scan for nearby BLE devices</div>

          <button
            :class="[
              'px-4 py-2 rounded text-white disabled:opacity-50 mb-4',
              isScanning ? 'bg-red-500 hover:bg-red-600' : 'bg-blue-500 hover:bg-blue-600'
            ]"
            :disabled="isProcessing.scan || adapterState !== 'on'"
            @click="isScanning ? stopScan() : startScan()"
          >
            {{ isProcessing.scan ? 'Starting...' : isScanning ? 'Stop Scan' : 'Start Scan' }}
          </button>

          <!-- Scan Results -->
          <div class="max-h-64 overflow-y-auto">
            <div v-if="devices.length === 0" class="text-fg-tertiary text-center py-5">
              {{ isScanning ? 'Scanning...' : 'No devices found. Start scanning!' }}
            </div>
            <div v-else class="flex flex-col gap-2">
              <div
                v-for="device in sortedDevices"
                :key="device.deviceId"
                class="flex items-center justify-between p-3 bg-surface border border-line rounded-lg"
              >
                <div class="flex-1 min-w-0">
                  <div class="font-semibold text-fg-primary truncate">
                    {{ device.name || device.localName || 'Unknown Device' }}
                  </div>
                  <div class="text-xs text-fg-tertiary font-mono truncate">{{ device.deviceId }}</div>
                </div>
                <div class="flex items-center gap-3 ml-3">
                  <span :class="['font-mono text-sm', getSignalStrengthClass(device.rssi)]">
                    {{ device.rssi }} dBm
                  </span>
                  <button
                    v-if="device.connectable !== false"
                    class="px-3 py-1 rounded bg-blue-500 text-white text-sm hover:bg-blue-600 disabled:opacity-50"
                    :disabled="isProcessing[`connect_${device.deviceId}`] || connectedDeviceId !== null"
                    @click="connectToDevice(device.deviceId)"
                  >
                    {{ isProcessing[`connect_${device.deviceId}`] ? '...' : 'Connect' }}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Connected Device -->
        <div v-if="connectedDeviceId" class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary mb-1">Connected Device</div>
          <div class="text-sm text-fg-secondary mb-4 font-mono">{{ connectedDeviceId }}</div>

          <div class="flex gap-2 mb-4">
            <button
              class="px-4 py-2 rounded bg-red-500 text-white hover:bg-red-600 disabled:opacity-50"
              :disabled="isProcessing.disconnect"
              @click="disconnectDevice"
            >
              {{ isProcessing.disconnect ? 'Disconnecting...' : 'Disconnect' }}
            </button>
            <button
              class="px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600 disabled:opacity-50"
              :disabled="isProcessing.discover"
              @click="discoverServices(connectedDeviceId!)"
            >
              {{ isProcessing.discover ? 'Discovering...' : 'Refresh Services' }}
            </button>
          </div>

          <!-- Services List -->
          <div v-if="services.length > 0" class="max-h-64 overflow-y-auto">
            <div class="text-sm font-semibold text-fg-secondary mb-2">
              Services ({{ services.length }})
            </div>
            <div class="flex flex-col gap-3">
              <div
                v-for="service in services"
                :key="service.uuid"
                class="bg-surface border border-line rounded-lg p-3"
              >
                <div class="font-mono text-xs text-blue-500 mb-2">{{ service.uuid }}</div>
                <div class="pl-3 flex flex-col gap-1">
                  <div
                    v-for="char in service.characteristics"
                    :key="char.uuid"
                    class="flex items-center justify-between py-1 border-b border-line last:border-0"
                  >
                    <div class="min-w-0 flex-1">
                      <div class="font-mono text-xs text-fg-secondary truncate">{{ char.uuid }}</div>
                      <div class="text-xs text-fg-tertiary">{{ getCharacteristicProperties(char) }}</div>
                    </div>
                    <div class="flex gap-1 ml-2">
                      <button
                        v-if="char.properties.read"
                        class="px-2 py-1 bg-blue-500 hover:bg-blue-600 text-white text-xs rounded"
                        @click="readCharacteristic(service.uuid, char.uuid)"
                      >
                        Read
                      </button>
                      <button
                        v-if="char.properties.notify || char.properties.indicate"
                        class="px-2 py-1 bg-purple-500 hover:bg-purple-600 text-white text-xs rounded"
                        @click="subscribeToCharacteristic(service.uuid, char.uuid)"
                      >
                        Subscribe
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Logs -->
        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary mb-1">Operation Logs</div>
          <div class="text-sm text-fg-secondary mb-4">Real-time Bluetooth operation logs</div>
          <div class="bg-gray-900 rounded-lg p-3 border border-gray-700 max-h-72 overflow-y-auto font-mono text-xs text-gray-300">
            <div v-if="logs.length === 0" class="text-gray-500">No logs yet...</div>
            <div v-for="(log, index) in logs" :key="index" class="mb-1 break-all">
              {{ log }}
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>