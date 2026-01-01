<script setup lang="ts">
import { computed, ref } from 'vue';

const customColor = ref('#10b981');
const customSize = ref(150);

const createSvgDataUrl = (svgContent: string) => `data:image/svg+xml;utf8,${encodeURIComponent(svgContent)}`;

const basicShapesSvg = createSvgDataUrl(`
  <svg xmlns='http://www.w3.org/2000/svg' width='300' height='100' viewBox='0 0 300 100'>
    <rect x='10' y='10' width='80' height='80' fill='#3b82f6' rx='8'/>
    <circle cx='150' cy='50' r='40' fill='#10b981'/>
    <polygon points='240,10 280,90 200,90' fill='#f59e0b'/>
  </svg>
`);

const gradientSvg = createSvgDataUrl(`
  <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
    <defs>
      <linearGradient id='grad1' x1='0%' y1='0%' x2='100%' y2='100%'>
        <stop offset='0%' style='stop-color:#667eea;stop-opacity:1' />
        <stop offset='100%' style='stop-color:#764ba2;stop-opacity:1' />
      </linearGradient>
    </defs>
    <rect width='200' height='200' fill='url(#grad1)' rx='16'/>
    <text x='100' y='110' font-size='32' text-anchor='middle' fill='white' font-weight='bold'>Gradient</text>
  </svg>
`);

const pathSvg = createSvgDataUrl(`
  <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
    <path d='M100,20 Q150,50 150,100 T100,180 Q50,150 50,100 T100,20 Z'
          fill='#ec4899' stroke='#be185d' stroke-width='3'/>
    <circle cx='100' cy='100' r='8' fill='white'/>
  </svg>
`);

const starSvg = createSvgDataUrl(`
  <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
    <defs>
      <radialGradient id='starGrad' cx='50%' cy='50%' r='50%'>
        <stop offset='0%' style='stop-color:#fbbf24;stop-opacity:1' />
        <stop offset='100%' style='stop-color:#f59e0b;stop-opacity:1' />
      </radialGradient>
    </defs>
    <path d='M100,30 L115,75 L165,75 L125,105 L140,150 L100,120 L60,150 L75,105 L35,75 L85,75 Z'
          fill='url(#starGrad)' stroke='#d97706' stroke-width='2'/>
  </svg>
`);

const iconsSvg = createSvgDataUrl(`
  <svg xmlns='http://www.w3.org/2000/svg' width='400' height='100' viewBox='0 0 400 100'>
    <path d='M50,70 C35,30 10,30 10,50 C10,70 30,85 50,95 C70,85 90,70 90,50 C90,30 65,30 50,70 Z' fill='#ef4444'/>
    <circle cx='150' cy='50' r='40' fill='#10b981'/>
    <path d='M135,50 L145,60 L165,35' stroke='white' stroke-width='6' stroke-linecap='round' stroke-linejoin='round' fill='none'/>
    <path d='M250,20 L290,80 L210,80 Z' fill='#f59e0b'/>
    <text x='250' y='60' font-size='24' text-anchor='middle' fill='white' font-weight='bold'>!</text>
    <circle cx='350' cy='50' r='40' fill='#3b82f6'/>
    <text x='350' y='65' font-size='32' text-anchor='middle' fill='white' font-weight='bold'>i</text>
  </svg>
`);

const patternSvg = createSvgDataUrl(`
  <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
    <defs>
      <pattern id='grid' x='0' y='0' width='20' height='20' patternUnits='userSpaceOnUse'>
        <rect x='0' y='0' width='20' height='20' fill='#e5e7eb'/>
        <rect x='0' y='0' width='10' height='10' fill='#d1d5db'/>
        <rect x='10' y='10' width='10' height='10' fill='#d1d5db'/>
      </pattern>
    </defs>
    <rect width='200' height='200' fill='url(#grid)' rx='12'/>
  </svg>
`);

const complexShapeSvg = createSvgDataUrl(`
  <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
    <defs>
      <linearGradient id='complexGrad' x1='0%' y1='0%' x2='100%' y2='0%'>
        <stop offset='0%' style='stop-color:#8b5cf6;stop-opacity:1' />
        <stop offset='50%' style='stop-color:#ec4899;stop-opacity:1' />
        <stop offset='100%' style='stop-color:#f59e0b;stop-opacity:1' />
      </linearGradient>
    </defs>
    <path d='M100,10 C120,10 140,20 150,40 C160,60 160,80 150,100 C140,120 120,130 100,130
             C80,130 60,120 50,100 C40,80 40,60 50,40 C60,20 80,10 100,10 Z
             M100,50 C90,50 80,60 80,70 C80,80 90,90 100,90 C110,90 120,80 120,70 C120,60 110,50 100,50 Z'
          fill='url(#complexGrad)' stroke='#1f2937' stroke-width='2'/>
  </svg>
`);

