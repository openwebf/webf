<script setup lang="ts">
import { ref, computed, watch, onUnmounted } from 'vue';
import { LucideIcons } from '@openwebf/vue-lucide-icons';

const ICONS_PER_PAGE = 60;

const searchTerm = ref('');
const debouncedSearchTerm = ref('');
const displayCount = ref(ICONS_PER_PAGE);
const iconsListRef = ref<any>(null);
let debounceTimer: ReturnType<typeof setTimeout> | null = null;

// Debounce the search term
watch(searchTerm, (newVal) => {
  if (debounceTimer) {
    clearTimeout(debounceTimer);
  }
  debounceTimer = setTimeout(() => {
    debouncedSearchTerm.value = newVal;
  }, 300);
});

onUnmounted(() => {
  if (debounceTimer) {
    clearTimeout(debounceTimer);
  }
});

// Get all icon names from the enum
const allIconNames = computed(() =>
  Object.keys(LucideIcons).filter(
    (key) => typeof LucideIcons[key as keyof typeof LucideIcons] === 'string'
  )
);

// Filter icons based on debounced search term
const filteredIcons = computed(() => {
  if (!debouncedSearchTerm.value) return allIconNames.value;
  const term = debouncedSearchTerm.value.toLowerCase();
  return allIconNames.value.filter((name) => name.toLowerCase().includes(term));
});

// Reset display count when search term changes
watch(debouncedSearchTerm, () => {
  displayCount.value = ICONS_PER_PAGE;
});

// Icons to display
const displayedIcons = computed(() => {
  return filteredIcons.value.slice(0, displayCount.value);
});

function handleSearchChange(e: Event) {
  searchTerm.value = (e.target as HTMLInputElement).value;
}

function handleLoadMore() {
  const hasMore = displayCount.value < filteredIcons.value.length;
  if (hasMore) {
    displayCount.value = Math.min(displayCount.value + ICONS_PER_PAGE, filteredIcons.value.length);
    // Signal successful load
    setTimeout(() => {
      iconsListRef.value?.finishLoad('success');
    }, 100);
  } else {
    // No more items to load
    iconsListRef.value?.finishLoad('noMore');
  }
}

