---
name: webf-prerendering
description: Use when writing JavaScript/HTML/CSS or React components for a WebF app that runs in prerendering mode, debugging clientWidth/clientHeight returning 0 inside a WebF page or from within a useEffect/useLayoutEffect, handling the `prerendered` / `load` / `DOMContentLoaded` event order in WebF, choosing between `useFlutterAttached` / `WebFLazyRender` and raw window events, or migrating a WebF page to prerendering mode for faster startup.
---

# WebF Prerendering Mode — Frontend Guide

## Overview

WebF's prerendering mode runs your page's JavaScript **before the Flutter widget is mounted**. Layout and paint are deferred until mount, so every viewport- or geometry-reading API (`clientWidth`, `clientHeight`, `innerWidth`, `innerHeight`, `getBoundingClientRect()`) returns `0` while your top-level script executes. When the widget finally mounts, four events fire on `window` in a fixed order: **`resize` → `DOMContentLoaded` → `load` → `prerendered`**. That's the entire contract you need to honor.

The reward for honoring it is up to ~90% faster startup: the page's JS and styles are already evaluated by the time Flutter is ready to show pixels.

## When to use this skill

Use it when you are:

- Writing frontend code (JS/HTML/CSS) for a WebF page that the embedder launches with `preRendering()` / `addWithPrerendering()`
- Debugging `clientWidth` / `clientHeight` / `getBoundingClientRect()` returning `0` inside a WebF page
- Wondering why a `prerendered` event listener never fires
- Migrating an existing WebF page from standard mode to prerendering mode
- Choosing between WebF's standard / preload / prerendering launch modes from the JS side

**Do NOT use this skill for:**

- Configuring the embedder (Dart/Flutter side — `WebFController.preRendering()`, `WebFControllerManager`). That's the embedder's job and is documented in `webf/lib/src/launcher/controller.dart`.
- Browser-platform prerendering (Chrome Speculation Rules, `document.prerendering`, `prerenderingchange`). Those APIs do **not** exist in WebF — the `prerendered` event below is WebF-specific.

## The three WebF launch modes at a glance

| Mode | When your JS runs | Layout / paint during JS | `clientWidth` before mount | Code constraints |
|---|---|---|---|---|
| **Standard** | After widget mount | Yes | n/a — JS hasn't run | None |
| **Preload** | After widget mount (resources fetched early) | Yes | n/a — JS hasn't run | None |
| **Prerendering** | **Before** widget mount | **No** | Returns `0` | Dimension-dependent code must defer to a window event |

A page written for prerendering mode runs unchanged in standard and preload modes. The constraint is one-way: prerender-ready code is always backward compatible.

## The frontend contract

Four rules. Memorize these.

1. **Geometry APIs return 0 during prerender.** `clientWidth`, `clientHeight`, `innerWidth`, `innerHeight`, `getBoundingClientRect()`, and any property derived from layout produce `0` (or zero-sized rects) while your top-level script runs. CSS still parses and the cascade still resolves — only layout and paint are deferred.

2. **On mount, four events fire on `window` in this order:**
   ```
   resize  →  DOMContentLoaded  →  load  →  prerendered
   ```
   By the time any of them fires, layout has run and geometry is real.

3. **`prerendered` fires exactly once.** It is guarded by an internal "already-dispatched" flag in WebF. If you attach a listener *after* the event has already fired, it will never trigger for you.

4. **Animation frame and timeline are paused during prerender.** `requestAnimationFrame` callbacks queued during prerender do **not** run until the widget mounts. CSS animations and transitions are also held. Don't use `rAF` as a "wait for layout" trick.

## Quick reference — where does my code go?

| I want to… | Put it in… |
|---|---|
| Fetch data, prepare state, build DOM | Top-level — runs immediately during prerender, that's the win |
| Register event listeners on `window` / `document` / elements | Top-level — must be attached *before* the events fire on mount |
| Read `clientWidth` / `getBoundingClientRect()` for the first time | `prerendered`, `load`, or `DOMContentLoaded` callback |
| Initialize a `<canvas>` at viewport size | `prerendered` (final layout is settled) |
| Start an entrance animation | `load` or `prerendered` |
| Auto-focus an input | `load` or `prerendered` |
| Set up an IntersectionObserver / ResizeObserver | Top-level is fine; observer callbacks fire after mount anyway |
| Restore scroll position | `prerendered` |

**Pick `prerendered` when you specifically need "post-prerender" semantics; pick `load` if the same code should also work in standard mode without changes.** `load` fires in every mode; `prerendered` fires only in prerendering mode.

## Migration — before and after

### Example 1: Chart that reads container size

