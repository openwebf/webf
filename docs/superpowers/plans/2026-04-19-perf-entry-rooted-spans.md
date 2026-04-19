# Performance Recording: Entry-Rooted Span Model — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the closed `JSSpanCategory` / `WaterfallCategory` enum model with an entry-rooted span tree where every span has a root call origin (drawFrame, flushUICommand, jsTimer, etc.) and former categories survive as descriptive child subTypes.

**Architecture:** Three phased PRs. PR 1 adds a `current_entry_id` push/pop API to the C++ profiler and stamps it into every JS-thread span. PR 2 introduces the Dart entry stack (`beginEntry` API) and migrates all 14 existing `beginSpan` / 6 `beginAsyncSpan` callsites + adds new entry sites. PR 3 swaps the JSON schema to v5, deletes `WaterfallCategory`, and rewrites the waterfall layout to render one row per entry subType.

**Tech Stack:** C++17 (bridge), Dart 3 (webf), Flutter, gtest (C++ unit), `package:flutter_test` (Dart unit/widget), QuickJS profiler hooks.

**Reference spec:** `docs/superpowers/specs/2026-04-19-perf-entry-rooted-spans-design.md`

---

## File Structure

### PR 1 — Files modified/created

| File | Responsibility |
|---|---|
| `bridge/core/profiling/js_thread_profiler.h` | Add `current_entry_id_` atomic field, `SetCurrentEntryId`/`GetCurrentEntryId` methods, `entry_id` field on `JSThreadSpan` struct |
| `bridge/core/profiling/js_thread_profiler.cc` | Implement entry-id setter/getter, stamp on `OnFunctionExit`, clear in `Enable` |
| `bridge/include/webf_bridge.h` | Add FFI declarations for `setJSProfilerCurrentEntryId`, `getJSProfilerCurrentEntryId` |
| `bridge/webf_bridge.cc` | Implement FFI exports |
| `bridge/core/profiling/entry_id_test.cc` (NEW) | gtest covering set/get round-trip, atomic visibility, stamp on exit, no-op when disabled |
| `bridge/test/test.cmake` | Register `entry_id_test.cc` in unit-test list |

### PR 2 — Files modified/created

| File | Responsibility |
|---|---|
| `webf/lib/src/devtools/panel/performance_subtypes.dart` (NEW) | String constants for all entry & child subTypes |
| `webf/lib/src/devtools/panel/performance_tracker.dart` | Add `_entryStack`, `beginEntry()` / `EntryHandle`, `_entryIdToSpan` map, dev-mode assert; `category` field stays for now |
| `webf/lib/src/bridge/to_native.dart` | Add `setJSProfilerCurrentEntryId` FFI binding; promote `flushUICommand` span to entry; reclassify `evaluateScripts`/`evaluateByteCode`/`evaluateModule`/`parseHTML` async spans |
| `webf/lib/src/bridge/binding_object.dart` | Wrap `_invokeBindingMethodFromNativeImpl` in `beginEntry` |
| `webf/lib/src/bridge/ui_command.dart` | Migrate `beginSpan('domConstruction', 'execUICommands', …)` arg to constant |
| `webf/lib/src/widget/webf.dart` | Migrate `beginSpan('build', 'buildRootView', …)` arg to constant |
| `webf/lib/src/rendering/flex.dart` | Migrate `beginSpan('layout', 'flexLayout')` arg to constant |
| `webf/lib/src/rendering/flow.dart` | Migrate `beginSpan('layout', 'flowLayout')` arg to constant |
| `webf/lib/src/rendering/box_model.dart` | Migrate `beginSpan('paint', 'paint')` arg to constant |
| `webf/lib/src/dom/element.dart` | Migrate two `beginSpan('styleRecalc', …)` args to constant |
| `webf/lib/src/dom/element_widget_adapter.dart` | Migrate `beginSpan('build', 'buildElement', …)` arg to constant |
| `webf/lib/src/dom/document.dart` | Migrate `beginSpan('styleFlush', 'flushStyle')` arg to constant |
| `webf/lib/src/css/style_declaration.dart` | Migrate `beginSpan('styleApply', …)` arg to constant |
| `webf/lib/src/html/head.dart` | Two `beginSpan` migrations + promote `fetchCSS` async span to entry |
| `webf/lib/src/html/img.dart` | Promote `fetchImage` async span to entry |
| `webf/lib/src/launcher/view_controller.dart` | Wrap `flushPendingCommandsPerFrame` body in `beginEntry('drawFrame', …)` |
| `webf/test/src/devtools/performance_tracker_test.dart` (NEW) | Dart unit tests for nested entries, dev assert, promote-to-root in prod, FFI stamping mock |
| `webf/test/webf_test.dart` | Register `performance_tracker_test.dart` |

### PR 3 — Files modified/created

| File | Responsibility |
|---|---|
| `webf/lib/src/devtools/panel/performance_tracker.dart` | Rename `category` → `subType` on `PerformanceSpan`; bump `version` to 5; reject v4 import; rewrite `drainJSThreadSpans` as graft-into-tree using `_entryIdToSpan`; delete `jsThreadSpans` flat list and `JSThreadSpan.categoryNames` |
| `webf/lib/src/bridge/native_types.dart` | Add `entryId` field on `NativeJSThreadSpan` struct |
| `webf/lib/src/devtools/panel/waterfall_chart.dart` | Delete `WaterfallCategory` enum; add row-order constants list; rewrite `_buildWaterfallDataImpl` to walk `tracker.rootSpans` keyed by `subType`; remove `jsSpans` field on `WaterfallEntry` (now embedded in tree) |
| `webf/test/src/devtools/performance_tracker_v5_test.dart` (NEW) | JSON v5 round-trip, v4 reject, drain-time grafting tests |
| `webf/test/src/devtools/waterfall_chart_test.dart` (NEW) | Widget test: fixture tracker → row count/order asserts; subType drilldown opens |

---

# PR 1 — C++ entry-id plumbing

Goal: C++ profiler can be told "you're inside Dart entry X" and stamps that id into every JS-thread span. Disabled-path cost unchanged. No Dart consumers yet.

---

### Task 1.1: Add `entry_id` field to `JSThreadSpan` struct

**Files:**
- Modify: `bridge/core/profiling/js_thread_profiler.h:37-43`

- [ ] **Step 1: Modify the `JSThreadSpan` struct definition**

In `bridge/core/profiling/js_thread_profiler.h`, replace lines 36-43:

```cpp
// Span stored in the ring buffer (completed spans only)
struct JSThreadSpan {
  uint8_t category;
  int64_t start_us;       // microseconds from profiler session start
  int64_t end_us;
  uint32_t func_name_atom; // JSAtom for function name (0 = anonymous)
  uint8_t depth;
  uint32_t entry_id;       // Dart-owned entry id active at span exit (0 = none)
};
```

- [ ] **Step 2: Build to verify struct change compiles**

Run: `npm run build:bridge:macos`
Expected: success. (Existing call sites that write `span.category`/`span.start_us`/etc. are unaffected; no read sites exist for `entry_id` yet.)

- [ ] **Step 3: Commit**

```bash
git add bridge/core/profiling/js_thread_profiler.h
git commit -m "feat(profiler): add entry_id field to JSThreadSpan struct"
```

---

### Task 1.2: Add `current_entry_id_` atomic and accessor methods to `JSThreadProfiler`

**Files:**
- Modify: `bridge/core/profiling/js_thread_profiler.h` (add to private members + public API)
- Modify: `bridge/core/profiling/js_thread_profiler.cc` (implement methods, init in `Enable`)

- [ ] **Step 1: Add public method declarations after `IsAtomKnown` (around line 85)**

In `bridge/core/profiling/js_thread_profiler.h`, after the existing `bool IsAtomKnown(JSAtom atom) const;` line:

```cpp
  // Set/clear the active Dart entry id. Called from Dart via FFI when an
  // entry root is pushed/popped. Stamped into JSThreadSpan.entry_id at span
  // exit time. id 0 means "no entry active".
  void SetCurrentEntryId(uint32_t entry_id);
  uint32_t GetCurrentEntryId() const;
```

- [ ] **Step 2: Add private member after `enabled_` (around line 96)**

In `bridge/core/profiling/js_thread_profiler.h`, after the `std::atomic<bool> enabled_{false};` line:

```cpp
  std::atomic<uint32_t> current_entry_id_{0};
```

- [ ] **Step 3: Implement methods in the .cc file**

In `bridge/core/profiling/js_thread_profiler.cc`, add after `IsAtomKnown` (around line 102):

```cpp
void JSThreadProfiler::SetCurrentEntryId(uint32_t entry_id) {
  current_entry_id_.store(entry_id, std::memory_order_relaxed);
}

uint32_t JSThreadProfiler::GetCurrentEntryId() const {
  return current_entry_id_.load(std::memory_order_relaxed);
}
```

- [ ] **Step 4: Reset `current_entry_id_` in `Enable`**

In `bridge/core/profiling/js_thread_profiler.cc`, add inside the existing `Enable` method (after `binding_names_.clear();` on line 25, before the `for` loop):

```cpp
  current_entry_id_.store(0, std::memory_order_relaxed);
```

- [ ] **Step 5: Build to verify**

Run: `npm run build:bridge:macos`
Expected: success.

- [ ] **Step 6: Commit**

```bash
git add bridge/core/profiling/js_thread_profiler.h bridge/core/profiling/js_thread_profiler.cc
git commit -m "feat(profiler): add SetCurrentEntryId / GetCurrentEntryId"
```

---

### Task 1.3: Stamp `current_entry_id_` into spans on exit

**Files:**
- Modify: `bridge/core/profiling/js_thread_profiler.cc:142-153` (the section of `OnFunctionExit` that writes to the ring buffer)

- [ ] **Step 1: Modify ring-buffer write to include `entry_id`**

In `bridge/core/profiling/js_thread_profiler.cc`, replace the block starting "// Write to ring buffer" through `write_pos_++;` (lines 142-151) with:

```cpp
  // Write to ring buffer
  int32_t buf_idx = write_pos_ % kMaxSpans;
  auto& span = buffer_[buf_idx];
  span.category = entry.category;
  span.start_us = entry.start_us;
  span.end_us = end_us;
  span.func_name_atom = entry.func_name_atom;
  span.depth = entry.depth;
  span.entry_id = current_entry_id_.load(std::memory_order_relaxed);

  write_pos_++;
```

- [ ] **Step 2: Build to verify**

Run: `npm run build:bridge:macos`
Expected: success.

- [ ] **Step 3: Commit**

```bash
git add bridge/core/profiling/js_thread_profiler.cc
git commit -m "feat(profiler): stamp current_entry_id into JSThreadSpan on exit"
```

---

### Task 1.4: Write failing C++ unit test for entry-id behavior

**Files:**
- Create: `bridge/core/profiling/entry_id_test.cc`
- Modify: `bridge/test/test.cmake:36` (insert new test file in the list)

- [ ] **Step 1: Create the test file**

Create `bridge/core/profiling/entry_id_test.cc`:

