# TailwindCSS Support Plan for WebF

Target: **Tailwind CSS v3.4.x** (core preflight + core utilities + core variants) running **directly in WebF** (no extra PostCSS “polyfills” required).

## Sources Used
- Tailwind v3.4.18 installed in this repo: `integration_tests/node_modules/tailwindcss/`
  - Core utility surface: `require('tailwindcss/lib/corePlugins').corePlugins`
  - Variant surface: `require('tailwindcss/lib/corePlugins').variantPlugins`
  - Preflight CSS source: `integration_tests/node_modules/tailwindcss/src/css/preflight.css`
- WebF CSS engine (Blink/bridge, C++): `bridge/core/css/` (used by `enableBlink: true` in integration tests)
- WebF CSS engine (Dart): `webf/lib/src/css/` (parser, selector evaluator, media query evaluation, RenderStyle mixins)

## Legend
- ✅ **Supported**: Works in WebF without build-time transforms.
- ⚠️ **Partial**: Works for some cases; known gaps vs Tailwind output.
- ❌ **Missing**: Not supported; Tailwind output will be dropped/misparsed or have no effect.
- 🧪 **Verify**: Likely supported, but needs targeted tests (Tailwind-style fixtures).

---

## 1) Tailwind → WebF: CSS Language Features (Blockers First)

| Capability | Tailwind uses it for | WebF status | Evidence (current) | Needed work |
|---|---|---:|---|---|
| `@layer` (cascade layers) | All Tailwind builds (`@tailwind base/components/utilities` expand into `@layer ... { ... }`) | ✅ | Implemented in Blink/bridge CSS pipeline; see `docs/CSS_CASCADE_LAYERS_PLAN.md` and integration specs under `integration_tests/specs/css/css-cascade/`. | Follow-ups (not Tailwind-critical): layered `@import ... layer(...)`, `revert-layer`. |
| `@supports` | `supports-*` variants | ❌ | `webf/lib/src/css/parser/parser.dart` returns `null` for `DIRECTIVE_SUPPORTS` | Implement `@supports` parsing + evaluation (at least allow/deny blocks, and “declare support” checks used by Tailwind). |
| Media queries (MQ) | Responsive (`sm/md/...`), `dark`, `motion-*`, `orientation-*`, `print`, `forced-colors`, `prefers-contrast` | ⚠️ | `webf/lib/src/css/css_rule.dart` only evaluates `min/max-width`, `min/max-aspect-ratio`, `prefers-color-scheme`; rejects `print` type | Expand media query parsing/evaluation for Tailwind variants: `prefers-reduced-motion`, `orientation`, `forced-colors`, `prefers-contrast`, `hover`, `pointer`, `print`. |
| Selector pseudo `:where(<selector-list>)` | Preflight selectors (`abbr:where([title])`, `[hidden]:where(:not(...))`), direction variants (`rtl:`/`ltr:`) | ⚠️ | Blink/bridge (C++) supports `:where()` parsing/matching and 0-specificity (`bridge/core/css/css_selector.cc` handles `CSSSelector::kPseudoWhere`), but the legacy Dart selector engine still lacks selector-list parsing/matching (`webf/lib/src/css/parser/parser.dart`, `webf/lib/src/css/query_selector.dart`). | Implement Selectors L4 `:where()`/`:is()` selector-list parsing + matching + specificity in the Dart engine; keep coverage via `integration_tests/specs/css/css-selectors/is-where-*.ts`. |
| Selector pseudo `:has(<relative-selector-list>)` | `has-*`, `group-has-*`, `peer-has-*` variants | ⚠️ | Blink/bridge parses `:has()` and has selector-checking/invalidation hooks, but traversal/caching are stubbed (`bridge/core/css/check_pseudo_has_*`); Dart selector engine still lacks `:has()`. | Implement full :has traversal/caching/invalidation in C++; add Dart parsing/matching; cover with integration tests. |
| Pseudo-classes (state) | `hover:`, `focus:`, `focus-visible:`, `focus-within:`, `active:`, `enabled:`, `disabled:` | ❌ | `webf/lib/src/css/query_selector.dart` only implements a small set (e.g., `:root`, `:empty`, `:first-child`, `:nth-*`); does not implement hover/focus/active/etc | Add element state model + selector matching for Tailwind pseudo-class variants; hook to Flutter pointer/focus events. |
| Pseudo-classes (forms) | `checked:`, `indeterminate:`, `placeholder-shown:`, `required:`, `valid:`/`invalid:`… | ❌ | Not implemented in selector evaluator | Implement form state pseudos based on element type/attributes/value validity model (as supported by WebF’s form elements). |
| Pseudo-elements used by Tailwind variants | `::before/::after`, `::placeholder`, `::selection`, `::marker`, `::file-selector-button`, `::backdrop`, `::first-letter/line` | ⚠️ | WebF has real `::before/::after` elements and first-line/first-letter plumbing, but selector matcher treats only a “legacy” subset as matchable; others return false | Extend pseudo-element matching + rendering support where meaningful; at minimum `::placeholder` for preflight + utilities. |
| CSS Custom Properties + `var()` (including empty values) | Most complex utilities (transform/ring/shadow/filter/gradients) | ✅ | `RenderStyle.setProperty` explicitly preserves empty custom properties (Tailwind gradient fix) in `webf/lib/src/css/render_style.dart` | Add targeted tests for `var()` expansion in more value syntaxes (box-shadow/filter). |

