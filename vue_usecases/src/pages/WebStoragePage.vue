<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';

interface StorageItem {
  key: string;
  value: string;
  size: number;
  timestamp: string;
}

const localStorageItems = ref<StorageItem[]>([]);
const sessionStorageItems = ref<StorageItem[]>([]);

const newKey = ref('');
const newValue = ref('');
const storageType = ref<'local' | 'session'>('local');
const searchTerm = ref('');

function formatBytes(bytes: number) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`;
}

function formatValue(value: string) {
  try {
    const parsed = JSON.parse(value);
    return JSON.stringify(parsed, null, 2);
  } catch {
    return value;
  }
}

function loadStorageItems() {
  const localItems: StorageItem[] = [];
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (!key) continue;
    const value = localStorage.getItem(key) || '';
    localItems.push({
      key,
      value,
      size: new Blob([value]).size,
      timestamp: new Date().toLocaleString(),
    });
  }
  localStorageItems.value = localItems.sort((a, b) => a.key.localeCompare(b.key));

  const sessionItems: StorageItem[] = [];
  for (let i = 0; i < sessionStorage.length; i++) {
    const key = sessionStorage.key(i);
    if (!key) continue;
    const value = sessionStorage.getItem(key) || '';
    sessionItems.push({
      key,
      value,
      size: new Blob([value]).size,
      timestamp: new Date().toLocaleString(),
    });
  }
  sessionStorageItems.value = sessionItems.sort((a, b) => a.key.localeCompare(b.key));
}

function addStorageItem() {
  const key = newKey.value.trim();
  if (!key) return;
  const storage = storageType.value === 'local' ? localStorage : sessionStorage;
  storage.setItem(key, newValue.value);
  newKey.value = '';
  newValue.value = '';
  loadStorageItems();
}

function removeStorageItem(key: string, type: 'local' | 'session') {
  const storage = type === 'local' ? localStorage : sessionStorage;
  storage.removeItem(key);
  loadStorageItems();
}

function clearStorage(type: 'local' | 'session') {
  const storage = type === 'local' ? localStorage : sessionStorage;
  storage.clear();
  loadStorageItems();
}

function generateSampleData() {
  const samples = [
    { key: 'user_preferences', value: '{"theme":"dark","language":"en","notifications":true}' },
    { key: 'cart_items', value: '[{"id":1,"name":"Laptop","price":999},{"id":2,"name":"Mouse","price":25}]' },
    { key: 'last_visited', value: new Date().toISOString() },
    { key: 'app_version', value: '1.2.3' },
    { key: 'feature_flags', value: '{"newUI":true,"betaFeatures":false,"analytics":true}' },
  ];

  const storage = storageType.value === 'local' ? localStorage : sessionStorage;
  for (const sample of samples) storage.setItem(sample.key, sample.value);
  loadStorageItems();
}

function filterItems(items: StorageItem[]) {
  const term = searchTerm.value.trim().toLowerCase();
  if (!term) return items;
  return items.filter((item) => item.key.toLowerCase().includes(term) || item.value.toLowerCase().includes(term));
}

const filteredLocal = computed(() => filterItems(localStorageItems.value));
const filteredSession = computed(() => filterItems(sessionStorageItems.value));

const localUsage = computed(() => {
  const totalSize = localStorageItems.value.reduce((sum, item) => sum + item.size, 0);
  return { count: localStorageItems.value.length, size: totalSize, sizeFormatted: formatBytes(totalSize) };
});

const sessionUsage = computed(() => {
  const totalSize = sessionStorageItems.value.reduce((sum, item) => sum + item.size, 0);
  return { count: sessionStorageItems.value.length, size: totalSize, sizeFormatted: formatBytes(totalSize) };
});

onMounted(() => loadStorageItems());
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">Web Storage</h1>
      <p class="text-fg-secondary mb-6">Add, inspect, search, and remove key-value pairs from localStorage and sessionStorage.</p>

      <div class="flex flex-col gap-4">
        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">Add Item</div>
          <div class="text-sm text-fg-secondary mb-3">Add key-value pairs to localStorage or sessionStorage</div>

          <div class="space-y-3">
            <div class="flex gap-2 flex-wrap">
              <button
                class="px-3 py-1.5 rounded border border-line"
                :class="storageType === 'local' ? 'bg-black text-white' : 'hover:bg-surface-hover'"
                @click="storageType = 'local'"
              >
                localStorage
              </button>
              <button
                class="px-3 py-1.5 rounded border border-line"
                :class="storageType === 'session' ? 'bg-black text-white' : 'hover:bg-surface-hover'"
                @click="storageType = 'session'"
              >
                sessionStorage
              </button>
            </div>
            <div class="flex gap-2 flex-wrap">
              <input
                v-model="newKey"
                type="text"
                placeholder="Enter key..."
                class="rounded border border-line px-3 py-2 bg-surface flex-1 min-w-[200px]"
              />
              <input
                v-model="newValue"
                type="text"
                placeholder="Enter value..."
                class="rounded border border-line px-3 py-2 bg-surface flex-1 min-w-[200px]"
              />
            </div>
            <div class="flex gap-2 flex-wrap">
              <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="addStorageItem">Add Item</button>
              <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="generateSampleData">
                Generate Sample Data
              </button>
              <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="loadStorageItems">Refresh</button>
            </div>
          </div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">Search</div>
          <div class="text-sm text-fg-secondary mb-3">Search through stored keys and values</div>
          <div>
            <input v-model="searchTerm" type="text" placeholder="Search keys and values..." class="w-full rounded border border-line px-3 py-2 bg-surface" />
            <div v-if="searchTerm" class="flex items-center justify-between text-sm text-fg-secondary mt-2 gap-3">
              <div>
                Found {{ filteredLocal.length }} items in localStorage, {{ filteredSession.length }} items in sessionStorage
              </div>
              <button class="px-3 py-1.5 rounded border border-line hover:bg-surface-hover" @click="searchTerm = ''">Clear</button>
            </div>
          </div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">localStorage</div>
          <div class="text-sm text-fg-secondary mb-3">{{ localUsage.count }} items • {{ localUsage.sizeFormatted }}</div>
          <div class="flex justify-end">
            <button class="px-3 py-1.5 rounded border border-line hover:bg-surface-hover" @click="clearStorage('local')">Clear All</button>
          </div>

          <div class="mt-3 space-y-2">
            <div v-if="filteredLocal.length === 0" class="text-sm text-fg-secondary border border-dashed border-line rounded p-3">
              {{ localStorageItems.length === 0 ? 'No items stored' : 'No items match your search' }}
            </div>
            <div v-for="item in filteredLocal" :key="item.key" class="rounded border border-line bg-surface p-3">
              <div class="flex items-start gap-3">
                <div class="flex-1">
                  <div class="font-mono text-sm break-all">{{ item.key }}</div>
                  <div class="text-xs text-fg-secondary mt-1">Size: {{ formatBytes(item.size) }} • Loaded: {{ item.timestamp }}</div>
                </div>
                <button class="px-3 py-1.5 rounded border border-line hover:bg-surface-hover" @click="removeStorageItem(item.key, 'local')">
                  Remove
                </button>
              </div>
              <pre class="m-0 mt-2 rounded bg-surface-secondary p-3 text-xs overflow-auto whitespace-pre-wrap">{{ formatValue(item.value) }}</pre>
            </div>
          </div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">sessionStorage</div>
          <div class="text-sm text-fg-secondary mb-3">{{ sessionUsage.count }} items • {{ sessionUsage.sizeFormatted }}</div>
          <div class="flex justify-end">
            <button class="px-3 py-1.5 rounded border border-line hover:bg-surface-hover" @click="clearStorage('session')">Clear All</button>
          </div>

          <div class="mt-3 space-y-2">
            <div v-if="filteredSession.length === 0" class="text-sm text-fg-secondary border border-dashed border-line rounded p-3">
              {{ sessionStorageItems.length === 0 ? 'No items stored' : 'No items match your search' }}
            </div>
            <div v-for="item in filteredSession" :key="item.key" class="rounded border border-line bg-surface p-3">
              <div class="flex items-start gap-3">
                <div class="flex-1">
                  <div class="font-mono text-sm break-all">{{ item.key }}</div>
                  <div class="text-xs text-fg-secondary mt-1">Size: {{ formatBytes(item.size) }} • Loaded: {{ item.timestamp }}</div>
                </div>
                <button class="px-3 py-1.5 rounded border border-line hover:bg-surface-hover" @click="removeStorageItem(item.key, 'session')">
                  Remove
                </button>
              </div>
              <pre class="m-0 mt-2 rounded bg-surface-secondary p-3 text-xs overflow-auto whitespace-pre-wrap">{{ formatValue(item.value) }}</pre>
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
