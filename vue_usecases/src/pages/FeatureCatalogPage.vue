<script setup lang="ts">
import { WebFRouter } from '@openwebf/vue-router';
import { LucideIcons } from '@openwebf/vue-lucide-icons';

type Item = { label: string; path: string; desc?: string };
type Section = { title: string; icon: LucideIcons; color: string; items: Item[] };

const sections: Section[] = [
  {
    title: 'Core UI Components',
    icon: LucideIcons.component,
    color: 'from-violet-500 to-purple-600',
    items: [
      { label: 'Gesture Detector', path: '/gesture', desc: 'Tap, pan, pinch, rotate' },
      { label: 'ListView', path: '/listview', desc: 'Infinite scrolling' },
      { label: 'Dragable List', path: '/dragable-list', desc: 'Drag to reorder' },
    ],
  },
  {
    title: 'Native UI',
    icon: LucideIcons.smartphone,
    color: 'from-violet-600 to-indigo-600',
    items: [
      { label: 'Video Player', path: '/webf-video-player', desc: 'Native video' },
      { label: 'Camera', path: '/webf-camera', desc: 'Photo & video' },
      { label: 'Lucide Icons', path: '/lucide/icons', desc: '1600+ icons' },
    ],
  },
  {
    title: 'Native Plugins',
    icon: LucideIcons.plug,
    color: 'from-red-500 to-rose-600',
    items: [
      { label: 'Share', path: '/webf-share', desc: 'Native sharing' },
      { label: 'Bluetooth', path: '/webf-bluetooth', desc: 'BLE devices' },
    ],
  },
  {
    title: 'Cupertino UI',
    icon: LucideIcons.apple,
    color: 'from-gray-700 to-gray-900',
    items: [
      { label: 'Showcase', path: '/cupertino-showcase', desc: 'All components' },
      { label: 'Colors', path: '/cupertino/colors', desc: 'System colors' },
      { label: 'Icons', path: '/cupertino/icons', desc: 'SF Symbols' },
      { label: 'Tabs', path: '/cupertino/tabs', desc: 'Tab navigation' },
      { label: 'Alert', path: '/cupertino/alert', desc: 'Alert dialogs' },
      { label: 'Action Sheet', path: '/cupertino/actionsheet', desc: 'Bottom actions' },
      { label: 'Modal Popup', path: '/cupertino/modal-popup', desc: 'Modal sheets' },
      { label: 'Context Menu', path: '/cupertino/context-menu', desc: 'Long press menu' },
      { label: 'List Section', path: '/cupertino/list-section', desc: 'Grouped lists' },
      { label: 'List Tile', path: '/cupertino/list-tile', desc: 'List items' },
      { label: 'Form Section', path: '/cupertino/form-section', desc: 'Form groups' },
      { label: 'TextField', path: '/cupertino/text-field', desc: 'Text input' },
      { label: 'Search Field', path: '/cupertino/search-text-field', desc: 'Search bar' },
      { label: 'Date Picker', path: '/cupertino/date-picker', desc: 'Date selection' },
      { label: 'Buttons', path: '/cupertino/buttons', desc: 'iOS buttons' },
      { label: 'Switch', path: '/cupertino/switch', desc: 'Toggle switch' },
      { label: 'Slider', path: '/cupertino/slider', desc: 'Value slider' },
      { label: 'Segmented', path: '/cupertino/sliding-segmented-control', desc: 'Segment control' },
      { label: 'Checkbox', path: '/cupertino/checkbox', desc: 'Checkboxes' },
      { label: 'Radio', path: '/cupertino/radio', desc: 'Radio buttons' },
    ],
  },
  {
    title: 'Navigation & Routing',
    icon: LucideIcons.compass,
    color: 'from-blue-500 to-cyan-500',
    items: [{ label: 'Hybrid Router', path: '/routing', desc: 'Client-side routing' }],
  },
  {
    title: 'Layout & Box Model',
    icon: LucideIcons.layoutGrid,
    color: 'from-emerald-500 to-teal-500',
    items: [
      { label: 'Flexbox', path: '/css/flex-layout', desc: 'Flexible layouts' },
      { label: 'CSS Grid', path: '/css/grid-layout', desc: 'Two-dimensional layouts' },
      { label: 'Display & Flow', path: '/css/display-flow', desc: 'Block, inline, flow' },
      { label: 'Sizing', path: '/css/sizing', desc: 'Width, height, box-sizing' },
      { label: 'Inline Formatting', path: '/css/inline-formatting', desc: 'Baselines, alignment' },
    ],
  },
  {
    title: 'Backgrounds & Borders',
    icon: LucideIcons.palette,
    color: 'from-pink-500 to-rose-500',
    items: [
      { label: 'Background', path: '/css/bg', desc: 'Color, position, size' },
      { label: 'Linear Gradient', path: '/css/bg-gradient', desc: 'Gradient backgrounds' },
      { label: 'Radial Gradient', path: '/css/bg-radial', desc: 'Radial gradients' },
      { label: 'Background Image', path: '/css/bg-image', desc: 'Image backgrounds' },
      { label: 'Border', path: '/css/border', desc: 'Styles and colors' },
      { label: 'Border Radius', path: '/css/border-radius', desc: 'Rounded corners' },
      { label: 'Box Shadow', path: '/css/box-shadow', desc: 'Shadow effects' },
      { label: 'Overflow', path: '/css/overflow', desc: 'Scroll behavior' },
    ],
  },
  {
    title: 'Animation & Effects',
    icon: LucideIcons.sparkles,
    color: 'from-amber-500 to-orange-500',
    items: [
      { label: 'Transforms', path: '/css/transforms', desc: 'Scale, rotate, skew' },
      { label: 'Transitions', path: '/css/transitions', desc: 'Smooth changes' },
      { label: 'Keyframes', path: '/css/keyframes', desc: 'Timeline animations' },
      { label: 'CSS Animations', path: '/css/animation', desc: 'Predefined effects' },
      { label: 'Filters', path: '/css/filter', desc: 'Blur, brightness' },
    ],
  },
  {
    title: 'Typography & Position',
    icon: LucideIcons.type,
    color: 'from-slate-500 to-gray-600',
    items: [
      { label: 'Position', path: '/css/position', desc: 'Absolute, fixed, sticky' },
      { label: 'Typography', path: '/typography', desc: 'Text styling' },
      { label: 'Custom Fonts', path: '/fontface', desc: '@font-face' },
      { label: 'Responsive', path: '/responsive', desc: 'Media queries' },
      { label: 'Values & Units', path: '/css/values-units', desc: 'px, em, rem, vw' },
    ],
  },
  {
    title: 'DOM APIs',
    icon: LucideIcons.globe,
    color: 'from-indigo-500 to-blue-600',
    items: [
      { label: 'Bounding Rect', path: '/dom-bounding-rect', desc: 'Element measurements' },
      { label: 'MutationObserver', path: '/mutation-observer', desc: 'Watch DOM changes' },
      { label: 'Events', path: '/dom/events', desc: 'Event handling' },
      { label: 'Geometry', path: '/dom/geometry', desc: 'DOMMatrix, DOMPoint' },
      { label: 'Offsets', path: '/dom/offsets', desc: 'Offset dimensions' },
      { label: 'classList', path: '/dom/classlist', desc: 'Class manipulation' },
      { label: 'innerHTML', path: '/dom/innerhtml', desc: 'HTML content' },
      { label: 'Style API', path: '/dom/style', desc: 'Inline styles' },
    ],
  },
  {
    title: 'Tailwind CSS',
    icon: LucideIcons.wind,
    color: 'from-sky-500 to-blue-500',
    items: [{ label: 'Tailwind Showcase', path: '/tailwind', desc: 'Utility-first CSS' }],
  },
  {
    title: 'Networking',
    icon: LucideIcons.wifi,
    color: 'from-green-500 to-emerald-600',
    items: [
      { label: 'Fetch & XHR', path: '/network', desc: 'HTTP requests' },
      { label: 'WebSocket', path: '/websocket', desc: 'Real-time comm' },
    ],
  },
  {
    title: 'Storage',
    icon: LucideIcons.database,
    color: 'from-yellow-500 to-amber-500',
    items: [
      { label: 'Web Storage', path: '/web-storage', desc: 'Local & session' },
      { label: 'Cookies', path: '/cookies', desc: 'Cookie management' },
    ],
  },
  {
    title: 'URL & Encoding',
    icon: LucideIcons.link,
    color: 'from-cyan-500 to-teal-500',
    items: [{ label: 'URL & Base64', path: '/url-encoding', desc: 'Encoding utilities' }],
  },
  {
    title: 'Graphics',
    icon: LucideIcons.image,
    color: 'from-fuchsia-500 to-pink-500',
    items: [
      { label: 'Image Gallery', path: '/image', desc: 'All image formats' },
      { label: 'Canvas 2D', path: '/canvas-2d', desc: 'Drawing API' },
      { label: 'SVG Images', path: '/svg-image', desc: 'Vector graphics' },
    ],
  },
  {
    title: 'Forms & Input',
    icon: LucideIcons.clipboardList,
    color: 'from-teal-500 to-green-500',
    items: [
      { label: 'Basic Form', path: '/form', desc: 'Form basics' },
      { label: 'Form Elements', path: '/basic-form-elements', desc: 'All inputs' },
      { label: 'Input Sizing', path: '/input-sizing', desc: 'Dynamic sizing' },
      { label: 'Advanced Form', path: '/advanced-form', desc: 'Complex forms' },
    ],
  },
];