---

## 2) Tailwind Core Variants → WebF Support

Tailwind v3.4.18 core variants are exposed by `variantPlugins` (15 groups).

| Tailwind variant group | What it generates | WebF status | Notes |
|---|---|---:|---|
| `screenVariants` | `@media (min-width: ...)` wrappers | ✅ | Works with existing `min-width` evaluation. |
| `darkVariants` | `@media (prefers-color-scheme: dark)` (default) or `.dark ...` (class mode) | ⚠️ | `prefers-color-scheme` supported; ensure “class” mode is verified in WebF. |
| `pseudoElementVariants` | `::before/after/first-line/first-letter/placeholder/selection/marker/file/backdrop` | ⚠️ | `before/after` exist; others need matching + element integration. |
| `pseudoClassVariants` | `:hover/:focus/...` and structural pseudos | ❌ | Structural subset exists; interactive/forms pseudos missing. |
| `directionVariants` | `&:where([dir=\"rtl\"], [dir=\"rtl\"] *)` / `ltr:` | ❌ | Blocked on `:where()` selector-list support. |
| `reducedMotionVariants` | `@media (prefers-reduced-motion: ...)` | ❌ | Media feature not evaluated today. |
| `orientationVariants` | `@media (orientation: portrait/landscape)` | ❌ | Media feature not evaluated today. |
| `printVariant` | `@media print` | ❌ | WebF currently rejects non-`screen` media types. |
| `supportsVariants` | `@supports (...)` | ❌ | `@supports` not parsed/evaluated today. |
| `hasVariants` | `:has(...)` | ⚠️ | Blink/bridge has parser + checker wiring, but :has traversal/caching are stubbed; Dart selector engine lacks `:has()`. |
| `ariaVariants` | Attribute selectors like `&[aria-checked=\"true\"]` | ✅ | Attribute selectors are supported; needs Tailwind fixture tests. |
| `dataVariants` | Attribute selectors like `&[data-state=\"open\"]` | ✅ | Attribute selectors are supported; needs Tailwind fixture tests. |
| `childVariant` | `& > *` | ✅ | Combinators supported. |
| `prefersContrastVariants` | `@media (prefers-contrast: ...)` | ❌ | Media feature not evaluated today. |
| `forcedColorsVariants` | `@media (forced-colors: active)` | ❌ | Media feature not evaluated today. |

---

## 3) Tailwind Core Utilities (corePlugins) → WebF Support

Tailwind v3.4.18 core utilities are exposed by `corePlugins` (179 keys). Below is a **capability-level** view focused on whether WebF can consume Tailwind’s emitted CSS.

### 3.1 High-level summary (what blocks “Tailwind just works”)

**P0 blockers (must fix first)**
- Selector parsing/matching: `:where(<selector-list>)` (Tailwind preflight + direction variants).
- `:has()` correctness + performance + invalidation strategy (C++ has stubbed traversal; Dart missing).
- Selector matching: interactive pseudo-classes (hover/focus/active/disabled/checked/…).
- https://github.com/openwebf/webf/issues/659
- Media query evaluation: `orientation`, `prefers-contrast`.

**P1 (big utility gaps, common in real apps)**
- `cursor`, `pointer-events`, `user-select`, `touch-action`, `resize`
- `outline-*` utilities
- `scroll-snap-*`, `overscroll-behavior`, `scroll-behavior`, `scroll-margin`, `scroll-padding`
- `box-sizing: content-box` (WebF currently supports only `border-box`)
- `-webkit-line-clamp`/`-webkit-box` based line clamp (Tailwind emits vendor properties)

**P2 (less common but in Tailwind core)**
- `appearance`, `accent-color`, `hyphens`, `text-wrap`, `will-change`, `contain`, `forced-color-adjust`
- Blend modes: `mix-blend-mode`, `background-blend-mode`
- Table/list/break utilities (depending on WebF’s HTML feature goals)

