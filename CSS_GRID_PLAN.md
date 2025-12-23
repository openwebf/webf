# CSS Grid Implementation & Testing Plan

## Part 1: Implementation Plan

**Overview**
- **Purpose:** Deliver a spec-compliant CSS Grid Layout implementation in WebF spanning style parsing, render-style plumbing, layout/painting updates, and integration tests so authors can rely on the MDN grid reference.
- **Scope:** Introduce grid displays (`grid`, `inline-grid`), grid property storage (`grid-template-*`, `grid-auto-*`, placement shorthands), a new `RenderGridLayout` with track sizing & placement, and computed-style serialization; cover widget/unit/integration tests plus docs/process tracking.

**Goals**
- **Display Plumbing:** Extend `CSSDisplay` and render-style creation to instantiate grid render objects; ensure blockification rules treat grid containers/items correctly.
- **Style Surface:** Provide `CSSGridMixin` with typed tracks and placements, shorthand expansion, gap interplay, and property invalidation hooks.
- **Layout Engine:** Implement `RenderGridLayout` (parent data, track sizing, placement, gaps, alignment) and integrate with intrinsic sizing/baseline logic.
- **Computed Style:** Serialize grid properties (`grid-auto-flow`, `grid-template-*`, placements) through `getComputedStyle`, mirroring MDN expectations.
- **Testing:** Add Flutter widget tests for parsing/layout, plus integration specs (snapshot + computed assertions) per phase; maintain `dev_css_grid_process.md`.

**Non-Goals**
- **CSS Grid Level 2+:** Subgrid, masonry layout, and advanced layout modules are out of scope for the initial landing.
- **Legacy Layout Rewrite:** Flexbox/flow engines remain untouched except for interoperability tweaks (blockification, gap invalidation, etc.).
- **Full bridge evaluation:** Keep grid logic in Dart/Flutter; no C++/bridge layout rewrite.

**Activation**
- **Default On:** Once merged, grid support is available without flags.
- **Process Tracking:** `dev_css_grid_process.md` records milestones, tests, and outstanding work.

**Architecture Changes**
- **Display Resolution:** `CSSDisplayMixin` recognizes `grid`/`inline-grid` and blockifies grid items; `RenderStyle.createRenderLayout()` instantiates `RenderGridLayout` or repaint-boundary variant.
- **Style Layer:** New `CSSGridMixin` stores track lists (`GridTrackList`), placements (`GridPlacement`), and auto-flow enums, exposing setters that trigger layout invalidation when grid containers/items update.
- **Parsing Helpers:** Track/placement parsing handles `auto`, fixed lengths, `fr`, keywords (`min-content`), and `span` syntaxes; `CSSStyleProperty` expands `grid-row` / `grid-column` shorthands.
- **Layout Engine:** `RenderGridLayout` (initially a flow placeholder, later full grid algorithm) manages track sizing, placement, painting order, and gap usage; other layout utilities (flow, inline builder, margin collapse) treat grid similar to block/flex.
- **Computed Style:** `ComputedCSSStyleDeclaration` maps grid properties (display, auto-flow, templates, placements) to CSS text to satisfy `getComputedStyle`.
- **Docs/Test Harness:** Plan + progress logs in `dev_css_grid_process.md`; integration group `GridLayout` added for CSS grid specs.

**Implementation Tasks**
- **Phase 1 – Style Plumbing**
  - Add grid display enum values, blockification rules, and `RenderStyle` factory branch.
  - Implement `CSSGridMixin`, grid keywords, shorthand expansion, and helper parsers.
  - Adjust surrounding systems (gap mixin, margin logic, inline builders, length percentages) to consider grid containers/items.
  - Tests: parsing widget tests (`grid_style_parsing_test.dart`), basic integration spec verifying computed values.

- **Phase 2 – Layout Skeleton**
  - Flesh out `RenderGridLayout` with parent data, child iteration, and instrumentation; keep legacy flow behavior until track sizing lands.
  - Integrate baseline/intrinsic sizing hooks and add guard helpers (`isSelfRenderGridLayout`).
  - Tests: smoke widget test ensuring grid render object instantiates without crashes.

