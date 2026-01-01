<script setup lang="ts">
type DemoItem = {
  label: string;
  className?: string;
  style: Record<string, string>;
};

const flower = new URL('../../resource/bg_flower.gif', import.meta.url).href;

const linearGradientDirections: DemoItem[] = [
  { label: 'linear-gradient(red, blue)', className: 'w-[100px] h-[100px]', style: { background: 'red linear-gradient(red, blue)' } },
  { label: 'to top', className: 'w-[100px] h-[100px]', style: { background: 'red linear-gradient(to top, red, blue)' } },
  { label: 'to bottom', className: 'w-[100px] h-[100px]', style: { background: 'rgba(255,0,0,0.5) linear-gradient(to bottom, red, blue)' } },
  { label: 'to left', className: 'w-[100px] h-[100px]', style: { background: 'rgba(255,0,0,0.5) linear-gradient(to left, red, blue)' } },
  { label: 'to right', className: 'w-[100px] h-[100px]', style: { background: 'rgba(255,0,0,0.5) linear-gradient(to right, red, blue)' } },
  {
    label: 'to top-left alpha',
    className: 'w-[100px] h-[100px]',
    style: { background: 'red linear-gradient(to top left, rgba(255,0,0,0.8), rgba(0,0,255,0.8))' },
  },
  {
    label: 'to top-right alpha',
    className: 'w-[100px] h-[100px]',
    style: { background: 'red linear-gradient(to top right, rgba(255,0,0,0.8), rgba(0,0,255,0.8))' },
  },
  {
    label: 'to bottom-right alpha',
    className: 'w-[100px] h-[100px]',
    style: { background: 'red linear-gradient(to bottom right, rgba(255,0,0,0.8), rgba(0,0,255,0.8))' },
  },
  {
    label: 'to bottom-left alpha',
    className: 'w-[100px] h-[100px]',
    style: { background: 'red linear-gradient(to bottom left, rgba(255,0,0,0.8), rgba(0,0,255,0.8))' },
  },
  { label: 'linear-gradient(#ff0000, #0000ff)', className: 'w-[100px] h-[100px]', style: { background: 'red linear-gradient(#ff0000, #0000ff)' } },
  {
    label: 'mix: img + gradients (1)',
    className: 'w-[300px] h-[100px]',
    style: {
      backgroundImage: `url(${flower}), linear-gradient(to bottom, green, pink), linear-gradient(to bottom left, red, yellow, blue)`,
      backgroundSize: '50px auto',
      backgroundRepeat: 'repeat, no-repeat',
    },
  },
  {
    label: 'mix: different angle + sizes',
    className: 'w-[300px] h-[100px]',
    style: {
      backgroundImage: `url(${flower}), linear-gradient(30deg, red, yellow, blue), linear-gradient(60deg, red, yellow, blue)`,
      backgroundSize: '150px, 100px, 100px',
      backgroundRepeat: 'repeat, no-repeat, repeat',
    },
  },
];

const backgroundRepeat: DemoItem[] = [
  { label: 'repeat', style: { backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'repeat' } },
  { label: 'repeat-x', style: { backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'repeat-x' } },
  { label: 'repeat-y', style: { backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'repeat-y' } },
  { label: 'no-repeat', style: { backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'no-repeat' } },
  { label: 'space', style: { backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'space' } },
  { label: 'round', style: { backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'round' } },
];

const backgroundPosition: DemoItem[] = [
  {
    label: 'left top',
    style: { backgroundImage: `url(${flower})`, backgroundSize: '50px 50px', backgroundRepeat: 'no-repeat', backgroundPosition: 'left top' },
  },
  {
    label: 'center center',
    style: {
      backgroundImage: `url(${flower})`,
      backgroundSize: '50px 50px',
      backgroundRepeat: 'no-repeat',
      backgroundPosition: 'center center',
    },
  },
  {
    label: 'right 20px bottom 10px',
    style: {
      backgroundImage: `url(${flower})`,
      backgroundSize: '50px 50px',
      backgroundRepeat: 'no-repeat',
      backgroundPosition: 'right 20px bottom 10px',
    },
  },
  { label: '50% 10px', style: { backgroundImage: `url(${flower})`, backgroundSize: '50px 50px', backgroundRepeat: 'no-repeat', backgroundPosition: '50% 10px' } },
];

const backgroundSize: DemoItem[] = [
  { label: 'auto (default)', style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center' } },
  { label: 'cover', style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center', backgroundSize: 'cover' } },
  { label: 'contain', style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center', backgroundSize: 'contain' } },
  { label: '50px auto', style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center', backgroundSize: '50px auto' } },
  { label: 'auto 50px', style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center', backgroundSize: 'auto 50px' } },
];

const originAndClip: DemoItem[] = [
  {
    label: 'origin: border-box',
    className: 'w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]',
    style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundOrigin: 'border-box' },
  },
  {
    label: 'origin: padding-box',
    className: 'w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]',
    style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundOrigin: 'padding-box' },
  },
  {
    label: 'origin: content-box',
    className: 'w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]',
    style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundOrigin: 'content-box' },
  },
  {
    label: 'clip: border-box',
    className: 'w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]',
    style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundClip: 'border-box' },
  },
  {
    label: 'clip: padding-box',
    className: 'w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]',
    style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundClip: 'padding-box' },
  },
  {
    label: 'clip: content-box',
    className: 'w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]',
    style: { backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundClip: 'content-box' },
  },
];

