import React from 'react';
import { WebFRouter } from '../router';
import { WebFListView } from '@openwebf/react-core-ui';

type Item = { label: string; path: string; desc?: string };
type Section = { title: string; items: Item[] };

const sections: Section[] = [
  {
    title: 'Core UI',
    items: [
      { label: 'FlutterGestureDetector', path: '/gesture', desc: 'Native gesture detection with tap, pan, pinch, and rotate' },
      { label: 'WebFListView', path: '/listview', desc: 'Infinite scrolling list optimized for long lists' },
      { label: 'Dragable List', path: '/dragable-list', desc: 'Touch-based draggable list with smooth reordering' },
    ],
  },
  {
    title: 'Hybrid Router',
    items: [
      { label: 'Routing & Navigation', path: '/routing', desc: 'Client-side routing and navigation' },
    ],
  },
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
      // { label: 'Selectors', path: '/css/selectors', desc: 'Attribute, pseudo, combinators' },
      { label: 'Values & Units', path: '/css/values-units', desc: 'px, em, rem, vw, vh, calc()' },
    ],
  },
  {
    title: 'DOM Core',
    items: [
      { label: 'DOM Measurements (getBoundingClientRect)', path: '/dom-bounding-rect', desc: 'Get element size and position relative to viewport' },
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
    items: [
      { label: 'Tailwind Showcase', path: '/tailwind', desc: 'Utility-first CSS framework demonstrations' },
    ],
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
  {
    title: 'URL & Encoding',
    items: [
      { label: 'URL / Base64 / TextEncoder', path: '/url-encoding', desc: 'URL parsing and text encoding utilities' },
    ],
  },
  {
    title: 'Graphics',
    items: [
      { label: 'Image Gallery', path: '/image', desc: 'Display various image formats: PNG, JPEG, GIF, WebP, and SVG' },
      { label: 'Canvas 2D', path: '/canvas-2d', desc: 'Draw shapes, text, and images with Canvas 2D API' },
      { label: 'SVG via <img>', path: '/svg-image', desc: 'Inline SVG data URLs with gradients, patterns, paths, and icons' },
      // { label: 'Image Preload', path: '/image-preload', desc: 'Preload images for better performance' },
    ],
  },
  {
    title: 'Native Plugins',
    items: [
      { label: 'WebF Share', path: '/webf-share', desc: 'Share and save content via native APIs' },
      { label: 'WebF SQFlite', path: '/webf-sqflite', desc: 'SQLite database for persistent local storage' },
      { label: 'WebF Bluetooth', path: '/webf-bluetooth', desc: 'Bluetooth Low Energy device scanning and connection' },
    ],
  },
  {
    title: 'Native UI',
    items: [
      { label: 'WebF Video Player', path: '/webf-video-player', desc: 'HTML5-compatible video player with native Flutter performance' },
      { label: 'WebF Camera', path: '/webf-camera', desc: 'Native camera with photo capture and video recording' },
    ],
  },
  {
    title: 'Cupertino UI',
    items: [
      { label: 'Cupertino Showcase', path: '/cupertino-showcase', desc: 'iOS-style components and interactions' },
      { label: 'Cupertino Colors', path: '/cupertino/colors', desc: 'Static and dynamic Cupertino colors' },
      { label: 'Cupertino Icons', path: '/cupertino/icons', desc: 'iOS SF Symbols icon set' },
      { label: 'Tabs', path: '/cupertino/tabs', desc: 'TabScaffold · TabBar · TabView · Controller' },
      { label: 'Cupertino Alert Dialog', path: '/cupertino/alert', desc: 'Alerts & dialog actions' },
      { label: 'Cupertino Action Sheet', path: '/cupertino/actionsheet', desc: 'Action sheet and sheet actions' },
      { label: 'Cupertino Modal Popup', path: '/cupertino/modal-popup', desc: 'Bottom sheet style modal popup' },
      { label: 'Cupertino Context Menu', path: '/cupertino/context-menu', desc: 'Peek and pop context actions' },
      { label: 'CupertinoListSection', path: '/cupertino/list-section', desc: 'Grouped list sections' },
      { label: 'CupertinoListTile', path: '/cupertino/list-tile', desc: 'iOS-style list tiles' },
      { label: 'CupertinoFormSection', path: '/cupertino/form-section', desc: 'Form rows and grouped settings' },
      { label: 'CupertinoTextField', path: '/cupertino/text-field', desc: 'Single-line iOS-style text input' },
      { label: 'CupertinoTextFormFieldRow', path: '/cupertino/text-form-field-row', desc: 'Inline text field row for forms' },
      { label: 'CupertinoSearchTextField', path: '/cupertino/search-text-field', desc: 'iOS-style search bar' },
      { label: 'CupertinoDatePicker', path: '/cupertino/date-picker', desc: 'iOS date & time picker' },
      { label: 'Cupertino Buttons', path: '/cupertino/buttons', desc: 'Buttons with iOS styling' },
      { label: 'CupertinoSwitch', path: '/cupertino/switch', desc: 'iOS-style toggle' },
      { label: 'CupertinoSlider', path: '/cupertino/slider', desc: 'Value selection slider' },
      { label: 'Sliding Segmented Control', path: '/cupertino/sliding-segmented-control', desc: 'Segmented control with sliding thumb' },
      { label: 'CupertinoCheckBox', path: '/cupertino/checkbox', desc: 'iOS checkbox' },
      { label: 'CupertinoRadio', path: '/cupertino/radio', desc: 'iOS radio button' },
    ],
  },
  {
    title: 'Forms & Input',
    items: [
      { label: 'Form (Basic)', path: '/form', desc: 'Basic form elements and validation' },
      { label: 'Basic Form Elements', path: '/basic-form-elements', desc: 'Input, textarea, select, and button elements' },
      { label: 'Input Sizing', path: '/input-sizing', desc: 'Dynamic input field sizing' },
      { label: 'Form (Advanced)', path: '/advanced-form', desc: 'Advanced form patterns and validation' },
    ],
  },
  // {
  //   title: 'Others',
  //   items: [
  //     { label: 'Tables', path: '/table', desc: 'HTML table layouts and styling' },
  //     { label: 'QR Code Generator', path: '/qrcode', desc: 'Generate QR codes dynamically' },
  //     { label: 'Video Player', path: '/video', desc: 'HTML5 video playback' },
  //   ],
  // },
];

export const FeatureCatalogPage: React.FC = () => {
  const navigate = (path: string) => WebFRouter.pushState({}, path);

  const Item = (props: { label: string; desc?: string; path: string }) => (
    <div
      className="flex items-center p-4 border-b border-gray-200 dark:border-gray-700 last:border-b-0 cursor-pointer transition-colors hover:bg-surface-hover"
      onClick={() => navigate(props.path)}
    >
      <div className="flex-1">
        <div className="text-base font-semibold text-gray-800 dark:text-white mb-1">{props.label}</div>
        {props.desc && (
          <div className="text-sm text-gray-600 dark:text-gray-400 leading-snug">{props.desc}</div>
        )}
      </div>
      <div className="text-base text-gray-400 dark:text-gray-500 font-bold ml-3">&gt;</div>
    </div>
  );

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
        {/* Header */}
        <div className="w-full flex justify-center items-center mb-8">
          <div className="bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 p-6 rounded-2xl text-white shadow-lg w-full">
            <h1 className="text-3xl font-bold mb-2 drop-shadow">WebF Feature Catalog</h1>
            <p className="text-base leading-relaxed opacity-90">
              Explore WebF capabilities organized by feature areas - CSS, DOM, Graphics, Forms, and more
            </p>
          </div>
        </div>

        {/* Sections - flattened for WebFListView optimization */}
        {sections.map((section, sectionIndex) => (
          <div key={section.title} className="">
            {/* Section Header */}
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mt-6 mb-3 pl-3 border-l-4 border-blue-500">
              {section.title}
            </h2>

            {/* Section Container */}
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-md overflow-hidden border border-gray-200 dark:border-gray-700 mb-4">
              {section.items.map((item) => (
                <Item key={item.path} label={item.label} desc={item.desc} path={item.path} />
              ))}
            </div>
          </div>
        ))}
      </WebFListView>
    </div>
  );
};
