<script setup lang="ts">
import { ref } from 'vue';

const isPlaying = ref<Record<string, boolean>>({});

function toggleAnimation(animationType: string) {
  isPlaying.value = { ...isPlaying.value, [animationType]: !isPlaying.value[animationType] };
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">CSS Animations Showcase</h1>
      <p class="text-sm text-fg-secondary mb-6">Interactive examples of CSS animations using transitions and transforms.</p>

      <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-2">Fade Animation</h2>
        <p class="text-sm text-fg-secondary mb-4 leading-relaxed">Simple fade in/out animation using opacity</p>
        <div class="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
          <div
            class="w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg bg-gradient-to-br from-indigo-500 to-purple-600 transition-opacity duration-500 ease-in-out"
            :class="isPlaying.fade ? 'opacity-100' : 'opacity-30'"
          >
            Fade
          </div>
          <button
            class="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
            @click="toggleAnimation('fade')"
          >
            {{ isPlaying.fade ? 'Fade Out' : 'Fade In' }}
          </button>
        </div>
      </div>

      <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-2">Slide Animation</h2>
        <p class="text-sm text-fg-secondary mb-4 leading-relaxed">Transform-based sliding animation</p>
        <div class="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
          <div
            class="w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg bg-gradient-to-br from-indigo-500 to-purple-600 transition-transform duration-500 ease-out"
            :class="isPlaying.slide ? 'translate-x-0' : '-translate-x-12'"
          >
            Slide
          </div>
          <button
            class="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
            @click="toggleAnimation('slide')"
          >
            {{ isPlaying.slide ? 'Slide Out' : 'Slide In' }}
          </button>
        </div>
      </div>

      <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-2">Scale Animation</h2>
        <p class="text-sm text-fg-secondary mb-4 leading-relaxed">Scale transformation with smooth transition</p>
        <div class="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
          <div
            class="w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg bg-gradient-to-br from-indigo-500 to-purple-600 transition-transform duration-300 ease-out"
            :class="isPlaying.scale ? 'scale-110' : 'scale-90'"
          >
            Scale
          </div>
          <button
            class="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
            @click="toggleAnimation('scale')"
          >
            {{ isPlaying.scale ? 'Scale Down' : 'Scale Up' }}
          </button>
        </div>
      </div>

      <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-2">Rotate Animation</h2>
        <p class="text-sm text-fg-secondary mb-4 leading-relaxed">Continuous rotation animation</p>
        <div class="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
          <div
            class="w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg bg-gradient-to-br from-indigo-500 to-purple-600"
            :class="isPlaying.rotate ? 'animate-spin-slow' : ''"
          >
            Rotate
          </div>
          <button
            class="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
            @click="toggleAnimation('rotate')"
          >
            {{ isPlaying.rotate ? 'Stop' : 'Rotate' }}
          </button>
        </div>
      </div>

      <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-2">Bounce Animation</h2>
        <p class="text-sm text-fg-secondary mb-4 leading-relaxed">Bouncing animation with keyframes</p>
        <div class="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
          <div
            class="w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg bg-gradient-to-br from-indigo-500 to-purple-600"
            :class="isPlaying.bounce ? 'animate-bounce-fast' : ''"
          >
            Bounce
          </div>
          <button
            class="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
            @click="toggleAnimation('bounce')"
          >
            {{ isPlaying.bounce ? 'Stop' : 'Bounce' }}
          </button>
        </div>
      </div>

      <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-2">Pulse Animation</h2>
        <p class="text-sm text-fg-secondary mb-4 leading-relaxed">Pulsing effect with scale and opacity</p>
        <div class="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
          <div
            class="w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg bg-gradient-to-br from-indigo-500 to-purple-600"
            :class="isPlaying.pulse ? 'animate-pulse-scale' : ''"
          >
            Pulse
          </div>
          <button
            class="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
            @click="toggleAnimation('pulse')"
          >
            {{ isPlaying.pulse ? 'Stop' : 'Pulse' }}
          </button>
        </div>
      </div>

      <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-2">Combined Animation</h2>
        <p class="text-sm text-fg-secondary mb-4 leading-relaxed">Multiple transform properties combined</p>
        <div class="flex flex-col md:flex-row items-center gap-6 p-4 bg-white rounded-lg border border-line">
          <div
            class="w-24 h-24 rounded-lg text-white font-semibold flex items-center justify-center shadow-lg bg-gradient-to-br"
            :class="
              isPlaying.combined
                ? 'translate-x-8 scale-110 rotate-[15deg] from-rose-500 to-teal-400 transition-all duration-700 ease-out'
                : 'from-indigo-500 to-purple-600'
            "
          >
            Combined
          </div>
          <button
            class="px-5 md:px-6 py-2.5 md:py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors active:translate-y-px"
            @click="toggleAnimation('combined')"
          >
            {{ isPlaying.combined ? 'Reset' : 'Animate' }}
          </button>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