### 3.2 Capability matrix (grouped)

| Area | Tailwind core plugin keys (examples) | WebF status | Notes / gaps |
|---|---|---:|---|
| Layout basics | `display`, `position`, `inset`, `zIndex`, `visibility` | ⚠️ | `display` in WebF is limited (no `table`, `flow-root`, `contents`, etc). |
| Box model | `margin`, `padding`, `size`, `width/height`, `min/max-*`, `aspectRatio` | ⚠️ | WebF supports only `box-sizing: border-box` (`boxSizing` is partial). |
| Flexbox | `flex*`, `order`, `justify*`, `align*`, `place*`, `gap` | ✅ | Implemented via `webf/lib/src/css/flexbox.dart`, `gap.dart`. |
| Grid | `gridTemplate*`, `gridAuto*`, `gridRow/Column*`, `place*`, `gap` | ✅ | Implemented via `webf/lib/src/css/grid.dart` + `webf/lib/src/rendering/grid.dart`. |
| Typography | `font*`, `textColor`, `textAlign`, `lineHeight`, `letterSpacing`, `whitespace`, `wordBreak`, `textOverflow` | ⚠️ | Missing `fontVariantNumeric`, `textUnderlineOffset`, `textDecorationThickness`, `hyphens`, `textWrap`. |
| Backgrounds & gradients | `backgroundColor/Image/Position/Size/Repeat/Clip/Origin`, `gradientColorStops` | ✅ | Tailwind-style gradient vars already have regressions covered (see `webf/CHANGELOG.md` tailwind gradient fix). |
| Borders & radius | `borderWidth/Style/Color/Opacity`, `borderRadius` | ✅ | Supported by `border.dart`, `border_radius.dart`. |
| Shadows & rings | `boxShadow`, `ring*`, `boxShadowColor` | 🧪 | Depends on `var()` support inside `box-shadow` lists and multiple shadows. |
| Filters | `filter`, `blur`, `brightness`, `contrast`, `dropShadow`, `grayscale`, `hueRotate`, `invert`, `saturate`, `sepia` | ✅ | WebF supports these filter functions in `webf/lib/src/css/filter.dart`. |
| Backdrop filters | `backdropFilter` + `backdrop*` | ❌ | No Dart-side `backdrop-filter` plumbing found. |
| Interactivity | `cursor`, `pointerEvents`, `userSelect`, `touchAction`, `resize`, `scroll*`, `overscrollBehavior` | ❌ | Missing as CSS properties; needs event + scroll integration. |
| Misc | `float`, `clear`, `isolation`, `willChange`, `contain`, `forcedColorAdjust`, `appearance`, `accentColor` | ❌ | `float` explicitly TODO in `webf/lib/src/css/display.dart`. |

---

## 4) Implementation Backlog (Proposed)

### P0 — Make Tailwind CSS parse + match correctly
1. ✅ **`@layer` support (parser + cascade order)**: implemented as Milestone M1; see `docs/CSS_CASCADE_LAYERS_PLAN.md`.
2. ✅ **Selectors Level 4 essentials**: implement parsing + matching for `:where(<selector-list>)` and `:is(<selector-list>)` (Tailwind emits `:where` today; `:is` appears in some variants/plugins).
3. **State pseudo-classes**: implement `:hover/:focus/:focus-visible/:focus-within/:active/:enabled/:disabled` and wire element state updates from Flutter events.
4. **Media query evaluation coverage**: add Tailwind-required media features: `prefers-reduced-motion`, `orientation`, `forced-colors`, `prefers-contrast`, plus **media type `print`** handling (likely “always false” in WebF unless printing is supported).
   - Add WPT-based integration tests for `orientation`, `forced-colors`, `prefers-contrast`, `prefers-reduced-motion`.
5. **Regression tests**: add a minimal “Tailwind preflight can load” integration test and a few utility/variant fixtures.

### P0 Dev Plan — Interactive pseudo-classes (Dart engine)
Scope: implement selector matching + invalidation for Tailwind’s interactive/state variants in the Dart CSS engine (`webf/lib/src/css/query_selector.dart`), including `:hover`, `:active`, `:focus`, `:focus-visible`, `:focus-within`, `:enabled`, `:disabled`, `:checked` (plus `:indeterminate`, `:required`, `:optional`, `:valid/:invalid`, `:placeholder-shown` if feasible).

1. **State model on Element (Dart)**
   - Add a lightweight pseudo-state bitset (hover/active/focus/focus-visible/checked/disabled/etc).
   - Provide helpers to set/clear states and mark style dirty on state change.
   - For `:focus-within`, propagate a derived flag to ancestors when focus changes.

