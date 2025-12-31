<script setup lang="ts">
import type { Component } from 'vue';

const props = withDefaults(
  defineProps<{
    title: string;
    description?: string;
    demo: Component;
    basePath?: string;
  }>(),
  {
    description: '',
    basePath: '/routing',
  },
);
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="min-h-screen w-full px-3 md:px-6 py-6 box-border">
      <div class="bg-surface-secondary rounded-2xl border border-line p-5 mb-5">
        <div class="text-2xl font-semibold text-fg-primary mb-2">{{ props.title }}</div>
        <div v-if="props.description" class="text-sm text-fg-secondary leading-relaxed">
          {{ props.description }}
        </div>
      </div>

      <div class="rounded-2xl border border-line bg-surface-secondary p-4 md:p-6 box-border">
        <component :is="props.demo" :basePath="props.basePath" />
      </div>
    </webf-list-view>
  </div>
</template>
