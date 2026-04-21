# Performance Recording Clock Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate timeline drift between Dart-recorded phases/spans and C++-recorded JS thread spans by unifying both sides on `steady_clock` and applying a one-time offset at session start.

**Architecture:** C++ already uses `std::chrono::steady_clock` for JS span timing. Dart currently uses `DateTime.now()` (wall-clock). Fix: (1) expose a new `getSteadyClockNowUs` FFI; (2) in `PerformanceTracker.startSession`, start a Dart `Stopwatch` and read the C++ steady_clock to derive `_cppToDartOffsetUs`; (3) apply that offset when draining JS spans; (4) add `offsetUs` fields alongside existing `DateTime` on `PerformanceSpan`, `LoadingPhase`, and `NavigationMetrics` — DateTime stays for API compat but is derived from monotonic offset; (5) bump export format version and switch serialization to `offsetUs`.

**Tech Stack:** C++17 (bridge), Dart/Flutter (webf package), FFI.

**Spec:** `docs/superpowers/specs/2026-04-18-perf-recording-clock-alignment-design.md`

---

## File Structure

**Modified:**
- `bridge/core/profiling/js_thread_profiler.h` — add `SteadyClockNowUs()` method declaration
- `bridge/core/profiling/js_thread_profiler.cc` — implement `SteadyClockNowUs()`
- `bridge/include/webf_bridge.h` — declare C export
- `bridge/webf_bridge.cc` — implement C export forwarding to `JSThreadProfiler::SteadyClockNowUs()`
- `webf/lib/src/bridge/to_native.dart` — add Dart binding for `getSteadyClockNowUs`
- `webf/lib/src/devtools/panel/performance_tracker.dart` — stopwatch-based session, offset math, apply correction on drain, `offsetUs` fields on `PerformanceSpan`/`ExportablePhase`, export version bump
- `webf/lib/src/launcher/loading_state.dart` — `LoadingPhase.offsetUs`, `recordPhase`/`recordPhaseStart` capture offset via tracker stopwatch
- `webf/lib/src/launcher/controller.dart` — FP/FCP/LCP use monotonic delta; `NavigationMetrics.navigationStartOffsetUs`
- `webf/lib/src/devtools/panel/waterfall_chart.dart` — `_buildWaterfallDataImpl` derives offsets from `offsetUs` when available

**Created (tests):**
- `webf/test/src/devtools/performance_tracker_clock_sync_test.dart` — unit tests for sync math + drain correction

No new runtime source files. This is a cross-cutting change within existing modules.

---

## Task 1: C++ — add `SteadyClockNowUs()` to `JSThreadProfiler`

**Files:**
- Modify: `bridge/core/profiling/js_thread_profiler.h:52`
- Modify: `bridge/core/profiling/js_thread_profiler.cc:43-45`

**Why:** Dart needs the absolute `steady_clock` time at a known instant so it can derive `_stopwatchStartAbsUs` (the anchor that converts C++ µs offsets into Dart stopwatch µs offsets).

- [ ] **Step 1: Add method declaration**

In `bridge/core/profiling/js_thread_profiler.h`, after line 52 (`int64_t SessionStartUs() const;`), add:

```cpp
  // Absolute steady_clock time in microseconds (time_since_epoch).
  // Safe to call regardless of enabled state.
  static int64_t SteadyClockNowUs();
```

Mark it `static` — it does not need the singleton instance.

- [ ] **Step 2: Implement method**

In `bridge/core/profiling/js_thread_profiler.cc`, after line 45 (end of `SessionStartUs`), add:

```cpp
int64_t JSThreadProfiler::SteadyClockNowUs() {
  auto now = std::chrono::steady_clock::now();
  return std::chrono::duration_cast<std::chrono::microseconds>(now.time_since_epoch()).count();
}
```

- [ ] **Step 3: Commit**

```bash
git add bridge/core/profiling/js_thread_profiler.h bridge/core/profiling/js_thread_profiler.cc
git commit -m "feat(bridge): add JSThreadProfiler::SteadyClockNowUs for clock sync"
```

---

## Task 2: C++ — export `getSteadyClockNowUs` via C bridge

**Files:**
- Modify: `bridge/include/webf_bridge.h:178` (after existing `getJSProfilerSessionStartUs` declaration)
- Modify: `bridge/webf_bridge.cc:370` (after existing `getJSProfilerSessionStartUs` definition)

- [ ] **Step 1: Add header declaration**

In `bridge/include/webf_bridge.h`, insert after line 178 (after `WEBF_EXPORT_C int64_t getJSProfilerSessionStartUs();`):

```c
WEBF_EXPORT_C int64_t getSteadyClockNowUs();
```

- [ ] **Step 2: Add C implementation**

In `bridge/webf_bridge.cc`, insert after the closing `}` of `getJSProfilerSessionStartUs` (after line 370):

```cpp
int64_t getSteadyClockNowUs() {
  return webf::JSThreadProfiler::SteadyClockNowUs();
}
```

- [ ] **Step 3: Build macOS to verify C++ compiles**

Run: `npm run build:bridge:macos`
Expected: Build completes without errors, produces updated `webf_bridge.dylib`.

- [ ] **Step 4: Commit**

```bash
git add bridge/include/webf_bridge.h bridge/webf_bridge.cc
git commit -m "feat(bridge): export getSteadyClockNowUs C FFI"
```

---

## Task 3: Dart — FFI binding for `getSteadyClockNowUs`

**Files:**
- Modify: `webf/lib/src/bridge/to_native.dart:875` (after `getJSProfilerSessionStartUs`)

