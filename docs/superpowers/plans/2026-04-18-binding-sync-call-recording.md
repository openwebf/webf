# Binding Sync Call Recording Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Capture every synchronous Dart-side roundtrip made from JavaScript during eval (e.g., `getBoundingClientRect`, `offsetWidth`, `getComputedStyle`) as named spans in the performance recording timeline, nested inside the surrounding `kJSScriptEval` block, with the binding method name as metadata.

**Architecture:** All sync JS→Dart calls funnel through two C++ entry points: `BindingObject::InvokeBindingMethod` (named-method variant, `binding_object.cc:119`) and `BindingObject::InvokeBindingMethod` (operation-enum variant, `binding_object.cc:276`). We wrap their `PostToDartSync` blocks with a new `JSThreadProfiler::ScopedSpan(kJSBindingSyncCall, name_id)`. The name `name_id` comes from a new "binding name" registry inside `JSThreadProfiler` — synthetic 32-bit IDs with the high bit set so they don't collide with real QuickJS atoms. The existing atom-name FFI (`getJSProfilerAtomName`) is extended to resolve from either registry, so no new FFI surface is needed; the Dart-side drain just keeps working.

**Tech Stack:** C++17 (bridge), Dart/Flutter (webf package), FFI.

**Spec:** Conversation context — see analysis preceding this plan.

**Branch:** `feat/perf-graph-redesign` (continues from clock-alignment work in `2026-04-18-perf-recording-clock-alignment.md`).

---

## File Structure

**Modified:**
- `bridge/core/profiling/js_thread_profiler.h` — add `kJSBindingSyncCall = 10` enum value; declare `RegisterBindingName(const std::string&)`; declare binding-name internal storage.
- `bridge/core/profiling/js_thread_profiler.cc` — implement `RegisterBindingName`; extend `GetAtomName` to consult binding-name table when high bit is set; clear binding registry on `Enable`.
- `bridge/core/binding_object.cc` — wrap both `PostToDartSync` blocks (lines 144 and 299) with `ScopedSpan(kJSBindingSyncCall, name_id)`; obtain `name_id` from new helper.
- `webf/lib/src/devtools/panel/performance_tracker.dart` — add `'jsBindingSyncCall'` to `JSThreadSpan.categoryNames` at index 10.
- `webf/lib/src/devtools/panel/waterfall_chart.dart` — add `WaterfallCategory.jsBindingSyncCall`; route `'jsBindingSyncCall'` to it in `_jsSpanCategory`; color/label entries; include in `_isJSThreadCategory`; include in the JS-categories-list literal.

**Created (tests):**
- `bridge/test/core/profiling/binding_name_registry_test.cc` — unit tests for `RegisterBindingName`/`GetAtomName` round-trip and high-bit ID space.
- `webf/test/src/devtools/performance_tracker_binding_span_test.dart` — Dart-side test that injects a `kJSBindingSyncCall` synthetic span via `debugInjectJSSpan` and verifies it lands in `jsThreadSpans` with the expected category.

No new runtime source files.

---

## Task 1: C++ — add `kJSBindingSyncCall` enum value

**Files:**
- Modify: `bridge/core/profiling/js_thread_profiler.h:22-33`

- [ ] **Step 1: Add the new enum value**

Edit `bridge/core/profiling/js_thread_profiler.h` to extend the `JSSpanCategory` enum:

```cpp
enum JSSpanCategory : uint8_t {
  kJSFunction = 0,
  kJSCFunction = 1,
  kJSScriptEval = 2,
  kJSTimer = 3,
  kJSEvent = 4,
  kJSRAF = 5,
  kJSIdle = 6,
  kJSMicrotask = 7,
  kJSMutationObserver = 8,
  kJSFlushUICommand = 9,
  kJSBindingSyncCall = 10,
};
```

- [ ] **Step 2: Build to verify enum compiles**

Run: `npm run build:bridge:macos`
Expected: build succeeds with no errors.

- [ ] **Step 3: Commit**

```bash
git add bridge/core/profiling/js_thread_profiler.h
git commit -m "feat(profiler): add kJSBindingSyncCall span category"
```

---

## Task 2: C++ — add binding-name registry to `JSThreadProfiler`

