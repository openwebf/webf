<script setup lang="ts">
import { WebFRouter } from '@openwebf/vue-router';

const navigateTo = (path: string) => WebFRouter.pushState({}, path);

const items = [
  { label: 'Icons Gallery', desc: 'Browse 1600+ icons with search and categories', to: '/lucide/icons' },
];
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <div class="w-full flex justify-center items-center">
        <div class="bg-gradient-to-tr from-orange-500 to-amber-400 p-6 rounded-2xl text-white shadow">
          <h1 class="text-[28px] font-bold mb-2 drop-shadow">Lucide Icons</h1>
          <p class="text-[16px]/[1.5] opacity-90">Beautiful & consistent icons for WebF applications</p>
        </div>
      </div>

      <div class="mt-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-orange-500">Icon Components</h2>
        <div class="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
          <div
            v-for="item in items"
            :key="item.label"
            class="flex items-center p-4 border-b border-[#f0f0f0] cursor-pointer transition-colors hover:bg-surface-hover"
            @click="navigateTo(item.to)"
          >
            <div class="flex-1">
              <div class="text-[16px] font-semibold text-[#2c3e50] mb-1">{{ item.label }}</div>
              <div class="text-[14px] text-[#7f8c8d] leading-snug">{{ item.desc }}</div>
            </div>
            <div class="text-[16px] text-[#bdc3c7] font-bold">&gt;</div>
          </div>
        </div>

        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-orange-500">Features</h2>
        <div class="mb-5 bg-surface-secondary rounded-xl p-4 border border-line">
          <ul class="space-y-3 text-[14px] text-fg-secondary">
            <li class="flex items-start gap-2">
              <span class="text-orange-500 font-bold">1600+</span>
              <span>Open source icons in a single package</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-orange-500 font-bold">6</span>
              <span>Stroke width variants (100-600) for each icon</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-green-500">CSS</span>
              <span>Use Tailwind classes for size and color</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-blue-500">A11y</span>
              <span>Accessibility labels for screen readers</span>
            </li>
          </ul>
        </div>

        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-orange-500">Quick Example</h2>
        <div class="mb-5 bg-surface-secondary rounded-xl p-4 border border-line">
          <div class="p-4 bg-gray-900 text-gray-100 rounded overflow-x-auto text-sm">
            <pre>import { LucideIcons } from '@openwebf/vue-lucide-icons';

// Basic usage
&lt;flutter-lucide-icon :name="LucideIcons.rocket" /&gt;

// With size and color
&lt;flutter-lucide-icon
  :name="LucideIcons.heart"
  class="text-4xl text-red-500"
/&gt;

// With stroke width variant
&lt;flutter-lucide-icon
  :name="LucideIcons.activity"
  :stroke-width="400"
/&gt;</pre>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