2. **Event wiring (Flutter → DOM)**
   - Hook pointer enter/leave to `:hover` (mouseenter/leave or pointermove/exit).
   - Hook pointer down/up to `:active` (pressed state while pointer is down).
   - Hook focus/blur to `:focus`; track last input modality to derive `:focus-visible`.
   - Ensure disabled/checked/value changes update state (reuse form element setters).

3. **Selector evaluator updates**
   - Extend `visitPseudoClassSelector()` in `webf/lib/src/css/query_selector.dart` to query the state model.
   - Implement `:focus-within` by checking self or descendants with focus state.
   - Keep current form-related logic (`:enabled/:disabled/:checked/:valid/:invalid`) consistent with the state model.

4. **Style invalidation**
   - On state changes, mark the element dirty; for `:focus-within`, mark ancestors dirty.
   - When `:has()` exists in the ruleset, conservatively mark the document root dirty to keep relational selectors correct.

5. **Tests (integration + unit)**
   - Add integration tests under `integration_tests/specs/css/css-selectors/` for hover/active/focus/focus-visible/focus-within.
   - Include mixed cases with `:has()` and pseudo-class variants to validate invalidation.
   - Add minimal unit tests for state transitions if feasible in Dart.

6. **Performance/flags**
   - Consider a RuleSet flag to detect presence of interactive pseudos to avoid unnecessary full-root invalidation.
   - Keep default behavior conservative first; optimize after correctness is verified.

### P1 — Close common utility gaps
1. **Vendor line clamp**: map Tailwind’s `-webkit-line-clamp`, `-webkit-box-orient`, `display:-webkit-box` onto WebF’s existing `lineClamp` model (or implement full vendor behavior).
2. **`cursor` / `pointer-events` / `user-select` / `touch-action` / `resize`**: implement in RenderStyle + event/gesture system.
3. **`outline-*`**: implement outline painting (or a compatible approximation) + `outline-offset`.
4. **Scroll utilities**: `scroll-behavior`, `scroll-snap-*`, `overscroll-behavior`, `scroll-margin`, `scroll-padding`.
5. **`box-sizing: content-box`**: extend layout sizing math beyond the current border-box-only constraint.

### P2 — Complete remaining Tailwind core surface
- `appearance`, `accent-color`, `hyphens`, `text-wrap`, `will-change`, `contain`, `forced-color-adjust`
- Blend modes (`mix-blend-mode`, `background-blend-mode`)
- `float/clear` if WebF wants full CSS2 layout parity
- Table/list/break utilities depending on HTML feature roadmap

---

## 5) Development Plan & Time Estimate

Assumptions:
- Target is **Tailwind v3.4.x core** (preflight + core utilities + core variants listed above) with **runtime support in WebF** (no CSS transforms).
- Estimates include unit/integration tests and basic docs, but exclude “unknown unknowns” in platform behavior.
- “Print” support is treated as **parseable**; rules can evaluate to false if printing isn’t a WebF feature.

### Milestones

| Milestone | Scope | Deliverable | Est. effort (person-days) |
|---|---|---|---:|
| M0 | Acceptance + fixtures | Integration tests that load Tailwind-built CSS + a small Tailwind showcase page as a regression target | 3–5 |
| M1 | CSS cascade layers | Parse `@layer` (block + statement), preserve layer ordering, apply cascade correctly | ✅ Completed (est. 8–12) |
| M2 | Selector L4 essentials | Parse + match `:where(<selector-list>)` + `:is(<selector-list>)`; implement correct specificity behavior | 6–10 |
| M3 | Media variants | Expand MQ evaluation to cover Tailwind variants: `prefers-reduced-motion`, `orientation`, `forced-colors`, `prefers-contrast`, `hover`, `pointer`, and `@media print` parsing | 6–10 |
| M4 | State variants | Implement `hover/focus/focus-visible/focus-within/active/enabled/disabled` (plus key form pseudos: `checked/placeholder-shown/required/invalid`) end-to-end (events → state → selector matching) | 12–20 |
| M5 | Utility gaps (most apps) | `cursor`, `pointer-events`, `user-select`, `touch-action`, `resize`, `outline-*`, `-webkit-line-clamp` mapping, basic scroll utilities | 25–45 |
| M6 | “Full core” hard parts | `:has()` variants, `scroll-snap-*`, `box-sizing: content-box`, `backdrop-filter`, blend modes, remaining misc properties | 60–110 |

### Total estimate (depending on definition of “full”)
- **Tailwind “baseline” (M0–M5):** ~60–102 person-days (~3–5 months for 1 engineer; ~6–10 weeks for 2 engineers).
- **Tailwind “full core + variants” (M0–M6):** ~120–212 person-days (~6–10 months for 1 engineer; ~3–5 months for 2 engineers).

