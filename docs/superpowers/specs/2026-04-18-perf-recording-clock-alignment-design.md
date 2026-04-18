# Performance Recording Clock Alignment

**Date:** 2026-04-18
**Branch:** feat/perf-graph-redesign
**Status:** Design approved, ready for implementation plan

## Problem

The WebF performance waterfall mixes timestamps from two independent clock sources, causing visible drift between Dart-recorded phases/spans and JS-thread spans drained from the C++ profiler.

**Concretely:**

- Dart side (`PerformanceTracker`, `LoadingState`, FP/FCP/LCP math) uses `DateTime.now()` — wall-clock (`CLOCK_REALTIME`).
- C++ side (`JSThreadProfiler`) uses `std::chrono::steady_clock` — monotonic.
- `PerformanceTracker.drainJSThreadSpans` copies C++ µs offsets straight into `Duration` and treats them as offsets from the Dart wall-clock `sessionStart`. The two epochs are unrelated, so every JS span lands at the wrong position on the shared timeline.
- An FFI calibration hook (`getJSProfilerSessionStartUs`) exists but is never called.

Wall-clock is also the wrong primitive for performance work: NTP adjustments, suspend/resume, and leap seconds all corrupt measurements.

## Goal

Unify all performance recording on a single monotonic clock, anchored once per session, so Dart-recorded and C++-recorded timestamps share one timeline with no drift.

## Approach

Replace `DateTime.now()` with `Stopwatch` (monotonic) for all performance math. Keep a `DateTime sessionStart` for display / export headers only. Sync the Dart stopwatch to the C++ `steady_clock` anchor once at session start; apply a constant offset to every drained JS span.

## Design

### Clock sync (one-time, in `startSession`)

```dart
_stopwatch = Stopwatch()..start();
final syncAbsUs = to_native.getSteadyClockNowUs();          // NEW FFI
final syncElapsedUs = _stopwatch.elapsedMicroseconds;
_stopwatchStartAbsUs = syncAbsUs - syncElapsedUs;            // Dart anchor on steady_clock

to_native.setJSThreadProfilingEnabled(true);
_cppSessionStartAbsUs = to_native.getJSProfilerSessionStartUs();  // existing FFI, newly used
_cppToDartOffsetUs = _cppSessionStartAbsUs - _stopwatchStartAbsUs;

sessionStart = DateTime.now();  // retained for display & export header only
```

Both Dart and C++ now share the `steady_clock` epoch. On all target platforms (darwin / Linux / Android), Dart's `Stopwatch` and C++'s `std::chrono::steady_clock` read the same underlying kernel clock.

### Timestamp representation

New primitive: **`int offsetUs`** — microseconds from `_stopwatchStartAbsUs` (session monotonic origin).

Dart-side capture: `_stopwatch.elapsedMicroseconds`.
JS-side drain: `native.startUs + _cppToDartOffsetUs`.

### Data model changes

**`PerformanceSpan`** (`performance_tracker.dart`):
- Add `int startOffsetUs`, `int? endOffsetUs`.
- Keep `DateTime startTime`, `DateTime? endTime` (derived from session start + offset) for existing consumers.

**`LoadingPhase`** (`loading_state.dart`):
- Add `int offsetUs`.
- Keep `DateTime timestamp` for API compatibility (derived = `sessionStart + offsetUs`).

**`NavigationMetrics`** in `controller.dart`:
- Add `int? navigationStartOffsetUs`.
- FP/FCP/LCP `double *Time` values computed from monotonic delta (same `double ms` external shape).
- `navigationStartTime: DateTime` retained for consumer compat.

**`WaterfallEntry`**, `WaterfallData` (`waterfall_chart.dart`):
- Already uses `Duration` offsets — switch internals to derive from `offsetUs`.

### JS span drain fix

```dart
// performance_tracker.dart:249
final startOffsetUs = native.startUs + _cppToDartOffsetUs;
final endOffsetUs = native.endUs + _cppToDartOffsetUs;
jsThreadSpans.add(JSThreadSpan(
  startOffset: Duration(microseconds: startOffsetUs),
  endOffset: Duration(microseconds: endOffsetUs),
  ...
));
```

### FFI additions

**C++** (`bridge/core/profiling/js_thread_profiler.{h,cc}`):
```cpp
int64_t SteadyClockNowUs();  // returns steady_clock::now().time_since_epoch() in µs
```

Exported via the existing profiler FFI surface. No state; safe to call from any thread.

**Dart** (`webf/lib/src/bridge/to_native.dart`):
```dart
int getSteadyClockNowUs();
```

### Export format (breaking change)

`ExportablePhase` / `PerformanceTracker.toJson` emit `offsetUs` (int µs) instead of `startTime` (absolute wall-clock µs). Old exports become unimportable — no migration shim.

Session header retains `sessionStart: <DateTime iso8601>` for human-readable context, but all timing math on import uses `offsetUs`.

### Public API compatibility

`LoadingPhase.timestamp: DateTime` stays. Any external consumer reading `phase.timestamp` continues to work — the value is now derived (`sessionStart.add(Duration(microseconds: offsetUs))`) rather than captured fresh. Drift-free internally; identical shape externally.

Same pattern for `PerformanceSpan.startTime/endTime` and `NavigationMetrics.navigationStartTime`.

### Scope boundaries — unchanged

These keep `DateTime.now()`:
- Network/CDP timestamps (wire protocol uses wall-clock).
- `event.timeStamp` (web standard = wall-clock epoch).
- Cookie/cache expiry, file timestamps.
- Console log entries.
- Request IDs built from `microsecondsSinceEpoch`.

## Risks / Non-goals

**Risk:** `_stopwatchStartAbsUs` is derived from one FFI call pair. If the call takes unusually long (>1 ms), the anchor has measurable skew. Mitigation: acceptable — per-session one-time, and 1 ms is well below visible waterfall resolution.

**Non-goal:** cross-process or cross-session time correlation. Monotonic clocks by definition don't carry meaning across processes.

**Non-goal:** fixing network panel timeline (uses wall-clock deliberately for DevTools protocol).

## Files touched

- `bridge/core/profiling/js_thread_profiler.{h,cc}` — add `SteadyClockNowUs` + export
- `bridge/core/dart_methods.{h,cc}` or wherever profiler FFI is wired — register export
- `webf/lib/src/bridge/to_native.dart` — add `getSteadyClockNowUs` binding
- `webf/lib/src/devtools/panel/performance_tracker.dart` — stopwatch, sync, offset on drain, span model
- `webf/lib/src/launcher/loading_state.dart` — `LoadingPhase.offsetUs`, `recordPhase` / `recordPhaseStart` via stopwatch
- `webf/lib/src/launcher/controller.dart` — navigation metrics monotonic source for FP/FCP/LCP
- `webf/lib/src/devtools/panel/waterfall_chart.dart` — `offset()` helper, `buildWaterfallData` derives from `offsetUs`
- Tests: new coverage for sync math, existing waterfall tests updated for new data model

## Success criteria

1. JS thread spans visually align under the corresponding Dart-recorded phases in the waterfall (e.g., `evaluateScripts` span contains its own JS child spans).
2. No drift over long sessions — a 60-second idle followed by a JS span shows the span at the correct `now - sessionStart` offset.
3. Suspend/resume test: suspend device mid-session, resume, record more spans — no timeline jump.
4. FP/FCP/LCP values unchanged in shape (`double ms`), computed from monotonic delta.
5. Export round-trip: export → import → waterfall renders identically.