- [ ] **Step 1: Add typedef + binding**

In `webf/lib/src/bridge/to_native.dart`, insert after line 874 (the closing brace of the `getJSProfilerSessionStartUs()` function):

```dart
typedef NativeGetSteadyClockNowUs = Int64 Function();
typedef DartGetSteadyClockNowUs = int Function();

final DartGetSteadyClockNowUs _getSteadyClockNowUs =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeGetSteadyClockNowUs>>('getSteadyClockNowUs').asFunction();

int getSteadyClockNowUs() {
  return _getSteadyClockNowUs();
}
```

- [ ] **Step 2: Quick sanity run — make sure the lookup succeeds**

Run: `cd webf && flutter analyze lib/src/bridge/to_native.dart`
Expected: No analyzer errors.

- [ ] **Step 3: Commit**

```bash
git add webf/lib/src/bridge/to_native.dart
git commit -m "feat(bridge): add getSteadyClockNowUs Dart FFI binding"
```

---

## Task 4: PerformanceTracker — add stopwatch + clock sync in `startSession`

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:191-215`
- Test: `webf/test/src/devtools/performance_tracker_clock_sync_test.dart` (new)

**Why:** The one-time sync in `startSession` establishes `_cppToDartOffsetUs`. All later math depends on this being correct.

- [ ] **Step 1: Write the failing test**

Create `webf/test/src/devtools/performance_tracker_clock_sync_test.dart`:

```dart
/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';