- **Phase 3 – Track Sizing & Placement**
  - Implement explicit/implicit track sizing (fixed, auto, fr), `grid-auto-flow` logic, placement resolution (`grid-row/column`, span handling).
  - Support gaps, auto row/column generation, and overflow/intrinsic impacts.
  - Tests: widget layout assertions (placement, spanning, gaps) + integration snapshot for dashboard-style grid.

- **Phase 4 – Alignment & Template Features**
  - Add `justify-content`, `align-content`, `justify-items`, `align-items`, per-item overrides, and template serialization (`grid-template-rows/columns`).
  - Extend parsing for `repeat()`, `minmax()`, and named lines/areas if planned for MVP.
  - Status: per-item alignment plus `place-*` shorthands now have widget + integration coverage, and `grid-auto-flow: row|column dense` behavior is verified through layout assertions.
  - Tests: alignment-focused widget suites, computed-style integration checks.

- **Phase 5 – Hardening & Docs**
  - Optimize layout passes, cache track calculations, and ensure intrinsic sizing/parsing edge cases handled.
  - Update documentation, example apps, and process log; expand integration specs to cover real-world grids.

**Testing**
- **Widget/Unit:** Add suites under `webf/test/src/css` and `webf/test/src/rendering` for parsing, track sizing, placement, alignment, and computed-style serialization.
- **Integration:** Under `integration_tests/specs/css/css-grid`, include computed-style assertions plus snapshot comparisons; register in `spec_group.json5`.
- **Regression:** Rerun existing `npm test`, `flutter test`, and integration test targets per milestone; document failures in `dev_css_grid_process.md`.

**Risks & Mitigations**
- **Performance:** Track sizing and placement loops may be expensive; mitigate with caching and early outs in later phases.
- **Interop Gaps:** MDN tests may expect features beyond MVP (e.g., `auto-flow: dense`); document unsupported features and guard usage.
- **Computed Style Expectations:** Ensure serialization returns deterministic strings (normalized whitespace) to avoid flaky tests.

**Rollout Strategy**
- **Incremental Landing:** Merge phases sequentially with tests + process log updates; each phase should leave grid usable (even if limited).
- **Docs & Communication:** Keep `dev_css_grid_process.md` and CSS_GRID_PLAN.md updated; highlight new capabilities in release notes when features stabilize.

**Next Steps**
Track sizing/placement for MVP grids now ships with widget + integration coverage, and per-item alignment plumbing is partially in-tree. Upcoming focus areas:

1. Begin Phase 5 hardening by profiling `RenderGridLayout` hot paths (auto-placement + track resolution), enumerating slow cases, and sketching caching/intrinsic sizing fixes.
2. Implement the `grid` shorthand property (per MDN / CSS Grid 1) as a thin layer over existing longhands (`grid-template-*`, `grid-auto-*`), covering the common `none`, template, and auto-flow forms and deferring subgrid/masonry keywords per non-goals.
3. Add a basic `grid-template` shorthand (rows/columns/areas) parser to align with authors' expectations for shorthand usage while still delegating storage to existing typed fields.
4. Expand track-size parsing to gracefully ignore unsupported keywords like `min-content`/`max-content` in grid track lists (where they are not yet wired into layout), and document the current support level in `dev_css_grid_process.md`.
5. Stress-test grid layouts inside representative app flows (dashboard, list virtualization) to validate performance/behavioral stability before GA.
6. Flip on `DebugFlags.enableCssGridProfiling` during perf sessions to capture per-grid timing for materialization, placement, and child layout.
7. Continue filling integration matrix: template-area happy-path + auto-fit/place-content + template-area overlap/unknown-area cases landed; next targets are shorthand-centric specs (e.g., `grid` / `grid-template`) and dense auto-fill dashboards with per-item overrides.

