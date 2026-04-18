# Performance Waterfall Phase Sub-Tabs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the WebF DevTools Performance-tab waterfall into two sub-tabs (Init → Attach, Attach → Paint) that each render one side of the `attachToFlutter` boundary on a shared absolute time axis.

**Architecture:** Keep `buildWaterfallData()` unchanged — it still produces a single merged `WaterfallData`. Introduce a `WaterfallPhase` enum and a required `phase` parameter on `WaterfallChart`. The chart filters entries / milestones / frame boundaries by start time vs `data.attachOffset` at render time. In `inspector_panel.dart`, wrap the `WaterfallChart` site in a nested `DefaultTabController` with two tabs, each passing a different phase. When `attachOffset == null`, the Attach → Paint tab is non-interactive with a placeholder.

**Tech Stack:** Flutter / Dart — `TabBar`, `TabBarView`, `DefaultTabController`. No new dependencies. Tests use `flutter_test`.

**Reference spec:** `docs/superpowers/specs/2026-04-18-perf-waterfall-phase-subtabs-design.md`

---

## File Structure

| File | Role |
|---|---|
| `webf/lib/src/devtools/panel/waterfall_chart.dart` | Core chart widget. Adds `WaterfallPhase` enum, `phase` field, filter predicates, phase-constrained axis range, gated stage divider. |
| `webf/lib/src/devtools/panel/inspector_panel.dart` | Hosts sub-tab scaffolding around the `WaterfallChart` site (`_buildSingleControllerPerformance`). Owns persisted sub-tab index and the placeholder widget. |
| `webf/test/src/devtools/waterfall_phase_filter_test.dart` (new) | Unit tests for the filter predicates against synthetic `WaterfallData`. |
| `webf/test/src/devtools/perf_subtabs_test.dart` (new) | Widget test for sub-tab enable / disable behavior based on `attachOffset`. |

---

### Task 1: Add `WaterfallPhase` enum and `phase` field to `WaterfallChart`

**Files:**
- Modify: `webf/lib/src/devtools/panel/waterfall_chart.dart` (append enum after `WaterfallData`, add `phase` field to widget)

This task is a plumbing change — no behavior yet. We thread the new parameter through so later tasks can apply it.

- [ ] **Step 1: Add `WaterfallPhase` enum after `WaterfallData` class declaration**

At the end of `WaterfallData` class block (currently ends around line 128), add:

```dart
/// Which phase of the session the chart should render.
///
/// Phase boundary is `WaterfallData.attachOffset`. Entries, milestones and
/// frame boundaries are filtered by their start time vs `attachOffset`.
enum WaterfallPhase {
  /// `controller.load()` up to (and excluding) `attachToFlutter`.
  initToAttach,
  /// `attachToFlutter` onward, including FP / FCP / LCP and all post-attach work.
  attachToPaint,
}
```

- [ ] **Step 2: Add `phase` field to `WaterfallChart` widget**

Edit the `WaterfallChart` class (currently at line 786). Replace the existing declaration:

```dart
class WaterfallChart extends StatefulWidget {
  final LoadingState loadingState;
  final PerformanceTracker tracker;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;

  const WaterfallChart({
    super.key,
    required this.loadingState,
    required this.tracker,
    this.onToggleFullscreen,
    this.isFullscreen = false,
  });
```

With:

```dart
class WaterfallChart extends StatefulWidget {
  final LoadingState loadingState;
  final PerformanceTracker tracker;
  final WaterfallPhase phase;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;

  const WaterfallChart({
    super.key,
    required this.loadingState,
    required this.tracker,
    required this.phase,
    this.onToggleFullscreen,
    this.isFullscreen = false,
  });
```

- [ ] **Step 3: Update call sites to pass `phase`**

Find all call sites of `WaterfallChart(...)`:

```bash
grep -rn "WaterfallChart(" webf/lib webf/test
```

Expected call sites:
- `webf/lib/src/devtools/panel/inspector_panel.dart:2846` (main site)
- `webf/lib/src/devtools/panel/inspector_panel.dart` (fullscreen page constructor, near `_FullscreenWaterfallPage`)

For each call site, add `phase: WaterfallPhase.initToAttach,` temporarily. The real routing to both phases happens in Task 7. Example — at line 2846:

```dart
? WaterfallChart(
    loadingState: controller.loadingState,
    tracker: PerformanceTracker.instance,
    phase: WaterfallPhase.initToAttach,
    onToggleFullscreen: () {
      // ...
```

Also add the matching import in `inspector_panel.dart` if not already present:

```dart
import 'package:webf/src/devtools/panel/waterfall_chart.dart' show WaterfallChart, WaterfallPhase;
```

- [ ] **Step 4: Verify it compiles**

Run:

```bash
cd webf && flutter analyze lib/src/devtools/panel/waterfall_chart.dart lib/src/devtools/panel/inspector_panel.dart
```

Expected: no errors, no new warnings.

- [ ] **Step 5: Commit**

```bash
git add webf/lib/src/devtools/panel/waterfall_chart.dart webf/lib/src/devtools/panel/inspector_panel.dart
git commit -m "feat(devtools): add WaterfallPhase enum and phase field to WaterfallChart"
```

