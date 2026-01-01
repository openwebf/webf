<script setup lang="ts">
import { nextTick, onMounted, ref } from 'vue';

const boxRef = ref<HTMLElement | null>(null);
const classes = ref('');
const isRed = ref(false);
const isRounded = ref(false);
const isActive = ref(false);

function sync() {
  classes.value = boxRef.value?.className ?? '';
}

async function toggleRed() {
  isRed.value = !isRed.value;
  await nextTick();
  sync();
}

async function toggleRounded() {
  isRounded.value = !isRounded.value;
  await nextTick();
  sync();
}

async function toggleActive() {
  isActive.value = !isActive.value;
  await nextTick();
  sync();
}

onMounted(() => {
  sync();
});
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">DOMTokenList (classList)</h1>
      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <div
          ref="boxRef"
          class="w-40 h-20 border border-line rounded flex items-center justify-center"
          :class="[isRed ? 'bg-red-200' : '', isRounded ? 'rounded-2xl' : '', isActive ? 'ring-2 ring-sky-400' : '']"
        >
          target
        </div>
        <div class="flex gap-2 flex-wrap items-center mt-2">
          <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="toggleRed">toggle red</button>
          <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="toggleRounded">toggle rounded</button>
          <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="toggleActive">toggle active</button>
        </div>
        <div class="font-mono text-sm mt-2">className: {{ classes }}</div>
      </div>
    </webf-list-view>
  </div>
</template>
