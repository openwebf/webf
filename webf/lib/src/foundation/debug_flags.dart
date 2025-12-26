/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Runtime debug flags for optional verbose logging.
 */

class DebugFlags {
  // Enable per-element matched rules memoization to reduce selector matching
  // cost when selector-relevant keys (tag/id/class/attr presence) are stable.
  static bool enableCssMemoization = true;

  // Capacity for per-element matched-rules memoization LRU cache.
  // Kept intentionally small to bound memory. Adjust during perf validation.
  // Values <= 0 are treated as 1 internally.
  static int cssMatchedRulesCacheCapacity = 4;

  // Dangerous: disables recalc-from-root fallback during flush, forcing only
  // targeted recalculation of dirty elements. Useful to isolate whether full
  // root recalc is the hotspot, but may lead to incorrect styles. Debug only.
  static bool enableCssDisableRootRecalc = false;

  // In stylesheet invalidation, skip evaluating universal selectors in the
  // fallback walk. This can significantly reduce cost when many universal
  // selectors change. Debug-only; may hide matches.
  static bool enableCssInvalidateSkipUniversal = false;

  // In stylesheet invalidation, skip evaluating tag selectors in the fallback
  // walk (e.g., DIV, SPAN, etc.). Debug-only; may hide matches.
  static bool enableCssInvalidateSkipTag = false;

  // Optional cap for how many universal rules to evaluate during invalidation
  // (0 or negative means no cap). Useful for probing cost sensitivity.
  static int cssInvalidateUniversalCap = 0;

  // Heuristic: when the number of changed universal selectors exceeds this
  // threshold, treat universal evaluation during invalidation as too costly and
  // skip it automatically (equivalent to enableCssInvalidateSkipUniversal).
  // Only applied when enableCssInvalidateUniversalHeuristics is true.
  static bool enableCssInvalidateUniversalHeuristics = false;
  static int cssInvalidateUniversalSkipThreshold = 128;

  // Detailed logging for selector matching: logs each matchesCompound()
  // evaluation with timing, selector summary, and early-fail position/type.
  // Useful to pinpoint slow selector patterns.
  static bool enableCssMatchDetail = false;

  // When > 0, emit a match-detail log only when a single matchesCompound()
  // evaluation takes at least this many milliseconds.
  static int cssMatchCompoundLogThresholdMs = 0;

  // Maximum number of [match][compound] logs to emit per style flush.
  // 0 or negative disables the cap (unlimited). Use to keep logs readable
  // when investigating in large apps.
  static int cssMatchCompoundMaxLogsPerFlush = 0;

  // Ultra-detailed CSS tracing for investigations. When true, emit
  // [trace] logs for dirty marking, invalidation sources, cache hits, and
  // root recalcs. Intended for short profiling sessions.
  static bool enableCssTrace = false;

  // Guard for selector matching micro-optimization that performs a cheap
  // ancestry key precheck for descendant combinators. This may help in deep
  // trees with heavy descendant selectors, but can add overhead otherwise.
  static bool enableCssAncestryFastPath = true;

  // Guard for batching style recalculation: when true, class/id/attribute
  // setters will mark the element dirty and defer style recalculation to the
  // next Document.flushStyle() or updateStyleIfNeeded() call.
  static bool enableCssBatchRecalc = true;

  // Extra diagnostics for bursts of <style> insertions and stylesheet flushes.
  // When true, logs multi-style add/flush details to help analyze overhead
  // when multiple style elements are appended quickly (e.g., in <head>).
  static bool enableCssMultiStyleTrace = false;

  // Batch multiple <style>/<link rel=stylesheet> insertions into a single
  // stylesheet update + flush per microtask to reduce repeated diffs/recalcs
  // during bursts. When true, style/link code schedules a deferred
  // updateStyleIfNeeded() instead of calling it immediately after each
  // appendPendingStyleSheet().
  static bool enableCssBatchStyleUpdates = true;

  // If true, batch stylesheet updates to the end of the current frame instead
  // of the current microtask. This can coalesce bursts across multiple
  // microtasks (e.g., async insertions) into a single flush per frame. Only
  // applied when enableCssBatchStyleUpdates is also true.
  static bool enableCssBatchStyleUpdatesPerFrame = false;

  // Optional debounce window (milliseconds) for batching stylesheet updates
  // across multiple frames. When > 0 and enableCssBatchStyleUpdates is true,
  // style/link updates are debounced by this window and flushed once when
  // no further updates arrive within the interval.
  static int cssBatchStyleUpdatesDebounceMs = 32;

  // Controls verbose IMG/network/decode logs for diagnostics.
  static bool enableImageLogs = false;

  // Removed: Use FlowLog filters to enable flow logs.

  // Verbose logging for scrollable sizing; toggle at runtime.
  static bool debugLogScrollableEnabled = const bool.fromEnvironment('WEBF_DEBUG_SCROLL', defaultValue: false);