---

### Task 2: Write failing tests for the filter predicate

**Files:**
- Create: `webf/test/src/devtools/waterfall_phase_filter_test.dart`

- [ ] **Step 1: Write the test file**

Create `webf/test/src/devtools/waterfall_phase_filter_test.dart`:

```dart
/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/waterfall_chart.dart';

WaterfallEntry _entry(
    {required Duration start, required Duration end, String label = 'e'}) {
  return WaterfallEntry(
    category: WaterfallCategory.lifecycle,
    label: label,
    start: start,
    end: end,
  );
}

WaterfallMilestone _ms(Duration offset, [String label = 'm']) {
  return WaterfallMilestone(
      label: label, offset: offset, color: const Color(0xFF000000));
}

void main() {
  group('WaterfallPhase filter — includeEntry', () {
    test('attachOffset set: initToAttach includes start < attachOffset', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 100),
                  end: const Duration(milliseconds: 200)),
              WaterfallPhase.initToAttach,
              attach),
          isTrue);
    });

    test('attachOffset set: initToAttach excludes start >= attachOffset', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 500),
                  end: const Duration(milliseconds: 600)),
              WaterfallPhase.initToAttach,
              attach),
          isFalse);
    });

    test('attachOffset set: attachToPaint includes start >= attachOffset', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 500),
                  end: const Duration(milliseconds: 700)),
              WaterfallPhase.attachToPaint,
              attach),
          isTrue);
    });

    test('attachOffset set: attachToPaint excludes start < attachOffset', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 100),
                  end: const Duration(milliseconds: 600)),
              WaterfallPhase.attachToPaint,
              attach),
          isFalse);
    });

    test('cross-boundary entry stays in initToAttach (no clipping)', () {
      // Start 100ms (pre-attach), end 800ms (post-attach).
      final attach = const Duration(milliseconds: 500);
      final entry = _entry(
          start: const Duration(milliseconds: 100),
          end: const Duration(milliseconds: 800));
      expect(
          includeEntryForPhase(entry, WaterfallPhase.initToAttach, attach),
          isTrue);
      expect(
          includeEntryForPhase(entry, WaterfallPhase.attachToPaint, attach),
          isFalse);
      // Entry bounds are preserved — no mutation.
      expect(entry.start, const Duration(milliseconds: 100));
      expect(entry.end, const Duration(milliseconds: 800));
    });

    test('attachOffset null: initToAttach includes everything', () {
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 0),
                  end: const Duration(milliseconds: 100)),
              WaterfallPhase.initToAttach,
              null),
          isTrue);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 999),
                  end: const Duration(milliseconds: 1000)),
              WaterfallPhase.initToAttach,
              null),
          isTrue);
    });

    test('attachOffset null: attachToPaint includes nothing', () {
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 0),
                  end: const Duration(milliseconds: 100)),
              WaterfallPhase.attachToPaint,
              null),
          isFalse);
    });
  });

  group('WaterfallPhase filter — includeMilestone', () {
    test('attachOffset set: milestone at attachOffset belongs to attachToPaint',
        () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeMilestoneForPhase(
              _ms(attach), WaterfallPhase.attachToPaint, attach),
          isTrue);
      expect(
          includeMilestoneForPhase(
              _ms(attach), WaterfallPhase.initToAttach, attach),
          isFalse);
    });

    test('attachOffset null: only initToAttach includes milestones', () {
      expect(
          includeMilestoneForPhase(
              _ms(const Duration(milliseconds: 100)),
              WaterfallPhase.initToAttach,
              null),
          isTrue);
      expect(
          includeMilestoneForPhase(
              _ms(const Duration(milliseconds: 100)),
              WaterfallPhase.attachToPaint,
              null),
          isFalse);
    });
  });

  group('WaterfallPhase filter — includeFrameBoundary', () {
    test('attachOffset set: boundary at offset belongs to matching phase', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeFrameBoundaryForPhase(
              const Duration(milliseconds: 100),
              WaterfallPhase.initToAttach,
              attach),
          isTrue);
      expect(
          includeFrameBoundaryForPhase(
              const Duration(milliseconds: 600),
              WaterfallPhase.attachToPaint,
              attach),
          isTrue);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
cd webf && flutter test test/src/devtools/waterfall_phase_filter_test.dart
```

Expected: compilation failure — `includeEntryForPhase`, `includeMilestoneForPhase`, `includeFrameBoundaryForPhase` are undefined.

- [ ] **Step 3: Commit**

```bash
git add webf/test/src/devtools/waterfall_phase_filter_test.dart
git commit -m "test(devtools): add failing unit tests for WaterfallPhase filter predicates"
```

---

### Task 3: Implement the filter predicates

**Files:**
- Modify: `webf/lib/src/devtools/panel/waterfall_chart.dart` (add top-level functions near `WaterfallPhase` enum)

- [ ] **Step 1: Add predicate functions just below the `WaterfallPhase` enum**

Immediately after the `WaterfallPhase` enum declaration (added in Task 1), add:

```dart
/// Returns true if [entry] should appear in the given [phase].
///
/// Rule: entries are allocated by start time. When [attachOffset] is non-null,
/// entries with `start < attachOffset` live in [WaterfallPhase.initToAttach];
/// entries with `start >= attachOffset` live in [WaterfallPhase.attachToPaint].
/// Cross-boundary entries are not clipped — they stay in initToAttach and
/// their `end` is preserved even if it extends past the attach boundary.
///
/// When [attachOffset] is null (attach has not yet fired), all entries live
/// in [WaterfallPhase.initToAttach] and none in [WaterfallPhase.attachToPaint].
bool includeEntryForPhase(
    WaterfallEntry entry, WaterfallPhase phase, Duration? attachOffset) {
  if (attachOffset == null) {
    return phase == WaterfallPhase.initToAttach;
  }
  return phase == WaterfallPhase.initToAttach
      ? entry.start < attachOffset
      : entry.start >= attachOffset;
}

/// Returns true if [milestone] should appear in the given [phase].
///
/// Same rule as [includeEntryForPhase] but keyed on `milestone.offset`.
bool includeMilestoneForPhase(WaterfallMilestone milestone,
    WaterfallPhase phase, Duration? attachOffset) {
  if (attachOffset == null) {
    return phase == WaterfallPhase.initToAttach;
  }
  return phase == WaterfallPhase.initToAttach
      ? milestone.offset < attachOffset
      : milestone.offset >= attachOffset;
}

/// Returns true if a frame boundary at [offset] should appear in the given [phase].
bool includeFrameBoundaryForPhase(
    Duration offset, WaterfallPhase phase, Duration? attachOffset) {
  if (attachOffset == null) {
    return phase == WaterfallPhase.initToAttach;
  }
  return phase == WaterfallPhase.initToAttach
      ? offset < attachOffset
      : offset >= attachOffset;
}
```

- [ ] **Step 2: Run tests to verify they pass**

Run:

```bash
cd webf && flutter test test/src/devtools/waterfall_phase_filter_test.dart
```

Expected: all tests pass.

- [ ] **Step 3: Commit**

```bash
git add webf/lib/src/devtools/panel/waterfall_chart.dart
git commit -m "feat(devtools): implement WaterfallPhase filter predicates"
```

---

### Task 4: Apply filters to chart rendering pipeline

**Files:**
- Modify: `webf/lib/src/devtools/panel/waterfall_chart.dart`

The chart today builds its list of overview items from `data.entries` in `_getItems()` (line ~872) and reads `data.milestones` + `data.frameBoundaries` directly during paint. We apply the new `phase` filter at these three consumption points.

- [ ] **Step 1: Filter entries in `_getItems()`**

Find `_getItems(WaterfallData data)` (currently around line 872). Replace the line:

```dart
final filtered = data.entries
    .where((e) => _enabledCategories.contains(e.category))
    .toList();
```

With:

```dart
final filtered = data.entries
    .where((e) => _enabledCategories.contains(e.category))
    .where((e) => includeEntryForPhase(e, widget.phase, data.attachOffset))
    .toList();
```

Also update `_getItems()`'s cache-invalidation key so a phase change invalidates the cached items. Find the `_cachedFilterSet` field at the top of `_WaterfallChartState` (line ~846) and add a sibling:

```dart
WaterfallPhase? _cachedFilterPhase;
```

Then in `_getItems()`, replace the cache check:

```dart
if (_cachedItems != null && _setEquals(_cachedFilterSet, _enabledCategories)) {
  return _cachedItems!;
}
```

With:

```dart
if (_cachedItems != null &&
    _setEquals(_cachedFilterSet, _enabledCategories) &&
    _cachedFilterPhase == widget.phase) {
  return _cachedItems!;
}
```

And at the end of `_getItems()`, after `_cachedFilterSet = Set.from(_enabledCategories);`, add:

```dart
_cachedFilterPhase = widget.phase;
```

Also update the sub-header logic to respect phase. In `_getItems()` (lines ~887–908), the existing code emits `'Preload / Prerender'` and `'Display'` headers inside a single `Dart Thread` group when `attachOffset != null`. With the new design, each tab shows only one side — so the sub-headers are redundant. Replace the entire `if (dartEntries.isNotEmpty) { ... }` block with:

```dart
// Dart thread entries
if (dartEntries.isNotEmpty) {
  items.add(_OverviewItem.header('Dart Thread'));
  for (final entry in dartEntries) {
    items.add(_OverviewItem.entry(entry));
  }
}
```

- [ ] **Step 2: Filter milestones passed to the ruler painter**

Find the `_TimeRulerPainter` construction (line ~1526):

```dart
painter: _TimeRulerPainter(
  totalMs: totalMs,
  pixelsPerMs: pixelsPerMs,
  milestones: data.milestones,
  attachX: attachX,
  frameBoundaries: data.frameBoundaries,
),
```

Replace with:

