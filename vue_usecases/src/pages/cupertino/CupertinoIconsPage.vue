<script setup lang="ts">
import { computed, ref } from 'vue';
import { CupertinoIcons } from '@openwebf/vue-cupertino-ui';

const searchTerm = ref('');

const popularIcons = [
  { name: 'house_fill', label: 'House' },
  { name: 'person_fill', label: 'Person' },
  { name: 'star_fill', label: 'Star' },
  { name: 'heart_fill', label: 'Heart' },
  { name: 'gear_alt_fill', label: 'Settings' },
  { name: 'search', label: 'Search' },
  { name: 'plus_circle_fill', label: 'Add' },
  { name: 'trash_fill', label: 'Delete' },
  { name: 'pencil', label: 'Edit' },
  { name: 'checkmark_alt', label: 'Check' },
  { name: 'xmark', label: 'Close' },
  { name: 'info_circle_fill', label: 'Info' },
  { name: 'exclamationmark_triangle_fill', label: 'Warning' },
  { name: 'arrow_right', label: 'Arrow Right' },
  { name: 'arrow_left', label: 'Arrow Left' },
  { name: 'arrow_up', label: 'Arrow Up' },
  { name: 'arrow_down', label: 'Arrow Down' },
  { name: 'chevron_right', label: 'Chevron Right' },
  { name: 'photo_fill', label: 'Photo' },
  { name: 'camera_fill', label: 'Camera' },
  { name: 'music_note_2', label: 'Music' },
  { name: 'doc_text_fill', label: 'Document' },
  { name: 'folder_fill', label: 'Folder' },
  { name: 'calendar', label: 'Calendar' },
  { name: 'clock_fill', label: 'Clock' },
  { name: 'bell_fill', label: 'Notification' },
  { name: 'bubble_left_bubble_right_fill', label: 'Chat' },
  { name: 'phone_fill', label: 'Phone' },
  { name: 'location_fill', label: 'Location' },
  { name: 'map_fill', label: 'Map' },
] as const;

const allIconNames = Object.keys(CupertinoIcons).filter((key) => typeof (CupertinoIcons as any)[key] === 'string');

const filteredIcons = computed(() => {
  const term = searchTerm.value.trim().toLowerCase();
  if (!term) return [];
  return allIconNames.filter((name) => name.toLowerCase().includes(term)).slice(0, 120);
});

function iconTypeByName(name: string): CupertinoIcons {
  return (CupertinoIcons as any)[name] as CupertinoIcons;
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Icons</h1>
      <p class="text-fg-secondary mb-6">iOS SF Symbols icon set for your applications.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic Usage</h2>
        <p class="text-fg-secondary mb-4">Render icons using <code>&lt;flutter-cupertino-icon&gt;</code> and the <code>CupertinoIcons</code> enum.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line">
          <div class="flex flex-wrap gap-6 items-center justify-center">
            <div class="flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="CupertinoIcons.house_fill" class="text-4xl" />
              <span class="text-sm text-fg-secondary">Default Size</span>
            </div>
            <div class="flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="CupertinoIcons.star_fill" class="text-6xl text-yellow-500" />
              <span class="text-sm text-fg-secondary">Large & Colored</span>
            </div>
            <div class="flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="CupertinoIcons.heart_fill" class="text-5xl text-red-500" />
              <span class="text-sm text-fg-secondary">Custom Color</span>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Popular Icons</h2>
        <p class="text-fg-secondary mb-4">Commonly used icons in iOS applications.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line">
          <div class="flex flex-wrap gap-4">
            <div
              v-for="icon in popularIcons"
              :key="icon.name"
              class="flex flex-col items-center gap-2 p-3 rounded-lg hover:bg-surface-tertiary transition-colors cursor-pointer"
              :title="icon.name"
            >
              <flutter-cupertino-icon :type="iconTypeByName(icon.name)" class="text-3xl" />
              <span class="text-xs text-fg-secondary text-center max-w-[80px]">{{ icon.label }}</span>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Search Icons</h2>
        <p class="text-fg-secondary mb-4">Search the full SF Symbols list by key name (limited to first 120 results).</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line">
          <input
            v-model="searchTerm"
            class="w-full rounded border border-line px-3 py-2 bg-surface"
            placeholder="Search icon name, e.g. gear, wifi, photo..."
          />

          <div v-if="!searchTerm" class="mt-4 text-sm text-fg-secondary">
            Start typing to search. Total icons available: {{ allIconNames.length }}.
          </div>

          <div v-else class="mt-4 grid grid-cols-3 md:grid-cols-6 gap-3">
            <div v-for="name in filteredIcons" :key="name" class="rounded border border-line bg-surface p-2 flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="iconTypeByName(name)" class="text-2xl" />
              <div class="text-[10px] text-fg-secondary text-center break-all leading-snug">{{ name }}</div>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Icon Colors</h2>
        <p class="text-fg-secondary mb-4">Apply colors using Tailwind classes.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line">
          <div class="flex flex-wrap gap-8 items-center justify-center">
            <div class="flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="CupertinoIcons.heart_fill" class="text-4xl text-red-500" />
              <code class="text-xs bg-gray-100 px-2 py-1 rounded">text-red-500</code>
            </div>
            <div class="flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="CupertinoIcons.star_fill" class="text-4xl text-yellow-500" />
              <code class="text-xs bg-gray-100 px-2 py-1 rounded">text-yellow-500</code>
            </div>
            <div class="flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="CupertinoIcons.checkmark_circle_fill" class="text-4xl text-green-500" />
              <code class="text-xs bg-gray-100 px-2 py-1 rounded">text-green-500</code>
            </div>
            <div class="flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="CupertinoIcons.info_circle_fill" class="text-4xl text-blue-500" />
              <code class="text-xs bg-gray-100 px-2 py-1 rounded">text-blue-500</code>
            </div>
            <div class="flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="CupertinoIcons.exclamationmark_triangle_fill" class="text-4xl text-orange-500" />
              <code class="text-xs bg-gray-100 px-2 py-1 rounded">text-orange-500</code>
            </div>
            <div class="flex flex-col items-center gap-2">
              <flutter-cupertino-icon :type="CupertinoIcons.xmark_circle_fill" class="text-4xl text-gray-500" />
              <code class="text-xs bg-gray-100 px-2 py-1 rounded">text-gray-500</code>
            </div>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

