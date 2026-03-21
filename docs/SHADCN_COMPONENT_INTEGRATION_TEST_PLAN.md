# Shadcn Component Integration Test Plan

**Last Updated:** 2026-03-16
**Status:** In Progress
**Target:** `integration_tests/specs/shadcn/`

This plan covers the React/Tailwind components documented at `ui.shadcn.com/docs/components`.
It does **not** cover the native Flutter package under `native_uis/webf_shadcn_ui`.

## Context

- As of **March 14, 2026**, the current shadcn docs target modern React/Tailwind setups, with both `Radix UI` and `Base UI` variants visible in the docs.
- This repo's integration harness currently uses **React 18**, **TypeScript/TSX**, **Tailwind CSS v3**, snapshot testing, and Chrome snapshot comparison.
- Because of that version mismatch, the test plan should use **locally vendored/adapted fixture components**, not direct `npx shadcn` output.
- The first milestone should validate the platform behaviors that shadcn depends on before importing a large component surface.

Relevant local files:
- `integration_tests/package.json`
- `integration_tests/webpack.config.js`
- `integration_tests/tailwind.config.cjs`
- `integration_tests/spec_group.json5`
- `integration_tests/specs/dom/react_support.tsx`
- `integration_tests/compare-snapshots.js`

## Goals

- Add a dedicated `Shadcn` integration test area under `integration_tests/specs/`.
- Validate that WebF can render and interact with a representative set of shadcn React components.
- Keep fixtures deterministic and repo-local.
- Compare WebF output against Chrome before accepting new snapshot baselines.
- Track progress in one place, PR by PR, with clear TODO lists and blockers.

## Related use_cases Rollout

This document still primarily tracks integration-test work. In parallel, the public
`use_cases` demo app should expose shadcn like the existing `Cupertino UI` and
`Lucide Icons` entries so the shipped component pages are easy to discover.

- [x] Expose shadcn routes outside the `import.meta.env.DEV` gate in `use_cases/src/App.tsx`.
- [x] Add a `Shadcn UI` quick-start card in `use_cases/src/pages/HomePage.tsx`.
- [x] Add a `Shadcn UI` section in `use_cases/src/pages/FeatureCatalogPage.tsx`.
- [x] Expand `use_cases/src/pages/ShadcnShowcasePage.tsx` to list all currently shipped shadcn demos.
- [x] Align the showcase-entry navigation helpers with `WebFRouter.push(...)`.

## Non-Goals

- Do not test the entire shadcn catalog in one pass.
- Do not depend on live shadcn CLI generation during CI or test runs.
- Do not mix this effort with `native_uis/webf_shadcn_ui`.
- Do not accept snapshot baselines without behavior assertions and a Chrome comparison pass.

## Working Rules

Use the following rules to update this document step by step during implementation:

1. Before starting a PR, update the matching row in **Progress Summary** to `In Progress`.
2. When a task lands, check its box in the relevant PR TODO list.
3. After each meaningful step, append a dated item to **Progress Log** with:
   - files changed
   - commands run
   - results or blockers
4. If work is blocked by a WebF gap, add it under **Active Blockers** with the exact API/CSS/event gap.
5. Keep snapshot acceptance gated on both:
   - passing WebF integration results
   - Chrome comparison review

## Definition Of Done

For a shadcn component to count as covered:

- The component has at least one dedicated integration spec.
- The spec includes stable DOM/state assertions.
- Interactive components include keyboard and/or pointer assertions as applicable.
- The spec captures at least one snapshot.
- Snapshot output is reviewed against Chrome before the baseline is accepted.

## Directory And Harness Plan

Planned structure:

- `integration_tests/specs/shadcn/_shared/globals.css`
- `integration_tests/specs/shadcn/_shared/cn.ts`
- `integration_tests/specs/shadcn/_shared/test-utils.tsx`
- `integration_tests/specs/shadcn/probes/*.tsx`
- `integration_tests/specs/shadcn/core/*.tsx`
- `integration_tests/specs/shadcn/overlays/*.tsx`
- `integration_tests/specs/shadcn/advanced/*.tsx`

## Progress Summary

| PR | Scope | Status | Notes |
| --- | --- | --- | --- |
| PR1 | Harness setup + compatibility probes | In Progress | 2 probes passing, 2 tracked skips, Chrome comparison pending |
| PR2 | Core display/form components | Planned | Depends on PR1 |
| PR3 | Overlay and portal-heavy components | Planned | Depends on PR1 and PR2 |
| PR4 | Heavy-dependency components and deferred decisions | Planned | Spike-first |

## PR1 - Harness Setup And Compatibility Probes

### Purpose

