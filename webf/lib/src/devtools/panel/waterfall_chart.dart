/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

/// Waterfall performance chart for the WebF inspector panel.
///
/// Provides two visualization modes:
/// - **Overview**: All pipeline stages on a shared time axis (lifecycle, network,
///   CSS parse, style, layout, paint) with milestone markers (FP, FCP, LCP).
/// - **Flame chart**: Drill-down into recursive stages (style recalc, layout, paint)
///   showing the full call tree with self-time vs child-time coloring.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/launcher/loading_state.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

enum WaterfallCategory {
  lifecycle,
  network,
  cssParse,
  style,
  layout,
  paint,
}

class WaterfallEntry {
  final WaterfallCategory category;
  final String label;
  Duration start;
  Duration end;
  final List<WaterfallSubEntry> subEntries;
  final PerformanceSpan? span; // For drill-down into flame chart

  WaterfallEntry({
    required this.category,
    required this.label,
    required this.start,
    required this.end,
    this.subEntries = const [],
    this.span,
  });

  Duration get duration => end - start;
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

  WaterfallMilestone({
    required this.label,
    required this.offset,
    required this.color,
  });
}

class WaterfallData {
  final List<WaterfallEntry> entries;
  final List<WaterfallMilestone> milestones;
  final Duration totalDuration;

  WaterfallData({
    required this.entries,
    required this.milestones,
    required this.totalDuration,
  });
}

// ---------------------------------------------------------------------------
// Data builder — transforms LoadingState + PerformanceTracker → WaterfallData
// ---------------------------------------------------------------------------

WaterfallData buildWaterfallData(
    LoadingState loadingState, PerformanceTracker tracker) {
  try {
    return _buildWaterfallDataImpl(loadingState, tracker);
  } catch (e) {
    // Error building waterfall data — return empty gracefully
    return WaterfallData(
        entries: [], milestones: [], totalDuration: Duration.zero);
  }
}

