<script setup lang="ts">
import { ref } from 'vue';
import type { FlutterCupertinoAlertElement } from '@openwebf/vue-cupertino-ui';

const lastAction = ref('');

const basicRef = ref<FlutterCupertinoAlertElement | null>(null);
const confirmRef = ref<FlutterCupertinoAlertElement | null>(null);
const destructiveRef = ref<FlutterCupertinoAlertElement | null>(null);
const customStyleRef = ref<FlutterCupertinoAlertElement | null>(null);
const imperativeRef = ref<FlutterCupertinoAlertElement | null>(null);

function showBasic() {
  basicRef.value?.show({ title: 'Welcome', message: 'This is a basic iOS-style alert dialog.' });
}
function showConfirm() {
  confirmRef.value?.show({
    title: 'Delete Item?',
    message: 'This action cannot be undone. Are you sure you want to proceed?',
  });
}
function showDestructive() {
  destructiveRef.value?.show({
    title: 'Clear All Data?',
    message: 'All your settings and data will be permanently deleted from this device.',
  });
}
function showCustomStyle() {
  customStyleRef.value?.show({
    title: 'Custom Styling',
    message: 'Buttons can have custom colors, font sizes, and weights.',
  });
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Alert Dialog</h1>
      <p class="text-fg-secondary mb-6">iOS-style alert and confirmation dialogs with native appearance.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic Alert</h2>
        <p class="text-fg-secondary mb-4">Simple alert with title, message, and a single confirm button.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-alert
            ref="basicRef"
            title="Welcome"
            message="This is a basic iOS-style alert dialog."
            confirm-text="OK"
            @confirm="lastAction = 'Confirmed basic alert'"
          />
          <button class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors" @click="showBasic">
            Show Basic Alert
          </button>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Alert with Cancel & Confirm</h2>
        <p class="text-fg-secondary mb-4">Two-button alert for user confirmation.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-alert
            ref="confirmRef"
            title="Delete Item?"
            message="This action cannot be undone. Are you sure you want to proceed?"
            cancel-text="Cancel"
            confirm-text="Delete"
            @cancel="lastAction = 'Cancelled deletion'"
            @confirm="lastAction = 'Confirmed deletion'"
          />
          <button class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors" @click="showConfirm">
            Show Confirmation Alert
          </button>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Destructive Actions</h2>
        <p class="text-fg-secondary mb-4">Use red destructive styling to warn users about irreversible actions.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-alert
            ref="destructiveRef"
            title="Clear All Data?"
            message="All your settings and data will be permanently deleted from this device."
            cancel-text="Keep Data"
            cancel-default
            confirm-text="Clear Everything"
            confirm-destructive
            @cancel="lastAction = 'Kept data (safe choice)'"
            @confirm="lastAction = 'Cleared everything (destructive)'"
          />
          <button class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors" @click="showDestructive">
            Show Destructive Alert
          </button>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Custom Button Styles</h2>
        <p class="text-fg-secondary mb-4">Pass JSON strings into text-style props.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-alert
            ref="customStyleRef"
            title="Custom Styling"
            message="Buttons can have custom colors, font sizes, and weights."
            cancel-text="No Thanks"
            cancel-text-style='{"color":"#FF3B30","fontSize":16,"fontWeight":"normal"}'
            confirm-text="Proceed"
            confirm-text-style='{"color":"#007AFF","fontSize":18,"fontWeight":"bold"}'
            @cancel="lastAction = 'Declined with custom style'"
            @confirm="lastAction = 'Proceeded with custom style'"
          />
          <button class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors" @click="showCustomStyle">
            Show Custom Styled Alert
          </button>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Imperative API</h2>
        <p class="text-fg-secondary mb-4">Use a ref to call <code>show()</code> and override title/message per call.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-alert
            ref="imperativeRef"
            title="Default Title"
            message="Default message content."
            confirm-text="Got it"
            @confirm="lastAction = 'Confirmed via imperative API'"
          />
          <div class="flex gap-3 flex-wrap">
            <button
              class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
              @click="imperativeRef?.show({ title: 'Default', message: 'Using default props' })"
            >
              Show with Default
            </button>
            <button
              class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
              @click="imperativeRef?.show({ title: 'Success!', message: 'Operation completed successfully.' })"
            >
              Show Success
            </button>
            <button
              class="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
              @click="imperativeRef?.show({ title: 'Warning', message: 'Please check your input.' })"
            >
              Show Warning
            </button>
          </div>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

