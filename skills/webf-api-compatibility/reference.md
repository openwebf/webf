# WebF API & CSS Compatibility Reference

Complete compatibility tables for quick reference when building WebF applications.

## JavaScript & Web APIs

### ✅ Fully Supported APIs

#### Timers & Animation
| API | Status | Notes |
|-----|--------|-------|
| `setTimeout()` | ✅ | Full support |
| `clearTimeout()` | ✅ | Full support |
| `setInterval()` | ✅ | Full support |
| `clearInterval()` | ✅ | Full support |
| `requestAnimationFrame()` | ✅ | Full support, use for smooth animations |
| `cancelAnimationFrame()` | ✅ | Full support |

#### Storage APIs
| API | Status | Notes |
|-----|--------|-------|
| `localStorage` | ✅ | Persistent key-value storage |
| `sessionStorage` | ✅ | Session-only storage |
| `IndexedDB` | ❌ | Not supported - use native plugin |

#### Networking
| API | Status | Notes |
|-----|--------|-------|
| `fetch()` | ✅ | Full async/await support |
| `XMLHttpRequest` | ✅ | For legacy code |
| `WebSocket` | ✅ | Real-time bidirectional communication |
| `EventSource` | ✅ | Server-Sent Events (SSE) — server push, auto-reconnect, named events |
| `URL` | ✅ | URL parsing and manipulation |
| `URLSearchParams` | ✅ | Query string handling |

#### Graphics APIs
| API | Status | Notes |
|-----|--------|-------|
| Canvas 2D | ✅ | Full 2D canvas API |
| SVG | ✅ | SVG element rendering |
| WebGL | ❌ | Not available, no alternative |
| WebGL2 | ❌ | Not available, no alternative |

#### DOM APIs
| API | Status | Notes |
|-----|--------|-------|
| `document.*` | ✅ | Standard DOM APIs |
| `window.*` | ✅ | Standard window APIs |
| `navigator.*` | ✅ | Navigator object |
| `querySelector()` | ✅ | CSS selector queries |
| `querySelectorAll()` | ✅ | CSS selector queries |
| `getElementById()` | ✅ | ID-based lookup |
| `getElementsByClassName()` | ✅ | Class-based lookup |
| `getElementsByTagName()` | ✅ | Tag-based lookup |
| `createElement()` | ✅ | Create elements |
| `appendChild()` | ✅ | DOM manipulation |
| `removeChild()` | ✅ | DOM manipulation |
| `insertBefore()` | ✅ | DOM manipulation |
| `cloneNode()` | ✅ | Node cloning |
| Custom Elements | ✅ | Define custom HTML elements |
| Shadow DOM | ❌ | Not supported - use framework components |

#### Event APIs
| API | Status | Notes |
|-----|--------|-------|
| `addEventListener()` | ✅ | Standard event handling |
| `removeEventListener()` | ✅ | Standard event handling |
| `click` events | ✅ | Enabled by default |
| `input` events | ✅ | Form input handling |
| `change` events | ✅ | Form change handling |
| `submit` events | ✅ | Form submission |
| `onscreen` | ✅ | WebF-specific: element laid out |
| `offscreen` | ✅ | WebF-specific: element removed |
| Other gestures | ⚠️ | Via `FlutterGestureDetector` |

#### Observers
| API | Status | Notes |
|-----|--------|-------|
| `MutationObserver` | ✅ | Watch DOM changes |
| `IntersectionObserver` | ❌ | Use `onscreen`/`offscreen` events |
| `ResizeObserver` | ❌ | Not supported |

#### Workers & Threads
| API | Status | Notes |
|-----|--------|-------|
| Web Workers | ❌ | Not needed - JS runs on dedicated thread |
| Service Workers | ❌ | Not supported |
| Shared Workers | ❌ | Not supported |

