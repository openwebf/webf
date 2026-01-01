<script setup lang="ts">
import { onMounted, ref } from 'vue';

type RectData = {
  x: number;
  y: number;
  width: number;
  height: number;
  top: number;
  right: number;
  bottom: number;
  left: number;
};

const currentRect = ref<RectData | null>(null);
const currentElement = ref('');

const boxRef = ref<HTMLElement | null>(null);
const textRef = ref<HTMLElement | null>(null);
const imageRef = ref<HTMLImageElement | null>(null);

const boxPosition = ref({ x: 50, y: 120 });

const WRAP_H = 180;
const BOX_H = 64;
const MAX_TOP = WRAP_H - BOX_H - 10;
const MIN_TOP = 32;

function round2(n: number) {
  return Math.round(n * 100) / 100;
}

function measureElement(el: HTMLElement | null, elementName: string) {
  if (!el) return;
  const rect = el.getBoundingClientRect();
  currentRect.value = {
    x: round2(rect.x),
    y: round2(rect.y),
    width: round2(rect.width),
    height: round2(rect.height),
    top: round2(rect.top),
    right: round2(rect.right),
    bottom: round2(rect.bottom),
    left: round2(rect.left),
  };
  currentElement.value = elementName;
}

function moveBox(direction: 'up' | 'down' | 'left' | 'right') {
  const step = 30;
  const prev = boxPosition.value;
  if (direction === 'up') boxPosition.value = { ...prev, y: Math.max(MIN_TOP, prev.y - step) };
  if (direction === 'down') boxPosition.value = { ...prev, y: Math.min(MAX_TOP, prev.y + step) };
  if (direction === 'left') boxPosition.value = { ...prev, x: Math.max(0, prev.x - step) };
  if (direction === 'right') boxPosition.value = { ...prev, x: Math.min(300, prev.x + step) };
}

