<script setup lang="ts">
import { onMounted, ref, watch } from 'vue';

const input = ref('<b>Hello</b> & <i>World</i>');
const textRef = ref<HTMLElement | null>(null);

function syncTextContent() {
  if (!textRef.value) return;
  textRef.value.textContent = input.value;
}

watch(input, () => syncTextContent());
onMounted(() => syncTextContent());
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">innerHTML vs textContent</h1>
      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <input v-model="input" class="w-full rounded border border-line px-3 py-2 bg-surface" />
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mt-2">
          <div class="border border-line rounded bg-surface p-2">
            <div class="font-semibold mb-1">innerHTML</div>
            <div v-html="input" />
          </div>
          <div class="border border-line rounded bg-surface p-2">
            <div class="font-semibold mb-1">textContent</div>
            <div ref="textRef" />
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