Create the test area, shared helpers, and a small set of probe specs that validate shadcn-critical behaviors before component rollout.

### TODO

- [x] Add a `Shadcn` group to `integration_tests/spec_group.json5`.
- [x] Create `integration_tests/specs/shadcn/` and `_shared/`.
- [x] Add shared `globals.css` for shadcn/Tailwind fixture styles.
- [x] Add shared `cn.ts` helper compatible with repo conventions.
- [x] Add shared `test-utils.tsx` for mount, flush, keyboard, pointer, and snapshot helpers.
- [ ] Add the minimal npm dependency set needed for PR1 and PR2 fixtures.
- [x] Add a probe spec for `ReactDOM.createPortal` mount to `document.body`.
- [x] Add a probe spec for focus trap and `Escape` dismissal behavior.
- [x] Add a probe spec for roving focus with arrow keys, `Home`, and `End`.
- [x] Add a probe spec for floating-layer measurement using `getBoundingClientRect` and `ResizeObserver`.
- [x] Verify filtered integration execution for the shadcn specs.
- [ ] Compare probe snapshots against Chrome before accepting baselines.

### Acceptance

- The shadcn test area builds and runs through the existing integration harness.
- Probe specs pass in WebF.
- Any missing platform capability is documented before PR2 starts.

## PR2 - Core Display And Form Components

### Scope

Start with components that do not depend on complex overlay stacks or large third-party data/rendering libraries.

### Target Components

- `Button`
- `Input`
- `Label`
- `Card`
- `Badge`
- `Checkbox`
- `Radio Group`
- `Switch`
- `Tabs`
- `Accordion`

### TODO

- [ ] Vendor/adapt local fixture implementations for the PR2 components.
- [ ] Keep fixtures compatible with React 18 and Tailwind CSS v3.
- [ ] Prefer small shared primitives over copy-pasting large generated examples.
- [ ] Add one or more specs under `integration_tests/specs/shadcn/core/`.
- [ ] Add stable snapshots for each component family.
- [ ] Assert disabled/default/selected/open states where applicable.
- [ ] Assert `aria-*` and `data-state` attributes where applicable.
- [ ] Add keyboard assertions for `Tabs`, `Accordion`, `Checkbox`, `Radio Group`, and `Switch`.
- [ ] Compare WebF snapshots against Chrome before accepting baselines.

### Acceptance

- PR2 component fixtures render correctly in WebF.
- State transitions and keyboard behavior match expectations closely enough to make Chrome snapshots reviewable.

## PR3 - Overlay And Portal-Heavy Components

### Scope

Add the components most likely to expose gaps in portals, focus management, outside-click handling, floating-layer positioning, and keyboard navigation.

### Target Components

- `Dialog`
- `Popover`
- `Tooltip`
- `Hover Card`
- `Dropdown Menu`
- `Select`
- `Context Menu`

### TODO

- [ ] Vendor/adapt local fixture implementations for the PR3 components.
- [ ] Add specs under `integration_tests/specs/shadcn/overlays/`.
- [ ] Assert portal mount behavior for overlay content.
- [ ] Assert open/close state transitions.
- [ ] Assert outside-click dismissal where applicable.
- [ ] Assert `Escape` dismissal where applicable.
- [ ] Assert focus trap and focus restore for `Dialog`.
- [ ] Assert keyboard navigation for menu-like and select-like components.
- [ ] Assert `aria-*` and `data-state` transitions.
- [ ] Compare WebF snapshots against Chrome before accepting baselines.

### Acceptance

- Overlay components behave consistently enough in WebF to support deterministic snapshots and interaction assertions.
- Any remaining gaps are specific and documented rather than hidden in flaky tests.

## PR4 - Heavy-Dependency Components And Deferred Decisions

### Scope

Handle shadcn components that introduce additional libraries or significantly expand the compatibility matrix.

### Candidate Components

- `Calendar` / date-related components
- `Carousel`
- `Data Table`
- `Chart`
- `Sonner`

### Known Dependency Risks

- `react-day-picker`
- `embla-carousel-react`
- `@tanstack/react-table`
- `recharts`
- `sonner`

### TODO

- [ ] Run a short compatibility spike for each candidate component before landing tests.
- [ ] Document the exact extra dependency set required by each component.
- [ ] Decide per component: `land now`, `defer`, or `replace with reduced fixture`.
- [ ] Add specs only for components that pass the spike stage.
- [ ] Record any WebF blockers in **Active Blockers**.
- [ ] Compare WebF snapshots against Chrome before accepting baselines.

### Acceptance

- PR4 does not broaden scope blindly.
- Each heavy component is either covered with evidence, or explicitly deferred with a reason.

