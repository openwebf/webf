/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

/// Waterfall performance chart for the WebF inspector panel.
///
/// Provides two visualization modes:
/// - **Overview**: One row per entry-call origin (drawFrame, flushUICommand,
///   invokeBindingMethodFromNative, JS timers/RAF/microtasks, etc.) on a shared
///   time axis, alongside lifecycle and network rows, with milestone markers
///   (FP, FCP, LCP). Row order is fixed by [kWaterfallRowOrder].
/// - **Flame chart**: Drill-down into the entry's full PerformanceSpan tree —
///   every nested span (style recalc, layout, paint, drained JS spans, …)
///   with self-time vs child-time coloring.
library;

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/launcher/loading_state.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
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

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

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

class WaterfallSubEntry {
  final String label;
  final Color color;
  Duration start;
  Duration end;

  WaterfallSubEntry({
    required this.label,
    required this.color,
    required this.start,
    required this.end,
  });

  Duration get duration => end - start;
}

class WaterfallMilestone {
  final String label;
  Duration offset;
  final Color color;
  final bool isStageDivider; // true for stage transitions like attachToFlutter

  WaterfallMilestone({
    required this.label,
    required this.offset,
    required this.color,
    this.isStageDivider = false,
  });
}

class WaterfallData {
  final List<WaterfallEntry> entries;
  final List<WaterfallMilestone> milestones;
  final List<Duration> frameBoundaries;
  final Duration totalDuration;
  /// Offset of the attachToFlutter phase (null if not a preload/prerender session).
  /// Everything before this is "Preload/Prerender", everything after is "Display".
  final Duration? attachOffset;

  WaterfallData({
    required this.entries,
    required this.milestones,
    this.frameBoundaries = const [],
    required this.totalDuration,
    this.attachOffset,
  });
}

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

// ---------------------------------------------------------------------------
// Data builder — transforms LoadingState + PerformanceTracker → WaterfallData
// ---------------------------------------------------------------------------

WaterfallData buildWaterfallData(
    LoadingState loadingState, PerformanceTracker tracker,
    {List<ExportablePhase>? importedPhases}) {
  try {
    return _buildWaterfallDataImpl(loadingState, tracker,
        importedPhases: importedPhases);
  } catch (e) {
    // Error building waterfall data — return empty gracefully
    return WaterfallData(
        entries: [], milestones: [], totalDuration: Duration.zero);
  }
}

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

  // --- Milestones ---
  // Use offsetFromPair so milestones share the same clock (monotonic when
  // available) as root-span entries — otherwise attachOffset would drift
  // from entry.start and phase filtering would misattribute entries.
  for (int i = 0; i < phaseNames.length; i++) {
    final name = phaseNames[i];
    final ts = phaseTimestamps[i];
    final off = offsetFromPair(ts, phaseOffsetUs[i]);
    if (name == LoadingState.phaseAttachToFlutter) {
      attachOffset = off;
      milestones.add(WaterfallMilestone(
        label: 'Attach', offset: off,
        color: const Color(0xFFFFB74D), isStageDivider: true,
      ));
    } else if (name == LoadingState.phaseFirstPaint) {
      milestones.add(WaterfallMilestone(
        label: 'FP', offset: off, color: const Color(0xFF4CAF50)));
    } else if (name == LoadingState.phaseFirstContentfulPaint) {
      milestones.add(WaterfallMilestone(
        label: 'FCP', offset: off, color: const Color(0xFF2196F3)));
    } else if (name == LoadingState.phaseLargestContentfulPaint ||
        name == LoadingState.phaseFinalLargestContentfulPaint) {
      milestones.add(WaterfallMilestone(
        label: 'LCP', offset: off, color: const Color(0xFFF44336)));
    }
  }

  // Frame boundaries: end-of-frame markers from completed drawFrame entries.
  // The ruler & dropped-frame highlight read these.
  final frameBoundaries = <Duration>[];
  for (final span in rootSnapshot) {
    if (span.subType != kSubTypeDrawFrame) continue;
    if (!span.isComplete) continue;
    frameBoundaries.add(shiftedOffset(span.endOffsetUs!));
  }
  frameBoundaries.sort();

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
    for (int i = 0; i < frameBoundaries.length; i++) {
      frameBoundaries[i] = frameBoundaries[i] - minStart;
    }
    if (attachOffset != null) {
      attachOffset = attachOffset - minStart;
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
    frameBoundaries: frameBoundaries,
    totalDuration: maxEnd,
    attachOffset: attachOffset,
  );
}

String _spanLabel(PerformanceSpan span) {
  final meta = span.metadata;
  if (meta != null) {
    if (meta.containsKey('url')) return 'parse ${meta['url']}';
    if (meta.containsKey('tagName')) return '${span.name}(${meta['tagName']})';
  }
  return span.name;
}

/// Returns true when [subType] is a JS-thread origin entry (kSubTypeJs*).
bool _isJSThreadSubType(String subType) {
  return subType == kSubTypeJsTimer ||
      subType == kSubTypeJsRAF ||
      subType == kSubTypeJsMicrotask ||
      subType == kSubTypeJsScriptEval ||
      subType == kSubTypeJsEvent ||
      subType == kSubTypeJsIdle ||
      subType == kSubTypeJsMutationObserver ||
      subType == kSubTypeJsFlushUICommand ||
      subType == kSubTypeJsBindingSyncCall ||
      subType == kSubTypeJsFunction ||
      subType == kSubTypeJsCFunction;
}

Color _lifecycleColor(String name) {
  switch (name) {
    case 'init':
      return const Color(0xFF1565C0);
    case 'preload':
      return const Color(0xFF8D6E00);
    case 'preRender':
      return const Color(0xFF8D6E00);
    case 'loadStart':
      return const Color(0xFF0277BD);
    case 'evaluateStart':
      return const Color(0xFF00838F);
    case 'evaluateComplete':
      return const Color(0xFF00695C);
    case 'domContentLoaded':
      return const Color(0xFF2E7D32);
    case 'windowLoad':
      return const Color(0xFFE65100);
    case 'attachToFlutter':
      return const Color(0xFFFFB74D);
    default:
      return const Color(0xFF546E7A);
  }
}

// ---------------------------------------------------------------------------
// Color scheme for spans
// ---------------------------------------------------------------------------

Color _flameSpanColor(PerformanceSpan span) {
  switch (span.subType) {
    case 'cssParse':
      return const Color(0xFF5C6BC0);
    case 'styleFlush':
      return const Color(0xFFAB47BC);
    case 'styleRecalc':
      return const Color(0xFFCE93D8);
    case 'styleApply':
      return const Color(0xFFE1BEE7);
    case 'layout':
      switch (span.name) {
        case 'flexLayout':
          return const Color(0xFFFFB74D);
        case 'flowLayout':
          return const Color(0xFFFFCC80);
        case 'gridLayout':
          return const Color(0xFFFFE0B2);
        default:
          return const Color(0xFFFFA726);
      }
    case 'paint':
      return const Color(0xFFEC407A);
    case 'jsEval':
      return const Color(0xFFEF5350);
    case 'htmlParse':
      return const Color(0xFF26A69A);
    case 'domConstruction':
      return const Color(0xFF78909C);
    case 'build':
      return const Color(0xFF29B6F6);
    case 'network':
      return const Color(0xFF66BB6A);
    default:
      return const Color(0xFF90A4AE);
  }
}

// ---------------------------------------------------------------------------
// WaterfallChart widget
// ---------------------------------------------------------------------------

enum _ChartMode { overview, flame }

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

  @override
  State<WaterfallChart> createState() => _WaterfallChartState();
}

class _WaterfallChartState extends State<WaterfallChart> {
  _ChartMode _mode = _ChartMode.overview;
  PerformanceSpan? _selectedSpan;
  List<PerformanceSpan> _selectedSpans = const [];
  double _zoom = 1.0;
  double _flameZoom = 1.0;

