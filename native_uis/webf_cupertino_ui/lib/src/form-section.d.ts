/*
 * Cupertino-style form sections and rows.
 *
 * These map to Flutter's `CupertinoFormSection` and `CupertinoFormRow`.
 */

/**
 * Properties for <flutter-cupertino-form-section>.
 * Wraps `CupertinoFormSection` with optional inset grouped styling.
 */
interface FlutterCupertinoFormSectionProperties {
  /**
   * Whether this section uses the "insetGrouped" style.
   * When true, the section has insets and rounded corners similar to
   * `CupertinoFormSection.insetGrouped`.
   * Default: false.
   */
  'inset-grouped'?: boolean;

  /**
   * Clip behavior applied to the section's background and children.
   * Accepts Flutter `Clip` values as strings, e.g.:
   * - 'none'
   * - 'hardEdge'
   * - 'antiAlias'
   * - 'antiAliasWithSaveLayer'
   *
   * Default: 'hardEdge'.
   */
  'clip-behavior'?: string;
}

/**
 * <flutter-cupertino-form-section> supports the following logical slots:
 * - header: section header content
 * - footer: section footer content
 * - default slot: one or more <flutter-cupertino-form-row> children
 */

interface FlutterCupertinoFormSectionEvents {
  // No custom events for now.
}

/**
 * Properties for <flutter-cupertino-form-row>.
 * Individual row inside a `CupertinoFormSection`.
 */
interface FlutterCupertinoFormRowProperties {}

/**
 * <flutter-cupertino-form-row> supports the following logical slots:
 * - prefix: leading content (label)
 * - helper: helper text below the row
 * - error: error text below the row
 * - default slot: main control (switch, input, etc.)
 */

interface FlutterCupertinoFormRowEvents {
  // No custom events for now; rows typically host interactive controls.
}

