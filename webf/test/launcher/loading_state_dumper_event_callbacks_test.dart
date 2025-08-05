/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/launcher.dart';

void main() {
  group('LoadingStateDumper Event Callbacks', () {
    test('convenience methods should register and trigger event callbacks', () {
      final dumper = LoadingState();
      final phaseEvents = <String>[];

      // Register callbacks using convenience methods
      dumper.onConstructor((event) => phaseEvents.add('constructor:${event.elapsed.inMilliseconds}'));
      dumper.onInit((event) => phaseEvents.add('init:${event.elapsed.inMilliseconds}'));
      dumper.onPreload((event) => phaseEvents.add('preload:${event.elapsed.inMilliseconds}'));
      dumper.onResolveEntrypointStart((event) => phaseEvents.add('resolveEntrypoint.start:${event.elapsed.inMilliseconds}'));
      dumper.onResolveEntrypointEnd((event) => phaseEvents.add('resolveEntrypoint.end:${event.elapsed.inMilliseconds}'));
      dumper.onParseHTMLStart((event) => phaseEvents.add('parseHTML.start:${event.elapsed.inMilliseconds}'));
      dumper.onParseHTMLEnd((event) => phaseEvents.add('parseHTML.end:${event.elapsed.inMilliseconds}'));
      dumper.onScriptQueue((event) => phaseEvents.add('scriptQueue:${event.elapsed.inMilliseconds}'));
      dumper.onScriptLoadStart((event) => phaseEvents.add('scriptLoadStart:${event.elapsed.inMilliseconds}'));
      dumper.onScriptLoadComplete((event) => phaseEvents.add('scriptLoadComplete:${event.elapsed.inMilliseconds}'));
      dumper.onAttachToFlutter((event) => phaseEvents.add('attachToFlutter:${event.elapsed.inMilliseconds}'));
      dumper.onScriptExecuteStart((event) => phaseEvents.add('scriptExecuteStart:${event.elapsed.inMilliseconds}'));
      dumper.onScriptExecuteComplete((event) => phaseEvents.add('scriptExecuteComplete:${event.elapsed.inMilliseconds}'));
      dumper.onDOMContentLoaded((event) => phaseEvents.add('domContentLoaded:${event.elapsed.inMilliseconds}'));
      dumper.onWindowLoad((event) => phaseEvents.add('windowLoad:${event.elapsed.inMilliseconds}'));
      dumper.onBuildRootView((event) => phaseEvents.add('buildRootView:${event.elapsed.inMilliseconds}'));
      dumper.onFirstPaint((event) => phaseEvents.add('firstPaint:${event.elapsed.inMilliseconds}'));
      dumper.onFirstContentfulPaint((event) => phaseEvents.add('firstContentfulPaint:${event.elapsed.inMilliseconds}'));
      dumper.onLargestContentfulPaint((event) => phaseEvents.add('largestContentfulPaint:${event.elapsed.inMilliseconds}'));

      // Record phases
      dumper.recordPhase(LoadingState.phaseConstructor);
      dumper.recordPhase(LoadingState.phaseInit);
      dumper.recordPhase(LoadingState.phasePreload);
      dumper.recordPhase('resolveEntrypoint.start');
      dumper.recordPhase('resolveEntrypoint.end');
      dumper.recordPhase('parseHTML.start');
      dumper.recordPhase('parseHTML.end');
      dumper.recordPhase('scriptQueue');
      dumper.recordPhase('scriptLoadStart');
      dumper.recordPhase('scriptLoadComplete');
      dumper.recordPhase(LoadingState.phaseAttachToFlutter);
      dumper.recordPhase('scriptExecuteStart');
      dumper.recordPhase('scriptExecuteComplete');
      dumper.recordPhase(LoadingState.phaseDOMContentLoaded);
      dumper.recordPhase(LoadingState.phaseWindowLoad);
      dumper.recordPhase(LoadingState.phaseBuildRootView);
      dumper.recordPhase(LoadingState.phaseFirstPaint);
      dumper.recordPhase(LoadingState.phaseFirstContentfulPaint);
      dumper.recordPhase(LoadingState.phaseLargestContentfulPaint);

      // Verify all events were triggered
      expect(phaseEvents.length, equals(19));
      expect(phaseEvents[0], startsWith('constructor:'));
      expect(phaseEvents[1], startsWith('init:'));
      expect(phaseEvents[2], startsWith('preload:'));
      expect(phaseEvents[3], startsWith('resolveEntrypoint.start:'));
      expect(phaseEvents[4], startsWith('resolveEntrypoint.end:'));
      expect(phaseEvents[5], startsWith('parseHTML.start:'));
      expect(phaseEvents[6], startsWith('parseHTML.end:'));
      expect(phaseEvents[7], startsWith('scriptQueue:'));
      expect(phaseEvents[8], startsWith('scriptLoadStart:'));
      expect(phaseEvents[9], startsWith('scriptLoadComplete:'));
      expect(phaseEvents[10], startsWith('attachToFlutter:'));
      expect(phaseEvents[11], startsWith('scriptExecuteStart:'));
      expect(phaseEvents[12], startsWith('scriptExecuteComplete:'));
      expect(phaseEvents[13], startsWith('domContentLoaded:'));
      expect(phaseEvents[14], startsWith('windowLoad:'));
      expect(phaseEvents[15], startsWith('buildRootView:'));
      expect(phaseEvents[16], startsWith('firstPaint:'));
      expect(phaseEvents[17], startsWith('firstContentfulPaint:'));
      expect(phaseEvents[18], startsWith('largestContentfulPaint:'));
    });

    test('should handle LCP parameters correctly', () {
      final dumper = LoadingState();
      LoadingPhaseEvent? capturedEvent;

      dumper.onLargestContentfulPaint((event) {
        capturedEvent = event;
      });

      // Record LCP with candidate status
      dumper.recordPhase(LoadingState.phaseLargestContentfulPaint, parameters: {
        'isCandidate': true,
        'isFinal': false,
        'timeSinceNavigationStart': 1500,
      });

      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.parameters['isCandidate'], isTrue);
      expect(capturedEvent!.parameters['isFinal'], isFalse);
      expect(capturedEvent!.parameters['timeSinceNavigationStart'], equals(1500));

      // Record final LCP
      dumper.recordPhase(LoadingState.phaseLargestContentfulPaint, parameters: {
        'isCandidate': false,
        'isFinal': true,
        'timeSinceNavigationStart': 2000,
      });

      expect(capturedEvent!.parameters['isCandidate'], isFalse);
      expect(capturedEvent!.parameters['isFinal'], isTrue);
      expect(capturedEvent!.parameters['timeSinceNavigationStart'], equals(2000));
    });
  });
}
