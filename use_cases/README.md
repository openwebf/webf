# WebF React Use Cases

This is a React implementation of the WebF use cases demo.

## Prerequisites

You need the WebF Go app to run these apps.

**iOS**

- Download from the App Store: [WebF Go](https://apps.apple.com/us/app/webf-go/id6754608818)

## Features

The demo includes the following feature areas (reflecting the current implementation). Open the Feature Catalog in the app to explore each:

- DOM Core
  - DOM measurements (getBoundingClientRect), MutationObserver
  - Events (mouse/touch/scroll/CustomEvent), Geometry (DOMMatrix/DOMPoint)
  - Offsets (offsetWidth/Height/Top/Left), DOMTokenList (classList)
  - HTML API (innerHTML vs textContent), Style API (element.style)

- CSS
  - Layout: Flexbox, Display/Flow/Box, Positioned layout
  - Visuals: Backgrounds (image/gradient/radial), Border/Radius, Box Shadow
  - Effects: Transforms, Transitions, Animations (Keyframes), Clip Path, Filter Effects
  - Text & sizing: Inline formatting, Sizing, Selectors, Values & Units
  - CSS showcase and animation demos

- Tailwind CSS
  - Tailwind showcase and tokenized design system

- Networking
  - Fetch / XHR / FormData, WebSocket echo

- Storage
  - Web Storage (localStorage / sessionStorage), Cookies

- URL & Encoding
  - URL, Base64, TextEncoder/TextDecoder

- SVG & Media
  - SVG via <img>, Image preload, Video player, Image basics

- Modules & Ecosystem
  - Routing & navigation, Deep links
  - Flutter interaction, Native interaction

- Cupertino UI
  - Cupertino Buttons, Action Sheet, Alert Dialog, Switches & Sliders

- UI Components & Interactions
  - Showcase/highlight tooltips, Action sheets, Context menu, Modal popup, Loading, Alerts, Gestures

- Lists & Tables
  - ListView with refresh/load more, Tables

- Forms
  - Basic form, Basic form elements, Input sizing, Advanced forms & validation

- Typography & Theme
  - Typography, FontFace, Responsive layouts, Theme toggle

## Project Structure

```
src/
├── components/
│   └── RouterView.tsx          # Router component wrapper
├── pages/
│   ├── HomePage.tsx            # Main navigation page
│   ├── ShowCasePage.tsx        # Showcase demonstrations
│   ├── ListviewPage.tsx        # ListView examples
│   └── FormPage.tsx            # Form validation examples
├── utils/
│   └── CreateComponent.tsx     # Utility for creating WebF components
├── App.tsx                     # Main application component
└── index.tsx                   # Application entry point
```

## Getting Started

1. Install dependencies:
   ```bash
   # with npm
   npm install
   # or with yarn
   yarn install
   ```

2. Start the development server (Vite):
   ```bash
   # with npm
   npm run dev
   # or for compatibility
   npm start
   # with yarn
   yarn dev
   ```

3. Build for production (Vite):
   ```bash
   # with npm
   npm run build
   # with yarn
   yarn build
   ```

4. Preview the production build locally:
   ```bash
   # with npm
   npm run preview
   # with yarn
   yarn preview
   ```