### Main risks / schedule drivers

- `box-sizing: content-box` (WebF layout code currently assumes border-box semantics in multiple places).
- Scroll snap and `touch-action` (requires deep integration with Flutter gesture/scroll systems).

---

## Appendix A — Tailwind v3.4.18 corePlugins list (179 keys)

Extracted from `require('tailwindcss/lib/corePlugins').corePlugins` in this repo.

```
preflight
container
accessibility
pointerEvents
visibility
position
inset
isolation
zIndex
order
gridColumn
gridColumnStart
gridColumnEnd
gridRow
gridRowStart
gridRowEnd
float
clear
margin
boxSizing
lineClamp
display
aspectRatio
size
height
maxHeight
minHeight
width
minWidth
maxWidth
flex
flexShrink
flexGrow
flexBasis
tableLayout
captionSide
borderCollapse
borderSpacing
transformOrigin
translate
rotate
skew
scale
transform
animation
cursor
touchAction
userSelect
resize
scrollSnapType
scrollSnapAlign
scrollSnapStop
scrollMargin
scrollPadding
listStylePosition
listStyleType
listStyleImage
appearance
columns
breakBefore
breakInside
breakAfter
gridAutoColumns
gridAutoFlow
gridAutoRows
gridTemplateColumns
gridTemplateRows
flexDirection
flexWrap
placeContent
placeItems
alignContent
alignItems
justifyContent
justifyItems
gap
space
divideWidth
divideStyle
divideColor
divideOpacity
placeSelf
alignSelf
justifySelf
overflow
overscrollBehavior
scrollBehavior
textOverflow
hyphens
whitespace
textWrap
wordBreak
borderRadius
borderWidth
borderStyle
borderColor
borderOpacity
backgroundColor
backgroundOpacity
backgroundImage
gradientColorStops
boxDecorationBreak
backgroundSize
backgroundAttachment
backgroundClip
backgroundPosition
backgroundRepeat
backgroundOrigin
fill
stroke
strokeWidth
objectFit
objectPosition
padding
textAlign
textIndent
verticalAlign
fontFamily
fontSize
fontWeight
textTransform
fontStyle
fontVariantNumeric
lineHeight
letterSpacing
textColor
textOpacity
textDecoration
textDecorationColor
textDecorationStyle
textDecorationThickness
textUnderlineOffset
fontSmoothing
placeholderColor
placeholderOpacity
caretColor
accentColor
opacity
backgroundBlendMode
mixBlendMode
boxShadow
boxShadowColor
outlineStyle
outlineWidth
outlineOffset
outlineColor
ringWidth
ringColor
ringOpacity
ringOffsetWidth
ringOffsetColor
blur
brightness
contrast
dropShadow
grayscale
hueRotate
invert
saturate
sepia
filter
backdropBlur
backdropBrightness
backdropContrast
backdropGrayscale
backdropHueRotate
backdropInvert
backdropOpacity
backdropSaturate
backdropSepia
backdropFilter
transitionProperty
transitionDelay
transitionDuration
transitionTimingFunction
willChange
contain
content
forcedColorAdjust
```

## Appendix B — Tailwind v3.4.18 variantPlugins list (15 groups)

Extracted from `require('tailwindcss/lib/corePlugins').variantPlugins` in this repo.

```
childVariant
pseudoElementVariants
pseudoClassVariants
directionVariants
reducedMotionVariants
darkVariants
printVariant
screenVariants
supportsVariants
hasVariants
ariaVariants
dataVariants
orientationVariants
prefersContrastVariants
forcedColorsVariants
```

## Appendix C — WebF status per Tailwind corePlugin (capability-level)

Status here is about whether WebF supports the **underlying CSS behavior** that the utility emits (independent of Tailwind’s packaging into `@layer`, which is covered in section 1).

