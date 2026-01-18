/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-popover>
 *
 * A floating content container that appears on trigger.
 *
 * @example
 * ```html
 * <flutter-shadcn-popover placement="bottom">
 *   <flutter-shadcn-popover-trigger>
 *     <flutter-shadcn-button>Open</flutter-shadcn-button>
 *   </flutter-shadcn-popover-trigger>
 *   <flutter-shadcn-popover-content>
 *     Popover content here.
 *   </flutter-shadcn-popover-content>
 * </flutter-shadcn-popover>
 * ```
 */
interface FlutterShadcnPopoverProperties {
  /**
   * Whether the popover is open.
   */
  open?: boolean;

  /**
   * Placement of the popover.
   * Options: 'top', 'bottom', 'left', 'right'
   * Default: 'bottom'
   */
  placement?: string;

  /**
   * Close when clicking outside.
   * Default: true
   */
  'close-on-outside-click'?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-popover>
 */
interface FlutterShadcnPopoverEvents {
  /** Fired when popover opens. */
  open: Event;

  /** Fired when popover closes. */
  close: Event;
}

/**
 * Properties for <flutter-shadcn-popover-trigger>
 * Trigger element for the popover.
 */
interface FlutterShadcnPopoverTriggerProperties {}

interface FlutterShadcnPopoverTriggerEvents {}

/**
 * Properties for <flutter-shadcn-popover-content>
 * Content of the popover.
 */
interface FlutterShadcnPopoverContentProperties {}

interface FlutterShadcnPopoverContentEvents {}
