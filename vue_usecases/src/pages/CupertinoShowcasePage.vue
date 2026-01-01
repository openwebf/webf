<script setup lang="ts">
import { WebFRouter } from '@openwebf/vue-router';

type NavItem = { label: string; desc: string; to?: string };
type NavSection = { title: string; items: NavItem[] };

const sections: NavSection[] = [
  {
    title: 'Theme & Colors',
    items: [
      { label: 'Cupertino Colors', desc: 'Static and dynamic Cupertino colors', to: '/cupertino/colors' },
      { label: 'Cupertino Icons', desc: 'iOS SF Symbols icon set', to: '/cupertino/icons' },
    ],
  },
  {
    title: 'Navigation, Tabs & Pages',
    items: [{ label: 'Tabs', desc: 'TabScaffold · TabBar · TabView · Controller', to: '/cupertino/tabs' }],
  },
  {
    title: 'Dialogs, Sheets & Menus',
    items: [
      { label: 'Cupertino Alert Dialog', desc: 'Alerts & dialog actions', to: '/cupertino/alert' },
      { label: 'Cupertino Action Sheet', desc: 'Action sheet and sheet actions', to: '/cupertino/actionsheet' },
      { label: 'Cupertino Modal Popup', desc: 'Bottom sheet style modal popup', to: '/cupertino/modal-popup' },
      { label: 'Cupertino Context Menu', desc: 'Peek and pop context actions', to: '/cupertino/context-menu' },
    ],
  },
  {
    title: 'Lists & Forms',
    items: [
      { label: 'CupertinoListSection', desc: 'Grouped list sections', to: '/cupertino/list-section' },
      { label: 'CupertinoListTile', desc: 'iOS-style list tiles', to: '/cupertino/list-tile' },
      { label: 'CupertinoFormSection', desc: 'Form rows and grouped settings', to: '/cupertino/form-section' },
    ],
  },
  {
    title: 'Text Input & Search',
    items: [
      { label: 'CupertinoTextField', desc: 'Single-line iOS-style text input', to: '/cupertino/text-field' },
      { label: 'CupertinoTextFormFieldRow', desc: 'Inline text field row for forms', to: '/cupertino/text-form-field-row' },
      { label: 'CupertinoSearchTextField', desc: 'iOS-style search bar', to: '/cupertino/search-text-field' },
    ],
  },
  {
    title: 'Pickers',
    items: [{ label: 'CupertinoDatePicker', desc: 'iOS date & time picker', to: '/cupertino/date-picker' }],
  },
  {
    title: 'Controls',
    items: [
      { label: 'Cupertino Buttons', desc: 'Buttons with iOS styling', to: '/cupertino/buttons' },
      { label: 'CupertinoSwitch', desc: 'iOS-style toggle', to: '/cupertino/switch' },
      { label: 'CupertinoSlider', desc: 'Value selection slider', to: '/cupertino/slider' },
      { label: 'Sliding Segmented Control', desc: 'Segmented control with sliding thumb', to: '/cupertino/sliding-segmented-control' },
      { label: 'CupertinoCheckBox', desc: 'iOS checkbox', to: '/cupertino/checkbox' },
      { label: 'CupertinoRadio', desc: 'iOS radio button', to: '/cupertino/radio' },
    ],
  },
];

function navigate(to?: string) {
  if (!to) return;
  WebFRouter.pushState({}, to);
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <div class="w-full flex justify-center items-center">
        <div class="bg-gradient-to-tr from-blue-500 to-cyan-400 p-6 rounded-2xl text-white shadow w-full">
          <h1 class="text-[28px] font-bold mb-2 drop-shadow">Cupertino UI</h1>
          <p class="text-[16px]/[1.5] opacity-90">iOS-style components and interactions built with WebF</p>
        </div>
      </div>

      <div class="mt-6">
        <template v-for="section in sections" :key="section.title">
          <h2 class="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">{{ section.title }}</h2>
          <div class="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
            <div
              v-for="item in section.items"
              :key="item.label"
              class="flex items-center p-4 border-b border-[#f0f0f0] cursor-pointer transition-colors hover:bg-surface-hover"
              :class="item.to ? '' : 'pointer-events-none opacity-60'"
              @click="navigate(item.to)"
            >
              <div class="flex-1">
                <div class="text-[16px] font-semibold text-[#2c3e50] mb-1">{{ item.label }}</div>
                <div class="text-[14px] text-[#7f8c8d] leading-snug">{{ item.desc }}</div>
              </div>
              <div class="text-[16px] text-[#bdc3c7] font-bold">&gt;</div>
            </div>
          </div>
        </template>
      </div>
    </webf-list-view>
  </div>
</template>

