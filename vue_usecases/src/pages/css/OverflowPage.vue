<script setup lang="ts">
const longText = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. '.repeat(6);
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">Overflow</h1>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-4">
        <div class="font-medium text-fg-primary">overflow: hidden</div>
        <div class="text-sm text-fg-secondary mb-2">Content clipped, no scrollbars.</div>
        <div class="flex gap-3 flex-wrap">
          <div class="w-40 h-24 border border-dashed border-line rounded bg-surface overflow-hidden">
            <div class="w-60">{{ longText }}</div>
          </div>
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-4">
        <div class="font-medium text-fg-primary">overflow: auto</div>
        <div class="text-sm text-fg-secondary mb-2">Scrollbars appear when needed.</div>
        <div class="flex gap-3 flex-wrap">
          <div class="w-40 h-24 border border-dashed border-line rounded bg-surface overflow-auto">
            <div class="w-60">{{ longText }}</div>
          </div>
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <div class="font-medium text-fg-primary">overflow: scroll</div>
        <div class="text-sm text-fg-secondary mb-2">Scrollbars are always shown.</div>
        <div class="flex gap-3 flex-wrap">
          <div class="w-40 h-24 border border-dashed border-line rounded bg-surface overflow-scroll">
            <div class="w-60">{{ longText }}</div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