**TODOs**
- [x] Capture overview/goals/scope plus risks and rollout strategy.
- [x] Land Phase 1 plumbing (display enum, CSSGridMixin, shorthand parsing, auxiliary helpers).
- [x] Add Phase 1 widget + integration tests (parsing/computed style) and wire to spec group.
- [x] Implement `RenderGridLayout` skeleton and hook creation paths.
- [x] Implement full track sizing/placement (Phase 3) with tests.
- [x] Extend alignment/template features (Phase 4) with serialization and coverage (per-item alignment + computed styles partially landed).
- [x] Complete computed-style serialization and integration specs for grid properties.
- [ ] Profile and harden grid layout (Phase 5), updating docs/examples.
- [ ] Add `grid` and `grid-template` shorthands on top of existing longhands, with focused integration specs under `integration_tests/specs/css/css-grid`.

---

## Part 2: Integration Testing Plan (WPT-Based)

**Last Updated:** 2025-12-15

### Overview

This section provides a comprehensive plan to add integration tests for WebF's CSS Grid implementation based on the Web Platform Tests (WPT) CSS Grid test suite structure.

**WPT Reference:** `~/Documents/github/wpt/css/css-grid/` (2,386 tests)
**WebF Target:** `integration_tests/specs/css/css-grid/`

### Current Test Coverage Analysis

#### Existing WebF CSS Grid Tests (11 files, ~40 tests)
1. `basic-concepts.ts` - Basic grid layout (2 tests)
2. `track-sizing.ts` - Track sizing algorithms (3 tests)
3. `auto-placement.ts` - Auto-placement & alignment (23 tests)
4. `template-areas.ts` - Grid template areas (2 tests)
5. `grid-shorthand.ts` - Grid shorthand property (3 tests)
6. `grid-template-shorthand.ts` - Grid-template shorthand
7. `auto-fit-place-content.ts` - Auto-fit with place-content (2 tests)
8. `dense-flow-dashboard.ts` - Dense flow algorithm (1 test)
9. `auto-columns.ts` - Auto columns
10. `computed-style.ts` - Computed styles
11. `template-areas-overlap.ts` - Template area overlaps

#### WPT Test Distribution
| Category | Test Count | Percentage | WebF Coverage |
|----------|-----------|------------|---------------|
| Grid Lanes (Track Sizing) | 789 | 33% | ⚠️ Minimal |
| Alignment | 476 | 20% | ⚠️ Basic only |
| Abspos | 303 | 13% | ❌ None |
| Grid Items | 205 | 9% | ⚠️ Minimal |
| Subgrid | 175 | 7% | ❌ Out of scope |
| Grid Definition | 82 | 3% | ✅ Basic |
| Grid Model | 81 | 3% | ✅ Basic |
| Parsing | 61 | 3% | ⚠️ Minimal |
| Layout Algorithm | 61 | 3% | ⚠️ Minimal |
| Placement | 20 | 1% | ✅ Good |
| Animation | 17 | 1% | ❌ None |
| Implicit Grids | 3 | <1% | ✅ Basic |

**Key Findings:**
- ❌ **Critical Gaps:** Grid lanes (track sizing), alignment (baseline), absolute positioning
- ⚠️ **Partial Coverage:** Grid items, layout algorithm, parsing
- ✅ **Good Coverage:** Basic concepts, placement, grid shorthand

### Integration Testing Phases

---

### Phase 1: Grid Definition & Track Sizing 🔴 HIGH PRIORITY
**Target:** 10 new test files, ~80 tests
**Est. Time:** 2 weeks

#### 1.1 Grid Track Definition Tests

**File:** `grid-definition/explicit-tracks.ts`
```typescript
describe('CSS Grid explicit track definition', () => {
  it('defines fixed pixel tracks')
  it('defines em/rem unit tracks')
  it('defines percentage tracks')
  it('defines fractional (fr) unit tracks')
  it('mixes fixed and flexible tracks')
  it('defines tracks with named lines')
  it('handles duplicate line names')
  it('resolves auto track sizes')
});
```