```dart
painter: _TimeRulerPainter(
  totalMs: totalMs,
  pixelsPerMs: pixelsPerMs,
  milestones: data.milestones
      .where((m) =>
          includeMilestoneForPhase(m, widget.phase, data.attachOffset))
      .toList(),
  attachX: attachX,
  frameBoundaries: data.frameBoundaries
      .where((b) => includeFrameBoundaryForPhase(
          b, widget.phase, data.attachOffset))
      .toList(),
),
```

Search the file for any **other** uses of `data.milestones` or `data.frameBoundaries` (there may be additional painters that receive them):

```bash
grep -n "data.milestones\|data.frameBoundaries" webf/lib/src/devtools/panel/waterfall_chart.dart
```

For each additional reference, apply the same `.where(...)` filter. Common candidates: overview body painter, minimap painter, flame chart ruler.

- [ ] **Step 3: Verify compilation**

Run:

```bash
cd webf && flutter analyze lib/src/devtools/panel/waterfall_chart.dart
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add webf/lib/src/devtools/panel/waterfall_chart.dart
git commit -m "feat(devtools): apply WaterfallPhase filter to entries, milestones, and frame boundaries"
```

---

### Task 5: Constrain axis range per phase and suppress the in-chart stage divider

**Files:**
- Modify: `webf/lib/src/devtools/panel/waterfall_chart.dart`

