/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-menubar>
 *
 * A horizontal menubar with nested menus and menu items.
 *
 * @example
 * ```html
 * <flutter-shadcn-menubar>
 *   <flutter-shadcn-menubar-menu>
 *     <flutter-shadcn-menubar-trigger>File</flutter-shadcn-menubar-trigger>
 *     <flutter-shadcn-menubar-content>
 *       <flutter-shadcn-menubar-item shortcut="Cmd+N">New</flutter-shadcn-menubar-item>
 *       <flutter-shadcn-menubar-item shortcut="Cmd+O">Open</flutter-shadcn-menubar-item>
 *       <flutter-shadcn-menubar-separator></flutter-shadcn-menubar-separator>
 *       <flutter-shadcn-menubar-item>Quit</flutter-shadcn-menubar-item>
 *     </flutter-shadcn-menubar-content>
 *   </flutter-shadcn-menubar-menu>
 * </flutter-shadcn-menubar>
 * ```
 */
interface FlutterShadcnMenubarProperties {}

interface FlutterShadcnMenubarEvents {}

/**
 * Properties for <flutter-shadcn-menubar-menu>
 *
 * Container that groups a trigger and content.
 */
interface FlutterShadcnMenubarMenuProperties {}

interface FlutterShadcnMenubarMenuEvents {}

/**
 * Properties for <flutter-shadcn-menubar-trigger>
 *
 * Trigger label shown in the menubar row.
 */
interface FlutterShadcnMenubarTriggerProperties {}

interface FlutterShadcnMenubarTriggerEvents {}

/**
 * Properties for <flutter-shadcn-menubar-content>
 *
 * Popup content for a menubar menu.
 */
interface FlutterShadcnMenubarContentProperties {}

interface FlutterShadcnMenubarContentEvents {}

/**
 * Properties for <flutter-shadcn-menubar-item>
 *
 * A standard menu item.
 */
interface FlutterShadcnMenubarItemProperties {
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;

  /**
   * Keyboard shortcut label to display (for example, "Cmd+N", "Ctrl+S", "Shift+Cmd+P").
   */
  shortcut?: string;

  /**
   * Whether to apply inset styling (left padding aligned with checkbox/radio items).
   */
  inset?: boolean;
}

interface FlutterShadcnMenubarItemEvents {
  /** Fired when the item is clicked/selected. */
  click: Event;
}

/**
 * Properties for <flutter-shadcn-menubar-separator>
 *
 * Visual separator between groups of menu items.
 */
interface FlutterShadcnMenubarSeparatorProperties {}

interface FlutterShadcnMenubarSeparatorEvents {}

/**
 * Properties for <flutter-shadcn-menubar-label>
 *
 * Group label/header in menu content.
 */
interface FlutterShadcnMenubarLabelProperties {}

interface FlutterShadcnMenubarLabelEvents {}

/**
 * Properties for <flutter-shadcn-menubar-sub>
 *
 * Container for nested submenu content.
 */
interface FlutterShadcnMenubarSubProperties {}

interface FlutterShadcnMenubarSubEvents {}

/**
 * Properties for <flutter-shadcn-menubar-sub-trigger>
 *
 * Trigger element for a submenu.
 */
interface FlutterShadcnMenubarSubTriggerProperties {
  /**
   * Whether the submenu trigger is disabled.
   */
  disabled?: boolean;

  /**
   * Whether to apply inset styling.
   */
  inset?: boolean;
}

interface FlutterShadcnMenubarSubTriggerEvents {}

/**
 * Properties for <flutter-shadcn-menubar-sub-content>
 *
 * Popup content for submenu items.
 */
interface FlutterShadcnMenubarSubContentProperties {}

interface FlutterShadcnMenubarSubContentEvents {}

/**
 * Properties for <flutter-shadcn-menubar-checkbox-item>
 *
 * A menu item with a checkbox indicator.
 */
interface FlutterShadcnMenubarCheckboxItemProperties {
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;

  /**
   * Whether the checkbox is checked.
   */
  checked?: boolean;

  /**
   * Keyboard shortcut label to display.
   */
  shortcut?: string;
}

interface FlutterShadcnMenubarCheckboxItemEvents {
  /** Fired when checked state changes. */
  change: Event;
}

/**
 * Properties for <flutter-shadcn-menubar-radio-group>
 *
 * Container for radio items where only one option can be selected.
 */
interface FlutterShadcnMenubarRadioGroupProperties {
  /**
   * Currently selected radio value.
   */
  value?: string;
}

interface FlutterShadcnMenubarRadioGroupChangeEventDetail {
  value: string | null;
}

interface FlutterShadcnMenubarRadioGroupEvents {
  /** Fired when selected value changes. */
  change: CustomEvent<FlutterShadcnMenubarRadioGroupChangeEventDetail>;
}

/**
 * Properties for <flutter-shadcn-menubar-radio-item>
 *
 * A radio item inside <flutter-shadcn-menubar-radio-group>.
 */
interface FlutterShadcnMenubarRadioItemProperties {
  /**
   * Whether the item is disabled.
   */
  disabled?: boolean;

  /**
   * Value represented by this radio item.
   */
  value?: string;

  /**
   * Keyboard shortcut label to display.
   */
  shortcut?: string;
}

interface FlutterShadcnMenubarRadioItemEvents {
  /** Fired when the item is clicked/selected. */
  click: Event;
}
