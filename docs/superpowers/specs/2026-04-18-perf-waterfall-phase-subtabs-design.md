# Performance Waterfall: Phase Sub-Tabs

**Date:** 2026-04-18
**Branch:** `feat/perf-graph-redesign`
**Scope:** WebF DevTools — inspector panel Performance tab

## Goal

Split the single Performance-tab waterfall into two sub-tabs that separate the two natural phases of a WebF session:

- **Init → Attach** — everything from `controller.load()` up to `attachToFlutter` fires.
- **Attach → Paint** — everything from `attachToFlutter` onward, including FP / FCP / LCP.

Today the waterfall shows both phases on a single timeline with `attachToFlutter` rendered as a vertical stage divider (`WaterfallData.attachOffset`). Users viewing mixed preload / prerender sessions have to mentally slice the timeline at the divider to reason about either phase in isolation. Sub-tabs make that slicing a UI affordance.

## Non-goals

- No changes to instrumentation (`LoadingState`, `PerformanceTracker`, controller callbacks, C++ JS profiler).
- No changes to the `buildWaterfallData()` data pipeline — it continues to produce one merged `WaterfallData`.
- No changes to the FP / FCP / LCP summary cards at the top of the Performance tab.
- No new metrics, no FFI work, no changes to how spans are recorded.
- No changes to top-level tab structure (`Controllers / Routes / Network / Console / Performance`).

## User-visible behavior

Inside the existing Performance tab (`_buildPerformanceTab` → `_buildSingleControllerPerformance`), the content becomes:

