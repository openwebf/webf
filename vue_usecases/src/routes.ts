import { defineAsyncComponent, type Component } from 'vue';

export type AppRoute = {
  path: string;
  title: string;
  theme?: 'material' | 'cupertino';
  element: Component;
};

export const appRoutes: AppRoute[] = [
  { path: '/', title: 'Feature Catalog', element: defineAsyncComponent(() => import('./pages/FeatureCatalogPage.vue')) },
  { path: '/features', title: 'Feature Catalog', element: defineAsyncComponent(() => import('./pages/FeatureCatalogPage.vue')) },
  { path: '/home', title: 'Home', element: defineAsyncComponent(() => import('./pages/HomePage.vue')) },
  { path: '/tailwind', title: 'Tailwind CSS Showcase', element: defineAsyncComponent(() => import('./pages/TailwindShowcasePage.vue')) },

  // Feature catalog routes
  { path: '/cookies', title: 'Cookies', element: defineAsyncComponent(() => import('./pages/CookiesPage.vue')) },
  { path: '/url-encoding', title: 'URL & Encoding', element: defineAsyncComponent(() => import('./pages/UrlEncodingPage.vue')) },
  { path: '/websocket', title: 'WebSocket', element: defineAsyncComponent(() => import('./pages/WebSocketPage.vue')) },
  { path: '/svg-image', title: 'SVG via Img', element: defineAsyncComponent(() => import('./pages/SvgImagePage.vue')) },
  { path: '/accessibility', title: 'Accessibility Use Cases', element: defineAsyncComponent(() => import('./pages/AccessibilityPage.vue')) },
  { path: '/webf-share', title: 'WebF Share', element: defineAsyncComponent(() => import('./pages/WebFSharePage.vue')) },
  { path: '/webf-camera', title: 'WebF Camera', element: defineAsyncComponent(() => import('./pages/WebFCameraPage.vue')) },
  { path: '/webf-bluetooth', title: 'WebF Bluetooth', element: defineAsyncComponent(() => import('./pages/WebFBluetoothPage.vue')) },
  { path: '/form', title: 'Form (Basic)', element: defineAsyncComponent(() => import('./pages/FormPage.vue')) },
  {
    path: '/basic-form-elements',
    title: 'Basic Form Elements',
    element: defineAsyncComponent(() => import('./pages/BasicFormElementsPage.vue')),
  },
  { path: '/input-sizing', title: 'Input Sizing', element: defineAsyncComponent(() => import('./pages/InputSizingPage.vue')) },
  { path: '/advanced-form', title: 'Form (Advanced)', element: defineAsyncComponent(() => import('./pages/FormAdvancedPage.vue')) },

  // DOM
  { path: '/dom/events', title: 'DOM Events', element: defineAsyncComponent(() => import('./pages/dom/DOMEventsPage.vue')) },
  { path: '/dom/geometry', title: 'DOM Geometry', element: defineAsyncComponent(() => import('./pages/dom/DOMGeometryPage.vue')) },
  { path: '/dom/offsets', title: 'DOM Offsets', element: defineAsyncComponent(() => import('./pages/dom/DOMOffsetsPage.vue')) },
  {
    path: '/dom/classlist',
    title: 'DOMTokenList (classList)',
    element: defineAsyncComponent(() => import('./pages/dom/DOMClassListPage.vue')),
  },
  {
    path: '/dom/innerhtml',
    title: 'innerHTML vs textContent',
    element: defineAsyncComponent(() => import('./pages/dom/DOMInnerHTMLPage.vue')),
  },
  { path: '/dom/style', title: 'element.style', element: defineAsyncComponent(() => import('./pages/dom/DOMStylePage.vue')) },

  // Graphics
  { path: '/canvas-2d', title: 'Canvas 2D', element: defineAsyncComponent(() => import('./pages/Canvas2dPage.vue')) },

  // CSS
  { path: '/css/bg', title: 'Background', element: defineAsyncComponent(() => import('./pages/css/BGPage.vue')) },
  { path: '/css/bg-gradient', title: 'Background Gradient', element: defineAsyncComponent(() => import('./pages/css/BGGradientPage.vue')) },
  { path: '/css/bg-image', title: 'Background Image', element: defineAsyncComponent(() => import('./pages/css/BGImagePage.vue')) },
  { path: '/css/bg-radial', title: 'Background Radial', element: defineAsyncComponent(() => import('./pages/css/BGRadialPage.vue')) },
  { path: '/css/border', title: 'Border', element: defineAsyncComponent(() => import('./pages/css/BorderPage.vue')) },
  {
    path: '/css/border-radius',
    title: 'Border Radius',
    element: defineAsyncComponent(() => import('./pages/css/BorderRadiusPage.vue')),
  },
  { path: '/css/box-shadow', title: 'Box Shadow', element: defineAsyncComponent(() => import('./pages/css/BoxShadowPage.vue')) },
  { path: '/css/filter', title: 'Filter', element: defineAsyncComponent(() => import('./pages/css/FilterPage.vue')) },
  { path: '/css/flex-layout', title: 'Flex Layout', element: defineAsyncComponent(() => import('./pages/css/FlexLayoutPage.vue')) },
  { path: '/css/keyframes', title: 'Keyframes', element: defineAsyncComponent(() => import('./pages/css/KeyframesPage.vue')) },
  {
    path: '/css/border-background-shadow',
    title: 'Border Background Shadow',
    element: defineAsyncComponent(() => import('./pages/css/BorderBackgroundShadowPage.vue')),
  },
  { path: '/css/overflow', title: 'Overflow', element: defineAsyncComponent(() => import('./pages/css/OverflowPage.vue')) },
  { path: '/css/transforms', title: 'Transforms', element: defineAsyncComponent(() => import('./pages/css/TransformsPage.vue')) },
  { path: '/css/animation', title: 'Animations', element: defineAsyncComponent(() => import('./pages/AnimationPage.vue')) },
  { path: '/css/transitions', title: 'Transitions', element: defineAsyncComponent(() => import('./pages/css/TransitionsPage.vue')) },
  { path: '/css/display-flow', title: 'Display & Flow', element: defineAsyncComponent(() => import('./pages/css/DisplayFlowPage.vue')) },
  { path: '/css/sizing', title: 'Sizing', element: defineAsyncComponent(() => import('./pages/css/SizingPage.vue')) },
  {
    path: '/css/inline-formatting',
    title: 'Inline Formatting',
    element: defineAsyncComponent(() => import('./pages/css/InlineFormattingPage.vue')),
  },
  { path: '/css/position', title: 'Positioned Layout', element: defineAsyncComponent(() => import('./pages/css/PositionPage.vue')) },
  { path: '/css/selectors', title: 'Selectors', element: defineAsyncComponent(() => import('./pages/css/SelectorsPage.vue')) },
  { path: '/css/values-units', title: 'Values & Units', element: defineAsyncComponent(() => import('./pages/css/ValuesUnitsPage.vue')) },

  // Storage / DOM APIs
  { path: '/web-storage', title: 'Web Storage API', element: defineAsyncComponent(() => import('./pages/WebStoragePage.vue')) },
  {
    path: '/dom-bounding-rect',
    title: 'DOM getBoundingClientRect API',
    element: defineAsyncComponent(() => import('./pages/DOMBoundingRectPage.vue')),
  },
  {
    path: '/mutation-observer',
    title: 'MutationObserver API',
    element: defineAsyncComponent(() => import('./pages/MutationObserverPage.vue')),
  },

  // Cupertino
  {
    path: '/cupertino-showcase',
    title: 'Cupertino UI Showcase',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/CupertinoShowcasePage.vue')),
  },
  {
    path: '/cupertino/buttons',
    title: 'Cupertino Buttons',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoButtonsPage.vue')),
  },
  {
    path: '/cupertino/modal-popup',
    title: 'Cupertino Modal Popup',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoModalPopupPage.vue')),
  },
  {
    path: '/cupertino/actionsheet',
    title: 'Cupertino Action Sheet',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoActionSheetPage.vue')),
  },
  {
    path: '/cupertino/alert',
    title: 'Cupertino Alert Dialog',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoAlertPage.vue')),
  },
  {
    path: '/cupertino/controls',
    title: 'Cupertino Switches & Sliders',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoControlsPage.vue')),
  },
  {
    path: '/cupertino/colors',
    title: 'Cupertino Colors',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoColorsPage.vue')),
  },
  {
    path: '/cupertino/icons',
    title: 'Cupertino Icons',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoIconsPage.vue')),
  },
  {
    path: '/cupertino/tabs',
    title: 'Cupertino Tabs',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoTabsPage.vue')),
  },
  {
    path: '/cupertino/context-menu',
    title: 'Cupertino Context Menu',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoContextMenuPage.vue')),
  },
  {
    path: '/cupertino/list-section',
    title: 'Cupertino List Section',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoListSectionPage.vue')),
  },
  {
    path: '/cupertino/list-tile',
    title: 'Cupertino List Tile',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoListTilePage.vue')),
  },
  {
    path: '/cupertino/form-section',
    title: 'Cupertino Form Section',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoFormSectionPage.vue')),
  },
  {
    path: '/cupertino/text-field',
    title: 'Cupertino Text Field',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoTextFieldPage.vue')),
  },
  {
    path: '/cupertino/text-form-field-row',
    title: 'Cupertino TextFormFieldRow',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoTextFormFieldRowPage.vue')),
  },
  {
    path: '/cupertino/search-text-field',
    title: 'Cupertino Search Text Field',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoSearchTextFieldPage.vue')),
  },
  {
    path: '/cupertino/adaptive-text-selection-toolbar',
    title: 'Adaptive Text Selection Toolbar',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoAdaptiveTextSelectionToolbarPage.vue')),
  },
  {
    path: '/cupertino/text-selection-toolbar',
    title: 'Text Selection Toolbar',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoTextSelectionToolbarPage.vue')),
  },
  {
    path: '/cupertino/desktop-text-selection-toolbar',
    title: 'Desktop Text Selection Toolbar',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoDesktopTextSelectionToolbarPage.vue')),
  },
  {
    path: '/cupertino/text-selection-controls',
    title: 'Text Selection Controls',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoTextSelectionControlsPage.vue')),
  },
  {
    path: '/cupertino/magnifier',
    title: 'Cupertino Magnifier',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoMagnifierPage.vue')),
  },
  {
    path: '/cupertino/spell-check-suggestions-toolbar',
    title: 'Spell Check Suggestions Toolbar',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoSpellCheckSuggestionsToolbarPage.vue')),
  },
  {
    path: '/cupertino/date-picker',
    title: 'Cupertino Date Picker',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoDatePickerPage.vue')),
  },
  {
    path: '/cupertino/timer-picker',
    title: 'Cupertino Timer Picker',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoTimerPickerPage.vue')),
  },
  {
    path: '/cupertino/picker',
    title: 'Cupertino Picker',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoPickerPage.vue')),
  },
  {
    path: '/cupertino/switch',
    title: 'Cupertino Switch',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoSwitchPage.vue')),
  },
  {
    path: '/cupertino/slider',
    title: 'Cupertino Slider',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoSliderPage.vue')),
  },
  {
    path: '/cupertino/sliding-segmented-control',
    title: 'Sliding Segmented Control',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoSlidingSegmentedControlPage.vue')),
  },
  {
    path: '/cupertino/checkbox',
    title: 'Cupertino CheckBox',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoCheckBoxPage.vue')),
  },
  {
    path: '/cupertino/radio',
    title: 'Cupertino Radio',
    theme: 'cupertino',
    element: defineAsyncComponent(() => import('./pages/cupertino/CupertinoRadioPage.vue')),
  },

  // Routing / Navigation
  { path: '/image-preload', title: 'Image Preload', element: defineAsyncComponent(() => import('./pages/ImagePreloadPage.vue')) },
  { path: '/routing/about', title: 'Routing Demo: About', element: defineAsyncComponent(() => import('./pages/routing/RoutingAboutPage.vue')) },
  { path: '/routing/users/:id', title: 'Routing Demo: User', element: defineAsyncComponent(() => import('./pages/routing/RoutingUserPage.vue')) },
  { path: '/routing/files/*', title: 'Routing Demo: Files', element: defineAsyncComponent(() => import('./pages/routing/RoutingFilesPage.vue')) },
  { path: '/routing', title: 'Routing & Navigation', element: defineAsyncComponent(() => import('./pages/RoutingPage.vue')) },
  { path: '/routing/*', title: 'Routing Demo: Not Found', element: defineAsyncComponent(() => import('./pages/routing/RoutingNotFoundPage.vue')) },

  // Dynamic Route Examples
  { path: '/user/:id', title: 'User Details', element: defineAsyncComponent(() => import('./pages/routeDemo/UserDetailsPage.vue')) },
  {
    path: '/dashboard/:year/:month/reports/:id',
    title: 'Report Details',
    element: defineAsyncComponent(() => import('./pages/routeDemo/ReportDetailsPage.vue')),
  },
  { path: '/profile/edit', title: 'Profile Edit', element: defineAsyncComponent(() => import('./pages/routeDemo/ProfileEditPage.vue')) },

  // Native UI
  {
    path: '/webf-video-player',
    title: 'WebF Video Player',
    element: defineAsyncComponent(() => import('./pages/WebFVideoPlayerPage.vue')),
  },

  // Other demos
  { path: '/native-interaction', title: 'WebF Share Module', element: defineAsyncComponent(() => import('./pages/NativeInteractionPage.vue')) },
  { path: '/network', title: 'Network Requests', element: defineAsyncComponent(() => import('./pages/NetworkPage.vue')) },
  { path: '/image', title: 'Image Gallery', element: defineAsyncComponent(() => import('./pages/ImagePage.vue')) },
  { path: '/typography', title: 'Typography', element: defineAsyncComponent(() => import('./pages/TypographyPage.vue')) },
  { path: '/fontface', title: 'Custom Fonts', element: defineAsyncComponent(() => import('./pages/FontFacePage.vue')) },
  { path: '/responsive', title: 'Responsive Design', element: defineAsyncComponent(() => import('./pages/ResponsivePage.vue')) },
  { path: '/alert', title: 'Alert', element: defineAsyncComponent(() => import('./pages/AlertPage.vue')) },
  { path: '/theme-toggle', title: 'Theme Toggle', element: defineAsyncComponent(() => import('./pages/ThemeTogglePage.vue')) },
  { path: '/gesture', title: 'Gesture Detection', element: defineAsyncComponent(() => import('./pages/GesturePage.vue')) },
  { path: '/dragable-list', title: 'Dragable List', element: defineAsyncComponent(() => import('./pages/DragableListPage.vue')) },
  { path: '/listview', title: 'WebFListView', element: defineAsyncComponent(() => import('./pages/ListviewPage.vue')) },
];
