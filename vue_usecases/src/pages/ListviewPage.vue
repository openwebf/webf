<script setup lang="ts">
import { computed, ref } from 'vue';
import type { WebFListViewElement } from '@openwebf/vue-core-ui';

type FinishResult = 'success' | 'fail' | 'noMore';
const delay = (ms: number) => new Promise<void>((resolve) => setTimeout(resolve, ms));

const listRef = ref<WebFListViewElement | null>(null);

const scrollDirection = ref<'vertical' | 'horizontal'>('vertical');
const shrinkWrap = ref(false);
const refreshStyle = ref<'default' | 'customCupertino'>('customCupertino');

const items = ref<number[]>(Array.from({ length: 60 }, (_, i) => i + 1));
const hasMore = ref(true);
const isRefreshing = ref(false);
const isLoadingMore = ref(false);

const nextRefreshResult = ref<FinishResult>('success');
const nextLoadResult = ref<FinishResult>('success');
const refreshCount = ref(0);
const loadCount = ref(0);

const headerText = computed(() => {
  const styleLabel = refreshStyle.value === 'customCupertino' ? 'customCupertino' : 'default';
  return `${scrollDirection.value} · shrinkWrap=${String(shrinkWrap.value)} · refresh-style=${styleLabel} · refresh#${refreshCount.value} · load#${loadCount.value}`;
});

async function onRefresh() {
  if (isRefreshing.value) return;
  isRefreshing.value = true;
  refreshCount.value += 1;

  await delay(700);

  const result = nextRefreshResult.value;
  if (result === 'success') {
    const start = (items.value[0] ?? 0) + 1;
    const fresh = Array.from({ length: 8 }, (_, i) => start + i).reverse();
    items.value = [...fresh, ...items.value];
    hasMore.value = true;
  }

  listRef.value?.finishRefresh(result);
  isRefreshing.value = false;
}

async function onLoadmore() {
  if (isLoadingMore.value) return;

  if (!hasMore.value) {
    listRef.value?.finishLoad('noMore');
    return;
  }

  isLoadingMore.value = true;
  loadCount.value += 1;

  await delay(650);

  const result = nextLoadResult.value;
  listRef.value?.finishLoad(result);

  if (result === 'success') {
    const start = (items.value[items.value.length - 1] ?? 0) + 1;
    const more = Array.from({ length: 20 }, (_, i) => start + i);
    items.value = [...items.value, ...more];
  } else if (result === 'noMore') {
    hasMore.value = false;
  }

  isLoadingMore.value = false;
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view
      ref="listRef"
      class="min-h-screen w-full px-3 md:px-6 py-6 box-border"
      :scroll-direction="scrollDirection"
      :shrink-wrap="shrinkWrap"
      :refresh-style="refreshStyle === 'customCupertino' ? 'customCupertino' : undefined"
      @refresh="onRefresh"
      @loadmore="onLoadmore"
    >
      <div :slotName="'refresh-indicator'" class="hidden items-center justify-center py-2">
        <div class="h-4 w-4 border-2 border-[#007aff] border-t-transparent rounded-full animate-spin mr-2" />
        <div class="text-sm font-medium text-[#007aff]">Refreshing…</div>
      </div>

      <div class="bg-surface-secondary rounded-2xl border border-line p-5 mb-5">
        <div class="text-2xl font-semibold text-fg-primary mb-2">WebFListView</div>
        <div class="text-sm text-fg-secondary leading-relaxed">
          Infinite scrolling list optimized for long lists, with pull-to-refresh and load-more.
        </div>
        <div class="mt-3 text-xs font-mono text-fg">{{ headerText }}</div>
      </div>

      <div class="bg-surface-secondary rounded-2xl border border-line p-5 mb-5">
        <div class="text-base font-semibold text-fg-primary mb-2">How to use</div>
        <div class="text-sm text-fg-secondary leading-relaxed">
          Pull down to trigger <span class="font-mono text-fg">refresh</span>. Scroll near the end to trigger
          <span class="font-mono text-fg"> loadmore</span>. Use
          <span class="font-mono text-fg"> finishRefresh(result)</span> /
          <span class="font-mono text-fg"> finishLoad(result)</span> to control the indicators (success/fail/noMore).
        </div>
      </div>

      <div class="text-sm font-semibold text-fg-primary mb-3">Items</div>
      <div
        v-for="n in items"
        :key="n"
        class="w-full rounded-xl border border-line bg-surface-secondary p-4 mt-4 box-border"
      >
        <div class="relative">
          <div class="text-base font-semibold text-fg-primary">Item #{{ n }}</div>
          <div class="text-sm text-fg-secondary mt-1">Long-list friendly: keep items simple and keys stable.</div>
          <div class="absolute right-0 top-0 text-xs font-mono text-fg-secondary">id:{{ n }}</div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
