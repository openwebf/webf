<script setup lang="ts">
import { ref } from 'vue';
import type {
  FlutterCupertinoActionSheetElement,
  FlutterCupertinoActionSheetSelectDetail,
} from '@openwebf/vue-cupertino-ui';

const lastAction = ref('');

const basicRef = ref<FlutterCupertinoActionSheetElement | null>(null);
const destructiveRef = ref<FlutterCupertinoActionSheetElement | null>(null);
const multiRef = ref<FlutterCupertinoActionSheetElement | null>(null);
const noCancelRef = ref<FlutterCupertinoActionSheetElement | null>(null);
const customEventsRef = ref<FlutterCupertinoActionSheetElement | null>(null);

function onSelect(e: CustomEvent<FlutterCupertinoActionSheetSelectDetail>) {
  lastAction.value = `Selected: ${e.detail.text} (index: ${e.detail.index ?? '-'})`;
}

function showBasic() {
  basicRef.value?.show({
    title: 'Choose an Option',
    message: 'Select one of the following actions',
    actions: [
      { text: 'Option 1', event: 'option1' },
      { text: 'Option 2', event: 'option2' },
      { text: 'Option 3', event: 'option3' },
    ],
    cancelButton: { text: 'Cancel', event: 'cancel' },
  });
}

function showDestructive() {
  destructiveRef.value?.show({
    title: 'Delete Photo?',
    message: 'This photo will be permanently deleted from your library.',
    actions: [{ text: 'Delete Photo', event: 'delete', isDestructive: true }],
    cancelButton: { text: 'Cancel', event: 'cancel' },
  });
}

function showMulti() {
  multiRef.value?.show({
    title: 'Share Photo',
    message: 'Choose how to share this photo',
    actions: [
      { text: 'Message', event: 'message', isDefault: true },
      { text: 'Mail', event: 'mail' },
      { text: 'AirDrop', event: 'airdrop' },
      { text: 'Save to Files', event: 'files' },
      { text: 'Delete', event: 'delete', isDestructive: true },
    ],
    cancelButton: { text: 'Cancel', event: 'cancel' },
  });
}

function showNoCancel() {
  noCancelRef.value?.show({
    title: 'Select Size',
    message: 'Choose the size for your order',
    actions: [
      { text: 'Small', event: 'small' },
      { text: 'Medium', event: 'medium', isDefault: true },
      { text: 'Large', event: 'large' },
      { text: 'Extra Large', event: 'xlarge' },
    ],
  });
}

function showCustomEvents() {
  customEventsRef.value?.show({
    title: 'Document Options',
    actions: [
      { text: 'Edit', event: 'edit', isDefault: true },
      { text: 'Duplicate', event: 'duplicate' },
      { text: 'Share', event: 'share' },
      { text: 'Archive', event: 'archive' },
      { text: 'Delete', event: 'delete', isDestructive: true },
    ],
    cancelButton: { text: 'Cancel', event: 'cancel' },
  });
}

function onSelectCustom(e: CustomEvent<FlutterCupertinoActionSheetSelectDetail>) {
  const eventMap: Record<string, string> = {
    edit: 'Opening editor...',
    duplicate: 'Creating duplicate...',
    share: 'Opening share sheet...',
    archive: 'Moving to archive...',
    delete: 'Deleting item...',
    cancel: 'Cancelled',
  };
  lastAction.value = eventMap[e.detail.event] || `Unknown event: ${e.detail.event}`;
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Action Sheet</h1>
      <p class="text-fg-secondary mb-6">iOS-style bottom sheet with multiple action options.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic Action Sheet</h2>
        <p class="text-fg-secondary mb-4">Title, message, actions, and a cancel button.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-action-sheet ref="basicRef" @select="onSelect" />
          <button class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors" @click="showBasic">
            Show Basic Action Sheet
          </button>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Destructive Actions</h2>
        <p class="text-fg-secondary mb-4">Destructive actions are shown in red.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-action-sheet
            ref="destructiveRef"
            @select="
              (e) => {
                lastAction = e.detail.isDestructive ? `Destructive action: ${e.detail.text}` : `Selected: ${e.detail.text}`;
              }
            "
          />
          <button class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors" @click="showDestructive">
            Show Destructive Action
          </button>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Multiple Actions</h2>
        <p class="text-fg-secondary mb-4">Default and destructive styling in the same sheet.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-action-sheet ref="multiRef" @select="onSelect" />
          <button class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors" @click="showMulti">
            Show Multi-Action Sheet
          </button>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Without Cancel Button</h2>
        <p class="text-fg-secondary mb-4">Omit the cancel button to require selection.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-action-sheet ref="noCancelRef" @select="onSelect" />
          <button class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors" @click="showNoCancel">
            Show Without Cancel
          </button>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Custom Event Handling</h2>
        <p class="text-fg-secondary mb-4">Use action <code>event</code> to drive app behavior.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <flutter-cupertino-action-sheet ref="customEventsRef" @select="onSelectCustom" />
          <button class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors" @click="showCustomEvents">
            Show Document Options
          </button>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

