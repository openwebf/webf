<script setup lang="ts">
type DemoCase = { label: string; style: Record<string, string> };

const borderStringStyles: string[] = [
  'thin solid #222',
  'medium dashed #1f2937',
  '10px solid orange',
  'medium solid #0000ff',
  '0 none transparent',
  '10px hidden red',
];

const perSideCases: DemoCase[] = [
  { label: 'border-top solid', style: { borderTop: '8px solid #f97316' } },
  { label: 'border-right dashed', style: { borderRight: '8px dashed #111827' } },
  { label: 'border-bottom double', style: { borderBottom: '8px double #16a34a' } },
  { label: 'border-left solid', style: { borderLeft: '8px solid #0ea5e9' } },
];

const sideStyleColorCases: DemoCase[] = [
  {
    label: 'width per side',
    style: {
      borderWidth: '2px 4px 8px 12px',
      borderStyle: 'solid',
      borderColor: '#374151',
    },
  },
  {
    label: 'only bottom visible',
    style: {
      borderWidth: '10px',
      borderStyle: 'solid',
      borderColor: 'transparent transparent #ef4444 transparent',
    },
  },
];

const mixedCases: DemoCase[] = [
  { label: 'currentColor + dashed', style: { border: '4px dashed currentColor', color: '#8b5cf6' } },
  { label: 'rgba(0,0,0,0.25)', style: { border: '4px solid rgba(0,0,0,0.25)' } },
];

const radiusVariants = ['15px', '10px 30px 60px 35px', '50px 0 0 50px', '20px 40px / 10px 30px', '8px'];
</script>

<template>
  <div id="main" class="min-h-screen">
    <webf-list-view class="px-3 md:px-6 bg-[#f8f9fa] max-w-5xl mx-auto py-4">
      <div class="w-full flex justify-center items-center">
        <div class="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
          <h1 class="text-[22px] font-bold mb-1 drop-shadow">Border</h1>
          <p class="text-[14px]/[1.5] opacity-90">Styles, widths, colors, and per-side control</p>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Shorthand borders</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(s, i) in borderStringStyles" :key="`b-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ s }}</div>
          <div class="mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="{ border: s }">
              {{ s }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Shorthand + rounded corners</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(s, i) in borderStringStyles" :key="`br-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ `${s} | r=${radiusVariants[i % radiusVariants.length]}` }}</div>
          <div class="mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm">
            <div
              class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100"
              :style="{ border: s, borderRadius: radiusVariants[i % radiusVariants.length] }"
            >
              {{ `${s} | r=${radiusVariants[i % radiusVariants.length]}` }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Per-side borders</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(c, i) in perSideCases" :key="`ps-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ c.label }}</div>
          <div class="mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="c.style">
              {{ c.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Multi-value sides</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(c, i) in sideStyleColorCases" :key="`mv-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ c.label }}</div>
          <div class="mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="c.style">
              {{ c.label }}
            </div>
          </div>
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Mixed and special</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(c, i) in mixedCases" :key="`mx-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ c.label }}</div>
          <div class="mt-2 mb-4 w-[220px] h-[80px] bg-white rounded-md shadow-sm">
            <div class="w-full h-full flex items-center justify-center text-xs text-[#111827] bg-yellow-100" :style="c.style">
              {{ c.label }}
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
