/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-dropdown-menu>
 *
 * A dropdown menu component.
 *
 * @example
 * ```html
 * <flutter-shadcn-dropdown-menu>
 *   <flutter-shadcn-dropdown-menu-trigger>
 *     <flutter-shadcn-button>Open Menu</flutter-shadcn-button>
 *   </flutter-shadcn-dropdown-menu-trigger>
 *   <flutter-shadcn-dropdown-menu-content>
 *     <flutter-shadcn-dropdown-menu-item>Profile</flutter-shadcn-dropdown-menu-item>
 *     <flutter-shadcn-dropdown-menu-item>Settings</flutter-shadcn-dropdown-menu-item>
 *     <flutter-shadcn-dropdown-menu-separator />
 *     <flutter-shadcn-dropdown-menu-item>Logout</flutter-shadcn-dropdown-menu-item>
 *   </flutter-shadcn-dropdown-menu-content>
 * </flutter-shadcn-dropdown-menu>
 * ```
 */
interface FlutterShadcnDropdownMenuProperties {
  /**
   * Whether the menu is open.
   */
  open?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-dropdown-menu>
 */
interface FlutterShadcnDropdownMenuEvents {
  /** Fired when menu opens. */
  open: Event;

  /** Fired when menu closes. */
  close: Event;
}

/**
 * Properties for <flutter-shadcn-dropdown-menu-trigger>
 * Trigger element for the menu.
 */
interface FlutterShadcnDropdownMenuTriggerProperties {}

interface FlutterShadcnDropdownMenuTriggerEvents {}

/**
 * Properties for <flutter-shadcn-dropdown-menu-content>
 * Container for menu items.
 */
interface FlutterShadcnDropdownMenuContentProperties {}

interface FlutterShadcnDropdownMenuContentEvents {}

/**
 * Properties for <flutter-shadcn-dropdown-menu-item>
 * Individual menu item.
 */
interface FlutterShadcnDropdownMenuItemProperties {
  /**
   * Disable this menu item.
   */
  disabled?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-dropdown-menu-item>
 */
interface FlutterShadcnDropdownMenuItemEvents {
  /** Fired when item is selected. */
  select: Event;
}

/**
 * Properties for <flutter-shadcn-dropdown-menu-separator>
 * Visual separator between items.
 */
interface FlutterShadcnDropdownMenuSeparatorProperties {}

interface FlutterShadcnDropdownMenuSeparatorEvents {}

/**
 * Properties for <flutter-shadcn-dropdown-menu-label>
 * Label/header for a group of items.
 */
interface FlutterShadcnDropdownMenuLabelProperties {}

interface FlutterShadcnDropdownMenuLabelEvents {}
