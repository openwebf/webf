/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-cupertino-checkbox>
 * iOS-style checkbox.
 */
interface FlutterCupertinoCheckboxProperties {
  /**
   * Whether the checkbox is checked.
   * Default: false.
   */
  checked?: boolean | null;

  /**
   * Whether the checkbox is disabled.
   * Default: false.
   */
  disabled?: boolean;

  /**
   * Whether the checkbox supports a third, mixed state.
   * When true, Flutter's checkbox cycles false → true → null → false.
   * Default: false.
   */
  tristate?: boolean;

  /**
   * Color of the checkbox when selected.
   * Hex string '#RRGGBB' or '#AARRGGBB', or any CSS color supported by WebF.
   */
  'active-color'?: string;

  /**
   * Color of the check icon.
   * Hex string '#RRGGBB' or '#AARRGGBB', or any CSS color supported by WebF.
   */
  'check-color'?: string;

  /**
   * Focus highlight color.
   * Hex string '#RRGGBB' or '#AARRGGBB', or any CSS color supported by WebF.
   */
  'focus-color'?: string;

  /**
   * Fill color when the checkbox is selected.
   * Hex string '#RRGGBB' or '#AARRGGBB', or any CSS color supported by WebF.
   */
  'fill-color-selected'?: string;

  /**
   * Fill color when the checkbox is disabled.
   * Hex string '#RRGGBB' or '#AARRGGBB', or any CSS color supported by WebF.
   */
  'fill-color-disabled'?: string;

  /**
   * Whether this checkbox should focus itself if nothing else is focused.
   * Default: false.
   */
  autofocus?: boolean;

  /**
   * Semantic label announced by screen readers (not visible in the UI).
   */
  'semantic-label'?: string;
}

interface FlutterCupertinoCheckboxEvents {
  /**
   * Fired when the checkbox value changes.
   * detail = checked state as a boolean.
   */
  change: CustomEvent<boolean>;

  /**
   * Fired when the checkbox value changes, including tristate transitions.
   * detail = 'checked' | 'unchecked' | 'mixed'.
   *
   * Use this event when you need to distinguish the mixed state,
   * instead of relying on null.
   */
  statechange: CustomEvent<'checked' | 'unchecked' | 'mixed'>;
}
