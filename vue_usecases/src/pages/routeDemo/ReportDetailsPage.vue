<script setup lang="ts">
import { computed } from 'vue';
import { useLocation, useParams, WebFRouter } from '@openwebf/vue-router';

const params = useParams();
const location = useLocation();

const reportId = computed(() => {
  const p = params.value as any;
  return params.value.id ?? p.reportId ?? (location.value.state as any)?.reportId;
});
</script>

<template>
  <webf-list-view class="p-5 bg-surface-secondary rounded-xl mb-5 border border-line">
    <h1 class="text-2xl font-semibold mb-4 text-fg-primary">Report Details</h1>

    <div class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Report Parameters:</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <p class="mb-2 font-mono text-fg"><strong>Year:</strong> {{ params.year || 'Not provided' }}</p>
        <p class="mb-2 font-mono text-fg"><strong>Month:</strong> {{ params.month || 'Not provided' }}</p>
        <p class="mb-0 font-mono text-fg"><strong>Report ID:</strong> {{ reportId || 'Not provided' }}</p>
      </div>
    </div>

    <div class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Report Information:</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <h3 class="text-sm mb-2 text-fg-secondary">Period</h3>
            <p class="text-base m-0 text-fg">{{ params.month || '--' }}/{{ params.year || '--' }}</p>
          </div>
          <div>
            <h3 class="text-sm mb-2 text-fg-secondary">Department</h3>
            <p class="text-base m-0 capitalize text-fg">{{ (location.state as any)?.department || 'Not specified' }}</p>
          </div>
          <div>
            <h3 class="text-sm mb-2 text-fg-secondary">Format</h3>
            <p class="text-base m-0 uppercase text-fg">{{ (location.state as any)?.format || 'Not specified' }}</p>
          </div>
          <div>
            <h3 class="text-sm mb-2 text-fg-secondary">Report ID</h3>
            <p class="text-base m-0 font-mono text-fg">{{ reportId || '--' }}</p>
          </div>
        </div>
      </div>
    </div>

    <div class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Navigation State:</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <pre class="m-0 text-xs font-mono whitespace-pre-wrap text-fg">{{ JSON.stringify(location.state, null, 2) }}</pre>
      </div>
    </div>

    <div class="flex">
      <button
        class="bg-[#007aff] hover:bg-[#006fe6] text-white border-0 rounded-lg py-3 px-6 text-base cursor-pointer transition-colors active:scale-[.98]"
        @click="WebFRouter.pop()"
      >
        Back
      </button>
    </div>
  </webf-list-view>
</template>
