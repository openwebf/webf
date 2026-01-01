/*
 * Cupertino-style single-line text input.
 *
 * Backed by Flutter's `CupertinoTextField`.
 */

/**
 * Properties for <flutter-cupertino-input>.
 */
interface FlutterCupertinoInputProperties {
  /**
   * Current text value of the input.
   */
  val?: string;

  /**
   * Placeholder text shown when the field is empty.
   */
  placeholder?: string;

  /**
   * Input type / keyboard type.
   * Supported values:
   * - 'text' (default)
   * - 'password'
   * - 'number'
   * - 'tel'
   * - 'email'
   * - 'url'
   */
  type?: string;

  /**
   * Whether the field is disabled (non-editable and dimmed).
   * Default: false.
   */
  disabled?: boolean;

  /**
   * Whether the field should autofocus when inserted.
   * Default: false.
   */
  autofocus?: boolean;

  /**
   * Whether to show a clear button while editing.
   * When true, a clear icon appears while text is non-empty.
   * Default: false.
   */
  clearable?: boolean;

  /**
   * Maximum number of characters allowed.
   * When set, input is truncated to this length.
   */
  maxlength?: int;

  /**
   * Whether the field is read-only (focusable but not editable).
   * Default: false.
   */
  readonly?: boolean;
}

interface FlutterCupertinoInputMethods {
  /** Programmatically focus the input. */
  focus(): void;
  /** Programmatically blur (unfocus) the input. */
  blur(): void;
  /** Clear the current value. Triggers the `clear` event. */
  clear(): void;
}

interface FlutterCupertinoInputEvents {
  /**
   * Fired whenever the text changes.
   * detail = current value.
   */
  input: CustomEvent<string>;

  /**
   * Fired when the user submits the field (e.g., presses the done/enter key).
   * detail = current value.
   */
  submit: CustomEvent<string>;

  /** Fired when the field gains focus. */
  focus: CustomEvent<void>;

  /** Fired when the field loses focus. */
  blur: CustomEvent<void>;

  /** Fired when the text is cleared via clear button or clear(). */
  clear: CustomEvent<void>;
}

