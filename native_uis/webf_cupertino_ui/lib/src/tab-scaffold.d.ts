/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-cupertino-tab-scaffold>
 * A container that renders a bottom tab bar and tabbed content (iOS style).
 */
interface FlutterCupertinoTabScaffoldProperties {
  /**
   * Zero-based index of the active tab.
   * Default: 0. Values outside range are clamped.
   */
  'current-index'?: int;
  /**
   * Whether to avoid bottom insets (e.g., when keyboard appears).
   * Boolean attribute; presence means true.
   * Default: true.
   */
  'resize-to-avoid-bottom-inset'?: string;
}

interface FlutterCupertinoTabScaffoldEvents {
  /** Fired when the active tab changes. detail = current index */
  change: CustomEvent<number>;
}

/**
 * Properties for <flutter-cupertino-tab-scaffold-tab>
 * Child item used within the TabScaffold; provides title and content for a tab.
 */
interface FlutterCupertinoTabScaffoldTabProperties {
  /** Label shown in the tab bar for this tab. */
  title?: string;
}

interface FlutterCupertinoTabScaffoldTabEvents {}
