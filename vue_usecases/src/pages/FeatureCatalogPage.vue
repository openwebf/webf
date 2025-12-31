<script setup lang="ts">
import { WebFRouter } from '@openwebf/vue-router';

type Item = { label: string; path: string; desc?: string };
type Section = { title: string; items: Item[] };

const sections: Section[] = [
  {
    title: 'CSS - Layout & Box Model',
    items: [
      { label: 'Flexbox', path: '/css/flex-layout', desc: 'One-dimensional layout with alignment controls' },
      { label: 'Display / Flow / Box', path: '/css/display-flow', desc: 'Block/inline, formatting context, flow' },
      { label: 'Sizing', path: '/css/sizing', desc: 'Width/height/min/max, box-sizing' },
      { label: 'Inline & Inline Formatting', path: '/css/inline-formatting', desc: 'Baselines, line boxes, alignment' },
    ],
  },
  {
    title: 'CSS - Backgrounds, Borders & Overflow',
    items: [
      { label: 'Background', path: '/css/bg', desc: 'Color, repeat, position and size' },
      { label: 'Background Gradient', path: '/css/bg-gradient', desc: 'Linear gradients' },
      { label: 'Background Radial', path: '/css/bg-radial', desc: 'Radial gradients' },
      { label: 'Background Image', path: '/css/bg-image', desc: 'Images as backgrounds' },
      { label: 'Border', path: '/css/border', desc: 'Styles, widths and colors' },
      { label: 'Border Radius', path: '/css/border-radius', desc: 'Rounded corners' },
      { label: 'Box Shadow', path: '/css/box-shadow', desc: 'Shadow and depth effects' },
      { label: 'Overflow', path: '/css/overflow', desc: 'Hidden, scroll and auto handling' },
    ],
  },
  {
    title: 'CSS - Transforms & Transitions',
    items: [
      { label: 'Transforms', path: '/css/transforms', desc: 'Translate, scale, rotate, skew' },
      { label: 'Transitions', path: '/css/transitions', desc: 'Smooth property changes' },
      { label: 'Animations (Keyframes)', path: '/css/keyframes', desc: 'Timeline-based animations' },
      { label: 'CSS Animations', path: '/css/animation', desc: 'Fade, slide, scale, rotate, bounce, pulse' },
      { label: 'Filter Effects', path: '/css/filter', desc: 'Blur, brightness, contrast and more' },
    ],
  },
  {
    title: 'CSS - Positioning, Typography & Media',
    items: [
      { label: 'Positioned Layout', path: '/css/position', desc: 'Relative, absolute, sticky, fixed' },
      { label: 'Typography', path: '/typography', desc: 'Text layout, overflow and decoration' },
      { label: 'Custom Fonts (@font-face)', path: '/fontface', desc: 'Custom web fonts' },
      { label: 'Responsive Design', path: '/responsive', desc: 'Media queries and adaptive layouts' },
      { label: 'Selectors', path: '/css/selectors', desc: 'Attribute, pseudo, combinators' },
      { label: 'Values & Units', path: '/css/values-units', desc: 'px, em, rem, vw, vh, calc()' },
    ],
  },
  {
    title: 'DOM Core',
    items: [
      {
        label: 'DOM Measurements (getBoundingClientRect)',
        path: '/dom-bounding-rect',
        desc: 'Get element size and position relative to viewport',
      },
      { label: 'MutationObserver', path: '/mutation-observer', desc: 'Observe and react to DOM changes' },
      { label: 'Events (mouse/touch/scroll/CustomEvent)', path: '/dom/events', desc: 'Event handling and custom events' },
      { label: 'Geometry (DOMMatrix/DOMPoint)', path: '/dom/geometry', desc: 'Geometric transformations and calculations' },
      { label: 'Offsets (offsetWidth/Height/Top/Left)', path: '/dom/offsets', desc: 'Element offset dimensions and positions' },
      { label: 'DOMTokenList (classList)', path: '/dom/classlist', desc: 'Add, remove, toggle CSS classes' },
      { label: 'HTML API (innerHTML vs textContent)', path: '/dom/innerhtml', desc: 'HTML and text content manipulation' },
      { label: 'Style API (element.style)', path: '/dom/style', desc: 'Inline style manipulation' },
    ],
  },
  {
    title: 'Tailwind CSS',
    items: [{ label: 'Tailwind Showcase', path: '/tailwind', desc: 'Utility-first CSS framework demonstrations' }],
  },
  {
    title: 'Networking',
    items: [
      { label: 'Fetch / XHR / FormData', path: '/network', desc: 'HTTP requests and form data handling' },
      { label: 'WebSocket (echo)', path: '/websocket', desc: 'Real-time bidirectional communication' },
    ],
  },
  {
    title: 'Storage',
    items: [
      { label: 'Web Storage (localStorage / sessionStorage)', path: '/web-storage', desc: 'Client-side key-value storage' },
      { label: 'Cookies', path: '/cookies', desc: 'HTTP cookies management' },
    ],
  },
  { title: 'URL & Encoding', items: [{ label: 'URL / Base64 / TextEncoder', path: '/url-encoding', desc: 'URL parsing and text encoding utilities' }] },
  {
    title: 'Graphics',
    items: [
      { label: 'Image Gallery', path: '/image', desc: 'Display various image formats: PNG, JPEG, GIF, WebP, and SVG' },
      { label: 'Canvas 2D', path: '/canvas-2d', desc: 'Draw shapes, text, and images with Canvas 2D API' },
      { label: 'SVG via <img>', path: '/svg-image', desc: 'Render SVG using <img src="...">' },
    ],
  },
  {
    title: 'Cupertino UI',
    items: [
      { label: 'Cupertino UI Showcase', path: '/cupertino-showcase', desc: 'Cupertino components overview' },
      { label: 'Cupertino Buttons', path: '/cupertino/buttons', desc: 'Buttons with iOS styling' },
      { label: 'Cupertino Tabs', path: '/cupertino/tabs', desc: 'iOS-style tab navigation' },
      { label: 'Cupertino Icons', path: '/cupertino/icons', desc: 'Cupertino icon set' },
      { label: 'Cupertino Colors', path: '/cupertino/colors', desc: 'iOS color palette' },
      { label: 'Cupertino Modal Popup', path: '/cupertino/modal-popup', desc: 'iOS-style modal popup' },
      { label: 'Cupertino Action Sheet', path: '/cupertino/actionsheet', desc: 'Bottom sheet actions' },
      { label: 'Cupertino Alert', path: '/cupertino/alert', desc: 'Alert dialogs' },
      { label: 'Cupertino Controls', path: '/cupertino/controls', desc: 'Switches, sliders and more' },
      { label: 'Cupertino Context Menu', path: '/cupertino/context-menu', desc: 'Peek and pop context actions' },
      { label: 'Cupertino List Section', path: '/cupertino/list-section', desc: 'Grouped list sections' },
      { label: 'Cupertino List Tile', path: '/cupertino/list-tile', desc: 'iOS-style list tiles' },
      { label: 'Cupertino Form Section', path: '/cupertino/form-section', desc: 'Form rows and grouped settings' },
      { label: 'Cupertino Text Field', path: '/cupertino/text-field', desc: 'Single-line iOS-style text input' },
    ],
  },
  {
    title: 'Others',
    items: [
      { label: 'Theme Toggle', path: '/theme-toggle', desc: 'Switch between themes' },
      { label: 'Gesture Detection', path: '/gesture', desc: 'Native gesture detection' },
      { label: 'Dragable List', path: '/dragable-list', desc: 'Touch-based draggable list with reordering' },
      { label: 'WebFListView', path: '/listview', desc: 'Long list optimized for WebF' },
      { label: 'Routing & Navigation', path: '/routing', desc: 'HybridHistory navigation patterns' },
      { label: 'Native Interaction', path: '/native-interaction', desc: 'Bridge to native modules' },
    ],
  },
];