WaterfallData _buildWaterfallDataImpl(
    LoadingState loadingState, PerformanceTracker tracker) {
  final entries = <WaterfallEntry>[];
  final milestones = <WaterfallMilestone>[];
  final sessionStart = loadingState.startTime ?? tracker.sessionStart;

  if (sessionStart == null) {
    return WaterfallData(
        entries: [], milestones: [], totalDuration: Duration.zero);
  }

  Duration offset(DateTime t) => t.difference(sessionStart);

  // --- Lifecycle phases ---
  // Snapshot to avoid ConcurrentModificationException
  final phases = List.of(loadingState.phases);
  if (phases.isNotEmpty) {
    final lifecyclePhaseNames = [
      LoadingState.phaseInit,
      LoadingState.phaseLoadStart,
      LoadingState.phaseEvaluateStart,
      LoadingState.phaseEvaluateComplete,
      LoadingState.phaseDOMContentLoaded,
      LoadingState.phaseWindowLoad,
    ];
    final relevantPhases =
        phases.where((p) => lifecyclePhaseNames.contains(p.name)).toList();
    if (relevantPhases.length >= 2) {
      final subEntries = <WaterfallSubEntry>[];
      for (int i = 0; i < relevantPhases.length - 1; i++) {
        subEntries.add(WaterfallSubEntry(
          label: relevantPhases[i].name,
          color: _lifecycleColor(relevantPhases[i].name),
          start: offset(relevantPhases[i].timestamp),
          end: offset(relevantPhases[i + 1].timestamp),
        ));
      }
      entries.add(WaterfallEntry(
        category: WaterfallCategory.lifecycle,
        label: 'Lifecycle',
        start: offset(relevantPhases.first.timestamp),
        end: offset(relevantPhases.last.timestamp),
        subEntries: subEntries,
      ));
    }
  }

  // --- Network requests ---
  final networkReqs = List.of(loadingState.networkRequests);
  for (final req in networkReqs) {
    if (!req.isComplete) continue;
    final subEntries = <WaterfallSubEntry>[];
    final reqStart = offset(req.startTime);
    final reqEnd = offset(req.endTime!);

    if (req.dnsDuration != null && req.dnsStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'DNS',
        color: const Color(0xFF4CAF50),
        start: offset(req.dnsStart!),
        end: offset(req.dnsEnd!),
      ));
    }
    if (req.connectDuration != null && req.connectStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'Connect',
        color: const Color(0xFFFF9800),
        start: offset(req.connectStart!),
        end: offset(req.connectEnd!),
      ));
    }
    if (req.tlsDuration != null && req.tlsStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'TLS',
        color: const Color(0xFF9C27B0),
        start: offset(req.tlsStart!),
        end: offset(req.tlsEnd!),
      ));
    }
    if (req.waitingDuration != null && req.requestStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'Waiting',
        color: const Color(0xFF2196F3),
        start: offset(req.requestStart!),
        end: offset(req.responseStart!),
      ));
    }
    if (req.downloadDuration != null && req.responseStart != null) {
      subEntries.add(WaterfallSubEntry(
        label: 'Download',
        color: const Color(0xFF607D8B),
        start: offset(req.responseStart!),
        end: offset(req.responseEnd!),
      ));
    }

    // Extract meaningful part of URL for label
    var urlLabel = req.url;
    try {
      final uri = Uri.parse(urlLabel);
      urlLabel = uri.path;
      if (urlLabel.isEmpty || urlLabel == '/') urlLabel = uri.host;
      // Strip query params for display but keep short ones
      if (uri.query.isNotEmpty && uri.query.length <= 15) {
        urlLabel = '$urlLabel?${uri.query}';
      }
    } catch (_) {}
    if (urlLabel.length > 30) {
      urlLabel = '...${urlLabel.substring(urlLabel.length - 27)}';
    }

    entries.add(WaterfallEntry(
      category: WaterfallCategory.network,
      label: urlLabel,
      start: reqStart,
      end: reqEnd,
      subEntries: subEntries,
    ));
  }

  // --- Performance spans from tracker ---
  // Snapshot to avoid ConcurrentModificationException (tracker may still be recording)
  final rootSpanSnapshot = List.of(tracker.rootSpans);
  for (final span in rootSpanSnapshot) {
    if (!span.isComplete) continue;
    final cat = _spanCategory(span.category);
    entries.add(WaterfallEntry(
      category: cat,
      label: _spanLabel(span),
      start: offset(span.startTime),
      end: offset(span.endTime!),
      span: span,
    ));
  }

  // --- Milestones ---
  for (final phase in phases) {
    if (phase.name == LoadingState.phaseFirstPaint) {
      milestones.add(WaterfallMilestone(
        label: 'FP',
        offset: offset(phase.timestamp),
        color: const Color(0xFF4CAF50),
      ));
    } else if (phase.name == LoadingState.phaseFirstContentfulPaint) {
      milestones.add(WaterfallMilestone(
        label: 'FCP',
        offset: offset(phase.timestamp),
        color: const Color(0xFF2196F3),
      ));
    } else if (phase.name == LoadingState.phaseLargestContentfulPaint ||
        phase.name == LoadingState.phaseFinalLargestContentfulPaint) {
      milestones.add(WaterfallMilestone(
        label: 'LCP',
        offset: offset(phase.timestamp),
        color: const Color(0xFFF44336),
      ));
    }
  }

  // Normalize: shift all entries so the timeline starts at the earliest event
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

  // Calculate total duration
  var maxEnd = Duration.zero;
  for (final e in entries) {
    if (e.end > maxEnd) maxEnd = e.end;
  }
  for (final m in milestones) {
    if (m.offset > maxEnd) maxEnd = m.offset;
  }

  // Sort entries by start time within their categories
  // Sort all entries by start time on a single shared timeline
  entries.sort((a, b) => a.start.compareTo(b.start));

  return WaterfallData(
    entries: entries,
    milestones: milestones,
    totalDuration: maxEnd,
  );
}

WaterfallCategory _spanCategory(String category) {
  switch (category) {
    case 'cssParse':
      return WaterfallCategory.cssParse;
    case 'styleFlush':
    case 'styleRecalc':
    case 'styleApply':
      return WaterfallCategory.style;
    case 'layout':
      return WaterfallCategory.layout;
    case 'paint':
      return WaterfallCategory.paint;
    default:
      return WaterfallCategory.lifecycle;
  }
}

String _spanLabel(PerformanceSpan span) {
  final meta = span.metadata;
  if (meta != null) {
    if (meta.containsKey('url')) return 'parse ${meta['url']}';
    if (meta.containsKey('tagName')) return '${span.name}(${meta['tagName']})';
  }
  return span.name;
}

Color _lifecycleColor(String name) {
  switch (name) {
    case 'init':
      return const Color(0xFF1565C0);
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
    default:
      return const Color(0xFF546E7A);
  }
}

// ---------------------------------------------------------------------------
// Color scheme for categories
// ---------------------------------------------------------------------------

