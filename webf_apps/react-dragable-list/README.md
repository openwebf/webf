# react-dragable-list

A simple, touch-driven draggable list demo built with React, TypeScript and Vite. It reorders items with smooth transforms and minimal state, using `WebFTouchArea` from `@openwebf/react-core-ui` for reliable touch handling.

## Features
- Touch-first drag to reorder items
- No heavy DnD libraries; small, readable logic
- Smooth CSS transforms and transitions
- Responsive spacing based on viewport width

## Quick Start
- Prerequisites: Node.js 18+
- Install dependencies: `npm install`
- Start dev server: `npm run dev`
- Build for production: `npm run build`
- Preview production build: `npm run preview`
- Lint: `npm run lint`

## How It Works
- The list order is managed by an array of indices. When dragging, the current row is computed from the y‑position and the array is updated via a small `reinsert` helper.
- Items are positioned with `translate3d` and scaled slightly while active. Transitions are disabled during drag for immediate feedback.
- Touch events are handled on each item via `WebFTouchArea` (`onTouchStart`, `onTouchMove`, `onTouchEnd`).

Key logic lives in `src/App.tsx`:
- `list` defines the visible labels.
- `order` tracks the current order of items.
- `reinsert` moves an item within the array.
- `itemGap` and `itemHeight` control spacing and sizing.

Styles are in `src/App.css`, including colors, shadows, and the drag handle.

## Customize
- Items: edit `list` in `src/App.tsx`.
- Spacing/height: tweak `itemGap` and derived `itemHeight` in `src/App.tsx`.
- Colors and layout: adjust `.demo-item-*` and related classes in `src/App.css`.
- Drag handle: update the simple three‑line handle in `DragHandle` (also in `src/App.tsx`).

## Desktop Notes
This demo uses touch events. For desktop testing, enable a mobile device emulator in your browser’s dev tools. If you need mouse support, add `onMouseDown/onMouseMove/onMouseUp` handlers mirroring the touch logic.

## Tech Stack
- React 19 + TypeScript
- Vite 7
- `@openwebf/react-core-ui` (`WebFTouchArea`)

## Scripts
Defined in `package.json`:
- `dev` – start Vite dev server
- `build` – type‑check and build
- `preview` – preview the production build
- `lint` – run ESLint

## Folder Layout
- `src/App.tsx` – draggable list logic and UI
- `src/App.css` – styles for the demo
- `src/main.tsx` – React entry
- `index.html` – app shell
