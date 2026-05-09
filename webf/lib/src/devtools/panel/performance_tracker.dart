/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

/// A lightweight hierarchical performance span tracker for WebF's rendering pipeline.
///
/// Records start/end timing for CSS parse, style recalc, layout, and paint stages.
/// Uses a call-stack model: when [beginSpan] is called during a recursive operation
/// (e.g., nested layout), the new span automatically becomes a child of the active span.
///
/// Zero-cost when [enabled] is false (single boolean check per call).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math' as math;
import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';
import 'package:webf/bridge.dart';
import 'package:webf/src/bridge/to_native.dart' as to_native;
import 'package:webf/src/devtools/panel/performance_subtypes.dart';

/// Represents a single performance span in the rendering pipeline.
///
/// Primary timestamps are `startOffsetUs` / `endOffsetUs` — microseconds
/// from the [PerformanceTracker] session start, captured from a monotonic
/// stopwatch. `startTime`/`endTime` remain as derived `DateTime` values for
/// API compatibility with existing consumers. The wall-clock anchor is
/// captured once at session start; wall-clock drift during the session
/// (e.g. NTP adjustment) is not reflected in the derived DateTime values.
class PerformanceSpan {
  final String subType;
  final String name;

  /// Monotonic offset from session start, in microseconds.
  final int startOffsetUs;

  /// Monotonic offset at span end. Null while the span is still open.
  int? endOffsetUs;

  // Mutable so that [_attachJSSpan] can re-parent a subtree when a later-
  // draining OUTER JS span turns out to time-contain spans that were
  // already attached as siblings. JS-thread spans exit inside-out (inner
  // functions pop before their enclosing script eval), so by the time
  // the outer `jsScriptEval` reaches the drain, its children are already
  // placed — we move them under it at insertion time and adjust depths.
  int depth;
  PerformanceSpan? parent;
  final List<PerformanceSpan> children = [];
  Map<String, dynamic>? metadata;

  /// Wall-clock anchor used to derive [startTime] / [endTime]. Captured at
  /// [PerformanceTracker.sessionStart].
  final DateTime _sessionAnchor;