onMounted(() => {
  measureElement(boxRef.value, 'Moving Box');
});
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <div class="flex flex-col gap-6">
        <div class="bg-surface-secondary border border-line rounded-xl p-3">
          <div class="text-lg font-medium text-fg-primary">Current Measurement</div>
          <div class="text-sm text-fg-secondary mb-3">Latest getBoundingClientRect() result</div>
          <div v-if="currentRect" class="bg-surface border border-line rounded p-3">
            <div class="flex items-center justify-between mb-2 pb-1 border-b border-line">
              <span class="text-base font-semibold text-fg-primary">{{ currentElement }}</span>
            </div>
            <div class="flex flex-wrap items-stretch gap-1.5">
              <div class="flex items-center gap-1.5 px-2 py-1.5 bg-surface-secondary rounded border border-line">
                <span class="text-[11px] font-semibold text-fg-secondary uppercase tracking-wide">X:</span>
                <span class="text-xs font-semibold font-mono text-fg-primary">{{ currentRect.x }}</span>
              </div>
              <div class="flex items-center gap-1.5 px-2 py-1.5 bg-surface-secondary rounded border border-line">
                <span class="text-[11px] font-semibold text-fg-secondary uppercase tracking-wide">Y:</span>
                <span class="text-xs font-semibold font-mono text-fg-primary">{{ currentRect.y }}</span>
              </div>
              <div class="flex items-center gap-1.5 px-2 py-1.5 bg-surface-secondary rounded border border-line">
                <span class="text-[11px] font-semibold text-fg-secondary uppercase tracking-wide">Width:</span>
                <span class="text-xs font-semibold font-mono text-fg-primary">{{ currentRect.width }}</span>
              </div>
              <div class="flex items-center gap-1.5 px-2 py-1.5 bg-surface-secondary rounded border border-line">
                <span class="text-[11px] font-semibold text-fg-secondary uppercase tracking-wide">Height:</span>
                <span class="text-xs font-semibold font-mono text-fg-primary">{{ currentRect.height }}</span>
              </div>
              <div class="flex items-center gap-1.5 px-2 py-1.5 bg-surface-secondary rounded border border-line">
                <span class="text-[11px] font-semibold text-fg-secondary uppercase tracking-wide">Top:</span>
                <span class="text-xs font-semibold font-mono text-fg-primary">{{ currentRect.top }}</span>
              </div>
              <div class="flex items-center gap-1.5 px-2 py-1.5 bg-surface-secondary rounded border border-line">
                <span class="text-[11px] font-semibold text-fg-secondary uppercase tracking-wide">Right:</span>
                <span class="text-xs font-semibold font-mono text-fg-primary">{{ currentRect.right }}</span>
              </div>
              <div class="flex items-center gap-1.5 px-2 py-1.5 bg-surface-secondary rounded border border-line">
                <span class="text-[11px] font-semibold text-fg-secondary uppercase tracking-wide">Bottom:</span>
                <span class="text-xs font-semibold font-mono text-fg-primary">{{ currentRect.bottom }}</span>
              </div>
              <div class="flex items-center gap-1.5 px-2 py-1.5 bg-surface-secondary rounded border border-line">
                <span class="text-[11px] font-semibold text-fg-secondary uppercase tracking-wide">Left:</span>
                <span class="text-xs font-semibold font-mono text-fg-primary">{{ currentRect.left }}</span>
              </div>
            </div>
          </div>
          <div v-else class="text-center text-fg-secondary italic py-6">Click on an element below to see its measurements</div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-3">
          <div class="text-lg font-medium text-fg-primary">Click Elements to Measure</div>
          <div class="text-sm text-fg-secondary mb-3">Click on any element below to see its getBoundingClientRect() result</div>
          <div class="relative h-[180px] border-2 border-line rounded bg-surface overflow-hidden flex">
            <div class="flex-1 relative p-4">
              <div class="mb-1.5">
                <span class="block text-xs font-semibold text-fg-primary mb-1">Moving Box</span>
                <div class="flex items-center gap-1">
                  <button class="px-1.5 py-0.5 rounded bg-sky-600 text-white text-[11px]" @click="moveBox('up')">↑</button>
                  <button class="px-1.5 py-0.5 rounded bg-sky-600 text-white text-[11px]" @click="moveBox('down')">↓</button>
                  <button class="px-1.5 py-0.5 rounded bg-sky-600 text-white text-[11px]" @click="moveBox('left')">←</button>
                  <button class="px-1.5 py-0.5 rounded bg-sky-600 text-white text-[11px]" @click="moveBox('right')">→</button>
                </div>
              </div>
              <div
                ref="boxRef"
                class="absolute w-[110px] h-[64px] bg-gradient-to-tr from-indigo-500 to-purple-600 rounded text-white font-semibold text-center shadow cursor-pointer transition-transform hover:scale-[1.02] flex items-center justify-center"
                :style="{ left: `${boxPosition.x}px`, top: `${boxPosition.y}px` }"
                @click="measureElement(boxRef, 'Moving Box')"
              >
                <div class="px-1.5 text-[11px]">Click to measure</div>
              </div>
            </div>

            <div class="flex-1 flex flex-col p-4 border-l border-line">
              <div
                ref="textRef"
                class="p-2.5 bg-white border-2 border-line rounded text-sm leading-tight cursor-pointer transition hover:border-sky-600 hover:shadow"
                @click="measureElement(textRef, 'Text Content')"
              >
                Click to measure this text element
              </div>

              <img
                ref="imageRef"
                src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIwIiBoZWlnaHQ9IjgwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iNjAiIGZpbGw9IiM0Q0FGNTB0Ii8+PHRleHQgeD0iNjAiIHk9IjQwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSI+SW1hZ2U8L3RleHQ+PC9zdmc+"
                alt="Sample"
                class="block max-w-[100px] rounded cursor-pointer transition hover:scale-105 mt-3"
                @click="measureElement(imageRef, 'Sample Image')"
              />
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
