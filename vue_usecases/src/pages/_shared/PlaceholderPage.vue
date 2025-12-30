<script setup lang="ts">
import PageScaffold from './PageScaffold.vue';

defineProps<{
  title: string;
  source?: string;
}>();
</script>

<template>
  <PageScaffold :title="title" description="TODO: port this page from react_use_cases">
    <div class="rounded-lg border border-white/10 bg-black/20 p-4 text-sm">
      <div class="opacity-80">Placeholder page.</div>
      <div v-if="source" class="mt-2 font-mono text-xs opacity-80">{{ source }}</div>
    </div>
  </PageScaffold>
</template>

