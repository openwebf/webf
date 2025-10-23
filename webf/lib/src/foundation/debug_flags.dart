/*
 * Runtime debug flags for optional verbose logging.
 */

class DebugFlags {
  // Controls verbose CSS/media/variables/style logs added for diagnostics.
  static bool enableCssLogs = false;

  // Enables lightweight CSS performance counters and timing when true.
  // When disabled, instrumentation code is a fast no-op.
  static bool enableCssPerf = false;
  // Enable per-element matched rules memoization to reduce selector matching
  // cost when selector-relevant keys (tag/id/class/attr presence) are stable.
  static bool enableCssMemoization = true;

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
  static bool enableCssBatchRecalc = false;

  // Extra diagnostics for bursts of <style> insertions and stylesheet flushes.
  // When true, logs multi-style add/flush details to help analyze overhead
  // when multiple style elements are appended quickly (e.g., in <head>).
  static bool enableCssMultiStyleTrace = false;

  // Batch multiple <style>/<link rel=stylesheet> insertions into a single
  // stylesheet update + flush per microtask to reduce repeated diffs/recalcs
  // during bursts. When true, style/link code schedules a deferred
  // updateStyleIfNeeded() instead of calling it immediately after each
  // appendPendingStyleSheet().
  static bool enableCssBatchStyleUpdates = false;

  // If true, batch stylesheet updates to the end of the current frame instead
  // of the current microtask. This can coalesce bursts across multiple
  // microtasks (e.g., async insertions) into a single flush per frame. Only
  // applied when enableCssBatchStyleUpdates is also true.
  static bool enableCssBatchStyleUpdatesPerFrame = false;

  // Optional debounce window (milliseconds) for batching stylesheet updates
  // across multiple frames. When > 0 and enableCssBatchStyleUpdates is true,
  // style/link updates are debounced by this window and flushed once when
  // no further updates arrive within the interval.
  static int cssBatchStyleUpdatesDebounceMs = 0;

  // Controls verbose IMG element logs added for diagnostics.
  static bool enableImageLogs = false;

  // Removed: Use FlowLog filters to enable flow logs.

  // Verbose logging for scrollable sizing; toggle at runtime.
  static bool debugLogScrollableEnabled = false;

  // Enable verbose baseline logging for flex baseline alignment.
  static bool debugLogFlexBaselineEnabled = false;

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

  // Enable general DevTools/CDP service logs (lifecycle, routing, targets)
  static bool enableDevToolsLogs = false;

  // Enable verbose CDP protocol logs (incoming/outgoing messages and params)
  // Use with care; this can be very chatty during screencast/network activity.
  static bool enableDevToolsProtocolLogs = false;
}
