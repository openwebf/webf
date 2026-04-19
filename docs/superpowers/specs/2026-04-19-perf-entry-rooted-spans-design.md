# Performance Recording: Entry-Rooted Span Model — Design

**Status**: Brainstormed, awaiting implementation plan
**Date**: 2026-04-19
**Branch**: `feat/perf-graph-redesign`
**Author**: Claude (with andycall)

---

## Goal

Replace WebF's hardcoded category enum (`JSSpanCategory` in C++ + `JSThreadSpan.categoryNames` + `WaterfallCategory` in Dart) with an **entry-rooted span model** in which every span tree is rooted at the call origin that triggered the work.

Today, spans are tagged with *what* they do (`styleRecalc`, `layout`, `paint`, `domConstruction`, `jsBindingSyncCall`). The new model preserves those labels as descriptive **child** subTypes while making *why* the work happened — the originating entry call (drawFrame, flushUICommand, jsTimer, imageLoadComplete, …) — the **root** of the tree. This mirrors Chrome DevTools' "Tasks" model: every slice of work has a root cause.

## Motivation

The current category model has two structural problems:

1. **It describes what, not why.** A `paint` span tells you painting happened, but not whether it was the result of a frame draw, a layout-invalidating binding call, a load handler, or a timer callback. Investigating "why is this paint expensive?" requires reading code, not the waterfall.

2. **It misses entries entirely.** New work added to the bridge (eg. the recently-shipped `kJSBindingSyncCall` for `el.style.src = '...'`) needs a hardcoded enum entry on both sides, a name in `categoryNames`, and a `WaterfallCategory` row, before it appears in the panel. Entries like `invokeBindingMethodFromNative`, `invokeModuleEvent`, image load handlers, network responses, and async callbacks don't exist as first-class concepts at all.

The fix is to invert the data model: entries are roots; categories survive only as descriptive child labels.

## Non-Goals

- Backwards compatibility with v4 profile JSON — old recordings are dev-only artifacts with no retention requirement.
- `causedBy` cross-tree correlation for async work — deferred (additive in a future revision).
- Compile-time gating of the profiler — runtime gating remains the only mode.
- Sampled mode — only revisit if measured overhead causes visible jank.
- Auto-instrumentation of arbitrary Flutter framework callbacks (`Future.then`, `Ticker`, `addPostFrameCallback`, etc.) — only WebF-named entries get instrumented.

---

## Design Decisions

### 1. Entry taxonomy: unified entry tree, WebF-relevant only

JS-thread entries (timer, RAF, microtask, FlushUICommand, ScriptEval) and Dart-thread entries (drawFrame, invokeBindingMethodFromNative, invokeModuleEvent, async loaders, network responses) all become roots in a **single unified entry tree**. Cross-thread work is parented honestly — eg. a binding-method call originating in a JS RAF callback becomes a child of the `jsRAF` entry.

Only **WebF-named** entries are instrumented. Generic Flutter framework callbacks (`Future.then`, `Ticker`, `addPostFrameCallback`) are not auto-treated as entries; they appear as `unattributed` roots if they trigger any WebF work, signalling missing instrumentation.

**Initial entry taxonomy**:

| Entry subType | Origin |
|---|---|
| `drawFrame` | Flutter `SchedulerBinding` draw entrypoint, Dart side |
| `flushUICommand` | UI command flush from C++ → Dart |
| `invokeBindingMethodFromNative` | C++ binding-method call into Dart |
| `invokeModuleEvent` | Module event dispatch path |
| `asyncCallback` | Dart-side async callback dispatcher |
| `imageLoadComplete` | Image loader response handler |
| `fontLoadComplete` | Font loader response handler |
| `scriptLoadComplete` | Script loader response handler |
| `networkResponse` | HTTP loader response handler |
| `htmlParse` | Loader-driven HTML parse |
| `cssParse` | Loader-driven CSS parse |
| `jsTimer` | JS-thread timer fire (synthesized when no Dart parent active) |
| `jsRAF` | JS-thread RAF callback |
| `jsMicrotask` | JS-thread microtask drain |
| `jsScriptEval` | JS-thread script evaluation |
| `unattributed` | `beginSpan` called outside any entry (production fallback) |

