<script setup lang="ts">
import { ref } from 'vue';
import type { FlutterCupertinoActionSheetElement, FlutterCupertinoActionSheetSelectDetail } from '@openwebf/vue-cupertino-ui';

const basicActionSheetRef = ref<FlutterCupertinoActionSheetElement | null>(null);
const destructiveActionSheetRef = ref<FlutterCupertinoActionSheetElement | null>(null);
const customActionSheetRef = ref<FlutterCupertinoActionSheetElement | null>(null);
const longListActionSheetRef = ref<FlutterCupertinoActionSheetElement | null>(null);

function showBasicActionSheet() {
  basicActionSheetRef.value?.show({
    title: 'Choose an Option',
    message: 'Select one of the options below',
    actions: [
      { text: 'Option 1', event: 'action', value: 'option1' },
      { text: 'Option 2', event: 'action', value: 'option2' },
      { text: 'Option 3', event: 'action', value: 'option3' },
    ],
    cancelButton: { text: 'Cancel', event: 'cancel' },
  } as any);
}

function showDestructiveActionSheet() {
  destructiveActionSheetRef.value?.show({
    title: 'Delete Item',
    message: 'This action cannot be undone',
    actions: [
      { text: 'Edit Item', event: 'action', value: 'edit' },
      { text: 'Duplicate Item', event: 'action', value: 'duplicate' },
      { text: 'Delete Item', event: 'action', value: 'delete', isDestructive: true },
    ],
    cancelButton: { text: 'Cancel', event: 'cancel' },
  } as any);
}

function showCustomActionSheet() {
  customActionSheetRef.value?.show({
    title: 'Share Options',
    actions: [
      { text: 'Copy Link', event: 'action', value: 'copy', icon: 'doc_on_doc' },
      { text: 'Send via Email', event: 'action', value: 'email', icon: 'mail' },
      { text: 'Send via Message', event: 'action', value: 'message', icon: 'message' },
      { text: 'Share on Social Media', event: 'action', value: 'social', icon: 'share' },
    ],
    cancelButton: { text: 'Cancel', event: 'cancel' },
  } as any);
}

function showLongListActionSheet() {
  longListActionSheetRef.value?.show({
    title: 'Select Country',
    message: 'Choose your country from the list',
    actions: [
      { text: 'United States', event: 'action', value: 'us' },
      { text: 'United Kingdom', event: 'action', value: 'uk' },
      { text: 'Canada', event: 'action', value: 'ca' },
      { text: 'Australia', event: 'action', value: 'au' },
      { text: 'Germany', event: 'action', value: 'de' },
      { text: 'France', event: 'action', value: 'fr' },
      { text: 'Italy', event: 'action', value: 'it' },
      { text: 'Spain', event: 'action', value: 'es' },
      { text: 'Japan', event: 'action', value: 'jp' },
      { text: 'South Korea', event: 'action', value: 'kr' },
      { text: 'China', event: 'action', value: 'cn' },
      { text: 'India', event: 'action', value: 'in' },
    ],
    cancelButton: { text: 'Cancel', event: 'cancel' },
  } as any);
}

function handleAction(event: CustomEvent<FlutterCupertinoActionSheetSelectDetail>) {
  console.log('Action selected:', event.detail);
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">Action Sheet Showcase</h1>
      <div class="flex flex-col gap-4">
        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">Basic Action Sheet</div>
          <div class="text-sm text-fg-secondary mb-3">Simple action sheet with multiple options and cancel button</div>
          <div class="bg-surface border border-line rounded p-3">
            <flutter-cupertino-button variant="filled" @click="showBasicActionSheet">
              Show Basic Action Sheet
            </flutter-cupertino-button>

            <flutter-cupertino-action-sheet ref="basicActionSheetRef" @select="handleAction" />
          </div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">Destructive Action Sheet</div>
          <div class="text-sm text-fg-secondary mb-3">Action sheet with destructive actions highlighted in red</div>
          <div class="bg-surface border border-line rounded p-3">
            <flutter-cupertino-button variant="filled" @click="showDestructiveActionSheet">
              Show Destructive Actions
            </flutter-cupertino-button>

            <flutter-cupertino-action-sheet ref="destructiveActionSheetRef" @select="handleAction" />
          </div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">Custom Action Sheet</div>
          <div class="text-sm text-fg-secondary mb-3">Action sheet with icons and custom styling</div>
          <div class="bg-surface border border-line rounded p-3">
            <flutter-cupertino-button variant="filled" @click="showCustomActionSheet">
              Show Custom Action Sheet
            </flutter-cupertino-button>

            <flutter-cupertino-action-sheet ref="customActionSheetRef" @select="handleAction" />
          </div>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary">Long List Action Sheet</div>
          <div class="text-sm text-fg-secondary mb-3">Action sheet with many options that can scroll</div>
          <div class="bg-surface border border-line rounded p-3">
            <flutter-cupertino-button variant="filled" @click="showLongListActionSheet">Show Long List</flutter-cupertino-button>

            <flutter-cupertino-action-sheet ref="longListActionSheetRef" @select="handleAction" />
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