## Active Blockers

Expected high-risk areas:

- `ReactDOM.createPortal` parity
- `document.activeElement` parity for button focus inside shadcn-style composite widgets
- Keyboard event parity for composite widgets
- Focus trap and focus restore behavior
- Floating-layer positioning and measurement
- Pending PR1 verification against the live integration harness
- Tailwind v4-only upstream examples that need React 18 / Tailwind v3 adaptation

Concrete PR1 blockers found so far:

- React keyboard-event parity: dispatched `KeyboardEvent` instances are not currently driving React keyboard handlers in the shadcn focus-trap and roving-focus probes under WebF. Those probes are temporarily skipped until the event-path behavior is understood or fixed.

## Progress Log

- **2026-03-14**: Created the initial plan document.
  - Verified the local harness already supports React, TSX, CSS imports, Tailwind CSS v3, snapshots, and Chrome snapshot comparison.
  - Captured a staged rollout with PR1 through PR4.
  - Added per-PR TODO lists and a single progress tracker for future step-by-step updates.
- **2026-03-14**: Started PR1 implementation.
  - Added the `Shadcn` spec group and created `integration_tests/specs/shadcn/_shared/`.
  - Added shared CSS and test utilities for React mounting, frame flushing, keyboard events, and center-click simulation.
  - Added four probe specs covering portal mount, focus trap plus `Escape`, roving focus, and floating-layer measurement with `ResizeObserver`.
  - Remaining PR1 items: dependency decision, filtered integration verification, and Chrome comparison review.
- **2026-03-14**: Ran the first targeted WebF integration pass for the PR1 probes.
  - The filtered shadcn bundle compiled successfully.
  - `portal-mount` and `floating-layer-measurement` passed in WebF.
  - `focus-trap-escape` and `roving-focus` failed on `document.activeElement` expectations for focused buttons.
  - Adjusted those probes to assert explicit component focus state, and recorded `document.activeElement` parity as an active blocker for follow-up investigation.
- **2026-03-14**: Reran the targeted PR1 probes after tightening assertions.
  - The React keyboard-driven probes still did not advance state under dispatched `KeyboardEvent` input, indicating a likely React keyboard-event parity gap rather than an assertion issue.
  - Marked `focus-trap-escape` and `roving-focus` as tracked skips for now so PR1 can continue without leaving the integration suite red.
- **2026-03-14**: Ran the final filtered PR1 verification with the current blocker state.
  - Command used: `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 npm run integration -- --skip-build specs/shadcn/probes/portal-mount.tsx specs/shadcn/probes/focus-trap-escape.tsx specs/shadcn/probes/roving-focus.tsx specs/shadcn/probes/floating-layer-measurement.tsx`
  - Result: `4 specs, 0 failures, 2 pending specs`.
  - Verified passing probes: `portal-mount`, `floating-layer-measurement`.
  - Remaining open PR1 work: dependency decision and Chrome snapshot comparison.
- **2026-03-14**: Added the first composed shadcn use-case case.
  - Added `specs/shadcn/use-cases/workspace-preferences.tsx` as a React settings-panel case instead of another low-level probe.
- **2026-03-16**: Enabled the shadcn use_cases surface alongside Cupertino UI and Lucide Icons.
  - Exposed the `/shadcn-*` routes in `use_cases/src/App.tsx` outside the previous dev-only gate.
  - Added `Shadcn UI` discovery entries to the `HomePage` quick-start cards and the `FeatureCatalogPage`.
  - Expanded `ShadcnShowcasePage` to list all currently shipped shadcn demo pages grouped by component area.
  - Switched the showcase-entry navigation helpers to `WebFRouter.push(...)` so route mounting follows the hybrid-router path consistently.
  - Added local dependency files under `integration_tests/shadcn_support/workspace_preferences/` to model a small component tree with supporting data and types.
  - Reused the shared shadcn harness and extended the shared CSS with card/input/badge/toggle utility classes so future use-case specs do not need to inline component styling.

## External References

Verified on **2026-03-14**:

- `https://ui.shadcn.com/docs/components`
- `https://ui.shadcn.com/docs/installation`
- `https://ui.shadcn.com/docs/components/dialog`
- `https://ui.shadcn.com/docs/components/dropdown-menu`
- `https://ui.shadcn.com/docs/components/select`
- `https://ui.shadcn.com/docs/components/data-table`
- `https://ui.shadcn.com/docs/components/calendar`
- `https://ui.shadcn.com/docs/components/carousel`
- `https://ui.shadcn.com/docs/components/chart`
- `https://ui.shadcn.com/docs/components/sonner`