function navigate(path: string) {
  WebFRouter.pushState({}, path);
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-gradient-to-b from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-950">
    <webf-list-view class="w-full">
      <!-- Hero Header -->
      <div class="w-full bg-gradient-to-br from-slate-800 via-slate-700 to-slate-800 dark:from-slate-950 dark:via-slate-900 dark:to-slate-950 px-6 pt-12 pb-10">
        <div class="max-w-4xl mx-auto">
          <div class="flex items-center gap-3 mb-4">
            <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center shadow-lg">
              <flutter-lucide-icon :name="LucideIcons.zap" class="text-2xl text-white" />
            </div>
            <div>
              <h1 class="text-3xl font-bold text-white">WebF Catalog</h1>
              <p class="text-slate-400 text-sm">Flutter-powered Web Development</p>
            </div>
          </div>
          <p class="text-slate-300 text-base leading-relaxed max-w-2xl">
            Explore WebF's complete feature set - from CSS styling to native device APIs.
            Each demo showcases real capabilities you can use in your apps.
          </p>
        </div>
      </div>

      <!-- Main Content -->
      <div class="px-4 py-8 max-w-4xl mx-auto">
        <!-- Sections -->
        <template v-for="section in sections" :key="section.title">
          <div class="mb-8">
            <!-- Section Header -->
            <div class="flex items-center gap-3 mb-4">
              <div
                :class="[
                  'w-10 h-10 rounded-xl flex items-center justify-center shadow-md bg-gradient-to-br',
                  section.color
                ]"
              >
                <flutter-lucide-icon :name="section.icon" class="text-lg text-white" />
              </div>
              <h2 class="text-xl font-bold text-slate-800 dark:text-slate-100">{{ section.title }}</h2>
              <span class="text-xs text-slate-400 bg-slate-200 dark:bg-slate-700 dark:text-slate-300 px-2 py-0.5 rounded-full">
                {{ section.items.length }}
              </span>
            </div>

            <!-- Cards Container -->
            <div class="bg-white dark:bg-slate-800 rounded-2xl shadow-sm border border-slate-200 dark:border-slate-700 overflow-hidden">
              <div class="flex flex-wrap">
                <button
                  v-for="item in section.items"
                  :key="item.path"
                  :class="[
                    'flex flex-col p-4 text-left transition-all duration-200',
                    'hover:bg-slate-50 dark:hover:bg-slate-700 active:bg-slate-100 dark:active:bg-slate-600 cursor-pointer',
                    'border-b border-r border-slate-100 dark:border-slate-700',
                    'w-1/2 md:w-1/3',
                  ]"
                  @click="navigate(item.path)"
                >
                  <span class="text-sm font-semibold text-slate-800 dark:text-slate-100 mb-1">{{ item.label }}</span>
                  <span class="text-xs text-slate-500 dark:text-slate-400 leading-relaxed">{{ item.desc }}</span>
                </button>
              </div>
            </div>
          </div>
        </template>

        <!-- Footer -->
        <div class="text-center py-8 text-slate-400 dark:text-slate-500 text-sm">
          <p>Built with WebF + Vue 3 + Tailwind CSS</p>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