Color _categoryColor(WaterfallCategory cat) {
  switch (cat) {
    case WaterfallCategory.lifecycle:
      return const Color(0xFF42A5F5);
    case WaterfallCategory.network:
      return const Color(0xFF66BB6A);
    case WaterfallCategory.cssParse:
      return const Color(0xFF5C6BC0);
    case WaterfallCategory.style:
      return const Color(0xFFAB47BC);
    case WaterfallCategory.layout:
      return const Color(0xFFFFA726);
    case WaterfallCategory.paint:
      return const Color(0xFFEC407A);
  }
}

Color _flameSpanColor(PerformanceSpan span) {
  switch (span.category) {
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
    default:
      return const Color(0xFF78909C);
  }
}

String _categoryLabel(WaterfallCategory cat) {
  switch (cat) {
    case WaterfallCategory.lifecycle:
      return 'Lifecycle';
    case WaterfallCategory.network:
      return 'Network';
    case WaterfallCategory.cssParse:
      return 'CSS Parse';
    case WaterfallCategory.style:
      return 'Style';
    case WaterfallCategory.layout:
      return 'Layout';
    case WaterfallCategory.paint:
      return 'Paint';
  }
}

// ---------------------------------------------------------------------------
// WaterfallChart widget
// ---------------------------------------------------------------------------

enum _ChartMode { overview, flame }

class WaterfallChart extends StatefulWidget {
  final LoadingState loadingState;
  final PerformanceTracker tracker;

  const WaterfallChart({
    super.key,
    required this.loadingState,
    required this.tracker,
  });

  @override
  State<WaterfallChart> createState() => _WaterfallChartState();
}

class _WaterfallChartState extends State<WaterfallChart> {
  _ChartMode _mode = _ChartMode.overview;
  PerformanceSpan? _selectedSpan;
  double _zoom = 1.0;

  // Separate scroll controllers for each scroll view — Flutter requires
  // one controller per scroll position.
  final ScrollController _rulerHScrollController = ScrollController();
  final ScrollController _chartHScrollController = ScrollController();
  final ScrollController _labelsVScrollController = ScrollController();
  final ScrollController _barsVScrollController = ScrollController();
  // Flame chart mode controllers
  final ScrollController _flameRulerHScrollController = ScrollController();
  final ScrollController _flameBodyHScrollController = ScrollController();

  final Set<WaterfallCategory> _enabledCategories =
      Set.from(WaterfallCategory.values);

  // Tap detail
  PerformanceSpan? _detailSpan;
  WaterfallEntry? _selectedEntry;

  bool _syncingScroll = false;