  // Enable verbose baseline logging for flex baseline alignment.
  static bool debugLogFlexBaselineEnabled = false;

  // Emit verbose semantics dumps per element to troubleshoot a11y tree wiring.
  static bool debugLogSemanticsEnabled = false;

  // Emit lightweight profiling logs from RenderGridLayout for track sizing and
  // auto-placement hot paths. Intended for Phase 5 hardening work.
  static bool enableCssGridProfiling = false;
  // Minimum duration (ms) before a grid profiling span is logged. Helps reduce
  // noise when profiling small grids.
  static int cssGridProfilingMinMs = 2;

  // Removed: Use FlexLog filters to enable flex logs.

  /// Debug flag to enable inline layout visualization.
  /// When true, paints debug information for line boxes, margins, padding, etc.
  ///
  /// To enable debug painting:
  /// ```dart
  /// import 'package:webf/rendering.dart';
  ///
  /// // Enable debug paint
  /// debugPaintInlineLayoutEnabled = true;
  ///
  /// // Your WebF widget will now show debug visualizations
  /// ```
  ///
  /// Debug visualizations include:
  /// - Green outline: Line box bounds
  /// - Red line: Text baseline
  /// - Blue outline: Text item bounds
  /// - Magenta outline: Inline box bounds (span, etc.)
  /// - Red semi-transparent fill: Left margin area
  /// - Green semi-transparent fill: Right margin area
  /// - Blue semi-transparent fill: Padding area
  ///
  /// This is useful for debugging inline layout issues such as:
  /// - Margin gaps not appearing correctly
  /// - Text alignment problems
  /// - Line box height calculations
  /// - Padding and border rendering
  static bool debugPaintInlineLayoutEnabled = false;
  // Removed: Use InlineLayoutLog filters to enable inline layout logs.

  // Enable verbose DOM logs (tree walks, counters, pseudo, etc.)
  static bool enableDomLogs = false;

  // Enable verbose Canvas 2D logs (action queue + paint scheduling).
  static bool enableCanvasLogs = false;

  // Enable general DevTools/CDP service logs (lifecycle, routing, targets)
  static bool enableDevToolsLogs = false;

  // Enable verbose CDP protocol logs (incoming/outgoing messages and params)
  // Use with care; this can be very chatty during screencast/network activity.
  static bool enableDevToolsProtocolLogs = false;

  // Verbose tracing for CSS variables and transitions decision points.
  // When true, logs:
  // - setCSSVariable/_notifyCSSVariableChanged flow
  // - Element._onStyleChanged routing and pending/running checks
  // - shouldTransition() decisions
  // - scheduleRunTransitionAnimations() batching
  // - runTransition() begin/end values and cancellation
  static bool enableCssVarAndTransitionLogs = false;

  // Optional: narrow transition/variable logs to specific CSS properties.
  // Put camelCase property names here (e.g., 'transform', 'backgroundColor').
  // When empty, all properties are logged (subject to enableCssVarAndTransitionLogs).
  static Set<String> watchedTransitionProperties = <String>{};

  // Helper to decide if we should emit logs for a specific CSS property.
  static bool shouldLogTransitionForProp(String property) {
    if (!enableCssVarAndTransitionLogs) return false;
    if (watchedTransitionProperties.isEmpty) return true;
    return watchedTransitionProperties.contains(property);
  }

  // Optional: narrow variable logs to specific CSS custom properties.
  // Use raw variable identifiers including leading dashes, e.g., '--tw-translate-x'.
  static Set<String> watchedCssVariables = <String>{};

  // Decide whether to log a CSS variable event. If deps are provided, this will
  // allow logging only when the variable feeds into a watched CSS property.
  static bool shouldLogCssVar(String identifier, [Iterable<String>? deps]) {
    if (!enableCssVarAndTransitionLogs) return false;
    if (watchedCssVariables.isNotEmpty) return watchedCssVariables.contains(identifier);
    // If no explicit var whitelist, only log when it affects watched properties.
    if (watchedTransitionProperties.isEmpty) return false;
    if (deps != null) {
      for (final String s in deps) {
        final String prop = s.contains('_') ? s.split('_').first : s;
        if (shouldLogTransitionForProp(prop)) return true;
      }
    }
    return false;
  }

  // When true, emit [var][dep] logs for variable-to-property dependency tracking.
  // Defaults to false to reduce noise; enable only when diagnosing var() chains.
  static bool enableCssVarDependencyLogs = false;

  // Background paint diagnostics: when true, logs background layering order,
  // per-layer size/position/repeat, and chosen rects for gradients/images.
  static bool enableBackgroundLogs = false;

  // Border/border-radius diagnostics: when true, logs parsing, resolution,
  // and painting decisions for border-radius (including clip/painter paths).
  static bool enableBorderRadiusLogs = false;
}
