<script setup lang="ts">
import { ref } from 'vue';

const basicSwitch = ref(false);
const notificationsOn = ref(true);
const wifiOn = ref(false);
const bluetoothOn = ref(true);
const airplaneModeOn = ref(false);
const locationOn = ref(true);

const customColorSwitch = ref(true);
const inactiveColorSwitch = ref(false);

const lastChange = ref('');
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Switch</h1>
      <p class="text-fg-secondary mb-6">iOS-style toggle switch control with smooth animations.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic Switch</h2>
        <p class="text-fg-secondary mb-4">Simple on/off toggle with default iOS green color.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="flex items-center justify-between p-4 bg-white rounded-lg">
            <div>
              <div class="font-semibold">Enable Feature</div>
              <div class="text-sm text-gray-600">Status: {{ basicSwitch ? 'On' : 'Off' }}</div>
            </div>
            <flutter-cupertino-switch
              :checked="basicSwitch"
              @change="
                (e) => {
                  basicSwitch = e.detail;
                  lastChange = `Basic switch: ${e.detail ? 'ON' : 'OFF'}`;
                }
              "
            />
          </div>
          <div v-if="lastChange" class="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last change: {{ lastChange }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Settings List Example</h2>
        <p class="text-fg-secondary mb-4">Multiple switches in a settings-style list.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg overflow-hidden divide-y divide-gray-200">
            <div class="flex items-center justify-between p-4">
              <div>
                <div class="font-semibold">Notifications</div>
                <div class="text-sm text-gray-600">Allow notifications and alerts</div>
              </div>
              <flutter-cupertino-switch
                :checked="notificationsOn"
                @change="
                  (e) => {
                    notificationsOn = e.detail;
                    lastChange = `Notifications: ${e.detail ? 'ON' : 'OFF'}`;
                  }
                "
              />
            </div>

            <div class="flex items-center justify-between p-4">
              <div>
                <div class="font-semibold">Wi‑Fi</div>
                <div class="text-sm text-gray-600">{{ wifiOn ? 'Connected to Home Network' : 'Not connected' }}</div>
              </div>
              <flutter-cupertino-switch
                :checked="wifiOn"
                @change="
                  (e) => {
                    wifiOn = e.detail;
                    lastChange = `Wi‑Fi: ${e.detail ? 'ON' : 'OFF'}`;
                  }
                "
              />
            </div>

            <div class="flex items-center justify-between p-4">
              <div>
                <div class="font-semibold">Bluetooth</div>
                <div class="text-sm text-gray-600">{{ bluetoothOn ? 'On' : 'Off' }}</div>
              </div>
              <flutter-cupertino-switch
                :checked="bluetoothOn"
                @change="
                  (e) => {
                    bluetoothOn = e.detail;
                    lastChange = `Bluetooth: ${e.detail ? 'ON' : 'OFF'}`;
                  }
                "
              />
            </div>

            <div class="flex items-center justify-between p-4">
              <div>
                <div class="font-semibold">Airplane Mode</div>
                <div class="text-sm text-gray-600">{{ airplaneModeOn ? 'Wireless services disabled' : 'All services active' }}</div>
              </div>
              <flutter-cupertino-switch
                :checked="airplaneModeOn"
                @change="
                  (e) => {
                    airplaneModeOn = e.detail;
                    lastChange = `Airplane Mode: ${e.detail ? 'ON' : 'OFF'}`;
                  }
                "
              />
            </div>

            <div class="flex items-center justify-between p-4">
              <div>
                <div class="font-semibold">Location Services</div>
                <div class="text-sm text-gray-600">{{ locationOn ? 'Apps can access location' : 'Location access disabled' }}</div>
              </div>
              <flutter-cupertino-switch
                :checked="locationOn"
                @change="
                  (e) => {
                    locationOn = e.detail;
                    lastChange = `Location: ${e.detail ? 'ON' : 'OFF'}`;
                  }
                "
              />
            </div>
          </div>
          <div v-if="lastChange" class="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last change: {{ lastChange }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Disabled State</h2>
        <p class="text-fg-secondary mb-4">Switches can be disabled to prevent user interaction.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <div class="flex items-center justify-between p-4 bg-white rounded-lg">
            <div>
              <div class="font-semibold text-gray-400">Disabled (Off)</div>
              <div class="text-sm text-gray-500">Cannot be toggled</div>
            </div>
            <flutter-cupertino-switch :checked="false" disabled />
          </div>
          <div class="flex items-center justify-between p-4 bg-white rounded-lg">
            <div>
              <div class="font-semibold text-gray-400">Disabled (On)</div>
              <div class="text-sm text-gray-500">Cannot be toggled</div>
            </div>
            <flutter-cupertino-switch :checked="true" disabled />
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Custom Colors</h2>
        <p class="text-fg-secondary mb-4">Customize active and inactive colors using hex values.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <div class="flex items-center justify-between p-4 bg-white rounded-lg">
            <div>
              <div class="font-semibold">Blue Active Color</div>
              <div class="text-sm text-gray-600">Custom #007AFF when on</div>
            </div>
            <flutter-cupertino-switch
              :checked="customColorSwitch"
              active-color="#007AFF"
              @change="
                (e) => {
                  customColorSwitch = e.detail;
                  lastChange = `Blue switch: ${e.detail ? 'ON' : 'OFF'}`;
                }
              "
            />
          </div>

          <div class="flex items-center justify-between p-4 bg-white rounded-lg">
            <div>
              <div class="font-semibold">Custom Inactive Color</div>
              <div class="text-sm text-gray-600">Inactive gray + orange active</div>
            </div>
            <flutter-cupertino-switch
              :checked="inactiveColorSwitch"
              active-color="#FF9500"
              inactive-color="#C7C7CC"
              @change="
                (e) => {
                  inactiveColorSwitch = e.detail;
                  lastChange = `Custom inactive: ${e.detail ? 'ON' : 'OFF'}`;
                }
              "
            />
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