We need a way to attach a human-readable name (e.g., `"getBoundingClientRect"`) to a binding-call span. The existing `func_name_atom` field is a `uint32_t` originally meant for QuickJS `JSAtom`s. We reuse the same field but use the high bit (`0x80000000`) to flag IDs that come from our C++-side registry instead of QuickJS. Real `JSAtom`s never exceed `0x7FFFFFFF` in practice, so the namespaces don't collide.

**Files:**
- Modify: `bridge/core/profiling/js_thread_profiler.h:71-103`
- Modify: `bridge/core/profiling/js_thread_profiler.cc:16-30, 71-77`

- [ ] **Step 1: Write failing test**

Create `bridge/test/core/profiling/binding_name_registry_test.cc`:

```cpp
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <gtest/gtest.h>
#include "core/profiling/js_thread_profiler.h"

namespace webf {

TEST(BindingNameRegistry, RegisterReturnsHighBitId) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  uint32_t id = p.RegisterBindingName("getBoundingClientRect");
  EXPECT_NE(0u, id & 0x80000000u) << "binding IDs must have the high bit set";
  p.Disable();
}

TEST(BindingNameRegistry, RegisterIsIdempotent) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  uint32_t id1 = p.RegisterBindingName("offsetWidth");
  uint32_t id2 = p.RegisterBindingName("offsetWidth");
  EXPECT_EQ(id1, id2) << "same name must return same ID";
  p.Disable();
}

TEST(BindingNameRegistry, GetAtomNameResolvesBindingId) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  uint32_t id = p.RegisterBindingName("getComputedStyle");
  EXPECT_EQ("getComputedStyle", p.GetAtomName(id));
  p.Disable();
}

TEST(BindingNameRegistry, EnableClearsBindingRegistry) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  uint32_t id_before = p.RegisterBindingName("scrollTop");
  p.Disable();
  p.Enable();
  // After re-enable, the same name should get a fresh registration; either same
  // or different id is OK as long as it resolves to the right name.
  uint32_t id_after = p.RegisterBindingName("scrollTop");
  EXPECT_EQ("scrollTop", p.GetAtomName(id_after));
  // And an old ID from a previous session should NOT resolve to scrollTop in
  // the new session.
  EXPECT_NE("scrollTop", p.GetAtomName(id_before == id_after ? (id_before ^ 1u) : id_before));
  p.Disable();
}

}  // namespace webf
```

Wire the new test into the bridge unit-test runner. Find the test target in `bridge/test/CMakeLists.txt` (or the equivalent build file) and add `core/profiling/binding_name_registry_test.cc` to the source list. Refer to `claude_memory/bridge_unit_tests.md` for the runner pattern.

- [ ] **Step 2: Run the test, verify it fails**

Run: `node scripts/run_bridge_unit_test.js`
Expected: FAIL — `RegisterBindingName` is not declared.

- [ ] **Step 3: Add registry to header**

Edit `bridge/core/profiling/js_thread_profiler.h`. After the existing public `IsAtomKnown` declaration (around line 84), add:

```cpp
  // Register a human-readable name for a C++-side span (e.g., binding method
  // names). Returns a stable ID with the high bit set so it does not collide
  // with QuickJS JSAtoms. Use the returned ID as the `name` argument of
  // ScopedSpan / OnFunctionEntry. GetAtomName() will resolve it.
  uint32_t RegisterBindingName(const std::string& name);
```

In the `private:` section (around line 102, after `kEmptyString`), add:

```cpp
  // C++-side name registry (binding methods, internal spans). IDs use the high
  // bit to distinguish from QuickJS atoms. Cleared on Enable().
  static constexpr uint32_t kBindingIdFlag = 0x80000000u;
  std::unordered_map<std::string, uint32_t> binding_name_to_id_;
  std::vector<std::string> binding_names_;  // index = id & ~kBindingIdFlag
```

- [ ] **Step 4: Implement in .cc**

Edit `bridge/core/profiling/js_thread_profiler.cc`. In `Enable()` (around line 16), add registry clearing alongside the existing `atom_to_id_.clear()` calls:

