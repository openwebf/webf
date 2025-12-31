<script setup lang="ts">
import { computed, ref } from 'vue';

function tryBtoa(input: string): string {
  try {
    return btoa(input);
  } catch (e: any) {
    return `Error: ${e?.message ?? e}`;
  }
}

function tryAtob(input: string): string {
  try {
    return atob(input);
  } catch (e: any) {
    return `Error: ${e?.message ?? e}`;
  }
}

const base = ref('https://www.example.com');
const path = ref('/path');
const query = ref('foo=bar&wd=Hello👿World');
const hash = ref('#section');

const url = computed(() => {
  try {
    const u = new URL(base.value);
    u.pathname = path.value || '/';
    u.search = '';
    if (query.value) {
      const usp = new URLSearchParams(query.value);
      u.search = usp.toString() ? `?${usp.toString()}` : '';
    }
    u.hash = hash.value || '';
    return u;
  } catch {
    return null;
  }
});

const plain = ref('Hello, WebF!');
const enc = computed(() => tryBtoa(plain.value));
const cipher = ref('SGVsbG8sIFdlYkYh');
const dec = computed(() => tryAtob(cipher.value));

const text = ref('🙂 café 你好');
const encoded = computed(() => Array.from(new TextEncoder().encode(text.value)));
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">URL &amp; Encoding</h1>
      <p class="text-fg-secondary mb-4">Demonstrations for URL, Base64 and TextEncoder.</p>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <h2 class="text-lg font-medium text-fg-primary mb-3">URL Builder</h2>
        <div class="space-y-3">
          <input v-model="base" class="w-full rounded border border-line px-3 py-2 bg-surface" />
          <input v-model="path" class="w-full rounded border border-line px-3 py-2 bg-surface" />
          <input v-model="query" class="w-full rounded border border-line px-3 py-2 bg-surface" />
          <input v-model="hash" class="w-full rounded border border-line px-3 py-2 bg-surface" />
        </div>
        <div class="mt-4">
          <div v-if="url" class="text-sm">
            <div class="mb-2"><span class="font-medium">href:</span> {{ url.href }}</div>
            <div class="flex flex-wrap -mx-2">
              <div class="w-full md:w-1/2 px-2 mb-1"><span class="font-medium">origin:</span> {{ url.origin }}</div>
              <div class="w-full md:w-1/2 px-2 mb-1"><span class="font-medium">host:</span> {{ url.host }}</div>
              <div class="w-full md:w-1/2 px-2 mb-1"><span class="font-medium">pathname:</span> {{ url.pathname }}</div>
              <div class="w-full md:w-1/2 px-2 mb-1"><span class="font-medium">search:</span> {{ url.search }}</div>
              <div class="w-full md:w-1/2 px-2 mb-1"><span class="font-medium">hash:</span> {{ url.hash }}</div>
            </div>
          </div>
          <div v-else class="text-sm text-red-600">Invalid URL</div>
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <h2 class="text-lg font-medium text-fg-primary mb-3">Base64</h2>
        <div class="md:flex md:space-x-3 space-y-3 md:space-y-0">
          <div class="flex-1">
            <label class="text-sm text-fg-secondary">Input</label>
            <input v-model="plain" class="w-full rounded border border-line px-3 py-2 bg-surface" />
            <div class="mt-2 text-sm break-all"><span class="font-medium">btoa:</span> {{ enc }}</div>
          </div>
          <div class="flex-1">
            <label class="text-sm text-fg-secondary">Base64</label>
            <input v-model="cipher" class="w-full rounded border border-line px-3 py-2 bg-surface" />
            <div class="mt-2 text-sm break-all"><span class="font-medium">atob:</span> {{ dec }}</div>
          </div>
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-3">TextEncoder (UTF-8)</h2>
        <input v-model="text" class="w-full rounded border border-line px-3 py-2 bg-surface" />
        <div class="mt-3 text-sm break-all">{{ JSON.stringify(encoded) }}</div>
      </div>
    </webf-list-view>
  </div>
</template>
