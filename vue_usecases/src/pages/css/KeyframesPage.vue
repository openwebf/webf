<script setup lang="ts"></script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">CSS Keyframes Animations</h1>
      <p class="text-sm text-fg-secondary mb-6">Demonstrates CSS @keyframes animations with various properties, timing functions, and effects.</p>

      <h2 class="text-lg font-medium text-fg-primary mb-3">Transform Animations</h2>
      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-sm text-fg-secondary mb-4">Basic transform animations using translate, rotate, and scale.</div>
        <div class="flex flex-wrap gap-4">
          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Slide (translateX)</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg overflow-hidden">
              <div class="w-12 h-12 bg-blue-500 rounded flex items-center justify-center text-white text-2xl animate-[slide_2s_ease-in-out_infinite]">
                🦁
              </div>
            </div>
          </div>

          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Spin (rotate)</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 bg-purple-500 rounded flex items-center justify-center text-white text-2xl animate-[spin_2s_linear_infinite]">
                ⭐
              </div>
            </div>
          </div>

          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Pulse (scale)</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center text-white text-2xl animate-pulse">❤️</div>
            </div>
          </div>

          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Bounce (translateY)</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 bg-orange-500 rounded-full flex items-center justify-center text-white text-2xl animate-bounce">🏀</div>
            </div>
          </div>
        </div>
      </div>

      <h2 class="text-lg font-medium text-fg-primary mb-3">Animation Timing Functions</h2>
      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-sm text-fg-secondary mb-4">Different timing functions affect animation speed curves.</div>
        <div class="space-y-3">
          <div>
            <div class="flex justify-between items-center mb-1">
              <span class="text-xs text-fg-secondary">linear</span>
              <span class="text-xs text-fg-secondary">Constant speed</span>
            </div>
            <div class="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
              <div class="absolute w-8 h-full bg-blue-500 animate-[slideLinear_3s_linear_infinite]" />
            </div>
          </div>

          <div>
            <div class="flex justify-between items-center mb-1">
              <span class="text-xs text-fg-secondary">ease</span>
              <span class="text-xs text-fg-secondary">Slow start and end</span>
            </div>
            <div class="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
              <div class="absolute w-8 h-full bg-purple-500 animate-[slideLinear_3s_ease_infinite]" />
            </div>
          </div>

          <div>
            <div class="flex justify-between items-center mb-1">
              <span class="text-xs text-fg-secondary">ease-in</span>
              <span class="text-xs text-fg-secondary">Slow start</span>
            </div>
            <div class="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
              <div class="absolute w-8 h-full bg-green-500 animate-[slideLinear_3s_ease-in_infinite]" />
            </div>
          </div>

          <div>
            <div class="flex justify-between items-center mb-1">
              <span class="text-xs text-fg-secondary">ease-out</span>
              <span class="text-xs text-fg-secondary">Slow end</span>
            </div>
            <div class="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
              <div class="absolute w-8 h-full bg-orange-500 animate-[slideLinear_3s_ease-out_infinite]" />
            </div>
          </div>

          <div>
            <div class="flex justify-between items-center mb-1">
              <span class="text-xs text-fg-secondary">ease-in-out</span>
              <span class="text-xs text-fg-secondary">Slow start and end</span>
            </div>
            <div class="h-8 bg-white border border-line rounded-lg overflow-hidden relative">
              <div class="absolute w-8 h-full bg-red-500 animate-[slideLinear_3s_ease-in-out_infinite]" />
            </div>
          </div>
        </div>
      </div>

      <h2 class="text-lg font-medium text-fg-primary mb-3">Animation Properties</h2>
      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-sm text-fg-secondary mb-4">Duration, delay, iteration count, direction, fill-mode.</div>
        <div class="flex flex-wrap gap-4">
          <div class="flex-1 min-w-[160px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Delay (1s)</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg overflow-hidden">
              <div class="w-12 h-12 bg-blue-500 rounded flex items-center justify-center text-white text-2xl animate-[slide_2s_ease-in-out_1s_infinite]">
                ⏳
              </div>
            </div>
          </div>
          <div class="flex-1 min-w-[160px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Alternate</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg overflow-hidden">
              <div class="w-12 h-12 bg-purple-500 rounded flex items-center justify-center text-white text-2xl animate-[slide_2s_ease-in-out_infinite_alternate]">
                ↔️
              </div>
            </div>
          </div>
          <div class="flex-1 min-w-[160px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Fill-mode (forwards)</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg overflow-hidden">
              <div class="w-12 h-12 bg-green-500 rounded flex items-center justify-center text-white text-2xl animate-[fadeIn_1.2s_ease-out_forwards]">
                ✅
              </div>
            </div>
          </div>
        </div>
      </div>

      <h2 class="text-lg font-medium text-fg-primary mb-3">More Keyframe Effects</h2>
      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-sm text-fg-secondary mb-4">Shake, wobble, flip and color cycles.</div>
        <div class="flex flex-wrap gap-4">
          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Fade In</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 bg-pink-500 rounded flex items-center justify-center text-white text-2xl animate-[fadeIn_1.2s_ease-out_infinite]">
                🌸
              </div>
            </div>
          </div>
          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Color Cycle</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 rounded-full flex items-center justify-center text-white text-2xl animate-[colorCycle_3s_linear_infinite]">
                🌈
              </div>
            </div>
          </div>
          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Shake</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 bg-red-500 rounded flex items-center justify-center text-white text-2xl animate-[shake_0.5s_ease-in-out_infinite]">
                🔔
              </div>
            </div>
          </div>
          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Wobble</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 bg-yellow-500 rounded-full flex items-center justify-center text-white text-2xl animate-[wobble_1s_ease-in-out_infinite]">
                😊
              </div>
            </div>
          </div>
          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Flip (3D)</div>
            <div class="h-20 flex items-center justify-center bg-white border border-line rounded-lg">
              <div
                class="w-12 h-12 bg-indigo-500 rounded flex items-center justify-center text-white text-2xl animate-[flip_2s_ease-in-out_infinite]"
                :style="{ transformStyle: 'preserve-3d' }"
              >
                🎴
              </div>
            </div>
          </div>
        </div>
      </div>

      <h2 class="text-lg font-medium text-fg-primary mb-3">Combined Animations</h2>
      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <div class="text-sm text-fg-secondary mb-4">Multiple animations applied simultaneously.</div>
        <div class="flex flex-wrap gap-4">
          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Spin + Bounce</div>
            <div class="h-24 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-500 rounded flex items-center justify-center text-white text-2xl animate-[spin_2s_linear_infinite,bounce_1s_ease-in-out_infinite]">
                ✨
              </div>
            </div>
          </div>

          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Pulse + Rotate</div>
            <div class="h-24 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center text-white text-2xl animate-[pulse_2s_ease-in-out_infinite,spin_4s_linear_infinite]">
                💎
              </div>
            </div>
          </div>

          <div class="flex-1 min-w-[140px] text-center">
            <div class="text-xs text-fg-secondary mb-2">Scale + Color</div>
            <div class="h-24 flex items-center justify-center bg-white border border-line rounded-lg">
              <div class="w-12 h-12 rounded-full flex items-center justify-center text-white text-2xl animate-[pulse_1.5s_ease-in-out_infinite,colorCycle_4s_linear_infinite]">
                🌈
              </div>
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>

<style>
@keyframes slide {
  0%,
  100% {
    transform: translateX(0);
  }
  50% {
    transform: translateX(60px);
  }
}
@keyframes slideLinear {
  0% {
    left: 0;
  }
  100% {
    left: calc(100% - 2rem);
  }
}
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
@keyframes colorCycle {
  0% {
    background-color: #ef4444;
  }
  25% {
    background-color: #f59e0b;
  }
  50% {
    background-color: #10b981;
  }
  75% {
    background-color: #3b82f6;
  }
  100% {
    background-color: #ef4444;
  }
}
@keyframes shake {
  0%,
  100% {
    transform: translateX(0);
  }
  25% {
    transform: translateX(-10px);
  }
  75% {
    transform: translateX(10px);
  }
}
@keyframes wobble {
  0%,
  100% {
    transform: rotate(0deg);
  }
  25% {
    transform: rotate(-15deg);
  }
  75% {
    transform: rotate(15deg);
  }
}
@keyframes flip {
  0% {
    transform: rotateY(0deg);
  }
  50% {
    transform: rotateY(180deg);
  }
  100% {
    transform: rotateY(360deg);
  }
}
</style>
