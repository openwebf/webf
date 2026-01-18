/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-context-menu>
 *
 * A context menu that appears on right-click.
 *
 * @example
 * ```html
 * <flutter-shadcn-context-menu>
 *   <flutter-shadcn-context-menu-trigger>
 *     <div>Right click here</div>
 *   </flutter-shadcn-context-menu-trigger>
 *   <flutter-shadcn-context-menu-content>
 *     <flutter-shadcn-context-menu-item>Cut</flutter-shadcn-context-menu-item>
 *     <flutter-shadcn-context-menu-item>Copy</flutter-shadcn-context-menu-item>
 *     <flutter-shadcn-context-menu-item>Paste</flutter-shadcn-context-menu-item>
 *   </flutter-shadcn-context-menu-content>
 * </flutter-shadcn-context-menu>
 * ```
 */
interface FlutterShadcnContextMenuProperties {
  /**
   * Whether the menu is open.
   */
  open?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-context-menu>
 */
interface FlutterShadcnContextMenuEvents {
  /** Fired when menu opens. */
  open: Event;

  /** Fired when menu closes. */
  close: Event;
}

/**
 * Properties for <flutter-shadcn-context-menu-trigger>
 */
interface FlutterShadcnContextMenuTriggerProperties {}

interface FlutterShadcnContextMenuTriggerEvents {}

/**
 * Properties for <flutter-shadcn-context-menu-content>
 */
interface FlutterShadcnContextMenuContentProperties {}

interface FlutterShadcnContextMenuContentEvents {}

/**
 * Properties for <flutter-shadcn-context-menu-item>
 */
interface FlutterShadcnContextMenuItemProperties {
  disabled?: boolean;
}

interface FlutterShadcnContextMenuItemEvents {
  select: Event;
}

/**
 * Properties for <flutter-shadcn-context-menu-separator>
 */
interface FlutterShadcnContextMenuSeparatorProperties {}

interface FlutterShadcnContextMenuSeparatorEvents {}
