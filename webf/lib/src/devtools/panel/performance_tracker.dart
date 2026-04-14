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

import 'dart:convert';

/// Represents a single performance span in the rendering pipeline.
class PerformanceSpan {
  final String category;
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  final int depth;
  final PerformanceSpan? parent;
  final List<PerformanceSpan> children = [];
  Map<String, dynamic>? metadata;

  PerformanceSpan({
    required this.category,
    required this.name,
    required this.startTime,
    required this.depth,
    this.parent,
    this.metadata,
  });

  Duration get duration =>
      endTime != null ? endTime!.difference(startTime) : Duration.zero;

  /// Time spent in this span excluding children.
  Duration get selfDuration {
    final childTotal =
        children.fold<Duration>(Duration.zero, (sum, c) => sum + c.duration);
    final d = duration - childTotal;
    return d.isNegative ? Duration.zero : d;
  }

  bool get isComplete => endTime != null;

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
        'category': category,
        'name': name,
        'startTime': startTime.microsecondsSinceEpoch,
        'endTime': endTime?.microsecondsSinceEpoch,
        'depth': depth,
        if (metadata != null && metadata!.isNotEmpty) 'metadata': metadata,
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
      };

  static PerformanceSpan fromJson(Map<String, dynamic> json,
      {PerformanceSpan? parent}) {
    final span = PerformanceSpan(
      category: json['category'] as String,
      name: json['name'] as String,
      startTime:
          DateTime.fromMicrosecondsSinceEpoch(json['startTime'] as int),
      depth: json['depth'] as int,
      parent: parent,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
    if (json['endTime'] != null) {
      span.endTime =
          DateTime.fromMicrosecondsSinceEpoch(json['endTime'] as int);
    }
    if (json['children'] != null) {
      for (final childJson in json['children'] as List) {
        span.children
            .add(PerformanceSpan.fromJson(childJson as Map<String, dynamic>,
                parent: span));
      }
    }
    return span;
  }
}

/// Handle returned by [PerformanceTracker.beginSpan] to end a span.
class PerformanceSpanHandle {
  final PerformanceSpan _span;
  final PerformanceTracker _tracker;

  PerformanceSpanHandle._(this._span, this._tracker);

  /// End this span and pop back to the parent span.
  void end({Map<String, dynamic>? metadata}) {
    _span.endTime = DateTime.now();
    if (metadata != null) {
      _span.metadata = (_span.metadata ?? {})..addAll(metadata);
    }
    _tracker._currentSpan = _span.parent;
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

  /// Top-level spans (not children of any other span).
  final List<PerformanceSpan> rootSpans = [];

  /// Currently active span (acts as call stack via parent pointer).
  PerformanceSpan? _currentSpan;

  /// When the current recording session started.
  DateTime? sessionStart;

  int _totalSpanCount = 0;

  /// Maximum number of spans to record per session to prevent memory issues.
  static const int maxSpans = 10000;

  /// Start a new recording session. Clears all previous spans.
  void startSession() {
    sessionStart = DateTime.now();
    rootSpans.clear();
    _currentSpan = null;
    _totalSpanCount = 0;
    enabled = true;
  }

  /// End the current recording session. Spans are preserved for reading.
  void endSession() {
    enabled = false;
    // Close any unclosed spans
    while (_currentSpan != null) {
      _currentSpan!.endTime ??= DateTime.now();
      _currentSpan = _currentSpan!.parent;
    }
  }

  /// Begin a new performance span.
  ///
  /// If another span is currently active, the new span becomes its child.
  /// Returns a [PerformanceSpanHandle] to end the span, or null if tracking
  /// is disabled or the span limit has been reached.
  ///
  /// [category] identifies the pipeline stage: 'cssParse', 'styleFlush',
  /// 'styleRecalc', 'styleApply', 'layout', 'paint'.
  ///
  /// [name] identifies the specific operation: 'parseStylesheet', 'flushStyle',
  /// 'recalculateStyle', 'flexLayout', 'paint', etc.
  PerformanceSpanHandle? beginSpan(String category, String name,
      {Map<String, dynamic>? metadata}) {
    if (!enabled || _totalSpanCount >= maxSpans) return null;

    final span = PerformanceSpan(
      category: category,
      name: name,
      startTime: DateTime.now(),
      depth: (_currentSpan != null) ? _currentSpan!.depth + 1 : 0,
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

  /// Total number of spans recorded in this session.
  int get totalSpanCount => _totalSpanCount;

  /// Whether the span limit has been reached.
  bool get isAtCapacity => _totalSpanCount >= maxSpans;

  /// Get all root spans of a specific category.
  List<PerformanceSpan> rootSpansForCategory(String category) {
    return rootSpans.where((s) => s.category == category).toList();
  }

  /// Clear all recorded spans without changing the enabled state.
  void clear() {
    rootSpans.clear();
    _currentSpan = null;
    _totalSpanCount = 0;
  }

  /// Export the current session data as a JSON string.
  ///
  /// If [phases] is provided, they are included so that lifecycle milestones
  /// (FP, FCP, LCP, Attach) can be reconstructed on import.
  String exportToJson({List<ExportablePhase>? phases}) {
    int countSpans(List<PerformanceSpan> spans) {
      int count = 0;
      for (final s in spans) {
        count += 1 + countSpans(s.children);
      }
      return count;
    }

    final data = <String, dynamic>{
      'version': 2,
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
    rootSpans.clear();
    _currentSpan = null;
    enabled = false;

    if (data['sessionStart'] != null) {
      sessionStart =
          DateTime.fromMicrosecondsSinceEpoch(data['sessionStart'] as int);
    }

    final spans = data['rootSpans'] as List;
    for (final spanJson in spans) {
      rootSpans
          .add(PerformanceSpan.fromJson(spanJson as Map<String, dynamic>));
    }
    _totalSpanCount = data['totalSpanCount'] as int? ?? rootSpans.length;

    // Restore phases if present
    final phasesJson = data['phases'] as List?;
    if (phasesJson != null) {
      return phasesJson
          .map((p) => ExportablePhase.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

/// Lightweight phase representation for export/import.
///
/// Captures just the name and timestamp from LoadingState phases so that
/// lifecycle milestones (FP, FCP, LCP, Attach) survive round-tripping.
class ExportablePhase {
  final String name;
  final DateTime timestamp;

  ExportablePhase({required this.name, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'name': name,
        'timestamp': timestamp.microsecondsSinceEpoch,
      };

  static ExportablePhase fromJson(Map<String, dynamic> json) {
    return ExportablePhase(
      name: json['name'] as String,
      timestamp:
          DateTime.fromMicrosecondsSinceEpoch(json['timestamp'] as int),
    );
  }
}
