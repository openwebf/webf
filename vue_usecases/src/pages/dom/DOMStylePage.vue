<script setup lang="ts">
import { computed, ref } from 'vue';

const bg = ref('#93c5fd');
const w = ref(140);
const transform = ref('rotate(0deg)');

const boxStyle = computed(() => ({
  background: bg.value,
  width: w.value,
  transform: transform.value,
}));
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">element.style</h1>
      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <div class="flex gap-2 flex-wrap items-center">
          <label class="text-sm"
            >background
            <input v-model="bg" class="ml-1 rounded border border-line px-2 py-1 bg-surface" />
          </label>
          <label class="text-sm"
            >width(px)
            <input v-model.number="w" type="number" class="ml-1 rounded border border-line px-2 py-1 bg-surface" />
          </label>
          <label class="text-sm"
            >transform
            <input v-model="transform" class="ml-1 rounded border border-line px-2 py-1 bg-surface" />
          </label>
        </div>
        <div class="mt-3">
          <div class="h-20 border border-line rounded bg-gray-200 flex items-center justify-center" :style="boxStyle">target</div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
