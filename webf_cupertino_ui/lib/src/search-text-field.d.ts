/*
 * Cupertino-style search text field.
 *
 * This maps Flutter's `CupertinoSearchTextField` into a WebF custom element.
 */

/**
 * Properties for <flutter-cupertino-search-text-field>.
 */
interface FlutterCupertinoSearchTextFieldProperties {
  /**
   * Current text value of the search field.
   */
  val?: string;

  /**
   * Placeholder text shown when the field is empty.
   * Defaults to the localized "Search" string if not provided.
   */
  placeholder?: string;

  /**
   * Whether the field should autofocus when inserted.
   * Default: false.
   */
  autofocus?: boolean;

  /**
   * Whether the field is disabled (non-editable and dimmed).
   * Default: false.
   */
  disabled?: boolean;
}

interface FlutterCupertinoSearchTextFieldMethods {
  /** Programmatically focus the search field. */
  focus(): void;
  /** Programmatically blur (unfocus) the search field. */
  blur(): void;
  /** Clear the current value. Triggers the `clear` and `input` events. */
  clear(): void;
}

interface FlutterCupertinoSearchTextFieldEvents {
  /**
   * Fired whenever the text changes.
   * detail = current value.
   */
  input: CustomEvent<string>;

  /**
   * Fired when the user submits the field (e.g., presses the search button).
   * detail = current value.
   */
  submit: CustomEvent<string>;

  /** Fired when the field gains focus. */
  focus: CustomEvent<void>;

  /** Fired when the field loses focus. */
  blur: CustomEvent<void>;

  /** Fired when the text is cleared via clear() or the suffix clear button. */
  clear: CustomEvent<void>;
}

