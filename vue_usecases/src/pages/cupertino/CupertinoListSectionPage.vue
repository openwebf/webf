<script setup lang="ts">
import { ref } from 'vue';
import { CupertinoIcons } from '@openwebf/vue-cupertino-ui';

const autoDownloads = ref(true);
const backgroundRefresh = ref(false);
const darkMode = ref(false);
const allowNotifications = ref(true);
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino List Section</h1>
      <p class="text-fg-secondary mb-6">iOS-style grouped list sections with headers and footers.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic List Section</h2>
        <p class="text-fg-secondary mb-4">Simple grouped list section without header or footer.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <flutter-cupertino-list-section>
            <div class="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer">
              <div class="font-semibold">Item 1</div>
              <div class="text-sm text-gray-600">Description for item 1</div>
            </div>
            <div class="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer">
              <div class="font-semibold">Item 2</div>
              <div class="text-sm text-gray-600">Description for item 2</div>
            </div>
            <div class="bg-white p-4 hover:bg-gray-50 cursor-pointer">
              <div class="font-semibold">Item 3</div>
              <div class="text-sm text-gray-600">Description for item 3</div>
            </div>
          </flutter-cupertino-list-section>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">With Header</h2>
        <p class="text-fg-secondary mb-4">List section with a header label.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <flutter-cupertino-list-section>
            <flutter-cupertino-list-section-header>
              <div class="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">General Settings</div>
            </flutter-cupertino-list-section-header>
            <div class="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
              <span class="font-medium">Wi‑Fi</span>
              <span class="text-gray-500">Home Network →</span>
            </div>
            <div class="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
              <span class="font-medium">Bluetooth</span>
              <span class="text-gray-500">On →</span>
            </div>
            <div class="bg-white p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
              <span class="font-medium">Cellular</span>
              <span class="text-gray-500">→</span>
            </div>
          </flutter-cupertino-list-section>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">With Footer</h2>
        <p class="text-fg-secondary mb-4">List section with explanatory footer text.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <flutter-cupertino-list-section>
            <div class="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
              <span class="font-medium">Privacy</span>
              <span class="text-gray-500">→</span>
            </div>
            <div class="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
              <span class="font-medium">Location Services</span>
              <span class="text-gray-500">While Using →</span>
            </div>
            <div class="bg-white p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
              <span class="font-medium">Tracking</span>
              <span class="text-gray-500">Ask Apps Not to Track →</span>
            </div>
            <flutter-cupertino-list-section-footer>
              <div class="px-4 py-2 text-sm text-gray-600">
                These settings help protect your personal information and give you control over how apps use your data.
              </div>
            </flutter-cupertino-list-section-footer>
          </flutter-cupertino-list-section>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Inset Grouped Style</h2>
        <p class="text-fg-secondary mb-4">iOS Settings-style inset sections with rounded corners.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-6">
          <flutter-cupertino-list-section :inset-grouped="true">
            <flutter-cupertino-list-section-header>
              <div class="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">Account</div>
            </flutter-cupertino-list-section-header>
            <div class="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex items-center gap-3">
              <div class="w-12 h-12 bg-blue-500 rounded-full flex items-center justify-center text-white font-semibold">JD</div>
              <div class="flex-1">
                <div class="font-semibold">John Doe</div>
                <div class="text-sm text-gray-600">Apple ID, iCloud, Media & Purchases</div>
              </div>
              <span class="text-gray-400">→</span>
            </div>
          </flutter-cupertino-list-section>

          <flutter-cupertino-list-section :inset-grouped="true">
            <flutter-cupertino-list-section-header>
              <div class="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">Devices</div>
            </flutter-cupertino-list-section-header>
            <div class="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex items-center gap-3">
              <span class="text-2xl"><flutter-cupertino-icon :type="CupertinoIcons.device_phone_portrait" /></span>
              <span class="flex-1 font-medium">iPhone</span>
              <span class="text-gray-400">→</span>
            </div>
            <div class="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex items-center gap-3">
              <span class="text-2xl"><flutter-cupertino-icon :type="CupertinoIcons.device_laptop" /></span>
              <span class="flex-1 font-medium">MacBook</span>
              <span class="text-gray-400">→</span>
            </div>
            <div class="bg-white p-4 hover:bg-gray-50 cursor-pointer flex items-center gap-3">
              <span class="text-2xl"><flutter-cupertino-icon :type="CupertinoIcons.stopwatch_fill" /></span>
              <span class="flex-1 font-medium">Apple Watch</span>
              <span class="text-gray-400">→</span>
            </div>
          </flutter-cupertino-list-section>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Settings Controls</h2>
        <p class="text-fg-secondary mb-4">Combine list sections with native Cupertino controls.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <flutter-cupertino-list-section :inset-grouped="true">
            <flutter-cupertino-list-section-header>
              <div class="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">Preferences</div>
            </flutter-cupertino-list-section-header>

            <div class="bg-white border-b border-gray-200 p-4 flex items-center justify-between">
              <div>
                <div class="font-semibold">Automatic Downloads</div>
                <div class="text-sm text-gray-600">{{ autoDownloads ? 'Enabled' : 'Disabled' }}</div>
              </div>
              <flutter-cupertino-switch :checked="autoDownloads" @change="(e) => (autoDownloads = e.detail)" />
            </div>

            <div class="bg-white border-b border-gray-200 p-4 flex items-center justify-between">
              <div>
                <div class="font-semibold">Background Refresh</div>
                <div class="text-sm text-gray-600">{{ backgroundRefresh ? 'On' : 'Off' }}</div>
              </div>
              <flutter-cupertino-switch :checked="backgroundRefresh" @change="(e) => (backgroundRefresh = e.detail)" />
            </div>

            <div class="bg-white border-b border-gray-200 p-4 flex items-center justify-between">
              <div>
                <div class="font-semibold">Dark Mode</div>
                <div class="text-sm text-gray-600">{{ darkMode ? 'On' : 'Off' }}</div>
              </div>
              <flutter-cupertino-switch :checked="darkMode" @change="(e) => (darkMode = e.detail)" />
            </div>

            <div class="bg-white p-4 flex items-center justify-between">
              <div>
                <div class="font-semibold">Notifications</div>
                <div class="text-sm text-gray-600">{{ allowNotifications ? 'Allowed' : 'Blocked' }}</div>
              </div>
              <flutter-cupertino-switch :checked="allowNotifications" @change="(e) => (allowNotifications = e.detail)" />
            </div>
          </flutter-cupertino-list-section>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

