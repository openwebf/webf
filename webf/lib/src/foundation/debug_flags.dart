/*
 * Runtime debug flags for optional verbose logging.
 */

class DebugFlags {
  // Controls verbose CSS/media/variables/style logs added for diagnostics.
  static bool enableCssLogs = false;

  // Enables lightweight CSS performance counters and timing when true.
  // When disabled, instrumentation code is a fast no-op.
  static bool enableCssPerf = false;

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
