<script setup lang="ts">
import { computed } from 'vue';
import { useLocation, WebFRouter } from '@openwebf/vue-router';

const location = useLocation();

const formData = computed(() => (location.value.state as any)?.formData);
const sessionInfo = computed(() => location.value.state as any);
const lastModifiedText = computed(() => {
  const lastModified = (location.value.state as any)?.lastModified;
  if (!lastModified) return null;
  return new Date(lastModified).toLocaleString();
});
</script>

<template>
  <webf-list-view class="p-5 bg-surface-secondary rounded-xl mb-5 border border-line">
    <h1 class="text-2xl font-semibold mb-4 text-fg-primary">Edit Profile</h1>

    <div class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Deep Link Navigation Demo</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <p class="mb-2 text-fg-secondary">This page demonstrates direct deep-link navigation.</p>
        <p class="mb-0 text-fg-secondary">When you click "Back", it will pop back to the previous route (if any).</p>
      </div>
    </div>

    <div v-if="formData" class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Form Data:</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <p class="mb-2 font-mono text-fg"><strong>Name:</strong> {{ formData.name || 'Not provided' }}</p>
        <p class="mb-2 font-mono text-fg"><strong>Email:</strong> {{ formData.email || 'Not provided' }}</p>
        <div v-if="formData.preferences" class="mt-3">
          <p class="mb-2 font-semibold text-fg">Preferences:</p>
          <div class="pl-4">
            <p class="mb-1 font-mono text-fg"><strong>Theme:</strong> {{ formData.preferences.theme }}</p>
            <p class="mb-0 font-mono text-fg"><strong>Language:</strong> {{ formData.preferences.language }}</p>
          </div>
        </div>
      </div>
    </div>

    <div class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Session Information:</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <p v-if="sessionInfo?.editMode !== undefined" class="mb-2 font-mono text-fg">
          <strong>Edit Mode:</strong> {{ sessionInfo.editMode ? 'Enabled' : 'Disabled' }}
        </p>
        <p v-if="sessionInfo?.scrollPosition !== undefined" class="mb-2 font-mono text-fg">
          <strong>Scroll Position:</strong> {{ sessionInfo.scrollPosition }}px
        </p>
        <p v-if="lastModifiedText" class="mb-0 font-mono text-fg"><strong>Last Modified:</strong> {{ lastModifiedText }}</p>
      </div>
    </div>

    <div class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Complete State:</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <pre class="m-0 text-xs font-mono whitespace-pre-wrap text-fg">{{ JSON.stringify(location.state, null, 2) }}</pre>
      </div>
    </div>

    <button
      class="bg-[#007aff] hover:bg-[#006fe6] text-white border-0 rounded-lg py-3 px-6 text-base cursor-pointer transition-colors active:scale-[.98]"
      @click="WebFRouter.pop()"
    >
      Back
    </button>
  </webf-list-view>
</template>