The list is open — adding a new entry subType requires only registering its display string in the constants file and the waterfall row-order list.

### 2. Span shape: root IS the entry (no separate `entrySource` field)

The span data model is unified across roots and children. A root span's `subType` IS the entry name; descendants carry descriptive subTypes (`styleRecalc`, `layout`, `paint`, etc.). UI groups by root subType to render swimlanes.

**Dart `PerformanceSpan`** (renamed/migrated):

```dart
class PerformanceSpan {
  final String subType;       // was: category. Free-form but constants-defined.
  final String name;          // optional refinement, e.g. 'flexLayout', 'setProperty(src)'
  final int startOffsetUs;
  int? endOffsetUs;
  final int depth;
  final PerformanceSpan? parent;
  final List<PerformanceSpan> children;
  Map<String, dynamic>? metadata;
  // No `entryName` field — root span IS the entry.
}
```

`subType` is open-ended at the type level (String) but constrained to a known taxonomy via Dart string constants in a shared file (`webf/lib/src/devtools/panel/performance_subtypes.dart`). Constants prevent typos; new entries are added by registering a new constant.

### 3. C++ side: Dart pushes `current_entry_id` via FFI

C++ profiler gains awareness of the active Dart entry but does not own entry semantics. A single `std::atomic<uint32_t> current_entry_id_{0}` is set/cleared from Dart via FFI when entries open and close. Each completed JS-thread span stamps the live value into its record at exit time.

**JS-thread spans with `entry_id == 0`** (fired with no Dart entry above — eg. a setTimeout firing while Dart is idle) become **roots themselves** at drain time, with `subType` synthesized from the C++ category enum (`jsTimer`, `jsRAF`, `jsMicrotask`, `jsScriptEval`).

**API additions**:

```cpp
// JSThreadProfiler instance methods
void SetCurrentEntryId(uint32_t entry_id);
uint32_t GetCurrentEntryId() const;

// FFI exports
WEBF_EXPORT_C void setJSProfilerCurrentEntryId(uint32_t entry_id);
WEBF_EXPORT_C uint32_t getJSProfilerCurrentEntryId();
```

`JSThreadSpan` struct grows by 4 bytes for `entry_id`. Hot-path cost: one relaxed atomic load + one struct write per `OnFunctionExit`. Disabled-path cost: zero (the FFI is gated on the Dart side by `tracker.enabled`; the C++ atomic is read only when the profiler is active).

**Concurrency**: JS thread is sole writer of spans. Dart isolate is sole writer of `current_entry_id_`. Atomic guarantees visibility. The "wrong entry stamped" race window is one JS function call wide — acceptable, since entry transitions happen at coarse boundaries.

### 4. Async entries: each completion is its own root

A delayed callback (image load, font load, script load, network response) becomes a new root entry — **not** a child of the originating call site. The originator's span ends cleanly when the request is queued; the wakeup is its own task.

This avoids spans crossing seconds of wall-clock idle time, removes the need for correlation IDs threaded through every async hop, and keeps the waterfall visually clean.

The cost — losing direct visibility into "what work did this `<img>` declaration ultimately cause?" — is acceptable. A future `causedBy` field can be added additively if cross-tree correlation becomes a frequent need.

Bare Dart `Future.then` continuations are NOT auto-treated as entries. They appear as spans inside whatever entry was active at await time, OR (if the entry already closed) become `unattributed` roots.

### 5. Waterfall UI: one row per entry type

The `WaterfallCategory` enum (20 values) is **deleted**. Rows are driven by entry subType, sorted by a fixed display order:

1. **Lifecycle group**: `drawFrame`, `attach` milestones (drawn from `phases`)
2. **Dart-thread entries** (in order): `flushUICommand`, `invokeBindingMethodFromNative`, `invokeModuleEvent`, `asyncCallback`, `imageLoadComplete`, `fontLoadComplete`, `scriptLoadComplete`, `networkResponse`, `htmlParse`, `cssParse`
3. **JS-thread-originated entries**: `jsTimer`, `jsRAF`, `jsMicrotask`, `jsScriptEval`
4. **`unattributed` row**: only shown if non-empty (signals missing instrumentation)

Each row aggregates that subType's root spans laid out chronologically as filled rectangles. Color per subType is fixed (lifecycle = blue family, JS = orange, network/loader = green, dom-mutation = purple). Click an entry rectangle → existing flame-chart drilldown opens with that root span's full subtree.

Phase split (`initToAttach` vs `attachToPaint`) is preserved unchanged — same rows, different time windows.

The row order list is a static const in the UI file. Adding a new entry subType requires registering it in that list.

### 6. Migration: tracker keeps current API; assert in dev when no entry active

Dart `_entryStack` becomes a stack of currently-open entry root spans. (C++ doesn't mirror this stack — it only holds the live `current_entry_id_` corresponding to the deepest open Dart entry.) Entry roots can nest (eg. `flushUICommand` inside `drawFrame`'s build phase) and the inner becomes a child span of the outer — preserving "what did this drawFrame trigger" attribution.

When a nested entry pops, Dart restores `current_entry_id_` to the outer entry's id via FFI. The bookkeeping cost is two FFI hops per entry (push + pop).

**Behavior when `beginSpan` is called outside any entry**:
- **Production**: silently promote to a root span with `subType = 'unattributed'` and the original subType moved to `name`. Keeps the panel useful while we iterate.
- **Dev** (`kDebugMode + tracker.enabled`): assert. Catches missing instrumentation early.

Existing 20 callsites of `beginSpan(category, name)` get their `category` arg renamed to subType constants. `beginAsyncSpan` callers (current `network`, `htmlParse`, `cssParse`, `jsEval`) are reviewed individually:
- Async completion handlers → promoted to `beginEntry`.
- Synchronous-nested inside another entry → demoted to `beginSpan`.

`beginAsyncSpan` itself is removed after the migration — making it compile-time impossible to forget classifying a callsite.

### 7. JSON v5: clean tree, hard-reject v4

```json
{
  "version": 5,
  "exportedAt": "2026-04-19T12:34:56.000Z",
  "sessionStart": 1745030400000000,
  "totalSpanCount": 1234,
  "rootSpans": [
    {
      "subType": "drawFrame",
      "name": "drawFrame#42",
      "startOffsetUs": 16000,
      "endOffsetUs": 32000,
      "depth": 0,
      "children": [
        {
          "subType": "flushUICommand",
          "name": "flushUICommand",
          "startOffsetUs": 16500,
          "endOffsetUs": 18000,
          "depth": 1,
          "children": [...]
        }
      ]
    }
  ],
  "phases": [...]
}
```

**Differences from v4**:
- `category` → `subType`
- `jsThreadSpans[]` flat array removed; JS spans live nested inside `rootSpans[]`
- `funcName`/`funcNameAtom` migrate into the regular span as the `name` field (atom resolution at drain time, not export time)
- No `entry_id` in JSON — the tree shape encodes attribution

**Import guard**: hard reject anything `version != 5` with `FormatException`. Same pattern as v3→v4 and v4→v5 transitions on this branch (commit `81e8589ab`).

**Drain-time grafting (Dart)**: when `drainJSThreadSpans` pulls from C++, each native span's `entry_id` is looked up against an `_entryIdToSpan` map. Entries are added to this map when pushed and **stay** until session reset — popping an entry does not remove its mapping, so JS spans drained after the entry has closed still graft correctly under the now-completed root.

Match → graft as child of the entry's deepest currently-leaf descendant whose interval contains the JS span's start. No match (`entry_id == 0` — JS work fired with no Dart entry above) → synthesize a new root span with `subType` derived from the C++ category enum (`jsTimer`, `jsRAF`, `jsMicrotask`, `jsScriptEval`).

The flat `jsThreadSpans` field on `PerformanceTracker` is deleted.

