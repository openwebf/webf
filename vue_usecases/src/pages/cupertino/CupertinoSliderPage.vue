<script setup lang="ts">
import { computed, ref } from 'vue';
import { CupertinoIcons } from '@openwebf/vue-cupertino-ui';

const basicValue = ref(50);
const steppedValue = ref(50);

const volumeValue = ref(75);
const brightnessValue = ref(60);
const temperatureValue = ref(22);

const redValue = ref(255);
const greenValue = ref(128);
const blueValue = ref(64);

const eventLog = ref<string[]>([]);
function addEventLog(message: string) {
  eventLog.value = [message, ...eventLog.value].slice(0, 5);
}

const rgbPreview = computed(() => `rgb(${redValue.value}, ${greenValue.value}, ${blueValue.value})`);
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Slider</h1>
      <p class="text-fg-secondary mb-6">iOS-style continuous or stepped slider for value selection.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic Slider</h2>
        <p class="text-fg-secondary mb-4">Continuous range (0-100).</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6">
            <div class="flex justify-between items-center mb-2">
              <span class="font-semibold">Value</span>
              <span class="text-2xl font-bold text-blue-600">{{ basicValue.toFixed(0) }}</span>
            </div>
            <flutter-cupertino-slider
              :val="basicValue"
              :min="0"
              :max="100"
              style="width: 100%;"
              @change="
                (e) => {
                  basicValue = e.detail;
                  addEventLog(`basic: ${e.detail}`);
                }
              "
            />
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Stepped Slider</h2>
        <p class="text-fg-secondary mb-4">Discrete steps using the <code>step</code> prop.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6">
            <div class="flex justify-between items-center mb-2">
              <span class="font-semibold">Steps (10 divisions)</span>
              <span class="text-2xl font-bold text-blue-600">{{ steppedValue.toFixed(0) }}</span>
            </div>
            <flutter-cupertino-slider
              :val="steppedValue"
              :min="0"
              :max="100"
              :step="10"
              style="width: 100%;"
              @change="
                (e) => {
                  steppedValue = e.detail;
                  addEventLog(`stepped: ${e.detail}`);
                }
              "
            />
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Practical Examples</h2>
        <p class="text-fg-secondary mb-4">Common use cases for sliders.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg overflow-hidden divide-y divide-gray-200">
            <div class="p-4">
              <div class="flex items-center gap-3 mb-3">
                <span class="text-2xl"><flutter-cupertino-icon :type="CupertinoIcons.speaker_3_fill" /></span>
                <div class="flex-1">
                  <div class="flex justify-between items-center mb-1">
                    <span class="font-semibold">Volume</span>
                    <span class="text-sm text-gray-600">{{ volumeValue.toFixed(0) }}%</span>
                  </div>
                  <flutter-cupertino-slider :val="volumeValue" :min="0" :max="100" style="width: 100%;" @change="(e) => (volumeValue = e.detail)" />
                </div>
              </div>
            </div>

            <div class="p-4">
              <div class="flex items-center gap-3 mb-3">
                <span class="text-2xl"><flutter-cupertino-icon :type="CupertinoIcons.sun_max_fill" /></span>
                <div class="flex-1">
                  <div class="flex justify-between items-center mb-1">
                    <span class="font-semibold">Brightness</span>
                    <span class="text-sm text-gray-600">{{ brightnessValue.toFixed(0) }}%</span>
                  </div>
                  <flutter-cupertino-slider :val="brightnessValue" :min="0" :max="100" style="width: 100%;" @change="(e) => (brightnessValue = e.detail)" />
                </div>
              </div>
            </div>

            <div class="p-4">
              <div class="flex items-center gap-3 mb-3">
                <span class="text-2xl"><flutter-cupertino-icon :type="CupertinoIcons.thermometer" /></span>
                <div class="flex-1">
                  <div class="flex justify-between items-center mb-1">
                    <span class="font-semibold">Temperature</span>
                    <span class="text-sm text-gray-600">{{ temperatureValue.toFixed(1) }}°C</span>
                  </div>
                  <flutter-cupertino-slider :val="temperatureValue" :min="16" :max="30" style="width: 100%;" @change="(e) => (temperatureValue = e.detail)" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">RGB Color Picker</h2>
        <p class="text-fg-secondary mb-4">Combine sliders to create a color picker.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6 space-y-4">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-lg border border-line" :style="{ backgroundColor: rgbPreview }" />
              <div class="font-mono text-sm">{{ rgbPreview }}</div>
            </div>

            <div>
              <div class="flex justify-between text-sm mb-1"><span class="font-semibold text-red-600">R</span><span>{{ redValue }}</span></div>
              <flutter-cupertino-slider :val="redValue" :min="0" :max="255" style="width: 100%;" @change="(e) => (redValue = Math.round(e.detail))" />
            </div>
            <div>
              <div class="flex justify-between text-sm mb-1"><span class="font-semibold text-green-600">G</span><span>{{ greenValue }}</span></div>
              <flutter-cupertino-slider :val="greenValue" :min="0" :max="255" style="width: 100%;" @change="(e) => (greenValue = Math.round(e.detail))" />
            </div>
            <div>
              <div class="flex justify-between text-sm mb-1"><span class="font-semibold text-blue-600">B</span><span>{{ blueValue }}</span></div>
              <flutter-cupertino-slider :val="blueValue" :min="0" :max="255" style="width: 100%;" @change="(e) => (blueValue = Math.round(e.detail))" />
            </div>
          </div>
        </div>
      </section>

      <div v-if="eventLog.length" class="bg-gray-50 rounded-lg p-4 border border-gray-200">
        <div class="text-sm font-semibold mb-2">Event Log (last 5)</div>
        <div class="space-y-1">
          <div v-for="(line, idx) in eventLog" :key="idx" class="text-xs font-mono text-gray-700">{{ line }}</div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>