  @override
  void initState() {
    super.initState();
    // Sync horizontal scroll: ruler ↔ chart
    _rulerHScrollController.addListener(() => _syncScroll(
        _rulerHScrollController, _chartHScrollController));
    _chartHScrollController.addListener(() => _syncScroll(
        _chartHScrollController, _rulerHScrollController));
    // Sync vertical scroll: labels ↔ bars
    _labelsVScrollController.addListener(() => _syncScroll(
        _labelsVScrollController, _barsVScrollController));
    _barsVScrollController.addListener(() => _syncScroll(
        _barsVScrollController, _labelsVScrollController));
    // Sync flame chart horizontal scroll: ruler ↔ body
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

  @override
  Widget build(BuildContext context) {
    final data =
        buildWaterfallData(widget.loadingState, widget.tracker);

    return Column(
      children: [
        _buildToolbar(data),
        const Divider(height: 1, color: Colors.white24),
        Expanded(
          child: _mode == _ChartMode.overview
              ? _buildOverview(data)
              : _buildFlameChart(),
        ),
        if (_selectedEntry != null && _mode == _ChartMode.overview)
          _buildEntryDetailPanel(),
        if (_detailSpan != null && _mode == _ChartMode.flame)
          _buildDetailPanel(),
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
        child: Row(
          children: [
            // Mode toggle
            _modeChip('Overview', _ChartMode.overview),
            const SizedBox(width: 4),
            _modeChip('Flame', _ChartMode.flame),
            const SizedBox(width: 12),
            // Zoom
            InkWell(
              onTap: () =>
                  setState(() => _zoom = (_zoom / 1.5).clamp(0.25, 8)),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.remove, size: 16, color: Colors.white70),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${(_zoom * 100).round()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
            InkWell(
              onTap: () =>
                  setState(() => _zoom = (_zoom * 1.5).clamp(0.25, 8)),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.add, size: 16, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 12),
            // Category filters (overview mode only)
            if (_mode == _ChartMode.overview) ...[
              for (final cat in WaterfallCategory.values) ...[
                _categoryFilterChip(cat),
                const SizedBox(width: 2),
              ],
            ],
            const SizedBox(width: 12),
            // Record button
            _buildRecordButton(),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(String label, _ChartMode mode) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = mode;
          _detailSpan = null;
          if (mode == _ChartMode.overview) _selectedSpan = null;
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

  Widget _categoryFilterChip(WaterfallCategory cat) {
    final enabled = _enabledCategories.contains(cat);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (enabled) {
            _enabledCategories.remove(cat);
          } else {
            _enabledCategories.add(cat);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: enabled
              ? _categoryColor(cat).withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: enabled
                ? _categoryColor(cat).withOpacity(0.6)
                : Colors.white12,
          ),
        ),
        child: Text(
          _categoryLabel(cat),
          style: TextStyle(
            color: enabled ? _categoryColor(cat) : Colors.white38,
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

  // -- Overview mode --

  Widget _buildOverview(WaterfallData data) {
    final filtered = data.entries
        .where((e) => _enabledCategories.contains(e.category))
        .toList();

    if (filtered.isEmpty && data.milestones.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No performance data recorded.\nReload the page or tap Record to capture.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final totalMs = data.totalDuration.inMicroseconds / 1000.0;
    final pixelsPerMs = _zoom * 2.0; // base: 2px per ms
    final chartWidth = math.max(totalMs * pixelsPerMs, 200.0);

    const labelWidth = 140.0;
    const rowHeight = 22.0;
    const rulerHeight = 24.0;

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
                  child: CustomPaint(
                    size: Size(chartWidth, rulerHeight),
                    painter: _TimeRulerPainter(
                      totalMs: totalMs,
                      pixelsPerMs: pixelsPerMs,
                      milestones: data.milestones,
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
                  itemCount: filtered.length,
                  itemExtent: rowHeight,
                  itemBuilder: (ctx, i) {
                    final entry = filtered[i];
                    final isSelected = _selectedEntry == entry;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEntry = entry;
                        });
                      },
                      onDoubleTap: () {
                        if (entry.span != null) {
                          setState(() {
                            _selectedSpan = entry.span;
                            _mode = _ChartMode.flame;
                            _detailSpan = null;
                            _selectedEntry = null;
                          });
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
                            color: _categoryColor(entry.category),
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
                  controller: _chartHScrollController,
                  child: SizedBox(
                    width: chartWidth,
                    child: ListView.builder(
                      controller: _barsVScrollController,
                      itemCount: filtered.length,
                      itemExtent: rowHeight,
                      itemBuilder: (ctx, i) {
                        return _buildOverviewRow(
                            filtered[i], totalMs, pixelsPerMs, chartWidth);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewRow(WaterfallEntry entry, double totalMs,
      double pixelsPerMs, double chartWidth) {
    final startMs = entry.start.inMicroseconds / 1000.0;
    final durationMs = entry.duration.inMicroseconds / 1000.0;
    final barLeft = startMs * pixelsPerMs;
    final barWidth = math.max(durationMs * pixelsPerMs, 2.0);
    final color = _categoryColor(entry.category);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEntry = entry;
        });
      },
      onDoubleTap: () {
        if (entry.span != null) {
          setState(() {
            _selectedSpan = entry.span;
            _mode = _ChartMode.flame;
            _detailSpan = null;
            _selectedEntry = null;
          });
        }
      },
      child: CustomPaint(
        size: Size(chartWidth, 22),
        painter: _OverviewRowPainter(
          barLeft: barLeft,
          barWidth: barWidth,
          color: color,
          subEntries: entry.subEntries,
          pixelsPerMs: pixelsPerMs,
          hasDrillDown: entry.span != null,
        ),
      ),
    );
  }

  // -- Flame chart mode --

  Widget _buildFlameChart() {
    final span = _selectedSpan;
    if (span == null) {
      return const Center(
        child: Text(
          'Tap a Style, Layout, or Paint bar in the Overview\nto drill down into the recursive call tree.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      );
    }

    // Collect all spans in the tree with flattened depth
    final allSpans = <PerformanceSpan>[];
    _collectSpans(span, allSpans);

    if (allSpans.isEmpty) {
      return const Center(
        child: Text('No child spans recorded.',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
      );
    }

    final rootStart = span.startTime;
    final rootDurationMs = span.duration.inMicroseconds / 1000.0;
    if (rootDurationMs <= 0) {
      return const Center(
        child: Text('Span has zero duration.',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
      );
    }

    final maxDepth = span.maxDepth - span.depth;
    final pixelsPerMs = _zoom * 2.0;
    final chartWidth = math.max(rootDurationMs * pixelsPerMs, 200.0);
    const rowHeight = 20.0;
    const rulerHeight = 24.0;
    final chartHeight = (maxDepth + 1) * rowHeight;

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
                  setState(() {
                    _mode = _ChartMode.overview;
                    _selectedSpan = null;
                    _detailSpan = null;
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
                '${_spanLabel(span)} — ${_formatDuration(span.duration)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                '(${span.subtreeCount} spans, max depth ${maxDepth + 1})',
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
            controller: _flameRulerHScrollController,
            child: CustomPaint(
              size: Size(chartWidth, rulerHeight),
              painter: _TimeRulerPainter(
                totalMs: rootDurationMs,
                pixelsPerMs: pixelsPerMs,
                milestones: const [],
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.white12),
        // Flame chart body
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _flameBodyHScrollController,
            child: SingleChildScrollView(
              child: GestureDetector(
                onTapDown: (details) {
                  _handleFlameChartTap(
                      details.localPosition, allSpans, rootStart,
                      pixelsPerMs, rowHeight, span.depth);
                },
                child: CustomPaint(
                  size: Size(chartWidth, chartHeight),
                  painter: _FlameChartPainter(
                    spans: allSpans,
                    rootStart: rootStart,
                    rootDepth: span.depth,
                    pixelsPerMs: pixelsPerMs,
                    rowHeight: rowHeight,
                    selectedSpan: _detailSpan,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
      int rootDepth) {
    final row = (pos.dy / rowHeight).floor();
    final ms = pos.dx / pixelsPerMs;

    for (final span in allSpans) {
      final depth = span.depth - rootDepth;
      if (depth != row) continue;
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
      int rootDepth) {
    final span = _hitTestFlameSpan(
        pos, allSpans, rootStart, pixelsPerMs, rowHeight, rootDepth);
    setState(() => _detailSpan = span);
  }

  // -- Detail panel --

  Widget _buildEntryDetailPanel() {
    final entry = _selectedEntry!;
    final startMs = (entry.start.inMicroseconds / 1000.0).toStringAsFixed(2);
    final durationMs = (entry.duration.inMicroseconds / 1000.0).toStringAsFixed(2);
    final color = _categoryColor(entry.category);

    final details = StringBuffer();
    details.write('Start: ${startMs}ms  Duration: ${durationMs}ms  ');
    details.write('Category: ${entry.category.name}');
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
          if (entry.span != null)
            InkWell(
              onTap: () {
                setState(() {
                  _selectedSpan = entry.span;
                  _mode = _ChartMode.flame;
                  _detailSpan = null;
                  _selectedEntry = null;
                });
              },
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
                  'Category: ${span.category}',
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
  final List<WaterfallMilestone> milestones;

  _TimeRulerPainter({
    required this.totalMs,
    required this.pixelsPerMs,
    required this.milestones,
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

    // Draw ticks
    double ms = 0;
    while (ms <= totalMs) {
      final x = ms * pixelsPerMs;
      canvas.drawLine(Offset(x, size.height - 6), Offset(x, size.height), paint);

      final tp = TextPainter(
        text: TextSpan(
          text: _formatMs(ms),
          style: const TextStyle(color: Color(0xFF888888), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 2, 2));

      ms += interval;
    }

    // Draw milestone lines
    for (final m in milestones) {
      final x = m.offset.inMicroseconds / 1000.0 * pixelsPerMs;
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
      old.milestones != milestones;

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
  final bool hasDrillDown;

  _OverviewRowPainter({
    required this.barLeft,
    required this.barWidth,
    required this.color,
    required this.subEntries,
    required this.pixelsPerMs,
    required this.hasDrillDown,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barTop = 3.0;
    final barHeight = size.height - 6.0;

    if (subEntries.isEmpty) {
      // Simple solid bar
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
        final subLeft = subStartMs * pixelsPerMs;
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
  bool shouldRepaint(_OverviewRowPainter old) => true;
}

class _FlameChartPainter extends CustomPainter {
  final List<PerformanceSpan> spans;
  final DateTime rootStart;
  final int rootDepth;
  final double pixelsPerMs;
  final double rowHeight;
  final PerformanceSpan? selectedSpan;

  _FlameChartPainter({
    required this.spans,
    required this.rootStart,
    required this.rootDepth,
    required this.pixelsPerMs,
    required this.rowHeight,
    this.selectedSpan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final span in spans) {
      if (!span.isComplete) continue;

      final depth = span.depth - rootDepth;
      final startMs =
          span.startTime.difference(rootStart).inMicroseconds / 1000.0;
      final durationMs = span.duration.inMicroseconds / 1000.0;
      final x = startMs * pixelsPerMs;
      final w = math.max(durationMs * pixelsPerMs, 1.0);
      final y = depth * rowHeight;

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
  bool shouldRepaint(_FlameChartPainter old) => true;
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
