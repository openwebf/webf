/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-cupertino-tab-bar>
 * Bottom navigation bar with iOS styling.
 */
interface FlutterCupertinoTabBarProperties {
  /**
   * Zero-based active item index.
   * Default: 0. Values outside range are clamped.
   */
  'current-index'?: int;
  /**
   * Background color of the tab bar.
   * Hex string: '#RRGGBB' or '#AARRGGBB'.
   */
  'background-color'?: string;
  /**
   * Color of the active item.
   * Hex string: '#RRGGBB' or '#AARRGGBB'.
   */
  'active-color'?: string;
  /**
   * Color of inactive items.
   * Hex string: '#RRGGBB' or '#AARRGGBB'.
   */
  'inactive-color'?: string;
  /**
   * Icon size in logical pixels.
   * Default: 30.
   */
  'icon-size'?: double;
  /**
   * Removes the top border.
   * Default: false.
   */
  'no-top-border'?: boolean;
}

interface FlutterCupertinoTabBarEvents {
  /** Fired when a different tab is selected. detail = selected index */
  change: CustomEvent<number>;
}
