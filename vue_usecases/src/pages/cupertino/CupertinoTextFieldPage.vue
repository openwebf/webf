<script setup lang="ts">
import { ref } from 'vue';
import type { FlutterCupertinoInputElement } from '@openwebf/vue-cupertino-ui';

const basicValue = ref('');
const boundValue = ref('Initial input content');
const passwordValue = ref('');
const emailValue = ref('');
const numberValue = ref('');
const maxValue = ref('');
const readonlyValue = ref('Read-only value');

const eventValue = ref('');
const eventLog = ref<string[]>([]);

const imperativeRef = ref<FlutterCupertinoInputElement | null>(null);

function addEventLog(message: string) {
  eventLog.value = [message, ...eventLog.value].slice(0, 5);
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Text Field</h1>
      <p class="text-fg-secondary mb-6">iOS-style single-line input backed by Flutter's <code>CupertinoTextField</code>.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
        <p class="text-fg-secondary mb-4">Bind <code>val</code> and handle <code>input</code>.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-4 space-y-4">
            <flutter-cupertino-input :val="basicValue" placeholder="Enter content" @input="(e) => (basicValue = e.detail)" />
            <div class="text-sm text-fg-secondary">Current value: <span class="font-mono">{{ basicValue || '(empty)' }}</span></div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Types & Basic Props</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <div>
            <div class="text-sm font-semibold text-fg-primary mb-2">Controlled Value</div>
            <flutter-cupertino-input :val="boundValue" placeholder="Enter content" @input="(e) => (boundValue = e.detail)" />
            <div class="mt-2 text-xs text-fg-secondary">Bound value: <span class="font-mono">{{ boundValue }}</span></div>
          </div>

          <div class="grid md:grid-cols-2 gap-4">
            <div>
              <div class="text-sm font-semibold text-fg-primary mb-1">Password</div>
              <flutter-cupertino-input type="password" :val="passwordValue" placeholder="Enter password" clearable @input="(e) => (passwordValue = e.detail)" />
            </div>
            <div>
              <div class="text-sm font-semibold text-fg-primary mb-1">Email</div>
              <flutter-cupertino-input type="email" :val="emailValue" placeholder="name@example.com" @input="(e) => (emailValue = e.detail)" />
            </div>
            <div>
              <div class="text-sm font-semibold text-fg-primary mb-1">Number</div>
              <flutter-cupertino-input type="number" :val="numberValue" placeholder="123" @input="(e) => (numberValue = e.detail)" />
            </div>
            <div>
              <div class="text-sm font-semibold text-fg-primary mb-1">Read-only</div>
              <flutter-cupertino-input :val="readonlyValue" readonly placeholder="Read-only" @input="(e) => (readonlyValue = e.detail)" />
            </div>
            <div>
              <div class="text-sm font-semibold text-fg-primary mb-1">Disabled</div>
              <flutter-cupertino-input val="Disabled input" disabled placeholder="Disabled" />
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Prefix & Suffix</h2>
        <p class="text-fg-secondary mb-4">Provide named slots via standard web-component slot attributes.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <div>
            <div class="text-sm font-semibold text-fg-primary mb-1">Amount with Prefix</div>
            <flutter-cupertino-input placeholder="Amount">
              <span slot="prefix" class="text-sm text-gray-700">$</span>
            </flutter-cupertino-input>
          </div>
          <div>
            <div class="text-sm font-semibold text-fg-primary mb-1">Domain with Prefix + Suffix</div>
            <flutter-cupertino-input placeholder="Domain" style="margin-top: 12px;">
              <span slot="prefix" class="text-sm text-gray-500">https://</span>
              <span slot="suffix" class="text-sm text-gray-500">.com</span>
            </flutter-cupertino-input>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Clearable & Max Length</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <div>
            <div class="text-sm font-semibold text-fg-primary mb-1">Clearable Field</div>
            <flutter-cupertino-input
              clearable
              :val="eventValue"
              placeholder="Try typing, then tap clear"
              @input="
                (e) => {
                  eventValue = e.detail;
                  addEventLog(`input: ${e.detail}`);
                }
              "
              @clear="
                () => {
                  eventValue = '';
                  addEventLog('clear');
                }
              "
            />
          </div>
          <div>
            <div class="text-sm font-semibold text-fg-primary mb-1">Max Length (10)</div>
            <flutter-cupertino-input :maxlength="10" clearable :val="maxValue" placeholder="Max 10 characters" @input="(e) => (maxValue = e.detail)" />
            <div class="mt-1 text-xs text-fg-secondary">{{ maxValue.length }}/10 characters</div>
          </div>
          <div v-if="eventLog.length" class="p-3 bg-gray-50 rounded-lg">
            <div class="text-sm font-semibold mb-2">Event Log</div>
            <div class="space-y-1">
              <div v-for="(line, idx) in eventLog" :key="idx" class="text-xs font-mono text-gray-700">{{ line }}</div>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Imperative API</h2>
        <p class="text-fg-secondary mb-4">Use a ref to call <code>focus()</code>, <code>blur()</code>, and <code>clear()</code>.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-3">
          <flutter-cupertino-input ref="imperativeRef" placeholder="Imperative control" />
          <div class="flex flex-wrap gap-2">
            <button class="px-3 py-1.5 text-sm rounded-lg bg-blue-500 text-white hover:bg-blue-600 transition-colors" @click="imperativeRef?.focus()">
              Focus
            </button>
            <button class="px-3 py-1.5 text-sm rounded-lg bg-gray-200 text-gray-800 hover:bg-gray-300 transition-colors" @click="imperativeRef?.blur()">
              Blur
            </button>
            <button class="px-3 py-1.5 text-sm rounded-lg bg-red-500 text-white hover:bg-red-600 transition-colors" @click="imperativeRef?.clear()">
              Clear
            </button>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>
