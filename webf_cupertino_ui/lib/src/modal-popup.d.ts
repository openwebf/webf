/**
 * Properties for <flutter-cupertino-modal-popup>.
 * Generic Cupertino-style modal popup overlay driven by WebF and Flutter.
 *
 * Content is provided by the element's children and is shown in a bottom
 * sheet using Flutter's `showCupertinoModalPopup`.
 */
interface FlutterCupertinoModalPopupProperties {
  /**
   * Whether the popup is currently visible.
   *
   * Usually controlled via the imperative `show()` / `hide()` methods,
   * but can also be toggled directly via this property.
   */
  visible?: boolean;

  /**
   * Fixed height of the popup content in logical pixels.
   * Example: 200 for ~200px popup height.
   * When omitted, the popup height is driven by its content.
   */
  height?: double;

  /**
   * Whether the popup surface should use the standard Cupertino
   * background and border styling.
   * Default: true.
   */
  'surface-painted'?: boolean;

  /**
   * Whether tapping on the background mask should dismiss the popup.
   * Default: true.
   */
  'mask-closable'?: boolean;

  /**
   * Background mask opacity (0.0–1.0).
   * Default: 0.4 (semi-opaque).
   */
  'background-opacity'?: double;
}

interface FlutterCupertinoModalPopupMethods {
  /**
   * Show the popup.
   */
  show(): void;

  /**
   * Hide the popup if it is currently visible.
   */
  hide(): void;
}

interface FlutterCupertinoModalPopupEvents {
  /**
   * Fired when the popup is dismissed, either by:
   * - tapping the mask (when maskClosable is true),
   * - calling hide(),
   * - or system back gesture.
   */
  close: CustomEvent<void>;
}