| corePlugin | WebF | Notes |
|---|---:|---|
| `preflight` | ❌ | Blocked by `:where()` + missing cursor/outline/appearance/etc from preflight. |
| `container` | ✅ | Depends on `@media (min-width: ...)` + `max-width`. |
| `accessibility` | ✅ | Uses common box/positioning properties (sr-only, etc). |
| `pointerEvents` | ❌ | CSS `pointer-events` not implemented in Dart RenderStyle. |
| `visibility` | ✅ | Implemented via `webf/lib/src/css/visibility.dart`. |
| `position` | ✅ | Implemented via `webf/lib/src/css/position.dart`. |
| `inset` | ✅ | Implemented via `top/right/bottom/left` in `webf/lib/src/css/position.dart`. |
| `isolation` | ❌ | CSS `isolation` not implemented. |
| `zIndex` | ✅ | Implemented via `zIndex` in `webf/lib/src/css/position.dart`. |
| `order` | ✅ | Implemented via `webf/lib/src/css/order.dart`. |
| `gridColumn` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `gridColumnStart` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `gridColumnEnd` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `gridRow` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `gridRowStart` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `gridRowEnd` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `float` | ❌ | Explicit TODO in `webf/lib/src/css/display.dart`. |
| `clear` | ❌ | Depends on float layout (not supported). |
| `margin` | ✅ | Implemented via `webf/lib/src/css/margin.dart`. |
| `boxSizing` | ⚠️ | WebF currently supports **border-box only** (`webf/lib/src/rendering/box_model.dart`). |
| `lineClamp` | ⚠️ | WebF has `lineClamp`, but Tailwind emits `-webkit-line-clamp`/`-webkit-box` pattern. |
| `display` | ⚠️ | Supports `block/inline/inline-block/flex/grid/none`; missing many Tailwind values (`table`, `contents`, etc). |
| `aspectRatio` | ✅ | Implemented via `webf/lib/src/css/sizing.dart`. |
| `size` | ✅ | Emits `width`+`height`; both supported. |
| `height` | ✅ | Implemented via `webf/lib/src/css/sizing.dart`. |
| `maxHeight` | ✅ | Implemented via `webf/lib/src/css/sizing.dart`. |
| `minHeight` | ✅ | Implemented via `webf/lib/src/css/sizing.dart`. |
| `width` | ✅ | Implemented via `webf/lib/src/css/sizing.dart`. |
| `minWidth` | ✅ | Implemented via `webf/lib/src/css/sizing.dart`. |
| `maxWidth` | ✅ | Implemented via `webf/lib/src/css/sizing.dart`. |
| `flex` | ✅ | Implemented via `webf/lib/src/css/flexbox.dart`. |
| `flexShrink` | ✅ | Implemented via `webf/lib/src/css/flexbox.dart`. |
| `flexGrow` | ✅ | Implemented via `webf/lib/src/css/flexbox.dart`. |
| `flexBasis` | ✅ | Implemented via `webf/lib/src/css/flexbox.dart`. |
| `tableLayout` | ❌ | No CSS table layout property support in Dart CSS engine. |
| `captionSide` | ❌ | Not implemented. |
| `borderCollapse` | ❌ | Not implemented. |
| `borderSpacing` | ❌ | Not implemented. |
| `transformOrigin` | ✅ | Implemented via `webf/lib/src/css/transform.dart`. |
| `translate` | ✅ | Implemented via `webf/lib/src/css/transform.dart`. |
| `rotate` | ✅ | Implemented via `webf/lib/src/css/transform.dart`. |
| `skew` | ✅ | Implemented via `webf/lib/src/css/transform.dart`. |
| `scale` | ✅ | Implemented via `webf/lib/src/css/transform.dart`. |
| `transform` | ✅ | Implemented via `webf/lib/src/css/transform.dart`. |
| `animation` | ✅ | Implemented via `webf/lib/src/css/css_animation.dart` + `webf/lib/src/css/animation.dart`. |
| `cursor` | ❌ | CSS `cursor` not implemented. |
| `touchAction` | ❌ | CSS `touch-action` not implemented. |
| `userSelect` | ❌ | CSS `user-select` not implemented. |
| `resize` | ❌ | CSS `resize` not implemented. |
| `scrollSnapType` | ❌ | CSS scroll snap not implemented. |
| `scrollSnapAlign` | ❌ | CSS scroll snap not implemented. |
| `scrollSnapStop` | ❌ | CSS scroll snap not implemented. |
| `scrollMargin` | ❌ | CSS `scroll-margin-*` not implemented. |
| `scrollPadding` | ❌ | CSS `scroll-padding-*` not implemented. |
| `listStylePosition` | ❌ | CSS list-style properties not implemented. |
| `listStyleType` | ❌ | CSS list-style properties not implemented. |
| `listStyleImage` | ❌ | CSS list-style properties not implemented. |
| `appearance` | ❌ | CSS `appearance` not implemented. |
| `columns` | ❌ | CSS multi-column (`columns`) not implemented. |
| `breakBefore` | ❌ | CSS fragmentation (`break-*`) not implemented. |
| `breakInside` | ❌ | CSS fragmentation (`break-*`) not implemented. |
| `breakAfter` | ❌ | CSS fragmentation (`break-*`) not implemented. |
| `gridAutoColumns` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `gridAutoFlow` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `gridAutoRows` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `gridTemplateColumns` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `gridTemplateRows` | ✅ | Implemented via `webf/lib/src/css/grid.dart`. |
| `flexDirection` | ✅ | Implemented via `webf/lib/src/css/flexbox.dart`. |
| `flexWrap` | ✅ | Implemented via `webf/lib/src/css/flexbox.dart`. |
| `placeContent` | ✅ | Implemented via box-alignment in flex/grid mixins. |
| `placeItems` | ✅ | Implemented via box-alignment in flex/grid mixins. |
| `alignContent` | ✅ | Implemented via box-alignment in flex/grid mixins. |
| `alignItems` | ✅ | Implemented via box-alignment in flex/grid mixins. |
| `justifyContent` | ✅ | Implemented via box-alignment in flex/grid mixins. |
| `justifyItems` | ✅ | Implemented via box-alignment in flex/grid mixins. |
| `gap` | ✅ | Implemented via `webf/lib/src/css/gap.dart`. |
| `space` | 🧪 | Requires `calc()` + `var()` interplay (Tailwind uses `--tw-space-*-reverse`). |
| `divideWidth` | 🧪 | Depends on sibling selectors + border parsing; needs Tailwind fixture tests. |
| `divideStyle` | 🧪 | Depends on sibling selectors + border parsing. |
| `divideColor` | 🧪 | Depends on color parsing + CSS variables. |
| `divideOpacity` | 🧪 | Tailwind uses opacity vars in color functional notation. |
| `placeSelf` | ✅ | Implemented via box-alignment in flex/grid mixins. |
| `alignSelf` | ✅ | Implemented via box-alignment in flex/grid mixins. |
| `justifySelf` | ✅ | Implemented via box-alignment in flex/grid mixins. |
| `overflow` | ✅ | Implemented via `webf/lib/src/css/overflow.dart`. |
| `overscrollBehavior` | ❌ | Not implemented. |
| `scrollBehavior` | ❌ | Not implemented. |
| `textOverflow` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `hyphens` | ❌ | Not implemented. |
| `whitespace` | ✅ | Implemented via `whiteSpace` + `whitespace_processor.dart`. |
| `textWrap` | ❌ | Not implemented. |
| `wordBreak` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `borderRadius` | ✅ | Implemented via `webf/lib/src/css/border_radius.dart`. |
| `borderWidth` | ✅ | Implemented via `webf/lib/src/css/border.dart`. |
| `borderStyle` | ✅ | Implemented via `webf/lib/src/css/border.dart`. |
| `borderColor` | ✅ | Implemented via `webf/lib/src/css/border.dart` + `CSSColor`. |
| `borderOpacity` | 🧪 | Tailwind uses opacity vars; relies on color parser handling `rgb(... / var(...))`. |
| `backgroundColor` | ✅ | Implemented via `webf/lib/src/css/background.dart`. |
| `backgroundOpacity` | 🧪 | Tailwind uses opacity vars in color functional notation. |
| `backgroundImage` | ✅ | Implemented via `webf/lib/src/css/background.dart` + `gradient.dart`. |
| `gradientColorStops` | ✅ | Implemented via `webf/lib/src/css/gradient.dart`. |
| `boxDecorationBreak` | ❌ | Not implemented. |
| `backgroundSize` | ✅ | Implemented via `webf/lib/src/css/background.dart`. |
| `backgroundAttachment` | 🧪 | Parsed; needs verification of runtime effect. |
| `backgroundClip` | ✅ | Implemented via `webf/lib/src/css/background.dart`. |
| `backgroundPosition` | ✅ | Implemented via `webf/lib/src/css/background.dart`. |
| `backgroundRepeat` | ✅ | Implemented via `webf/lib/src/css/background.dart`. |
| `backgroundOrigin` | ✅ | Implemented via `webf/lib/src/css/background.dart`. |
| `fill` | ✅ | Supported via `CSSPaint.parsePaint` (see `render_style.dart`). |
| `stroke` | ✅ | Supported via `CSSPaint.parsePaint` (see `render_style.dart`). |
| `strokeWidth` | ✅ | Supported as length (see `STROKE_WIDTH` handling in `render_style.dart`). |
| `objectFit` | ✅ | Implemented via `webf/lib/src/css/object_fit.dart`. |
| `objectPosition` | ✅ | Implemented via `webf/lib/src/css/object_position.dart`. |
| `padding` | ✅ | Implemented via `webf/lib/src/css/padding.dart`. |
| `textAlign` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `textIndent` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `verticalAlign` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `fontFamily` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `fontSize` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `fontWeight` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `textTransform` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `fontStyle` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `fontVariantNumeric` | ❌ | Not implemented. |
| `lineHeight` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `letterSpacing` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `textColor` | ✅ | Implemented via `CSSColor.resolveColor`. |
| `textOpacity` | 🧪 | Tailwind uses opacity vars in color functional notation. |
| `textDecoration` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `textDecorationColor` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `textDecorationStyle` | ✅ | Implemented in `webf/lib/src/css/text.dart`. |
| `textDecorationThickness` | ❌ | Not implemented. |
| `textUnderlineOffset` | ❌ | Not implemented. |
| `fontSmoothing` | ❌ | Not implemented. |
| `placeholderColor` | ❌ | Requires `::placeholder` matching + input placeholder styling support. |
| `placeholderOpacity` | ❌ | Requires `::placeholder` matching + input placeholder styling support. |
| `caretColor` | ✅ | Implemented via `caretColor` in `render_style.dart`. |
| `accentColor` | ❌ | Not implemented. |
| `opacity` | ✅ | Implemented via `webf/lib/src/css/opacity.dart`. |
| `backgroundBlendMode` | ❌ | Not implemented (BoxDecoration supports blend mode but CSS property isn’t wired). |
| `mixBlendMode` | ❌ | Not implemented. |
| `boxShadow` | ✅ | Implemented via `webf/lib/src/css/box_shadow.dart`. |
| `boxShadowColor` | 🧪 | Tailwind uses `--tw-shadow-color`; depends on var expansion in box-shadow. |
| `outlineStyle` | ❌ | Not implemented. |
| `outlineWidth` | ❌ | Not implemented. |
| `outlineOffset` | ❌ | Not implemented. |
| `outlineColor` | ❌ | Not implemented. |
| `ringWidth` | 🧪 | Tailwind rings are `box-shadow` + vars; needs fixtures to confirm var-in-box-shadow works. |
| `ringColor` | 🧪 | Same as `ringWidth`. |
| `ringOpacity` | 🧪 | Same as `ringWidth`. |
| `ringOffsetWidth` | 🧪 | Same as `ringWidth` (uses `calc()` + vars). |
| `ringOffsetColor` | 🧪 | Same as `ringWidth`. |
| `blur` | ✅ | Supported via `filter` implementation (`webf/lib/src/css/filter.dart`). |
| `brightness` | ✅ | Supported via `filter` implementation (`webf/lib/src/css/filter.dart`). |
| `contrast` | ✅ | Supported via `filter` implementation (`webf/lib/src/css/filter.dart`). |
| `dropShadow` | ✅ | Supported via `filter` implementation (`webf/lib/src/css/filter.dart`). |
| `grayscale` | ✅ | Supported via `filter` implementation (`webf/lib/src/css/filter.dart`). |
| `hueRotate` | ✅ | Supported via `filter` implementation (`webf/lib/src/css/filter.dart`). |
| `invert` | ✅ | Supported via `filter` implementation (`webf/lib/src/css/filter.dart`). |
| `saturate` | ✅ | Supported via `filter` implementation (`webf/lib/src/css/filter.dart`). |
| `sepia` | ✅ | Supported via `filter` implementation (`webf/lib/src/css/filter.dart`). |
| `filter` | ✅ | Supported via `webf/lib/src/css/filter.dart`. |
| `backdropBlur` | ❌ | `backdrop-filter` not implemented. |
| `backdropBrightness` | ❌ | `backdrop-filter` not implemented. |
| `backdropContrast` | ❌ | `backdrop-filter` not implemented. |
| `backdropGrayscale` | ❌ | `backdrop-filter` not implemented. |
| `backdropHueRotate` | ❌ | `backdrop-filter` not implemented. |
| `backdropInvert` | ❌ | `backdrop-filter` not implemented. |
| `backdropOpacity` | ❌ | `backdrop-filter` not implemented. |
| `backdropSaturate` | ❌ | `backdrop-filter` not implemented. |
| `backdropSepia` | ❌ | `backdrop-filter` not implemented. |
| `backdropFilter` | ❌ | `backdrop-filter` not implemented. |
| `transitionProperty` | ✅ | Implemented via `webf/lib/src/css/transition.dart`. |
| `transitionDelay` | ✅ | Implemented via `webf/lib/src/css/transition.dart`. |
| `transitionDuration` | ✅ | Implemented via `webf/lib/src/css/transition.dart`. |
| `transitionTimingFunction` | ✅ | Implemented via `webf/lib/src/css/transition.dart`. |
| `willChange` | ❌ | Not implemented. |
| `contain` | ❌ | Not implemented. |
| `content` | ⚠️ | Pseudo-element content exists, but Tailwind relies on `content: var(--tw-content)` → needs `var()` support for content evaluation. |
| `forcedColorAdjust` | ❌ | Not implemented. |
