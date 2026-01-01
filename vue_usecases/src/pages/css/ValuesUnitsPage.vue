<script setup lang="ts">
const baseFont = 16;
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">Absolute vs Relative Units</h1>
      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="flex gap-3 flex-wrap">
          <div class="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" :style="{ width: '100px', height: '60px' }">100px</div>
          <div class="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" :style="{ width: '10rem', height: '60px' }">10rem</div>
          <div
            class="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]"
            :style="{ width: '10em', height: '60px', fontSize: '14px' }"
          >
            10em (fs=14)
          </div>
          <div class="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" :style="{ width: '20vw', height: '60px' }">20vw</div>
          <div class="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" :style="{ width: '20vh', height: '60px' }">20vh</div>
        </div>
        <div class="text-sm text-fg-secondary mt-2">Assuming base font-size {{ baseFont }}px: 10rem = 160px; 10em depends on element font-size.</div>
      </div>

      <h2 class="text-lg font-medium text-fg-primary mb-2">calc()</h2>
      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <div class="flex gap-3 flex-wrap">
          <div class="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" :style="{ width: 'calc(50% - 20px)', height: '60px' }">
            calc(50% - 20px)
          </div>
          <div class="bg-gray-200 border border-line rounded flex items-center justify-center text-[#111827]" :style="{ width: 'calc(10rem + 10px)', height: '60px' }">
            calc(10rem + 10px)
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