**File:** `grid-definition/repeat-notation.ts`
```typescript
describe('CSS Grid repeat() notation', () => {
  it('repeats fixed number of tracks')
  it('repeats with named lines')
  it('handles multiple repeat() blocks')
  it('mixes repeat() with explicit tracks')
  it('validates invalid repeat() syntax')
});
```

**File:** `grid-definition/auto-repeat.ts`
```typescript
describe('CSS Grid auto-repeat (auto-fill/auto-fit)', () => {
  it('fills columns with auto-fill')
  it('fits columns with auto-fit')
  it('auto-fills rows')
  it('auto-fits rows')
  it('auto-repeat with minmax()')
  it('auto-repeat with fixed tracks before')
  it('auto-repeat with fixed tracks after')
  it('auto-repeat with percentage sizes')
  it('updates on container resize')
  it('works with gaps')
});
```

**File:** `grid-definition/template-areas-advanced.ts`
```typescript
describe('CSS Grid template areas advanced', () => {
  it('handles complex multi-row areas')
  it('rejects non-rectangular areas')
  it('handles empty cells with dot notation')
  it('combines areas with line placement')
  it('updates areas dynamically')
  it('handles invalid area names gracefully')
});
```

#### 1.2 Track Sizing Algorithm Tests

**File:** `grid-lanes/track-sizing-basic.ts`
```typescript
describe('CSS Grid track sizing fundamentals', () => {
  it('sizes fixed pixel tracks')
  it('sizes percentage tracks in definite container')
  it('sizes percentage tracks in indefinite container')
  it('sizes auto tracks to content')
  it('resolves track sizes in correct order')
});
```

**File:** `grid-lanes/track-sizing-minmax.ts`
```typescript
describe('CSS Grid minmax() function', () => {
  it('clamps to min with small content')
  it('clamps to max with large content')
  it('uses auto as min')
  it('uses auto as max')
  it('handles min-content/max-content')
  it('resolves percentage min/max')
  it('handles fr units in minmax')
  it('handles invalid min > max')
});
```

**File:** `grid-lanes/track-sizing-fr.ts`
```typescript
describe('CSS Grid fractional (fr) units', () => {
  it('distributes space with single fr')
  it('distributes space with multiple fr values')
  it('combines fr with fixed tracks')
  it('combines fr with percentage tracks')
  it('calculates fr with gaps')
  it('distributes remaining space correctly')
  it('handles fr in minmax()')
});
```

**File:** `grid-lanes/track-sizing-content.ts`
```typescript
describe('CSS Grid content-based sizing', () => {
  it('sizes tracks to min-content')
  it('sizes tracks to max-content')
  it('uses fit-content() function')
  it('sizes with spanning items')
  it('handles nested grid content sizing')
  it('resolves intrinsic sizes correctly')
});
```

**File:** `grid-lanes/track-sizing-intrinsic.ts`
```typescript
describe('CSS Grid intrinsic track sizing', () => {
  it('calculates base size for auto tracks')
  it('calculates growth limit')
  it('handles spanning items contribution')
  it('distributes extra space')
  it('resolves circular dependencies')
});
```

**File:** `grid-lanes/gaps.ts`
```typescript
describe('CSS Grid gaps', () => {
  it('applies row-gap')
  it('applies column-gap')
  it('uses gap shorthand')
  it('handles percentage gaps')
  it('uses calc() in gaps')
  it('combines gaps with repeat()')
  it('excludes gaps from fr calculation')
});
```

---

### Phase 2: Grid Item Placement & Sizing 🔴 HIGH PRIORITY
**Target:** 12 new test files, ~90 tests
**Est. Time:** 2 weeks

#### 2.1 Explicit Placement Tests

**File:** `placement/line-based.ts`
```typescript
describe('CSS Grid line-based placement', () => {
  it('places item with grid-column-start')
  it('places item with grid-column-end')
  it('places item with grid-row-start')
  it('places item with grid-row-end')
  it('uses positive line numbers')
  it('uses negative line numbers')
  it('places with named lines')
  it('spans with span keyword and number')
  it('spans with named lines')
});
```

