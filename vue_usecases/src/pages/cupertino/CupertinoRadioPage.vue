<script setup lang="ts">
import { ref } from 'vue';

type BasicOption = 'one' | 'two' | 'three';
type SizeOption = 'small' | 'medium' | 'large';
type ThemeOption = 'light' | 'dark' | 'auto';

const basicValue = ref<BasicOption>('one');
const sizeValue = ref<SizeOption>('medium');
const themeValue = ref<ThemeOption>('auto');
const toggleableValue = ref('option1');
const checkmarkValue = ref('check1');

const eventLog = ref<string[]>([]);
function addEventLog(message: string) {
  eventLog.value = [message, ...eventLog.value].slice(0, 5);
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Radio</h1>
      <p class="text-fg-secondary mb-6">macOS-style radio buttons for mutually exclusive selections.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic Radio Group</h2>
        <p class="text-fg-secondary mb-4">Radio buttons work in groups by sharing the same <code>group-value</code>.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6">
            <div class="space-y-3 mb-4">
              <div class="flex items-center gap-3">
                <flutter-cupertino-radio val="one" :group-value="basicValue" @change="(e) => (basicValue = e.detail as BasicOption)" />
                <span class="text-lg">Option One</span>
              </div>
              <div class="flex items-center gap-3">
                <flutter-cupertino-radio val="two" :group-value="basicValue" @change="(e) => (basicValue = e.detail as BasicOption)" />
                <span class="text-lg">Option Two</span>
              </div>
              <div class="flex items-center gap-3">
                <flutter-cupertino-radio val="three" :group-value="basicValue" @change="(e) => (basicValue = e.detail as BasicOption)" />
                <span class="text-lg">Option Three</span>
              </div>
            </div>
            <div class="text-sm text-gray-600 text-center">Selected: <span class="font-semibold">{{ basicValue }}</span></div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Disabled State</h2>
        <p class="text-fg-secondary mb-4">Disabled radios are non-interactive.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6 space-y-4">
            <div class="flex items-center gap-3">
              <flutter-cupertino-radio val="disabled1" group-value="disabled1" disabled />
              <span class="text-gray-400">Disabled (Selected)</span>
            </div>
            <div class="flex items-center gap-3">
              <flutter-cupertino-radio val="disabled2" group-value="disabled1" disabled />
              <span class="text-gray-400">Disabled (Unselected)</span>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Toggleable Radios</h2>
        <p class="text-fg-secondary mb-4">Allow deselecting by clicking the selected option again.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6">
            <div class="space-y-3 mb-4">
              <div class="flex items-center gap-3">
                <flutter-cupertino-radio
                  val="option1"
                  :group-value="toggleableValue"
                  toggleable
                  @change="
                    (e) => {
                      toggleableValue = e.detail || '';
                      addEventLog(`toggleable: ${toggleableValue || '(none)'}`);
                    }
                  "
                />
                <span class="text-lg">Toggleable Option 1</span>
              </div>
              <div class="flex items-center gap-3">
                <flutter-cupertino-radio
                  val="option2"
                  :group-value="toggleableValue"
                  toggleable
                  @change="
                    (e) => {
                      toggleableValue = e.detail || '';
                      addEventLog(`toggleable: ${toggleableValue || '(none)'}`);
                    }
                  "
                />
                <span class="text-lg">Toggleable Option 2</span>
              </div>
            </div>
            <div class="text-sm text-gray-600 text-center">
              Selected: <span class="font-semibold">{{ toggleableValue || '(none)' }}</span>
              <div class="text-xs mt-1">Click the selected radio to deselect it</div>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Checkmark Style</h2>
        <p class="text-fg-secondary mb-4">Use checkmark style instead of the default radio UI.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6">
            <div class="space-y-3 mb-4">
              <div class="flex items-center gap-3">
                <flutter-cupertino-radio val="check1" :group-value="checkmarkValue" use-checkmark-style @change="(e) => (checkmarkValue = e.detail)" />
                <span class="text-lg">Checkmark Option 1</span>
              </div>
              <div class="flex items-center gap-3">
                <flutter-cupertino-radio val="check2" :group-value="checkmarkValue" use-checkmark-style @change="(e) => (checkmarkValue = e.detail)" />
                <span class="text-lg">Checkmark Option 2</span>
              </div>
              <div class="flex items-center gap-3">
                <flutter-cupertino-radio val="check3" :group-value="checkmarkValue" use-checkmark-style @change="(e) => (checkmarkValue = e.detail)" />
                <span class="text-lg">Checkmark Option 3</span>
              </div>
            </div>
            <div class="text-sm text-gray-600 text-center">Selected: <span class="font-semibold">{{ checkmarkValue }}</span></div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Custom Colors</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6 space-y-4">
            <div class="flex items-center gap-3">
              <flutter-cupertino-radio val="red" group-value="red" active-color="#FF3B30" fill-color="#FFFFFF" />
              <span>Red Theme</span>
            </div>
            <div class="flex items-center gap-3">
              <flutter-cupertino-radio val="green" group-value="green" active-color="#34C759" fill-color="#FFFFFF" />
              <span>Green Theme</span>
            </div>
            <div class="flex items-center gap-3">
              <flutter-cupertino-radio val="blue" group-value="blue" active-color="#007AFF" fill-color="#FFFFFF" />
              <span>Blue Theme</span>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Size Options</h2>
        <p class="text-fg-secondary mb-4">A simple example of grouping string values.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6 space-y-3">
            <div class="flex items-center gap-3">
              <flutter-cupertino-radio val="small" :group-value="sizeValue" @change="(e) => { sizeValue = e.detail as SizeOption; addEventLog(`size: ${e.detail}`); }" />
              <span class="text-lg">Small</span>
            </div>
            <div class="flex items-center gap-3">
              <flutter-cupertino-radio val="medium" :group-value="sizeValue" @change="(e) => { sizeValue = e.detail as SizeOption; addEventLog(`size: ${e.detail}`); }" />
              <span class="text-lg">Medium</span>
            </div>
            <div class="flex items-center gap-3">
              <flutter-cupertino-radio val="large" :group-value="sizeValue" @change="(e) => { sizeValue = e.detail as SizeOption; addEventLog(`size: ${e.detail}`); }" />
              <span class="text-lg">Large</span>
            </div>
            <div class="text-sm text-gray-600">Selected: <span class="font-semibold">{{ sizeValue }}</span></div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Practical Example</h2>
        <p class="text-fg-secondary mb-4">Choose a theme preference.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6 space-y-3">
            <div class="flex items-center justify-between">
              <div>
                <div class="font-semibold">Theme</div>
                <div class="text-sm text-gray-600">Current: {{ themeValue }}</div>
              </div>
              <div class="flex gap-3">
                <div class="flex items-center gap-2">
                  <flutter-cupertino-radio val="light" :group-value="themeValue" @change="(e) => { themeValue = e.detail as ThemeOption; addEventLog(`theme: ${e.detail}`); }" />
                  <span class="text-sm">Light</span>
                </div>
                <div class="flex items-center gap-2">
                  <flutter-cupertino-radio val="dark" :group-value="themeValue" @change="(e) => { themeValue = e.detail as ThemeOption; addEventLog(`theme: ${e.detail}`); }" />
                  <span class="text-sm">Dark</span>
                </div>
                <div class="flex items-center gap-2">
                  <flutter-cupertino-radio val="auto" :group-value="themeValue" @change="(e) => { themeValue = e.detail as ThemeOption; addEventLog(`theme: ${e.detail}`); }" />
                  <span class="text-sm">Auto</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="eventLog.length" class="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <div class="text-sm font-semibold mb-2">Event Log (last 5)</div>
          <div class="space-y-1">
            <div v-for="(line, idx) in eventLog" :key="idx" class="text-xs font-mono text-gray-700">{{ line }}</div>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>