function navigate(path: string) {
  WebFRouter.pushState({}, path);
}

function onListViewAttached() {
  console.log('list view attached');
}
</script>

<template>
  <div id="main" class="min-h-screen w-full">
    <webf-list-view class="w-full px-3 py-6 md:px-6 max-w-4xl mx-auto" v-flutter-attached="onListViewAttached">
      <div class="w-full flex justify-center items-center mb-8">
        <div class="bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 p-6 rounded-2xl text-white shadow-lg w-full">
          <h1 class="text-3xl font-bold mb-2 drop-shadow">WebF Feature Catalog</h1>
          <p class="text-base leading-relaxed opacity-90">
            Explore WebF capabilities organized by feature areas - CSS, DOM, Graphics, Forms, and more
          </p>
        </div>
      </div>

      <template v-for="section in sections" :key="section.title">
        <h2 class="text-lg font-semibold opacity-90 mt-6 mb-3 pl-3 border-l-4 border-blue-500">
          {{ section.title }}
        </h2>

        <button
          v-for="item in section.items"
          :key="item.path"
          class="flex w-full items-center p-4 border-b border-white/10 cursor-pointer transition-colors hover:bg-white/10"
          @click="navigate(item.path)"
        >
          <div class="flex-1">
            <div class="text-base font-semibold mb-1">{{ item.label }}</div>
            <div v-if="item.desc" class="text-sm opacity-80 leading-snug">{{ item.desc }}</div>
          </div>
          <div class="text-base opacity-70 font-bold ml-3">&gt;</div>
        </button>
      </template>
    </webf-list-view>
  </div>
</template>