**File:** `placement/area-based.ts`
```typescript
describe('CSS Grid area-based placement', () => {
  it('places with grid-area line numbers')
  it('places with named grid areas')
  it('uses grid-area shorthand syntax')
  it('handles invalid area references')
  it('falls back to auto-placement')
});
```

**File:** `placement/auto-placement-algorithm.ts`
```typescript
describe('CSS Grid auto-placement algorithm', () => {
  it('auto-places in sparse packing mode')
  it('auto-places in dense packing mode')
  it('flows in row direction')
  it('flows in column direction')
  it('packs densely in row direction')
  it('packs densely in column direction')
  it('mixes explicit and auto placement')
  it('fills earlier gaps with dense')
});
```

**File:** `placement/overlapping-items.ts`
```typescript
describe('CSS Grid overlapping items', () => {
  it('overlaps items in same cell')
  it('orders items by source order')
  it('orders items with z-index')
  it('overlaps spanning items')
  it('paints correctly with transparency')
});
```

#### 2.2 Grid Item Behavior Tests

**File:** `grid-items/sizing.ts`
```typescript
describe('CSS Grid item sizing', () => {
  it('resolves percentage width in definite tracks')
  it('resolves percentage height in definite tracks')
  it('resolves percentage in auto tracks')
  it('applies min-width constraints')
  it('applies max-width constraints')
  it('applies min-height constraints')
  it('applies max-height constraints')
  it('uses box-sizing: border-box')
});
```

**File:** `grid-items/margins.ts`
```typescript
describe('CSS Grid item margins', () => {
  it('centers with auto horizontal margins')
  it('centers with auto vertical margins')
  it('combines auto margins with alignment')
  it('resolves percentage margins')
  it('handles negative margins')
  it('does not collapse margins')
});
```

**File:** `grid-items/aspect-ratio.ts`
```typescript
describe('CSS Grid item aspect ratio', () => {
  it('maintains aspect ratio with fixed width')
  it('maintains aspect ratio with fixed height')
  it('maintains aspect ratio with auto sizing')
  it('combines aspect ratio with minmax()')
  it('resolves conflicts with explicit sizes')
});
```

**File:** `grid-items/baseline.ts`
```typescript
describe('CSS Grid baseline alignment', () => {
  it('aligns to first baseline')
  it('aligns to last baseline')
  it('handles different font sizes')
  it('accounts for padding and borders')
  it('aligns in row axis')
  it('aligns in column axis')
  it('falls back when baseline unavailable')
});
```

---

### Phase 3: Alignment & Spacing 🟡 MEDIUM PRIORITY
**Target:** 12 new test files, ~85 tests
**Est. Time:** 2 weeks

#### 3.1 Container Alignment Tests

**File:** `alignment/justify-content.ts`
```typescript
describe('CSS Grid justify-content', () => {
  it('justifies content start')
  it('justifies content end')
  it('justifies content center')
  it('distributes space-between')
  it('distributes space-around')
  it('distributes space-evenly')
  it('stretches tracks')
  it('works with fixed tracks')
  it('works with auto tracks')
  it('combines with gaps')
});
```

**File:** `alignment/align-content.ts`
```typescript
describe('CSS Grid align-content', () => {
  it('aligns content start')
  it('aligns content end')
  it('aligns content center')
  it('distributes space-between')
  it('distributes space-around')
  it('distributes space-evenly')
  it('stretches tracks')
  it('works with fixed tracks')
  it('works with auto tracks')
  it('combines with gaps')
});
```

**File:** `alignment/place-content.ts`
```typescript
describe('CSS Grid place-content shorthand', () => {
  it('sets both axes with two values')
  it('sets both axes with one value')
  it('interacts with gaps')
  it('overrides individual properties')
});
```

#### 3.2 Item Alignment Tests

**File:** `alignment/justify-items.ts`
```typescript
describe('CSS Grid justify-items', () => {
  it('justifies items start')
  it('justifies items end')
  it('justifies items center')
  it('stretches items (default)')
  it('interacts with item width')
});
```