  PerformanceSpan({
    required this.subType,
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

  /// Collect all spans at a given depth level (breadth-first).
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
        'subType': subType,
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
}

/// Handle returned by [PerformanceTracker.beginSpan] to end a span.
class PerformanceSpanHandle {
  final PerformanceSpan _span;
  final PerformanceTracker _tracker;

  /// Snapshot of `_tracker._currentSpan` at the moment this span was opened.
  /// Restored on [end] so that grafted spans (whose `parent` was resolved via
  /// [_entryIdToSpan] rather than the live `_currentSpan` pointer) do not
  /// leave `_currentSpan` pointing at an entry root that is no longer on
  /// the active call stack.
  final PerformanceSpan? _previousCurrentSpan;

  PerformanceSpanHandle._(this._span, this._tracker, this._previousCurrentSpan);

  /// End this span and pop back to the previous span.
  void end({Map<String, dynamic>? metadata}) {
    _span.endOffsetUs = _tracker.nowOffsetUs();
    if (metadata != null) {
      _span.metadata = (_span.metadata ?? {})..addAll(metadata);
    }
    _tracker._currentSpan = _previousCurrentSpan;
  }
}

/// Handle returned by [PerformanceTracker.beginEntry] to end an entry root.
///
/// Ending an entry pops it from the entry stack and clears (or restores)
/// the C++ profiler's current_entry_id. Child spans opened between
/// beginEntry/end auto-attribute to the entry via the existing _currentSpan
/// stack.
///
/// For async-spanning entries (created with `asyncSpanning: true`), the
/// entry is NOT pushed onto the call stack — only the C++ entry_id is
/// stamped — so unrelated Dart work that runs while the future awaits
/// does not get nested under this entry.
class EntryHandle {
  final PerformanceSpan _root;
  final PerformanceTracker _tracker;
  final int _entryId;
  final int _previousEntryId;
  bool _asyncSpanning;

  EntryHandle._(this._root, this._tracker, this._entryId, this._previousEntryId,
      {bool asyncSpanning = false})
      : _asyncSpanning = asyncSpanning;

  /// The entry id stamped into the C++ profiler for this entry. Callers
  /// that invoke Dart→JS FFIs (eg. `_dispatchEventToNative`) pass this id
  /// into the bridge so the JS thread can override `current_entry_id_`
  /// for the duration of the synchronous JS invocation, guaranteeing
  /// correct attribution even when the shared atomic has since been
  /// overwritten by other async entries opened on the Dart thread.
  int get entryId => _entryId;

  /// Convert a sync entry into an async-spanning one. Call right before
  /// `await`-ing so that work scheduled during the suspension does not
  /// nest under this entry. After this call the entry is popped from the
  /// call-stack (matching what `end()` would do for a sync entry) but
  /// stays alive — the matching `end()` still closes the root span.
  ///
  /// Idempotent: calling multiple times is safe.
  void transitionToAsync() {
    if (_asyncSpanning) return;
    _asyncSpanning = true;
    _tracker._popEntry(_root, _previousEntryId);
  }

  void end({Map<String, dynamic>? metadata}) {
    _root.endOffsetUs = _tracker.nowOffsetUs();
    if (metadata != null) {
      _root.metadata = (_root.metadata ?? {})..addAll(metadata);
    }
    if (_asyncSpanning) {
      _tracker._endAsyncEntry(_previousEntryId);
    } else {
      _tracker._popEntry(_root, _previousEntryId);
    }
  }
}

/// Singleton performance tracker that records hierarchical spans.
///
/// The tracker uses a [_currentSpan] pointer as a call stack. When [beginSpan]
/// is called during a recursive operation (e.g., flex layout calling child layout),
/// the new span automatically becomes a child of the active span:
///
/// ```
/// flexLayout [0-50ms]              // beginSpan → _currentSpan = flex
///   ├── flowLayout [2-15ms]        // beginSpan → _currentSpan = flow (child of flex)
///   │     └── flexLayout [5-10ms]  // beginSpan → _currentSpan = nestedFlex (child of flow)
///   └── gridLayout [20-40ms]       // beginSpan → _currentSpan = grid (child of flex)
/// ```
class PerformanceTracker {
  PerformanceTracker._();

  static final PerformanceTracker instance = PerformanceTracker._();

  /// Whether span recording is active. When false, [beginSpan] returns null immediately.
  bool enabled = false;

  /// When true, [beginSpan] called outside any entry triggers an assertion.
  /// Default false because the spec allows uninstrumented call sites
  /// (Flutter framework callbacks like Future.then, Ticker, FutureBuilder
  /// rebuilds) to fall through to an `unattributed` root in production.
  /// Tests that want to verify dev-mode contract enforcement must opt in.
  bool assertOnUnattributedSpan = false;

  /// When true, emit a single-line summary on every waterfall drill-down
  /// — the target span's time window, subtree size, tree-integrity
  /// violations (children whose interval escapes the parent), and a sample
  /// of direct children. Used to diagnose wrong drilldown rendering. Off
  /// by default; flip at runtime via
  /// `PerformanceTracker.instance.debugLogDrilldown = true`.
  bool debugLogDrilldown = false;

  /// Top-level spans (not children of any other span).
  final List<PerformanceSpan> rootSpans = [];

  /// Phases parsed from the most recent [importFromJson] call. Empty for
  /// live sessions. Held on the tracker (rather than per-WaterfallChart)
  /// so the inspector panel can compute attachOffset for tab gating
  /// without depending on which sub-tab triggered the import.
  List<ExportablePhase> importedPhases = [];

  /// Monotonic clock source. A fresh instance is created on every
  /// [startSession] call and used for all timing within that session.
  Stopwatch? _stopwatch;

  /// Absolute C++ steady_clock microseconds captured at the instant the Dart
  /// stopwatch was started. Derived from `getSteadyClockNowUs()` and the
  /// stopwatch's elapsed at that instant. Constant for the session.
  /// Note: there is a sub-ms skew equal to any OS/GC pause between the
  /// `getSteadyClockNowUs()` FFI call and the `elapsedMicroseconds` read.
  /// Accepted — well below visible waterfall resolution.
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

  /// Mirror of the C++ `current_entry_id` for in-Dart parent lookup.
  /// Updated in lockstep with [to_native.setJSProfilerCurrentEntryId] via
  /// [_setCurrentEntryId]. Used by [beginSpan] to graft top-level spans
  /// under the current entry when the local `_entryStack` is empty
  /// (e.g. when a Dart binding callback runs inside an active JS entry but
  /// the binding handler itself opens no entry of its own).
  int _currentEntryId = 0;

  /// Periodic drain of the C++ JS span ring buffer.
  ///
  /// The primary drain is piggy-backed on `flushUICommand`, which runs at
  /// the end of every frame that actually has UI work. But a long JS-only
  /// burst — e.g. Vite evaluating `import` statements for 1+s of module
  /// resolution with no DOM output — produces zero UI commands, so
  /// `flushUICommand` short-circuits, `scheduleFrame()` stops recurring,
  /// and the frame loop stalls. Meanwhile the JS thread keeps firing
  /// function entries/exits into the 8192-slot C++ ring buffer, which
  /// overflows and silently drops the oldest spans. By the time React
  /// finally renders and UI commands resume, only the last ~10% of the
  /// JS history survives — which was the "1.1s of untracked idle"
  /// reported on the evaluateModule drilldown.
  ///
  /// Schedule a short-period Timer that drains independently of the
  /// frame loop while a session is active. 10ms pacing gives us a
  /// worst-case window of ~81 spans/ms * 10ms ≈ 810 spans per drain,
  /// well under the 8192 ring size even for spike activity.
  Timer? _periodicDrainTimer;
  static const Duration _periodicDrainInterval = Duration(milliseconds: 10);

  void _setCurrentEntryId(int entryId) {
    _currentEntryId = entryId;
    to_native.setJSProfilerCurrentEntryId(entryId);
  }

  /// When the current recording session started.
  DateTime? sessionStart;

  int _totalSpanCount = 0;

  /// Maximum number of spans to record per session to prevent memory issues.
  ///
  /// JS-thread spans (jsFunction, jsCFunction) dominate real recordings —
  /// a few seconds of busy app activity can produce thousands. The cap
  /// must be high enough that important Dart entries (drawFrame,
  /// flushUICommand, evaluate*) are not crowded out by JS-thread fan-out.
  ///
  /// At 1000k the cap was hit in ~7s on heavy-render sessions (a styleRecalc
  /// cascade alone can produce 10k+ spans during a single drawFrame burst),
  /// causing post-LCP `invokeModule` entries to be silently dropped and
  /// hiding late-firing API calls from the analysis. 1M gives ~10× more
  /// headroom for the long tail of microsecond-scale js spans without
  /// meaningfully changing the per-span memory footprint of a typical
  /// session.
  static const int maxSpans = 10000000;

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
    importedPhases = [];
    _currentSpan = null;
    _totalSpanCount = 0;
    enabled = true;
    _entryStack.clear();
    _entryIdToSpan.clear();
    _entryIdMap.clear();
    _nextEntryId = 1;
    _setCurrentEntryId(0);

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
    final cppSessionStartAbsUs = to_native.getJSProfilerSessionStartUs();
    _cppSessionStartAbsUs = cppSessionStartAbsUs;
    _cppToDartOffsetUs = cppSessionStartAbsUs - _stopwatchStartAbsUs!;

    // Step C: start the periodic JS-span drainer so JS activity that
    // doesn't produce UI commands (module loading, pure computation,
    // idle callbacks) still makes it out of the C++ ring buffer before
    // it wraps and loses history.
    _periodicDrainTimer?.cancel();
    _periodicDrainTimer = Timer.periodic(_periodicDrainInterval, (_) {
      if (!enabled) return;
      drainJSThreadSpans();
    });
  }

  /// End the current recording session. Spans are preserved for reading.
  void endSession() {
    enabled = false;
    _periodicDrainTimer?.cancel();
    _periodicDrainTimer = null;
    // Drain any remaining JS spans before tearing down state
    drainJSThreadSpans();
    // Disable C++ JS thread profiling
    to_native.setJSThreadProfilingEnabled(false);
    _setCurrentEntryId(0);
    // Close any unclosed spans using the monotonic clock.
    final nowUs = nowOffsetUs();
    while (_currentSpan != null) {
      _currentSpan!.endOffsetUs ??= nowUs;
      _currentSpan = _currentSpan!.parent;
    }
    _entryStack.clear();
    _entryIdMap.clear();
  }

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

      // Sort spans by (startUs ASC, endUs DESC) so outer spans land before
      // their inner spans within this drain batch. This matters for the
      // entryId == 0 nesting heuristic in [_attachJSSpan]: an inner span can
      // only nest under an outer one that's already been registered as a root.
      final indices = List.generate(count, (i) => i);
      indices.sort((a, b) {
        final sa = buffer[a].startUs;
        final sb = buffer[b].startUs;
        if (sa != sb) return sa.compareTo(sb);
        return buffer[b].endUs.compareTo(buffer[a].endUs);
      });

      for (final i in indices) {
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

        _attachJSSpan(
          entryId: native.entryId,
          subType: subType,
          name: funcName,
          startOffsetUs: startOffsetUs,
          endOffsetUs: endOffsetUs,
          anchor: anchor,
        );
      }
    } finally {
      calloc.free(buffer);
    }
  }

  /// Attach a drained (or test-injected) JS span to the entry-rooted tree.
  ///
  /// Resolution order for the parent root:
  /// 1. [entryId] resolves to a live entry root via [_entryIdToSpan] and
  ///    that root is JS-hosting (either a `js*`-subType entry or one
  ///    listed in [kJsHostingDartEntries]) — graft as a child of the
  ///    deepest leaf whose interval contains [startOffsetUs]. Stamps
  ///    pointing at pure-Dart entries (drawFrame, flushUICommand, etc.)
  ///    are rejected and fall through to rule 2 — the JS thread was just
  ///    running concurrently while the Dart thread happened to hold
  ///    `current_entry_id_` for a non-JS-hosting entry.
  /// 2. Otherwise, search [rootSpans] for a root whose interval contains
  ///    [startOffsetUs] AND is JS-compatible: either a `js*`-subType root
  ///    (preserves the C++-internal JS hierarchy when outer/inner arrive
  ///    in the same drain batch — eg. jsMicrotask wrapping jsFunction)
  ///    or a Dart entry listed in [kJsHostingDartEntries] (dispatchEvent,
  ///    evaluate*, invokeBinding*, invokeModuleEvent — these are often
  ///    opened with `asyncSpanning:true` and lose their entry_id stamp
  ///    before JS actually runs, so we recover the nesting by time).
  ///    Pure-Dart roots (drawFrame, flushUICommand, htmlParse, etc.) are
  ///    excluded: wall-clock overlap with concurrent JS-thread activity
  ///    does not imply causality.
  /// 3. No containing root — the span becomes a new root.
  ///
  /// Drops the span if [_totalSpanCount] is at [maxSpans]. This matches the
  /// cap behavior in [beginSpan] / [beginEntry] so JS-thread spans cannot
  /// starve out Dart entries that arrive afterwards.
  void _attachJSSpan({
    required int entryId,
    required String subType,
    required String name,
    required int startOffsetUs,
    required int endOffsetUs,
    required DateTime anchor,
  }) {
    if (_totalSpanCount >= maxSpans) return;

    PerformanceSpan? root;
    if (entryId != 0) {
      final candidate = _entryIdToSpan[entryId];
      // Reject the stamp when it resolves to a pure-Dart entry. The C++
      // profiler samples `current_entry_id_` at JS-function entry, and
      // the JS thread can run concurrently with a Dart entry like
      // drawFrame — so the stamp can point at a Dart root that had no
      // hand in producing this JS work. Only accept stamps that target
      // an entry which legitimately hosts synchronous JS execution
      // (see [kJsHostingDartEntries]) or a JS-side entry. Also reject
      // stamps whose resolved entry has already closed BEFORE the new
      // span ends — the JS function was stamped at entry with an entry
      // that had just a few µs left and then kept running past it; it
      // isn't really hosted by that entry any more (observed: a 208ms
      // `renderRootSync` kept running past evaluateModule's close).
      if (candidate != null &&
          (candidate.subType.startsWith('js') ||
              kJsHostingDartEntries.contains(candidate.subType))) {
        final cEnd = candidate.endOffsetUs;
        if (cEnd == null || endOffsetUs <= cEnd) {
          root = candidate;
        }
      }
    }
    root ??= _findContainingRoot(startOffsetUs, endOffsetUs);

    if (root != null) {
      final parent =
          _findInsertionParent(root, startOffsetUs, endOffsetUs);
      final span = PerformanceSpan(
        subType: subType,
        name: name,
        startOffsetUs: startOffsetUs,
        depth: parent.depth + 1,
        sessionAnchor: anchor,
        parent: parent,
      );
      span.endOffsetUs = endOffsetUs;
      _adoptContainedSiblings(
          parent.children, span, startOffsetUs, endOffsetUs);
      parent.children.add(span);
    } else {
      final span = PerformanceSpan(
        subType: subType,
        name: name,
        startOffsetUs: startOffsetUs,
        depth: 0,
        sessionAnchor: anchor,
      );
      span.endOffsetUs = endOffsetUs;
      _adoptContainedSiblings(rootSpans, span, startOffsetUs, endOffsetUs);
      rootSpans.add(span);
    }
    _totalSpanCount++;
  }

  /// Move any entries in [siblings] whose interval is time-contained within
  /// `[startOffsetUs..endOffsetUs]` to become children of [newSpan] instead,
  /// adjusting their depth (and the depth of their descendants) to match
  /// the new position in the tree.
  ///
  /// Drain batches deliver completed JS spans in function-exit order, so an
  /// enclosing `jsScriptEval` (which exits LAST) shows up after every
  /// function it ran has already been attached. Without this step those
  /// inner functions would remain siblings of the script eval under the
  /// Dart entry, flattening the JS call stack. Returns the number of spans
  /// actually moved.
  int _adoptContainedSiblings(List<PerformanceSpan> siblings,
      PerformanceSpan newSpan, int startOffsetUs, int endOffsetUs) {
    // Collect first, mutate after — modifying the list mid-iteration is
    // brittle and adopted spans may themselves be the containing root for
    // other siblings (we handle by a single pass because we're re-parenting
    // a flat layer, not walking the whole tree).
    //
    // Only adopt JS-thread spans. Adoption exists specifically to recover
    // JS nesting when a late-draining outer JS span (typically jsScriptEval)
    // turns out to enclose js* children that arrived in earlier drain
    // batches. Pure-Dart entries (drawFrame, imageLoadComplete, etc.) run
    // on a separate thread and only time-overlap JS by coincidence — the
    // JS work didn't "cause" them, so they must never be swept into a JS
    // subtree. Skipping non-js* siblings here prevents a long-running JS
    // function from hoarding concurrent Dart entries that happened to open
    // and close during its window.
    //
    // Also skip still-open siblings: a Dart entry root can linger in
    // `rootSpans` with `endOffsetUs==null` for tens of ms while its subtree
    // is being built, and if we treated an open span as a zero-duration
    // point (start==end), adoption would later pull the not-yet-complete
    // subtree into a span that had nothing to do with it.
    final toMove = <PerformanceSpan>[];
    for (final s in siblings) {
      if (!s.subType.startsWith('js')) continue;
      if (s.startOffsetUs < startOffsetUs) continue;
      final sEnd = s.endOffsetUs;
      if (sEnd == null) continue;
      if (sEnd > endOffsetUs) continue;
      toMove.add(s);
    }
    if (toMove.isEmpty) return 0;
    siblings.removeWhere(toMove.contains);
    final newDepth = newSpan.depth + 1;
    for (final m in toMove) {
      m.parent = newSpan;
      _adjustSubtreeDepth(m, newDepth);
      newSpan.children.add(m);
    }
    return toMove.length;
  }

  void _adjustSubtreeDepth(PerformanceSpan span, int newDepth) {
    span.depth = newDepth;
    for (final c in span.children) {
      _adjustSubtreeDepth(c, newDepth + 1);
    }
  }

  /// Find a JS-compatible root span whose interval contains [startOffsetUs].
  /// Searches from most-recently-added back so the latest matching root
  /// (i.e. the innermost candidate at insertion time) wins.
  ///
  /// Accepts two kinds of roots:
  /// - `js*` subTypes — JS-thread roots that legitimately host nested JS.
  /// - [kJsHostingDartEntries] — Dart entries whose purpose is to bracket
  ///   synchronous JS execution (dispatchEvent, evaluate*, invokeBinding*,
  ///   invokeModuleEvent). These are often opened with `asyncSpanning:true`
  ///   and their `current_entry_id_` stamp can be overwritten by other
  ///   Dart entries before JS actually runs, so the stamp-based attachment
  ///   in [_attachJSSpan] rule 1 often misses legitimate children; falling
  ///   through to time-containment here recovers them.
  ///
  /// Pure-Dart roots (drawFrame, flushUICommand, htmlParse, etc.) are
  /// deliberately skipped: wall-clock overlap with concurrent JS-thread
  /// activity implies no causality between them.
  PerformanceSpan? _findContainingRoot(int startOffsetUs, int endOffsetUs) {
    for (int i = rootSpans.length - 1; i >= 0; i--) {
      final root = rootSpans[i];
      if (!root.subType.startsWith('js') &&
          !kJsHostingDartEntries.contains(root.subType)) {
        continue;
      }
      if (root.startOffsetUs > startOffsetUs) continue;
      final endUs = root.endOffsetUs;
      // Require full [start..end] containment; partial overlap means the
      // new span extends past the root, so it isn't truly "inside" and
      // nesting it would produce a child-longer-than-parent violation.
      if (endUs == null ||
          (startOffsetUs <= endUs && endOffsetUs <= endUs)) {
        return root;
      }
    }
    return null;
  }

  /// Walks down [root] to find the deepest descendant whose interval
  /// fully contains `[startOffsetUs..endOffsetUs]`. Used to graft drained
  /// JS spans at the correct depth in the tree.
  ///
  /// A child is eligible when the new span's interval fits inside the
  /// child's own interval. Checking only the start (as the original
  /// version did) nests a later-ending span under a shorter sibling
  /// that simply started first — the new span then extends past its
  /// parent, producing child-longer-than-parent tree violations like
  /// the earlier 5130µs jsMicrotask grafted into a 100µs jsFunction "s".
  ///
  /// However, a strict end-containment check is TOO strict: the C++
  /// profiler records `OnFunctionEntry` / `OnFunctionExit` timestamps at
  /// slightly different points than the logical JS call stack
  /// enter/exit, so an inner function's `end_us` can legitimately land
  /// a few µs past its parent's recorded `end_us` (observed: a 106.97ms
  /// `jsFunction "w"` ending 40µs — 0.03% of the parent's duration —
  /// past its `jsMicrotask` parent). Rejecting that case kicks `w` out
  /// into becoming a same-depth sibling of the microtask, so the flame
  /// chart paints both at the same row and the bars overlap visually.
  ///
  /// Allow a small tolerance: accept nesting when the overflow is
  /// <5% of the candidate's duration AND <1ms absolute. Both bounds
  /// matter — the percentage catches small absolute overflows in short
  /// spans; the absolute cap prevents a huge span from swallowing a
  /// meaningfully-overflowing child.
  ///
  /// Open-ended children (endOffsetUs == null) are treated as still
  /// ongoing — their interval extends to +∞ — so a mid-session drain
  /// can attribute a JS span to an open Dart entry.
  PerformanceSpan _findInsertionParent(
      PerformanceSpan root, int startOffsetUs, int endOffsetUs) {
    PerformanceSpan candidate = root;
    while (true) {
      PerformanceSpan? next;
      for (final child in candidate.children) {
        if (child.startOffsetUs > startOffsetUs) continue;
        final childEnd = child.endOffsetUs;
        if (childEnd == null) {
          next = child;
          break;
        }
        if (startOffsetUs > childEnd) continue;
        if (endOffsetUs <= childEnd) {
          next = child;
          break;
        }
        // End overflows. Accept if small enough to be profiler noise.
        final overflow = endOffsetUs - childEnd;
        final childDur = childEnd - child.startOffsetUs;
        final tolerance =
            math.min(1000, (childDur * 0.05).round()); // 5% or 1ms, whichever smaller
        if (overflow <= tolerance) {
          next = child;
          break;
        }
      }
      if (next == null) return candidate;
      candidate = next;
    }
  }

  /// Test-only: inject a JS span as if it had just been drained from C++.
  /// `startUs` and `endUs` are C++ offsets (from C++ session_start_); this
  /// helper applies [_cppToDartOffsetUs] the same way [drainJSThreadSpans]
  /// would, so tests exercise the real correction math.
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
    _attachJSSpan(
      entryId: entryId,
      subType: subType,
      name: funcName,
      startOffsetUs: startUs + offsetUs,
      endOffsetUs: endUs + offsetUs,
      anchor: sessionStart ?? DateTime.now(),
    );
  }

  /// Begin a new performance span.
  ///
  /// If another span is currently active, the new span becomes its child.
  /// Returns a [PerformanceSpanHandle] to end the span, or null if tracking
  /// is disabled or the span limit has been reached.
  ///
  /// [category] identifies the pipeline stage: 'cssParse', 'styleFlush',
  /// 'styleRecalc', 'styleApply', 'layout', 'paint'. Stored as
  /// [PerformanceSpan.subType].
  ///
  /// [name] identifies the specific operation: 'parseStylesheet', 'flushStyle',
  /// 'recalculateStyle', 'flexLayout', 'paint', etc.
  ///
  /// Returns null when tracking is disabled, the span limit is reached, or
  /// no session has been started.
  PerformanceSpanHandle? beginSpan(String category, String name,
      {Map<String, dynamic>? metadata}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;
    final anchor = sessionStart;
    if (anchor == null) return null;

    // Dev-mode contract: every span should live under an entry. In
    // production we silently promote to root with subType `unattributed`
    // and the original subType moved into the name field, so the panel
    // stays useful while we iterate. In dev (assertions enabled) we
    // surface the missing instrumentation immediately.
    //
    // Sibling-entry lookup: when the local Dart `_entryStack` is empty
    // but the C++ profiler has a non-zero `current_entry_id`, we are
    // running inside an entry that was opened on a different Dart
    // call-stack (e.g. JS execution that called back into Dart via a
    // binding handler). Graft the span under that entry's root rather
    // than orphaning to "unattributed" — the JS spans drained later
    // will already attribute under the same entry, so this keeps the
    // Dart-side work (style recalc / layout / paint triggered from the
    // binding) sibling-attached to the JS side that triggered it.
    final previousCurrentSpan = _currentSpan;
    String effectiveSubType = category;
    String effectiveName = name;
    PerformanceSpan? parentSpan = _currentSpan;
    if (parentSpan == null) {
      final entryRoot = _currentEntryId != 0
          ? _entryIdToSpan[_currentEntryId]
          : null;
      if (entryRoot != null) {
        parentSpan = entryRoot;
      } else {
        assert(!assertOnUnattributedSpan,
            'beginSpan called outside any entry: $category/$name. '
            'Wrap the call site in tracker.beginEntry(...) or use the '
            'unattributed subType explicitly.');
        effectiveSubType = 'unattributed';
        effectiveName = '$category/$name';
      }
    }

    final span = PerformanceSpan(
      subType: effectiveSubType,
      name: effectiveName,
      startOffsetUs: nowOffsetUs(),
      depth: (parentSpan != null) ? parentSpan.depth + 1 : 0,
      sessionAnchor: anchor,
      parent: parentSpan,
      metadata: metadata,
    );

    if (parentSpan != null) {
      parentSpan.children.add(span);
    } else {
      rootSpans.add(span);
    }

    _currentSpan = span;
    _totalSpanCount++;
    return PerformanceSpanHandle._(span, this, previousCurrentSpan);
  }

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
  ///
  /// When [asyncSpanning] is true the entry is treated as bracketing async
  /// work (the caller will `await` between begin and end). The root span and
  /// C++ entry_id stamping happen as usual, but the entry is NOT pushed onto
  /// `_currentSpan` / `_entryStack`. This is critical: Dart's call-stack
  /// nesting is synchronous, but `await` lets unrelated microtasks
  /// (post-frame callbacks, timer ticks) run between begin and end. Without
  /// this opt-out their `beginEntry` calls would see a leaked `_currentSpan`
  /// and become children of an async entry they have nothing to do with.
  EntryHandle? beginEntry(String subType, String name,
      {Map<String, dynamic>? metadata, bool asyncSpanning = false}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;
    final anchor = sessionStart;
    if (anchor == null) return null;

    final parent = asyncSpanning ? null : _currentSpan;
    final root = PerformanceSpan(
      subType: subType,
      name: name,
      startOffsetUs: nowOffsetUs(),
      depth: (parent != null) ? parent.depth + 1 : 0,
      sessionAnchor: anchor,
      parent: parent,
      metadata: metadata,
    );

    if (parent != null) {
      parent.children.add(root);
    } else {
      rootSpans.add(root);
    }

    final entryId = _nextEntryId++;
    final previousEntryId = _entryStack.isEmpty
        ? 0
        : _entryIdMap[_entryStack.last] ?? 0;
    _entryIdToSpan[entryId] = root;
    _totalSpanCount++;

    if (!asyncSpanning) {
      _entryIdMap[root] = entryId;
      _entryStack.add(root);
      _currentSpan = root;
    }

    _setCurrentEntryId(entryId);

    return EntryHandle._(root, this, entryId, previousEntryId,
        asyncSpanning: asyncSpanning);
  }

  /// End handler for async-spanning entries.
  ///
  /// Async entries never pushed onto `_currentSpan` / `_entryStack`, so all
  /// we need is to restore the C++ entry_id to whatever sync entry is
  /// currently active (or 0). We DO NOT touch `_currentSpan` because it may
  /// belong to a completely unrelated sync entry stack that was opened while
  /// the async work was in flight.
  void _endAsyncEntry(int previousEntryId) {
    final restoredEntryId = _entryStack.isEmpty
        ? previousEntryId
        : _entryIdMap[_entryStack.last] ?? previousEntryId;
    _setCurrentEntryId(restoredEntryId);
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
    // Restore `_currentSpan` to whatever entry is STILL on the stack, not
    // to `root.parent`. `root.parent` was correct at the moment root was
    // pushed, but by the time we pop, it may have been a long-dead span
    // from an earlier frame that has no bearing on the current active
    // stack. If we resurrect it here, the next `beginEntry` will nest
    // under it — observed in multi-view / frame-callback races where 200+
    // consecutive `drawFrame` roots chained themselves under each other's
    // parent pointers, burying `flushUICommand` and its entire style/
    // paint subtree 200 levels deep. Using the live stack top keeps
    // `_currentSpan` honest regardless of `parent` staleness.
    _currentSpan = _entryStack.isEmpty ? null : _entryStack.last;
    _setCurrentEntryId(previousEntryId);
    // Note: do NOT remove from _entryIdToSpan — JS spans drained later may
    // still need to graft under this completed root.
  }

  /// Total number of spans recorded in this session.
  int get totalSpanCount => _totalSpanCount;

  /// Whether the span limit has been reached.
  bool get isAtCapacity => _totalSpanCount >= maxSpans;

  /// Get all root spans of a specific subType.
  List<PerformanceSpan> rootSpansForSubType(String subType) {
    return rootSpans.where((s) => s.subType == subType).toList();
  }

  /// Clear all recorded spans without changing the enabled state.
  void clear() {
    rootSpans.clear();
    _currentSpan = null;
    _totalSpanCount = 0;
    _entryStack.clear();
    _entryIdToSpan.clear();
    _entryIdMap.clear();
    _nextEntryId = 1;
    // Only reset C++ entry id when a session is active. When no session
    // is running, C++ profiling is disabled and the FFI sync would force
    // libwebf load in environments (e.g. unit tests) that never opted in.
    if (enabled) {
      _setCurrentEntryId(0);
    } else {
      _currentEntryId = 0;
    }
  }

  /// Export the current session data as a JSON string.
  ///
  /// If [phases] is provided, they are included so that lifecycle milestones
  /// (FP, FCP, LCP, Attach) can be reconstructed on import.
  ///
  /// JS-thread spans are intentionally not exported in v5: under the
  /// entry-rooted model they are grafted into [rootSpans] at drain time
  /// (see Task 3.3), so the export is already complete via [rootSpans].
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

  /// Import session data from a JSON string, replacing current data.
  ///
  /// Returns imported [ExportablePhase] list if present in the data.
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
    importedPhases = [];
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
      importedPhases = phasesJson
          .map((p) => ExportablePhase.fromJson(
                p as Map<String, dynamic>,
                sessionAnchor: anchor,
              ))
          .toList();
      return importedPhases;
    }
    return [];
  }
}

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
