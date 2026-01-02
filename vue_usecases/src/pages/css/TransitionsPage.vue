<script setup lang="ts">
import { ref } from 'vue';

const open = ref(false);

const b1 = ref(false);
const o1 = ref(false);
const btn1 = ref(false);

const t1 = ref(false);
const t2 = ref(false);
const t3 = ref(false);
const t4 = ref(false);
const t5 = ref(false);

const d1 = ref(false);
const d2 = ref(false);
const d3 = ref(false);
const d4 = ref(false);

const p1 = ref(false);
const p2 = ref(false);
const p3 = ref(false);

const wWide = ref(false);

const s1 = ref(false);
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
      <div class="w-full flex justify-center items-center">
        <div class="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
          <h1 class="text-[22px] font-bold mb-1 drop-shadow">Transitions</h1>
          <p class="text-[14px]/[1.5] opacity-90">Properties, durations, easing, delays, groups and stateful toggles</p>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Basics (transform + color)</div>
      <div class="flex gap-4 flex-wrap">
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-blue-300 rounded transition-[transform,background-color] duration-300 ease-in-out cursor-pointer"
            :class="b1 ? '-translate-y-2 scale-105 bg-blue-400' : ''"
            @click="b1 = !b1"
          />
          <div class="text-sm text-fg-secondary mt-2">Click square to toggle transform and bg-color.</div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-emerald-300 rounded transition-opacity duration-500 ease-in-out cursor-pointer"
            :class="o1 ? 'opacity-50' : ''"
            @click="o1 = !o1"
          />
          <div class="text-sm text-fg-secondary mt-2">Click square to toggle opacity (500ms).</div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <button
            class="px-3 py-2 rounded border border-line transition-colors duration-200"
            :class="btn1 ? 'bg-red-400' : 'bg-surface'"
            @click="btn1 = !btn1"
          >
            Click me
          </button>
          <div class="text-sm text-fg-secondary mt-2">Click button to toggle colors.</div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Timing functions</div>
      <div class="flex gap-4 flex-wrap">
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-linear cursor-pointer"
            :class="t1 ? 'translate-x-6' : ''"
            @click="t1 = !t1"
          />
          <div class="text-sm text-fg-secondary mt-2">ease-linear (click)</div>
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-in cursor-pointer"
            :class="t2 ? 'translate-x-6' : ''"
            @click="t2 = !t2"
          />
          <div class="text-sm text-fg-secondary mt-2">ease-in (click)</div>
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-out cursor-pointer"
            :class="t3 ? 'translate-x-6' : ''"
            @click="t3 = !t3"
          />
          <div class="text-sm text-fg-secondary mt-2">ease-out (click)</div>
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-in-out cursor-pointer"
            :class="t4 ? 'translate-x-6' : ''"
            @click="t4 = !t4"
          />
          <div class="text-sm text-fg-secondary mt-2">ease-in-out (click)</div>
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-fuchsia-300 rounded transition-transform duration-700 ease-[cubic-bezier(0.68,-0.55,0.27,1.55)] cursor-pointer"
            :class="t5 ? 'translate-x-6' : ''"
            @click="t5 = !t5"
          />
          <div class="text-sm text-fg-secondary mt-2">cubic-bezier(0.68,-0.55,0.27,1.55) (click)</div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Durations and delays</div>
      <div class="flex gap-4 flex-wrap">
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-amber-300 rounded transition-transform duration-150 cursor-pointer"
            :class="d1 ? 'translate-x-6' : ''"
            @click="d1 = !d1"
          />
          <div class="text-sm text-fg-secondary mt-2">duration-150 (click)</div>
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-amber-300 rounded transition-transform duration-500 cursor-pointer"
            :class="d2 ? 'translate-x-6' : ''"
            @click="d2 = !d2"
          />
          <div class="text-sm text-fg-secondary mt-2">duration-500 (click)</div>
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-amber-300 rounded transition-transform duration-1000 cursor-pointer"
            :class="d3 ? 'translate-x-6' : ''"
            @click="d3 = !d3"
          />
          <div class="text-sm text-fg-secondary mt-2">duration-1000 (click)</div>
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-amber-300 rounded transition-transform duration-700 delay-500 cursor-pointer"
            :class="d4 ? 'translate-x-6' : ''"
            @click="d4 = !d4"
          />
          <div class="text-sm text-fg-secondary mt-2">delay-500 + duration-700 (click)</div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Specific properties vs all</div>
      <div class="flex gap-4 flex-wrap">
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 bg-cyan-300 rounded transition-transform duration-500 cursor-pointer"
            :class="p1 ? 'translate-y-4' : ''"
            @click="p1 = !p1"
          />
          <div class="text-sm text-fg-secondary mt-2">Only transform transitions (click)</div>
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div
            class="w-20 h-20 rounded transition-colors duration-500 cursor-pointer"
            :class="p2 ? 'bg-cyan-400' : 'bg-cyan-300'"
            @click="p2 = !p2"
          />
          <div class="text-sm text-fg-secondary mt-2">Only color transitions (click)</div>
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div class="w-20 h-20 bg-cyan-300 rounded transition duration-500 cursor-pointer" :class="p3 ? '-translate-y-2 bg-cyan-400' : ''" @click="p3 = !p3" />
          <div class="text-sm text-fg-secondary mt-2">All (transform + color) (click)</div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Width/height transitions</div>
      <div class="flex gap-4 flex-wrap">
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[420px]">
          <div class="text-sm text-fg-secondary mb-2">Click bar to animate width</div>
          <div
            class="h-5 bg-sky-300 rounded transition-[width] duration-500 ease-in-out cursor-pointer"
            :class="wWide ? 'w-64' : 'w-24'"
            @click="wWide = !wWide"
          />
        </div>
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[420px]">
          <div class="text-sm text-fg-secondary mb-2">Accordion: max-height + opacity</div>
          <div class="rounded border border-line p-3">
            <div class="flex items-center justify-between">
              <div class="font-medium">Panel</div>
              <button class="px-2 py-1 text-xs rounded border border-line bg-surface hover:bg-surface-hover transition-colors" @click="open = !open">
                {{ open ? 'Close' : 'Open' }}
              </button>
            </div>
            <div
              class="overflow-hidden transition-[max-height,opacity] duration-500 ease-in-out"
              :class="open ? 'max-h-40 opacity-100 mt-2' : 'max-h-0 opacity-0'"
            >
              <div class="text-sm text-fg-secondary">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus quis.</div>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Filter / shadow transitions</div>
      <div class="flex gap-4 flex-wrap">
        <div class="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
          <div class="w-24 h-24 bg-white rounded transition-shadow duration-500 cursor-pointer" :class="s1 ? 'shadow-xl' : ''" @click="s1 = !s1" />
          <div class="text-sm text-fg-secondary mt-2">shadow transition (click)</div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