  // Scroll controllers
  final ScrollController _rulerHScrollController = ScrollController();
  final ScrollController _chartHScrollController = ScrollController();
  final ScrollController _labelsVScrollController = ScrollController();
  final ScrollController _barsVScrollController = ScrollController();
  // Saved scroll positions for restoring after drill-down
  double _savedOverviewHScrollOffset = 0.0;
  double _savedOverviewVScrollOffset = 0.0;
  double _savedFlameHScrollOffset = 0.0;

  // Flame chart mode controllers
  final ScrollController _flameRulerHScrollController = ScrollController();
  final ScrollController _flameBodyHScrollController = ScrollController();

  /// Set of subTypes that are currently visible in the overview.
  /// Initialised lazily to "all known subTypes from the current dataset".
  final Set<String> _enabledSubTypes = <String>{};
  // Tracks every subType the build has emitted so far. When a new subType
  // first appears mid-session (eg. the first navigation triggers htmlParse),
  // it gets auto-enabled. SubTypes the user has explicitly toggled off stay
  // off because we only auto-enable when we see them for the FIRST time.
  final Set<String> _seenSubTypes = <String>{};

  // Tap detail
  PerformanceSpan? _detailSpan;
  WaterfallEntry? _selectedEntry;

  // Cluster drill-downs (e.g. 733 drawFrames merged by the 50ms-gap rule)
  // can ingest 95k+ spans into one flame chart, making individual frames
  // indistinguishable. When set, narrow the flame chart to a single root
  // picked from the cluster; tapping a depth-0 root in cluster mode enters
  // this state, the back button exits it.
  PerformanceSpan? _focusedRoot;

  bool _syncingScroll = false;

  // --- Data cache ---
  WaterfallData? _cachedData;
  int _cachedSpanCount = -1;
  int _cachedPhaseCount = -1;
  int _cachedNetworkCount = -1;

  List<_OverviewItem>? _cachedItems;
  Set<String>? _cachedFilterSet;
  WaterfallPhase? _cachedFilterPhase;
  int _cachedImportedPhaseCount = -1;

  WaterfallData _getData() {
    final tracker = widget.tracker;
    final ls = widget.loadingState;
    final spanCount = tracker.totalSpanCount;
    final phaseCount = ls.phases.length;
    final networkCount = ls.networkRequests.length;
    final importedPhaseCount = tracker.importedPhases.length;
    if (_cachedData != null &&
        spanCount == _cachedSpanCount &&
        phaseCount == _cachedPhaseCount &&
        networkCount == _cachedNetworkCount &&
        importedPhaseCount == _cachedImportedPhaseCount) {
      return _cachedData!;
    }
    final imported =
        tracker.importedPhases.isNotEmpty ? tracker.importedPhases : null;
    _cachedData = buildWaterfallData(ls, tracker, importedPhases: imported);
    _cachedSpanCount = spanCount;
    _cachedPhaseCount = phaseCount;
    _cachedNetworkCount = networkCount;
    _cachedImportedPhaseCount = importedPhaseCount;
    _cachedItems = null; // invalidate derived cache
    return _cachedData!;
  }

  List<_OverviewItem> _getItems(WaterfallData data) {
    // Auto-enable any subType the first time we see it. Explicit user
    // disables stick because the chip handler only flips _enabledSubTypes,
    // never _seenSubTypes.
    for (final entry in data.entries) {
      if (_seenSubTypes.add(entry.subType)) {
        _enabledSubTypes.add(entry.subType);
      }
    }
    if (_cachedItems != null &&
        _setEquals(_cachedFilterSet, _enabledSubTypes) &&
        _cachedFilterPhase == widget.phase) {
      return _cachedItems!;
    }
    final filtered = data.entries
        .where((e) => _enabledSubTypes.contains(e.subType))
        .where((e) => includeEntryForPhase(e, widget.phase, data.attachOffset))
        .toList();

    // Separate Dart thread and JS thread entries
    final dartEntries = filtered.where((e) => !_isJSThreadSubType(e.subType)).toList();
    final jsEntries = filtered.where((e) => _isJSThreadSubType(e.subType)).toList();

    final items = <_OverviewItem>[];

    // Dart thread entries
    if (dartEntries.isNotEmpty) {
      items.add(_OverviewItem.header('Dart Thread'));
      for (final entry in dartEntries) {
        items.add(_OverviewItem.entry(entry));
      }
    }

    // JS thread entries
    if (jsEntries.isNotEmpty) {
      items.add(_OverviewItem.header('JS Thread'));
      for (final entry in jsEntries) {
        items.add(_OverviewItem.entry(entry));
      }
    }

    _cachedItems = items;
    _cachedFilterSet = Set.from(_enabledSubTypes);
    _cachedFilterPhase = widget.phase;
    return items;
  }

  static bool _setEquals(Set<String>? a, Set<String> b) {
    if (a == null || a.length != b.length) return false;
    return a.containsAll(b);
  }

  @override
  void initState() {
    super.initState();
    _rulerHScrollController.addListener(() => _syncScroll(
        _rulerHScrollController, _chartHScrollController));
    _chartHScrollController.addListener(() => _syncScroll(
        _chartHScrollController, _rulerHScrollController));
    _labelsVScrollController.addListener(() => _syncScroll(
        _labelsVScrollController, _barsVScrollController));
    _barsVScrollController.addListener(() => _syncScroll(
        _barsVScrollController, _labelsVScrollController));
    _flameRulerHScrollController.addListener(() => _syncScroll(
        _flameRulerHScrollController, _flameBodyHScrollController));
    _flameBodyHScrollController.addListener(() => _syncScroll(
        _flameBodyHScrollController, _flameRulerHScrollController));
  }

  void _syncScroll(ScrollController source, ScrollController target) {
    if (_syncingScroll) return;
    if (!target.hasClients) return;
    _syncingScroll = true;
    target.jumpTo(source.offset);
    _syncingScroll = false;
  }

  @override
  void dispose() {
    _rulerHScrollController.dispose();
    _chartHScrollController.dispose();
    _labelsVScrollController.dispose();
    _barsVScrollController.dispose();
    _flameRulerHScrollController.dispose();
    _flameBodyHScrollController.dispose();
    super.dispose();
  }

  void _drillDownEntry(WaterfallEntry entry) {
    // Save current overview scroll positions before switching to flame chart
    _savedOverviewHScrollOffset = _chartHScrollController.hasClients
        ? _chartHScrollController.offset : 0.0;
    _savedOverviewVScrollOffset = _barsVScrollController.hasClients
        ? _barsVScrollController.offset : 0.0;

    if (PerformanceTracker.instance.debugLogDrilldown) {
      _logDrilldownTarget(entry);
    }

    setState(() {
      _selectedSpan = entry.span;
      _selectedSpans = entry.spans;
      _mode = _ChartMode.flame;
      _flameZoom = 1.0;
      _detailSpan = null;
      _selectedEntry = null;
      _focusedRoot = null;
    });
  }