#### Animation APIs
| API | Status | Notes |
|-----|--------|-------|
| CSS Animations | ✅ | `@keyframes`, `animation` property |
| CSS Transitions | ✅ | `transition` property |
| Web Animations API (JS) | ❌ | Not supported - use CSS animations |

### ⏳ Coming Soon

| API | Status | Expected |
|-----|--------|----------|
| CSS Grid | ⏳ | Future release |
| Tailwind CSS v4 | ⏳ | 2026 |

## CSS Compatibility

### Layout Modes

#### ✅ Fully Supported
| Layout Mode | Support | Notes |
|-------------|---------|-------|
| Block | ✅ | `display: block` |
| Inline | ✅ | `display: inline` |
| Inline-block | ✅ | `display: inline-block` |
| Flexbox | ✅ | **Recommended** - Full support |
| Positioned (relative) | ✅ | `position: relative` |
| Positioned (absolute) | ✅ | `position: absolute` |
| Positioned (fixed) | ✅ | `position: fixed` |
| Positioned (sticky) | ✅ | `position: sticky` |

#### ❌ NOT Supported
| Layout Mode | Support | Alternative |
|-------------|---------|-------------|
| Float | ❌ | Use Flexbox |
| Table layout | ❌ | Use Flexbox or CSS Grid (when available) |
| CSS Grid | ⏳ | Coming soon - use Flexbox for now |

### CSS Properties

#### Colors & Backgrounds
| Property | Support | Notes |
|----------|---------|-------|
| `color` | ✅ | All formats (hex, rgb, rgba, hsl, hsla, named) |
| `background-color` | ✅ | All color formats |
| `background-image` | ✅ | Including gradients |
| `background-size` | ✅ | `cover`, `contain`, dimensions |
| `background-position` | ✅ | Full support |
| `background-repeat` | ✅ | Full support |
| `linear-gradient()` | ✅ | Linear gradients |
| `radial-gradient()` | ✅ | Radial gradients |
| `opacity` | ✅ | Full support |

#### Borders & Shapes
| Property | Support | Notes |
|----------|---------|-------|
| `border` | ✅ | All border properties |
| `border-radius` | ✅ | Rounded corners |
| `border-color` | ✅ | Per-side colors |
| `border-width` | ✅ | Per-side widths |
| `border-style` | ✅ | Solid, dashed, dotted, etc. |
| `box-shadow` | ✅ | Multiple shadows supported |
| `text-shadow` | ✅ | Text shadows |
| `outline` | ✅ | Full support |

#### Transforms (Hardware Accelerated)
| Property | Support | Notes |
|----------|---------|-------|
| `transform: translate()` | ✅ | 2D and 3D |
| `transform: rotate()` | ✅ | 2D and 3D |
| `transform: scale()` | ✅ | 2D and 3D |
| `transform: skew()` | ✅ | 2D |
| `transform-origin` | ✅ | Full support |
| `perspective` | ✅ | 3D transforms |

#### Animations & Transitions
| Property | Support | Notes |
|----------|---------|-------|
| `transition` | ✅ | All properties |
| `transition-duration` | ✅ | Timing |
| `transition-timing-function` | ✅ | Easing functions |
| `transition-delay` | ✅ | Delays |
| `@keyframes` | ✅ | Animation definitions |
| `animation` | ✅ | All properties |
| `animation-duration` | ✅ | Timing |
| `animation-timing-function` | ✅ | Easing functions |
| `animation-delay` | ✅ | Delays |
| `animation-iteration-count` | ✅ | Repeat counts |
| `animation-direction` | ✅ | Forward, reverse, alternate |

#### Layout & Sizing
| Property | Support | Notes |
|----------|---------|-------|
| `width` / `height` | ✅ | All units |
| `min-width` / `min-height` | ✅ | Constraints |
| `max-width` / `max-height` | ✅ | Constraints |
| `margin` | ✅ | All sides |
| `padding` | ✅ | All sides |
| `box-sizing` | ✅ | `border-box`, `content-box` |
| `overflow` | ✅ | `visible`, `hidden`, `scroll`, `auto` |
| `display` | ⚠️ | Most values (see layout table) |

