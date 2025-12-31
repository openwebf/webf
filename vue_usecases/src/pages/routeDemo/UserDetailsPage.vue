<script setup lang="ts">
import { computed } from 'vue';
import { useLocation, useParams, WebFRouter } from '@openwebf/vue-router';

const params = useParams();
const location = useLocation();

const userId = computed(() => params.value.id ?? 'Not provided');
const userType = computed(() => (params.value as any).userType as string | undefined);
</script>

<template>
  <webf-list-view class="p-5 bg-surface-secondary rounded-xl mb-5 border border-line">
    <h1 class="text-2xl font-semibold mb-4 text-fg-primary">User Details</h1>

    <div class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Route Parameters:</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <p class="mb-2 font-mono text-fg"><strong>userId:</strong> {{ userId }}</p>
        <p v-if="userType" class="font-mono text-fg"><strong>userType:</strong> {{ userType }}</p>
      </div>
    </div>

    <div class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Location State:</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <pre class="m-0 text-xs font-mono whitespace-pre-wrap text-fg">{{ JSON.stringify(location.state, null, 2) }}</pre>
      </div>
    </div>

    <div class="mb-5">
      <h2 class="text-lg font-semibold mb-3 text-fg-primary">Current Path:</h2>
      <div class="bg-surface-tertiary p-4 rounded-lg border border-line">
        <p class="m-0 font-mono text-fg">{{ location.pathname }}</p>
      </div>
    </div>

    <div class="flex flex-wrap gap-3">
      <button
        class="bg-[#007aff] hover:bg-[#006fe6] text-white border-0 rounded-lg py-3 px-6 text-base cursor-pointer transition-colors active:scale-[.98]"
        @click="WebFRouter.pop()"
      >
        Back
      </button>
      <button
        class="bg-[#007aff] hover:bg-[#006fe6] text-white border-0 rounded-lg py-3 px-6 text-base cursor-pointer transition-colors active:scale-[.98]"
        @click="WebFRouter.pushState({}, '/user/888')"
      >
        Go User Details 888
      </button>
    </div>
  </webf-list-view>
</template>
