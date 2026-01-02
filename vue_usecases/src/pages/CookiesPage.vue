<script setup lang="ts">
import { computed, ref } from 'vue';

function setCookie(name: string, value: string, days?: number, path: string = '/') {
  let cookie = `${encodeURIComponent(name)}=${encodeURIComponent(value)}; path=${path}`;
  if (typeof days === 'number') {
    const d = new Date();
    d.setTime(d.getTime() + days * 24 * 60 * 60 * 1000);
    cookie += `; expires=${d.toUTCString()}`;
  }
  document.cookie = cookie;
}

function deleteCookie(name: string, path: string = '/') {
  document.cookie = `${encodeURIComponent(name)}=; path=${path}; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
}

function parseCookies(): Record<string, string> {
  return document.cookie
    .split(';')
    .map((c) => c.trim())
    .filter(Boolean)
    .reduce((acc, part) => {
      const eq = part.indexOf('=');
      if (eq >= 0) {
        const k = decodeURIComponent(part.slice(0, eq));
        const v = decodeURIComponent(part.slice(eq + 1));
        acc[k] = v;
      }
      return acc;
    }, {} as Record<string, string>);
}

const name = ref('name');
const value = ref('webf');
const days = ref('');
const path = ref('/');
const message = ref('');

const cookies = computed(() => {
  void message.value;
  return parseCookies();
});

const cookieEntries = computed(() => Object.entries(cookies.value));
const cookieString = computed(() => {
  void message.value;
  return document.cookie || '(empty)';
});

function onSet() {
  const trimmedName = name.value.trim();
  const d = days.value.trim() ? Number(days.value) : undefined;
  if (!trimmedName) return;
  setCookie(trimmedName, value.value, d, path.value || '/');
  message.value = `Set cookie ${trimmedName}`;
}

function onDelete() {
  const trimmedName = name.value.trim();
  if (!trimmedName) return;
  deleteCookie(trimmedName, path.value || '/');
  message.value = `Deleted cookie ${trimmedName}`;
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">Cookies</h1>
      <p class="text-fg-secondary mb-4">Read and write cookies via <code>document.cookie</code>.</p>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="flex flex-col md:flex-row md:space-x-3 space-y-3 md:space-y-0">
          <input
            v-model="name"
            class="flex-1 rounded border border-line px-3 py-2 bg-surface"
            placeholder="name"
          />
          <input
            v-model="value"
            class="flex-1 rounded border border-line px-3 py-2 bg-surface"
            placeholder="value"
          />
        </div>
        <div class="mt-3 flex flex-col md:flex-row md:space-x-3 space-y-3 md:space-y-0">
          <input
            v-model="days"
            class="w-full md:w-40 rounded border border-line px-3 py-2 bg-surface"
            placeholder="days (optional)"
          />
          <input
            v-model="path"
            class="w-full md:w-40 rounded border border-line px-3 py-2 bg-surface"
            placeholder="path"
          />
        </div>
        <div class="mt-4 flex space-x-2">
          <button class="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700" @click="onSet">Set</button>
          <button class="px-4 py-2 rounded border border-line hover:bg-surface-hover" @click="onDelete">Delete</button>
        </div>
        <div v-if="message" class="mt-3 text-sm text-fg-secondary">{{ message }}</div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-2">Current Cookies</h2>
        <div class="text-sm text-fg-secondary break-all mb-3">{{ cookieString }}</div>
        <div class="overflow-auto rounded border border-line">
          <table class="w-full text-sm">
            <thead class="bg-surface-tertiary">
              <tr>
                <th class="text-left px-3 py-2 border-b border-line">Name</th>
                <th class="text-left px-3 py-2 border-b border-line">Value</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="cookieEntries.length === 0">
                <td class="px-3 py-2" :colspan="2">No cookies</td>
              </tr>
              <tr v-for="[k, v] in cookieEntries" :key="k" class="odd:bg-surface">
                <td class="px-3 py-2 border-b border-line align-top">{{ k }}</td>
                <td class="px-3 py-2 border-b border-line align-top">{{ v }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