```
┌─ Performance ───────────────────────────────────┐
│ Route: /home    FP: 120ms  FCP: 180ms  LCP: …  │  ← summary stays shared
├─────────────────────────────────────────────────┤
│ ┌─ Sub-tab bar ───────────────────────────────┐ │
│ │ [ Init → Attach ] [ Attach → Paint ]        │ │
│ ├─────────────────────────────────────────────┤ │
│ │                                             │ │
│ │       Waterfall (filtered by phase)         │ │
│ │                                             │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

- FP / FCP / LCP summary cards and per-route metadata stay above the sub-tabs and remain visible regardless of sub-tab selection.
- Sub-tab selection is persisted per-widget session via a static int mirroring the top-level tab's `_lastSelectedTabIndex`.
- When `attachOffset == null` (attach has not yet fired), the **Attach → Paint** tab is rendered with reduced opacity, cannot be selected, and its body shows "Waiting for attachToFlutter…".

## Design decisions

1. **Sub-tabs live inside the existing Performance tab** (not new top-level tabs). Summary cards and per-route LCP info stay shared.
2. **Time-based allocation, no duplication.** Each entry / milestone / frame boundary appears in the sub-tab whose time window contains its start timestamp. Cross-boundary entries (start pre-attach, end post-attach) live in Init → Attach only; their bar visually extends past the attach line. This is necessary because category alone does not predict phase — e.g. JS eval / HTML parse / DOM construction run pre-attach in prerender mode but post-attach in preload mode.
3. **Absolute t=0 shared across both tabs.** Both tabs use `sessionStart` (`loadingState.startTime` or `tracker.sessionStart`) as time zero. Axis labels in Tab 2 start at `attachOffset.inMilliseconds`, not `0`.
4. **Disabled-when-empty for Attach → Paint.** Tab is always present in the bar; its appearance and interactivity toggle on `attachOffset != null`.

## Architecture

### New enum

Add to `webf/lib/src/devtools/panel/waterfall_chart.dart`:

```dart
enum WaterfallPhase {
  initToAttach,   // entries with start < attachOffset
  attachToPaint,  // entries with start >= attachOffset
}
```

### WaterfallChart parameter

`WaterfallChart` gains one required field:

```dart
final WaterfallPhase phase;
```

### Filter predicates

Applied once per render before the existing layout / painting logic:

```dart
bool _includeEntry(WaterfallEntry e, Duration? attachOffset) {
  if (attachOffset == null) {
    return phase == WaterfallPhase.initToAttach;
  }
  return phase == WaterfallPhase.initToAttach
      ? e.start < attachOffset
      : e.start >= attachOffset;
}
```

Analogous predicates apply to:
- `milestones` — filtered by `milestone.offset`.
- `frameBoundaries` — filtered by `Duration` value.

### Axis range per tab

- Tab 1 (`initToAttach`): `[Duration.zero, attachOffset ?? totalDuration]`.
- Tab 2 (`attachToPaint`): `[attachOffset!, totalDuration]`.

Axis tick labels always show "time since load" (absolute). Tab 2's left-edge tick is therefore `attachOffset.inMilliseconds`, not `0`.

### Stage divider suppression

The existing in-chart stage-divider vertical line (waterfall_chart.dart:1507, 1541) is gated behind `phase == null`. With the new design, `phase` is always set, so the divider is never drawn — each tab already represents one side of the divider. The "Attach" milestone continues to render at the left edge of Tab 2 as a phase-start marker.

### Inspector panel sub-tab scaffolding

Inside `_buildSingleControllerPerformance`:

- Wrap the existing `WaterfallChart` site in a nested `DefaultTabController(length: 2)` with `TabBar` + `TabBarView`.
- Tab labels: `"Init → Attach"`, `"Attach → Paint"`.
- Persist the selected index in a static int (`_lastSelectedPerfSubTabIndex`) mirroring the top-level tab pattern.
- When `waterfallData.attachOffset == null`, make the Attach → Paint tab non-interactive:
  - Style the label with reduced opacity (~0.4).
  - Override `TabBar.onTap` to reject switching to the disabled index; the controller stays on Init → Attach.
- If the disabled tab somehow ends up selected (e.g. persisted index from a previous session), the body renders a placeholder widget: "Waiting for attachToFlutter…".

## FP / FCP / LCP placement

FP / FCP / LCP milestones fire after attach (paint requires a render tree). Their timestamps satisfy `offset >= attachOffset`, so under the time-based filter they always land on Attach → Paint automatically. No special-casing in the filter code.

The summary cards above the sub-tabs continue to show all three values regardless of selected sub-tab. They already render today in both current and final variants; behavior unchanged.

## Empty-state matrix

| `attachOffset` | Selected sub-tab | Render |
|---|---|---|
| `null` | Init → Attach | Waterfall showing all entries (everything is pre-attach) |
| `null` | Attach → Paint | Placeholder: "Waiting for attachToFlutter…" — tab label dimmed, tap rejected (controller stays on Init → Attach if user taps the disabled tab) |
| set | Init → Attach | Filtered waterfall, axis `[0, attachOffset]` |
| set | Attach → Paint | Filtered waterfall, axis `[attachOffset, totalDuration]` |

## Reset semantics

- `controller.load()` resets `_loadingState` and the route's `navigationStartTime`. Waterfall data rebuilds; `attachOffset` becomes `null` until the new attach fires; Attach → Paint re-enters its disabled state.
- Controller detached: existing `_buildSingleControllerPerformance` already renders "No attached controller found" at the tab level. This supersedes sub-tabs — no interaction needed.

## Files touched

| File | Change |
|---|---|
| `webf/lib/src/devtools/panel/waterfall_chart.dart` | Add `WaterfallPhase` enum; add `phase` field to `WaterfallChart`; add three filter predicates; gate existing in-chart stage-divider rendering behind `phase == null`; constrain axis range per phase; adjust `_hitTestFlameSpan` to operate on the filtered span list. |
| `webf/lib/src/devtools/panel/inspector_panel.dart` | Inside `_buildSingleControllerPerformance`, add a nested `DefaultTabController` + `TabBar` + `TabBarView` around the existing waterfall widget. Add static `_lastSelectedPerfSubTabIndex`. Add placeholder widget for the empty Attach → Paint state. Dim the Attach → Paint label when `attachOffset == null`. |
| `webf/test/src/devtools/waterfall_phase_filter_test.dart` (new) | Unit test for the filter predicate across the three state combinations below. |
| `webf/test/src/devtools/perf_subtabs_test.dart` (new) | Widget test for tab enable / disable behavior driven by `attachOffset`. |

## Migration risk

- `WaterfallChart` becomes phase-scoped. The grep across `webf/lib/` shows no call sites outside `inspector_panel.dart`, so the change is contained. If a future caller needs the full timeline, the in-chart stage divider code stays in place behind the `phase == null` gate.
- Persisted top-level tab index (`_lastSelectedTabIndex`) behavior is unchanged.
- `buildWaterfallData()` signature unchanged — no ripple to other callers.

## Testing

### Unit — filter predicate

`webf/test/src/devtools/waterfall_phase_filter_test.dart`. Build a synthetic `WaterfallData` with entries on both sides of a fixed `attachOffset`; assert:

- `initToAttach` includes only entries with `start < attachOffset`.
- `attachToPaint` includes only entries with `start >= attachOffset`.
- When `attachOffset == null`, `initToAttach` includes everything and `attachToPaint` includes nothing.
- Cross-boundary entry (start pre-attach, end post-attach) appears in `initToAttach` only and is not clipped.

### Widget — sub-tab enable state

`webf/test/src/devtools/perf_subtabs_test.dart`. Pump the inspector panel with:

- `attachOffset == null` — assert Attach → Paint tab has reduced opacity and tapping it does not switch selection; placeholder widget is visible if selected by default.
- `attachOffset` set — assert Attach → Paint becomes enabled; switching to it renders the filtered waterfall.

### Manual / integration validation

- Load a prerender session in the example app; confirm JS eval spans show in Init → Attach.
- Load a preload session; confirm JS eval spans show in Attach → Paint.
- Verify FP / FCP / LCP milestones land in Attach → Paint in both modes.
- Verify summary cards above the sub-tabs show unchanged values across sub-tab selection.

## Open questions

None. All four design questions (sub-tab scope, allocation rule, time origin, empty-state behavior) resolved during brainstorming.