**File:** `alignment/align-items.ts`
```typescript
describe('CSS Grid align-items', () => {
  it('aligns items start')
  it('aligns items end')
  it('aligns items center')
  it('stretches items (default)')
  it('aligns to baseline')
  it('aligns to first baseline')
  it('aligns to last baseline')
  it('interacts with item height')
});
```

**File:** `alignment/justify-self.ts`
```typescript
describe('CSS Grid justify-self', () => {
  it('overrides container justify-items')
  it('uses auto to inherit')
  it('works with all values')
  it('combines with fixed size')
  it('combines with auto size')
});
```

**File:** `alignment/align-self.ts`
```typescript
describe('CSS Grid align-self', () => {
  it('overrides container align-items')
  it('uses auto to inherit')
  it('works with all values')
  it('combines with fixed size')
  it('combines with auto size')
});
```

**File:** `alignment/place-items.ts`
```typescript
describe('CSS Grid place-items shorthand', () => {
  it('sets both axes with two values')
  it('sets both axes with one value')
});
```

**File:** `alignment/place-self.ts`
```typescript
describe('CSS Grid place-self shorthand', () => {
  it('sets both axes with two values')
  it('sets both axes with one value')
});
```

**File:** `alignment/baseline-alignment.ts`
```typescript
describe('CSS Grid baseline alignment', () => {
  it('aligns items to row baseline')
  it('aligns items to column baseline')
  it('handles multiple baseline contexts')
  it('works with different writing modes')
  it('falls back to start/end')
});
```

**File:** `alignment/safe-unsafe.ts`
```typescript
describe('CSS Grid safe/unsafe alignment', () => {
  it('uses safe with center')
  it('uses unsafe with center')
  it('handles overflow with safe')
  it('handles overflow with unsafe')
});
```

---

### Phase 4: Implicit Grid & Dynamic Behavior 🟡 MEDIUM PRIORITY
**Target:** 8 new test files, ~55 tests
**Est. Time:** 1.5 weeks

**File:** `implicit-grids/auto-rows.ts`
**File:** `implicit-grids/auto-columns-extended.ts`
**File:** `implicit-grids/implicit-creation.ts`
**File:** `implicit-grids/implicit-with-gaps.ts`
**File:** `implicit-grids/implicit-named-lines.ts`
**File:** `dynamic/add-remove-items.ts`
**File:** `dynamic/style-changes.ts`
**File:** `dynamic/resize.ts`

---

### Phase 5: Absolute Positioning 🟡 MEDIUM PRIORITY
**Target:** 8 new test files, ~50 tests
**Est. Time:** 1.5 weeks

**File:** `abspos/containing-block.ts`
**File:** `abspos/offset-resolution.ts`
**File:** `abspos/alignment.ts`
**File:** `abspos/sizing.ts`
**File:** `abspos/grid-placement.ts`
**File:** `abspos/out-of-flow.ts`
**File:** `abspos/static-position.ts`
**File:** `abspos/z-index.ts`

---

### Phase 6: Grid Model & Parsing 🟢 LOW PRIORITY
**Target:** 8 new test files, ~45 tests
**Est. Time:** 1.5 weeks

**File:** `grid-model/display-grid.ts`
**File:** `grid-model/grid-containers.ts`
**File:** `grid-model/grid-items-types.ts`
**File:** `grid-model/writing-modes.ts`
**File:** `parsing/computed-values-extended.ts`
**File:** `parsing/invalid-values.ts`
**File:** `parsing/getComputedStyle-complete.ts`
**File:** `parsing/serialization.ts`

---

### Phase 7: Advanced Features 🟢 LOW PRIORITY
**Target:** 6 new test files, ~35 tests
**Est. Time:** 1 week

**File:** `animation/track-size-transition.ts`
**File:** `animation/gap-transition.ts`
**File:** `layout-algorithm/sizing-resolution.ts`
**File:** `layout-algorithm/circular-dependencies.ts`
**File:** `interactions/nested-grids.ts`
**File:** `interactions/grid-in-flex.ts`

