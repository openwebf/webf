<script setup lang="ts">
import { ref } from 'vue';

const showFixed = ref(false);
</script>

<template>
  <div id="main" class="w-full h-full bg-gray-50">
    <webf-list-view class="p-5 flex flex-col gap-6 w-full box-border pb-20">
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">1. Static (Default)</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-2">
            Elements appear in the normal document flow. Top, right, bottom, left, and z-index properties have no effect.
          </p>
          <div class="flex flex-col gap-2 border border-gray-100 p-2 rounded bg-gray-50">
            <div class="bg-blue-100 p-3 rounded text-blue-800 font-medium">Item 1 (Static)</div>
            <div class="bg-blue-100 p-3 rounded text-blue-800 font-medium">Item 2 (Static)</div>
            <div class="bg-blue-100 p-3 rounded text-blue-800 font-medium">Item 3 (Static)</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">position: static</span>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">2. Relative</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-2">
            Positioned relative to its normal position. Other elements are not affected by the gap left.
          </p>
          <div class="flex flex-col gap-2 border border-gray-100 p-2 rounded bg-gray-50">
            <div class="bg-emerald-100 p-3 rounded text-emerald-800 opacity-50">Item 1</div>
            <div class="bg-emerald-500 p-3 rounded text-white shadow-lg relative left-8 top-2 z-10">
              Item 2 (Relative) <br />
              <span class="text-xs opacity-90">left: 2rem, top: 0.5rem</span>
            </div>
            <div class="bg-emerald-100 p-3 rounded text-emerald-800 opacity-50">Item 3</div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">position: relative</span>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">3. Absolute</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-2">Removed from normal flow. Positioned relative to the nearest positioned ancestor (non-static).</p>
          <div class="relative h-48 bg-slate-100 rounded border border-dashed border-slate-300 overflow-hidden">
            <div class="absolute top-0 left-0 p-2 bg-purple-500 text-white text-xs rounded-br">top:0 left:0</div>
            <div class="absolute top-4 right-4 w-12 h-12 bg-purple-400 rounded-full flex items-center justify-center text-white text-xs shadow-md">TR</div>
            <div class="absolute bottom-4 left-4 w-12 h-12 bg-purple-400 rounded-full flex items-center justify-center text-white text-xs shadow-md">BL</div>
            <div class="absolute bottom-0 right-0 p-2 bg-purple-600 text-white text-xs rounded-tl">bottom:0 right:0</div>
            <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-purple-700 text-white px-4 py-2 rounded shadow-xl">
              Centered
            </div>
          </div>
          <div class="flex gap-2">
            <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">position: absolute</span>
            <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">position: relative (parent)</span>
          </div>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">4. Sticky</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-2">Toggles between relative and fixed depending on scroll position.</p>
          <div class="h-48 overflow-auto border border-gray-200 rounded bg-white relative shadow-inner">
            <div class="bg-gray-50 p-2">Scroll me...</div>
            <div class="sticky top-0 bg-amber-400 text-amber-900 p-2 font-bold shadow-md z-10 flex justify-between items-center">
              <span>Sticky Header 1</span>
              <span class="text-xs font-normal bg-amber-200 px-1 rounded">top: 0</span>
            </div>
            <div class="p-4 space-y-2 text-sm text-gray-500">
              <p>Content block 1...</p>
              <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
              <p>Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
            </div>
            <div class="sticky top-10 bg-amber-300 text-amber-800 p-2 font-bold shadow-md z-10 flex justify-between items-center">
              <span>Sticky Header 2</span>
              <span class="text-xs font-normal bg-amber-100 px-1 rounded">top: 2.5rem</span>
            </div>
            <div class="p-4 space-y-2 text-sm text-gray-500">
              <p>Content block 2...</p>
              <p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.</p>
              <p>Duis aute irure dolor in reprehenderit in voluptate velit esse.</p>
              <p>Cillum dolore eu fugiat nulla pariatur.</p>
              <p>Excepteur sint occaecat cupidatat non proident.</p>
            </div>
          </div>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">position: sticky</span>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">5. Fixed</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-600 mb-2">Positioned relative to the viewport. It stays in the same place even if the page is scrolled.</p>
          <button
            class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700 active:bg-indigo-800 transition-colors self-start"
            @click="showFixed = !showFixed"
          >
            {{ showFixed ? 'Hide Fixed Element' : 'Show Fixed Element' }}
          </button>
          <span class="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">position: fixed</span>
        </div>
      </div>

      <div v-if="showFixed" class="fixed bottom-10 right-5 bg-indigo-600 text-white px-4 py-3 rounded-full shadow-2xl z-50 flex items-center gap-2 animate-bounce">
        <span class="text-xl">📌</span>
        <div class="flex flex-col">
          <span class="font-bold text-sm">Fixed Position</span>
          <span class="text-[10px] opacity-80">bottom: 2.5rem, right: 1.25rem</span>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
