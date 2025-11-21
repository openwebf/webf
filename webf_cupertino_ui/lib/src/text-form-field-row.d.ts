/*
 * Cupertino-style form row containing a text field.
 *
 * This maps Flutter's `CupertinoTextFormFieldRow` semantics into a single
 * WebF custom element that combines a form row with a borderless text field.
 */

/**
 * Properties for <flutter-cupertino-text-form-field-row>.
 *
 * This element behaves similarly to using a <flutter-cupertino-form-row>
 * with a <flutter-cupertino-input> as its child, but wrapped into a single
 * convenience component.
 */
interface FlutterCupertinoTextFormFieldRowProperties {
  /**
   * Current text value of the field.
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

interface FlutterCupertinoTextFormFieldRowMethods {
  /** Programmatically focus the input inside the row. */
  focus(): void;
  /** Programmatically blur (unfocus) the input inside the row. */
  blur(): void;
  /** Clear the current value. Triggers the `clear` event. */
  clear(): void;
}

interface FlutterCupertinoTextFormFieldRowEvents {
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

  /** Fired when the text is cleared via clear() or internal clear logic. */
  clear: CustomEvent<void>;
}
