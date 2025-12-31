<script setup lang="ts">
import { ref } from 'vue';
import type { FlutterCupertinoAlertElement } from '@openwebf/vue-cupertino-ui';

const basicAlertRef = ref<FlutterCupertinoAlertElement | null>(null);
const confirmAlertRef = ref<FlutterCupertinoAlertElement | null>(null);
const customAlertRef = ref<FlutterCupertinoAlertElement | null>(null);
const destructiveAlertRef = ref<FlutterCupertinoAlertElement | null>(null);
const defaultButtonAlertRef = ref<FlutterCupertinoAlertElement | null>(null);

function showBasicAlert() {
  basicAlertRef.value?.show({});
}
function showConfirmAlert() {
  confirmAlertRef.value?.show({});
}
function showCustomAlert() {
  customAlertRef.value?.show({});
}
function showDestructiveAlert() {
  destructiveAlertRef.value?.show({});
}
function showDefaultButtonAlert() {
  defaultButtonAlertRef.value?.show({});
}

function onCancel() {
  console.log('Operation cancelled');
}
function onConfirm() {
  console.log('Operation confirmed');
}
function onDelete() {
  console.log('Executing delete operation');
}
function onLater() {
  console.log('Postponed');
}
function onUpdate() {
  console.log('Executing update operation');
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">Alert</h1>
      <div class="flex flex-col gap-4">
        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary mb-2">Basic Usage</div>
          <flutter-cupertino-button variant="filled" @click="showBasicAlert">Show Basic Alert</flutter-cupertino-button>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary mb-2">With Title and Buttons</div>
          <flutter-cupertino-button variant="filled" @click="showConfirmAlert">Show Confirm Alert</flutter-cupertino-button>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary mb-2">With Title and Message</div>
          <flutter-cupertino-button variant="filled" @click="showCustomAlert">Show Title and Message</flutter-cupertino-button>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary mb-2">Destructive Action</div>
          <flutter-cupertino-button variant="filled" @click="showDestructiveAlert">Show Destructive Alert</flutter-cupertino-button>
        </div>

        <div class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="text-lg font-medium text-fg-primary mb-2">Default Button</div>
          <flutter-cupertino-button variant="filled" @click="showDefaultButtonAlert">
            Show Default Button Alert
          </flutter-cupertino-button>
        </div>
      </div>
    </webf-list-view>

    <flutter-cupertino-alert ref="basicAlertRef" title="This is a Basic Alert" confirm-text="Got it" />

    <flutter-cupertino-alert
      ref="confirmAlertRef"
      title="Are you sure you want to proceed?"
      cancel-text="Cancel"
      confirm-text="Confirm"
      @cancel="onCancel"
      @confirm="onConfirm"
    />

    <flutter-cupertino-alert
      ref="customAlertRef"
      title="Operation Notice"
      message="This is an important notice, please read carefully"
      confirm-text="Got it"
    />

    <flutter-cupertino-alert
      ref="destructiveAlertRef"
      title="Delete Confirmation"
      message="Data cannot be recovered after deletion. Do you want to continue?"
      cancel-text="Cancel"
      confirm-text="Delete"
      confirm-destructive
      @cancel="onCancel"
      @confirm="onDelete"
    />

    <flutter-cupertino-alert
      ref="defaultButtonAlertRef"
      title="Choose Action"
      message="Please select the action to perform"
      cancel-text="Later"
      confirm-text="Update Now"
      cancel-default
      @cancel="onLater"
      @confirm="onUpdate"
    />
  </div>
</template>