const multiBg: DemoItem[] = [
  {
    label: 'multiple images + positions',
    style: {
      backgroundColor: '#fef3c7',
      backgroundImage: `url(${flower}), url(${flower})`,
      backgroundRepeat: 'no-repeat, no-repeat',
      backgroundPosition: 'left 10px top 10px, right 10px bottom 10px',
      backgroundSize: '50px 50px, 70px 70px',
    },
  },
  {
    label: 'debug grid overlay',
    style: {
      backgroundColor: '#fff',
      backgroundImage: `url(${flower}), linear-gradient(#0000 24px, rgba(0,0,0,0.15) 25px), linear-gradient(90deg, #0000 24px, rgba(0,0,0,0.15) 25px)`,
      backgroundRepeat: 'no-repeat, repeat, repeat',
      backgroundPosition: 'center, top left, top left',
      backgroundSize: '60px 60px, 25px 25px, 25px 25px',
    },
  },
];
</script>

<template>
  <div id="main" class="min-h-screen">
    <webf-list-view class="px-3 md:px-6 bg-[#f8f9fa] max-w-5xl mx-auto py-4">
      <div class="mt-5 font-semibold text-[#2c3e50]">Linear gradient directions</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(demo, i) in linearGradientDirections" :key="`lg-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ demo.label }}</div>
          <div
            :class="['mt-2 mb-4 border border-dashed border-[#bdbdbd] w-[220px] h-[120px] bg-white', demo.className ?? '']"
            :style="demo.style"
          />
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Background repeat</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(demo, i) in backgroundRepeat" :key="`br-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ demo.label }}</div>
          <div class="mt-2 mb-4 border border-dashed border-[#bdbdbd] w-[220px] h-[120px] bg-white" :style="demo.style" />
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Background position</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(demo, i) in backgroundPosition" :key="`bp-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ demo.label }}</div>
          <div class="mt-2 mb-4 border border-dashed border-[#bdbdbd] w-[220px] h-[120px] bg-white" :style="demo.style" />
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Background size</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(demo, i) in backgroundSize" :key="`bs-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ demo.label }}</div>
          <div class="mt-2 mb-4 border border-dashed border-[#bdbdbd] w-[220px] h-[120px] bg-white" :style="demo.style" />
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Background origin &amp; clip</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(demo, i) in originAndClip" :key="`oc-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ demo.label }}</div>
          <div
            :class="['mt-2 mb-4 border border-dashed border-[#bdbdbd] w-[220px] h-[120px] bg-white', demo.className ?? '']"
            :style="demo.style"
          />
        </div>
      </div>

      <div class="mt-5 font-semibold text-[#2c3e50]">Multiple backgrounds &amp; debug overlays</div>
      <div class="flex flex-wrap gap-4 items-start">
        <div v-for="(demo, i) in multiBg" :key="`mb-${i}`" class="flex flex-col mt-3">
          <div class="text-sm text-[#374151]">{{ demo.label }}</div>
          <div class="mt-2 mb-4 border border-dashed border-[#bdbdbd] w-[220px] h-[120px] bg-white" :style="demo.style" />
        </div>
      </div>

      <div class="mt-5">
        <div class="font-semibold text-[#2c3e50] mb-2">background-attachment</div>
        <div class="flex flex-col md:flex-row gap-3">
          <div class="relative h-40 w-full md:w-[360px] overflow-auto border border-gray-300">
            <div class="absolute top-1 left-2 text-xs text-gray-700 bg-white/70 px-2 py-0.5 rounded">scroll</div>
            <div
              class="h-[320px] flex items-center justify-center text-sm text-gray-900"
              :style="{
                backgroundImage:
                  'linear-gradient(45deg, rgba(59,130,246,0.15) 25%, transparent 25%, transparent 50%, rgba(59,130,246,0.15) 50%, rgba(59,130,246,0.15) 75%, transparent 75%, transparent)',
                backgroundSize: '32px 32px',
                backgroundAttachment: 'scroll',
              }"
            >
              Scroll me
            </div>
          </div>
          <div class="relative h-40 w-full md:w-[360px] overflow-auto border border-gray-300">
            <div class="absolute top-1 left-2 text-xs text-gray-700 bg-white/70 px-2 py-0.5 rounded">fixed</div>
            <div
              class="h-[320px] flex items-center justify-center text-sm text-gray-900"
              :style="{
                backgroundImage:
                  'linear-gradient(45deg, rgba(59,130,246,0.15) 25%, transparent 25%, transparent 50%, rgba(59,130,246,0.15) 50%, rgba(59,130,246,0.15) 75%, transparent 75%, transparent)',
                backgroundSize: '32px 32px',
                backgroundAttachment: 'fixed',
              }"
            >
              Scroll me
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
