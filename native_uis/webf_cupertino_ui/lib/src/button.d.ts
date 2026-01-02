/**
 * Properties for <flutter-cupertino-button>
 */
interface FlutterCupertinoButtonProperties {
  /**
   * Visual variant of the button.
   * - 'plain': Standard CupertinoButton
   * - 'filled': CupertinoButton.filled (ignores custom background color)
   * - 'tinted': CupertinoButton.tinted
   * Default: 'plain'
   */
  variant?: string;

  /**
   * Size style used to derive default padding and min height.
   * - 'small': minSize ~32, compact padding
   * - 'large': minSize ~44, comfortable padding
   * Default: 'small'
   */
  size?: string;

  /**
   * Disable interactions. When true, onPressed is null and the button uses a disabled color.
   */
  disabled?: boolean;

  /**
   * Opacity applied while pressed (0.0–1.0). Default: 0.4
   * Note: Accepts numeric value as a string.
   */
  'pressed-opacity'?: string;

  /**
   * Hex color used when disabled. Accepts '#RRGGBB' or '#AARRGGBB'.
   * Overrides the internally computed disabled color.
   */
  'disabled-color'?: string;
}

/**
 * Events emitted by <flutter-cupertino-button>
 */
interface FlutterCupertinoButtonEvents {
  /** Fired when the button is pressed (not emitted when disabled). */
  click: Event;
}
