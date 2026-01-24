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
   *
   * This value is updated automatically when the native menu opens/closes.
   * Setting it to `false` will close the menu.
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
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;

  /**
   * Keyboard shortcut to display (e.g., "⌘Z", "Ctrl+C").
   *
   * When the context menu is open, matching key presses will trigger the
   * item's `click` handler.
   */
  shortcut?: string;

  /**
   * Whether to use inset styling (adds left padding for alignment with checkbox/radio items).
   */
  inset?: boolean;
}

interface FlutterShadcnContextMenuItemEvents {
  /** Fired when the item is clicked. */
  click: Event;
}

/**
 * Properties for <flutter-shadcn-context-menu-separator>
 */
interface FlutterShadcnContextMenuSeparatorProperties {}

interface FlutterShadcnContextMenuSeparatorEvents {}

/**
 * Properties for <flutter-shadcn-context-menu-label>
 *
 * A label/header for grouping context menu items.
 *
 * @example
 * ```html
 * <flutter-shadcn-context-menu-label>People</flutter-shadcn-context-menu-label>
 * ```
 */
interface FlutterShadcnContextMenuLabelProperties {}

interface FlutterShadcnContextMenuLabelEvents {}

/**
 * Properties for <flutter-shadcn-context-menu-sub>
 *
 * A container for nested submenu items.
 * Submenus open on hover (mouse) and can be toggled by tap/click.
 *
 * @example
 * ```html
 * <flutter-shadcn-context-menu-sub>
 *   <flutter-shadcn-context-menu-sub-trigger>More Tools</flutter-shadcn-context-menu-sub-trigger>
 *   <flutter-shadcn-context-menu-sub-content>
 *     <flutter-shadcn-context-menu-item>Save Page As...</flutter-shadcn-context-menu-item>
 *     <flutter-shadcn-context-menu-item>Create Shortcut...</flutter-shadcn-context-menu-item>
 *   </flutter-shadcn-context-menu-sub-content>
 * </flutter-shadcn-context-menu-sub>
 * ```
 */
interface FlutterShadcnContextMenuSubProperties {}

interface FlutterShadcnContextMenuSubEvents {}

/**
 * Properties for <flutter-shadcn-context-menu-sub-trigger>
 *
 * The trigger element for a submenu.
 */
interface FlutterShadcnContextMenuSubTriggerProperties {
  /**
   * Whether the submenu trigger is disabled.
   */
  disabled?: boolean;

  /**
   * Whether to use inset styling (adds left padding for alignment).
   */
  inset?: boolean;
}

interface FlutterShadcnContextMenuSubTriggerEvents {}

/**
 * Properties for <flutter-shadcn-context-menu-sub-content>
 *
 * Container for submenu items.
 */
interface FlutterShadcnContextMenuSubContentProperties {}

interface FlutterShadcnContextMenuSubContentEvents {}

/**
 * Properties for <flutter-shadcn-context-menu-checkbox-item>
 *
 * A menu item with a checkbox indicator.
 *
 * @example
 * ```html
 * <flutter-shadcn-context-menu-checkbox-item checked>
 *   Show Bookmarks Bar
 * </flutter-shadcn-context-menu-checkbox-item>
 * ```
 */
interface FlutterShadcnContextMenuCheckboxItemProperties {
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;

  /**
   * Whether the checkbox is checked.
   */
  checked?: boolean;

  /**
   * Keyboard shortcut to display (e.g., "⌘B").
   */
  shortcut?: string;
}

interface FlutterShadcnContextMenuCheckboxItemEvents {
  /** Fired when the checked state changes. */
  change: Event;
}

/**
 * Properties for <flutter-shadcn-context-menu-radio-group>
 *
 * A group of radio items where only one can be selected.
 *
 * @example
 * ```html
 * <flutter-shadcn-context-menu-radio-group value="pedro">
 *   <flutter-shadcn-context-menu-label>People</flutter-shadcn-context-menu-label>
 *   <flutter-shadcn-context-menu-separator />
 *   <flutter-shadcn-context-menu-radio-item value="pedro">Pedro Duarte</flutter-shadcn-context-menu-radio-item>
 *   <flutter-shadcn-context-menu-radio-item value="colm">Colm Tuite</flutter-shadcn-context-menu-radio-item>
 * </flutter-shadcn-context-menu-radio-group>
 * ```
 */
interface FlutterShadcnContextMenuRadioGroupProperties {
  /**
   * The value of the currently selected radio item.
   */
  value?: string;
}

interface FlutterShadcnContextMenuRadioGroupChangeEventDetail {
  value: string | null;
}

interface FlutterShadcnContextMenuRadioGroupEvents {
  /** Fired when the selected value changes. */
  change: CustomEvent<FlutterShadcnContextMenuRadioGroupChangeEventDetail>;
}

/**
 * Properties for <flutter-shadcn-context-menu-radio-item>
 *
 * A radio-style menu item within a radio group.
 */
interface FlutterShadcnContextMenuRadioItemProperties {
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;

  /**
   * The value of this radio item.
   */
  value?: string;

  /**
   * Keyboard shortcut to display.
   */
  shortcut?: string;
}

interface FlutterShadcnContextMenuRadioItemEvents {
  /** Fired when the item is clicked. */
  click: Event;
}
