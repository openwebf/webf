<script setup lang="ts">
import { computed, ref } from 'vue';
import type { FlutterCupertinoTextFormFieldRowElement } from '@openwebf/vue-cupertino-ui';

const accountName = ref('');
const boundValue = ref('Initial row value');
const profileEmail = ref('');
const emailError = ref<string | null>(null);
const eventLog = ref<string[]>([]);

const rowRef = ref<FlutterCupertinoTextFormFieldRowElement | null>(null);

function addEventLog(message: string) {
  eventLog.value = [message, ...eventLog.value].slice(0, 5);
}

function handleEmailBlur() {
  if (profileEmail.value && !profileEmail.value.includes('@')) emailError.value = 'Invalid email address';
  else emailError.value = null;
}

const emailHelper = computed(() => (profileEmail.value ? 'We will send a confirmation link.' : 'Enter an email address.'));
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino TextFormFieldRow</h1>
      <p class="text-fg-secondary mb-6">Inline, borderless Cupertino text field embedded inside a form row.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-2xl overflow-hidden">
            <flutter-cupertino-text-form-field-row :val="accountName" placeholder="Enter account name" @input="(e) => (accountName = e.detail)">
              <span slot="prefix" class="text-sm text-gray-700">Account</span>
            </flutter-cupertino-text-form-field-row>
          </div>
          <div class="mt-3 text-sm text-fg-secondary">Current name: <span class="font-mono">{{ accountName || '(empty)' }}</span></div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Common Props</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <div class="bg-white rounded-2xl overflow-hidden divide-y divide-gray-200">
            <flutter-cupertino-text-form-field-row :val="boundValue" placeholder="Bound value" @input="(e) => (boundValue = e.detail)">
              <span slot="prefix" class="text-sm text-gray-700">Bound</span>
            </flutter-cupertino-text-form-field-row>

            <flutter-cupertino-text-form-field-row type="email" :val="profileEmail" placeholder="name@example.com" @input="(e) => (profileEmail = e.detail)" @blur="handleEmailBlur">
              <span slot="prefix" class="text-sm text-gray-700">Email</span>
              <span slot="helper" class="block mt-1 text-xs text-gray-500">{{ emailHelper }}</span>
              <span v-if="emailError" slot="error" class="block mt-1 text-xs text-red-600">{{ emailError }}</span>
            </flutter-cupertino-text-form-field-row>

            <flutter-cupertino-text-form-field-row val="Disabled row" placeholder="Disabled" disabled>
              <span slot="prefix" class="text-sm text-gray-700">Disabled</span>
            </flutter-cupertino-text-form-field-row>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Events + Imperative API</h2>
        <p class="text-fg-secondary mb-4">The row exposes input/submit/focus/blur/clear and focus()/blur()/clear().</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-3">
          <div class="bg-white rounded-2xl overflow-hidden">
            <flutter-cupertino-text-form-field-row
              ref="rowRef"
              placeholder="Type and press Enter / clear"
              @input="(e) => addEventLog(`input: ${e.detail}`)"
              @submit="(e) => addEventLog(`submit: ${e.detail}`)"
              @focus="() => addEventLog('focus')"
              @blur="() => addEventLog('blur')"
              @clear="() => addEventLog('clear')"
              clearable
            >
              <span slot="prefix" class="text-sm text-gray-700">Log</span>
            </flutter-cupertino-text-form-field-row>
          </div>
          <div class="flex flex-wrap gap-2">
            <button class="px-3 py-1.5 text-sm rounded-lg bg-blue-500 text-white hover:bg-blue-600 transition-colors" @click="rowRef?.focus()">
              Focus
            </button>
            <button class="px-3 py-1.5 text-sm rounded-lg bg-gray-200 text-gray-800 hover:bg-gray-300 transition-colors" @click="rowRef?.blur()">
              Blur
            </button>
            <button class="px-3 py-1.5 text-sm rounded-lg bg-red-500 text-white hover:bg-red-600 transition-colors" @click="rowRef?.clear()">
              Clear
            </button>
          </div>
          <div v-if="eventLog.length" class="mt-2 p-3 bg-gray-50 rounded-lg">
            <div class="text-sm font-semibold mb-2">Event Log (last 5)</div>
            <div class="space-y-1">
              <div v-for="(line, idx) in eventLog" :key="idx" class="text-xs font-mono text-gray-700">{{ line }}</div>
            </div>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

