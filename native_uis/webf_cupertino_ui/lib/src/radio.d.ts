/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-cupertino-radio>
 * macOS-style radio button.
 */
interface FlutterCupertinoRadioProperties {
  /**
   * Value represented by this radio button.
   * When it matches `group-value`, the radio is selected.
   */
  val?: string;

  /**
   * Currently selected value for the radio group.
   * When equal to `val`, this radio appears selected.
   */
  'group-value'?: string;

  /**
   * Whether the radio is disabled.
   * When true, the control is non-interactive and dimmed.
   */
  disabled?: boolean;

  /**
   * Whether this radio can be toggled off by tapping it again when selected.
   * When true, on change the group value may be cleared.
   * Default: false.
   */
  toggleable?: boolean;

  /**
   * When true, renders in a checkmark style instead of the default radio style.
   * Default: false.
   */
  'use-checkmark-style'?: boolean;

  /**
   * Color used when this radio is selected.
   * Hex string '#RRGGBB' or '#AARRGGBB', or any CSS color supported by WebF.
   */
  'active-color'?: string;

  /**
   * Color used when this radio is not selected.
   * Hex string '#RRGGBB' or '#AARRGGBB', or any CSS color supported by WebF.
   */
  'inactive-color'?: string;

  /**
   * Inner fill color when selected.
   * Hex string '#RRGGBB' or '#AARRGGBB', or any CSS color supported by WebF.
   */
  'fill-color'?: string;

  /**
   * Focus highlight color.
   * Hex string '#RRGGBB' or '#AARRGGBB', or any CSS color supported by WebF.
   */
  'focus-color'?: string;

  /**
   * Whether this radio should focus itself if nothing else is focused.
   * Default: false.
   */
  autofocus?: boolean;
}

interface FlutterCupertinoRadioEvents {
  /**
   * Fired when this radio is selected or deselected.
   * detail = the new group value (string); when `toggleable` is true and
   * the selection is cleared, detail is the empty string ''.
   */
  change: CustomEvent<string>;
}