---

### Phase 8: Edge Cases & Polish 🟢 LOW PRIORITY
**Target:** 5 new test files, ~30 tests
**Est. Time:** 1 week

**File:** `edge-cases/overlarge-grids.ts`
**File:** `edge-cases/empty-grids.ts`
**File:** `edge-cases/single-cell.ts`
**File:** `edge-cases/extreme-values.ts`
**File:** `edge-cases/rtl-support.ts`

---

### Test Implementation Guidelines

#### Standard Test Template
```typescript
describe('CSS Grid <feature>', () => {
  it('should <specific behavior>', async () => {
    // 1. Setup
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 200px';
    grid.style.gridTemplateRows = '50px 100px';

    // 2. Create items
    const item = document.createElement('div');
    item.textContent = 'Item';
    item.style.gridColumn = '1';
    item.style.gridRow = '1';
    grid.appendChild(item);

    // 3. Add to document
    document.body.appendChild(grid);

    // 4. Wait for layout
    await waitForFrame();

    // 5. Visual regression test
    await snapshot();

    // 6. Assertions
    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateColumns).toBe('100px 200px');

    const rect = item.getBoundingClientRect();
    expect(rect.left).toBe(0);
    expect(rect.width).toBe(100);

    // 7. Cleanup
    grid.remove();
  });
});
```

#### Testing Best Practices
1. **Snapshot First:** Use `await snapshot()` for visual regression
2. **Computed Values:** Verify getComputedStyle() returns correct values
3. **Layout Verification:** Check getBoundingClientRect() positions/sizes
4. **Cleanup:** Always call `.remove()` on created elements
5. **Async Handling:** Use `await waitForFrame()` before assertions
6. **Clear Names:** Describe exact behavior being tested

### Coverage Summary

| Phase | Files | Tests | Priority | Weeks |
|-------|-------|-------|----------|-------|
| Current | 11 | 40 | - | - |
| Phase 1 | +10 | +80 | 🔴 HIGH | 2 |
| Phase 2 | +12 | +90 | 🔴 HIGH | 2 |
| Phase 3 | +12 | +85 | 🟡 MEDIUM | 2 |
| Phase 4 | +8 | +55 | 🟡 MEDIUM | 1.5 |
| Phase 5 | +8 | +50 | 🟡 MEDIUM | 1.5 |
| Phase 6 | +8 | +45 | 🟢 LOW | 1.5 |
| Phase 7 | +6 | +35 | 🟢 LOW | 1 |
| Phase 8 | +5 | +30 | 🟢 LOW | 1 |
| **TOTAL** | **80** | **510** | - | **12.5** |

### Success Metrics

- ✅ Minimum 500 integration tests covering CSS Grid
- ✅ All P0/P1 features tested with multiple scenarios
- ✅ 100% of implemented features have tests
- ✅ Visual regression coverage for all layout features
- ✅ Computed style validation for all grid properties
- ✅ All tests pass consistently (no flaky tests)

### Running Tests

```bash
# Run all CSS Grid tests
cd integration_tests && npm run integration -- specs/css/css-grid/

# Run specific phase
npm run integration -- specs/css/css-grid/grid-definition/
npm run integration -- specs/css/css-grid/alignment/

# Run single test file
npm run integration -- specs/css/css-grid/placement/line-based.ts

# Update snapshots
npm run integration -- --update-snapshots

# View snapshot diffs
npm run snapshot-viewer
```

### References

- [CSS Grid Level 1 Spec](https://drafts.csswg.org/css-grid-1/)
- [CSS Grid Level 2 Spec](https://drafts.csswg.org/css-grid-2/)
- [WPT CSS Grid Tests](https://github.com/web-platform-tests/wpt/tree/master/css/css-grid)
- [MDN CSS Grid](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout)
- [WebF Integration Testing Guide](integration_tests/CLAUDE.md)