```cpp
/*
 * Copyright (C) 2026-present The OpenWebF authors. All rights reserved.
 */

#include <gtest/gtest.h>
#include "core/profiling/js_thread_profiler.h"

namespace webf {

TEST(EntryId, DefaultsToZero) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  EXPECT_EQ(0u, p.GetCurrentEntryId());
  p.Disable();
}

TEST(EntryId, SetAndGetRoundtrip) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  p.SetCurrentEntryId(42);
  EXPECT_EQ(42u, p.GetCurrentEntryId());
  p.SetCurrentEntryId(0);
  EXPECT_EQ(0u, p.GetCurrentEntryId());
  p.Disable();
}

TEST(EntryId, EnableResetsToZero) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  p.SetCurrentEntryId(99);
  p.Disable();
  p.Enable();
  EXPECT_EQ(0u, p.GetCurrentEntryId()) << "Enable must reset entry id";
  p.Disable();
}

TEST(EntryId, StampedIntoSpanOnExit) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable(/*min_duration_us=*/0);  // no filter so test span is recorded
  p.SetCurrentEntryId(7);
  int32_t idx = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(idx, 0);
  p.OnFunctionExit(idx);

  JSThreadSpan out[1];
  int32_t count = p.DrainSpans(out, 1);
  ASSERT_EQ(1, count);
  EXPECT_EQ(7u, out[0].entry_id);
  p.Disable();
}

TEST(EntryId, ZeroStampWhenNoEntryActive) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable(/*min_duration_us=*/0);
  // do not call SetCurrentEntryId — should default to 0
  int32_t idx = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(idx, 0);
  p.OnFunctionExit(idx);

  JSThreadSpan out[1];
  int32_t count = p.DrainSpans(out, 1);
  ASSERT_EQ(1, count);
  EXPECT_EQ(0u, out[0].entry_id);
  p.Disable();
}

}  // namespace webf
```

- [ ] **Step 2: Register the test in CMake**

In `bridge/test/test.cmake`, replace line 36 (the existing `./core/profiling/binding_name_registry_test.cc` line) with:

```cmake
  ./core/profiling/binding_name_registry_test.cc
  ./core/profiling/entry_id_test.cc
```

- [ ] **Step 3: Run the test, verify it passes**

Run: `node scripts/run_bridge_unit_test.js`
Expected: all `EntryId.*` tests pass alongside existing tests. (Tests don't need to fail-first because the implementation already lives in Tasks 1.1–1.3.)

- [ ] **Step 4: Commit**

```bash
git add bridge/core/profiling/entry_id_test.cc bridge/test/test.cmake
git commit -m "test(profiler): cover SetCurrentEntryId + entry_id stamping"
```

---

### Task 1.5: Add C FFI exports for `setJSProfilerCurrentEntryId` / `getJSProfilerCurrentEntryId`

**Files:**
- Modify: `bridge/include/webf_bridge.h:177-182` (after existing JS profiler block)
- Modify: `bridge/webf_bridge.cc:385-388` (after existing `getJSProfilerAtomName`)

- [ ] **Step 1: Add FFI declarations to header**

In `bridge/include/webf_bridge.h`, replace the existing JS Thread Profiling block (lines 176-183) with:

```cpp
// JS Thread Profiling
WEBF_EXPORT_C void setJSThreadProfilingEnabled(int8_t enabled, int64_t min_duration_us);
WEBF_EXPORT_C int64_t getJSProfilerSessionStartUs();
WEBF_EXPORT_C int64_t getSteadyClockNowUs();
WEBF_EXPORT_C int32_t drainJSThreadProfilingSpans(void* out_spans, int32_t max_spans);
WEBF_EXPORT_C int8_t isJSThreadProfilingEnabled();
WEBF_EXPORT_C const char* getJSProfilerAtomName(uint32_t atom);
WEBF_EXPORT_C void setJSProfilerCurrentEntryId(uint32_t entry_id);
WEBF_EXPORT_C uint32_t getJSProfilerCurrentEntryId();

#endif  // WEBF_BRIDGE_EXPORT_H
```

- [ ] **Step 2: Implement FFI exports in webf_bridge.cc**

In `bridge/webf_bridge.cc`, append after the closing `}` of `getJSProfilerAtomName` (after line 388):

```cpp
void setJSProfilerCurrentEntryId(uint32_t entry_id) {
  webf::JSThreadProfiler::Instance().SetCurrentEntryId(entry_id);
}

uint32_t getJSProfilerCurrentEntryId() {
  return webf::JSThreadProfiler::Instance().GetCurrentEntryId();
}
```

- [ ] **Step 3: Build to verify**

Run: `npm run build:bridge:macos`
Expected: success — symbols `_setJSProfilerCurrentEntryId` and `_getJSProfilerCurrentEntryId` appear in `libwebf.dylib`.

- [ ] **Step 4: Verify symbols present**

Run: `nm bridge/build/macos/lib/x86_64/libwebf.dylib 2>/dev/null | grep -E 'setJSProfilerCurrentEntryId|getJSProfilerCurrentEntryId'`
Expected: two lines, both with `T` (defined symbol).

- [ ] **Step 5: Commit**

```bash
git add bridge/include/webf_bridge.h bridge/webf_bridge.cc
git commit -m "feat(bridge): export setJSProfilerCurrentEntryId / getJSProfilerCurrentEntryId C FFI"
```

---

### Task 1.6: Update `NativeJSThreadSpan` Dart struct to add `entryId` field

**Files:**
- Modify: `webf/lib/src/bridge/native_types.dart:46-61`

- [ ] **Step 1: Add `entryId` field to the FFI struct**

In `webf/lib/src/bridge/native_types.dart`, replace lines 44-61 with:

```dart
// Matches C++ JSThreadSpan in js_thread_profiler.h
// Note: struct padding means category (uint8) is followed by 7 bytes padding before start_us (int64)
final class NativeJSThreadSpan extends Struct {
  @Uint8()
  external int category;

  @Int64()
  external int startUs;

  @Int64()
  external int endUs;

  @Uint32()
  external int funcNameAtom;

  @Uint8()
  external int depth;

  @Uint32()
  external int entryId;
}
```

- [ ] **Step 2: Verify Dart still analyzes**

Run: `cd webf && flutter analyze lib/src/bridge/native_types.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add webf/lib/src/bridge/native_types.dart
git commit -m "feat(bridge): add entryId field to NativeJSThreadSpan FFI struct"
```

---

### Task 1.7: PR 1 — manual smoke verification

- [ ] **Step 1: Build everything together**

Run: `npm run build:bridge:macos`
Expected: success.

- [ ] **Step 2: Run all bridge unit tests**

Run: `node scripts/run_bridge_unit_test.js`
Expected: all tests pass including new `EntryId.*` block.

- [ ] **Step 3: Open PR 1**

PR description should mention: no user-visible change; adds Dart-callable API to push/pop entry id, stamps on every JS-thread span exit; future PRs consume this. Reference spec: `docs/superpowers/specs/2026-04-19-perf-entry-rooted-spans-design.md`.

---

# PR 2 — Dart entry stack + migration

Goal: Dart owns an entry stack, `beginEntry()` API exists, all 14 `beginSpan` callsites migrated to `kSubType*` constants, all 6 `beginAsyncSpan` callsites reclassified, `beginAsyncSpan` removed, new entry sites instrumented (drawFrame, flushUICommand, invokeBindingMethod, image/font/script/network loaders). Waterfall UI unchanged in this PR.

---

### Task 2.1: Create the subType constants file

**Files:**
- Create: `webf/lib/src/devtools/panel/performance_subtypes.dart`

- [ ] **Step 1: Create the file with all subType constants**

Create `webf/lib/src/devtools/panel/performance_subtypes.dart`:

```dart
/*
 * Copyright (C) 2026-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

/// Canonical string constants for [PerformanceSpan.subType].
///
/// Root spans (entries) describe *why* work happened. Child spans describe
/// *what* happened. Both share the subType namespace — the distinction is
/// structural (root vs nested) not type-level.
library;

// --- Entry subTypes (root spans, describe call origin) ---

// Lifecycle
const String kSubTypeDrawFrame = 'drawFrame';

// Dart-thread entries
const String kSubTypeFlushUICommand = 'flushUICommand';
const String kSubTypeInvokeBindingMethodFromNative = 'invokeBindingMethodFromNative';
const String kSubTypeInvokeModuleEvent = 'invokeModuleEvent';
const String kSubTypeAsyncCallback = 'asyncCallback';
const String kSubTypeImageLoadComplete = 'imageLoadComplete';
const String kSubTypeFontLoadComplete = 'fontLoadComplete';
const String kSubTypeScriptLoadComplete = 'scriptLoadComplete';
const String kSubTypeNetworkResponse = 'networkResponse';
const String kSubTypeHtmlParse = 'htmlParse';
const String kSubTypeCssParse = 'cssParse';
const String kSubTypeEvaluateScripts = 'evaluateScripts';
const String kSubTypeEvaluateByteCode = 'evaluateByteCode';
const String kSubTypeEvaluateModule = 'evaluateModule';

// JS-thread origins (synthesized at drain time when no Dart parent)
const String kSubTypeJsTimer = 'jsTimer';
const String kSubTypeJsRAF = 'jsRAF';
const String kSubTypeJsMicrotask = 'jsMicrotask';
const String kSubTypeJsScriptEval = 'jsScriptEval';
const String kSubTypeJsEvent = 'jsEvent';
const String kSubTypeJsIdle = 'jsIdle';
const String kSubTypeJsMutationObserver = 'jsMutationObserver';
const String kSubTypeJsFunction = 'jsFunction';
const String kSubTypeJsCFunction = 'jsCFunction';
const String kSubTypeJsFlushUICommand = 'jsFlushUICommand';
const String kSubTypeJsBindingSyncCall = 'jsBindingSyncCall';

// Fallback when beginSpan fires outside any entry (production)
const String kSubTypeUnattributed = 'unattributed';

// --- Child subTypes (descriptive labels for nested spans) ---

const String kSubTypeBuild = 'build';
const String kSubTypeStyleRecalc = 'styleRecalc';
const String kSubTypeStyleFlush = 'styleFlush';
const String kSubTypeStyleApply = 'styleApply';
const String kSubTypeLayout = 'layout';
const String kSubTypePaint = 'paint';
const String kSubTypeDomConstruction = 'domConstruction';

/// Maps the C++ JSSpanCategory enum value (matches kJSFunction=0 ... kJSBindingSyncCall=10)
/// to the entry subType to synthesize when a JS span has entry_id == 0.
const List<String> kJsCategorySubTypes = [
  kSubTypeJsFunction,           // 0: kJSFunction
  kSubTypeJsCFunction,          // 1: kJSCFunction
  kSubTypeJsScriptEval,         // 2: kJSScriptEval
  kSubTypeJsTimer,              // 3: kJSTimer
  kSubTypeJsEvent,              // 4: kJSEvent
  kSubTypeJsRAF,                // 5: kJSRAF
  kSubTypeJsIdle,               // 6: kJSIdle
  kSubTypeJsMicrotask,          // 7: kJSMicrotask
  kSubTypeJsMutationObserver,   // 8: kJSMutationObserver
  kSubTypeJsFlushUICommand,     // 9: kJSFlushUICommand
  kSubTypeJsBindingSyncCall,    // 10: kJSBindingSyncCall
];
```

- [ ] **Step 2: Analyze**

Run: `cd webf && flutter analyze lib/src/devtools/panel/performance_subtypes.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_subtypes.dart
git commit -m "feat(devtools): add subType constants for entry-rooted spans"
```

---

### Task 2.2: Add Dart FFI binding for `setJSProfilerCurrentEntryId`

**Files:**
- Modify: `webf/lib/src/bridge/to_native.dart:875` (after `getSteadyClockNowUs`)

- [ ] **Step 1: Insert FFI binding after `getSteadyClockNowUs`**

In `webf/lib/src/bridge/to_native.dart`, insert after line 884 (the closing brace of `getSteadyClockNowUs`):

```dart
typedef NativeSetJSProfilerCurrentEntryId = Void Function(Uint32);
typedef DartSetJSProfilerCurrentEntryId = void Function(int);

final DartSetJSProfilerCurrentEntryId _setJSProfilerCurrentEntryId =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeSetJSProfilerCurrentEntryId>>('setJSProfilerCurrentEntryId').asFunction();

void setJSProfilerCurrentEntryId(int entryId) {
  _setJSProfilerCurrentEntryId(entryId);
}
```

- [ ] **Step 2: Analyze**

Run: `cd webf && flutter analyze lib/src/bridge/to_native.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add webf/lib/src/bridge/to_native.dart
git commit -m "feat(bridge): add setJSProfilerCurrentEntryId Dart FFI binding"
```

---

### Task 2.3: Add `_entryStack`, `beginEntry`, `EntryHandle` to `PerformanceTracker`

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart` — add `EntryHandle` class, `_entryStack` field, `_nextEntryId` counter, `_entryIdToSpan` map, `beginEntry()` method
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:259-281` (`startSession`) — clear new fields
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:283-296` (`endSession`) — close any open entries

- [ ] **Step 1: Add `EntryHandle` class after `AsyncPerformanceSpanHandle`**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, insert after the closing `}` of `AsyncPerformanceSpanHandle` (line 189):

```dart
/// Handle returned by [PerformanceTracker.beginEntry] to end an entry root.
///
/// Ending an entry pops it from the entry stack and clears (or restores)
/// the C++ profiler's current_entry_id. Child spans opened between
/// beginEntry/end auto-attribute to the entry via the existing _currentSpan
/// stack.
class EntryHandle {
  final PerformanceSpan _root;
  final PerformanceTracker _tracker;
  final int _entryId;
  final int _previousEntryId;