  /// Back-button header used by the flame chart's empty-state return so
  /// the user isn't trapped when a drilldown target has no inner spans to
  /// render. The full flame chart builds its own richer header inline;
  /// this one carries only the essentials (arrow + title + subtitle).
  Widget _buildFlameHeaderBar(
      {required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: const Color(0xFF262626),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              _savedFlameHScrollOffset = _flameBodyHScrollController.hasClients
                  ? _flameBodyHScrollController.offset
                  : 0.0;
              setState(() {
                _mode = _ChartMode.overview;
                _selectedSpan = null;
                _selectedSpans = const [];
                _detailSpan = null;
                _focusedRoot = null;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_chartHScrollController.hasClients) {
                  _chartHScrollController.jumpTo(_savedOverviewHScrollOffset);
                }
                if (_barsVScrollController.hasClients) {
                  _barsVScrollController.jumpTo(_savedOverviewVScrollOffset);
                }
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back, size: 14, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 8),
          Text(subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  /// One-shot diagnostic dump for a drill-down target. Prints the span's
  /// own window, subtree size, tree-integrity violations (children whose
  /// interval escapes the parent — typically a sign that `_attachJSSpan`
  /// placed them under the wrong parent), and a small sample of direct
  /// children. Written to stdout so it lands in the Flutter console
  /// alongside the app log.
  void _logDrilldownTarget(WaterfallEntry entry) {
    final spans = entry.spans.isNotEmpty
        ? entry.spans
        : (entry.span != null ? [entry.span!] : const <PerformanceSpan>[]);
    if (spans.isEmpty) {
      // ignore: avoid_print
      print('[drilldown] entry has no underlying spans');
      return;
    }
    final isCluster = spans.length > 1;
    final label = isCluster
        ? 'CLUSTER ${spans.length}×${spans.first.subType}'
        : '${spans.first.subType}/"${spans.first.name}"';
    // ignore: avoid_print
    print('[drilldown] ─── $label ───');

    int totalSubtree = 0;
    int totalViolations = 0;
    int totalOpen = 0;
    int maxDepth = 0;
    for (final s in spans) {
      final stats = _spanStats(s);
      totalSubtree += stats.subtreeCount;
      totalViolations += stats.violations;
      totalOpen += stats.openChildren;
      if (stats.maxDepth > maxDepth) maxDepth = stats.maxDepth;
    }

    for (final s in spans.take(3)) {
      final start = s.startOffsetUs;
      final end = s.endOffsetUs;
      final dur = (end ?? start) - start;
      final kids = s.children.length;
      // ignore: avoid_print
      print('[drilldown]   root: ${s.subType}/"${s.name}" '
          '[$start..${end ?? "(open)"}] dur=${dur}us '
          'direct=$kids depth=${s.depth}');
      for (final c in s.children.take(5)) {
        final cStart = c.startOffsetUs;
        final cEnd = c.endOffsetUs;
        final cDur = (cEnd ?? cStart) - cStart;
        final overflow = (cEnd != null && end != null && cEnd > end)
            ? ' !!overflow by ${cEnd - end}us'
            : '';
        // ignore: avoid_print
        print('[drilldown]     child: ${c.subType}/"${c.name}" '
            '[$cStart..${cEnd ?? "(open)"}] dur=${cDur}us '
            'kids=${c.children.length}$overflow');
      }
      if (s.children.length > 5) {
        // ignore: avoid_print
        print('[drilldown]     … ${s.children.length - 5} more children');
      }
    }
    if (spans.length > 3) {
      // ignore: avoid_print
      print('[drilldown]   … ${spans.length - 3} more cluster roots');
    }
    // ignore: avoid_print
    print('[drilldown]   subtree total: $totalSubtree spans, '
        'maxDepth=$maxDepth, '
        'integrity-violations=$totalViolations, '
        'still-open=$totalOpen');
  }

  _SpanStats _spanStats(PerformanceSpan s) {
    int count = 0;
    int maxDepth = s.depth;
    int violations = 0;
    int open = 0;
    void walk(PerformanceSpan n) {
      count++;
      if (n.depth > maxDepth) maxDepth = n.depth;
      if (n.endOffsetUs == null) open++;
      final parent = n.parent;
      if (parent != null && n.endOffsetUs != null && parent.endOffsetUs != null
          && n.endOffsetUs! > parent.endOffsetUs!) {
        violations++;
      }
      for (final c in n.children) {
        walk(c);
      }
    }
    walk(s);
    return _SpanStats(count, maxDepth, violations, open);
  }

  @override
  Widget build(BuildContext context) {
    final data = _getData();

    return Column(
      children: [
        _buildToolbar(data),
        const Divider(height: 1, color: Colors.white24),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: _mode == _ChartMode.overview
                    ? _buildOverview(data)
                    : _buildFlameChart(),
              ),
              if (_selectedEntry != null && _mode == _ChartMode.overview)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildEntryDetailPanel(),
                ),
              if (_detailSpan != null && _mode == _ChartMode.flame)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildDetailPanel(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // -- Toolbar --

  Widget _buildToolbar(WaterfallData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: [
            if (widget.onToggleFullscreen != null) ...[
              _buildToolbarButton(
                icon: widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                label: widget.isFullscreen ? 'Exit' : 'Fullscreen',
                onTap: widget.onToggleFullscreen!,
              ),
              const SizedBox(width: 8),
            ],
            // Mode toggle
            _modeChip('Overview', _ChartMode.overview),
            const SizedBox(width: 4),
            _modeChip('Flame', _ChartMode.flame),
            const SizedBox(width: 12),
            // Zoom
            InkWell(
              onTap: () => setState(() {
                if (_mode == _ChartMode.flame) {
                  _flameZoom = (_flameZoom / 1.5).clamp(0.25, 64);
                } else {
                  _zoom = (_zoom / 1.5).clamp(0.25, 64);
                }
              }),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.remove, size: 16, color: Colors.white70),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${((_mode == _ChartMode.flame ? _flameZoom : _zoom) * 100).round()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
            InkWell(
              onTap: () => setState(() {
                if (_mode == _ChartMode.flame) {
                  _flameZoom = (_flameZoom * 1.5).clamp(0.25, 64);
                } else {
                  _zoom = (_zoom * 1.5).clamp(0.25, 64);
                }
              }),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.add, size: 16, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 12),
            // SubType filters (overview mode only). The filter set is built
            // from the current dataset's subTypes, ordered by kWaterfallRowOrder.
            if (_mode == _ChartMode.overview) ...[
              for (final subType in _filterSubTypes(data)) ...[
                _subTypeFilterChip(subType),
                const SizedBox(width: 2),
              ],
            ],
            const SizedBox(width: 12),
            // Record button
            _buildRecordButton(),
            const SizedBox(width: 8),
            // Export button
            _buildToolbarButton(
              icon: Icons.file_download_outlined,
              label: 'Export',
              onTap: _exportProfile,
            ),
            const SizedBox(width: 4),
            // Import button
            _buildToolbarButton(
              icon: Icons.file_upload_outlined,
              label: 'Import',
              onTap: _showImportDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(String label, _ChartMode mode) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () {
        // Save scroll position of the current mode before switching
        if (_mode == _ChartMode.overview) {
          _savedOverviewHScrollOffset = _chartHScrollController.hasClients
              ? _chartHScrollController.offset : 0.0;
          _savedOverviewVScrollOffset = _barsVScrollController.hasClients
              ? _barsVScrollController.offset : 0.0;
        } else if (_mode == _ChartMode.flame) {
          _savedFlameHScrollOffset = _flameBodyHScrollController.hasClients
              ? _flameBodyHScrollController.offset : 0.0;
        }
        setState(() {
          _mode = mode;
          _detailSpan = null;
          if (mode == _ChartMode.overview) {
            _selectedSpan = null;
            _selectedSpans = const [];
          }
        });
        // Restore scroll position of the target mode after frame renders
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mode == _ChartMode.overview) {
            if (_chartHScrollController.hasClients) {
              _chartHScrollController.jumpTo(_savedOverviewHScrollOffset);
            }
            if (_barsVScrollController.hasClients) {
              _barsVScrollController.jumpTo(_savedOverviewVScrollOffset);
            }
          } else if (mode == _ChartMode.flame) {
            if (_flameBodyHScrollController.hasClients) {
              _flameBodyHScrollController.jumpTo(_savedFlameHScrollOffset);
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? Colors.white38 : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// SubTypes appearing in the current dataset, ordered by kWaterfallRowOrder
  /// (then any unknown subTypes appended in insertion order).
  ///
  /// Auto-enables any first-seen subType so the chip and the row light up on
  /// the same frame. Toolbar builds before the body, so deferring auto-enable
  /// to [_getItems] would leave the chip rendered as disabled while the row
  /// still renders — and a subsequent click on the "disabled" chip would
  /// actually toggle the subType OFF, sticking it disabled going forward.
  List<String> _filterSubTypes(WaterfallData data) {
    for (final entry in data.entries) {
      if (_seenSubTypes.add(entry.subType)) {
        _enabledSubTypes.add(entry.subType);
      }
    }
    final present = <String>{for (final e in data.entries) e.subType};
    return <String>[
      ...kWaterfallRowOrder.where(present.contains),
      ...present.where((s) => !kWaterfallRowOrder.contains(s)),
    ];
  }

  Widget _subTypeFilterChip(String subType) {
    final enabled = _enabledSubTypes.contains(subType);
    final color = colorForSubType(subType);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (enabled) {
            _enabledSubTypes.remove(subType);
          } else {
            _enabledSubTypes.add(subType);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: enabled
              ? color.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: enabled
                ? color.withOpacity(0.6)
                : Colors.white12,
          ),
        ),
        child: Text(
          subType,
          style: TextStyle(
            color: enabled ? color : Colors.white38,
            fontSize: 9,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    final recording = widget.tracker.enabled;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (recording) {
            widget.tracker.endSession();
          } else {
            widget.tracker.startSession();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: recording ? Colors.red.withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: recording ? Colors.red.withOpacity(0.5) : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              recording ? Icons.stop : Icons.fiber_manual_record,
              size: 12,
              color: recording ? Colors.red : Colors.white54,
            ),
            const SizedBox(width: 4),
            Text(
              recording ? 'Stop' : 'Record',
              style: TextStyle(
                color: recording ? Colors.red : Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white54),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _exportProfile() {
    try {
      final tracker = widget.tracker;
      // Gather phases from LoadingState for milestone reconstruction.
      // Skip phases with null offsetUs — they were captured before the
      // tracker's session started and have no valid monotonic representation.
      // Coercing them to 0 would silently corrupt the export round-trip.
      final phases = widget.loadingState.phases
          .where((p) => p.offsetUs != null)
          .map((p) => ExportablePhase(
                name: p.name,
                timestamp: p.timestamp,
                offsetUs: p.offsetUs!,
              ))
          .toList();
      final json = tracker.exportToJson(phases: phases);

      // Write to temp directory with timestamp
      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/webf_profile_$ts.json');
      file.writeAsStringSync(json);

      final path = file.path;
      final fileName = file.uri.pathSegments.last;
      final isAndroid = Platform.isAndroid;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Profile Exported',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saved to:',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 4),
                SelectableText(
                  path,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (isAndroid) ...[
                  const SizedBox(height: 12),
                  const Text('Pull from device via adb:',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  SelectableText(
                    'adb pull $path ./$fileName',
                    style: const TextStyle(
                        color: Color(0xFF80CBC4),
                        fontSize: 12,
                        fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 8),
                  const Text('Or copy to device sdcard first:',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  SelectableText(
                    'adb shell cp $path /sdcard/$fileName\n'
                    'adb pull /sdcard/$fileName ./$fileName',
                    style: const TextStyle(
                        color: Color(0xFF80CBC4),
                        fontSize: 12,
                        fontFamily: 'monospace'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    } catch (e, st) {
      debugPrint('Export failed: $e\n$st');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Export Failed',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
          content: Text(
            '$e',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    }
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Import Profile',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Enter path to .json profile file',
              hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _importProfile(controller.text.trim());
            },
            child: const Text('Import',
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _importProfile(String path) {
    if (path.isEmpty) return;
    try {
      final file = File(path);
      if (!file.existsSync()) {
        _showResultDialog('File Not Found', path);
        return;
      }
      final content = file.readAsStringSync();
      widget.tracker.importFromJson(content);
      setState(() {
        _cachedData = null; // force rebuild
        _cachedSpanCount = -1;
        _cachedImportedPhaseCount = -1;
      });
      _showResultDialog('Profile Imported', 'Loaded ${widget.tracker.totalSpanCount} spans from\n$path');
    } catch (e) {
      _showResultDialog('Import Failed', '$e');
    }
  }

  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        content: SelectableText(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // -- Overview mode --

  Widget _buildOverview(WaterfallData data) {
    final items = _getItems(data);

    if (items.isEmpty &&
        !data.milestones.any((m) =>
            includeMilestoneForPhase(m, widget.phase, data.attachOffset))) {
      return const Center(
        child: Text(
          'No performance data recorded.\nReload the page or tap Record to capture.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      );
    }

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

    const labelWidth = 140.0;
    const rowHeight = 22.0;
    const rulerHeight = 24.0;

    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth - labelWidth - 1;
      final chartWidth = math.max(contentWidth, availableWidth);

      return Column(
        children: [
          // Time ruler
          SizedBox(
            height: rulerHeight,
            child: Row(
              children: [
                const SizedBox(width: labelWidth),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _rulerHScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: CustomPaint(
                      size: Size(chartWidth, rulerHeight),
                      painter: _TimeRulerPainter(
                        totalMs: totalMs,
                        pixelsPerMs: pixelsPerMs,
                        phaseStartMs: phaseStartMs,
                        milestones: data.milestones
                            .where((m) =>
                                includeMilestoneForPhase(m, widget.phase, data.attachOffset))
                            .toList(),
                        frameBoundaries: data.frameBoundaries
                            .where((b) => includeFrameBoundaryForPhase(
                                b, widget.phase, data.attachOffset))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          // Chart rows
          Expanded(
            child: Row(
              children: [
                // Labels
                SizedBox(
                  width: labelWidth,
                  child: ListView.builder(
                    controller: _labelsVScrollController,
                    physics: const ClampingScrollPhysics(),
                    itemCount: items.length,
                    itemExtent: rowHeight,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      if (item.isHeader) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.centerLeft,
                          color: const Color(0x204CAF50),
                          child: Text(
                            item.headerText!,
                            style: const TextStyle(
                              color: Color(0xCC4CAF50),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                      final entry = item.entry!;
                      final isSelected = _selectedEntry == entry;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEntry = entry;
                          });
                        },
                        onDoubleTap: () {
                          if (entry.hasDrillDown) {
                            _drillDownEntry(entry);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.centerLeft,
                          color: isSelected
                              ? Colors.white10
                              : Colors.transparent,
                          child: Text(
                            entry.label,
                            style: TextStyle(
                              color: colorForSubType(entry.subType),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.white12),
                // Bars
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    controller: _chartHScrollController,
                    child: SizedBox(
                      width: chartWidth,
                      child: Stack(
                        children: [
                          // Frame boundary lines (background)
                          if (data.frameBoundaries.any((b) =>
                              includeFrameBoundaryForPhase(
                                  b, widget.phase, data.attachOffset)))
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _FrameBoundaryPainter(
                                  frameBoundaries: data.frameBoundaries
                                      .where((b) => includeFrameBoundaryForPhase(
                                          b, widget.phase, data.attachOffset))
                                      .toList(),
                                  pixelsPerMs: pixelsPerMs,
                                  phaseStartMs: phaseStartMs,
                                ),
                              ),
                            ),
                          // Bar rows
                          ListView.builder(
                            controller: _barsVScrollController,
                            physics: const ClampingScrollPhysics(),
                            itemCount: items.length,
                            itemExtent: rowHeight,
                            itemBuilder: (ctx, i) {
                              final item = items[i];
                              if (item.isHeader) {
                                return Container(
                                  color: const Color(0x204CAF50),
                                );
                              }
                              return _buildOverviewRow(
                                  item.entry!, pixelsPerMs, chartWidth,
                                  phaseStartMs: phaseStartMs);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOverviewRow(WaterfallEntry entry,
      double pixelsPerMs, double chartWidth,
      {required double phaseStartMs}) {
    final startMs = entry.start.inMicroseconds / 1000.0;
    final durationMs = entry.duration.inMicroseconds / 1000.0;
    final barLeft = (startMs - phaseStartMs) * pixelsPerMs;
    final barWidth = math.max(durationMs * pixelsPerMs, 2.0);
    final color = colorForSubType(entry.subType);

    // If the tap lands on a specific spanSegment within a multi-span cluster
    // row, narrow selection to just that one span. Drilling into an aggregate
    // drawFrame row of 9655 spans is almost never what the user wants — they
    // want the frame under their cursor.
    WaterfallEntry? resolveTappedEntry(Offset localPosition) {
      if (entry.spans.isEmpty || entry.spanSegments.isEmpty) return entry;
      final tapMs = localPosition.dx / pixelsPerMs + phaseStartMs;
      for (int i = 0; i < entry.spanSegments.length; i++) {
        final seg = entry.spanSegments[i];
        if (tapMs >= seg.startMs && tapMs <= seg.endMs) {
          final span = entry.spans[i];
          final baseMs = entry.spanSegments[0].startMs;
          final narrowStart = entry.start +
              Duration(microseconds: ((seg.startMs - baseMs) * 1000).round());
          final narrowDuration =
              Duration(microseconds: ((seg.endMs - seg.startMs) * 1000).round());
          return WaterfallEntry(
            subType: entry.subType,
            label: '${_spanLabel(span)} '
                '(${i + 1}/${entry.spans.length}) — '
                '${_formatDuration(span.duration)}',
            start: narrowStart,
            end: narrowStart + narrowDuration,
            span: span,
          );
        }
      }
      return entry;
    }

    return GestureDetector(
      onTapDown: (details) {
        final tapped = resolveTappedEntry(details.localPosition) ?? entry;
        setState(() {
          _selectedEntry = tapped;
        });
      },
      onDoubleTapDown: (details) {
        final tapped = resolveTappedEntry(details.localPosition) ?? entry;
        if (tapped.hasDrillDown) {
          _drillDownEntry(tapped);
        }
      },
      // onTap/onDoubleTap are no-ops; *Down variants above do the work using
      // the tap's localPosition to hit-test spanSegments.
      onTap: () {},
      onDoubleTap: () {},
      child: CustomPaint(
        size: Size(chartWidth, 22),
        painter: _OverviewRowPainter(
          barLeft: barLeft,
          barWidth: barWidth,
          color: color,
          subEntries: entry.subEntries,
          pixelsPerMs: pixelsPerMs,
          phaseStartMs: phaseStartMs,
          hasDrillDown: entry.hasDrillDown,
          spanSegments: entry.spanSegments.isNotEmpty ? entry.spanSegments : null,
        ),
      ),
    );
  }

  // -- Flame chart mode --

  Widget _buildFlameChart() {
    // Support both single span and multi-span aggregated entries.
    // The entry's PerformanceSpan tree already contains any drained JS-thread
    // spans grafted in as children, so the regular tree walk handles both
    // Dart-thread and JS-thread drilldowns uniformly.
    final List<PerformanceSpan> allRoots;
    if (_selectedSpan != null) {
      allRoots = [_selectedSpan!];
    } else if (_selectedSpans.isNotEmpty) {
      allRoots = _selectedSpans;
    } else {
      return const Center(
        child: Text(
          'Tap any bar in the Overview to drill down\ninto the recursive call tree.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      );
    }

    // Focus mode: a cluster drill-down (e.g. 733 drawFrames merged by the
    // 50ms-gap rule) ingests 95k+ spans and makes individual frames
    // indistinguishable. When the user taps a depth-0 root in cluster mode,
    // narrow the flame chart to that single root; the back button exits focus
    // before exiting flame mode entirely.
    final isCluster = allRoots.length > 1;
    final focusedIndex =
        _focusedRoot != null ? allRoots.indexOf(_focusedRoot!) : -1;
    final isFocused = focusedIndex >= 0;
    final rootSpans = isFocused ? [allRoots[focusedIndex]] : allRoots;

    // Collect all spans, normalizing depth so root spans are at depth 0.
    // In cluster mode without focus, skip the children — 659 drawFrames with
    // ~130 children each pile 86k spans onto a handful of depth rows and
    // children from different frames smear together, making individual frames
    // indistinguishable. Strip to the roots so the user can see and tap the
    // frame-by-frame timeline, then drill into a single frame via focus.
    final allSpans = <PerformanceSpan>[];
    if (isCluster && !isFocused) {
      allSpans.addAll(rootSpans);
    } else {
      for (final rs in rootSpans) {
        _collectSpans(rs, allSpans);
      }
    }

    if (allSpans.isEmpty) {
      return const Center(
        child: Text('No child spans recorded.',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
      );
    }

    // Explain dead-end drilldowns instead of rendering a single lone bar
    // over a large empty canvas. Entries like `imageLoadComplete` wrap an
    // uninstrumented async op (`await request.obtainImage(...)`) and have
    // no inner spans by construction — there's nothing for the flame chart
    // to decompose. Only applies when we're expanded into one root's
    // subtree; cluster overview of multiple same-subType roots is still
    // informative and stays as-is.
    final expanded = !isCluster || isFocused;
    if (expanded &&
        rootSpans.length == 1 &&
        rootSpans.first.children.isEmpty) {
      final only = rootSpans.first;
      final durMs = only.duration.inMicroseconds / 1000.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFlameHeaderBar(
              title: '${only.subType}${only.name.isEmpty ? "" : " — ${only.name}"}',
              subtitle: '${durMs.toStringAsFixed(1)}ms'),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'No inner spans tracked for this entry.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'This entry wraps an uninstrumented async operation —\n'
                      'the work inside is not broken down into spans.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Use earliest root start and latest root end
    final rootStart = rootSpans
        .map((s) => s.startTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final rootEnd = rootSpans
        .map((s) => s.endTime!)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final rootDurationMs =
        rootEnd.difference(rootStart).inMicroseconds / 1000.0;
    if (rootDurationMs <= 0) {
      return const Center(
        child: Text('Span has zero duration.',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
      );
    }

    // Find min depth among root spans for normalization
    final minDepth = rootSpans.map((s) => s.depth).reduce(math.min);

    // Split spans into Dart/JS lanes. The JS profiler grafts JS-thread spans
    // (subType prefix "js") as children of Dart spans — so they share the
    // Dart depth namespace and used to render interleaved on the same rows.
    // That made a "flushUICommand / execUICommands" Dart row visually next
    // to "j / bound run" JS function frames, and users couldn't tell which
    // thread a given bar belonged to. Stack Dart above, JS below, with a
    // one-row gutter between them.
    bool isJsSpan(PerformanceSpan s) => s.subType.startsWith('js');

    final dartSpans = <PerformanceSpan>[];
    final jsSpans = <PerformanceSpan>[];
    for (final s in allSpans) {
      if (isJsSpan(s)) {
        jsSpans.add(s);
      } else {
        dartSpans.add(s);
      }
    }

    final rowForSpan = <PerformanceSpan, int>{};
    int dartMaxRow = -1;
    for (final s in dartSpans) {
      final r = s.depth - minDepth;
      rowForSpan[s] = r;
      if (r > dartMaxRow) dartMaxRow = r;
    }
    int jsMaxRow = -1;
    if (jsSpans.isNotEmpty) {
      final jsMinDepth = jsSpans.map((s) => s.depth).reduce(math.min);
      final jsLaneStart = dartMaxRow + 2; // +2 = one gutter row
      for (final s in jsSpans) {
        final r = jsLaneStart + (s.depth - jsMinDepth);
        rowForSpan[s] = r;
        if (r > jsMaxRow) jsMaxRow = r;
      }
    }
    final maxRow = math.max(dartMaxRow, jsMaxRow);
    final laneDividerRow =
        (dartSpans.isNotEmpty && jsSpans.isNotEmpty) ? dartMaxRow + 1 : -1;

    const rowHeight = 20.0;
    const rulerHeight = 24.0;
    final chartHeight = (maxRow + 1) * rowHeight;

    // Frame boundaries for dropped-frame highlighting. Use endTimes of any
    // drawFrame roots in this drill-down, expressed as local offsets from
    // rootStart. Overview has the same grid via data.frameBoundaries; the
    // drill-down was rendering without them, so 45-130ms frames looked
    // indistinguishable from in-budget ones.
    final frameBoundariesLocal = <Duration>[];
    for (final rs in rootSpans) {
      if (rs.subType == kSubTypeDrawFrame && rs.isComplete) {
        frameBoundariesLocal.add(rs.endTime!.difference(rootStart));
      }
    }
    frameBoundariesLocal.sort((a, b) => a.compareTo(b));

    return LayoutBuilder(builder: (context, constraints) {
    // Auto-fit the content to the viewport when it would otherwise compress
    // to a tiny sliver (e.g. a single 44.9ms frame rendered at 2px/ms is only
    // ~90px wide). Keep 2px/ms as the floor so large durations still scroll
    // instead of being crushed to sub-pixel bars.
    final fitPixelsPerMs = constraints.maxWidth / rootDurationMs;
    final pixelsPerMs = math.max(2.0, fitPixelsPerMs) * _flameZoom;
    final contentWidth = rootDurationMs * pixelsPerMs;
    final chartWidth = math.max(contentWidth, constraints.maxWidth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button + span info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: const Color(0xFF262626),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (isFocused) {
                    // Exit focus first; keep the cluster flame chart visible.
                    setState(() {
                      _focusedRoot = null;
                      _detailSpan = null;
                    });
                    return;
                  }
                  _savedFlameHScrollOffset = _flameBodyHScrollController.hasClients
                      ? _flameBodyHScrollController.offset : 0.0;
                  setState(() {
                    _mode = _ChartMode.overview;
                    _selectedSpan = null;
                    _selectedSpans = const [];
                    _detailSpan = null;
                    _focusedRoot = null;
                  });
                  // Restore scroll positions after frame renders
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_chartHScrollController.hasClients) {
                      _chartHScrollController.jumpTo(_savedOverviewHScrollOffset);
                    }
                    if (_barsVScrollController.hasClients) {
                      _barsVScrollController.jumpTo(_savedOverviewVScrollOffset);
                    }
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child:
                      Icon(Icons.arrow_back, size: 14, color: Colors.white70),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isFocused
                    ? 'Frame ${focusedIndex + 1} of ${allRoots.length} '
                        '— ${_spanLabel(rootSpans.first)} '
                        '— ${_formatDuration(rootSpans.first.duration)}'
                    : rootSpans.length == 1
                        ? '${_spanLabel(rootSpans.first)} — ${_formatDuration(rootSpans.first.duration)}'
                        : '${rootSpans.length} spans — ${_formatDuration(rootEnd.difference(rootStart))}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                isCluster && !isFocused
                    ? '(${allRoots.length} frames — tap one to inspect its stack)'
                    : '(Dart: ${dartSpans.length}, JS: ${jsSpans.length} — '
                        'max depth ${maxRow + 1})',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ),
        // Ruler
        SizedBox(
          height: rulerHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            controller: _flameRulerHScrollController,
            child: CustomPaint(
              size: Size(chartWidth, rulerHeight),
              painter: _TimeRulerPainter(
                totalMs: rootDurationMs,
                pixelsPerMs: pixelsPerMs,
                phaseStartMs: 0.0,
                milestones: const [],
                frameBoundaries: frameBoundariesLocal,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.white12),
        // Flame chart body
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            controller: _flameBodyHScrollController,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: GestureDetector(
                onTapDown: (details) {
                  _handleFlameChartTap(
                      details.localPosition, allSpans, rootStart,
                      pixelsPerMs, rowHeight, rowForSpan, allRoots);
                },
                child: SizedBox(
                  width: chartWidth,
                  height: chartHeight,
                  child: Stack(
                    children: [
                      if (frameBoundariesLocal.isNotEmpty)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _FrameBoundaryPainter(
                              frameBoundaries: frameBoundariesLocal,
                              pixelsPerMs: pixelsPerMs,
                              phaseStartMs: 0.0,
                            ),
                          ),
                        ),
                      CustomPaint(
                        size: Size(chartWidth, chartHeight),
                        painter: _FlameChartPainter(
                          spans: allSpans,
                          rootStart: rootStart,
                          rowForSpan: rowForSpan,
                          laneDividerRow: laneDividerRow,
                          pixelsPerMs: pixelsPerMs,
                          rowHeight: rowHeight,
                          selectedSpan: _detailSpan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    });
  }

  void _collectSpans(PerformanceSpan span, List<PerformanceSpan> result) {
    result.add(span);
    for (final child in span.children) {
      _collectSpans(child, result);
    }
  }

  PerformanceSpan? _hitTestFlameSpan(
      Offset pos,
      List<PerformanceSpan> allSpans,
      DateTime rootStart,
      double pixelsPerMs,
      double rowHeight,
      Map<PerformanceSpan, int> rowForSpan) {
    final row = (pos.dy / rowHeight).floor();
    final ms = pos.dx / pixelsPerMs;

    for (final span in allSpans) {
      final spanRow = rowForSpan[span];
      if (spanRow != row) continue;
      final spanStartMs =
          span.startTime.difference(rootStart).inMicroseconds / 1000.0;
      final spanEndMs = span.endTime != null
          ? span.endTime!.difference(rootStart).inMicroseconds / 1000.0
          : spanStartMs;
      if (ms >= spanStartMs && ms <= spanEndMs) {
        return span;
      }
    }
    return null;
  }

  void _handleFlameChartTap(
      Offset pos,
      List<PerformanceSpan> allSpans,
      DateTime rootStart,
      double pixelsPerMs,
      double rowHeight,
      Map<PerformanceSpan, int> rowForSpan,
      List<PerformanceSpan> allRoots) {
    final span = _hitTestFlameSpan(
        pos, allSpans, rootStart, pixelsPerMs, rowHeight, rowForSpan);
    // In cluster mode with no focus, a tap on one of the depth-0 roots enters
    // focus on that root instead of opening the detail panel — otherwise the
    // cluster's concatenated timeline hides per-frame boundaries.
    if (span != null &&
        allRoots.length > 1 &&
        _focusedRoot == null &&
        allRoots.contains(span)) {
      setState(() {
        _focusedRoot = span;
        _detailSpan = null;
      });
      return;
    }
    setState(() => _detailSpan = span);
  }

  // -- Detail panel --

  Widget _buildEntryDetailPanel() {
    final entry = _selectedEntry!;
    final startMs = (entry.start.inMicroseconds / 1000.0).toStringAsFixed(2);
    final durationMs = (entry.duration.inMicroseconds / 1000.0).toStringAsFixed(2);
    final color = colorForSubType(entry.subType);

    final details = StringBuffer();
    details.write('Start: ${startMs}ms  Duration: ${durationMs}ms  ');
    details.write('SubType: ${entry.subType}');
    if (entry.subEntries.isNotEmpty) {
      for (final sub in entry.subEntries) {
        final subMs = (sub.duration.inMicroseconds / 1000.0).toStringAsFixed(2);
        details.write('\n  ${sub.label}: ${subMs}ms');
      }
    }
    if (entry.span != null) {
      final span = entry.span!;
      if (span.children.isNotEmpty) {
        details.write('\nChildren: ${span.children.length}  '
            'Self: ${_formatDuration(span.selfDuration)}');
      }
      if (span.metadata != null) {
        for (final kv in span.metadata!.entries) {
          details.write('\n${kv.key}: ${kv.value}');
        }
      }
    } else if (entry.spans.isNotEmpty) {
      final totalOps = entry.spans.length;
      final totalChildren = entry.spans.fold<int>(0, (s, sp) => s + sp.children.length);
      details.write('\nSpans: $totalOps');
      if (totalChildren > 0) details.write('  Total children: $totalChildren');
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF2A2A2A),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  details.toString(),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
          if (entry.hasDrillDown)
            InkWell(
              onTap: () => _drillDownEntry(entry),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text('Drill down',
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
              ),
            ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => setState(() => _selectedEntry = null),
            child: const Icon(Icons.close, size: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel() {
    final span = _detailSpan!;
    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF2A2A2A),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: _flameSpanColor(span),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _spanLabel(span),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total: ${_formatDuration(span.duration)}  '
                  'Self: ${_formatDuration(span.selfDuration)}  '
                  'Children: ${span.children.length}  '
                  'SubType: ${span.subType}',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => setState(() => _detailSpan = null),
            child: const Icon(Icons.close, size: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }

}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

class _TimeRulerPainter extends CustomPainter {
  final double totalMs;
  final double pixelsPerMs;
  /// Phase start offset in milliseconds since load. Tick labels display
  /// `phaseStartMs + localMs` so users read absolute "time since load" even
  /// when the x-axis origin is the phase start. Flame-chart callers pass 0.0
  /// because their local coordinate system already starts at 0.
  final double phaseStartMs;
  final List<WaterfallMilestone> milestones;
  final List<Duration> frameBoundaries;

  _TimeRulerPainter({
    required this.totalMs,
    required this.pixelsPerMs,
    required this.phaseStartMs,
    required this.milestones,
    this.frameBoundaries = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF444444)
      ..strokeWidth = 1;

    // Determine tick interval
    final targetTickPx = 80.0;
    final rawInterval = targetTickPx / pixelsPerMs;
    final interval = _niceInterval(rawInterval);

    // Draw ticks — tick positions are LOCAL to the phase (0..totalMs), but
    // the displayed label shows the ABSOLUTE time since load (phaseStartMs +
    // localMs) so users can still read "time since page load" for any tick.
    double ms = 0;
    while (ms <= totalMs) {
      final x = ms * pixelsPerMs;
      canvas.drawLine(Offset(x, size.height - 6), Offset(x, size.height), paint);

      final tp = TextPainter(
        text: TextSpan(
          text: _formatMs(phaseStartMs + ms),
          style: const TextStyle(color: Color(0xFF888888), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 2, 2));

      ms += interval;
    }

    // Draw frame boundary indicators with dropped-frame highlighting
    if (frameBoundaries.isNotEmpty) {
      const droppedThresholdMs = 16.67; // 60fps
      final normalPaint = Paint()
        ..color = const Color(0xFF555555)
        ..strokeWidth = 0.5;
      final droppedPaint = Paint()
        ..color = const Color(0xFFEF5350)
        ..strokeWidth = 0.5;
      final droppedBgPaint = Paint()
        ..color = const Color(0x15EF5350);
      for (int i = 0; i < frameBoundaries.length; i++) {
        final xMs = frameBoundaries[i].inMicroseconds / 1000.0;
        final x = (xMs - phaseStartMs) * pixelsPerMs;
        final prevMs = i > 0 ? frameBoundaries[i - 1].inMicroseconds / 1000.0 : phaseStartMs;
        final gapMs = xMs - prevMs;
        final isDropped = i > 0 && gapMs > droppedThresholdMs;
        // Shade dropped-frame region
        if (isDropped) {
          final prevX = (prevMs - phaseStartMs) * pixelsPerMs;
          canvas.drawRect(Rect.fromLTRB(prevX, 0, x, size.height), droppedBgPaint);
        }
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), isDropped ? droppedPaint : normalPaint);
      }
    }

    // Draw milestone lines
    for (final m in milestones) {
      final x = (m.offset.inMicroseconds / 1000.0 - phaseStartMs) * pixelsPerMs;
      final mPaint = Paint()
        ..color = m.color.withOpacity(0.7)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Dashed line
      double y = 0;
      while (y < size.height) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 3), mPaint);
        y += 6;
      }

      final tp = TextPainter(
        text: TextSpan(
          text: m.label,
          style: TextStyle(
              color: m.color, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 2, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(_TimeRulerPainter old) =>
      old.totalMs != totalMs ||
      old.pixelsPerMs != pixelsPerMs ||
      old.phaseStartMs != phaseStartMs ||
      old.milestones != milestones ||
      old.frameBoundaries.length != frameBoundaries.length;

  double _niceInterval(double raw) {
    if (raw <= 1) return 1;
    if (raw <= 2) return 2;
    if (raw <= 5) return 5;
    if (raw <= 10) return 10;
    if (raw <= 20) return 20;
    if (raw <= 50) return 50;
    if (raw <= 100) return 100;
    if (raw <= 200) return 200;
    if (raw <= 500) return 500;
    return 1000;
  }

  String _formatMs(double ms) {
    if (ms >= 1000) return '${(ms / 1000).toStringAsFixed(1)}s';
    if (ms >= 1) return '${ms.toStringAsFixed(0)}ms';
    return '${(ms * 1000).toStringAsFixed(0)}µs';
  }
}

class _OverviewRowPainter extends CustomPainter {
  final double barLeft;
  final double barWidth;
  final Color color;
  final List<WaterfallSubEntry> subEntries;
  final double pixelsPerMs;
  /// Phase start offset in milliseconds since load. Bar x-positions are
  /// computed as `(startMs - phaseStartMs) * pixelsPerMs` so the chart's
  /// origin is the phase start. Flame-chart callers pass 0.0 because their
  /// local coordinate system already starts at 0.
  final double phaseStartMs;
  final bool hasDrillDown;
  final List<_SpanSegment>? spanSegments;

  _OverviewRowPainter({
    required this.barLeft,
    required this.barWidth,
    required this.color,
    required this.subEntries,
    required this.pixelsPerMs,
    required this.phaseStartMs,
    required this.hasDrillDown,
    this.spanSegments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barTop = 3.0;
    final barHeight = size.height - 6.0;

    if (spanSegments != null && spanSegments!.isNotEmpty) {
      // Aggregated spans — draw translucent background range, then solid segments
      final bgPaint = Paint()..color = color.withValues(alpha: 0.15);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barLeft, barTop, barWidth, barHeight),
          const Radius.circular(2),
        ),
        bgPaint,
      );
      final segPaint = Paint()..color = color;
      for (final seg in spanSegments!) {
        final segLeft = (seg.startMs - phaseStartMs) * pixelsPerMs;
        final segWidth = math.max((seg.endMs - seg.startMs) * pixelsPerMs, 1.5);
        canvas.drawRect(
          Rect.fromLTWH(segLeft, barTop, segWidth, barHeight),
          segPaint,
        );
      }
    } else if (subEntries.isEmpty) {
      // Simple solid bar (single span or lifecycle)
      final paint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barLeft, barTop, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    } else {
      // Background bar
      final bgPaint = Paint()..color = color.withOpacity(0.2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barLeft, barTop, barWidth, barHeight),
          const Radius.circular(2),
        ),
        bgPaint,
      );
      // Sub-entry segments
      for (final sub in subEntries) {
        final subStartMs = sub.start.inMicroseconds / 1000.0;
        final subDurationMs = sub.duration.inMicroseconds / 1000.0;
        final subLeft = (subStartMs - phaseStartMs) * pixelsPerMs;
        final subWidth = math.max(subDurationMs * pixelsPerMs, 1.0);
        final subPaint = Paint()..color = sub.color;
        canvas.drawRect(
          Rect.fromLTWH(subLeft, barTop, subWidth, barHeight),
          subPaint,
        );
      }
    }

    // Drill-down indicator
    if (hasDrillDown) {
      final arrowPaint = Paint()
        ..color = Colors.white54
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      final cx = barLeft + barWidth + 6;
      final cy = size.height / 2;
      canvas.drawLine(Offset(cx - 2, cy - 3), Offset(cx + 2, cy), arrowPaint);
      canvas.drawLine(Offset(cx + 2, cy), Offset(cx - 2, cy + 3), arrowPaint);
    }
  }

  @override
  bool shouldRepaint(_OverviewRowPainter old) =>
      old.barLeft != barLeft ||
      old.barWidth != barWidth ||
      old.color != color ||
      old.pixelsPerMs != pixelsPerMs ||
      old.phaseStartMs != phaseStartMs ||
      old.hasDrillDown != hasDrillDown ||
      old.subEntries.length != subEntries.length;
}

class _FlameChartPainter extends CustomPainter {
  final List<PerformanceSpan> spans;
  final DateTime rootStart;
  final Map<PerformanceSpan, int> rowForSpan;
  final int laneDividerRow;
  final double pixelsPerMs;
  final double rowHeight;
  final PerformanceSpan? selectedSpan;

  _FlameChartPainter({
    required this.spans,
    required this.rootStart,
    required this.rowForSpan,
    required this.laneDividerRow,
    required this.pixelsPerMs,
    required this.rowHeight,
    this.selectedSpan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Lane divider between Dart (top) and JS (bottom) lanes. The gutter row
    // (laneDividerRow) is deliberately kept empty of spans; fill it with a
    // visible banner so users notice the JS lane exists below. A subtle 1px
    // line was too easy to miss — users reported "JS stacks are all missing"
    // when in fact the JS lane was simply below the fold.
    if (laneDividerRow >= 0) {
      final y = laneDividerRow * rowHeight;
      final bandPaint = Paint()..color = const Color(0xFF3B2A12);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, rowHeight), bandPaint);
      final borderPaint = Paint()
        ..color = const Color(0xFFE0A94A)
        ..strokeWidth = 1.5;
      canvas.drawLine(
          Offset(0, y), Offset(size.width, y), borderPaint);
      canvas.drawLine(Offset(0, y + rowHeight),
          Offset(size.width, y + rowHeight), borderPaint);
      final labelTp = TextPainter(
        text: const TextSpan(
          text: '▼ JS THREAD',
          style: TextStyle(
            color: Color(0xFFE0A94A),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(canvas, Offset(6, y + (rowHeight - labelTp.height) / 2));
    }

    for (final span in spans) {
      if (!span.isComplete) continue;

      final row = rowForSpan[span];
      if (row == null) continue;
      final startMs =
          span.startTime.difference(rootStart).inMicroseconds / 1000.0;
      final durationMs = span.duration.inMicroseconds / 1000.0;
      final x = startMs * pixelsPerMs;
      final w = math.max(durationMs * pixelsPerMs, 1.0);
      final y = row * rowHeight;

      final color = _flameSpanColor(span);
      final isSelected = identical(span, selectedSpan);

      // Self-time as solid, child-time as lighter

      // Draw child-time background (lighter)
      final bgPaint = Paint()..color = color.withOpacity(0.35);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y + 1, w, rowHeight - 2),
          const Radius.circular(2),
        ),
        bgPaint,
      );

      // Draw self-time segments as solid overlays
      // Self-time accumulates at gaps between children
      if (span.children.isEmpty) {
        // All self-time
        final solidPaint = Paint()..color = color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y + 1, w, rowHeight - 2),
            const Radius.circular(2),
          ),
          solidPaint,
        );
      } else {
        // Fill gaps between children as solid
        final solidPaint = Paint()..color = color;
        double cursor = startMs;
        final sortedChildren = List<PerformanceSpan>.from(span.children)
          ..sort(
              (a, b) => a.startTime.compareTo(b.startTime));
        for (final child in sortedChildren) {
          if (!child.isComplete) continue;
          final childStartMs =
              child.startTime.difference(rootStart).inMicroseconds / 1000.0;
          if (childStartMs > cursor) {
            final gapX = cursor * pixelsPerMs;
            final gapW = (childStartMs - cursor) * pixelsPerMs;
            canvas.drawRect(
              Rect.fromLTWH(gapX, y + 1, gapW, rowHeight - 2),
              solidPaint,
            );
          }
          final childEndMs =
              child.endTime!.difference(rootStart).inMicroseconds / 1000.0;
          cursor = math.max(cursor, childEndMs);
        }
        // Trailing self-time
        final endMs = startMs + durationMs;
        if (cursor < endMs) {
          final gapX = cursor * pixelsPerMs;
          final gapW = (endMs - cursor) * pixelsPerMs;
          canvas.drawRect(
            Rect.fromLTWH(gapX, y + 1, gapW, rowHeight - 2),
            solidPaint,
          );
        }
      }

      // Selection highlight
      if (isSelected) {
        final selPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y + 1, w, rowHeight - 2),
            const Radius.circular(2),
          ),
          selPaint,
        );
      }

      // Label (only if bar is wide enough)
      if (w > 30) {
        final label = _spanLabel(span);
        final tp = TextPainter(
          text: TextSpan(
            text: w > 80
                ? '$label ${_formatDuration(span.duration)}'
                : label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
              fontSize: 9,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
        )..layout(maxWidth: w - 4);
        tp.paint(canvas, Offset(x + 2, y + (rowHeight - tp.height) / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_FlameChartPainter old) =>
      old.spans.length != spans.length ||
      old.rootStart != rootStart ||
      old.laneDividerRow != laneDividerRow ||
      old.pixelsPerMs != pixelsPerMs ||
      old.rowHeight != rowHeight ||
      !identical(old.selectedSpan, selectedSpan) ||
      !identical(old.rowForSpan, rowForSpan);
}

// ---------------------------------------------------------------------------
class _FrameBoundaryPainter extends CustomPainter {
  final List<Duration> frameBoundaries;
  final double pixelsPerMs;
  /// Phase start offset in milliseconds since load. Frame boundary lines are
  /// positioned relative to the phase origin (x = (frameMs - phaseStartMs) *
  /// pixelsPerMs). Flame-chart callers pass 0.0 for local coordinates.
  final double phaseStartMs;

  _FrameBoundaryPainter({
    required this.frameBoundaries,
    required this.pixelsPerMs,
    required this.phaseStartMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const droppedThresholdMs = 16.67;
    final normalPaint = Paint()
      ..color = const Color(0xFF444444)
      ..strokeWidth = 0.5;
    final droppedPaint = Paint()
      ..color = const Color(0xFFEF5350)
      ..strokeWidth = 0.5;
    final droppedBgPaint = Paint()
      ..color = const Color(0x10EF5350);
    for (int i = 0; i < frameBoundaries.length; i++) {
      final xMs = frameBoundaries[i].inMicroseconds / 1000.0;
      final x = (xMs - phaseStartMs) * pixelsPerMs;
      final prevMs = i > 0 ? frameBoundaries[i - 1].inMicroseconds / 1000.0 : phaseStartMs;
      final gapMs = xMs - prevMs;
      final isDropped = i > 0 && gapMs > droppedThresholdMs;
      if (isDropped) {
        final prevX = (prevMs - phaseStartMs) * pixelsPerMs;
        canvas.drawRect(Rect.fromLTRB(prevX, 0, x, size.height), droppedBgPaint);
      }
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), isDropped ? droppedPaint : normalPaint);
    }
  }

  @override
  bool shouldRepaint(_FrameBoundaryPainter old) =>
      old.frameBoundaries.length != frameBoundaries.length ||
      old.pixelsPerMs != pixelsPerMs ||
      old.phaseStartMs != phaseStartMs;
}

// ---------------------------------------------------------------------------
// Overview item wrapper — either a section header or a regular entry
// ---------------------------------------------------------------------------

class _OverviewItem {
  final bool isHeader;
  final String? headerText;
  final WaterfallEntry? entry;

  _OverviewItem.header(this.headerText)
      : isHeader = true,
        entry = null;

  _OverviewItem.entry(this.entry)
      : isHeader = false,
        headerText = null;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatDuration(Duration d) {
  final us = d.inMicroseconds;
  if (us >= 1000000) return '${(us / 1000000).toStringAsFixed(1)}s';
  if (us >= 1000) return '${(us / 1000).toStringAsFixed(1)}ms';
  return '$us µs';
}

class _SpanStats {
  final int subtreeCount;
  final int maxDepth;
  final int violations;
  final int openChildren;
  const _SpanStats(
      this.subtreeCount, this.maxDepth, this.violations, this.openChildren);
}