### 8. Performance overhead: single global enabled flag

Gating model unchanged from today: `tracker.enabled` is a single boolean checked first in every `beginSpan`/`beginEntry`. When false: no allocation, no FFI hop. C++ side mirrors with `enabled_.load()` first in `SetCurrentEntryId`.

Per-entry overhead when enabled: ~100ns FFI hop × 2 per entry. Per-span overhead unchanged from today. Deemed acceptable based on the existing profiler's measured overhead at production scale.

---

## Implementation strategy: phased over three PRs

| PR | Scope | User-visible? |
|---|---|---|
| **PR 1** | C++ side: `current_entry_id` push/pop API, FFI exports, `JSThreadSpan.entry_id` field, drain change | No (additive) |
| **PR 2** | Dart entry stack, `beginEntry` API, `_currentEntry` stack, all entry instrumentation sites added, all 20 existing callsites migrated to subType constants, `beginAsyncSpan` removed | No (UI still groups by old categories) |
| **PR 3** | JSON v5 schema, v4 hard-reject, `WaterfallCategory` enum deleted, waterfall row layout rewritten, drilldown subType-keyed | Yes — this is the visible flip |

Each PR is independently buildable, testable, and reviewable. PR 1 can soak before any UI churn; PR 2's assertions surface missed instrumentation; PR 3 ships the visible relayout cleanly.

---

## Test strategy

**PR 1 (C++)**:
- Unit test in `bridge/core/profiling/`: `SetCurrentEntryId`/`GetCurrentEntryId` round-trip, atomic visibility across threads, `OnFunctionExit` stamps live `current_entry_id_` into span record, no-op when disabled.
- Disabled-cost regression: micro-benchmark `OnFunctionEntry`/`OnFunctionExit` before/after to confirm no measurable delta.
- Existing `binding_name_registry_test.cc` and ring-buffer drain tests stay green.

**PR 2 (Dart entry stack)**:
- `webf/test/devtools/performance_tracker_test.dart`: nested `beginEntry` produces nested span tree (not sibling roots); `beginSpan` outside an entry asserts in dev when enabled, promotes to `unattributed` root in prod; entry stack popping correctly restores parent attribution.
- End-to-end: drive `flushUICommand` inside `drawFrame` with profiler enabled, assert tree shape `drawFrame > flushUICommand > domConstruction children`.
- Compile-time inventory: `beginAsyncSpan` API removed; every old callsite must be reclassified or it won't compile.

**PR 3 (JSON v5 + UI)**:
- JSON round-trip: export → import → export produces byte-identical output.
- v4 import rejection: feeding a v4 payload throws `FormatException` cleanly without mutating tracker state.
- Drain-time grafting: synthesize C++ JS spans with `entry_id` matching open Dart entries, assert they land as children; with unknown `entry_id`, assert they synthesize root spans of correct subType.
- Widget test: build a fixture tracker with one of each entry subType, assert each gets its own row, rows in fixed order, drilldown opens flame chart on click.

**Manual E2E verification (each PR)**:
- `npm run start`, enable profiler in DevTools, perform `el.style.src = '...'` interaction, verify expected entry rooting in waterfall.

**Build verification**: `npm run build:bridge:macos` after PR 1; `flutter analyze` + `flutter test` after each Dart PR.

---

## Open risks

- **Concurrent entries on JS vs Dart thread**: `current_entry_id_` is single-valued, but only Dart pushes/pops. JS thread reads the live value when stamping. Race window is one JS function wide — invisible in the waterfall. Acceptable.
- **Missed entry instrumentation in production**: manifests as a tall `unattributed` row. Visible signal, easy to triage. Dev assertions catch most cases pre-merge.
- **Breaking JSON v4**: documented in PR 3's description. No production retention requirement.

---

## Out of scope (future work)

- `causedBy` field for cross-tree async correlation — additive when needed.
- Sampled mode — only if measured jank requires it.
- Compile-time profiler gating — runtime gating remains sufficient.
- Auto-instrumentation of arbitrary Flutter framework callbacks.