  EntryHandle._(this._root, this._tracker, this._entryId, this._previousEntryId);

  void end({Map<String, dynamic>? metadata}) {
    _root.endOffsetUs = _tracker.nowOffsetUs();
    if (metadata != null) {
      _root.metadata = (_root.metadata ?? {})..addAll(metadata);
    }
    _tracker._popEntry(_root, _previousEntryId);
  }
}
```

- [ ] **Step 2: Add private fields to `PerformanceTracker`**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, after the `PerformanceSpan? _currentSpan;` line (around line 239), insert:

```dart
  /// Stack of currently-open entry root spans. Mirrors the depth that the
  /// C++ profiler is aware of via current_entry_id_.
  final List<PerformanceSpan> _entryStack = [];

  /// Map from entry id → root span. Entries are added on push and stay
  /// until session reset (popping does NOT remove), so JS spans drained
  /// after the entry has closed still graft correctly.
  final Map<int, PerformanceSpan> _entryIdToSpan = {};

  /// Monotonic entry-id allocator. Reset to 1 on session start (0 reserved
  /// for "no entry active").
  int _nextEntryId = 1;
```

- [ ] **Step 3: Reset new fields in `startSession`**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, inside `startSession` after `enabled = true;` (around line 265), insert:

```dart
    _entryStack.clear();
    _entryIdToSpan.clear();
    _nextEntryId = 1;
    to_native.setJSProfilerCurrentEntryId(0);
```

- [ ] **Step 4: Close open entries in `endSession`**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, replace the body of `endSession` (lines 284-296) with:

```dart
  void endSession() {
    enabled = false;
    // Drain any remaining JS spans before tearing down state
    drainJSThreadSpans();
    // Disable C++ JS thread profiling
    to_native.setJSThreadProfilingEnabled(false);
    to_native.setJSProfilerCurrentEntryId(0);
    // Close any unclosed spans using the monotonic clock.
    final nowUs = nowOffsetUs();
    while (_currentSpan != null) {
      _currentSpan!.endOffsetUs ??= nowUs;
      _currentSpan = _currentSpan!.parent;
    }
    _entryStack.clear();
  }
```

- [ ] **Step 5: Add `beginEntry` method and `_popEntry` private helper**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, insert after the existing `beginAsyncSpan` method (after line 437, before `int get totalSpanCount`):

```dart
  /// Begin a new entry root.
  ///
  /// Pushes a fresh root span onto [rootSpans], registers an entry id with
  /// the C++ profiler so JS-thread spans drained later can be grafted under
  /// this root, and sets the entry as the active call-stack head.
  ///
  /// Entries can nest — eg. flushUICommand inside drawFrame's build phase.
  /// The inner becomes a child span of the outer (not a sibling root) so
  /// that "what work did this drawFrame trigger" attribution is preserved.
  ///
  /// Returns null when tracking is disabled or the span limit is reached.
  EntryHandle? beginEntry(String subType, String name,
      {Map<String, dynamic>? metadata}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;
    final anchor = sessionStart;
    if (anchor == null) return null;

    final root = PerformanceSpan(
      category: subType,
      name: name,
      startOffsetUs: nowOffsetUs(),
      depth: (_currentSpan != null) ? _currentSpan!.depth + 1 : 0,
      sessionAnchor: anchor,
      parent: _currentSpan,
      metadata: metadata,
    );

    if (_currentSpan != null) {
      _currentSpan!.children.add(root);
    } else {
      rootSpans.add(root);
    }

    final entryId = _nextEntryId++;
    final previousEntryId = _entryStack.isEmpty
        ? 0
        : _entryIdMap[_entryStack.last] ?? 0;
    _entryIdToSpan[entryId] = root;
    _entryIdMap[root] = entryId;
    _entryStack.add(root);
    _currentSpan = root;
    _totalSpanCount++;

    to_native.setJSProfilerCurrentEntryId(entryId);

    return EntryHandle._(root, this, entryId, previousEntryId);
  }

  /// Reverse-lookup map: span → entry id. Used by [_popEntry] to find the
  /// id corresponding to the parent entry being restored.
  final Map<PerformanceSpan, int> _entryIdMap = {};

  void _popEntry(PerformanceSpan root, int previousEntryId) {
    if (_entryStack.isNotEmpty && identical(_entryStack.last, root)) {
      _entryStack.removeLast();
    } else {
      // Out-of-order pop (defensive — shouldn't happen with sane handle usage).
      _entryStack.remove(root);
    }
    _currentSpan = root.parent;
    to_native.setJSProfilerCurrentEntryId(previousEntryId);
    // Note: do NOT remove from _entryIdToSpan — JS spans drained later may
    // still need to graft under this completed root.
  }
```

- [ ] **Step 6: Verify analyze**

Run: `cd webf && flutter analyze lib/src/devtools/panel/performance_tracker.dart`
Expected: no errors.

- [ ] **Step 7: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_tracker.dart
git commit -m "feat(devtools): add entry stack + beginEntry API to PerformanceTracker"
```

---

### Task 2.4: Add dev-mode assertion when `beginSpan` is called outside any entry

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:382-407` (`beginSpan` method)

- [ ] **Step 1: Modify `beginSpan` to assert in dev when no entry is open**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, replace the `beginSpan` method body (lines 382-407) with:

```dart
  PerformanceSpanHandle? beginSpan(String category, String name,
      {Map<String, dynamic>? metadata}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;
    final anchor = sessionStart;
    if (anchor == null) return null;

    // Dev-mode contract: every span should live under an entry. In
    // production we silently promote to root with subType `unattributed`
    // and the original category moved into the name field, so the panel
    // stays useful while we iterate. In dev (assertions enabled) we
    // surface the missing instrumentation immediately.
    String effectiveCategory = category;
    String effectiveName = name;
    if (_entryStack.isEmpty) {
      assert(false,
          'beginSpan called outside any entry: $category/$name. '
          'Wrap the call site in tracker.beginEntry(...) or use the '
          'unattributed subType explicitly.');
      effectiveCategory = 'unattributed';
      effectiveName = '$category/$name';
    }

    final span = PerformanceSpan(
      category: effectiveCategory,
      name: effectiveName,
      startOffsetUs: nowOffsetUs(),
      depth: (_currentSpan != null) ? _currentSpan!.depth + 1 : 0,
      sessionAnchor: anchor,
      parent: _currentSpan,
      metadata: metadata,
    );

    if (_currentSpan != null) {
      _currentSpan!.children.add(span);
    } else {
      rootSpans.add(span);
    }

    _currentSpan = span;
    _totalSpanCount++;
    return PerformanceSpanHandle._(span, this);
  }
```

- [ ] **Step 2: Verify analyze**

Run: `cd webf && flutter analyze lib/src/devtools/panel/performance_tracker.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_tracker.dart
git commit -m "feat(devtools): assert in dev when beginSpan fires outside any entry"
```

---

### Task 2.5: Wrap `flushUICommand` with `beginEntry`

**Files:**
- Modify: `webf/lib/src/bridge/to_native.dart:925-945` (`flushUICommand` function)

- [ ] **Step 1: Replace the existing `beginSpan('domConstruction', 'flushUICommand', …)` with `beginEntry`**

In `webf/lib/src/bridge/to_native.dart`, replace lines 936-939 (the three lines `List<UICommand> commands = …;` through `handle?.end();`) with:

```dart
  List<UICommand> commands = nativeUICommandToDartFFI(view.contextId);
  final entry = PerformanceTracker.instance.beginEntry(
      kSubTypeFlushUICommand, 'flushUICommand',
      metadata: {'commandCount': commands.length});
  execUICommands(view, commands);
  entry?.end();
```

- [ ] **Step 2: Add the import for the constants**

In `webf/lib/src/bridge/to_native.dart`, near the top with other webf imports, add:

```dart
import 'package:webf/src/devtools/panel/performance_subtypes.dart';
```

- [ ] **Step 3: Verify analyze**

Run: `cd webf && flutter analyze lib/src/bridge/to_native.dart`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add webf/lib/src/bridge/to_native.dart
git commit -m "feat(devtools): promote flushUICommand span to entry root"
```

---

### Task 2.6: Wrap `_invokeBindingMethodFromNativeImpl` with `beginEntry`

**Files:**
- Modify: `webf/lib/src/bridge/binding_object.dart:368-419`

- [ ] **Step 1: Add the constants import near other webf imports**

In `webf/lib/src/bridge/binding_object.dart`, add (with existing imports near top):

```dart
import 'package:webf/src/devtools/panel/performance_subtypes.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
```

(If `performance_tracker.dart` import already exists, only add `performance_subtypes.dart`.)

- [ ] **Step 2: Wrap the body in a beginEntry**

In `webf/lib/src/bridge/binding_object.dart`, replace the body of `_invokeBindingMethodFromNativeImpl` (lines 371-418) with:

```dart
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;

  // Make sure the dart object related to nativeBindingObject had been created.
  flushUICommand(controller.view, nullptr);

  dynamic method = fromNativeValue(controller.view, nativeMethod);
  List<dynamic> values = List.generate(argc, (i) {
    Pointer<NativeValue> nativeValue = argv + i;
    return fromNativeValue(controller.view, nativeValue);
  });

  BindingObject bindingObject = controller.view.getBindingObject(nativeBindingObject);

  // Open an entry so all Dart work below this point attributes back to the
  // call origin in the waterfall (eg. setProperty(src) → fetchImage subspan).
  final entryName = method is String ? method : 'op#$method';
  final entry = PerformanceTracker.instance
      .beginEntry(kSubTypeInvokeBindingMethodFromNative, entryName);

  dynamic result;
  try {
    // Method is binding call method operations from internal.
    if (method is int) {
      // Get and setter ops
      result = bindingCallMethodDispatchTable[method](bindingObject, values);
    } else {
      BindingObject bindingObject = controller.view.getBindingObject(nativeBindingObject);
      // invokeBindingMethod directly
      Stopwatch? stopwatch;
      if (enableWebFCommandLog) {
        stopwatch = Stopwatch()..start();
      }

      result = _callBindingObjectMethods(bindingObject, method, values);

      if (result is Future) {
        result = await result;
      }

      if (enableWebFCommandLog) {
        bridgeLogger.fine(
            '$bindingObject invokeBindingMethod method: $method args: $values result: $result time: ${stopwatch!.elapsedMicroseconds}us');
      }
    }
  } catch (e, stack) {
    bridgeLogger.severe('Error in invokeBindingMethod', e, stack);
    rethrow;
  } finally {
    if (result is Future) {
      result = await result;
    }
    toNativeValue(returnValue, result, bindingObject);
    entry?.end();
  }
```