```javascript
// ❌ Before — breaks in prerender (width = 0)
import { Chart } from './chart-lib.js';

const container = document.getElementById('chart-container');
const chart = new Chart(container, {
  width:  container.clientWidth,
  height: container.clientHeight,
});
chart.render();
```

```javascript
// ✅ After — works in standard, preload, and prerender modes
import { Chart } from './chart-lib.js';

const container = document.getElementById('chart-container');
let chart;

// Register the listener at top level so it's attached before the event fires.
window.addEventListener('load', () => {
  chart = new Chart(container, {
    width:  container.clientWidth,
    height: container.clientHeight,
  });
  chart.render();
});
```

Why `load` and not `prerendered`? `load` fires in every launch mode, so the same code works regardless of how the embedder starts the page. Use `prerendered` only when you specifically want code that fires *just* in prerendering mode.

### Example 2: Scroll position restore

```javascript
// ❌ Before — runs during prerender, before layout exists, scroll is a no-op
const savedY = sessionStorage.getItem('scrollY');
if (savedY) window.scrollTo(0, Number(savedY));
```

```javascript
// ✅ After — restore after layout is real
const savedY = sessionStorage.getItem('scrollY');
window.addEventListener('prerendered', () => {
  if (savedY) window.scrollTo(0, Number(savedY));
}, { once: true });
```

## Common mistakes

| Mistake | Why it breaks | Fix |
|---|---|---|
| Reading `clientWidth` / `getBoundingClientRect()` at module top level | Layout has not run yet during prerender; result is `0` | Move into a `load` or `prerendered` listener |
| Attaching `addEventListener('prerendered', …)` *after* the chart/initialization code that supposedly triggers it | The event has already fired by the time the listener attaches; it fires once and is not replayed | Register the listener at module top level, before any awaits or async work |
| Confusing WebF's `prerendered` event with the browser's Speculation Rules (`document.prerendering`, `prerenderingchange`) | These browser APIs do not exist in WebF — `document.prerendering` is `undefined`, `prerenderingchange` never fires | Use the WebF `window` event `prerendered` instead |
| Using `setTimeout(fn, 0)` or `setTimeout(fn, 100)` to "wait until layout is ready" | Timers fire during prerender too; dimensions are still `0`. Larger delays only race with mount | Use the `load` or `prerendered` event |
| Using `requestAnimationFrame` to wait for layout | Animation frame is paused during prerender; the callback queues but doesn't run until mount, by which time `load` has already fired | Use the `load` or `prerendered` event |
| Listening on `document` instead of `window` | `prerendered` is dispatched on `window` only | `window.addEventListener('prerendered', …)` |
| Relying on `document.visibilityState === 'prerender'` | WebF does not implement the Speculation Rules visibility extension | There is no synchronous "am I prerendering?" check from JS today; assume you are if you're a prerender-eligible bundle, or feature-detect another way |

## Debugging checklist

Walk through these in order.

- **Dimensions still `0` *after* widget mount?** The embedder is probably not using prerender mode. From the embedder's Dart code, confirm `WebFController.preRenderingStatus` reaches `PreRenderingStatus.done`. If status is `none`, this is a standard-mode launch and these rules don't apply.
- **`prerendered` event never fires?** Two likely causes:
  1. The listener was attached after the event already fired (most common — move `addEventListener` to top level).
  2. The page was launched in standard or preload mode, where `prerendered` does not fire at all. Use `load` instead for a mode-agnostic hook.
- **Page stuck at "loading" indefinitely?** Prerendering has a default **20 second** timeout (configurable via the `timeout` argument to `preRendering()`). After that, `PreRenderingStatus` becomes `fail` and the page never mounts. Profile what's taking >20s during evaluate phase (a synchronous network call, a heavy bundle, etc.) and either speed it up or extend the timeout from the embedder side.
- **Animations not running?** They were started during prerender, while the animation timeline was paused. Move animation triggers into `load` or `prerendered`.
- **`load` fires but `prerendered` doesn't?** Confirms the page is in standard / preload mode. Either accept this and rely on `load`, or have the embedder switch to `addWithPrerendering()`.
- **First paint flashes wrong dimensions then corrects?** Top-level code is rendering before listening for `load`. Defer the initial render call into the `load` listener.

## React patterns

In a WebF app written with React, the mental model is: **"React mounted" ≠ "Flutter widget mounted."** React commits the tree during the prerender phase — `useEffect` and `useLayoutEffect` run, refs are set, the DOM node exists — but no WebF element has been attached to Flutter's render tree yet, so layout hasn't happened and every geometry read returns `0`.

WebF gives you a precise per-element signal for that transition: the **`onscreen`** and **`offscreen`** DOM events. They are dispatched directly from Flutter's element lifecycle hooks in `webf/lib/src/dom/element_widget_adapter.dart` (the `mount()` and `unmount()` methods of `WebFReplacedElementWidgetState` and `WebRenderLayoutRenderObjectElement`), which means:

