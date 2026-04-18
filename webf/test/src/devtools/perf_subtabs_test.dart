/*
 * Copyright (C) 2026-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/launcher/loading_state.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/performance_waterfall_sub_tabs.dart';

Widget _harness({required Duration? attachOffset, int initialIndex = 0}) {
  final loadingState = LoadingState();
  final tracker = PerformanceTracker.instance;
  return MaterialApp(
    home: Scaffold(
      body: PerformanceWaterfallSubTabs(
        loadingState: loadingState,
        tracker: tracker,
        attachOffset: attachOffset,
        initialIndex: initialIndex,
      ),
    ),
  );
}

void main() {
  testWidgets('both sub-tab labels are present', (tester) async {
    await tester.pumpWidget(_harness(attachOffset: null));
    expect(find.text('Init → Attach'), findsOneWidget);
    expect(find.text('Attach → Paint'), findsOneWidget);
  });

  testWidgets('Attach → Paint label is dimmed when attachOffset is null',
      (tester) async {
    await tester.pumpWidget(_harness(attachOffset: null));
    final opacityFinder = find.ancestor(
      of: find.text('Attach → Paint'),
      matching: find.byType(Opacity),
    );
    expect(opacityFinder, findsOneWidget);
    final opacity = tester.widget<Opacity>(opacityFinder);
    expect(opacity.opacity, 0.4);
  });

  testWidgets('tapping disabled Attach → Paint tab keeps index at 0',
      (tester) async {
    await tester.pumpWidget(_harness(attachOffset: null));
    await tester.tap(find.text('Attach → Paint'));
    await tester.pumpAndSettle();
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller!.index, 0);
  });

  testWidgets('disabled tab is not selectable via initialIndex',
      (tester) async {
    await tester.pumpWidget(_harness(attachOffset: null, initialIndex: 1));
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller!.index, 0);
  });

  testWidgets('Attach → Paint label is full opacity when attachOffset is set',
      (tester) async {
    await tester.pumpWidget(
        _harness(attachOffset: const Duration(milliseconds: 500)));
    final opacityFinder = find.ancestor(
      of: find.text('Attach → Paint'),
      matching: find.byType(Opacity),
    );
    final opacity = tester.widget<Opacity>(opacityFinder);
    expect(opacity.opacity, 1.0);
  });
}