- [ ] **Step 3: Verify analyze**

Run: `cd webf && flutter analyze lib/src/bridge/binding_object.dart`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add webf/lib/src/bridge/binding_object.dart
git commit -m "feat(devtools): wrap invokeBindingMethodFromNative in entry root"
```

---

### Task 2.7: Wrap `flushPendingCommandsPerFrame` (drawFrame entry)

**Files:**
- Modify: `webf/lib/src/launcher/view_controller.dart:106-111`

- [ ] **Step 1: Add the constants and tracker imports near other webf imports**

In `webf/lib/src/launcher/view_controller.dart`, add (with existing imports near top):

```dart
import 'package:webf/src/devtools/panel/performance_subtypes.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
```

(Skip whichever already exist.)

- [ ] **Step 2: Wrap the body of `flushPendingCommandsPerFrame` in a `beginEntry`**

In `webf/lib/src/launcher/view_controller.dart`, replace lines 106-111 (the `flushPendingCommandsPerFrame` method) with:

```dart
  void flushPendingCommandsPerFrame() {
    if (disposed && _isFrameBindingAttached) return;
    _isFrameBindingAttached = true;
    final entry = PerformanceTracker.instance.beginEntry(kSubTypeDrawFrame, 'drawFrame');
    flushUICommand(this, window.pointer!);
    entry?.end();
    SchedulerBinding.instance.addPostFrameCallback((_) => flushPendingCommandsPerFrame());
  }
```

- [ ] **Step 3: Verify analyze**

Run: `cd webf && flutter analyze lib/src/launcher/view_controller.dart`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add webf/lib/src/launcher/view_controller.dart
git commit -m "feat(devtools): wrap per-frame flush in drawFrame entry root"
```

---

### Task 2.8: Migrate the 11 plain `beginSpan` callsites to subType constants

**Files:**
- Modify: `webf/lib/src/bridge/ui_command.dart:101`
- Modify: `webf/lib/src/widget/webf.dart:609`
- Modify: `webf/lib/src/rendering/flex.dart:784`
- Modify: `webf/lib/src/rendering/flow.dart:205`
- Modify: `webf/lib/src/rendering/box_model.dart:1355`
- Modify: `webf/lib/src/dom/element.dart:1166,1186`
- Modify: `webf/lib/src/dom/element_widget_adapter.dart:168`
- Modify: `webf/lib/src/dom/document.dart:564`
- Modify: `webf/lib/src/css/style_declaration.dart:484`
- Modify: `webf/lib/src/html/head.dart:282,478`

For each file: add `import 'package:webf/src/devtools/panel/performance_subtypes.dart';` at the top (if not already present) and replace the literal string in the first arg of `beginSpan(...)` with the matching constant.

- [ ] **Step 1: Migrate `webf/lib/src/bridge/ui_command.dart:101`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('domConstruction', 'execUICommands', metadata: {'commandCount': commands.length});
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeDomConstruction, 'execUICommands', metadata: {'commandCount': commands.length});
```

Add the import at top of file.

- [ ] **Step 2: Migrate `webf/lib/src/widget/webf.dart:609`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('build', 'buildRootView', metadata: {'initialRoute': initialRoute});
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeBuild, 'buildRootView', metadata: {'initialRoute': initialRoute});
```

Add the import at top of file.

- [ ] **Step 3: Migrate `webf/lib/src/rendering/flex.dart:784`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('layout', 'flexLayout');
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeLayout, 'flexLayout');
```

Add the import at top of file.

- [ ] **Step 4: Migrate `webf/lib/src/rendering/flow.dart:205`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('layout', 'flowLayout');
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeLayout, 'flowLayout');
```

Add the import at top of file.

- [ ] **Step 5: Migrate `webf/lib/src/rendering/box_model.dart:1355`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('paint', 'paint');
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypePaint, 'paint');
```

Add the import at top of file.

- [ ] **Step 6: Migrate `webf/lib/src/dom/element.dart:1166`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('styleRecalc', 'applyStyle', metadata: {'tagName': tagName});
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeStyleRecalc, 'applyStyle', metadata: {'tagName': tagName});
```

- [ ] **Step 7: Migrate `webf/lib/src/dom/element.dart:1186`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('styleRecalc', 'recalculateStyle', metadata: {'tagName': tagName});
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeStyleRecalc, 'recalculateStyle', metadata: {'tagName': tagName});
```

Add the import at top of file (one import covers both step 6 and 7).

- [ ] **Step 8: Migrate `webf/lib/src/dom/element_widget_adapter.dart:168`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('build', 'buildElement',
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeBuild, 'buildElement',
```

Add the import at top of file.

- [ ] **Step 9: Migrate `webf/lib/src/dom/document.dart:564`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('styleFlush', 'flushStyle');
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeStyleFlush, 'flushStyle');
```

Add the import at top of file.

- [ ] **Step 10: Migrate `webf/lib/src/css/style_declaration.dart:484`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('styleApply', 'flushPendingProperties', metadata: {'propertyCount': _pendingProperties.length});
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeStyleApply, 'flushPendingProperties', metadata: {'propertyCount': _pendingProperties.length});
```

Add the import at top of file.

- [ ] **Step 11: Migrate `webf/lib/src/html/head.dart:282`**

Replace:
```dart
final parseHandle = PerformanceTracker.instance.beginSpan('cssParse', 'parseStylesheet', metadata: {'url': href});
```
with:
```dart
final parseHandle = PerformanceTracker.instance.beginSpan(kSubTypeCssParse, 'parseStylesheet', metadata: {'url': href});
```

- [ ] **Step 12: Migrate `webf/lib/src/html/head.dart:478`**

Replace:
```dart
final handle = PerformanceTracker.instance.beginSpan('cssParse', 'parseInlineStyle');
```
with:
```dart
final handle = PerformanceTracker.instance.beginSpan(kSubTypeCssParse, 'parseInlineStyle');
```

Add the import at top of file (covers both step 11 and 12).

- [ ] **Step 13: Verify analyze across all touched files**

Run: `cd webf && flutter analyze lib/`
Expected: no errors.

- [ ] **Step 14: Commit**

```bash
git add \
  webf/lib/src/bridge/ui_command.dart \
  webf/lib/src/widget/webf.dart \
  webf/lib/src/rendering/flex.dart \
  webf/lib/src/rendering/flow.dart \
  webf/lib/src/rendering/box_model.dart \
  webf/lib/src/dom/element.dart \
  webf/lib/src/dom/element_widget_adapter.dart \
  webf/lib/src/dom/document.dart \
  webf/lib/src/css/style_declaration.dart \
  webf/lib/src/html/head.dart
git commit -m "refactor(devtools): migrate beginSpan callsites to subType constants"
```

---

### Task 2.9: Reclassify the 6 `beginAsyncSpan` callsites + remove `beginAsyncSpan` API

**Files:**
- Modify: `webf/lib/src/html/img.dart:661` — promote `fetchImage` async span to `beginEntry(kSubTypeImageLoadComplete, …)` at completion handler (NOT at the call site that queues the fetch — keep that as a child span if needed)
- Modify: `webf/lib/src/bridge/to_native.dart:339,427,458,527` — promote four async spans to entries (`evaluateScripts`, `evaluateByteCode`, `evaluateModule`, `parseHTML`)
- Modify: `webf/lib/src/html/head.dart:271` — promote `fetchCSS` async span to `beginEntry(kSubTypeNetworkResponse, …)` at the response handler
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart` — delete `beginAsyncSpan` and `AsyncPerformanceSpanHandle`

The four `evaluate*` and `parseHTML` spans live in `to_native.dart` as wrappers around C++ FFI calls. They are entry origins — the FFI is the call boundary into webf — so promote them to `beginEntry`.

- [ ] **Step 1: Migrate `webf/lib/src/bridge/to_native.dart:339` (evaluateScripts)**

Open the file, find the line:
```dart
final handle = PerformanceTracker.instance.beginAsyncSpan('jsEval', 'evaluateScripts', metadata: {'url': url, 'size': codeBytes.length});
```
and find the matching `handle?.end()` later in the same function. Replace with:
```dart
final entry = PerformanceTracker.instance.beginEntry(kSubTypeEvaluateScripts, url, metadata: {'size': codeBytes.length});
```
and at the matching close site:
```dart
entry?.end();
```

- [ ] **Step 2: Migrate `webf/lib/src/bridge/to_native.dart:427` (evaluateByteCode)**

Same pattern: replace `beginAsyncSpan('jsEval', 'evaluateByteCode', …)` with `beginEntry(kSubTypeEvaluateByteCode, 'evaluateByteCode', metadata: {'size': bytes.length})`. Update its `handle?.end()` to `entry?.end()`.

- [ ] **Step 3: Migrate `webf/lib/src/bridge/to_native.dart:458` (evaluateModule)**

Replace `beginAsyncSpan('jsEval', 'evaluateModule', …)` with `beginEntry(kSubTypeEvaluateModule, url, metadata: {'size': codeBytes.length})`. Update close site.

- [ ] **Step 4: Migrate `webf/lib/src/bridge/to_native.dart:527` (parseHTML)**

Replace `beginAsyncSpan('htmlParse', 'parseHTML', …)` with `beginEntry(kSubTypeHtmlParse, 'parseHTML', metadata: {'size': codeBytes.length})`. Update close site.

- [ ] **Step 5: Migrate `webf/lib/src/html/img.dart:661` (fetchImage)**

Replace:
```dart
final handle = PerformanceTracker.instance.beginAsyncSpan('network', 'fetchImage', metadata: {'url': url.toString()});
```
with:
```dart
final entry = PerformanceTracker.instance.beginEntry(kSubTypeImageLoadComplete, url.toString());
```
Update the matching `handle?.end()` to `entry?.end()`. Add the constants import to the top of the file.

- [ ] **Step 6: Migrate `webf/lib/src/html/head.dart:271` (fetchCSS)**

Replace:
```dart
final fetchHandle = PerformanceTracker.instance.beginAsyncSpan('network', 'fetchCSS', metadata: {'url': url});
```
with:
```dart
final fetchEntry = PerformanceTracker.instance.beginEntry(kSubTypeNetworkResponse, url, metadata: {'kind': 'css'});
```
Update the matching `fetchHandle?.end()` to `fetchEntry?.end()`. (Constants import was already added in Task 2.8.)

- [ ] **Step 7: Delete `beginAsyncSpan` and `AsyncPerformanceSpanHandle` from the tracker**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, delete the entire `AsyncPerformanceSpanHandle` class (lines 178-189) and the entire `beginAsyncSpan` method (lines 409-437). Also delete any `import` lines that become unused.

- [ ] **Step 8: Verify analyze (all `beginAsyncSpan` references must be gone)**

Run: `cd webf && flutter analyze lib/`
Expected: no errors. If any error like "Method 'beginAsyncSpan' isn't defined" appears, you missed a callsite — find it via `grep -rn beginAsyncSpan webf/lib`.

- [ ] **Step 9: Commit**

```bash
git add \
  webf/lib/src/bridge/to_native.dart \
  webf/lib/src/html/img.dart \
  webf/lib/src/html/head.dart \
  webf/lib/src/devtools/panel/performance_tracker.dart
git commit -m "refactor(devtools): replace beginAsyncSpan with beginEntry; delete AsyncPerformanceSpanHandle"
```

---

### Task 2.10: Wrap `invokeModuleEvent` with `beginEntry`

**Files:**
- Modify: `webf/lib/src/bridge/to_native.dart:161-192` (`invokeModuleEvent` function)

- [ ] **Step 1: Wrap the FFI call in `beginEntry`**

In `webf/lib/src/bridge/to_native.dart`, modify the `scheduleMicrotask` body (around lines 181-189) to:

```dart
  scheduleMicrotask(() {
    if (controller.view.disposed) {
      callbackContext.completer.complete(null);
      return;
    }

    final entry = PerformanceTracker.instance
        .beginEntry(kSubTypeInvokeModuleEvent, moduleName);
    try {
      _invokeModuleEvent(_allocatedPages[contextId]!, nativeModuleName,
          event == null ? nullptr : event.type.toNativeUtf8(), rawEvent, extraData, callbackContext, callback);
    } finally {
      entry?.end();
    }
  });
