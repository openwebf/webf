/*
 * Copyright (C) 2026-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

/// Tracks the lifecycle of every DOM node created via the UI command buffer
/// so the profiler can report:
///
///   - **created**:   total nodes constructed in this session
///   - **inserted**:  nodes that ever became part of a connected subtree
///   - **disposed**:  nodes whose binding was destroyed
///   - **orphan**:    created → never inserted → disposed (pure waste)
///   - **ephemeral**: created → inserted → removed inside the same session
///                    (lived briefly, often a render-then-replace pattern)
///
/// Identity is keyed on the C++ NativeBindingObject pointer address. The
/// tracker is intentionally minimal — it does not hold the binding object,
/// just records create/insert/remove/dispose timestamps in microseconds
/// from the [PerformanceTracker] session start.
///
/// Cleared on session start so each profile capture is self-contained.
library;

import 'package:webf/src/devtools/panel/performance_tracker.dart';

class _NodeRecord {
  /// Tag name (or '#text', '#comment', '#fragment').
  final String tag;
  final int createdAtUs;
  int? insertedAtUs;
  int? removedAtUs;
  int? disposedAtUs;

  _NodeRecord({required this.tag, required this.createdAtUs});

  bool get wasInserted => insertedAtUs != null;
  bool get wasRemoved => removedAtUs != null;
  bool get wasDisposed => disposedAtUs != null;
}

class DomLifecycleTracker {
  DomLifecycleTracker._();
  static final DomLifecycleTracker instance = DomLifecycleTracker._();

  /// Map from native binding-object pointer address to its lifecycle record.
  /// Capped at [_kMaxRecords] to bound memory; once full, new records are
  /// dropped (the existing ones still get their insert/remove/dispose
  /// updates, so we lose visibility on late-session creates but keep the
  /// early picture intact).
  final Map<int, _NodeRecord> _records = {};
  static const int _kMaxRecords = 200000;
  bool _capacityReached = false;

  /// Number of records dropped because the cap was hit. Surfaced in the
  /// summary so the analysis script knows the picture is partial.
  int _droppedCreates = 0;

  /// Tracks the `PerformanceTracker.sessionStart` we last saw so that a new
  /// session auto-clears stale records without requiring an explicit hook.
  /// Avoids an import cycle: the tracker itself doesn't need to know about
  /// the lifecycle subsystem.
  DateTime? _lastSessionStart;

  void clear() {
    _records.clear();
    _capacityReached = false;
    _droppedCreates = 0;
  }

  void _maybeResetForNewSession() {
    final s = PerformanceTracker.instance.sessionStart;
    if (s != _lastSessionStart) {
      _lastSessionStart = s;
      clear();
    }
  }

  void recordCreate(int ptrAddr, String tag) {
    if (!PerformanceTracker.instance.enabled) return;
    _maybeResetForNewSession();
    if (_records.length >= _kMaxRecords) {
      _capacityReached = true;
      _droppedCreates++;
      return;
    }
    // Pointer reuse can happen if the same address gets allocated to a new
    // binding object after the previous one was disposed. If the existing
    // record has been disposed, replace it; otherwise keep the older one
    // (the create call is likely a duplicate/spurious notification).
    final existing = _records[ptrAddr];
    if (existing != null && !existing.wasDisposed) return;
    _records[ptrAddr] = _NodeRecord(
      tag: tag,
      createdAtUs: PerformanceTracker.instance.nowOffsetUs(),
    );
  }

  void recordInsert(int ptrAddr) {
    if (!PerformanceTracker.instance.enabled) return;
    final r = _records[ptrAddr];
    if (r == null) return;
    // First insert wins — re-inserts of the same node just overwrite the
    // remove timestamp (the node is back in the tree).
    r.insertedAtUs ??= PerformanceTracker.instance.nowOffsetUs();
    r.removedAtUs = null;
  }

  void recordRemove(int ptrAddr) {
    if (!PerformanceTracker.instance.enabled) return;
    final r = _records[ptrAddr];
    if (r == null) return;
    r.removedAtUs = PerformanceTracker.instance.nowOffsetUs();
  }

  void recordDispose(int ptrAddr) {
    if (!PerformanceTracker.instance.enabled) return;
    final r = _records[ptrAddr];
    if (r == null) return;
    r.disposedAtUs = PerformanceTracker.instance.nowOffsetUs();
  }

  /// Aggregate summary for inclusion in the JSON export.
  Map<String, dynamic> toSummary() {
    int created = _records.length;
    int inserted = 0;
    int removed = 0;
    int disposed = 0;
    int orphans = 0;     // created, never inserted, disposed (pure waste)
    int ephemerals = 0;  // created, inserted, then removed (replaced/swapped)
    int stillborn = 0;   // created, never inserted, never disposed (still pending)
    final Map<String, int> orphansByTag = {};
    final Map<String, int> ephemeralsByTag = {};

    for (final r in _records.values) {
      if (r.wasInserted) inserted++;
      if (r.wasRemoved) removed++;
      if (r.wasDisposed) disposed++;
      if (!r.wasInserted && r.wasDisposed) {
        orphans++;
        orphansByTag[r.tag] = (orphansByTag[r.tag] ?? 0) + 1;
      } else if (r.wasInserted && r.wasRemoved) {
        ephemerals++;
        ephemeralsByTag[r.tag] = (ephemeralsByTag[r.tag] ?? 0) + 1;
      } else if (!r.wasInserted && !r.wasDisposed) {
        stillborn++;
      }
    }

    return {
      'created': created,
      'inserted': inserted,
      'removed': removed,
      'disposed': disposed,
      'orphans': orphans,
      'ephemerals': ephemerals,
      'stillborn': stillborn,
      'orphansByTag': orphansByTag,
      'ephemeralsByTag': ephemeralsByTag,
      if (_capacityReached) 'capacityReached': true,
      if (_droppedCreates > 0) 'droppedCreates': _droppedCreates,
    };
  }
}
