<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue';

const touchAreaRef = ref<HTMLElement | null>(null);
const customRef = ref<HTMLElement | null>(null);

const log = ref<string[]>([]);
const isLogCollapsed = ref(false);

function push(s: string) {
  log.value = [new Date().toLocaleTimeString() + ' ' + s, ...log.value].slice(0, 50);
}

function getRelative(evt: TouchEvent) {
  const el = touchAreaRef.value;
  const t = (evt.touches && evt.touches[0]) || (evt.changedTouches && evt.changedTouches[0]);
  if (!el || !t) return { x: 0, y: 0 };
  const rect = el.getBoundingClientRect();
  return { x: Math.round(t.clientX - rect.left), y: Math.round(t.clientY - rect.top) };
}

function dispatchCustom() {
  const ev = new CustomEvent('my-event', { detail: { hello: 'world' } });
  customRef.value?.dispatchEvent(ev);
}

function clearLog() {
  log.value = [];
}

let removeCustomListener: (() => void) | null = null;

onMounted(() => {
  const el = customRef.value;
  if (!el) return;
  const onCustom = () => push('CustomEvent received: my-event');
  el.addEventListener('my-event', onCustom as EventListener);
  removeCustomListener = () => el.removeEventListener('my-event', onCustom as EventListener);
});

onBeforeUnmount(() => {
  removeCustomListener?.();
  removeCustomListener = null;
});
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6 pb-40">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">DOM Events</h1>

      <webf-toucharea
        ref="touchAreaRef"
        class="bg-surface-secondary border border-line rounded-xl p-4 mb-6"
        @touchstart="
          (e) => {
            const { x, y } = getRelative(e);
            push(`touchstart @(${x},${y})`);
          }
        "
        @touchmove="
          (e) => {
            const { x, y } = getRelative(e);
            push(`touchmove @(${x},${y})`);
          }
        "
        @touchend="
          (e) => {
            const { x, y } = getRelative(e);
            push(`touchend @(${x},${y})`);
          }
        "
        @touchcancel="() => push('touchcancel')"
      >
        <h2 class="text-lg font-medium text-fg-primary mb-2">Touch Events</h2>
        <div class="w-56 h-28 border border-dashed border-line rounded-md bg-surface flex items-center justify-center text-fg-secondary select-none">
          Touch / Drag Here
        </div>
      </webf-toucharea>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <h2 class="text-lg font-medium text-fg-primary mb-2">Scroll Events</h2>
        <div class="w-56 h-28 border border-dashed border-line rounded-md bg-surface overflow-auto" @scroll="(e) => push('scroll: ' + (e.target as HTMLDivElement).scrollTop)">
          <div class="h-[300px] p-2">Scrollable content</div>
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <h2 class="text-lg font-medium text-fg-primary mb-2">CustomEvent</h2>
        <div ref="customRef" class="w-56 h-28 border border-dashed border-line rounded-md bg-surface flex items-center justify-center">Listen: my-event</div>
        <div class="mt-2">
          <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="dispatchCustom">Dispatch my-event</button>
        </div>
      </div>
    </webf-list-view>

    <div class="fixed bottom-0 left-0 right-0 z-50">
      <div class="max-w-3xl mx-auto px-3 md:px-6">
        <div class="bg-surface-secondary border border-line rounded-t-xl shadow-xl">
          <div class="flex items-center justify-between p-3">
            <div class="text-lg font-medium text-fg-primary">Event Log</div>
            <div class="flex items-center gap-2">
              <button class="px-3 py-1.5 rounded bg-black text-white hover:bg-neutral-700 text-sm" @click="clearLog">Clear</button>
              <button
                class="px-3 py-1.5 rounded border border-line bg-white hover:bg-neutral-50 text-sm"
                :aria-expanded="!isLogCollapsed"
                aria-controls="event-log-panel"
                @click="isLogCollapsed = !isLogCollapsed"
              >
                {{ isLogCollapsed ? 'Expand' : 'Fold' }}
              </button>
            </div>
          </div>
          <div
            id="event-log-panel"
            class="border-t border-line rounded-b-xl overflow-hidden transition-all duration-300 ease-in-out"
            :class="isLogCollapsed ? 'max-h-0 opacity-0' : 'max-h-[24vh] opacity-100'"
          >
            <div class="bg-surface p-3 overflow-y-auto max-h-[24vh] text-sm font-mono">
              <div v-if="log.length === 0" class="text-center text-fg-secondary italic py-6">No events yet</div>
              <div v-else>
                <div v-for="(l, i) in log" :key="i" class="py-0.5">{{ l }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