void main() {
  group('PerformanceTracker clock sync', () {
    setUp(() {
      PerformanceTracker.instance.clear();
    });

    test('startSession starts a monotonic stopwatch', () {
      final tracker = PerformanceTracker.instance;
      tracker.startSession();

      final first = tracker.nowOffsetUs();
      // Busy-wait ~1ms so stopwatch advances.
      final end = DateTime.now().add(const Duration(milliseconds: 1));
      while (DateTime.now().isBefore(end)) {}
      final second = tracker.nowOffsetUs();

      expect(second, greaterThan(first),
          reason: 'Stopwatch must advance monotonically');
      expect(second - first, greaterThan(500),
          reason: 'Expected >500µs after ~1ms busy wait');

      tracker.endSession();
    });

    test('startSession records a non-zero C++→Dart offset after FFI sync',
        () {
      final tracker = PerformanceTracker.instance;
      tracker.startSession();
      // The offset is the delta between C++ session_start_ and the Dart
      // stopwatch anchor. It is a constant for the session and must be
      // populated (not null) after startSession() completes.
      expect(tracker.cppToDartOffsetUsForTest, isNotNull);
      tracker.endSession();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd webf && flutter test test/src/devtools/performance_tracker_clock_sync_test.dart`
Expected: FAIL with `nowOffsetUs` / `cppToDartOffsetUsForTest` undefined.

- [ ] **Step 3: Modify imports and add fields**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, the top imports (line 14-19) stay. Change the `PerformanceTracker` class body (lines 176-215) to:

```dart
class PerformanceTracker {
  PerformanceTracker._();

  static final PerformanceTracker instance = PerformanceTracker._();

  /// Whether span recording is active. When false, [beginSpan] returns null immediately.
  bool enabled = false;

  /// Top-level spans (not children of any other span).
  final List<PerformanceSpan> rootSpans = [];

  /// JS thread spans collected from the C++ profiler.
  final List<JSThreadSpan> jsThreadSpans = [];

  /// Dart session start time, used for display and export header only.
  /// All timing math uses the monotonic stopwatch below.
  DateTime? sessionStart;

  /// Monotonic clock source. Started once in [startSession].
  Stopwatch? _stopwatch;

  /// Absolute C++ steady_clock microseconds captured at the instant the Dart
  /// stopwatch was started. Derived from `getSteadyClockNowUs()` and the
  /// stopwatch's elapsed at that instant. Constant for the session.
  int? _stopwatchStartAbsUs;

  /// Absolute C++ steady_clock microseconds of the C++ profiler's
  /// `session_start_`. Read via `getJSProfilerSessionStartUs()`.
  int? _cppSessionStartAbsUs;

  /// Delta to add to C++-reported JS span offsets (which are relative to
  /// `_cppSessionStartAbsUs`) to convert them into offsets relative to
  /// `_stopwatchStartAbsUs`. Constant for the session.
  int? _cppToDartOffsetUs;

  /// Currently active span (acts as call stack via parent pointer).
  PerformanceSpan? _currentSpan;

  int _totalSpanCount = 0;

  /// Maximum number of spans to record per session to prevent memory issues.
  static const int maxSpans = 10000;

  /// Current monotonic offset from session start, in microseconds.
  /// Returns 0 if session has not started.
  int nowOffsetUs() => _stopwatch?.elapsedMicroseconds ?? 0;

  /// Offset to apply when converting a C++ JS span offset into a
  /// Dart-timeline offset. Visible for testing.
  @visibleForTesting
  int? get cppToDartOffsetUsForTest => _cppToDartOffsetUs;

  /// Start a new recording session. Clears all previous spans.
  void startSession() {
    sessionStart = DateTime.now();
    rootSpans.clear();
    jsThreadSpans.clear();
    _currentSpan = null;
    _totalSpanCount = 0;
    enabled = true;

    // Step A: start Dart stopwatch, read C++ steady_clock, compute
    // `_stopwatchStartAbsUs` as the absolute steady_clock microseconds at
    // which the stopwatch started.
    final sw = Stopwatch()..start();
    final syncAbsUs = to_native.getSteadyClockNowUs();
    final syncElapsedUs = sw.elapsedMicroseconds;
    _stopwatch = sw;
    _stopwatchStartAbsUs = syncAbsUs - syncElapsedUs;

    // Step B: enable C++ profiling (this captures C++ session_start_).
    to_native.setJSThreadProfilingEnabled(true);
    _cppSessionStartAbsUs = to_native.getJSProfilerSessionStartUs();
    _cppToDartOffsetUs = _cppSessionStartAbsUs! - _stopwatchStartAbsUs!;
  }
```

Add the import needed for `@visibleForTesting` — at the top of the file add:

```dart
import 'package:meta/meta.dart';
```

(insert alphabetically among the other imports — after `import 'dart:convert';` or similar).

- [ ] **Step 4: Run the test to verify it passes**

Run: `cd webf && flutter test test/src/devtools/performance_tracker_clock_sync_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_tracker.dart webf/test/src/devtools/performance_tracker_clock_sync_test.dart
git commit -m "feat(devtools): add monotonic stopwatch and C++ clock sync to PerformanceTracker"
```

---

## Task 5: PerformanceTracker — fix `drainJSThreadSpans` with offset correction

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:233-271` (and `endSession` on line 218)
- Test: same file as Task 4

**Why:** This is the visible fix — every drained JS span gets `_cppToDartOffsetUs` applied so it lands correctly on the shared Dart timeline.

- [ ] **Step 1: Add failing test for offset correction**

Append to `webf/test/src/devtools/performance_tracker_clock_sync_test.dart` inside the same `group(...)`:

```dart
    test('drainJSThreadSpans applies cppToDartOffsetUs to native spans', () {
      final tracker = PerformanceTracker.instance;
      tracker.startSession();
      final offsetUs = tracker.cppToDartOffsetUsForTest!;

      // Simulate a C++ span at offset 1_000_000 µs (1s after C++ session_start_).
      // After correction it should sit at 1_000_000 + offsetUs relative to
      // the Dart stopwatch anchor.
      tracker.debugInjectJSSpan(
        category: 'jsScriptEval',
        startUs: 1000000,
        endUs: 1500000,
      );

      expect(tracker.jsThreadSpans, hasLength(1));
      final s = tracker.jsThreadSpans.first;
      expect(s.startOffset.inMicroseconds, 1000000 + offsetUs);
      expect(s.endOffset.inMicroseconds, 1500000 + offsetUs);

      tracker.endSession();
    });
```

Run: `cd webf && flutter test test/src/devtools/performance_tracker_clock_sync_test.dart`
Expected: FAIL (`debugInjectJSSpan` undefined).

- [ ] **Step 2: Apply offset correction in `drainJSThreadSpans`**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, replace the body of `drainJSThreadSpans` (lines 231-271). The new body:

```dart
  /// Drain JS thread profiling spans from the C++ ring buffer.
  /// Called during flushUICommand and at session end.
  ///
  /// C++ spans arrive as microsecond offsets from the C++ profiler's
  /// `session_start_`. We shift them by [_cppToDartOffsetUs] so they land on
  /// the shared Dart timeline (rooted at the stopwatch start).
  void drainJSThreadSpans() {
    if (!enabled && jsThreadSpans.isEmpty && _stopwatch == null) return;
    final offsetUs = _cppToDartOffsetUs ?? 0;

    const maxDrain = 4096;
    final buffer = calloc<NativeJSThreadSpan>(maxDrain);
    try {
      final count = to_native.drainJSThreadProfilingSpans(buffer, maxDrain);
      if (count <= 0) return;

      // Cache resolved atom names to avoid repeated FFI calls
      final atomNameCache = <int, String>{};

      for (int i = 0; i < count; i++) {
        final native = buffer[i];
        // Shift C++ offsets onto the Dart monotonic timeline.
        final startOffsetUs = native.startUs + offsetUs;
        final endOffsetUs = native.endUs + offsetUs;

        // Resolve function name from atom
        final atom = native.funcNameAtom;
        String funcName = '';
        if (atom != 0) {
          funcName = atomNameCache[atom] ??= to_native.getJSProfilerAtomName(atom);
        }

        jsThreadSpans.add(JSThreadSpan(
          category: JSThreadSpan.categoryFromIndex(native.category),
          startOffset: Duration(microseconds: startOffsetUs),
          endOffset: Duration(microseconds: endOffsetUs),
          funcNameAtom: atom,
          funcName: funcName,
          depth: native.depth,
        ));
      }
    } finally {
      calloc.free(buffer);
    }
  }
```

- [ ] **Step 3: Add `debugInjectJSSpan` test helper**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, right after the `drainJSThreadSpans` method, add:

```dart
  /// Test-only: inject a JS span as if it had just been drained from C++.
  /// `startUs` and `endUs` are C++ offsets (from C++ session_start_); this
  /// helper applies [_cppToDartOffsetUs] the same way [drainJSThreadSpans]
  /// would, so tests exercise the real correction math.
  @visibleForTesting
  void debugInjectJSSpan({
    required String category,
    required int startUs,
    required int endUs,
    int funcNameAtom = 0,
    String funcName = '',
    int depth = 0,
  }) {
    final offsetUs = _cppToDartOffsetUs ?? 0;
    jsThreadSpans.add(JSThreadSpan(
      category: category,
      startOffset: Duration(microseconds: startUs + offsetUs),
      endOffset: Duration(microseconds: endUs + offsetUs),
      funcNameAtom: funcNameAtom,
      funcName: funcName,
      depth: depth,
    ));
  }
```

Also: remove the now-unused `_dartSessionStart` field (line 191) and its assignment on line 207. Replace `_dartSessionStart == null` checks with `_stopwatch == null` if any remain (only `drainJSThreadSpans` referenced it; already handled above). Similarly, `endSession()` (line 218) should close spans using monotonic timestamps:

Replace `endSession()` body (lines 217-229) with:

```dart
  /// End the current recording session. Spans are preserved for reading.
  void endSession() {
    enabled = false;
    // Drain any remaining JS spans
    drainJSThreadSpans();
    // Disable C++ JS thread profiling
    to_native.setJSThreadProfilingEnabled(false);
    // Close any unclosed spans using the monotonic clock.
    final nowUs = nowOffsetUs();
    while (_currentSpan != null) {
      _currentSpan!.endOffsetUs ??= nowUs;
      _currentSpan = _currentSpan!.parent;
    }
  }
```

(`endOffsetUs` is added on `PerformanceSpan` in Task 6. If executing this plan in order, Task 6 follows immediately; keep this change — it will compile once Task 6 lands. If you're running these as discrete commits, do Task 6 first or merge Task 5 + Task 6 into one commit.)

**Simpler sequencing:** merge Task 5 and Task 6 into one commit. Proceed with Task 6 below before running tests.

- [ ] **Step 4: Defer test run until Task 6 compiles**

Do not run tests yet — `endOffsetUs` on `PerformanceSpan` is added in Task 6.

- [ ] **Step 5: Commit (after Task 6 lands)** — see Task 6 for combined commit.

---

## Task 6: PerformanceSpan — add `startOffsetUs`/`endOffsetUs`, switch `beginSpan` to stopwatch

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:22-127` (PerformanceSpan class)
- Modify: same file, `PerformanceSpanHandle.end` (line 137), `AsyncPerformanceSpanHandle.end` (line 156), `beginSpan` (line 284), `beginAsyncSpan` (line 314)
- Test: `webf/test/src/devtools/performance_tracker_clock_sync_test.dart`

- [ ] **Step 1: Append failing test**

Append to the test file (inside the same `group`):

```dart
    test('beginSpan records offsetUs from monotonic clock', () {
      final tracker = PerformanceTracker.instance;
      tracker.startSession();

      final before = tracker.nowOffsetUs();
      final handle = tracker.beginSpan('layout', 'flexLayout');
      expect(handle, isNotNull);
      handle!.end();
      final after = tracker.nowOffsetUs();

      expect(tracker.rootSpans, hasLength(1));
      final span = tracker.rootSpans.first;
      expect(span.startOffsetUs, greaterThanOrEqualTo(before));
      expect(span.endOffsetUs, isNotNull);
      expect(span.endOffsetUs!, greaterThanOrEqualTo(span.startOffsetUs));
      expect(span.endOffsetUs!, lessThanOrEqualTo(after));

      tracker.endSession();
    });
```

Run: `cd webf && flutter test test/src/devtools/performance_tracker_clock_sync_test.dart`
Expected: FAIL — `startOffsetUs` undefined.

- [ ] **Step 2: Modify `PerformanceSpan`**

Replace the `PerformanceSpan` class body (lines 22-127) with:

```dart
/// Represents a single performance span in the rendering pipeline.
///
/// Primary timestamps are `startOffsetUs` / `endOffsetUs` — microseconds
/// from the [PerformanceTracker] session start, captured from a monotonic
/// stopwatch. `startTime`/`endTime` remain as derived `DateTime` values for
/// API compatibility with existing consumers.
class PerformanceSpan {
  final String category;
  final String name;

  /// Monotonic offset from session start, in microseconds.
  final int startOffsetUs;

  /// Monotonic offset at span end. Null while the span is still open.
  int? endOffsetUs;

  final int depth;
  final PerformanceSpan? parent;
  final List<PerformanceSpan> children = [];
  Map<String, dynamic>? metadata;

  /// Wall-clock anchor, used to derive [startTime] / [endTime]. Captured at
  /// [PerformanceTracker.sessionStart].
  final DateTime _sessionAnchor;

  PerformanceSpan({
    required this.category,
    required this.name,
    required this.startOffsetUs,
    required this.depth,
    required DateTime sessionAnchor,
    this.parent,
    this.metadata,
  }) : _sessionAnchor = sessionAnchor;

  /// Derived wall-clock start time (anchor + offset).
  DateTime get startTime =>
      _sessionAnchor.add(Duration(microseconds: startOffsetUs));

  /// Derived wall-clock end time, or null if span still open.
  DateTime? get endTime => endOffsetUs == null
      ? null
      : _sessionAnchor.add(Duration(microseconds: endOffsetUs!));

  Duration get duration => endOffsetUs != null
      ? Duration(microseconds: endOffsetUs! - startOffsetUs)
      : Duration.zero;

  /// Time spent in this span excluding children.
  Duration get selfDuration {
    final childTotal =
        children.fold<Duration>(Duration.zero, (sum, c) => sum + c.duration);
    final d = duration - childTotal;
    return d.isNegative ? Duration.zero : d;
  }

  bool get isComplete => endOffsetUs != null;

  /// Total number of spans in this subtree (including self).
  int get subtreeCount {
    int count = 1;
    for (final child in children) {
      count += child.subtreeCount;
    }
    return count;
  }

  /// Maximum depth in this subtree.
  int get maxDepth {
    int max = depth;
    for (final child in children) {
      final childMax = child.maxDepth;
      if (childMax > max) max = childMax;
    }
    return max;
  }

  List<PerformanceSpan> spansAtDepth(int targetDepth) {
    final result = <PerformanceSpan>[];
    _collectAtDepth(targetDepth, result);
    return result;
  }

  void _collectAtDepth(int targetDepth, List<PerformanceSpan> result) {
    if (depth == targetDepth) {
      result.add(this);
      return;
    }
    for (final child in children) {
      child._collectAtDepth(targetDepth, result);
    }
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'name': name,
        'startOffsetUs': startOffsetUs,
        'endOffsetUs': endOffsetUs,
        'depth': depth,
        if (metadata != null && metadata!.isNotEmpty) 'metadata': metadata,
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
      };

  static PerformanceSpan fromJson(Map<String, dynamic> json,
      {PerformanceSpan? parent, required DateTime sessionAnchor}) {
    final span = PerformanceSpan(
      category: json['category'] as String,
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
}
```

- [ ] **Step 3: Update `PerformanceSpanHandle.end` and `AsyncPerformanceSpanHandle.end`**

Replace `PerformanceSpanHandle.end` (line 137) with:

```dart
  /// End this span and pop back to the parent span.
  void end({Map<String, dynamic>? metadata}) {
    _span.endOffsetUs = _tracker.nowOffsetUs();
    if (metadata != null) {
      _span.metadata = (_span.metadata ?? {})..addAll(metadata);
    }
    _tracker._currentSpan = _span.parent;
  }
```

Replace `AsyncPerformanceSpanHandle.end` (line 156) with:

```dart
  void end({Map<String, dynamic>? metadata}) {
    _span.endOffsetUs = PerformanceTracker.instance.nowOffsetUs();
    if (metadata != null) {
      _span.metadata = (_span.metadata ?? {})..addAll(metadata);
    }
  }
```

- [ ] **Step 4: Update `beginSpan` and `beginAsyncSpan`**

Replace `beginSpan` body (lines 284-306) with:

```dart
  PerformanceSpanHandle? beginSpan(String category, String name,
      {Map<String, dynamic>? metadata}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;
    final anchor = sessionStart;
    if (anchor == null) return null;

    final span = PerformanceSpan(
      category: category,
      name: name,
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

Replace `beginAsyncSpan` body (lines 314-330) with:

```dart
  AsyncPerformanceSpanHandle? beginAsyncSpan(String category, String name,
      {Map<String, dynamic>? metadata}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;
    final anchor = sessionStart;
    if (anchor == null) return null;

    final span = PerformanceSpan(
      category: category,
      name: name,
      startOffsetUs: nowOffsetUs(),
      depth: 0,
      sessionAnchor: anchor,
      parent: null,
      metadata: metadata,
    );

    rootSpans.add(span);
    _totalSpanCount++;
    return AsyncPerformanceSpanHandle._(span);
  }
```

- [ ] **Step 5: Update `importFromJson` to pass sessionAnchor**

In `importFromJson` (line 382), after restoring `sessionStart`, change the spans loop (line 394-398) to:

```dart
    final anchor = sessionStart ?? DateTime.now();
    final spans = data['rootSpans'] as List;
    for (final spanJson in spans) {
      rootSpans.add(PerformanceSpan.fromJson(
        spanJson as Map<String, dynamic>,
        sessionAnchor: anchor,
      ));
    }
```

- [ ] **Step 6: Run all performance tracker tests**

Run: `cd webf && flutter test test/src/devtools/performance_tracker_clock_sync_test.dart`
Expected: PASS (all four tests).

- [ ] **Step 7: Run full webf test suite to catch downstream breakage**

Run: `cd webf && flutter test`
Expected: Any failures will flag consumers of `PerformanceSpan.startTime`/`endTime`. Since those are retained as derived getters, the most likely breakage is anyone *constructing* a `PerformanceSpan` manually. Fix those to pass `startOffsetUs` + `sessionAnchor` instead of `startTime`.

- [ ] **Step 8: Commit Tasks 5 and 6 together**

```bash
git add webf/lib/src/devtools/panel/performance_tracker.dart webf/test/src/devtools/performance_tracker_clock_sync_test.dart
git commit -m "feat(devtools): switch PerformanceSpan to monotonic offsetUs; fix JS span drift

- PerformanceSpan gains startOffsetUs/endOffsetUs as primary timestamps.
- startTime/endTime retained as derived DateTime for API compat.
- drainJSThreadSpans now shifts C++ offsets by _cppToDartOffsetUs,
  aligning JS spans with Dart spans on one shared timeline.
- Export JSON format switches to *OffsetUs (breaking — v4)."
```

---

## Task 7: LoadingPhase — add `offsetUs`

**Files:**
- Modify: `webf/lib/src/launcher/loading_state.dart:11-30` (LoadingPhase class)
- Modify: `webf/lib/src/launcher/loading_state.dart:1776-1826` (recordPhase, recordPhaseStart)

**Why:** Phases like `attachToFlutter` and `firstPaint` drive waterfall phase boundaries. They must share the monotonic timeline.

- [ ] **Step 1: Update `LoadingPhase` to carry `offsetUs`**

Replace lines 11-30 of `webf/lib/src/launcher/loading_state.dart` with:

```dart
/// Represents a single phase in the WebFController loading lifecycle
class LoadingPhase {
  final String name;
  final DateTime timestamp;

  /// Monotonic offset from the tracker session start, in microseconds.
  /// Null only when the phase was constructed outside a performance session
  /// (e.g., fallback `orElse` placeholders).
  final int? offsetUs;

  final Map<String, dynamic> parameters;
  final Duration? duration;
  final List<LoadingPhase> substeps = [];
  final String? parentPhase;

  LoadingPhase({
    required this.name,
    required this.timestamp,
    this.offsetUs,
    Map<String, dynamic>? parameters,
    this.duration,
    this.parentPhase,
  }) : parameters = parameters ?? {};

  void addSubstep(LoadingPhase substep) {
    substeps.add(substep);
  }
}
```

- [ ] **Step 2: Update `recordPhase` to capture `offsetUs`**

At the top of `webf/lib/src/launcher/loading_state.dart`, add import:

```dart
import 'package:webf/src/devtools/panel/performance_tracker.dart';
```

(Place it alphabetically among other imports. If a circular-import issue arises, import only the `PerformanceTracker` symbol — e.g. via `show PerformanceTracker`.)

Replace the body of `recordPhase` (line 1776-1811) with:

```dart
  /// Records a loading phase with optional parameters
  void recordPhase(String phaseName, {Map<String, dynamic>? parameters, String? parentPhase}) {
    final now = DateTime.now();
    final duration =
        _lastPhaseTime != null ? now.difference(_lastPhaseTime!) : null;

    final tracker = PerformanceTracker.instance;
    final offsetUs = tracker.sessionStart != null ? tracker.nowOffsetUs() : null;

    final phase = LoadingPhase(
      name: phaseName,
      timestamp: now,
      offsetUs: offsetUs,
      parameters: parameters,
      duration: duration,
      parentPhase: parentPhase,
    );

    // Special handling for LCP candidates
    if (phaseName == phaseLargestContentfulPaint && !_lcpFinalized) {
      _lastLcpCandidate = phase;
      if (parameters?['isFinal'] == true) {
        _lcpFinalized = true;
        _phases[phaseName] = phase;
      }
    } else if (parentPhase != null && _phases.containsKey(parentPhase)) {
      _phases[parentPhase]!.addSubstep(phase);
    } else {
      _phases[phaseName] = phase;
    }

    _lastPhaseTime = now;
    _dispatchPhaseEvent(phase);
  }
```

- [ ] **Step 3: Run webf tests**

Run: `cd webf && flutter test`
Expected: PASS. Any test reading `phase.timestamp` continues to work unchanged; `offsetUs` is additive.

- [ ] **Step 4: Commit**

```bash
git add webf/lib/src/launcher/loading_state.dart
git commit -m "feat(launcher): add offsetUs to LoadingPhase for monotonic timeline alignment"
```

---

## Task 8: NavigationMetrics — monotonic FP/FCP/LCP

**Files:**
- Modify: `webf/lib/src/launcher/controller.dart:77` (`RoutePerformanceMetrics` class — search for `DateTime? navigationStartTime;`)
- Modify: `webf/lib/src/launcher/controller.dart:639, 1005, 1826` (`navigationStartTime = DateTime.now()`)
- Modify: `webf/lib/src/launcher/controller.dart:1876-2012` (LCP, FCP, FP reporting blocks)

**Why:** FP/FCP/LCP `double ms` values are the public API the user sees — they should be drift-free.

- [ ] **Step 1: Add `navigationStartOffsetUs` field**

Find the `RoutePerformanceMetrics` class in `webf/lib/src/launcher/controller.dart` (around line 77). Add below `DateTime? navigationStartTime;`:

```dart
  /// Monotonic offset (from [PerformanceTracker.sessionStart]) at which this
  /// route's navigation began. Drift-free companion to [navigationStartTime].
  int? navigationStartOffsetUs;
```

- [ ] **Step 2: Populate `navigationStartOffsetUs` at every assignment site**

At each of lines 639, 1005, 1826 where `navigationStartTime = DateTime.now()` is set, add below it (same `metrics` receiver):

```dart
metrics.navigationStartOffsetUs =
    PerformanceTracker.instance.sessionStart != null
        ? PerformanceTracker.instance.nowOffsetUs()
        : null;
```

Example — replace line 639:

Before:
```dart
_routeMetrics[routePath]!.navigationStartTime = DateTime.now();
```

After:
```dart
_routeMetrics[routePath]!.navigationStartTime = DateTime.now();
_routeMetrics[routePath]!.navigationStartOffsetUs =
    PerformanceTracker.instance.sessionStart != null
        ? PerformanceTracker.instance.nowOffsetUs()
        : null;
```

Apply the same pattern for lines 1005 and 1826.

Make sure `PerformanceTracker` is imported — add at the top of the file if not already:

```dart
import 'package:webf/src/devtools/panel/performance_tracker.dart';
```

- [ ] **Step 3: Helper to compute monotonic delta**

At the end of the `WebFController` class, add a private helper:

```dart
  double? _monotonicDeltaMs(RoutePerformanceMetrics metrics) {
    final startUs = metrics.navigationStartOffsetUs;
    if (startUs == null) return null;
    final tracker = PerformanceTracker.instance;
    if (tracker.sessionStart == null) return null;
    return (tracker.nowOffsetUs() - startUs) / 1000.0;
  }
```

- [ ] **Step 4: Replace FP/FCP/LCP time math to use the monotonic helper**

In `reportFP()` (line 1986), replace the block:
```dart
    _loadingState.recordPhase(LoadingState.phaseFirstPaint, parameters: {
      'timeSinceNavigationStart': DateTime.now().difference(metrics.navigationStartTime!).inMilliseconds,
    });

    metrics.fpReported = true;
    metrics.fpTime = DateTime.now().difference(metrics.navigationStartTime!).inMilliseconds.toDouble();
```

With:
```dart
    final deltaMs = _monotonicDeltaMs(metrics)
        ?? DateTime.now().difference(metrics.navigationStartTime!).inMilliseconds.toDouble();
    _loadingState.recordPhase(LoadingState.phaseFirstPaint, parameters: {
      'timeSinceNavigationStart': deltaMs.round(),
    });

    metrics.fpReported = true;
    metrics.fpTime = deltaMs;
```

Apply identical pattern to `reportFCP()` (line 1959) with `phaseFirstContentfulPaint` and `metrics.fcpTime`.

For LCP at line 1892:
Before:
```dart
      final lcpTime = DateTime.now().difference(metrics.navigationStartTime!).inMilliseconds.toDouble();
```

After:
```dart
      final lcpTime = _monotonicDeltaMs(metrics)
          ?? DateTime.now().difference(metrics.navigationStartTime!).inMilliseconds.toDouble();
```

- [ ] **Step 5: Run webf tests**

Run: `cd webf && flutter test`
Expected: PASS. FP/FCP/LCP values may shift by sub-millisecond — any test with a tight exact-ms assertion may need to tolerate ±1ms.

- [ ] **Step 6: Commit**

```bash
git add webf/lib/src/launcher/controller.dart
git commit -m "feat(launcher): compute FP/FCP/LCP from monotonic clock

Adds RoutePerformanceMetrics.navigationStartOffsetUs and uses it to
derive the *ms delta values, falling back to DateTime diff when the
performance session has not been started."
```

---

## Task 9: WaterfallChart — prefer `offsetUs` when available

**Files:**
- Modify: `webf/lib/src/devtools/panel/waterfall_chart.dart:202-418` (the `_buildWaterfallDataImpl` function)

**Why:** The waterfall currently derives every entry's position from `DateTime.difference(sessionStart)`. When `offsetUs` is populated, we should use it directly — no conversion back and forth through wall-clock.

- [ ] **Step 1: Introduce `offsetUsFrom` helper that prefers monotonic**

In `_buildWaterfallDataImpl`, right after the existing line 216 (`Duration offset(DateTime t) => t.difference(sessionStart);`), add:

```dart
  // Prefer the monotonic offset when available; fall back to wall-clock diff.
  // Accepts (DateTime, int?) — the int? is the monotonic offset in µs.
  Duration offsetFromPair(DateTime wallClock, int? monotonicUs) {
    if (monotonicUs != null) return Duration(microseconds: monotonicUs);
    return wallClock.difference(sessionStart);
  }
```

- [ ] **Step 2: Switch lifecycle phases to `offsetFromPair`**

In the lifecycle phase block (lines 218-274), the loop uses `phaseTimestamps[idx]`. Change the collection at lines 221-233 to track both timestamp and offsetUs:

Replace lines 220-233:

```dart
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
```

Then replace the `subEntries.add` and `entries.add` blocks (lines 258-272) to use `offsetFromPair`:

```dart
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
        category: WaterfallCategory.lifecycle,
        label: 'Lifecycle',
        start: offsetFromPair(
            phaseTimestamps[relevantIndices.first], phaseOffsetUs[relevantIndices.first]),
        end: offsetFromPair(
            phaseTimestamps[relevantIndices.last], phaseOffsetUs[relevantIndices.last]),
        subEntries: subEntries,
      ));
```

- [ ] **Step 3: Switch performance spans to direct offsetUs**

In the `--- Performance spans from tracker ---` section (lines 350-418), replace calls like `offset(spans.first.startTime)` with direct `Duration(microseconds: span.startOffsetUs)`:

Replace line 372-373:
```dart
    var clusterStart = offset(spans.first.startTime);
    var clusterEnd = offset(spans.first.endTime!);
```

With:
```dart
    var clusterStart = Duration(microseconds: spans.first.startOffsetUs);
    var clusterEnd = Duration(microseconds: spans.first.endOffsetUs!);
```

Replace lines 402-404 (inside the cluster-extension loop):
```dart
      final spanStart = offset(spans[i].startTime);
      final spanEnd = offset(spans[i].endTime!);
```

With:
```dart
      final spanStart = Duration(microseconds: spans[i].startOffsetUs);
      final spanEnd = Duration(microseconds: spans[i].endOffsetUs!);
```

Replace the `segments` list construction at lines 386-390:
```dart
      final segments = count > 1
          ? clusterSpans.map((s) => _SpanSegment(
              startMs: offset(s.startTime).inMicroseconds / 1000.0,
              endMs: offset(s.endTime!).inMicroseconds / 1000.0,
            )).toList()
          : const <_SpanSegment>[];
```

With:
```dart
      final segments = count > 1
          ? clusterSpans.map((s) => _SpanSegment(
              startMs: s.startOffsetUs / 1000.0,
              endMs: s.endOffsetUs! / 1000.0,
            )).toList()
          : const <_SpanSegment>[];
```

- [ ] **Step 4: Network requests stay on `offset(DateTime)`**

No change needed for the network section (lines 276-348) — network timestamps remain wall-clock per the spec.

- [ ] **Step 5: Run webf + waterfall tests**

Run: `cd webf && flutter test test/src/devtools/`
Expected: PASS. Existing waterfall phase filter tests should continue to work — the positions they assert against are computed via `offsetFromPair`, which now uses `offsetUs` when available.

- [ ] **Step 6: Commit**

```bash
git add webf/lib/src/devtools/panel/waterfall_chart.dart
git commit -m "feat(devtools): waterfall reads offsetUs from spans and phases when available"
```

---

## Task 10: ExportablePhase — switch export format to `offsetUs` (breaking v4)

**Files:**
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:479-501` (`ExportablePhase` class)
- Modify: `webf/lib/src/devtools/panel/performance_tracker.dart:355-377` (`exportToJson`)
- Modify: any callsite that constructs `ExportablePhase` — search with Grep before editing.

**Why:** Decision (1): break export compatibility. Export now carries `offsetUs` (int) instead of `timestamp` (absolute wall-clock µs). Version bump to `4`.

- [ ] **Step 1: Find callsites**

Run: `Grep for "ExportablePhase(" in webf/lib/src to find all constructors.`

Each callsite will need to pass `offsetUs` in addition to `timestamp`. Note them down — usually one or two sites inside `performance_tracker.dart` and `inspector_panel.dart`.

- [ ] **Step 2: Replace `ExportablePhase` class**

In `webf/lib/src/devtools/panel/performance_tracker.dart`, replace lines 479-501 with:

```dart
/// Lightweight phase representation for export/import.
///
/// Captures name, wall-clock timestamp, and monotonic offset so that
/// lifecycle milestones (FP, FCP, LCP, Attach) survive round-tripping and
/// the waterfall can render them on the monotonic timeline.
class ExportablePhase {
  final String name;
  final DateTime timestamp;

  /// Monotonic offset from session start, in microseconds.
  final int offsetUs;

  ExportablePhase({
    required this.name,
    required this.timestamp,
    required this.offsetUs,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'offsetUs': offsetUs,
      };

  static ExportablePhase fromJson(Map<String, dynamic> json,
      {required DateTime sessionAnchor}) {
    final offsetUs = json['offsetUs'] as int;
    return ExportablePhase(
      name: json['name'] as String,
      timestamp: sessionAnchor.add(Duration(microseconds: offsetUs)),
      offsetUs: offsetUs,
    );
  }
}
```

- [ ] **Step 3: Bump export version and thread `sessionAnchor` through import**

In `exportToJson` (line 355), change `'version': 3,` to `'version': 4,`.

In `importFromJson` (line 382), the phases block (lines 410-415) must pass `sessionAnchor`:

```dart
    final anchor = sessionStart ?? DateTime.now();
    // Restore phases if present
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
```

- [ ] **Step 4: Update ExportablePhase construction callsites**

At every `ExportablePhase(name: ..., timestamp: ...)` callsite, add `offsetUs: <source>.offsetUs ?? 0`. The source will typically be a `LoadingPhase`, which now has `offsetUs` (from Task 7).

Example (guess — verify with Grep first):
```dart
// Before:
ExportablePhase(name: phase.name, timestamp: phase.timestamp)

// After:
ExportablePhase(
  name: phase.name,
  timestamp: phase.timestamp,
  offsetUs: phase.offsetUs ?? 0,
)
```

- [ ] **Step 5: Run webf tests**

Run: `cd webf && flutter test`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add webf/lib/src/devtools/panel/performance_tracker.dart webf/lib/src/devtools/panel/inspector_panel.dart
git commit -m "feat(devtools): export format v4 — ExportablePhase carries offsetUs (breaking)"
```

(If `inspector_panel.dart` was not touched, adjust the `git add` accordingly.)

---

## Task 11: End-to-end verification

**Files:** none modified.

- [ ] **Step 1: Build full macOS bridge + run**

Run: `npm run build:bridge:macos`
Expected: Clean build.

Run: `npm run start`
Expected: `webf/example` launches.

- [ ] **Step 2: Visual smoke test in DevTools performance tab**

Manually:
1. Open DevTools performance panel.
2. Record a session (load any page with JS and layout).
3. Verify JS thread spans in the `jsScriptEval` row visually sit *inside* the Dart `evaluateScripts` phase band (they should nest, not drift).
4. Repeat the recording — alignment should be stable across sessions.

- [ ] **Step 3: Export → import round-trip**

Manually:
1. Record a session.
2. Export via the toolbar.
3. Clear and import the exported JSON.
4. Verify the waterfall renders identically.
5. Verify the version field in the JSON is `4`.

- [ ] **Step 4: Full test suite**

Run: `cd webf && flutter test`
Expected: All pass.

Run: `cd webf && flutter analyze`
Expected: No errors (existing warnings are fine).

- [ ] **Step 5: Final commit (only if verification surfaced any fixes)**

If steps 1-4 required follow-up tweaks, commit them:

```bash
git add -p
git commit -m "fix(devtools): post-verification tweaks for clock alignment"
```

---

## Self-Review Notes

**Spec coverage:** Each numbered section of the spec maps to at least one task — C++ FFI (Tasks 1–2), Dart FFI (Task 3), sync (Task 4), drain fix (Task 5), data model (Tasks 6–7), navigation metrics (Task 8), waterfall (Task 9), export format (Task 10), verification (Task 11).

**Known risk in plan:** Task 7 adds an import of `performance_tracker.dart` into `loading_state.dart`. If this creates a cycle (tracker may eventually import loading_state for ExportablePhase integration), the import may need to be deferred via an interface or done with `show PerformanceTracker` only. Verify at the time of Task 7 execution.

**Type consistency check:**
- `PerformanceSpan.startOffsetUs` (int) — used consistently across tracker, spans, and waterfall.
- `LoadingPhase.offsetUs` (int?) — nullable by design (for fallback cases).
- `ExportablePhase.offsetUs` (int, required) — export-only, always present by Task 10.
- `RoutePerformanceMetrics.navigationStartOffsetUs` (int?) — nullable because some navigation starts can occur before `PerformanceTracker.startSession()`.

No mismatched names between tasks.
