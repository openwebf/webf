<script setup lang="ts">
import { CupertinoColors } from '@openwebf/vue-cupertino-ui';

type Swatch = { name: string; color: string; description?: string };
type Group = { title: string; swatches: Swatch[] };

const groups: Group[] = [
  {
    title: 'Primary System Colors',
    swatches: [
      { name: 'systemBlue', color: CupertinoColors.systemBlue, description: 'Default iOS blue, used for links and primary actions' },
      { name: 'systemGreen', color: CupertinoColors.systemGreen, description: 'Success and positive actions' },
      { name: 'systemIndigo', color: CupertinoColors.systemIndigo, description: 'Deep blue-purple' },
      { name: 'systemOrange', color: CupertinoColors.systemOrange, description: 'Warnings and highlights' },
      { name: 'systemPink', color: CupertinoColors.systemPink, description: 'Accent color' },
      { name: 'systemPurple', color: CupertinoColors.systemPurple, description: 'Creative and media' },
      { name: 'systemRed', color: CupertinoColors.systemRed, description: 'Errors and destructive actions' },
      { name: 'systemTeal', color: CupertinoColors.systemTeal, description: 'Calm and neutral' },
      { name: 'systemYellow', color: CupertinoColors.systemYellow, description: 'Attention and energy' },
    ],
  },
  {
    title: 'Grayscale System Colors',
    swatches: [
      { name: 'systemGrey', color: CupertinoColors.systemGrey, description: 'Base gray' },
      { name: 'systemGrey2', color: CupertinoColors.systemGrey2, description: 'Lighter gray' },
      { name: 'systemGrey3', color: CupertinoColors.systemGrey3, description: 'Light gray' },
      { name: 'systemGrey4', color: CupertinoColors.systemGrey4, description: 'Very light gray' },
      { name: 'systemGrey5', color: CupertinoColors.systemGrey5, description: 'Extra light gray' },
      { name: 'systemGrey6', color: CupertinoColors.systemGrey6, description: 'Nearly white gray' },
    ],
  },
  {
    title: 'Label Colors',
    swatches: [
      { name: 'label', color: CupertinoColors.label, description: 'Primary text and content' },
      { name: 'secondaryLabel', color: CupertinoColors.secondaryLabel, description: 'Secondary text' },
      { name: 'tertiaryLabel', color: CupertinoColors.tertiaryLabel, description: 'Tertiary text' },
      { name: 'quaternaryLabel', color: CupertinoColors.quaternaryLabel, description: 'Quaternary text' },
    ],
  },
  {
    title: 'Fill Colors',
    swatches: [
      { name: 'systemFill', color: CupertinoColors.systemFill, description: 'Primary fill for UI elements' },
      { name: 'secondarySystemFill', color: CupertinoColors.secondarySystemFill, description: 'Secondary fill' },
      { name: 'tertiarySystemFill', color: CupertinoColors.tertiarySystemFill, description: 'Tertiary fill' },
      { name: 'quaternarySystemFill', color: CupertinoColors.quaternarySystemFill, description: 'Quaternary fill' },
    ],
  },
  {
    title: 'Background Colors',
    swatches: [
      { name: 'systemBackground', color: CupertinoColors.systemBackground, description: 'Primary background' },
      { name: 'secondarySystemBackground', color: CupertinoColors.secondarySystemBackground, description: 'Secondary background' },
      { name: 'tertiarySystemBackground', color: CupertinoColors.tertiarySystemBackground, description: 'Tertiary background' },
    ],
  },
  {
    title: 'Grouped Background Colors',
    swatches: [
      { name: 'systemGroupedBackground', color: CupertinoColors.systemGroupedBackground, description: 'Background for grouped content' },
      { name: 'secondarySystemGroupedBackground', color: CupertinoColors.secondarySystemGroupedBackground, description: 'Secondary grouped background' },
      { name: 'tertiarySystemGroupedBackground', color: CupertinoColors.tertiarySystemGroupedBackground, description: 'Tertiary grouped background' },
    ],
  },
  {
    title: 'Separator Colors',
    swatches: [
      { name: 'separator', color: CupertinoColors.separator, description: 'Thin lines and dividers' },
      { name: 'opaqueSeparator', color: CupertinoColors.opaqueSeparator, description: 'Opaque separator' },
    ],
  },
  {
    title: 'Link & Placeholder',
    swatches: [
      { name: 'link', color: CupertinoColors.link, description: 'Hyperlinks and tappable text' },
      { name: 'placeholderText', color: CupertinoColors.placeholderText, description: 'Placeholder text in inputs' },
    ],
  },
  {
    title: 'Standard Colors',
    swatches: [
      { name: 'black', color: CupertinoColors.black, description: 'Pure black' },
      { name: 'white', color: CupertinoColors.white, description: 'Pure white' },
      { name: 'darkBackgroundGray', color: CupertinoColors.darkBackgroundGray, description: 'Dark mode background' },
      { name: 'lightBackgroundGray', color: CupertinoColors.lightBackgroundGray, description: 'Light mode background' },
    ],
  },
  {
    title: 'Active & Interaction Colors',
    swatches: [
      { name: 'activeBlue', color: CupertinoColors.activeBlue, description: 'Active blue state' },
      { name: 'activeGreen', color: CupertinoColors.activeGreen, description: 'Active green state' },
      { name: 'activeOrange', color: CupertinoColors.activeOrange, description: 'Active orange state' },
    ],
  },
  {
    title: 'Inactive Colors',
    swatches: [{ name: 'inactiveGray', color: CupertinoColors.inactiveGray, description: 'Disabled and inactive elements' }],
  },
  {
    title: 'Destructive Colors',
    swatches: [{ name: 'destructiveRed', color: CupertinoColors.destructiveRed, description: 'Destructive actions and warnings' }],
  },
];
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Colors</h1>
      <p class="text-fg-secondary mb-6">Static and dynamic iOS color palette from Flutter's Cupertino design system</p>

      <div v-for="group in groups" :key="group.title" class="mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">{{ group.title }}</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-3">
          <div v-for="swatch in group.swatches" :key="swatch.name" class="flex items-center gap-4 p-3 bg-surface rounded-lg border border-line">
            <div class="w-16 h-16 rounded-lg shadow-md flex-shrink-0 border border-line" :style="{ backgroundColor: swatch.color }" />
            <div class="flex-1 min-w-0">
              <div class="text-base font-medium text-fg-primary">{{ swatch.name }}</div>
              <div class="text-sm text-fg-secondary font-mono">{{ swatch.color }}</div>
              <div v-if="swatch.description" class="text-xs text-fg-secondary mt-1">{{ swatch.description }}</div>
            </div>
          </div>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Live Example</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
          <div class="flex flex-wrap gap-3">
            <button class="px-4 py-2 rounded-lg font-medium" :style="{ backgroundColor: CupertinoColors.systemBlue, color: CupertinoColors.white }">Primary</button>
            <button class="px-4 py-2 rounded-lg font-medium" :style="{ backgroundColor: CupertinoColors.systemGreen, color: CupertinoColors.white }">Success</button>
            <button class="px-4 py-2 rounded-lg font-medium" :style="{ backgroundColor: CupertinoColors.destructiveRed, color: CupertinoColors.white }">Danger</button>
            <button class="px-4 py-2 rounded-lg font-medium" :style="{ backgroundColor: CupertinoColors.systemGrey, color: CupertinoColors.white }">Secondary</button>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>

