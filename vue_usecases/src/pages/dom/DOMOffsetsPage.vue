<script setup lang="ts">
import { ref } from 'vue';

const targetRef = ref<HTMLElement | null>(null);
const result = ref<any>(null);

function measure() {
  const el = targetRef.value;
  if (!el) return;
  const rect = el.getBoundingClientRect();
  result.value = {
    offsetWidth: el.offsetWidth,
    offsetHeight: el.offsetHeight,
    offsetTop: el.offsetTop,
    offsetLeft: el.offsetLeft,
    rect: { x: rect.x, y: rect.y, width: rect.width, height: rect.height },
  };
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">Offsets & Measurements</h1>
      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <div class="relative p-3 border border-dashed border-line rounded bg-surface">
          <div ref="targetRef" class="relative w-40 h-24 bg-emerald-100 border border-line rounded" />
        </div>
        <div class="mt-2">
          <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="measure">Measure</button>
        </div>
        <pre v-if="result" class="font-mono text-sm mt-2">{{ JSON.stringify(result, null, 2) }}</pre>
      </div>
    </webf-list-view>
  </div>
</template>