#### Flexbox Properties
| Property | Support | Notes |
|----------|---------|-------|
| `display: flex` | ✅ | Primary layout mode |
| `flex-direction` | ✅ | `row`, `column`, `row-reverse`, `column-reverse` |
| `justify-content` | ✅ | Main axis alignment |
| `align-items` | ✅ | Cross axis alignment |
| `align-content` | ✅ | Multi-line alignment |
| `flex-wrap` | ✅ | `wrap`, `nowrap`, `wrap-reverse` |
| `flex-grow` | ✅ | Grow factor |
| `flex-shrink` | ✅ | Shrink factor |
| `flex-basis` | ✅ | Base size |
| `gap` | ✅ | Spacing between items |
| `align-self` | ✅ | Individual item alignment |
| `order` | ✅ | Item ordering |

#### Positioning
| Property | Support | Notes |
|----------|---------|-------|
| `position` | ✅ | `static`, `relative`, `absolute`, `fixed`, `sticky` |
| `top` / `right` / `bottom` / `left` | ✅ | Positioning offsets |
| `z-index` | ✅ | Stacking order |

#### Text & Typography
| Property | Support | Notes |
|----------|---------|-------|
| `font-family` | ✅ | Web fonts and system fonts |
| `font-size` | ✅ | All units |
| `font-weight` | ✅ | Numeric and keywords |
| `font-style` | ✅ | `normal`, `italic`, `oblique` |
| `line-height` | ✅ | All units |
| `letter-spacing` | ✅ | Character spacing |
| `word-spacing` | ✅ | Word spacing |
| `text-align` | ✅ | All alignments |
| `text-decoration` | ✅ | Underline, overline, line-through |
| `text-transform` | ✅ | `uppercase`, `lowercase`, `capitalize` |
| `white-space` | ✅ | Text wrapping control |
| `text-overflow` | ✅ | `ellipsis` support |

#### Responsive Design
| Property | Support | Notes |
|----------|---------|-------|
| `@media` queries | ✅ | Full support |
| `vw` / `vh` | ✅ | Viewport units |
| `vmin` / `vmax` | ✅ | Viewport min/max |
| `dvh` / `lvh` / `svh` | ❌ | Advanced viewport units not supported |
| `rem` | ✅ | Root em units |
| `em` | ✅ | Em units |
| `%` | ✅ | Percentage units |

#### Advanced CSS
| Property | Support | Notes |
|----------|---------|-------|
| CSS Variables (`--custom`) | ✅ | Custom properties |
| `calc()` | ✅ | Mathematical calculations |
| `var()` | ✅ | Variable references |
| Pseudo-classes (`:hover`, `:active`, etc.) | ✅ | Interactive states |
| Pseudo-elements (`::before`, `::after`) | ✅ | Generated content |
| Filters (`blur`, `brightness`, etc.) | ✅ | Visual effects |
| `backdrop-filter` | ❌ | Not supported |
| `clip-path` | ✅ | Shape clipping |
| `mask` | ⚠️ | Partial support |

### CSS Frameworks

| Framework | Version | Support | Notes |
|-----------|---------|---------|-------|
| Tailwind CSS | v3.x | ✅ | Some utilities may not work if using unsupported features |
| Tailwind CSS | v4.x | ❌ | Planned for 2026 |
| Bootstrap | All | ✅ | Works with caveats (no float-based grid) |
| Material-UI | All | ✅ | Full support |
| Ant Design | All | ✅ | Full support |
| Chakra UI | All | ✅ | Full support |

## Popular Libraries

### State Management
| Library | Support | Notes |
|---------|---------|-------|
| Redux | ✅ | Full support |
| Zustand | ✅ | Full support |
| Jotai | ✅ | Full support |
| Recoil | ✅ | Full support |
| MobX | ✅ | Full support |

