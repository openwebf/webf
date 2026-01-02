<script setup lang="ts">
import { ref } from 'vue';
import type { FlutterCupertinoModalPopupElement } from '@openwebf/vue-cupertino-ui';

const basicPopupRef = ref<FlutterCupertinoModalPopupElement | null>(null);
const propsPopupRef = ref<FlutterCupertinoModalPopupElement | null>(null);
const noMaskPopupRef = ref<FlutterCupertinoModalPopupElement | null>(null);
const styledPopupRef = ref<FlutterCupertinoModalPopupElement | null>(null);

const lastClosed = ref<string | null>(null);

function handleClose(source: string) {
  lastClosed.value = source;
  console.log('popup closed', source);
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Modal Popup</h1>
      <p class="text-fg-secondary mb-6">
        Present an iOS-style modal bottom sheet using <code>&lt;flutter-cupertino-modal-popup&gt;</code> controlled via
        <code>show()</code>/<code>hide()</code>.
      </p>

      <flutter-cupertino-modal-popup ref="basicPopupRef" :height="250" @close="() => handleClose('basic popup')">
        <div class="p-5">
          <div class="text-lg font-semibold mb-2">Modal Popup</div>
          <div class="text-sm text-gray-600 mb-4">
            This content is rendered inside a Cupertino-style bottom sheet.
          </div>
          <flutter-cupertino-button variant="filled" @click="basicPopupRef?.hide()">Close</flutter-cupertino-button>
        </div>
      </flutter-cupertino-modal-popup>

      <flutter-cupertino-modal-popup
        ref="propsPopupRef"
        :height="320"
        :mask-closable="false"
        :background-opacity="0.25"
        @close="() => handleClose('props demo')"
      >
        <div class="p-5 space-y-3">
          <div class="text-lg font-semibold">Props Demo</div>
          <div class="text-sm text-gray-600">
            Fixed height, background opacity, and <code>mask-closable=false</code>.
          </div>
          <flutter-cupertino-button variant="filled" @click="propsPopupRef?.hide()">Close</flutter-cupertino-button>
        </div>
      </flutter-cupertino-modal-popup>

      <flutter-cupertino-modal-popup
        ref="noMaskPopupRef"
        :height="280"
        :mask-closable="false"
        @close="() => handleClose('no-mask')"
      >
        <div class="p-5 space-y-3">
          <div class="text-lg font-semibold">Non-maskClosable Popup</div>
          <div class="text-sm text-gray-600">Mask taps are ignored; close it using the button below.</div>
          <flutter-cupertino-button variant="filled" @click="noMaskPopupRef?.hide()">Close</flutter-cupertino-button>
        </div>
      </flutter-cupertino-modal-popup>

      <flutter-cupertino-modal-popup
        ref="styledPopupRef"
        :height="300"
        :surface-painted="false"
        :background-opacity="0.15"
        @close="() => handleClose('styled popup')"
      >
        <div class="p-5">
          <div class="rounded-xl border border-line bg-white p-4">
            <div class="text-lg font-semibold mb-2">Custom Surface</div>
            <div class="text-sm text-gray-600 mb-3">Surface painting disabled; content draws its own card.</div>
            <flutter-cupertino-button variant="tinted" @click="styledPopupRef?.hide()">Done</flutter-cupertino-button>
          </div>
        </div>
      </flutter-cupertino-modal-popup>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
          <flutter-cupertino-button variant="filled" @click="basicPopupRef?.show()">Show Modal Popup</flutter-cupertino-button>
          <div class="text-sm text-fg-secondary">Dismiss by tapping the mask, or using the close button inside.</div>
          <div v-if="lastClosed" class="text-xs px-3 py-2 rounded bg-blue-50 text-blue-800">Last closed: {{ lastClosed }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Variants</h2>
        <div class="grid md:grid-cols-2 gap-4">
          <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-3">
            <h3 class="font-semibold text-fg-primary text-sm">Props Demo</h3>
            <div class="text-xs text-fg-secondary">Fixed height, custom opacity, and mask-close disabled.</div>
            <flutter-cupertino-button variant="filled" @click="propsPopupRef?.show()">Show Props Demo</flutter-cupertino-button>
          </div>
          <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-3">
            <h3 class="font-semibold text-fg-primary text-sm">Non-maskClosable</h3>
            <div class="text-xs text-fg-secondary">Close only from inside.</div>
            <flutter-cupertino-button variant="filled" @click="noMaskPopupRef?.show()">Show non-maskClosable</flutter-cupertino-button>
          </div>
          <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-3">
            <h3 class="font-semibold text-fg-primary text-sm">Custom Surface</h3>
            <div class="text-xs text-fg-secondary">Disable surface painting and adjust mask opacity.</div>
            <flutter-cupertino-button variant="filled" @click="styledPopupRef?.show()">Show custom styled popup</flutter-cupertino-button>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

