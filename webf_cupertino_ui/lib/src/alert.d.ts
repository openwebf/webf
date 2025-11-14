/**
 * Properties for <flutter-cupertino-alert>
 * Imperative wrapper around Flutter's CupertinoAlertDialog.
 */
interface FlutterCupertinoAlertProperties {
  /**
   * Dialog title text.
   */
  title?: string;

  /**
   * Dialog message/body text.
   */
  message?: string;

  /**
   * Cancel button label. If empty or omitted, no cancel button is shown.
   */
  'cancel-text'?: string;

  /**
   * Whether the cancel button is destructive (red).
   * Default: false.
   */
  'cancel-destructive'?: boolean;

  /**
   * Whether the cancel button is the default action.
   * Default: false.
   */
  'cancel-default'?: boolean;

  /**
   * JSON-encoded text style for the cancel button label.
   * Example: '{"color":"#FF0000","fontSize":16,"fontWeight":"bold"}'
   */
  'cancel-text-style'?: string;

  /**
   * Confirm button label.
   * Default: localized 'OK'.
   */
  'confirm-text'?: string;

  /**
   * Whether the confirm button is the default action.
   * Default: true.
   */
  'confirm-default'?: boolean;

  /**
   * Whether the confirm button is destructive.
   * Default: false.
   */
  'confirm-destructive'?: boolean;

  /**
   * JSON-encoded text style for the confirm button label.
   */
  'confirm-text-style'?: string;
}

interface FlutterCupertinoAlertOptions {
  /** Optional override title for this show() call. */
  title?: string;
  /** Optional override message for this show() call. */
  message?: string;
}

interface FlutterCupertinoAlertMethods {
  /**
   * Show the alert dialog.
   * Options override the current title/message for this call only.
   */
  show(options?: FlutterCupertinoAlertOptions): void;

  /**
   * Hide the alert dialog if it is currently visible.
   */
  hide(): void;
}

interface FlutterCupertinoAlertEvents {
  /** Fired when the cancel button is pressed. */
  cancel: CustomEvent<void>;
  /** Fired when the confirm button is pressed. */
  confirm: CustomEvent<void>;
}

