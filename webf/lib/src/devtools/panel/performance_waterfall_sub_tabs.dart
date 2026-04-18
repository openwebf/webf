/*
 * Copyright (C) 2026-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/src/launcher/loading_state.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/waterfall_chart.dart';

/// Two sub-tabs that split the waterfall into Init → Attach and Attach → Paint.
///
/// When [attachOffset] is null, the Attach → Paint tab is rendered with reduced
/// opacity and taps are rejected; its body shows a "waiting for attach" placeholder.
class PerformanceWaterfallSubTabs extends StatefulWidget {
  final LoadingState loadingState;
  final PerformanceTracker tracker;
  final Duration? attachOffset;
  final ValueChanged<WaterfallPhase>? onToggleFullscreen;

  /// Last-selected sub-tab index, persisted across widget rebuilds.
  /// Callers pass the same static int in both `initialIndex` and the
  /// `onIndexChanged` handler to keep the index sticky across the panel.
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  const PerformanceWaterfallSubTabs({
    super.key,
    required this.loadingState,
    required this.tracker,
    required this.attachOffset,
    this.onToggleFullscreen,
    this.initialIndex = 0,
    this.onIndexChanged,
  });

  @override
  State<PerformanceWaterfallSubTabs> createState() =>
      _PerformanceWaterfallSubTabsState();
}

class _PerformanceWaterfallSubTabsState
    extends State<PerformanceWaterfallSubTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex:
          widget.attachOffset != null ? widget.initialIndex.clamp(0, 1) : 0,
    );
  }

  @override
  void didUpdateWidget(covariant PerformanceWaterfallSubTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If attachOffset flips from null -> non-null, the disabled tab becomes
    // interactable; no index change needed. The reverse (non-null -> null)
    // can only happen on a new load, which typically destroys this widget
    // via parent rebuild. Defensive: if index is 1 and tab is now disabled,
    // jump back to 0.
    if (widget.attachOffset == null && _tabController.index == 1) {
      _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paintTabEnabled = widget.attachOffset != null;
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.blue,
          onTap: (index) {
            if (index == 1 && !paintTabEnabled) {
              _tabController.index = 0;
              return;
            }
            widget.onIndexChanged?.call(index);
          },
          tabs: [
            const Tab(
              child: Text('Init → Attach', style: TextStyle(fontSize: 12)),
            ),
            Tab(
              child: Opacity(
                opacity: paintTabEnabled ? 1.0 : 0.4,
                child: const Text('Attach → Paint',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const Divider(height: 1, color: Colors.white12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: paintTabEnabled
                ? null
                : const NeverScrollableScrollPhysics(),
            children: [
              WaterfallChart(
                loadingState: widget.loadingState,
                tracker: widget.tracker,
                phase: WaterfallPhase.initToAttach,
                onToggleFullscreen: widget.onToggleFullscreen == null
                    ? null
                    : () => widget.onToggleFullscreen!(WaterfallPhase.initToAttach),
              ),
              paintTabEnabled
                  ? WaterfallChart(
                      loadingState: widget.loadingState,
                      tracker: widget.tracker,
                      phase: WaterfallPhase.attachToPaint,
                      onToggleFullscreen: widget.onToggleFullscreen == null
                          ? null
                          : () => widget.onToggleFullscreen!(WaterfallPhase.attachToPaint),
                    )
                  : const _AttachPendingPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachPendingPlaceholder extends StatelessWidget {
  const _AttachPendingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.hourglass_empty, color: Colors.white54, size: 32),
          SizedBox(height: 12),
          Text(
            'Waiting for attachToFlutter…',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