function getIconValue(iconName: string) {
  return LucideIcons[iconName as keyof typeof LucideIcons];
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Lucide Icons</h1>
      <p class="text-fg-secondary mb-6">
        Beautiful & consistent icon set with {{ allIconNames.length }} icons for your applications.
      </p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Common Use Cases</h2>
        <p class="text-fg-secondary mb-4">Real-world examples of icon usage.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
          <!-- Button with Icon -->
          <div>
            <h3 class="font-semibold text-fg-primary mb-3">Buttons with Icons</h3>
            <div class="flex flex-wrap gap-3">
              <button
                class="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
              >
                <flutter-lucide-icon :name="LucideIcons.plus" />
                <span>Add Item</span>
              </button>
              <button
                class="flex items-center gap-2 px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
              >
                <flutter-lucide-icon :name="LucideIcons.trash" />
                <span>Delete</span>
              </button>
              <button
                class="flex items-center gap-2 px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
              >
                <flutter-lucide-icon :name="LucideIcons.check" />
                <span>Confirm</span>
              </button>
            </div>
          </div>

          <!-- List Items -->
          <div>
            <h3 class="font-semibold text-fg-primary mb-3 mt-3">List Items</h3>
            <div class="space-y-2">
              <div class="flex items-center gap-3 p-3 bg-surface rounded-lg">
                <flutter-lucide-icon :name="LucideIcons.circleUser" class="text-2xl text-blue-500" />
                <div class="flex-1">
                  <div class="font-medium">Profile Settings</div>
                  <div class="text-sm text-fg-secondary">Manage your account</div>
                </div>
                <flutter-lucide-icon :name="LucideIcons.chevronRight" class="text-gray-400" />
              </div>
              <div class="flex items-center gap-3 p-3 bg-surface rounded-lg">
                <flutter-lucide-icon :name="LucideIcons.bell" class="text-2xl text-purple-500" />
                <div class="flex-1">
                  <div class="font-medium">Notifications</div>
                  <div class="text-sm text-fg-secondary">Manage alerts</div>
                </div>
                <flutter-lucide-icon :name="LucideIcons.chevronRight" class="text-gray-400" />
              </div>
              <div class="flex items-center gap-3 p-3 bg-surface rounded-lg">
                <flutter-lucide-icon :name="LucideIcons.lock" class="text-2xl text-red-500" />
                <div class="flex-1">
                  <div class="font-medium">Privacy & Security</div>
                  <div class="text-sm text-fg-secondary">Control your privacy</div>
                </div>
                <flutter-lucide-icon :name="LucideIcons.chevronRight" class="text-gray-400" />
              </div>
            </div>
          </div>

          <!-- Status Indicators -->
          <div>
            <h3 class="font-semibold text-fg-primary mb-3">Status Indicators</h3>
            <div class="space-y-2">
              <div class="flex items-center gap-2 p-3 bg-green-50 border border-green-200 rounded-lg">
                <flutter-lucide-icon :name="LucideIcons.circleCheck" class="text-xl text-green-600" />
                <span class="text-green-800">Success! Your changes have been saved.</span>
              </div>
              <div class="flex items-center gap-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                <flutter-lucide-icon :name="LucideIcons.info" class="text-xl text-blue-600" />
                <span class="text-blue-800">Information: Please review the details below.</span>
              </div>
              <div class="flex items-center gap-2 p-3 bg-orange-50 border border-orange-200 rounded-lg">
                <flutter-lucide-icon :name="LucideIcons.triangleAlert" class="text-xl text-orange-600" />
                <span class="text-orange-800">Warning: This action cannot be undone.</span>
              </div>
              <div class="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
                <flutter-lucide-icon :name="LucideIcons.circleX" class="text-xl text-red-600" />
                <span class="text-red-800">Error: Something went wrong.</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Search Section -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Search Icons</h2>
        <p class="text-fg-secondary mb-4">Search through all {{ allIconNames.length }} icons.</p>

        <div class="mb-4">
          <input
            type="text"
            placeholder="Search icons..."
            :value="searchTerm"
            @input="handleSearchChange"
            class="w-full px-4 py-2 border border-line rounded-lg bg-surface text-fg-primary focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div class="bg-surface-secondary rounded-xl border border-line overflow-hidden">
          <div class="text-sm text-fg-secondary p-4 pb-2">
            <template v-if="filteredIcons.length === allIconNames.length">
              Showing {{ displayedIcons.length }} of {{ allIconNames.length }} icons
            </template>
            <template v-else>
              Found {{ filteredIcons.length }} icons matching "{{ debouncedSearchTerm }}" (showing
              {{ displayedIcons.length }})
            </template>
          </div>

          <div v-if="filteredIcons.length === 0" class="text-center py-8 text-fg-secondary">
            No icons found matching "{{ debouncedSearchTerm }}"
          </div>

          <webf-list-view
            v-else
            ref="iconsListRef"
            class="h-96 px-4 pb-4"
            :shrink-wrap="false"
            @loadmore="handleLoadMore"
          >
            <div class="grid grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-2">
              <div
                v-for="iconName in displayedIcons"
                :key="iconName"
                class="flex flex-col items-center justify-start gap-2 p-2 rounded-lg hover:bg-surface-tertiary transition-colors cursor-pointer h-20"
                :title="iconName"
              >
                <div class="h-8 flex items-center justify-center">
                  <flutter-lucide-icon :name="getIconValue(iconName)" class="text-2xl text-fg-primary" />
                </div>
                <span
                  class="text-xs text-fg-secondary text-center leading-tight break-all line-clamp-2 w-full flex items-center justify-center"
                >
                  {{ iconName }}
                </span>
              </div>
            </div>
            <div v-if="displayCount < filteredIcons.length" class="text-center py-4 text-fg-secondary text-sm">
              Scroll down to load more...
            </div>
          </webf-list-view>
        </div>
      </section>

      <!-- Notes -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
        <div class="bg-orange-50 border-l-4 border-orange-500 p-4 rounded">
          <ul class="space-y-2 text-sm text-gray-700">
            <li>Icons are from the Lucide icon set (lucide.dev)</li>
            <li>
              Use the <code class="bg-gray-200 px-1 rounded">LucideIcons</code> enum for type-safe icon names
            </li>
            <li>
              Control size with Tailwind's text size classes (<code class="bg-gray-200 px-1 rounded">text-xl</code>,
              <code class="bg-gray-200 px-1 rounded">text-4xl</code>, etc.)
            </li>
            <li>Apply colors using Tailwind color classes or inline styles</li>
            <li>
              Use <code class="bg-gray-200 px-1 rounded">stroke-width</code> prop (100-600) for weight variants
            </li>
            <li>Add <code class="bg-gray-200 px-1 rounded">label</code> prop for accessibility</li>
          </ul>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>