Today the overview axis spans `[0, totalDuration]`. With sub-tabs, the visible range for each phase should be its half of the timeline — but x-coordinates stay in absolute time (ticks still show "time since load", matching the spec's Decision 3).

The existing stage-bar rendering (a one-time `_StageBarPainter` strip at line ~1541) becomes redundant — each tab now IS one side of the divider — so we suppress it.

- [ ] **Step 1: Compute a phase-constrained content width**

Find `_buildOverview(WaterfallData data)` (search for the function containing line 1496 — where `final totalMs = data.totalDuration.inMicroseconds / 1000.0;`).

Replace the computation block:

```dart
final totalMs = data.totalDuration.inMicroseconds / 1000.0;
final pixelsPerMs = _zoom * 2.0; // base: 2px per ms
final contentWidth = totalMs * pixelsPerMs;
```

With:

```dart
// Visible range for the current phase — absolute x remains unchanged so
// tick labels still show "time since load". Only the content width and the
// starting horizontal offset change per phase.
final Duration phaseStart;
final Duration phaseEnd;
switch (widget.phase) {
  case WaterfallPhase.initToAttach:
    phaseStart = Duration.zero;
    phaseEnd = data.attachOffset ?? data.totalDuration;
    break;
  case WaterfallPhase.attachToPaint:
    phaseStart = data.attachOffset ?? data.totalDuration;
    phaseEnd = data.totalDuration;
    break;
}
final phaseStartMs = phaseStart.inMicroseconds / 1000.0;
final phaseEndMs = phaseEnd.inMicroseconds / 1000.0;
final totalMs = phaseEndMs - phaseStartMs;
final pixelsPerMs = _zoom * 2.0; // base: 2px per ms
final contentWidth = math.max(totalMs * pixelsPerMs, 0.0);
```

- [ ] **Step 2: Translate absolute offsets into phase-local x**

Find the `attachX` computation (line ~1507):

```dart
final attachX = data.attachOffset != null
    ? data.attachOffset!.inMicroseconds / 1000.0 * pixelsPerMs
    : null;
```

Replace with:

```dart
// Stage-divider vertical line is redundant in sub-tab mode (each tab is
// one side of the divider). Passing null disables the in-chart divider
// rendering in both the ruler painter and the overview body painter.
final double? attachX = null;
```

Search this function and the file for any other usages of `data.attachOffset` in x-coordinate math, **including** anywhere that offsets a milestone or span into x pixels. Typical pattern:

```dart
final x = milestone.offset.inMicroseconds / 1000.0 * pixelsPerMs;
```

Change every such calculation to subtract `phaseStartMs`:

```dart
final x = (milestone.offset.inMicroseconds / 1000.0 - phaseStartMs) * pixelsPerMs;
```

The same shift applies to entry bars (`entry.start`, `entry.end`) and frame boundaries. Audit all painters that receive entries/milestones/boundaries and apply the shift at the point of pixel conversion. Tip: `pixelsPerMs` is the same; what changes is that every ms value must be `msSinceLoad - phaseStartMs` before multiplication.

If a painter receives raw `Duration` values and does the conversion internally (e.g. `_TimeRulerPainter`, `_OverviewBodyPainter`), thread `phaseStartMs` through as a constructor parameter:

```dart
class _TimeRulerPainter extends CustomPainter {
  final double totalMs;
  final double pixelsPerMs;
  final double phaseStartMs;      // <-- new
  final List<WaterfallMilestone> milestones;
  final double? attachX;
  final List<Duration> frameBoundaries;

  _TimeRulerPainter({
    required this.totalMs,
    required this.pixelsPerMs,
    required this.phaseStartMs,
    required this.milestones,
    this.attachX,
    required this.frameBoundaries,
  });
```

And inside `paint()`, shift every ms-to-x conversion:

```dart
// before
final x = milestone.offset.inMicroseconds / 1000.0 * pixelsPerMs;
// after
final x =
    (milestone.offset.inMicroseconds / 1000.0 - phaseStartMs) * pixelsPerMs;
```

Tick labels should **still** render absolute values (`phaseStartMs + localMs` as the displayed number), so only the x placement uses the shift. The label formatter already reads from `totalMs` (now local) — update tick label computation to display `phaseStartMs + localMs` rounded to whatever precision it uses.

Do the same threading for any other painter that consumes absolute Durations (overview body, minimap, flame ruler).

- [ ] **Step 3: Remove the stage-bar strip block**

Find the `// Stage bar (only for preload/prerender sessions)` block at line ~1540:

```dart
// Stage bar (only for preload/prerender sessions)
if (data.attachOffset != null)
  SizedBox(
    height: 16,
    child: Row(
      ...
      _StageBarPainter(
        attachX: attachX!,
        chartWidth: chartWidth,
      ),
      ...
    ),
  ),
```

Delete the entire `if (data.attachOffset != null) SizedBox(...)` widget. The strip was there to show a "Preload/Prerender | Display" label across the shared timeline — sub-tabs replace it.

`_StageBarPainter` itself becomes unused. Delete the class definition too (search the file for `class _StageBarPainter`). Run `flutter analyze` after to verify no dangling references.

- [ ] **Step 4: Verify compilation and existing tests still pass**

Run:

```bash
cd webf && flutter analyze lib/src/devtools/panel/waterfall_chart.dart
cd webf && flutter test test/src/devtools/waterfall_phase_filter_test.dart
```

Expected: no errors; filter tests still pass.

- [ ] **Step 5: Commit**

```bash
git add webf/lib/src/devtools/panel/waterfall_chart.dart
git commit -m "feat(devtools): constrain waterfall axis to phase range and remove stage bar"
```

---

### Task 6: Manual smoke test — single phase renders correctly

**Files:** none touched; this is a validation checkpoint.

- [ ] **Step 1: Run the example app**

```bash
npm run start
```

Launch a page that exercises preload or prerender mode so `attachToFlutter` fires after some pre-attach work.

- [ ] **Step 2: Open DevTools and navigate to Performance tab**

Currently both Task 1's temporary `phase: WaterfallPhase.initToAttach` call sites render only pre-attach work. Confirm:

- Lifecycle entries from `phaseInit` through `phaseAttachToFlutter` appear.
- Network requests that started pre-attach appear (cross-boundary ones extend past the right edge visually — expected).
- FP / FCP / LCP milestones do **not** appear in the chart (they live post-attach).
- No vertical stage-divider line is drawn.
- Axis tick labels show absolute times (e.g. 0ms, 100ms, …, 500ms if attach is at 500ms).

- [ ] **Step 3: Flip the temp call site to `WaterfallPhase.attachToPaint`**

Manually edit line 2846 to `phase: WaterfallPhase.attachToPaint,` and hot-reload. Confirm:

- Lifecycle entries are gone (or only the `attachToFlutter` sub-entry remains in the Lifecycle bar — acceptable, because the entry's start equals `attachOffset`).
- Post-attach layout / paint / style / build entries appear.
- FP / FCP / LCP milestones appear on the ruler.
- Axis tick labels start at `attachOffset` (absolute) rather than 0.

Restore the call site to `WaterfallPhase.initToAttach` before the commit below.

- [ ] **Step 4: Commit nothing — but record findings**

If anything looks wrong, fix it in `waterfall_chart.dart` and re-commit amending Task 4 or 5. Do not proceed to Task 7 until both phases render correctly in isolation.

---

### Task 7: Create the `PerformanceWaterfallSubTabs` widget

**Files:**
- Create: `webf/lib/src/devtools/panel/performance_waterfall_sub_tabs.dart`

Extract the sub-tab scaffolding as its own widget from the start. This keeps the file focused, makes the logic testable without spinning up the full inspector panel, and avoids a later refactor.

- [ ] **Step 1: Create the widget file**

Create `webf/lib/src/devtools/panel/performance_waterfall_sub_tabs.dart`:

```dart
/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/material.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/launcher/loading_state.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/waterfall_chart.dart';

/// Two sub-tabs that split the waterfall into Init → Attach and Attach → Paint.
///
/// When [attachOffset] is null, the Attach → Paint tab is rendered with reduced
/// opacity and taps are rejected; its body shows a "waiting for attach" placeholder.
class PerformanceWaterfallSubTabs extends StatefulWidget {
  final LoadingState loadingState;
  final PerformanceTracker tracker;
  final Duration? attachOffset;
  final void Function(WaterfallPhase phase)? onToggleFullscreen;

  /// Last-selected sub-tab index, persisted across widget rebuilds.
  /// Callers pass the same static int in both `initialIndex` and the
  /// `onIndexChanged` handler to keep the index sticky across the panel.
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  const PerformanceWaterfallSubTabs({
    super.key,
    required this.loadingState,
    required this.tracker,
    required this.attachOffset,
    this.onToggleFullscreen,
    this.initialIndex = 0,
    this.onIndexChanged,
  });

  @override
  State<PerformanceWaterfallSubTabs> createState() =>
      _PerformanceWaterfallSubTabsState();
}

class _PerformanceWaterfallSubTabsState
    extends State<PerformanceWaterfallSubTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex:
          widget.attachOffset != null ? widget.initialIndex.clamp(0, 1) : 0,
    );
  }

  @override
  void didUpdateWidget(covariant PerformanceWaterfallSubTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If attachOffset flips from null -> non-null, the disabled tab becomes
    // interactable; no index change needed. The reverse (non-null -> null)
    // can only happen on a new load, which typically destroys this widget
    // via parent rebuild. Defensive: if index is 1 and tab is now disabled,
    // jump back to 0.
    if (widget.attachOffset == null && _tabController.index == 1) {
      _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paintTabEnabled = widget.attachOffset != null;
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.blue,
          onTap: (index) {
            if (index == 1 && !paintTabEnabled) {
              _tabController.index = 0;
              return;
            }
            widget.onIndexChanged?.call(index);
          },
          tabs: [
            const Tab(
              child: Text('Init → Attach', style: TextStyle(fontSize: 12)),
            ),
            Tab(
              child: Opacity(
                opacity: paintTabEnabled ? 1.0 : 0.4,
                child: const Text('Attach → Paint',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const Divider(height: 1, color: Colors.white12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: paintTabEnabled
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: [
              WaterfallChart(
                loadingState: widget.loadingState,
                tracker: widget.tracker,
                phase: WaterfallPhase.initToAttach,
                onToggleFullscreen: widget.onToggleFullscreen == null
                    ? null
                    : () =>
                        widget.onToggleFullscreen!(WaterfallPhase.initToAttach),
              ),
              paintTabEnabled
                  ? WaterfallChart(
                      loadingState: widget.loadingState,
                      tracker: widget.tracker,
                      phase: WaterfallPhase.attachToPaint,
                      onToggleFullscreen: widget.onToggleFullscreen == null
                          ? null
                          : () => widget.onToggleFullscreen!(
                              WaterfallPhase.attachToPaint),
                    )
                  : const _AttachPendingPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachPendingPlaceholder extends StatelessWidget {
  const _AttachPendingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.hourglass_empty, color: Colors.white54, size: 32),
          SizedBox(height: 12),
          Text(
            'Waiting for attachToFlutter…',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            'Paint-phase data will appear once the controller is attached.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify the new file compiles**

```bash
cd webf && flutter analyze lib/src/devtools/panel/performance_waterfall_sub_tabs.dart
```

Expected: no errors. (The widget is not yet wired up anywhere, but its types must be self-consistent.)

- [ ] **Step 3: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_waterfall_sub_tabs.dart
git commit -m "feat(devtools): add PerformanceWaterfallSubTabs widget for phase split"
```

---

### Task 8: Wire `PerformanceWaterfallSubTabs` into the inspector panel

**Files:**
- Modify: `webf/lib/src/devtools/panel/inspector_panel.dart`

Replace the single `WaterfallChart` call with the new sub-tabs widget. Persist the selected sub-tab index and thread the fullscreen route through both phases.

- [ ] **Step 1: Add imports**

At the top of `inspector_panel.dart`, find the existing `waterfall_chart.dart` import (search for `waterfall_chart`). Replace it to also export `WaterfallPhase` and `buildWaterfallData`:

```dart
import 'package:webf/src/devtools/panel/waterfall_chart.dart'
    show WaterfallChart, WaterfallPhase, WaterfallData,
    buildWaterfallData;
import 'package:webf/src/devtools/panel/performance_waterfall_sub_tabs.dart';
```

(If the import is already a plain `import '…waterfall_chart.dart';` with no `show`, simply add the `performance_waterfall_sub_tabs.dart` import and leave the first alone.)

- [ ] **Step 2: Add the persisted sub-tab index static field**

Near the top of the inspector-panel state class (the class containing `static int _lastSelectedTabIndex = 0;` at line ~2080), add alongside it:

```dart
static int _lastSelectedPerfSubTabIndex = 0;
```

- [ ] **Step 3: Capture `attachOffset` at the top of `_buildSingleControllerPerformance`**

Inside `_buildSingleControllerPerformance(WebFController controller, String controllerName)` (line ~2743), immediately after the method signature `{`, add:

```dart
final waterfallData = buildWaterfallData(
    controller.loadingState, PerformanceTracker.instance);
final attachOffset = waterfallData.attachOffset;
```

(The child `WaterfallChart` caches its own copy internally. This one call is cheap; we only read `attachOffset` from it.)

- [ ] **Step 4: Replace the `WaterfallChart` call site with `PerformanceWaterfallSubTabs`**

Find the `Expanded(child: _showWaterfall ? WaterfallChart(...) : ...)` block (line ~2844). Replace the whole `WaterfallChart(...)` sub-expression (the one inside the `? :` ternary) with `_buildWaterfallSubTabs(controller, attachOffset)`:

```dart
Expanded(
  child: _showWaterfall
      ? _buildWaterfallSubTabs(controller, attachOffset)
      : SingleChildScrollView(
          child: _buildPerformanceMetrics(controller),
        ),
),
```

- [ ] **Step 5: Add the `_buildWaterfallSubTabs` and `_openFullscreenWaterfall` helpers**

Add these methods inside the same state class, adjacent to the other `_build*` helpers:

```dart
Widget _buildWaterfallSubTabs(
    WebFController controller, Duration? attachOffset) {
  return PerformanceWaterfallSubTabs(
    loadingState: controller.loadingState,
    tracker: PerformanceTracker.instance,
    attachOffset: attachOffset,
    initialIndex: _lastSelectedPerfSubTabIndex,
    onIndexChanged: (i) => _lastSelectedPerfSubTabIndex = i,
    onToggleFullscreen: (phase) =>
        _openFullscreenWaterfall(context, controller, phase),
  );
}

void _openFullscreenWaterfall(
    BuildContext context, WebFController controller, WaterfallPhase phase) {
  Navigator.of(context).pop();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _FullscreenWaterfallPage(
        loadingState: controller.loadingState,
        tracker: PerformanceTracker.instance,
        phase: phase,
      ),
    ),
  );
}
```

- [ ] **Step 6: Thread `phase` into `_FullscreenWaterfallPage`**

Find the `_FullscreenWaterfallPage` class (search `class _FullscreenWaterfallPage`). Add a `phase` field:

```dart
class _FullscreenWaterfallPage extends StatelessWidget {
  final LoadingState loadingState;
  final PerformanceTracker tracker;
  final WaterfallPhase phase;

  const _FullscreenWaterfallPage({
    required this.loadingState,
    required this.tracker,
    required this.phase,
  });
```

And pass it to the internal `WaterfallChart(...)` call in the page's `build` method:

```dart
WaterfallChart(
  loadingState: loadingState,
  tracker: tracker,
  phase: phase,
  isFullscreen: true,
  onToggleFullscreen: () => Navigator.of(context).pop(),
),
```

Also: any temporary `phase: WaterfallPhase.initToAttach,` stub inside the fullscreen page (from Task 1 Step 3) must be removed — `phase` is now a constructor argument.

- [ ] **Step 7: Verify compilation**

```bash
cd webf && flutter analyze lib/src/devtools/panel/inspector_panel.dart
```

Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add webf/lib/src/devtools/panel/inspector_panel.dart
git commit -m "feat(devtools): wire phase sub-tabs into inspector Performance tab"
```

---

### Task 9: Write widget test for sub-tab enable state

**Files:**
- Create: `webf/test/src/devtools/perf_subtabs_test.dart`

- [ ] **Step 1: Write the failing test file**

Create `webf/test/src/devtools/perf_subtabs_test.dart`:

```dart
/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/launcher/loading_state.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/performance_waterfall_sub_tabs.dart';

Widget _harness({required Duration? attachOffset, int initialIndex = 0}) {
  final loadingState = LoadingState();
  final tracker = PerformanceTracker.instance;
  return MaterialApp(
    home: Scaffold(
      body: PerformanceWaterfallSubTabs(
        loadingState: loadingState,
        tracker: tracker,
        attachOffset: attachOffset,
        initialIndex: initialIndex,
      ),
    ),
  );
}

void main() {
  testWidgets('both sub-tab labels are present', (tester) async {
    await tester.pumpWidget(_harness(attachOffset: null));
    expect(find.text('Init → Attach'), findsOneWidget);
    expect(find.text('Attach → Paint'), findsOneWidget);
  });

  testWidgets('Attach → Paint label is dimmed when attachOffset is null',
      (tester) async {
    await tester.pumpWidget(_harness(attachOffset: null));
    final opacityFinder = find.ancestor(
      of: find.text('Attach → Paint'),
      matching: find.byType(Opacity),
    );
    expect(opacityFinder, findsOneWidget);
    final opacity = tester.widget<Opacity>(opacityFinder);
    expect(opacity.opacity, 0.4);
  });

  testWidgets('tapping disabled Attach → Paint tab keeps index at 0',
      (tester) async {
    await tester.pumpWidget(_harness(attachOffset: null));
    await tester.tap(find.text('Attach → Paint'));
    await tester.pumpAndSettle();
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller!.index, 0);
  });

  testWidgets('disabled tab is not selectable via initialIndex',
      (tester) async {
    // Force-select index 1 via initialIndex; the widget should clamp to 0.
    await tester.pumpWidget(_harness(attachOffset: null, initialIndex: 1));
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller!.index, 0);
  });

  testWidgets('Attach → Paint label is full opacity when attachOffset is set',
      (tester) async {
    await tester.pumpWidget(
        _harness(attachOffset: const Duration(milliseconds: 500)));
    final opacityFinder = find.ancestor(
      of: find.text('Attach → Paint'),
      matching: find.byType(Opacity),
    );
    final opacity = tester.widget<Opacity>(opacityFinder);
    expect(opacity.opacity, 1.0);
  });
}
```

- [ ] **Step 2: Run the tests**

```bash
cd webf && flutter test test/src/devtools/perf_subtabs_test.dart
```

Expected: all five tests pass (the widget already exists from Task 7; these tests verify it behaves correctly).

- [ ] **Step 3: Run the full devtools test suite to catch regressions**

```bash
cd webf && flutter test test/src/devtools/
```

Expected: all tests pass. Any pre-existing devtools tests that construct `WaterfallChart` directly must now pass a `phase:` argument — if any fail, update them to pass `phase: WaterfallPhase.initToAttach` explicitly.

- [ ] **Step 4: Commit**

```bash
git add webf/test/src/devtools/perf_subtabs_test.dart
git commit -m "test(devtools): widget tests for phase sub-tab disabled-state behavior"
```

---

### Task 10: End-to-end manual validation

**Files:** none touched; validation checkpoint.

- [ ] **Step 1: Prerender-mode session**

```bash
npm run start
```

Load a page configured for `WebFLoadingMode.preRendering`. With DevTools open:

- Verify the Performance tab shows two sub-tabs: "Init → Attach" and "Attach → Paint".
- Select "Init → Attach": JS eval / HTML parse / DOM construction entries appear here (prerender evaluates pre-attach).
- Select "Attach → Paint": layout / paint / widget build entries appear; FP / FCP / LCP markers visible on the ruler.
- Neither tab shows the stage-divider vertical line in the chart body.
- Axis tick labels in both tabs read absolute times (t since `controller.load()`).

- [ ] **Step 2: Preload-mode session**

Load a page configured for `WebFLoadingMode.preloading`:

- "Init → Attach" shows only bytes-loaded / lifecycle spans (JS has not evaluated yet).
- "Attach → Paint" shows JS eval / HTML parse / DOM construction **plus** layout / paint / FP / FCP / LCP. This confirms time-based allocation handles preload-vs-prerender differences correctly.

- [ ] **Step 3: Pre-attach snapshot (controller loaded but not attached)**

If WebFControllerManager's preload flow lets you inspect the panel while a controller is preloaded-but-not-yet-attached:

- "Attach → Paint" label is dimmed (~0.4 opacity).
- Tapping "Attach → Paint" does not switch tabs.
- If forced to index 1, the placeholder with "Waiting for attachToFlutter…" renders.

- [ ] **Step 4: Toggle `_showWaterfall` (Metrics ↔ Waterfall) and back**

- Switching to Metrics view and back preserves the last-selected sub-tab.
- Switching top-level tabs (Controllers / Routes / …) and back also preserves it.

- [ ] **Step 5: Fullscreen**

- From either sub-tab, the fullscreen button navigates to `_FullscreenWaterfallPage` with the same `phase`.
- Back navigation returns to the same sub-tab.

- [ ] **Step 6: If any step fails**

Record the mismatch, fix in the relevant file, re-run the failing test, and commit the fix on top.

---

### Task 11: Cleanup pass

**Files:** any touched in prior tasks.

- [ ] **Step 1: Run analyzer over all touched files**

```bash
cd webf && flutter analyze \
  lib/src/devtools/panel/waterfall_chart.dart \
  lib/src/devtools/panel/inspector_panel.dart \
  lib/src/devtools/panel/performance_waterfall_sub_tabs.dart \
  test/src/devtools/waterfall_phase_filter_test.dart \
  test/src/devtools/perf_subtabs_test.dart