- **`onscreen` fires on an element the moment Flutter mounts the widget that represents it** — i.e. layout has been performed for that element. `clientWidth`, `getBoundingClientRect()`, etc. are now real.
- **`offscreen` fires when Flutter unmounts the widget** — for example, when the element is removed from the DOM, or when its containing route/tab is swapped out.

These events fire for every WebF element, in every launch mode. In prerender mode they fire after the prerender phase completes; in standard mode they fire on the initial widget mount; for elements that mount later (lazy routes, virtualised lists, tab switches) they fire when those elements are actually attached.

The official React package **`@openwebf/react-core-ui`** exposes this signal as two helpers: **`useFlutterAttached`** and **`WebFLazyRender`**. Use them by default. Reach for raw page-level `load`/`prerendered` only when you genuinely need a page-wide signal.

### Lifecycle at a glance

| Phase | What is happening | What you can read |
|---|---|---|
| Prerender — React commit | DOM nodes created, refs set, `useEffect` / `useLayoutEffect` run | DOM exists; `clientWidth` is **0** |
| **─── boundary ───** | Flutter mounts the widget for the element | — |
| After boundary | element fires `onscreen`; `useFlutterAttached` callback runs | `clientWidth`, `getBoundingClientRect()` return **real** values |
| Element detached | element fires `offscreen`; `useFlutterAttached` cleanup runs | — |

The trap is reading `ref.current.clientWidth` from `useEffect` (left of the boundary). The fix is to do that read on `onscreen` (right of the boundary), which is what `useFlutterAttached` gives you.

### The useEffect trap

```tsx
// ❌ Wrong — useEffect runs on the React-level side of the boundary,
//    before Flutter has mounted the element. clientWidth is 0.
useEffect(() => {
  const { clientWidth, clientHeight } = ref.current!;
  new Chart(ref.current!, { width: clientWidth, height: clientHeight }).render();
}, []);
```

`useLayoutEffect` is not a fix — it runs *earlier* in React's lifecycle, not later. The thing you're waiting for is on the **Flutter** side of the boundary, and no React-side hook can see across it.

### Pattern A — `useFlutterAttached` (canonical for "this element is now rendered")

`useFlutterAttached(onAttached, onDetached?)` returns a ref callback. Attach it to the element you care about — plain `<div>`, custom WebF tag (`<WebFListView>`, `<WebFTable>`, …), anything. The `onAttached` callback runs on `onscreen` — at which point that element has real geometry. The optional `onDetached` callback runs on `offscreen` — the right place to dispose chart/canvas/observer resources.

```tsx
import { useFlutterAttached } from '@openwebf/react-core-ui';
import { useRef } from 'react';
import { Chart } from 'chart-lib';

export function ChartCard() {
  const chartRef = useRef<Chart | null>(null);

  const attachedRef = useFlutterAttached(
    (event) => {
      // We are now past the boundary — the element has real layout.
      const el = event.currentTarget as HTMLDivElement;
      chartRef.current = new Chart(el, {
        width: el.clientWidth,
        height: el.clientHeight,
      });
      chartRef.current.render();
    },
    () => {
      // Flutter has detached this element — release native resources.
      chartRef.current?.destroy();
      chartRef.current = null;
    },
  );

  return <div ref={attachedRef} style={{ width: '100%', height: 300 }} />;
}
```

Idiomatic notes (drawn from real WebF apps in this repo — see `webf_apps/bn-showcase`):

- Pass *both* callbacks, even when one body is empty — it documents intent and leaves a clean hook for adding cleanup later. Real apps match this style (`webf_apps/bn-showcase/src/pages/BitcoinPriceTailwind.tsx:34`).
- The hook's underlying listener is bound to the element you assign the ref to, so `event.currentTarget` inside the callback IS that node — no second ref needed.
- Equally fine to attach to a custom WebF element rather than the geometry-reader itself: `<WebFListView ref={attachedRef}>` is a common pattern when the listview wraps a virtualised area whose dimensions depend on the viewport.

### Pattern B — `WebFLazyRender` (placeholder until on-screen)

When you have an expensive subtree that should not even mount until the user actually navigates to it (off-screen tabs, hidden routes), wrap it in `WebFLazyRender`. The component renders a placeholder until its container fires `onscreen`, then swaps to the real children. Inside the children, every `useEffect` and `useFlutterAttached` callback runs *after* the boundary, so geometry reads work normally.

Real-world idiom (paraphrased from `webf_apps/bn-showcase/src/AppTailwind.tsx`):