```

- [ ] **Step 2: Verify analyze**

Run: `cd webf && flutter analyze lib/src/bridge/to_native.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add webf/lib/src/bridge/to_native.dart
git commit -m "feat(devtools): wrap invokeModuleEvent dispatch in entry root"
```

---

### Task 2.11: Write Dart unit tests for entry stack + beginEntry semantics

**Files:**
- Create: `webf/test/src/devtools/performance_tracker_test.dart`
- Modify: `webf/test/webf_test.dart` (register the test file in the test group)

- [ ] **Step 1: Create the test file**

Create `webf/test/src/devtools/performance_tracker_test.dart`:

```dart
/*
 * Copyright (C) 2026-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/performance_subtypes.dart';

void main() {
  group('PerformanceTracker entry stack', () {
    setUp(() {
      // Each test gets a fresh session. We can't construct PerformanceTracker
      // because it's a singleton, but startSession resets all state including
      // _entryStack, _entryIdToSpan, _nextEntryId.
      PerformanceTracker.instance.startSession();
    });

    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('nested beginEntry produces nested span tree (not sibling roots)', () {
      final outer = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      expect(outer, isNotNull);
      expect(PerformanceTracker.instance.rootSpans.length, 1);

      final inner = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      expect(inner, isNotNull);

      // Inner must be a CHILD of outer, not a sibling root.
      expect(PerformanceTracker.instance.rootSpans.length, 1,
          reason: 'inner entry must not appear as a sibling root');
      final outerRoot = PerformanceTracker.instance.rootSpans.first;
      expect(outerRoot.children.length, 1);
      expect(outerRoot.children.first.category, kSubTypeFlushUICommand);

      inner!.end();
      outer!.end();
    });

    test('beginSpan inside an entry attributes to that entry', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      final child = PerformanceTracker.instance
          .beginSpan(kSubTypePaint, 'paint');
      expect(child, isNotNull);

      final root = PerformanceTracker.instance.rootSpans.first;
      expect(root.children.length, 1);
      expect(root.children.first.category, kSubTypePaint);

      child!.end();
      entry!.end();
    });

    test('beginSpan outside any entry asserts in dev', () {
      expect(
        () => PerformanceTracker.instance.beginSpan(kSubTypePaint, 'paint'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('endSession closes any unclosed entries', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      expect(entry, isNotNull);
      // Note: endSession is called in tearDown, so we check state after it.
      PerformanceTracker.instance.endSession();
      final root = PerformanceTracker.instance.rootSpans.first;
      expect(root.endOffsetUs, isNotNull,
          reason: 'open entry must be closed when session ends');
      // Restart so tearDown's endSession doesn't double-fail
      PerformanceTracker.instance.startSession();
    });

    test('popping inner entry restores _currentSpan to outer entry', () {
      final outer = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      final inner = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      inner!.end();

      // Now beginSpan should attribute to OUTER, not become a sibling root.
      final child = PerformanceTracker.instance
          .beginSpan(kSubTypePaint, 'paint');
      expect(child, isNotNull);

      final root = PerformanceTracker.instance.rootSpans.first;
      // root.children = [flushUICommand (closed), paint]
      expect(root.children.length, 2);
      expect(root.children[1].category, kSubTypePaint);

      child!.end();
      outer!.end();
    });
  });
}
```

- [ ] **Step 2: Register the test in `webf_test.dart`**

In `webf/test/webf_test.dart`, locate the import section and the `main()` group structure. Add the import:

```dart
import 'src/devtools/performance_tracker_test.dart' as performance_tracker_test;
```

And inside the appropriate group invocation in `main()`, add:

```dart
  group('PerformanceTracker', performance_tracker_test.main);
```

(If `webf_test.dart` does not exist or uses a different aggregator pattern, run the test directly via the next step.)

- [ ] **Step 3: Run tests, verify they pass**

Run: `cd webf && flutter test test/src/devtools/performance_tracker_test.dart`
Expected: all 5 tests pass.

- [ ] **Step 4: Commit**

```bash
git add webf/test/src/devtools/performance_tracker_test.dart webf/test/webf_test.dart
git commit -m "test(devtools): cover entry stack semantics in PerformanceTracker"
```

---

### Task 2.12: PR 2 — manual smoke verification

- [ ] **Step 1: Build the bridge**

Run: `npm run build:bridge:macos`
Expected: success.

- [ ] **Step 2: Run all Dart unit tests**

Run: `cd webf && flutter test`
Expected: all tests pass (existing + new performance_tracker tests).

- [ ] **Step 3: Run analyze**

Run: `cd webf && flutter analyze`
Expected: no errors.

- [ ] **Step 4: Open the example app and exercise profiling**

Run: `npm run start`
Open DevTools → Performance panel, start recording, perform `el.style.src = '...'` interaction, stop recording. Inspect the JSON export from `/var/folders/.../webf_profile_*.json`. Verify:

- Root spans now include `drawFrame`, `flushUICommand`, `invokeBindingMethodFromNative` entries.
- `domConstruction`/`paint`/`styleRecalc` spans appear nested under their parent entries (not as roots).
- The waterfall UI continues to render (categories still match because `category` field is still in use).

- [ ] **Step 5: Open PR 2**

PR description should mention: introduces entry-rooted span tree on the Dart side; UI grouping unchanged for now (PR 3 will do the visible flip); JSON v4 still in use.

---

# PR 3 — JSON v5 + UI relayout

Goal: bump JSON to v5 with hard reject of v4, rename `category` → `subType` on `PerformanceSpan`, drain JS spans as a tree (graft via `entry_id`), delete `WaterfallCategory`, rewrite waterfall layout to one-row-per-entry-subType.

---

### Task 3.1: Rename `category` → `subType` on `PerformanceSpan`

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart` — `PerformanceSpan` class (lines 30-154), `toJson`, `fromJson`, `rootSpansForCategory` rename
- Modify: every consumer (waterfall_chart.dart and any other callsite of `.category` on a span)

- [ ] **Step 1: Rename the field on `PerformanceSpan`**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, replace the field definition (line 31):

```dart
  final String subType;
```

Replace the constructor (lines 49-57):

```dart
  PerformanceSpan({
    required this.subType,
    required this.name,
    required this.startOffsetUs,
    required this.depth,
    required DateTime sessionAnchor,
    this.parent,
    this.metadata,
  }) : _sessionAnchor = sessionAnchor;
```

Replace `toJson` (lines 118-127):

```dart
  Map<String, dynamic> toJson() => {
        'subType': subType,
        'name': name,
        'startOffsetUs': startOffsetUs,
        'endOffsetUs': endOffsetUs,
        'depth': depth,
        if (metadata != null && metadata!.isNotEmpty) 'metadata': metadata,
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
      };
```

Replace `fromJson` (lines 129-153):

```dart
  static PerformanceSpan fromJson(Map<String, dynamic> json,
      {PerformanceSpan? parent, required DateTime sessionAnchor}) {
    final span = PerformanceSpan(
      subType: json['subType'] as String,
      name: json['name'] as String,
      startOffsetUs: json['startOffsetUs'] as int,
      depth: json['depth'] as int,
      sessionAnchor: sessionAnchor,
      parent: parent,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
    span.endOffsetUs = json['endOffsetUs'] as int?;
    if (json['children'] != null) {
      for (final childJson in json['children'] as List) {
        span.children.add(PerformanceSpan.fromJson(
          childJson as Map<String, dynamic>,
          parent: span,
          sessionAnchor: sessionAnchor,
        ));
      }
    }
    return span;
  }
```

Rename `rootSpansForCategory` → `rootSpansForSubType` (line 446):

```dart
  List<PerformanceSpan> rootSpansForSubType(String subType) {
    return rootSpans.where((s) => s.subType == subType).toList();
  }
```

- [ ] **Step 2: Update `beginSpan` and `beginEntry` callers in tracker that use `category:` named arg**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, find the two `PerformanceSpan(...)` constructor calls inside `beginSpan` (~line 388) and `beginEntry` (added in Task 2.3). Change `category: ...` to `subType: ...`.

- [ ] **Step 3: Update consumers**

Run: `cd webf && grep -rn '\.category' lib/src/devtools/panel/` to find usages. Each `.category` access on a `PerformanceSpan` becomes `.subType`. Also update `waterfall_chart.dart` lines that read `span.category` (around lines 394, 447) → `span.subType`.

- [ ] **Step 4: Verify analyze**

Run: `cd webf && flutter analyze lib/`
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_tracker.dart webf/lib/src/devtools/panel/waterfall_chart.dart
git commit -m "refactor(devtools): rename PerformanceSpan.category to subType"
```

---

### Task 3.2: Bump JSON to v5; hard-reject v4 imports

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:462-484` (`exportToJson`)
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:486-542` (`importFromJson`)

- [ ] **Step 1: Bump version + drop `jsThreadSpans` array from export**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, replace the body of `exportToJson` (lines 462-484) with:

```dart
  String exportToJson({List<ExportablePhase>? phases}) {
    int countSpans(List<PerformanceSpan> spans) {
      int count = 0;
      for (final s in spans) {
        count += 1 + countSpans(s.children);
      }
      return count;
    }

    final data = <String, dynamic>{
      'version': 5,
      'exportedAt': DateTime.now().toIso8601String(),
      'sessionStart': sessionStart?.microsecondsSinceEpoch,
      'totalSpanCount': countSpans(rootSpans),
      'rootSpans': rootSpans.map((s) => s.toJson()).toList(),
    };
    if (phases != null && phases.isNotEmpty) {
      data['phases'] = phases.map((p) => p.toJson()).toList();
    }
    return const JsonEncoder.withIndent('  ').convert(data);
  }
```

- [ ] **Step 2: Reject anything other than v5 on import**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, replace the body of `importFromJson` (lines 489-542) with:

```dart
  List<ExportablePhase> importFromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Hard-reject any version other than v5. Earlier formats encoded
    // categories as a flat enum and JS-thread spans as a parallel list,
    // both incompatible with the entry-rooted tree.
    final version = data['version'] as int?;
    if (version != 5) {
      throw FormatException(
        'Unsupported profile version: ${version ?? "missing"}. '
        'Expected version 5 (this build of WebF DevTools).',
      );
    }

    rootSpans.clear();
    _currentSpan = null;
    enabled = false;

    if (data['sessionStart'] != null) {
      sessionStart =
          DateTime.fromMicrosecondsSinceEpoch(data['sessionStart'] as int);
    }

    final anchor = sessionStart ?? DateTime.now();
    final spans = data['rootSpans'] as List;
    for (final spanJson in spans) {
      rootSpans.add(PerformanceSpan.fromJson(
        spanJson as Map<String, dynamic>,
        sessionAnchor: anchor,
      ));
    }
    _totalSpanCount = data['totalSpanCount'] as int? ?? rootSpans.length;

    final phasesJson = data['phases'] as List?;
    if (phasesJson != null) {
      return phasesJson
          .map((p) => ExportablePhase.fromJson(
                p as Map<String, dynamic>,
                sessionAnchor: anchor,
              ))
          .toList();
    }
    return [];
  }
```

- [ ] **Step 3: Verify analyze**

Run: `cd webf && flutter analyze lib/src/devtools/panel/performance_tracker.dart`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_tracker.dart
git commit -m "feat(devtools): bump profile JSON to v5; hard-reject v4"
```

---

### Task 3.3: Replace flat `jsThreadSpans` with drain-time grafting

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:215` (delete `jsThreadSpans` field)
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:298-342` (`drainJSThreadSpans`)
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:344-366` (`debugInjectJSSpan`)
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:545-603` (delete `JSThreadSpan` class — it's no longer needed)
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:451-456` (`clear` — remove `jsThreadSpans.clear()`)

- [ ] **Step 1: Delete the `jsThreadSpans` field**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, delete lines 214-215:

```dart
  /// JS thread spans collected from the C++ profiler.
  final List<JSThreadSpan> jsThreadSpans = [];
```

- [ ] **Step 2: Rewrite `drainJSThreadSpans` to graft into the tree**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, replace the entire `drainJSThreadSpans` method (lines 304-342) with:

```dart
  /// Drain JS thread profiling spans from the C++ ring buffer and graft
  /// each into the unified span tree.
  ///
  /// For each drained native span:
  /// - Look up `entry_id` in [_entryIdToSpan]. Match → the JS span is added
  ///   as a child of the entry's deepest leaf descendant whose interval
  ///   contains the span's start time.
  /// - No match (`entry_id == 0` or unknown) → synthesize a new root span
  ///   with `subType` derived from the C++ category enum
  ///   (kJsCategorySubTypes[category]).
  void drainJSThreadSpans() {
    if (!enabled && _stopwatch == null) return;
    final offsetUs = _cppToDartOffsetUs ?? 0;
    final anchor = sessionStart;
    if (anchor == null) return;

    const maxDrain = 4096;
    final buffer = calloc<NativeJSThreadSpan>(maxDrain);
    try {
      final count = to_native.drainJSThreadProfilingSpans(buffer, maxDrain);
      if (count <= 0) return;

      final atomNameCache = <int, String>{};

      for (int i = 0; i < count; i++) {
        final native = buffer[i];
        final startOffsetUs = native.startUs + offsetUs;
        final endOffsetUs = native.endUs + offsetUs;

        final atom = native.funcNameAtom;
        String funcName = '';
        if (atom != 0) {
          funcName = atomNameCache[atom] ??= to_native.getJSProfilerAtomName(atom);
        }

        final categoryIdx = native.category;
        final subType = (categoryIdx >= 0 && categoryIdx < kJsCategorySubTypes.length)
            ? kJsCategorySubTypes[categoryIdx]
            : 'jsUnknown';

        final root = native.entryId != 0 ? _entryIdToSpan[native.entryId] : null;

        if (root != null) {
          // Graft as child of the deepest leaf whose interval contains startOffsetUs.
          final parent = _findInsertionParent(root, startOffsetUs);
          final span = PerformanceSpan(
            subType: subType,
            name: funcName,
            startOffsetUs: startOffsetUs,
            depth: parent.depth + 1,
            sessionAnchor: anchor,
            parent: parent,
          );
          span.endOffsetUs = endOffsetUs;
          parent.children.add(span);
          _totalSpanCount++;
        } else {
          // Synthesize a new root for JS-originated work with no Dart parent.
          final span = PerformanceSpan(
            subType: subType,
            name: funcName,
            startOffsetUs: startOffsetUs,
            depth: 0,
            sessionAnchor: anchor,
          );
          span.endOffsetUs = endOffsetUs;
          rootSpans.add(span);
          _totalSpanCount++;
        }
      }
    } finally {
      calloc.free(buffer);
    }
  }

  /// Walks down [root] to find the deepest descendant whose interval
  /// contains [startOffsetUs]. Used to graft drained JS spans at the
  /// correct depth in the tree.
  PerformanceSpan _findInsertionParent(PerformanceSpan root, int startOffsetUs) {
    PerformanceSpan candidate = root;
    while (true) {
      PerformanceSpan? next;
      for (final child in candidate.children) {
        final endUs = child.endOffsetUs;
        if (endUs == null) continue;
        if (child.startOffsetUs <= startOffsetUs && startOffsetUs <= endUs) {
          next = child;
          break;
        }
      }
      if (next == null) return candidate;
      candidate = next;
    }
  }
```

- [ ] **Step 3: Rewrite `debugInjectJSSpan` to graft into the tree**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, replace the entire `debugInjectJSSpan` method (lines 348-366) with:

```dart
  @visibleForTesting
  void debugInjectJSSpan({
    required String subType,
    required int startUs,
    required int endUs,
    int entryId = 0,
    int funcNameAtom = 0,
    String funcName = '',
    int depth = 0,
  }) {
    final offsetUs = _cppToDartOffsetUs ?? 0;
    final startOffsetUs = startUs + offsetUs;
    final endOffsetUs = endUs + offsetUs;
    final anchor = sessionStart ?? DateTime.now();
    final root = entryId != 0 ? _entryIdToSpan[entryId] : null;
    if (root != null) {
      final parent = _findInsertionParent(root, startOffsetUs);
      final span = PerformanceSpan(
        subType: subType,
        name: funcName,
        startOffsetUs: startOffsetUs,
        depth: parent.depth + 1,
        sessionAnchor: anchor,
        parent: parent,
      );
      span.endOffsetUs = endOffsetUs;
      parent.children.add(span);
      _totalSpanCount++;
    } else {
      final span = PerformanceSpan(
        subType: subType,
        name: funcName,
        startOffsetUs: startOffsetUs,
        depth: 0,
        sessionAnchor: anchor,
      );
      span.endOffsetUs = endOffsetUs;
      rootSpans.add(span);
      _totalSpanCount++;
    }
  }
```

- [ ] **Step 4: Delete the `JSThreadSpan` class**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, delete the entire `JSThreadSpan` class (currently around lines 545-603). It's no longer needed — JS spans are regular `PerformanceSpan` instances now.

- [ ] **Step 5: Update `clear` to drop the deleted `jsThreadSpans` reference**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, modify `clear` (around line 451) to remove the `jsThreadSpans.clear()` line:

```dart
  void clear() {
    rootSpans.clear();
    _currentSpan = null;
    _totalSpanCount = 0;
    _entryStack.clear();
    _entryIdToSpan.clear();
    _entryIdMap.clear();
    _nextEntryId = 1;
  }
```

- [ ] **Step 6: Verify analyze (will surface waterfall_chart.dart breakage)**

Run: `cd webf && flutter analyze lib/`
Expected: errors in `waterfall_chart.dart` referring to `JSThreadSpan` and `tracker.jsThreadSpans` — these are fixed in Task 3.5. For now, accept the failures.

- [ ] **Step 7: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_tracker.dart
git commit -m "refactor(devtools): graft JS-thread spans into entry tree at drain time"
```

---

### Task 3.4: Delete `WaterfallCategory` enum + remove `jsSpans` field on `WaterfallEntry`

**Files:**
- Modify: `webf/lib/src/devtools/panel/waterfall_chart.dart:26-48` (delete `WaterfallCategory` enum)
- Modify: `webf/lib/src/devtools/panel/waterfall_chart.dart:56-81` (rewrite `WaterfallEntry` to use `String subType` instead of `WaterfallCategory category`; remove `jsSpans` field — JS spans are now in the tree)

- [ ] **Step 1: Replace `WaterfallEntry` to use a String subType**

In `webf/lib/src/devtools/panel/waterfall_chart.dart`, replace lines 26-81 (the enum + `_SpanSegment` + `WaterfallEntry`) with:

```dart
class _SpanSegment {
  final double startMs;
  final double endMs;
  _SpanSegment({required this.startMs, required this.endMs});
}

/// One row in the waterfall, representing one entry-root span (or a cluster
/// of consecutive same-subType roots). Drilldown opens a flame chart of
/// the root's full subtree.
class WaterfallEntry {
  /// Canonical entry subType (eg. 'drawFrame', 'flushUICommand'). Drives
  /// row grouping and color.
  final String subType;
  final String label;
  Duration start;
  Duration end;
  final List<WaterfallSubEntry> subEntries;
  final PerformanceSpan? span; // single-span entry → flame-chart root
  final List<PerformanceSpan> spans; // multi-span cluster → drilldown across all
  final List<_SpanSegment> spanSegments;

  WaterfallEntry({
    required this.subType,
    required this.label,
    required this.start,
    required this.end,
    this.subEntries = const [],
    this.span,
    this.spans = const [],
    this.spanSegments = const [],
  });

  Duration get duration => end - start;
  bool get hasDrillDown => span != null || spans.isNotEmpty;
}
```

- [ ] **Step 2: Verify analyze (will surface `_buildWaterfallDataImpl` and painter breakage)**

Run: `cd webf && flutter analyze lib/src/devtools/panel/waterfall_chart.dart`
Expected: errors. Fixed in Task 3.5.

- [ ] **Step 3: Commit**

```bash
git add webf/lib/src/devtools/panel/waterfall_chart.dart
git commit -m "refactor(devtools): replace WaterfallCategory enum with subType string"
```

---

### Task 3.5: Rewrite `_buildWaterfallDataImpl` to walk `tracker.rootSpans` keyed by subType

**Files:**
- Modify: `webf/lib/src/devtools/panel/waterfall_chart.dart:203+` (entire function `_buildWaterfallDataImpl`)
- Modify: any helper functions in waterfall_chart.dart that referenced `WaterfallCategory` (`_spanCategory`, `_jsSpanCategory`, `_categoryLabel`, `_lifecycleColor`)

- [ ] **Step 1: Add the row-order constant list near the top of waterfall_chart.dart**

In `webf/lib/src/devtools/panel/waterfall_chart.dart`, after the imports and before `_SpanSegment`, insert:

```dart
import 'package:webf/src/devtools/panel/performance_subtypes.dart';

/// Fixed row order in the waterfall. SubTypes not in this list are appended
/// at the end (catches new entries until they're explicitly placed).
const List<String> kWaterfallRowOrder = [
  // Lifecycle group
  kSubTypeDrawFrame,
  // Dart-thread entries
  kSubTypeFlushUICommand,
  kSubTypeInvokeBindingMethodFromNative,
  kSubTypeInvokeModuleEvent,
  kSubTypeAsyncCallback,
  kSubTypeImageLoadComplete,
  kSubTypeFontLoadComplete,
  kSubTypeScriptLoadComplete,
  kSubTypeNetworkResponse,
  kSubTypeHtmlParse,
  kSubTypeCssParse,
  kSubTypeEvaluateScripts,
  kSubTypeEvaluateByteCode,
  kSubTypeEvaluateModule,
  // JS-thread entries
  kSubTypeJsTimer,
  kSubTypeJsRAF,
  kSubTypeJsMicrotask,
  kSubTypeJsScriptEval,
  kSubTypeJsEvent,
  kSubTypeJsIdle,
  kSubTypeJsMutationObserver,
  kSubTypeJsFlushUICommand,
  kSubTypeJsBindingSyncCall,
  kSubTypeJsFunction,
  kSubTypeJsCFunction,
  // Fallback
  kSubTypeUnattributed,
];

/// Color for a given entry subType. Stable across sessions.
Color colorForSubType(String subType) {
  // Lifecycle = blue family
  if (subType == kSubTypeDrawFrame) return const Color(0xFF1976D2);
  if (subType == kSubTypeFlushUICommand) return const Color(0xFF42A5F5);
  // DOM/binding = purple family
  if (subType == kSubTypeInvokeBindingMethodFromNative) return const Color(0xFF7E57C2);
  if (subType == kSubTypeInvokeModuleEvent) return const Color(0xFF9575CD);
  // Loaders / network = green family
  if (subType == kSubTypeImageLoadComplete) return const Color(0xFF66BB6A);
  if (subType == kSubTypeFontLoadComplete) return const Color(0xFF81C784);
  if (subType == kSubTypeScriptLoadComplete) return const Color(0xFF4CAF50);
  if (subType == kSubTypeNetworkResponse) return const Color(0xFF26A69A);
  if (subType == kSubTypeHtmlParse) return const Color(0xFF388E3C);
  if (subType == kSubTypeCssParse) return const Color(0xFF2E7D32);
  // JS evaluation = orange family
  if (subType == kSubTypeEvaluateScripts) return const Color(0xFFFB8C00);
  if (subType == kSubTypeEvaluateByteCode) return const Color(0xFFEF6C00);
  if (subType == kSubTypeEvaluateModule) return const Color(0xFFE65100);
  // JS thread origins = orange light
  if (subType == kSubTypeJsTimer) return const Color(0xFFFFA726);
  if (subType == kSubTypeJsRAF) return const Color(0xFFFFB74D);
  if (subType == kSubTypeJsMicrotask) return const Color(0xFFFFCC80);
  if (subType == kSubTypeJsScriptEval) return const Color(0xFFFFE0B2);
  // Async/unknown
  if (subType == kSubTypeAsyncCallback) return const Color(0xFF8D6E63);
  if (subType == kSubTypeUnattributed) return const Color(0xFFEF5350);
  return const Color(0xFF9E9E9E);
}
```

- [ ] **Step 2: Replace `_buildWaterfallDataImpl` body**

In `webf/lib/src/devtools/panel/waterfall_chart.dart`, replace the entire `_buildWaterfallDataImpl` function (from line 203 up to but not including the next top-level declaration after the function's closing `}`) with:

```dart
WaterfallData _buildWaterfallDataImpl(
    LoadingState loadingState, PerformanceTracker tracker,
    {List<ExportablePhase>? importedPhases}) {
  final entries = <WaterfallEntry>[];
  final milestones = <WaterfallMilestone>[];
  final sessionStart = importedPhases != null
      ? tracker.sessionStart
      : (loadingState.startTime ?? tracker.sessionStart);

  if (sessionStart == null) {
    return WaterfallData(
        entries: [], milestones: [], totalDuration: Duration.zero);
  }

  final monotonicShiftUs = (importedPhases == null &&
          tracker.sessionStart != null &&
          tracker.sessionStart != sessionStart)
      ? tracker.sessionStart!.difference(sessionStart).inMicroseconds
      : 0;

  Duration offset(DateTime t) => t.difference(sessionStart);
  Duration offsetFromPair(DateTime wallClock, int? monotonicUs) {
    if (monotonicUs != null) {
      return Duration(microseconds: monotonicUs + monotonicShiftUs);
    }
    return wallClock.difference(sessionStart);
  }
  Duration shiftedOffset(int monotonicUs) =>
      Duration(microseconds: monotonicUs + monotonicShiftUs);

  // --- Lifecycle phases (unchanged) ---
  final phaseNames = <String>[];
  final phaseTimestamps = <DateTime>[];
  final phaseOffsetUs = <int?>[];
  if (importedPhases != null) {
    for (final p in importedPhases) {
      phaseNames.add(p.name);
      phaseTimestamps.add(p.timestamp);
      phaseOffsetUs.add(p.offsetUs);
    }
  } else {
    final livePhases = List.of(loadingState.phases);
    for (final p in livePhases) {
      phaseNames.add(p.name);
      phaseTimestamps.add(p.timestamp);
      phaseOffsetUs.add(p.offsetUs);
    }
  }
  Duration? attachOffset;
  if (phaseNames.isNotEmpty) {
    final lifecyclePhaseNames = [
      LoadingState.phaseInit,
      LoadingState.phasePreload,
      LoadingState.phasePreRender,
      LoadingState.phaseLoadStart,
      LoadingState.phaseEvaluateStart,
      LoadingState.phaseEvaluateComplete,
      LoadingState.phaseDOMContentLoaded,
      LoadingState.phaseWindowLoad,
      LoadingState.phaseAttachToFlutter,
    ];
    final relevantIndices = <int>[];
    for (int i = 0; i < phaseNames.length; i++) {
      if (lifecyclePhaseNames.contains(phaseNames[i])) {
        relevantIndices.add(i);
      }
    }
    if (relevantIndices.length >= 2) {
      final subEntries = <WaterfallSubEntry>[];
      for (int i = 0; i < relevantIndices.length - 1; i++) {
        final idx = relevantIndices[i];
        final nextIdx = relevantIndices[i + 1];
        subEntries.add(WaterfallSubEntry(
          label: phaseNames[idx],
          color: _lifecycleColor(phaseNames[idx]),
          start: offsetFromPair(phaseTimestamps[idx], phaseOffsetUs[idx]),
          end: offsetFromPair(phaseTimestamps[nextIdx], phaseOffsetUs[nextIdx]),
        ));
      }
      entries.add(WaterfallEntry(
        subType: 'lifecycle',
        label: 'Lifecycle',
        start: offsetFromPair(
            phaseTimestamps[relevantIndices.first], phaseOffsetUs[relevantIndices.first]),
        end: offsetFromPair(
            phaseTimestamps[relevantIndices.last], phaseOffsetUs[relevantIndices.last]),
        subEntries: subEntries,
      ));
    }
  }

  // --- Network requests (unchanged) ---
  final networkReqs =
      importedPhases != null ? <dynamic>[] : List.of(loadingState.networkRequests);
  for (final req in networkReqs) {
    if (!req.isComplete) continue;
    final subEntries = <WaterfallSubEntry>[];
    final reqStart = offset(req.startTime);
    final reqEnd = offset(req.endTime!);

    if (req.dnsDuration != null && req.dnsStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'DNS', color: const Color(0xFF4CAF50),
        start: offset(req.dnsStart!), end: offset(req.dnsEnd!),
      ));
    }
    if (req.connectDuration != null && req.connectStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'Connect', color: const Color(0xFFFF9800),
        start: offset(req.connectStart!), end: offset(req.connectEnd!),
      ));
    }
    if (req.tlsDuration != null && req.tlsStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'TLS', color: const Color(0xFF9C27B0),
        start: offset(req.tlsStart!), end: offset(req.tlsEnd!),
      ));
    }
    if (req.waitingDuration != null && req.requestStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'Waiting', color: const Color(0xFF2196F3),
        start: offset(req.requestStart!), end: offset(req.responseStart!),
      ));
    }
    if (req.downloadDuration != null && req.responseStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'Download', color: const Color(0xFF607D8B),
        start: offset(req.responseStart!), end: offset(req.responseEnd!),
      ));
    }

    var urlLabel = req.url;
    try {
      final uri = Uri.parse(urlLabel);
      urlLabel = uri.path;
      if (urlLabel.isEmpty || urlLabel == '/') urlLabel = uri.host;
      if (uri.query.isNotEmpty && uri.query.length <= 15) {
        urlLabel = '$urlLabel?${uri.query}';
      }
    } catch (_) {}
    if (urlLabel.length > 30) {
      urlLabel = '...${urlLabel.substring(urlLabel.length - 27)}';
    }

    entries.add(WaterfallEntry(
      subType: 'network',
      label: urlLabel,
      start: reqStart,
      end: reqEnd,
      subEntries: subEntries,
    ));
  }

  // --- Entry-rooted spans grouped by subType ---
  // Walk root spans, group by subType, cluster consecutive same-subType
  // spans within 50ms gap into a single entry row.
  final rootSnapshot = List.of(tracker.rootSpans);
  final rootsBySubType = <String, List<PerformanceSpan>>{};
  for (final span in rootSnapshot) {
    if (!span.isComplete) continue;
    (rootsBySubType[span.subType] ??= []).add(span);
  }

  // Iterate in fixed kWaterfallRowOrder, then any unknown subTypes appended.
  final orderedSubTypes = <String>[
    ...kWaterfallRowOrder.where(rootsBySubType.containsKey),
    ...rootsBySubType.keys.where((k) => !kWaterfallRowOrder.contains(k)),
  ];

  for (final subType in orderedSubTypes) {
    final spans = rootsBySubType[subType]!;
    if (spans.isEmpty) continue;
    spans.sort((a, b) => a.startOffsetUs.compareTo(b.startOffsetUs));

    const clusterGap = Duration(milliseconds: 50);
    var clusterStart = shiftedOffset(spans.first.startOffsetUs);
    var clusterEnd = shiftedOffset(spans.first.endOffsetUs!);
    var clusterSpans = <PerformanceSpan>[spans.first];

    void flushCluster() {
      final totalDuration = clusterSpans.fold<Duration>(
          Duration.zero, (sum, s) => sum + s.duration);
      final count = clusterSpans.length;
      final label = count == 1
          ? (clusterSpans.first.name.isNotEmpty
              ? clusterSpans.first.name
              : subType)
          : '$subType ($count, ${_formatDuration(totalDuration)})';
      final segments = count > 1
          ? clusterSpans.map((s) => _SpanSegment(
              startMs: (s.startOffsetUs + monotonicShiftUs) / 1000.0,
              endMs: (s.endOffsetUs! + monotonicShiftUs) / 1000.0,
            )).toList()
          : const <_SpanSegment>[];
      entries.add(WaterfallEntry(
        subType: subType,
        label: label,
        start: clusterStart,
        end: clusterEnd,
        span: count == 1 ? clusterSpans.first : null,
        spans: count > 1 ? List.of(clusterSpans) : const [],
        spanSegments: segments,
      ));
    }

    for (int i = 1; i < spans.length; i++) {
      final spanStart = shiftedOffset(spans[i].startOffsetUs);
      final spanEnd = shiftedOffset(spans[i].endOffsetUs!);
      if (spanStart - clusterEnd > clusterGap) {
        flushCluster();
        clusterStart = spanStart;
        clusterEnd = spanEnd;
        clusterSpans = [spans[i]];
      } else {
        if (spanEnd > clusterEnd) clusterEnd = spanEnd;
        clusterSpans.add(spans[i]);
      }
    }
    flushCluster();
  }

  // --- Milestones (unchanged) ---
  for (int i = 0; i < phaseNames.length; i++) {
    final name = phaseNames[i];
    final ts = phaseTimestamps[i];
    if (name == LoadingState.phaseAttachToFlutter) {
      attachOffset = offset(ts);
      milestones.add(WaterfallMilestone(
        label: 'Attach', offset: attachOffset,
        color: const Color(0xFFFFB74D), isStageDivider: true,
      ));
    } else if (name == LoadingState.phaseFirstPaint) {
      milestones.add(WaterfallMilestone(
        label: 'FP', offset: offset(ts), color: const Color(0xFF4CAF50)));
    } else if (name == LoadingState.phaseFirstContentfulPaint) {
      milestones.add(WaterfallMilestone(
        label: 'FCP', offset: offset(ts), color: const Color(0xFF2196F3)));
    } else if (name == LoadingState.phaseLargestContentfulPaint ||
        name == LoadingState.phaseFinalLargestContentfulPaint) {
      milestones.add(WaterfallMilestone(
        label: 'LCP', offset: offset(ts), color: const Color(0xFFF44336)));
    }
  }

  // Normalize: shift all entries so the timeline starts at the earliest event.
  var minStart = const Duration(days: 999);
  for (final e in entries) {
    if (e.start < minStart) minStart = e.start;
  }
  for (final m in milestones) {
    if (m.offset < minStart) minStart = m.offset;
  }
  if (minStart > Duration.zero && entries.isNotEmpty) {
    for (final e in entries) {
      e.start = e.start - minStart;
      e.end = e.end - minStart;
      for (final s in e.subEntries) {
        s.start = s.start - minStart;
        s.end = s.end - minStart;
      }
    }
    for (final m in milestones) {
      m.offset = m.offset - minStart;
    }
  }

  var maxEnd = Duration.zero;
  for (final e in entries) {
    if (e.end > maxEnd) maxEnd = e.end;
  }
  for (final m in milestones) {
    if (m.offset > maxEnd) maxEnd = m.offset;
  }

  return WaterfallData(
    entries: entries,
    milestones: milestones,
    totalDuration: maxEnd,
    attachOffset: attachOffset,
  );
}
```

- [ ] **Step 3: Delete now-dead helpers**

In `webf/lib/src/devtools/panel/waterfall_chart.dart`, search for and delete the helper functions `_spanCategory`, `_jsSpanCategory`, `_spanLabel`, `_categoryLabel` (they referenced the deleted `WaterfallCategory` enum). Keep `_lifecycleColor` and `_formatDuration` (still used). Also search for any remaining `WaterfallCategory.` references in the painter file (`waterfall_chart_painter.dart` if it exists, or further down in the same file) and update them to use `colorForSubType(entry.subType)` instead.

Run: `cd webf && grep -rn 'WaterfallCategory' lib/`
Expected: zero matches (confirms enum is fully gone).

- [ ] **Step 4: Verify analyze**

Run: `cd webf && flutter analyze lib/`
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add webf/lib/src/devtools/panel/waterfall_chart.dart
git commit -m "refactor(devtools): rewrite waterfall layout for entry-rooted spans"
```

---

### Task 3.6: Write tests for JSON v5 round-trip + drain-time grafting

**Files:**
- Create: `webf/test/src/devtools/performance_tracker_v5_test.dart`
- Modify: `webf/test/webf_test.dart` (register the new test file)

- [ ] **Step 1: Create the test file**

Create `webf/test/src/devtools/performance_tracker_v5_test.dart`:

```dart
/*
 * Copyright (C) 2026-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/performance_subtypes.dart';

void main() {
  group('PerformanceTracker JSON v5', () {
    setUp(() {
      PerformanceTracker.instance.startSession();
    });

    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('exportToJson writes version 5 and no jsThreadSpans field', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      final child = PerformanceTracker.instance
          .beginSpan(kSubTypePaint, 'paint');
      child!.end();
      entry!.end();

      final exported = PerformanceTracker.instance.exportToJson();
      final data = jsonDecode(exported) as Map<String, dynamic>;
      expect(data['version'], 5);
      expect(data.containsKey('jsThreadSpans'), false,
          reason: 'v5 has no flat jsThreadSpans array — JS spans live in tree');
      expect(data['rootSpans'], isList);
      final root = (data['rootSpans'] as List).first as Map<String, dynamic>;
      expect(root['subType'], kSubTypeDrawFrame);
      expect(root['children'], isList);
      expect((root['children'] as List).first['subType'], kSubTypePaint);
    });

    test('importFromJson rejects v4 with FormatException', () {
      final v4 = jsonEncode({
        'version': 4,
        'exportedAt': DateTime.now().toIso8601String(),
        'sessionStart': DateTime.now().microsecondsSinceEpoch,
        'totalSpanCount': 0,
        'rootSpans': <dynamic>[],
      });
      expect(
        () => PerformanceTracker.instance.importFromJson(v4),
        throwsA(isA<FormatException>()),
      );
    });

    test('importFromJson rejects missing version with FormatException', () {
      final missing = jsonEncode({'rootSpans': <dynamic>[]});
      expect(
        () => PerformanceTracker.instance.importFromJson(missing),
        throwsA(isA<FormatException>()),
      );
    });

    test('export → import → export is byte-identical', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      final paint = PerformanceTracker.instance
          .beginSpan(kSubTypePaint, 'paint');
      paint!.end();
      entry!.end();

      final once = PerformanceTracker.instance.exportToJson();
      PerformanceTracker.instance.importFromJson(once);
      final twice = PerformanceTracker.instance.exportToJson();

      // exportedAt timestamp will differ; strip it for comparison.
      final a = jsonDecode(once) as Map<String, dynamic>..remove('exportedAt');
      final b = jsonDecode(twice) as Map<String, dynamic>..remove('exportedAt');
      expect(jsonEncode(a), jsonEncode(b));
    });
  });

  group('PerformanceTracker drain-time grafting', () {
    setUp(() {
      PerformanceTracker.instance.startSession();
    });
    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('JS span with matching entryId becomes child of that root', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');

      // Entry ids are allocated monotonically from 1. The first entry id is 1.
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsBindingSyncCall,
        startUs: PerformanceTracker.instance.nowOffsetUs() - 100,
        endUs: PerformanceTracker.instance.nowOffsetUs() - 50,
        entryId: 1,
        funcName: 'getBoundingClientRect',
      );

      entry!.end();

      final root = PerformanceTracker.instance.rootSpans.first;
      expect(root.subType, kSubTypeFlushUICommand);
      expect(root.children.length, 1);
      expect(root.children.first.subType, kSubTypeJsBindingSyncCall);
      expect(root.children.first.name, 'getBoundingClientRect');
    });

    test('JS span with entryId=0 becomes a new root', () {
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsTimer,
        startUs: 1000,
        endUs: 2000,
        entryId: 0,
        funcName: 'setTimeout',
      );

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 1);
      expect(roots.first.subType, kSubTypeJsTimer);
      expect(roots.first.parent, isNull);
    });

    test('JS span drained AFTER entry closes still grafts under its root', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      entry!.end();
      // Now drain a JS span tagged with the (now-closed) entry's id.
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsCFunction,
        startUs: 0,
        endUs: 100,
        entryId: 1,
        funcName: 'lateArrival',
      );

      final root = PerformanceTracker.instance.rootSpans.first;
      expect(root.children.any((c) => c.name == 'lateArrival'), true,
          reason: '_entryIdToSpan must persist past entry close');
    });
  });
}
```

- [ ] **Step 2: Register the test in `webf_test.dart`**

In `webf/test/webf_test.dart`, add the import:

```dart
import 'src/devtools/performance_tracker_v5_test.dart' as performance_tracker_v5_test;
```

And in `main()`:

```dart
  group('PerformanceTracker v5', performance_tracker_v5_test.main);
```

- [ ] **Step 3: Run tests, verify pass**

Run: `cd webf && flutter test test/src/devtools/performance_tracker_v5_test.dart`
Expected: all 7 tests pass.

- [ ] **Step 4: Commit**

```bash
git add webf/test/src/devtools/performance_tracker_v5_test.dart webf/test/webf_test.dart
git commit -m "test(devtools): cover JSON v5 round-trip + drain-time grafting"
```

---

### Task 3.7: Write widget test for waterfall row layout

**Files:**
- Create: `webf/test/src/devtools/waterfall_chart_test.dart`
- Modify: `webf/test/webf_test.dart`

- [ ] **Step 1: Create the test file**

Create `webf/test/src/devtools/waterfall_chart_test.dart`:

```dart
/*
 * Copyright (C) 2026-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/performance_subtypes.dart';
import 'package:webf/src/devtools/panel/waterfall_chart.dart';
import 'package:webf/src/launcher/loading_state.dart';

void main() {
  group('WaterfallData layout', () {
    setUp(() {
      PerformanceTracker.instance.startSession();
    });
    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('one row per entry subType in fixed order', () {
      // Drive entries in REVERSE display order to confirm sorting.
      final timer = PerformanceTracker.instance
          .beginEntry(kSubTypeJsTimer, 'setTimeout');
      timer!.end();
      final flush = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      flush!.end();
      final draw = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      draw!.end();

      final loadingState = LoadingState();
      final data = buildWaterfallData(loadingState, PerformanceTracker.instance);

      // Filter entries by the subTypes we created (skip lifecycle/network rows).
      final entrySubTypes = data.entries
          .map((e) => e.subType)
          .where((s) => [
                kSubTypeDrawFrame,
                kSubTypeFlushUICommand,
                kSubTypeJsTimer,
              ].contains(s))
          .toList();
      expect(entrySubTypes,
          [kSubTypeDrawFrame, kSubTypeFlushUICommand, kSubTypeJsTimer],
          reason: 'rows must follow kWaterfallRowOrder');
    });

    test('drilldown is available for entry rows', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      entry!.end();

      final loadingState = LoadingState();
      final data = buildWaterfallData(loadingState, PerformanceTracker.instance);
      final drawRow = data.entries.firstWhere((e) => e.subType == kSubTypeDrawFrame);
      expect(drawRow.hasDrillDown, true);
    });

    test('color is stable across runs for the same subType', () {
      expect(colorForSubType(kSubTypeDrawFrame),
          colorForSubType(kSubTypeDrawFrame));
      expect(colorForSubType(kSubTypeDrawFrame),
          isNot(colorForSubType(kSubTypeJsTimer)));
    });
  });
}
```

- [ ] **Step 2: Register in `webf_test.dart`**

In `webf/test/webf_test.dart`:

```dart
import 'src/devtools/waterfall_chart_test.dart' as waterfall_chart_test;
```

```dart
  group('WaterfallChart', waterfall_chart_test.main);
```

- [ ] **Step 3: Run tests**

Run: `cd webf && flutter test test/src/devtools/waterfall_chart_test.dart`
Expected: all 3 tests pass.

- [ ] **Step 4: Commit**

```bash
git add webf/test/src/devtools/waterfall_chart_test.dart webf/test/webf_test.dart
git commit -m "test(devtools): cover waterfall row ordering for entry-rooted layout"
```

---

### Task 3.8: PR 3 — manual smoke verification

- [ ] **Step 1: Build everything**

Run: `npm run build:bridge:macos && cd webf && flutter analyze`
Expected: success.

- [ ] **Step 2: Run all tests**

Run: `npm test`
Expected: all bridge unit tests, all Dart tests, integration tests pass.

- [ ] **Step 3: Open the example app and inspect the waterfall**

Run: `npm run start`
Open DevTools → Performance panel, start recording, perform `el.style.src = '...'` interaction. Verify:
- Waterfall has rows: Lifecycle, drawFrame, flushUICommand, invokeBindingMethodFromNative.
- The `drawFrame` row contains nested `flushUICommand` and `paint` children visible via drilldown (not as separate top-level rows).
- JS-thread microtasks/timers fired without a Dart parent appear as their own `jsTimer` / `jsMicrotask` rows.
- A previously-saved v4 profile JSON fails to import with a clear FormatException.

- [ ] **Step 4: Open PR 3**

PR description should call out: visible UI relayout — rows now grouped by entry subType; v4 profile JSON files no longer importable (dev-only artifacts). Reference the spec.

---

## Self-Review Checklist

After implementation, verify against the spec sections:

- **Spec §1 (Entry taxonomy)**: All 16 entry subTypes from the table appear as constants in `performance_subtypes.dart` and have at least one push site (or are reserved for future, like `fontLoadComplete` / `scriptLoadComplete` / `asyncCallback`). Check Task 2.1 + new entry sites in 2.5/2.6/2.7/2.10.
- **Spec §2 (Span shape)**: `category` field renamed to `subType`; constants in `performance_subtypes.dart`. Tasks 2.1 + 3.1.
- **Spec §3 (C++ side)**: `current_entry_id_` atomic added; `JSThreadSpan.entry_id` field; FFI exports + Dart binding. Tasks 1.1–1.6 + 2.2.
- **Spec §4 (Async entries)**: `beginAsyncSpan` removed; each completion handler is its own root entry. Task 2.9.
- **Spec §5 (Waterfall UI)**: `WaterfallCategory` enum deleted; rows by subType; `kWaterfallRowOrder` defines order. Tasks 3.4 + 3.5.
- **Spec §6 (Migration)**: All 14 `beginSpan` callsites migrated; dev-mode assert; promote-to-`unattributed` in prod. Tasks 2.4 + 2.8.
- **Spec §7 (JSON v5)**: Version 5; v4 hard-rejected; `jsThreadSpans` array deleted; tree-only. Tasks 3.2 + 3.3.
- **Spec §8 (Performance overhead)**: `setJSProfilerCurrentEntryId` is gated by `tracker.enabled` (via `startSession`/`endSession` set/clear); C++ `SetCurrentEntryId` is a relaxed atomic store. Tasks 1.2 + 2.3.