const customSvg = computed(() =>
  createSvgDataUrl(`
    <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
      <rect x='10' y='10' width='180' height='180' rx='20' ry='20' fill='${customColor.value}'
            stroke='#1f2937' stroke-width='3'/>
      <text x='100' y='110' font-size='28' text-anchor='middle' fill='white'
            font-family='sans-serif' font-weight='bold'>Custom</text>
    </svg>
  `),
);
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <div class="w-full flex justify-center items-center mb-6">
        <div class="bg-gradient-to-br from-emerald-500 via-teal-500 to-blue-500 p-6 rounded-2xl text-white shadow-lg w-full">
          <h1 class="text-2xl font-bold mb-2 drop-shadow">SVG via &lt;img&gt;</h1>
          <p class="text-sm leading-relaxed opacity-90">
            Inline SVG data URLs rendered as images, with gradients, patterns, paths, and icons.
          </p>
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-lg font-semibold text-fg-primary mb-2">Basic Shapes</div>
        <div class="text-sm text-fg-secondary mb-4">Rect, circle and polygon inside a single SVG.</div>
        <div class="bg-surface rounded-lg p-4 border border-line w-full flex items-center justify-center">
          <img :src="basicShapesSvg" alt="Basic shapes" class="w-[300px] h-[100px]" />
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-lg font-semibold text-fg-primary mb-2">Gradient</div>
        <div class="text-sm text-fg-secondary mb-4">Linear gradient fill with text overlay.</div>
        <div class="bg-surface rounded-lg p-4 border border-line w-full flex items-center justify-center">
          <img :src="gradientSvg" alt="Gradient" class="w-[200px] h-[200px]" />
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-lg font-semibold text-fg-primary mb-2">Path</div>
        <div class="text-sm text-fg-secondary mb-4">Complex path + stroke.</div>
        <div class="bg-surface rounded-lg p-4 border border-line w-full flex items-center justify-center">
          <img :src="pathSvg" alt="Path" class="w-[200px] h-[200px]" />
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-lg font-semibold text-fg-primary mb-2">Icons</div>
        <div class="text-sm text-fg-secondary mb-4">Multiple icons in a single SVG.</div>
        <div class="bg-surface rounded-lg p-4 border border-line w-full flex items-center justify-center">
          <img :src="iconsSvg" alt="Icons" class="w-[400px] h-[100px]" />
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-lg font-semibold text-fg-primary mb-2">Pattern Fill</div>
        <div class="text-sm text-fg-secondary mb-4">SVG pattern with repeating checkerboard design.</div>
        <div class="bg-surface rounded-lg p-4 border border-line w-full flex items-center justify-center">
          <img :src="patternSvg" alt="Pattern" class="w-[200px] h-[200px]" />
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-lg font-semibold text-fg-primary mb-2">Complex Shape with Cutout</div>
        <div class="text-sm text-fg-secondary mb-4">Multi-color gradient with inner cutout.</div>
        <div class="bg-surface rounded-lg p-4 border border-line w-full flex items-center justify-center">
          <img :src="complexShapeSvg" alt="Complex shape" class="w-[200px] h-[200px]" />
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-lg font-semibold text-fg-primary mb-2">Interactive Custom SVG</div>
        <div class="text-sm text-fg-secondary mb-4">Customize the color and size of the SVG dynamically.</div>
        <div class="bg-surface rounded-lg p-4 border border-line w-full">
          <div class="flex flex-col md:flex-row gap-4 mb-6">
            <div class="flex-1">
              <label class="text-sm font-medium text-fg-secondary mb-2 block">Color</label>
              <input
                v-model="customColor"
                type="text"
                class="w-full rounded-lg border border-line px-4 py-2 bg-surface text-fg-primary"
                placeholder="#10b981"
              />
            </div>
            <div class="w-full md:w-40">
              <label class="text-sm font-medium text-fg-secondary mb-2 block">Size (px)</label>
              <input
                v-model.number="customSize"
                type="number"
                class="w-full rounded-lg border border-line px-4 py-2 bg-surface text-fg-primary"
                min="50"
                max="300"
              />
            </div>
          </div>

          <div class="bg-surface-secondary rounded-lg p-8 border border-line flex items-center justify-center">
            <img :src="customSvg" alt="Custom SVG" :style="{ width: `${customSize}px`, height: `${customSize}px` }" />
          </div>
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <div class="text-lg font-semibold text-fg-primary mb-2">Responsive SVG Sizing</div>
        <div class="text-sm text-fg-secondary mb-4">Same SVG displayed at different sizes demonstrating scalability.</div>
        <div class="bg-surface rounded-lg p-4 border border-line w-full">
          <div class="flex flex-wrap items-end justify-center gap-6">
            <div class="flex flex-col items-center">
              <img :src="starSvg" alt="Small star" class="w-[80px] h-[80px] mb-2" />
              <span class="text-xs text-fg-secondary">80×80</span>
            </div>
            <div class="flex flex-col items-center">
              <img :src="starSvg" alt="Medium star" class="w-[120px] h-[120px] mb-2" />
              <span class="text-xs text-fg-secondary">120×120</span>
            </div>
            <div class="flex flex-col items-center">
              <img :src="starSvg" alt="Large star" class="w-[160px] h-[160px] mb-2" />
              <span class="text-xs text-fg-secondary">160×160</span>
            </div>
            <div class="flex flex-col items-center">
              <img :src="starSvg" alt="XL star" class="w-[200px] h-[200px] mb-2" />
              <span class="text-xs text-fg-secondary">200×200</span>
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>