```tsx
import { WebFLazyRender } from '@openwebf/react-core-ui';
import {
  FlutterCupertinoTabBar,
  FlutterCupertinoTabBarItem,
} from '@openwebf/react-cupertino-ui';

<FlutterCupertinoTabBar>
  <FlutterCupertinoTabBarItem title="Bitcoin" path="/bitcoin">
    <WebFLazyRender className="h-full" placeholder={<Skeleton />}>
      <BitcoinPricePage />
    </WebFLazyRender>
  </FlutterCupertinoTabBarItem>

  <FlutterCupertinoTabBarItem title="Demo" path="/demo">
    <WebFLazyRender className="h-full">
      <DemoPage />
    </WebFLazyRender>
  </FlutterCupertinoTabBarItem>
</FlutterCupertinoTabBar>
```

Non-active tabs only construct their subtree when the user navigates to them — eliminating the cost of prerendering pages the user may never visit.

### Pattern C — page-level signals (rare)

Patterns A and B cover almost every component-level need. Only use raw page-level events when you genuinely need a *page-wide* signal (e.g. a global analytics ping after the entire page is interactive). If you do: register the listener at **module top level**, never inside `useEffect`, and bridge the state into React via `useSyncExternalStore` or a `useState` set from a module-scoped subscription. The window events are `resize → DOMContentLoaded → load → prerendered` (see *The frontend contract* above).

### React-specific common mistakes

| Mistake | Why it breaks | Fix |
|---|---|---|
| Reading `ref.current.clientWidth` inside `useEffect` | `useEffect` runs on the React-level side of the boundary, before Flutter mounts the element | `useFlutterAttached` (Pattern A) |
| Switching to `useLayoutEffect` to "wait for layout" | `useLayoutEffect` runs *earlier* in React's lifecycle, not later. The thing you're waiting for is on the Flutter side of the boundary, which neither React effect can see | `useFlutterAttached` (Pattern A) |
| Hand-rolling `element.addEventListener('onscreen', …)` inside `useEffect` | Works, but reinvents the hook — easy to get the cleanup, ref-attachment, and StrictMode resilience wrong | Use `useFlutterAttached` directly |
| Subscribing to `window.prerendered` inside `useEffect` | `prerendered` fires once per page; if your component mounts late (lazy route, code-split chunk), the listener attaches after the event already fired and never triggers | Don't reach for `window.prerendered` for component-level concerns. Pattern A is element-scoped and resilient — every `onscreen` fires when the element itself is attached, regardless of when it mounts |
| Using `requestAnimationFrame` inside `useEffect` to wait for layout | rAF is paused during prerender; the callback queues but only fires after widget mount — by which time `useFlutterAttached` would have fired anyway | `useFlutterAttached` (Pattern A) |
| Wrapping the whole app in a single "wait until ready" gate | Defeats the prerender win — you re-render the entire tree at mount instead of letting React commit it during prerender | Pattern A *per component* that needs geometry; Pattern B *per route/tab* that should defer entirely |
| Forgetting the `onDetached` callback | Charts, canvases, observers leak when the element is detached (route change, tab swap) | Pass the second callback to `useFlutterAttached` and dispose there |

### React + WebF resources

- Package: `@openwebf/react-core-ui` — source at `packages/react-core-ui/`
- `useFlutterAttached`: `packages/react-core-ui/src/hooks/useFlutterAttached.ts`
- `WebFLazyRender`: `packages/react-core-ui/src/components/WebFLazyRender.tsx`
- Custom-element wrapper used by `webf codegen --framework=react`: `packages/react-core-ui/src/utils/createWebFComponent.tsx`
- Event dispatch source (Dart): `webf/lib/src/dom/element_widget_adapter.dart` lines 474–477 (onscreen) and 492–495 (offscreen)
- Event name constants: `webf/lib/src/dom/event.dart` (`EVENT_ON_SCREEN`, `EVENT_OFF_SCREEN`)
- Real-world usage examples: `webf_apps/bn-showcase/src/AppTailwind.tsx`, `webf_apps/bn-showcase/src/pages/BitcoinPriceTailwind.tsx`, `webf_apps/bn-showcase/src/pages/ChatRoomTailwind.tsx`
- All React versions ≥ 16.8 are supported

## See also

- Existing prose tutorial: `website/docs/tutorials/performance_optimization/prerendering_and_preload_mode.md`
- Source of truth (Dart): `webf/lib/src/launcher/controller.dart` — `preRendering()` method and `PreRenderingStatus` enum
- Source of truth for event dispatch order: `webf/lib/src/widget/webf.dart` — `_loadingInPreRenderingMode()`
- Embedder API for higher-level controller management: `webf/lib/src/launcher/controller_manager.dart` — `addWithPrerendering()`