```

Expected: 0 errors, 0 new warnings.

- [ ] **Step 2: Run full test suite**

```bash
cd webf && flutter test
```

Expected: all tests pass. Failures here likely mean a previously-hidden assumption about `WaterfallChart` or `data.attachOffset` broke; investigate before proceeding.

- [ ] **Step 3: Remove dead code**

Search for `_StageBarPainter` (should be deleted by Task 5). Search for any references to `'Preload / Prerender'` or `'Display'` header strings left over from the old split logic.

```bash
grep -n "_StageBarPainter\|Preload / Prerender\|'  Display'" \
  webf/lib/src/devtools/panel/waterfall_chart.dart
```

Expected: no matches. If any appear, remove the stragglers and commit.

- [ ] **Step 4: Final commit (if any cleanup happened)**

```bash
git add webf/lib/src/devtools/panel/waterfall_chart.dart
git commit -m "chore(devtools): remove dead stage-divider code left over from sub-tab split"
```

---

## Summary of commits expected

1. Task 1: `feat(devtools): add WaterfallPhase enum and phase field to WaterfallChart`
2. Task 2: `test(devtools): add failing unit tests for WaterfallPhase filter predicates`
3. Task 3: `feat(devtools): implement WaterfallPhase filter predicates`
4. Task 4: `feat(devtools): apply WaterfallPhase filter to entries, milestones, and frame boundaries`
5. Task 5: `feat(devtools): constrain waterfall axis to phase range and remove stage bar`
6. Task 7: `feat(devtools): add PerformanceWaterfallSubTabs widget for phase split`
7. Task 8: `feat(devtools): wire phase sub-tabs into inspector Performance tab`
8. Task 9: `test(devtools): widget tests for phase sub-tab disabled-state behavior`
9. Task 11 (optional): `chore(devtools): remove dead stage-divider code left over from sub-tab split`