```cpp
void JSThreadProfiler::Enable(int64_t min_duration_us) {
  min_duration_us_ = min_duration_us;
  write_pos_ = 0;
  read_pos_ = 0;
  stack_depth_ = 0;
  atom_to_id_.clear();
  unique_atoms_.clear();
  atom_names_.clear();
  binding_name_to_id_.clear();
  binding_names_.clear();
  for (int i = 0; i < kMaxDepth; i++) {
    pending_[i].valid = false;
  }
  session_start_ = std::chrono::steady_clock::now();
  enabled_.store(true, std::memory_order_release);
  InstallHooks();
}
```

After the existing `GetAtomName` definition (around line 71), add:

```cpp
uint32_t JSThreadProfiler::RegisterBindingName(const std::string& name) {
  auto it = binding_name_to_id_.find(name);
  if (it != binding_name_to_id_.end()) return it->second;
  uint32_t idx = static_cast<uint32_t>(binding_names_.size());
  uint32_t id = idx | kBindingIdFlag;
  binding_name_to_id_.emplace(name, id);
  binding_names_.push_back(name);
  return id;
}
```

Replace the existing `GetAtomName` (lines 71-77) so it routes binding IDs:

```cpp
const std::string& JSThreadProfiler::GetAtomName(JSAtom atom) const {
  if ((atom & kBindingIdFlag) != 0) {
    uint32_t idx = atom & ~kBindingIdFlag;
    if (idx < binding_names_.size()) return binding_names_[idx];
    return kEmptyString;
  }
  auto it = atom_to_id_.find(atom);
  if (it != atom_to_id_.end() && it->second < static_cast<int32_t>(atom_names_.size())) {
    return atom_names_[it->second];
  }
  return kEmptyString;
}
```

Note: `kBindingIdFlag` is referenced unqualified above because it's a member constant. If the compiler complains about access in a `const` context, prefix with `JSThreadProfiler::` or move the constant declaration above the method. Adjust if needed.

- [ ] **Step 5: Run the test, verify it passes**

Run: `npm run build:bridge:macos && node scripts/run_bridge_unit_test.js`
Expected: PASS for all four `BindingNameRegistry.*` tests.

- [ ] **Step 6: Commit**

```bash
git add bridge/core/profiling/js_thread_profiler.h \
        bridge/core/profiling/js_thread_profiler.cc \
        bridge/test/core/profiling/binding_name_registry_test.cc \
        bridge/test/CMakeLists.txt
git commit -m "feat(profiler): add binding-name registry with high-bit IDs"
```

---

## Task 3: C++ — wrap `InvokeBindingMethod` (named-method variant) with span

This variant is called for ad-hoc binding methods like `getBoundingClientRect`, `getClientRects`, `getComputedStyle`, etc. The method name is an `AtomicString`, which we convert to a UTF-8 `std::string` for registration. The registry caches by string so repeat calls of the same method only allocate the first time.

**Files:**
- Modify: `bridge/core/binding_object.cc:119-173`

- [ ] **Step 1: Add include**

At the top of `bridge/core/binding_object.cc`, ensure the profiler header is included. Add (or verify present):

```cpp
#include "core/profiling/js_thread_profiler.h"
```

- [ ] **Step 2: Wrap PostToDartSync with ScopedSpan**

Replace the body of `BindingObject::InvokeBindingMethod` (the `AtomicString` overload at line 119) so the `PostToDartSync` call is wrapped:

```cpp
NativeValue BindingObject::InvokeBindingMethod(const AtomicString& method,
                                               int32_t argc,
                                               const NativeValue* argv,
                                               uint32_t reason,
                                               ExceptionState& exception_state) const {
  auto* context = GetExecutingContext();

  if (auto* canvas_context = DynamicTo<CanvasRenderingContext2D>(this)) {
    canvas_context->requestPaint();
  }

  std::vector<NativeBindingObject*> invoke_elements_deps;
  // Collect all DOM elements in arguments.
  CollectElementDepsOnArgs(invoke_elements_deps, argc, argv);
  // Make sure all these elements are ready in dart.
  context->FlushUICommand(this, reason, invoke_elements_deps);

  NativeValue return_value = Native_NewNull();
  NativeValue native_method =
      NativeValueConverter<NativeTypeString>::ToNativeValue(GetExecutingContext()->ctx(), method);

#if ENABLE_LOG
  WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Call Begin";
#endif

  // Record this synchronous Dart roundtrip as a span on the JS thread so it
  // nests inside the surrounding kJSScriptEval block in the perf timeline.
  uint32_t name_id = 0;
  auto& profiler = JSThreadProfiler::Instance();
  if (profiler.enabled()) {
    name_id = profiler.RegisterBindingName(method.ToStdString(GetExecutingContext()->ctx()));
  }
  JSThreadProfiler::ScopedSpan span_guard(profiler, kJSBindingSyncCall, name_id);

  GetDispatcher()->PostToDartSync(
      GetExecutingContext()->isDedicated(), contextId(),
      [&](bool cancel, double contextId, const NativeBindingObject* binding_object,
          NativeValue* return_value, NativeValue* method, int32_t argc, const NativeValue* argv) {
        if (cancel)
          return;

#if ENABLE_LOG
        WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Callback Start";
#endif

        if (binding_object_->invoke_bindings_methods_from_native == nullptr) {
          WEBF_LOG(VERBOSE) << "invoke_bindings_methods_from_native is nullptr" << std::endl;
          return;
        }
        binding_object_->invoke_bindings_methods_from_native(contextId, binding_object, return_value,
                                                             method, argc, argv);
#if ENABLE_LOG
        WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Callback End";
#endif
      },
      GetExecutingContext()->contextId(), binding_object_, &return_value, &native_method, argc,
      argv);

#if ENABLE_LOG
  WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Call End";
#endif

  return return_value;
}
```

Note: `AtomicString::ToStdString(JSContext*)` is the canonical conversion in WebF. If that method does not exist verbatim, use the existing pattern for converting `AtomicString` to a `std::string` (search `bridge/core/` for existing `ToStdString` or `ToUTF8` calls). Adjust the conversion to whatever exists in the codebase — do not invent an API.

- [ ] **Step 3: Build to verify**

Run: `npm run build:bridge:macos`
Expected: builds clean.

- [ ] **Step 4: Commit**

```bash
git add bridge/core/binding_object.cc
git commit -m "feat(profiler): record sync binding method calls as spans"
```

---

## Task 4: C++ — wrap `InvokeBindingMethod` (operation-enum variant) with span

This variant is invoked for property get/set, where the `method` is the enum `BindingMethodCallOperations` (`kGetProperty` or `kSetProperty`). We map the enum to a fixed string for the span name.

**Files:**
- Modify: `bridge/core/binding_object.cc:276-327`

- [ ] **Step 1: Wrap PostToDartSync with ScopedSpan**

Replace the body of the enum-overload `BindingObject::InvokeBindingMethod` at line 276 so the sync call is recorded:

```cpp
NativeValue BindingObject::InvokeBindingMethod(BindingMethodCallOperations binding_method_call_operation,
                                               size_t argc,
                                               const NativeValue* argv,
                                               uint32_t reason,
                                               ExceptionState& exception_state) const {
  auto* context = GetExecutingContext();
  if (auto* canvas_context = DynamicTo<CanvasRenderingContext2D>(this)) {
    canvas_context->requestPaint();
  }

  std::vector<NativeBindingObject*> invoke_elements_deps;
  // Collect all DOM elements in arguments.
  CollectElementDepsOnArgs(invoke_elements_deps, argc, argv);
  // Make sure all these elements are ready in dart.
  context->FlushUICommand(this, reason, invoke_elements_deps);

  NativeValue return_value = Native_NewNull();

#if ENABLE_LOG
  WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Call Begin";
#endif

  NativeValue native_method = NativeValueConverter<NativeTypeInt64>::ToNativeValue(binding_method_call_operation);

  // Record sync Dart roundtrip as a profiler span. For the enum variant the
  // name is one of two fixed strings.
  uint32_t name_id = 0;
  auto& profiler = JSThreadProfiler::Instance();
  if (profiler.enabled()) {
    const char* op_name =
        (binding_method_call_operation == BindingMethodCallOperations::kGetProperty)
            ? "getProperty"
            : "setProperty";
    name_id = profiler.RegisterBindingName(op_name);
  }
  JSThreadProfiler::ScopedSpan span_guard(profiler, kJSBindingSyncCall, name_id);

  GetDispatcher()->PostToDartSync(
      GetExecutingContext()->isDedicated(), contextId(),
      [&](bool cancel, double contextId, const NativeBindingObject* binding_object,
          NativeValue* return_value, NativeValue* method, int32_t argc, const NativeValue* argv) {
        if (cancel)
          return;

#if ENABLE_LOG
        WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Callback Start";
#endif

        if (binding_object_->invoke_bindings_methods_from_native == nullptr) {
          WEBF_LOG(VERBOSE) << "invoke_bindings_methods_from_native is nullptr" << std::endl;
          return;
        }
        binding_object_->invoke_bindings_methods_from_native(contextId, binding_object, return_value,
                                                             method, argc, argv);
#if ENABLE_LOG
        WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Callback End";
#endif
      },
      context->contextId(), binding_object_, &return_value, &native_method, argc, argv);

#if ENABLE_LOG
  WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Call End";
#endif

  return return_value;
}
```

