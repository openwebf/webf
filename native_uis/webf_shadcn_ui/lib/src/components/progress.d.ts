/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-progress>
 *
 * A progress indicator component.
 *
 * @example
 * ```html
 * <flutter-shadcn-progress value="60" max="100" />
 * ```
 */
interface FlutterShadcnProgressProperties {
  /**
   * Current progress value.
   */
  value?: string;

  /**
   * Maximum value.
   * Default: 100
   */
  max?: string;

  /**
   * Visual variant.
   * Options: 'default', 'indeterminate'
   * Default: 'default'
   */
  variant?: string;
}

interface FlutterShadcnProgressEvents {}
