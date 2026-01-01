<script setup lang="ts">
import { computed, ref } from 'vue';
import type { FlutterCupertinoSearchTextFieldElement } from '@openwebf/vue-cupertino-ui';

const query = ref('');
const settingsQuery = ref('');
const logQuery = ref('');
const eventLog = ref<string[]>([]);

const searchRef = ref<FlutterCupertinoSearchTextFieldElement | null>(null);

const settingsItems = [
  'Wi‑Fi',
  'Bluetooth',
  'Mobile Data',
  'Personal Hotspot',
  'Notifications',
  'Sounds & Haptics',
  'Focus',
  'Screen Time',
  'General',
  'Control Center',
  'Display & Brightness',
  'Home Screen',
];

const filteredSettings = computed(() => {
  const term = settingsQuery.value.toLowerCase();
  return settingsItems.filter((item) => item.toLowerCase().includes(term));
});

function addEventLog(message: string) {
  eventLog.value = [message, ...eventLog.value].slice(0, 5);
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Search Text Field</h1>
      <p class="text-fg-secondary mb-6">iOS-style search field backed by Flutter's <code>CupertinoSearchTextField</code>.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-4 space-y-3">
            <flutter-cupertino-search-text-field :val="query" placeholder="Search" @input="(e) => (query = e.detail)" />
            <div class="text-sm text-fg-secondary">Current query: <span class="font-mono">{{ query || '(empty)' }}</span></div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Settings Search</h2>
        <p class="text-fg-secondary mb-4">Filter a settings list using the search field.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-4 space-y-3">
            <div class="text-sm font-semibold text-fg-primary">Enabled</div>
            <flutter-cupertino-search-text-field :val="settingsQuery" placeholder="Search settings" @input="(e) => (settingsQuery = e.detail)" />
            <div class="text-xs text-fg-secondary">
              Showing results for: <span class="font-mono">{{ settingsQuery || '(all)' }}</span>
            </div>
            <div class="mt-2 border-t border-line pt-3 space-y-1 max-h-52 overflow-y-auto">
              <div
                v-for="item in filteredSettings"
                :key="item"
                class="text-sm text-fg-primary px-2 py-1 rounded hover:bg-surface-hover cursor-pointer"
              >
                {{ item }}
              </div>
              <div v-if="filteredSettings.length === 0" class="text-xs text-fg-secondary px-2 py-1">No results found</div>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Events</h2>
        <p class="text-fg-secondary mb-4">Listen to input/submit/focus/blur/clear.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-4 space-y-3">
            <flutter-cupertino-search-text-field
              :val="logQuery"
              placeholder="Type and press Enter / clear"
              @input="
                (e) => {
                  logQuery = e.detail;
                  addEventLog(`input: ${e.detail}`);
                }
              "
              @submit="(e) => addEventLog(`submit: ${e.detail}`)"
              @focus="() => addEventLog('focus')"
              @blur="() => addEventLog('blur')"
              @clear="
                () => {
                  logQuery = '';
                  addEventLog('clear');
                }
              "
            />

            <div v-if="eventLog.length" class="mt-2 p-3 bg-gray-50 rounded-lg">
              <div class="text-sm font-semibold mb-2">Event Log (last 5)</div>
              <div class="space-y-1">
                <div v-for="(line, idx) in eventLog" :key="idx" class="text-xs font-mono text-gray-700">{{ line }}</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Imperative API</h2>
        <p class="text-fg-secondary mb-4">Use a ref to call <code>focus()</code>, <code>blur()</code>, <code>clear()</code>.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-4 space-y-3">
            <flutter-cupertino-search-text-field ref="searchRef" placeholder="Imperative control" />
            <div class="flex flex-wrap gap-2">
              <button class="px-3 py-1.5 text-sm rounded-lg bg-blue-500 text-white hover:bg-blue-600 transition-colors" @click="searchRef?.focus()">Focus</button>
              <button class="px-3 py-1.5 text-sm rounded-lg bg-gray-200 text-gray-800 hover:bg-gray-300 transition-colors" @click="searchRef?.blur()">Blur</button>
              <button class="px-3 py-1.5 text-sm rounded-lg bg-red-500 text-white hover:bg-red-600 transition-colors" @click="searchRef?.clear()">Clear</button>
            </div>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

