/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-cupertino-tab-view>
 * Provides an iOS-style per-tab Navigator. Used inside TabScaffold tabs.
 */
interface FlutterCupertinoTabViewProperties {
  /**
   * Default title used by the Navigator for the top-most route.
   */
  'default-title'?: string;

  /**
   * Restoration scope ID to enable state restoration for this tab's Navigator.
   */
  'restoration-scope-id'?: string;
}

interface FlutterCupertinoTabViewEvents {}
