/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-tooltip>
 *
 * A tooltip component that shows additional information on hover.
 *
 * @example
 * ```html
 * <flutter-shadcn-tooltip content="This is a tooltip">
 *   <flutter-shadcn-button>Hover me</flutter-shadcn-button>
 * </flutter-shadcn-tooltip>
 * ```
 */
interface FlutterShadcnTooltipProperties {
  /**
   * Text content of the tooltip.
   */
  content?: string;

  /**
   * Delay before showing tooltip in milliseconds.
   * Default: 200
   */
  'show-delay'?: string;

  /**
   * Delay before hiding tooltip in milliseconds.
   * Default: 0
   */
  'hide-delay'?: string;

  /**
   * Placement of the tooltip relative to the trigger.
   * Options: 'top', 'bottom', 'left', 'right'
   * Default: 'top'
   */
  placement?: string;
}

interface FlutterShadcnTooltipEvents {}
