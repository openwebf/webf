<script setup lang="ts">
import { computed, ref } from 'vue';

const basicIndex = ref(0);
const viewMode = ref(0);
const filterIndex = ref(0);
const customColorIndex = ref(0);

const eventLog = ref<string[]>([]);
function addEventLog(message: string) {
  eventLog.value = [message, ...eventLog.value].slice(0, 5);
}

const allItems = [
  { id: 1, name: 'Meeting Notes', status: 'active', priority: 'high' },
  { id: 2, name: 'Project Plan', status: 'completed', priority: 'medium' },
  { id: 3, name: 'Bug Report', status: 'active', priority: 'high' },
  { id: 4, name: 'Design Doc', status: 'pending', priority: 'low' },
  { id: 5, name: 'Code Review', status: 'active', priority: 'medium' },
];

const filterCategories = ['All', 'Active', 'Completed', 'Pending'] as const;

const filteredItems = computed(() => {
  if (filterIndex.value === 0) return allItems;
  const status = filterCategories[filterIndex.value]?.toLowerCase() ?? 'all';
  return allItems.filter((item) => item.status === status);
});
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Sliding Segmented Control</h1>
      <p class="text-fg-secondary mb-6">iOS-style segmented control with a sliding thumb animation.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic Control</h2>
        <p class="text-fg-secondary mb-4">A simple three-segment control.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6">
            <div class="flex justify-center mb-6">
              <flutter-cupertino-sliding-segmented-control
                class="w-full max-w-sm"
                :current-index="basicIndex"
                @change="
                  (e) => {
                    basicIndex = e.detail;
                    addEventLog(`basic: ${e.detail}`);
                  }
                "
              >
                <flutter-cupertino-sliding-segmented-control-item title="Photos" />
                <flutter-cupertino-sliding-segmented-control-item title="Music" />
                <flutter-cupertino-sliding-segmented-control-item title="Videos" />
              </flutter-cupertino-sliding-segmented-control>
            </div>
            <div class="text-center text-sm text-gray-600">
              Selected: <span class="font-semibold">{{ ['Photos', 'Music', 'Videos'][basicIndex] }}</span> (index: {{ basicIndex }})
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Two-Segment Toggle</h2>
        <p class="text-fg-secondary mb-4">A binary choice control.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6">
            <div class="flex justify-center mb-6">
              <flutter-cupertino-sliding-segmented-control class="w-64" :current-index="viewMode" @change="(e) => (viewMode = e.detail)">
                <flutter-cupertino-sliding-segmented-control-item title="Compact" />
                <flutter-cupertino-sliding-segmented-control-item title="Detailed" />
              </flutter-cupertino-sliding-segmented-control>
            </div>
            <div v-if="viewMode === 0" class="grid grid-cols-3 gap-2">
              <div v-for="i in 6" :key="i" class="bg-gray-100 rounded p-3 text-center text-sm">Item {{ i }}</div>
            </div>
            <div v-else class="space-y-2">
              <div v-for="i in 6" :key="i" class="bg-gray-50 rounded p-3">
                <div class="font-semibold">Item {{ i }}</div>
                <div class="text-xs text-gray-600">More details shown in the detailed mode.</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Filter Example</h2>
        <p class="text-fg-secondary mb-4">Filter a list with segmented control.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6 space-y-4">
            <flutter-cupertino-sliding-segmented-control
              :current-index="filterIndex"
              class="w-full max-w-lg"
              @change="
                (e) => {
                  filterIndex = e.detail;
                  addEventLog(`filter: ${filterCategories[e.detail] ?? e.detail}`);
                }
              "
            >
              <flutter-cupertino-sliding-segmented-control-item title="All" />
              <flutter-cupertino-sliding-segmented-control-item title="Active" />
              <flutter-cupertino-sliding-segmented-control-item title="Completed" />
              <flutter-cupertino-sliding-segmented-control-item title="Pending" />
            </flutter-cupertino-sliding-segmented-control>

            <div class="space-y-2">
              <div v-for="item in filteredItems" :key="item.id" class="p-3 bg-gray-50 rounded-lg flex justify-between items-center">
                <div>
                  <div class="font-semibold">{{ item.name }}</div>
                  <div class="text-xs text-gray-600">{{ item.status }} • {{ item.priority }} priority</div>
                </div>
                <div
                  class="px-2 py-1 rounded text-xs font-semibold"
                  :class="
                    item.status === 'active'
                      ? 'bg-green-100 text-green-700'
                      : item.status === 'completed'
                        ? 'bg-blue-100 text-blue-700'
                        : 'bg-yellow-100 text-yellow-700'
                  "
                >
                  {{ item.status }}
                </div>
              </div>
              <div v-if="filteredItems.length === 0" class="text-center py-8 text-gray-500">No items found</div>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Custom Colors</h2>
        <p class="text-fg-secondary mb-4">Customize background and thumb colors.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <div class="bg-white rounded-lg p-6">
            <div class="text-sm font-semibold text-gray-700 mb-3">Blue Theme</div>
            <flutter-cupertino-sliding-segmented-control
              :current-index="customColorIndex"
              background-color="#E3F2FD"
              thumb-color="#2196F3"
              class="w-full max-w-xs"
              style="font-size: 14px; font-weight: 600;"
              @change="(e) => (customColorIndex = e.detail)"
            >
              <flutter-cupertino-sliding-segmented-control-item title="One" />
              <flutter-cupertino-sliding-segmented-control-item title="Two" />
              <flutter-cupertino-sliding-segmented-control-item title="Three" />
            </flutter-cupertino-sliding-segmented-control>
          </div>
        </div>
      </section>

      <div v-if="eventLog.length" class="bg-gray-50 rounded-lg p-4 border border-gray-200">
        <div class="text-sm font-semibold mb-2">Event Log (last 5)</div>
        <div class="space-y-1">
          <div v-for="(line, idx) in eventLog" :key="idx" class="text-xs font-mono text-gray-700">{{ line }}</div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>

