<script setup lang="ts">
type DemoItem = { label: string; className?: string; style: Record<string, string> };

const flower = new URL('../../resource/bg_flower.gif', import.meta.url).href;

const basic: string[] = ['4px', '8px', '16px', '24px', '50%', '9999px'];

const fourValue: string[] = ['4px 8px 12px 16px', '8px 50px 30px 5px', '15px 50px 30px 5px', '1em 2em 4em 4em', '100px 30px'];

const elliptical: string[] = ['2em / 5em', '2em 1em 4em / 0.5em 3em', '1em 2em 4em 4em / 1em 2em 2em 8em', '100px 30px / 10px', '50% / 20%'];

const perCorner: DemoItem[] = [
  { label: 'TL 24px', style: { borderTopLeftRadius: '24px' } },
  { label: 'TR 24px', style: { borderTopRightRadius: '24px' } },
  { label: 'BR 24px', style: { borderBottomRightRadius: '24px' } },
  { label: 'BL 24px', style: { borderBottomLeftRadius: '24px' } },
  { label: 'TL/BR 30px', style: { borderTopLeftRadius: '30px', borderBottomRightRadius: '30px' } },
  { label: 'TR/BL 30px', style: { borderTopRightRadius: '30px', borderBottomLeftRadius: '30px' } },
];

const circleAndPills: DemoItem[] = [
  { label: 'Circle (50%)', className: 'w-[120px] h-[120px]', style: { borderRadius: '50%' } },
  { label: 'Pill (9999px)', className: 'w-[220px] h-[60px]', style: { borderRadius: '9999px' } },
  { label: 'Pill (50%)', className: 'w-[220px] h-[60px]', style: { borderRadius: '50%' } },
];

const borderMix: DemoItem[] = [
  { label: 'solid 6px + 12px radius', style: { border: '6px solid #374151', borderRadius: '12px' } },
  { label: 'diff widths + color', style: { borderWidth: '2px 4px 8px 12px', borderStyle: 'solid', borderColor: '#ef4444', borderRadius: '20px' } },
  {
    label: 'per-corner + per-side',
    style: { borderStyle: 'solid', borderWidth: '6px', borderColor: '#f59e0b #10b981 #ef4444 #3b82f6', borderRadius: '10px 30px 60px 35px' },
  },
];

const backgroundClip: DemoItem[] = [
  { label: 'image + 24px radius', className: 'w-[220px] h-[120px]', style: { borderRadius: '24px', backgroundImage: `url(${flower})`, backgroundSize: 'cover', backgroundPosition: 'center' } },
  { label: 'gradient + elliptical', className: 'w-[220px] h-[120px]', style: { borderRadius: '40px 10px / 20px 50px', backgroundImage: 'linear-gradient(135deg, #60a5fa, #f472b6)' } },
];
</script>

<template>
  <div id="main" class="min-h-screen">
    <webf-list-view class="px-3 md:px-6 bg-[#f8f9fa] max-w-5xl mx-auto py-4">
      <div class="w-full flex justify-center items-center">
        <div class="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
          <h1 class="text-[22px] font-bold mb-1 drop-shadow">Border Radius</h1>
          <p class="text-[14px]/[1.5] opacity-90">Rounded corners, elliptical radii, and per-corner control</p>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Basic radii</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(r, i) in basic" :key="`b-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ r }}</div>
          <div class="mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm">
            <div
              class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100"
              :style="{ borderRadius: r, border: '6px solid #9ca3af' }"
            >
              {{ r }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Four-value/Two-value</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(r, i) in fourValue" :key="`fv-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ r }}</div>
          <div class="mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="{ borderRadius: r, border: '6px solid #4b5563' }">
              {{ r }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Elliptical radii (with /)</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(r, i) in elliptical" :key="`el-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ r }}</div>
          <div class="mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="{ borderRadius: r, border: '6px solid #10b981' }">
              {{ r }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Per-corner properties</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in perCorner" :key="`pc-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div class="mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="{ ...o.style, border: '6px solid #f59e0b' }">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Pills and circle</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in circleAndPills" :key="`cp-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div :class="['mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm', o.className ?? '']">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="{ ...o.style, border: '6px solid #ef4444' }">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">With borders</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in borderMix" :key="`bm-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ o.label }}</div>
          <div :class="['mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm', o.className ?? '']">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="o.style">
              {{ o.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Background clipping</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(o, i) in backgroundClip" :key="`bg-${i}`" class="flex flex-col mt-3">
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
