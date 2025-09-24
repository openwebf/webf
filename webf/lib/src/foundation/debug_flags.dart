/*
 * Runtime debug flags for optional verbose logging.
 */

class DebugFlags {
  // Controls verbose CSS/media/variables/style logs added for diagnostics.
  static bool enableCssLogs = false;

  // Controls verbose IMG element logs added for diagnostics.
  static bool enableImageLogs = false;

  // Verbose logging for flow sizing and constraints; toggle at runtime.
  static bool debugLogFlowEnabled = false;

  // Verbose logging for scrollable sizing; toggle at runtime.
  static bool debugLogScrollableEnabled = false;

  // Enable verbose baseline logging for flex baseline alignment.
  static bool debugLogFlexBaselineEnabled = false;

  // Verbose logging for flex sizing and constraints; toggle at runtime.
  static bool debugLogFlexEnabled = false;

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
  static bool debugLogInlineLayoutEnabled = false; // Enable verbose logging for paragraph-based IFC

  // Enable verbose DOM logs (tree walks, counters, pseudo, etc.)
  static bool enableDomLogs = false;
}
