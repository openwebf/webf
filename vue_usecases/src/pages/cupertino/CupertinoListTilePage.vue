<script setup lang="ts">
import { ref } from 'vue';
import { CupertinoIcons } from '@openwebf/vue-cupertino-ui';

const wifiEnabled = ref(true);
const bluetoothEnabled = ref(false);
const notificationsEnabled = ref(true);

const eventLog = ref<string[]>([]);
function addEventLog(message: string) {
  eventLog.value = [message, ...eventLog.value].slice(0, 5);
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino List Tile</h1>
      <p class="text-fg-secondary mb-6">iOS-style list rows for settings pages, menus, and navigation lists.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic List Tile</h2>
        <p class="text-fg-secondary mb-4">Title + optional additional info + chevron.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg overflow-hidden">
            <flutter-cupertino-list-section>
              <flutter-cupertino-list-tile show-chevron @click="addEventLog('Clicked Wi‑Fi tile')">
                Wi‑Fi
                <flutter-cupertino-list-tile-additional-info>HomeNetwork</flutter-cupertino-list-tile-additional-info>
              </flutter-cupertino-list-tile>
              <flutter-cupertino-list-tile show-chevron @click="addEventLog('Clicked Bluetooth tile')">
                Bluetooth
                <flutter-cupertino-list-tile-additional-info>Off</flutter-cupertino-list-tile-additional-info>
              </flutter-cupertino-list-tile>
              <flutter-cupertino-list-tile show-chevron @click="addEventLog('Clicked Cellular tile')">
                Cellular
                <flutter-cupertino-list-tile-additional-info>T‑Mobile</flutter-cupertino-list-tile-additional-info>
              </flutter-cupertino-list-tile>
            </flutter-cupertino-list-section>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Leading Icon</h2>
        <p class="text-fg-secondary mb-4">Use the dedicated leading slot element.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg overflow-hidden">
            <flutter-cupertino-list-section>
              <flutter-cupertino-list-tile show-chevron @click="addEventLog('Clicked Phone')">
                <flutter-cupertino-list-tile-leading>
                  <div class="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                    <flutter-cupertino-icon :type="CupertinoIcons.phone_fill" />
                  </div>
                </flutter-cupertino-list-tile-leading>
                Phone
              </flutter-cupertino-list-tile>

              <flutter-cupertino-list-tile show-chevron @click="addEventLog('Clicked Messages')">
                <flutter-cupertino-list-tile-leading>
                  <div class="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white text-sm">
                    <flutter-cupertino-icon :type="CupertinoIcons.bubble_left_bubble_right_fill" />
                  </div>
                </flutter-cupertino-list-tile-leading>
                Messages
                <flutter-cupertino-list-tile-additional-info>3 new</flutter-cupertino-list-tile-additional-info>
              </flutter-cupertino-list-tile>

              <flutter-cupertino-list-tile show-chevron @click="addEventLog('Clicked Settings')">
                <flutter-cupertino-list-tile-leading>
                  <div class="w-8 h-8 rounded-full bg-purple-500 flex items-center justify-center text-white text-sm">
                    <flutter-cupertino-icon :type="CupertinoIcons.gear_alt_fill" />
                  </div>
                </flutter-cupertino-list-tile-leading>
                Settings
              </flutter-cupertino-list-tile>
            </flutter-cupertino-list-section>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Subtitle + Custom Trailing</h2>
        <p class="text-fg-secondary mb-4">Use subtitle + trailing for switches and badges.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg overflow-hidden">
            <flutter-cupertino-list-section>
              <flutter-cupertino-list-tile @click="addEventLog('Clicked Wi‑Fi (tile)')">
                <flutter-cupertino-list-tile-leading>
                  <div class="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                    <flutter-cupertino-icon :type="CupertinoIcons.wifi" />
                  </div>
                </flutter-cupertino-list-tile-leading>
                Wi‑Fi
                <flutter-cupertino-list-tile-subtitle>
                  {{ wifiEnabled ? 'Connected to HomeNetwork' : 'Not connected' }}
                </flutter-cupertino-list-tile-subtitle>
                <flutter-cupertino-list-tile-trailing>
                  <flutter-cupertino-switch
                    :checked="wifiEnabled"
                    @change="
                      (e) => {
                        wifiEnabled = e.detail;
                        addEventLog(`Wi‑Fi toggled: ${e.detail ? 'ON' : 'OFF'}`);
                      }
                    "
                  />
                </flutter-cupertino-list-tile-trailing>
              </flutter-cupertino-list-tile>

              <flutter-cupertino-list-tile>
                <flutter-cupertino-list-tile-leading>
                  <div class="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-white text-sm">
                    <flutter-cupertino-icon :type="CupertinoIcons.bluetooth" />
                  </div>
                </flutter-cupertino-list-tile-leading>
                Bluetooth
                <flutter-cupertino-list-tile-subtitle>{{ bluetoothEnabled ? 'On' : 'Off' }}</flutter-cupertino-list-tile-subtitle>
                <flutter-cupertino-list-tile-trailing>
                  <flutter-cupertino-switch
                    :checked="bluetoothEnabled"
                    @change="
                      (e) => {
                        bluetoothEnabled = e.detail;
                        addEventLog(`Bluetooth toggled: ${e.detail ? 'ON' : 'OFF'}`);
                      }
                    "
                  />
                </flutter-cupertino-list-tile-trailing>
              </flutter-cupertino-list-tile>

              <flutter-cupertino-list-tile show-chevron @click="addEventLog('Clicked Mail')">
                <flutter-cupertino-list-tile-leading>
                  <div class="w-8 h-8 rounded-full bg-red-500 flex items-center justify-center text-white text-sm">
                    <flutter-cupertino-icon :type="CupertinoIcons.mail_solid" />
                  </div>
                </flutter-cupertino-list-tile-leading>
                Mail
                <flutter-cupertino-list-tile-trailing>
                  <span class="bg-red-500 text-white text-xs font-semibold px-2 py-1 rounded-full">12</span>
                </flutter-cupertino-list-tile-trailing>
              </flutter-cupertino-list-tile>

              <flutter-cupertino-list-tile>
                <flutter-cupertino-list-tile-leading>
                  <div class="w-8 h-8 rounded-full bg-green-600 flex items-center justify-center text-white text-sm">
                    <flutter-cupertino-icon :type="CupertinoIcons.bell_fill" />
                  </div>
                </flutter-cupertino-list-tile-leading>
                Notifications
                <flutter-cupertino-list-tile-subtitle>Push, email, and SMS notifications</flutter-cupertino-list-tile-subtitle>
                <flutter-cupertino-list-tile-additional-info>{{ notificationsEnabled ? 'On' : 'Off' }}</flutter-cupertino-list-tile-additional-info>
                <flutter-cupertino-list-tile-trailing>
                  <flutter-cupertino-switch
                    :checked="notificationsEnabled"
                    @change="
                      (e) => {
                        notificationsEnabled = e.detail;
                        addEventLog(`Notifications toggled: ${e.detail ? 'ON' : 'OFF'}`);
                      }
                    "
                  />
                </flutter-cupertino-list-tile-trailing>
              </flutter-cupertino-list-tile>
            </flutter-cupertino-list-section>
          </div>
        </div>

        <div v-if="eventLog.length" class="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <div class="text-sm font-semibold mb-2">Event Log (last 5)</div>
          <div class="space-y-1">
            <div v-for="(line, idx) in eventLog" :key="idx" class="text-xs font-mono text-gray-700">{{ line }}</div>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

