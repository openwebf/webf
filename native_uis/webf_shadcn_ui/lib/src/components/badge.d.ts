/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-badge>
 *
 * A small badge component for displaying labels or counts.
 *
 * @example
 * ```html
 * <flutter-shadcn-badge variant="default">New</flutter-shadcn-badge>
 * <flutter-shadcn-badge variant="destructive">Error</flutter-shadcn-badge>
 * ```
 */
interface FlutterShadcnBadgeProperties {
  /**
   * Visual variant of the badge.
   * - 'default': Primary filled badge
   * - 'secondary': Secondary muted badge
   * - 'destructive': Red destructive badge
   * - 'outline': Bordered outline badge
   * Default: 'default'
   */
  variant?: string;
}

interface FlutterShadcnBadgeEvents {}