### Data Fetching & Streaming
| Library | Support | Notes |
|---------|---------|-------|
| React Query (TanStack Query) | ✅ | Full support |
| SWR | ✅ | Full support |
| Axios | ✅ | Full support |
| Apollo Client | ✅ | Works if using fetch transport |
| Vercel AI SDK | ✅ | SSE streaming via EventSource |
| OpenAI SDK (streaming) | ✅ | SSE streaming supported |

### CSS-in-JS
| Library | Support | Notes |
|---------|---------|-------|
| styled-components | ✅ | Full support |
| Emotion | ✅ | Full support |
| CSS Modules | ✅ | Full support |
| Sass/SCSS | ✅ | Full support |
| Styled-JSX | ✅ | Full support |

### UI Component Libraries
| Library | Support | Notes |
|---------|---------|-------|
| Material-UI (MUI) | ✅ | Full support |
| Ant Design | ✅ | Full support |
| Chakra UI | ✅ | Full support |
| Mantine | ✅ | Full support |
| Radix UI | ✅ | Full support |
| Headless UI | ✅ | Full support |

## Feature Detection Template

Use this template to check compatibility at runtime:

```javascript
const webfFeatures = {
  // Storage
  localStorage: typeof localStorage !== 'undefined',
  sessionStorage: typeof sessionStorage !== 'undefined',
  indexedDB: typeof indexedDB !== 'undefined', // Will be false

  // Graphics
  canvas2d: (() => {
    const canvas = document.createElement('canvas');
    return !!(canvas.getContext && canvas.getContext('2d'));
  })(),
  webgl: (() => {
    const canvas = document.createElement('canvas');
    return !!(canvas.getContext && canvas.getContext('webgl')); // Will be false
  })(),

  // Networking
  fetch: typeof fetch !== 'undefined',
  websocket: typeof WebSocket !== 'undefined',
  eventSource: typeof EventSource !== 'undefined',

  // Workers
  webWorkers: typeof Worker !== 'undefined', // Will be false

  // Observers
  mutationObserver: typeof MutationObserver !== 'undefined',
  intersectionObserver: typeof IntersectionObserver !== 'undefined', // Will be false

  // WebF-specific
  isWebF: typeof WebF !== 'undefined',
  webfEvents: typeof WebF !== 'undefined' && 'onscreen' in document.createElement('div')
};

console.log('WebF Features:', webfFeatures);
```

## Quick Decision Matrix

### "Which storage API should I use?"
| Use Case | Solution |
|----------|----------|
| Simple key-value (< 5MB) | `localStorage` ✅ |
| Session-only data | `sessionStorage` ✅ |
| Complex queries, large datasets | Native plugin (sqflite, hive) ✅ |
| IndexedDB required | ❌ Not available - use native alternative |

### "Which layout approach should I use?"
| Use Case | Solution |
|----------|----------|
| Modern responsive layout | Flexbox ✅ |
| Complex grid layouts | Wait for CSS Grid ⏳ or use Flexbox |
| Legacy float layout | ❌ Convert to Flexbox |
| Table-based layout | ❌ Convert to Flexbox |

### "Which graphics API should I use?"
| Use Case | Solution |
|----------|----------|
| 2D graphics, charts | Canvas 2D ✅ |
| Icons, illustrations | SVG ✅ |
| 3D graphics, WebGL | ❌ Not available - consider Flutter rendering |

### "Which framework should I use?"
| Framework | Status |
|-----------|--------|
| React (16-19) | ✅ Recommended |
| Vue (2-3) | ✅ Recommended |
| Svelte | ✅ Recommended |
| Preact | ✅ Works |
| Solid | ✅ Works |
| Angular | ⚠️ Not tested, may work |

## Resources

- **Full Documentation**: https://openwebf.com/en/docs
- **API Reference**: https://openwebf.com/en/docs/api
- **GitHub Discussions**: Ask compatibility questions
- **Native Plugins**: See `alternatives.md` in this skill