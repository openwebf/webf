<script setup lang="ts">
type DemoItem = { label: string; className?: string; style: Record<string, string> };

const flower = new URL('../../resource/bg_flower.gif', import.meta.url).href;

const basics: DemoItem[] = [
  { label: '6px -6px teal', style: { boxShadow: '6px -6px teal' } },
  { label: '10px 5px 5px black', style: { boxShadow: '10px 5px 5px black' } },
  { label: '5px 5px 10px 10px rgba(255,0,255,.5)', style: { boxShadow: '5px 5px 10px 10px rgba(255,0,255,.5)' } },
  { label: '0.5em 1em gold', style: { boxShadow: '0.5em 1em gold' } },
];

const spreads: DemoItem[] = [
  { label: '0 0 0 6px #60a5fa', style: { boxShadow: '0 0 0 6px #60a5fa' } },
  { label: '0 0 10px -3px rgba(0,0,0,.5)', style: { boxShadow: '0 0 10px -3px rgba(0,0,0,.5)' } },
  { label: '0 8px 24px -6px rgba(0,0,0,.3)', style: { boxShadow: '0 8px 24px -6px rgba(0,0,0,.3)' } },
];

const insetVsOutset: DemoItem[] = [
  { label: 'inset 6px -6px teal', style: { boxShadow: 'inset 6px -6px teal', borderRadius: '10px' } },
  { label: 'inset 10px 5px 5px black', style: { boxShadow: 'inset 10px 5px 5px black', borderRadius: '10px' } },
  {
    label: 'inset 5px 5px 10px 10px rgba(255,0,255,.5)',
    style: { boxShadow: 'inset 5px 5px 10px 10px rgba(255,0,255,.5)', borderRadius: '10px' },
  },
];

const multiple: DemoItem[] = [
  { label: '3px 3px red, 6px 6px olive', style: { boxShadow: '3px 3px red, 6px 6px olive' } },
  { label: '3px 3px red, -1em 0 0.4em blue', style: { boxShadow: '3px 3px red, -1em 0 0.4em blue' } },
  { label: 'outset + inset', style: { boxShadow: '20px 20px 20px 10px rgba(255,0,255,.5), inset 5px 15px 20px 10px rgba(0,255,255,.5)', borderRadius: '24px' } },
  { label: 'diag + inset', style: { boxShadow: '20px -10px 20px 10px rgba(0,255,255,.5), inset 5px 15px 20px 10px rgba(255,0,255,.5)', borderRadius: '24px' } },
];

const elevation: DemoItem[] = [
  { label: 'elev-1', style: { boxShadow: '0 1px 2px rgba(0,0,0,0.08), 0 1px 1px rgba(0,0,0,0.06)' } },
  { label: 'elev-2', style: { boxShadow: '0 2px 4px rgba(0,0,0,0.08), 0 1px 2px rgba(0,0,0,0.06)' } },
  { label: 'elev-3', style: { boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05)' } },
  { label: 'elev-4', style: { boxShadow: '0 25px 50px -12px rgba(0,0,0,0.25)' } },
];

const rings: DemoItem[] = [
  { label: 'ring 3px sky', style: { boxShadow: '0 0 0 3px rgba(56,189,248,0.7)', borderRadius: '8px' } },
  { label: 'focus + ring', style: { boxShadow: '0 0 0 2px #fff, 0 0 0 4px #3b82f6', borderRadius: '8px' } },
  { label: 'currentColor ring', style: { color: '#8b5cf6', boxShadow: '0 0 0 6px currentColor', borderRadius: '8px' } },
];

const withBg: DemoItem[] = [
  {
    label: 'img + inset',
    className: 'w-[220px] h-[120px]',
    style: {
      boxShadow: 'inset 0 0 20px rgba(0,0,0,0.35)',
      borderRadius: '16px',
      backgroundImage: `url(${flower})`,
      backgroundSize: 'cover',
      backgroundPosition: 'center',
    },
  },
  {
    label: 'gradient + glow',
    className: 'w-[220px] h-[120px]',
    style: {
      boxShadow: '0 0 24px 0 rgba(59,130,246,0.5)',
      borderRadius: '16px',
      backgroundImage: 'linear-gradient(135deg, #60a5fa, #f472b6)',
    },
  },
];
</script>

<template>
  <div id="main" class="min-h-screen">
    <webf-list-view class="px-3 md:px-6 bg-[#f8f9fa] max-w-5xl mx-auto py-4">
      <div class="w-full flex justify-center items-center">
        <div class="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
          <h1 class="text-[22px] font-bold mb-1 drop-shadow">Box Shadow</h1>
          <p class="text-[14px]/[1.5] opacity-90">Offsets, blur, spread, inset/outset, and multiple layers</p>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Basic offsets and blur</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in basics" :key="`b-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div :class="['mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm', o.className ?? '']">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="o.style">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Spread and negative spread</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in spreads" :key="`s-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div :class="['mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm', o.className ?? '']">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="o.style">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Inset shadows</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in insetVsOutset" :key="`i-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div :class="['mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm', o.className ?? '']">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="o.style">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Multiple shadows</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in multiple" :key="`m-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div :class="['mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm', o.className ?? '']">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="o.style">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Elevation presets</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in elevation" :key="`e-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div :class="['mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm', o.className ?? '']">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="o.style">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Rings via spread</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in rings" :key="`r-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div :class="['mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm', o.className ?? '']">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="o.style">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Background with inset/outset</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in withBg" :key="`bg-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div :class="['mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm', o.className ?? '']">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="o.style">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
