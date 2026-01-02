/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-cupertino-switch>
 * iOS-style toggle switch.
 */
interface FlutterCupertinoSwitchProperties {
  /**
   * Whether the switch is on.
   * Default: false.
   */
  checked?: boolean;

  /**
   * Whether the switch is disabled.
   * Default: false.
   */
  disabled?: boolean;

  /**
   * Track color when the switch is on.
   * Hex string '#RRGGBB' or '#AARRGGBB'.
   */
  'active-color'?: string;

  /**
   * Track color when the switch is off.
   * Hex string '#RRGGBB' or '#AARRGGBB'.
   */
  'inactive-color'?: string;
}

interface FlutterCupertinoSwitchEvents {
  /** Fired when the switch value changes. detail = checked state */
  change: CustomEvent<boolean>;
}