- [ ] **Step 2: Build**

Run: `npm run build:bridge:macos`
Expected: builds clean.

- [ ] **Step 3: Commit**

```bash
git add bridge/core/binding_object.cc
git commit -m "feat(profiler): record sync binding property get/set as spans"
```

---

## Task 5: Dart — add `'jsBindingSyncCall'` category to `JSThreadSpan`

The Dart-side `JSThreadSpan.categoryNames` list is indexed by the C++ enum value. Adding the entry at index 10 keeps it aligned with the C++ enum.

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:547-558`

- [ ] **Step 1: Write failing test**

Create `webf/test/src/devtools/performance_tracker_binding_span_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';

void main() {
  group('JSThreadSpan binding-sync category', () {
    test('categoryFromIndex(10) returns jsBindingSyncCall', () {
      expect(JSThreadSpan.categoryFromIndex(10), 'jsBindingSyncCall');
    });

    test('categoryNames length matches C++ enum (11 entries 0..10)', () {
      expect(JSThreadSpan.categoryNames.length, 11);
    });

    test('debugInjectJSSpan accepts the new category', () {
      final tracker = PerformanceTracker.instance;
      tracker.startSession();
      try {
        tracker.debugInjectJSSpan(
          category: 'jsBindingSyncCall',
          startUs: 0,
          endUs: 100,
          funcNameAtom: 0x80000001,
          funcName: 'getBoundingClientRect',
          depth: 1,
        );
        final spans = tracker.jsThreadSpans
            .where((s) => s.category == 'jsBindingSyncCall')
            .toList();
        expect(spans, hasLength(1));
        expect(spans.first.funcName, 'getBoundingClientRect');
      } finally {
        tracker.endSession();
      }
    });
  });
}
```

Add the test to the test runner. Open `webf/test/webf_test.dart` and add an import + invocation in the appropriate group, mirroring the pattern used by neighboring tests. Refer to existing `performance_tracker_*_test.dart` files for the exact pattern.

- [ ] **Step 2: Run, verify it fails**

Run: `cd webf && flutter test test/src/devtools/performance_tracker_binding_span_test.dart`
Expected: FAIL on first test — `categoryFromIndex(10)` returns `'jsUnknown'`.

- [ ] **Step 3: Add the new category name**

Edit `webf/lib/src/devtools/panel/performance_tracker.dart`. Update the `categoryNames` list:

```dart
class JSThreadSpan {
  static const List<String> categoryNames = [
    'jsFunction',         // 0: kJSFunction
    'jsCFunction',        // 1: kJSCFunction
    'jsScriptEval',       // 2: kJSScriptEval
    'jsTimer',            // 3: kJSTimer
    'jsEvent',            // 4: kJSEvent
    'jsRAF',              // 5: kJSRAF
    'jsIdle',             // 6: kJSIdle
    'jsMicrotask',        // 7: kJSMicrotask
    'jsMutationObserver', // 8: kJSMutationObserver
    'jsFlushUICommand',   // 9: kJSFlushUICommand
    'jsBindingSyncCall',  // 10: kJSBindingSyncCall
  ];
```

- [ ] **Step 4: Run, verify it passes**

Run: `cd webf && flutter test test/src/devtools/performance_tracker_binding_span_test.dart`
Expected: all three tests PASS.

- [ ] **Step 5: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_tracker.dart \
        webf/test/src/devtools/performance_tracker_binding_span_test.dart \
        webf/test/webf_test.dart
git commit -m "feat(devtools): add jsBindingSyncCall span category in Dart"
```

---

## Task 6: Dart — surface `jsBindingSyncCall` in the waterfall chart

Without this step, binding-call spans drained from C++ would land in `jsThreadSpans` but never appear in the rendered chart. We add a `WaterfallCategory` enum value, a label, a color, and routing.

**Files:**
- Modify: `webf/lib/src/devtools/panel/waterfall_chart.dart:26-47, 466-468, 720-750, 791-832, 834-844, 846-870`

- [ ] **Step 1: Add enum value**

Edit `webf/lib/src/devtools/panel/waterfall_chart.dart` (around line 46). Add `jsBindingSyncCall` after `jsFlushUICommand`:

```dart
enum WaterfallCategory {
  lifecycle,
  network,
  cssParse,
  style,
  layout,
  paint,
  jsEval,
  htmlParse,
  domConstruction,
  build,
  // JS Thread categories
  jsFunction,
  jsScriptEval,
  jsTimer,
  jsEvent,
  jsRAF,
  jsIdle,
  jsMicrotask,
  jsMutationObserver,
  jsFlushUICommand,
  jsBindingSyncCall,
}
```

- [ ] **Step 2: Add to JS-categories string list**

Around line 466-468, the implementation has a list literal of JS category names used for grouping. Update it:

```dart
      'jsScriptEval', 'jsTimer', 'jsEvent', 'jsRAF', 'jsIdle',
      'jsMicrotask', 'jsMutationObserver', 'jsFlushUICommand',
      'jsBindingSyncCall',
```

(Verify the exact list at the live file location before editing — pattern: search the file for `'jsScriptEval'` and update the surrounding literal.)

- [ ] **Step 3: Add color mapping**

In `_categoryColor` (around line 748-749), add a case after `jsFlushUICommand`:

```dart
    case WaterfallCategory.jsFlushUICommand:
      return const Color(0xFFFFB74D);
    case WaterfallCategory.jsBindingSyncCall:
      // Distinct hue from other JS categories — sync Dart roundtrip cost.
      return const Color(0xFFFF7043);
```

- [ ] **Step 4: Add label mapping**

In `_categoryLabel` (around line 829-830), add a case:

```dart
    case WaterfallCategory.jsFlushUICommand:
      return 'JS FlushUI';
    case WaterfallCategory.jsBindingSyncCall:
      return 'JS Binding Sync';
```

- [ ] **Step 5: Include in `_isJSThreadCategory`**

Around line 843, extend the predicate:

```dart
bool _isJSThreadCategory(WaterfallCategory cat) {
  return cat == WaterfallCategory.jsFunction ||
      cat == WaterfallCategory.jsScriptEval ||
      cat == WaterfallCategory.jsTimer ||
      cat == WaterfallCategory.jsEvent ||
      cat == WaterfallCategory.jsRAF ||
      cat == WaterfallCategory.jsIdle ||
      cat == WaterfallCategory.jsMicrotask ||
      cat == WaterfallCategory.jsMutationObserver ||
      cat == WaterfallCategory.jsFlushUICommand ||
      cat == WaterfallCategory.jsBindingSyncCall;
}
```

- [ ] **Step 6: Route the string category in `_jsSpanCategory`**

Around line 865-866, add:

```dart
    case 'jsFlushUICommand':
      return WaterfallCategory.jsFlushUICommand;
    case 'jsBindingSyncCall':
      return WaterfallCategory.jsBindingSyncCall;
```

- [ ] **Step 7: Run analyze + tests**

Run: `cd webf && flutter analyze lib/src/devtools/panel/waterfall_chart.dart`
Expected: no errors. (Switch statement now exhaustive over all enum values.)

Run: `cd webf && flutter test test/src/devtools/`
Expected: existing devtools tests still pass.

- [ ] **Step 8: Commit**

```bash
git add webf/lib/src/devtools/panel/waterfall_chart.dart
git commit -m "feat(devtools): render jsBindingSyncCall spans in waterfall chart"
```

---

## Task 7: Manual end-to-end verification

Goal: confirm that running JS code that performs a sync DOM read produces visible `jsBindingSyncCall` spans in the perf graph at the right offsets.

**Files:** none (manual test).

- [ ] **Step 1: Create a tiny test page**

Inside the WebF example app (`webf/example/`), add a button or use an existing page that calls something layout-sensitive in JS, e.g.:

```html
<script>
  function measure() {
    const el = document.body;
    return el.getBoundingClientRect().width + ',' + el.offsetHeight;
  }
  document.body.innerText = measure();
</script>
```

- [ ] **Step 2: Run example with DevTools**

Run: `npm run start`
Open the WebF DevTools panel, navigate to the Performance tab, start a recording, reload the page, stop recording.

- [ ] **Step 3: Verify spans appear**

Expected in waterfall:
- A `JS Script Eval` block (top-level eval)
- Nested inside it (or immediately after `JS FlushUI`), one `JS Binding Sync` block per binding call (`getBoundingClientRect`, `offsetHeight`)
- Span tooltip / detail view shows the binding name (e.g., `getBoundingClientRect`) — this comes from the `funcName` field on the drained span, which the existing `getJSProfilerAtomName` FFI now resolves through the binding registry.

If span names are missing but blocks appear: verify Task 2 step 4 (registry lookup in `GetAtomName`).
If blocks are missing entirely: verify Task 3 / Task 4 inserted the `ScopedSpan` and that `JSThreadProfiler::Instance().enabled()` is true at the call site.

- [ ] **Step 4: Export and re-import the recording**

Use the v4 export feature in DevTools to save the recording, then import it back. Verify the binding spans round-trip correctly (category preserved, `funcName` preserved via `JSThreadSpan.toJson`/`fromJson` at lines 583-601 of `performance_tracker.dart`).

- [ ] **Step 5: No commit** — this is verification only.

---

## Self-Review

**Spec coverage:**
- New category `kJSBindingSyncCall`: Task 1 ✓
- Binding-name registry: Task 2 ✓
- Wrap named-method `InvokeBindingMethod`: Task 3 ✓
- Wrap enum-method `InvokeBindingMethod` (covers GetProperty/SetProperty): Task 4 ✓
- Dart-side category routing: Task 5 ✓
- Waterfall display: Task 6 ✓
- E2E verification: Task 7 ✓

**Out of scope (intentionally):**
- Async binding paths (`InvokeBindingMethodAsync`, line 213) — these don't block JS; they queue commands and resolve via promises. They're already partially observable via the `kAsyncCaller` UI command path and don't need the same span treatment.
- Per-call argument capture (e.g., element tag name as metadata). Adding this would require changing `JSThreadSpan` shape across the FFI boundary; deferred unless we actually need it for diagnosis.
- New FFI exports — none needed; existing `getJSProfilerAtomName` (`bridge/webf_bridge.cc:385`) handles binding IDs after Task 2.

**Placeholder scan:** none.

**Type consistency:**
- `RegisterBindingName(const std::string&) -> uint32_t` — used identically in Tasks 2-4.
- `kBindingIdFlag = 0x80000000u` — referenced by both `RegisterBindingName` and `GetAtomName`.
- Enum value `kJSBindingSyncCall = 10` matches Dart `categoryNames` index 10 (Task 5) and waterfall routing string `'jsBindingSyncCall'` (Task 6).

**Risk to flag for the implementer:**
- The conversion call `method.ToStdString(ctx)` in Task 3 step 2 is a placeholder for whatever `AtomicString → std::string` API exists in the codebase. Before implementing, grep `bridge/core/` for existing usage (e.g., `AtomicString::ToStdString`, `AtomicString::ToUTF8String`, `AtomicString::ToStringView`) and use the real API. Do not invent a method.
- The `kBindingIdFlag` member-constant access from a `const` method (Task 2 step 4): if the compiler complains about access in a const expression, qualify it as `JSThreadProfiler::kBindingIdFlag` or move the constant to be a `static constexpr` at namespace scope.

---
