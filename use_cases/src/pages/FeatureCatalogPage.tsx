import React from 'react';
import { WebFRouter } from '../router';
import { WebFListView } from '@openwebf/react-core-ui';

type Item = { label: string; path: string; desc?: string };
type Section = { title: string; items: Item[] };

const sections: Section[] = [
  {
    title: 'DOM Core',
    items: [
      { label: 'DOM Measurements (getBoundingClientRect)', path: '/dom-bounding-rect' },
      { label: 'MutationObserver', path: '/mutation-observer' },
      { label: 'Events (mouse/touch/scroll/CustomEvent)', path: '/dom/events' },
      { label: 'Geometry (DOMMatrix/DOMPoint)', path: '/dom/geometry' },
      { label: 'Offsets (offsetWidth/Height/Top/Left)', path: '/dom/offsets' },
      { label: 'DOMTokenList (classList)', path: '/dom/classlist' },
      { label: 'HTML API (innerHTML vs textContent)', path: '/dom/innerhtml' },
      { label: 'Style API (element.style)', path: '/dom/style' },
    ],
  },
  {
    title: 'CSS',
    items: [
      { label: 'CSS Showcase', path: '/css-showcase' },
      { label: 'Flexbox', path: '/css/flex-layout' },
      { label: 'Positioned Layout', path: '/css/position' },
      { label: 'Display / Flow / Box', path: '/css/display-flow' },
      { label: 'Sizing', path: '/css/sizing' },
      { label: 'Inline & Inline Formatting', path: '/css/inline-formatting' },
      { label: 'Background', path: '/css/bg' },
      { label: 'Background Gradient', path: '/css/bg-gradient' },
      { label: 'Background Radial', path: '/css/bg-radial' },
      { label: 'Background Image', path: '/css/bg-image' },
      { label: 'Border', path: '/css/border' },
      { label: 'Border Radius', path: '/css/border-radius' },
      { label: 'Box Shadow', path: '/css/box-shadow' },
      { label: 'Overflow', path: '/css/overflow' },
      { label: 'Transforms', path: '/css/transforms' },
      { label: 'Transitions', path: '/css/transitions' },
      { label: 'Animations (Keyframes)', path: '/css/keyframes' },
      // { label: 'Clip Path', path: '/css/clip-path' },
      { label: 'Filter Effects', path: '/css/filter' },
      { label: 'Selectors', path: '/css/selectors' },
      { label: 'Values & Units', path: '/css/values-units' },
      { label: 'Animations', path: '/css/animation' },
    ],
  },
  {
    title: 'Tailwind CSS',
    items: [
      { label: 'Tailwind Showcase', path: '/tailwind' },
    ],
  },
  {
    title: 'Networking',
    items: [
      { label: 'Fetch / XHR / FormData', path: '/network' },
      { label: 'WebSocket (echo)', path: '/websocket' },
    ],
  },
  {
    title: 'Storage',
    items: [
      { label: 'Web Storage (localStorage / sessionStorage)', path: '/web-storage' },
      { label: 'Cookies', path: '/cookies' },
    ],
  },
  {
    title: 'URL & Encoding',
    items: [
      { label: 'URL / Base64 / TextEncoder', path: '/url-encoding' },
    ],
  },
  {
    title: 'Graphics',
    items: [
      { label: 'Canvas 2D', path: '/canvas-2d' },
      { label: 'SVG via <img>', path: '/svg-image' },
      { label: 'Image Preload', path: '/image-preload' },
    ],
  },
  {
    title: 'Modules & Ecosystem',
    items: [
      { label: 'Routing & Navigation', path: '/routing' },
      { label: 'Deep Links', path: '/deep-link' },
      { label: 'Flutter Interaction', path: '/flutter-interaction' },
      { label: 'Native Interaction', path: '/native-interaction' },
    ],
  },
  {
    title: 'Cupertino UI',
    items: [
      { label: 'Cupertino Showcase', path: '/cupertino-showcase', desc: 'iOS-style components and interactions' },
    ],
  },
  {
    title: 'Gestures',
    items: [
      { label: 'FlutterGestureDetector', path: '/gesture', desc: 'Native gesture detection with tap, pan, pinch, and rotate' },
    ],
  },
  // {
  //   title: 'Accessibility',
  //   items: [
  //     {
  //       label: 'Accessibility Use Cases',
  //       path: '/accessibility',
  //       desc: 'Landmarks, keyboard navigation, and accessible forms',
  //     },
  //   ],
  // },
  {
    title: 'Forms & Input',
    items: [
      { label: 'Form (Basic)', path: '/form' },
      { label: 'Basic Form Elements', path: '/basic-form-elements' },
      { label: 'Input Sizing', path: '/input-sizing' },
      { label: 'Form (Advanced)', path: '/advanced-form' },
    ],
  },
  {
    title: 'Others',
    items: [
      { label: 'Listview', path: '/listview' },
      { label: 'Tables', path: '/table' },
      { label: 'QR Code Generator', path: '/qrcode' },
      { label: 'Video Player', path: '/video' },
    ],
  },
];

export const FeatureCatalogPage: React.FC = () => {
  const navigate = (path: string) => WebFRouter.pushState({}, path);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">WebF Feature Catalog</h1>
          <p className="text-fg-secondary mb-6">Browse showcases grouped by supported feature areas.</p>

          <div className="flex flex-wrap -mx-2">
            {sections.map((section) => (
              <div key={section.title} className="w-full md:w-1/2 px-2 mb-4">
                <div className="bg-surface-secondary rounded-xl border border-line p-4 h-full">
                  <h2 className="text-lg font-medium text-fg-primary mb-2">{section.title}</h2>
                  <div className="divide-y divide-line">
                    {section.items.map((item) => (
                      <div
                        key={item.path}
                        className="-mx-2 px-2 py-2 cursor-pointer hover:bg-surface-hover rounded-md transition "
                        onClick={() => navigate(item.path)}
                      >
                        <div className="flex items-center justify-between">
                          <span className="text-fg-primary">{item.label}</span>
                          <span className="text-fg-secondary">&gt;</span>
                        </div>
                        {item.desc && (
                          <p className="text-sm text-fg-secondary mt-1">{item.desc}</p>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </div>
      </WebFListView>
    </div>
  );
};
