<script setup lang="ts">
const webfLogo = new URL('../../resource/webf.png', import.meta.url).href;

type FilterDemoItem = {
  title: string;
  filterClass: string;
  description: string;
};

const demos: FilterDemoItem[] = [
  { title: 'Original', filterClass: '', description: 'No filter' },

  { title: 'Blur', filterClass: 'blur-sm', description: 'blur(4px)' },
  { title: 'Blur (Heavy)', filterClass: 'blur-md', description: 'blur(12px)' },

  { title: 'Grayscale', filterClass: 'grayscale', description: 'grayscale(100%)' },
  { title: 'Grayscale (Partial)', filterClass: 'grayscale-[0.5]', description: 'grayscale(50%)' },

  { title: 'Sepia', filterClass: 'sepia', description: 'sepia(100%)' },

  { title: 'Brightness (Dim)', filterClass: 'brightness-50', description: 'brightness(0.5)' },
  { title: 'Brightness (Bright)', filterClass: 'brightness-150', description: 'brightness(1.5)' },

  { title: 'Contrast (Low)', filterClass: 'contrast-50', description: 'contrast(0.5)' },
  { title: 'Contrast (High)', filterClass: 'contrast-150', description: 'contrast(1.5)' },

  { title: 'Hue Rotate', filterClass: 'hue-rotate-90', description: 'hue-rotate(90deg)' },
  { title: 'Hue Rotate (180)', filterClass: 'hue-rotate-180', description: 'hue-rotate(180deg)' },

  { title: 'Invert', filterClass: 'invert', description: 'invert(100%)' },

  { title: 'Saturate (Muted)', filterClass: 'saturate-0', description: 'saturate(0)' },
  { title: 'Saturate (Vibrant)', filterClass: 'saturate-200', description: 'saturate(2)' },

  { title: 'Opacity', filterClass: 'opacity-50', description: 'opacity(0.5)' },

  { title: 'Drop Shadow', filterClass: 'drop-shadow-xl', description: 'drop-shadow(...)' },
  {
    title: 'Drop Shadow (Color)',
    filterClass: 'drop-shadow-[0_10px_8px_rgba(255,0,0,0.5)]',
    description: 'drop-shadow(0 10px 8px rgba(255,0,0,0.5))',
  },
];
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-gray-50">
    <webf-list-view class="w-full px-3 md:px-6 max-w-5xl mx-auto py-6 flex flex-col gap-6 box-border pb-10">
      <div v-for="(demo, index) in demos" :key="index" class="bg-white p-4 rounded-xl shadow-sm flex flex-col items-center gap-4 w-full shrink-0">
        <div class="text-gray-800 font-semibold text-lg self-start">{{ demo.title }}</div>
        <div class="w-full flex justify-center bg-gray-50 rounded-lg p-6 border border-gray-100">
          <img :src="webfLogo" :alt="`Filter ${demo.title}`" class="w-32 h-32 object-contain transition-all duration-300" :class="demo.filterClass" />
        </div>
        <div class="w-full text-xs text-gray-500 font-mono bg-gray-100 px-3 py-2 rounded border border-gray-200">
          {{ demo.description || demo.filterClass }}
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
