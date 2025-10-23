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

  // Capacity for per-element matched-rules memoization LRU cache.
  // Kept intentionally small to bound memory. Adjust during perf validation.
  // Values <= 0 are treated as 1 internally.
  static int cssMatchedRulesCacheCapacity = 4;

  // Emit a per-flush/style-update breakdown to help diagnose hotspots when many
  // <style> elements are appended (e.g., in <head>). When true, logs timing for
  // style diff, invalidation, indexing, and flush along with dirty counts.
  static bool enableCssStyleUpdateBreakdown = false;

  // When true, prints more detailed invalidation info during stylesheet updates:
  // counts by rule category (id/class/attr/tag/universal/pseudo), fallback walk
  // visited/matched counts, and top-level tag keys involved. Use with the
  // breakdown flag to correlate timings.
  static bool enableCssInvalidateDetail = false;

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
