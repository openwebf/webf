<script setup lang="ts">
import { ref } from 'vue';

const counter = ref(0);

function increment() {
  counter.value += 1;
}

function decrement() {
  counter.value -= 1;
}

function reset() {
  counter.value = 0;
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Buttons</h1>
      <p class="text-fg-secondary mb-6">iOS-style buttons with haptic feedback</p>

      <div class="mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Button Variants</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
          <div>
            <p class="text-sm text-fg-secondary mb-2">Plain Button (default)</p>
            <flutter-cupertino-button variant="plain" @click="console.log('Plain button clicked')">
              Plain Button
            </flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Tinted Button</p>
            <flutter-cupertino-button variant="tinted" @click="console.log('Tinted button clicked')">
              Tinted Button
            </flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Filled Button</p>
            <flutter-cupertino-button
              variant="filled"
              @click="
                () => {
                  increment();
                  console.log('Filled button clicked');
                }
              "
            >
              Filled Button ({{ counter }})
            </flutter-cupertino-button>
          </div>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Button Sizes</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
          <div>
            <p class="text-sm text-fg-secondary mb-2">Small Size</p>
            <flutter-cupertino-button variant="filled" size="small" @click="console.log('Small button')">
              Small Button
            </flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Default Size</p>
            <flutter-cupertino-button variant="filled" @click="console.log('Default button')">
              Default Button
            </flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Large Size</p>
            <flutter-cupertino-button variant="filled" size="large" @click="console.log('Large button')">
              Large Button
            </flutter-cupertino-button>
          </div>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Disabled State</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
          <div>
            <p class="text-sm text-fg-secondary mb-2">Disabled Plain Button</p>
            <flutter-cupertino-button variant="plain" disabled>Disabled Plain</flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Disabled Tinted Button</p>
            <flutter-cupertino-button variant="tinted" disabled>Disabled Tinted</flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Disabled Filled Button</p>
            <flutter-cupertino-button variant="filled" disabled>Disabled Filled</flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Disabled with Custom Color</p>
            <flutter-cupertino-button variant="filled" disabled disabled-color="#B0B0B0">
              Custom Disabled Color
            </flutter-cupertino-button>
          </div>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Pressed Opacity</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
          <div>
            <p class="text-sm text-fg-secondary mb-2">Default Pressed Opacity (0.4)</p>
            <flutter-cupertino-button variant="filled" @click="console.log('Default opacity')">Default Press</flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Softer Press (0.2)</p>
            <flutter-cupertino-button variant="filled" pressed-opacity="0.2" @click="console.log('Soft press')">Softer Press</flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Harder Press (0.6)</p>
            <flutter-cupertino-button variant="filled" pressed-opacity="0.6" @click="console.log('Hard press')">Harder Press</flutter-cupertino-button>
          </div>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Custom Styling</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
          <div>
            <p class="text-sm text-fg-secondary mb-2">Custom Padding & Border Radius</p>
            <flutter-cupertino-button
              variant="tinted"
              class="px-4 py-2 rounded-xl"
              :style="{ minHeight: '44px', textAlign: 'center' }"
              @click="console.log('Custom styling')"
            >
              Continue
            </flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Fixed Width Button</p>
            <flutter-cupertino-button variant="tinted" class="w-52 rounded-lg" @click="console.log('Fixed width')">
              Fixed Width
            </flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Custom Background (Tinted with CSS)</p>
            <flutter-cupertino-button
              variant="tinted"
              class="rounded-lg"
              :style="{ backgroundColor: '#34C759', color: 'white' }"
              @click="console.log('Custom background')"
            >
              Success Green
            </flutter-cupertino-button>
          </div>

          <div>
            <p class="text-sm text-fg-secondary mb-2">Custom Background (Plain with CSS)</p>
            <flutter-cupertino-button
              variant="plain"
              class="rounded-lg px-4 py-2"
              :style="{ backgroundColor: '#FF3B30', color: 'white' }"
              @click="console.log('Custom danger')"
            >
              Danger Red
            </flutter-cupertino-button>
          </div>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Color Variants</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line">
          <p class="text-sm text-fg-secondary mb-4">Using tinted variant with custom CSS colors</p>
          <div class="flex flex-wrap gap-3">
            <flutter-cupertino-button
              variant="tinted"
              class="rounded-lg"
              :style="{ backgroundColor: '#007AFF', color: 'white' }"
              @click="console.log('Primary')"
            >
              Primary
            </flutter-cupertino-button>

            <flutter-cupertino-button
              variant="tinted"
              class="rounded-lg"
              :style="{ backgroundColor: '#34C759', color: 'white' }"
              @click="console.log('Success')"
            >
              Success
            </flutter-cupertino-button>

            <flutter-cupertino-button
              variant="tinted"
              class="rounded-lg"
              :style="{ backgroundColor: '#FF9500', color: 'white' }"
              @click="console.log('Warning')"
            >
              Warning
            </flutter-cupertino-button>

            <flutter-cupertino-button
              variant="tinted"
              class="rounded-lg"
              :style="{ backgroundColor: '#FF3B30', color: 'white' }"
              @click="console.log('Danger')"
            >
              Danger
            </flutter-cupertino-button>

            <flutter-cupertino-button
              variant="tinted"
              class="rounded-lg"
              :style="{ backgroundColor: '#8E8E93', color: 'white' }"
              @click="console.log('Secondary')"
            >
              Secondary
            </flutter-cupertino-button>
          </div>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Interactive Example</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line">
          <p class="text-fg-secondary mb-4">
            Counter: <span class="font-bold text-2xl text-fg-primary">{{ counter }}</span>
          </p>
          <div class="flex flex-wrap gap-3">
            <flutter-cupertino-button
              variant="tinted"
              class="rounded-lg"
              :style="{ backgroundColor: '#34C759', color: 'white' }"
              @click="increment"
            >
              Increment
            </flutter-cupertino-button>

            <flutter-cupertino-button
              variant="tinted"
              class="rounded-lg"
              :style="{ backgroundColor: '#FF3B30', color: 'white' }"
              @click="decrement"
            >
              Decrement
            </flutter-cupertino-button>

            <flutter-cupertino-button
              variant="tinted"
              class="rounded-lg"
              :style="{ backgroundColor: '#8E8E93', color: 'white' }"
              @click="reset"
            >
              Reset
            </flutter-cupertino-button>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
