/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-select>
 *
 * A dropdown select component with support for single/multiple selection and search.
 *
 * @example
 * ```html
 * <!-- Simple usage -->
 * <flutter-shadcn-select placeholder="Select a fruit" onchange="handleChange(event)">
 *   <flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
 *   <flutter-shadcn-select-item value="banana">Banana</flutter-shadcn-select-item>
 *   <flutter-shadcn-select-item value="orange">Orange</flutter-shadcn-select-item>
 * </flutter-shadcn-select>
 *
 * <!-- With trigger and content (web shadcn/ui pattern) -->
 * <flutter-shadcn-select>
 *   <flutter-shadcn-select-trigger placeholder="Select a fruit" />
 *   <flutter-shadcn-select-content>
 *     <flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
 *     <flutter-shadcn-select-item value="banana">Banana</flutter-shadcn-select-item>
 *   </flutter-shadcn-select-content>
 * </flutter-shadcn-select>
 *
 * <!-- With groups -->
 * <flutter-shadcn-select placeholder="Select a timezone">
 *   <flutter-shadcn-select-group label="North America">
 *     <flutter-shadcn-select-item value="est">Eastern Standard Time</flutter-shadcn-select-item>
 *     <flutter-shadcn-select-item value="cst">Central Standard Time</flutter-shadcn-select-item>
 *   </flutter-shadcn-select-group>
 *   <flutter-shadcn-select-group label="Europe">
 *     <flutter-shadcn-select-item value="gmt">Greenwich Mean Time</flutter-shadcn-select-item>
 *     <flutter-shadcn-select-item value="cet">Central European Time</flutter-shadcn-select-item>
 *   </flutter-shadcn-select-group>
 * </flutter-shadcn-select>
 *
 * <!-- With search -->
 * <flutter-shadcn-select searchable search-placeholder="Search frameworks...">
 *   <flutter-shadcn-select-item value="react">React</flutter-shadcn-select-item>
 *   <flutter-shadcn-select-item value="vue">Vue</flutter-shadcn-select-item>
 *   <flutter-shadcn-select-item value="angular">Angular</flutter-shadcn-select-item>
 * </flutter-shadcn-select>
 * ```
 */
interface FlutterShadcnSelectProperties {
  /**
   * Currently selected value.
   */
  value?: string;

  /**
   * Placeholder text when no value is selected.
   */
  placeholder?: string;

  /**
   * Disable the select.
   */
  disabled?: boolean;

  /**
   * Allow multiple selection.
   */
  multiple?: boolean;

  /**
   * Allow searching/filtering options.
   */
  searchable?: boolean;

  /**
   * Placeholder for search input when searchable.
   */
  searchPlaceholder?: string;

  /**
   * Allow deselecting the current selection.
   */
  allowDeselection?: boolean;

  /**
   * Whether to close the popover after selecting an option.
   * Default: true for single select, configurable for multiple.
   */
  closeOnSelect?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-select>
 */
interface FlutterShadcnSelectEvents {
  /**
   * Fired when selection changes.
   * Event detail contains { value: string }.
   */
  change: CustomEvent<{ value: string }>;
}

/**
 * Properties for <flutter-shadcn-select-trigger>
 *
 * The trigger element that displays the selected value and opens the dropdown.
 *
 * @example
 * ```html
 * <flutter-shadcn-select>
 *   <flutter-shadcn-select-trigger placeholder="Select an option" />
 *   <flutter-shadcn-select-content>
 *     ...
 *   </flutter-shadcn-select-content>
 * </flutter-shadcn-select>
 * ```
 */
interface FlutterShadcnSelectTriggerProperties {
  /**
   * Placeholder text when no value is selected.
   */
  placeholder?: string;
}

interface FlutterShadcnSelectTriggerEvents {}

/**
 * Properties for <flutter-shadcn-select-content>
 *
 * Container for the dropdown content/options.
 *
 * @example
 * ```html
 * <flutter-shadcn-select-content>
 *   <flutter-shadcn-select-item value="1">Option 1</flutter-shadcn-select-item>
 *   <flutter-shadcn-select-item value="2">Option 2</flutter-shadcn-select-item>
 * </flutter-shadcn-select-content>
 * ```
 */
interface FlutterShadcnSelectContentProperties {}

interface FlutterShadcnSelectContentEvents {}

/**
 * Properties for <flutter-shadcn-select-item>
 *
 * Individual select option.
 *
 * @example
 * ```html
 * <flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
 * <flutter-shadcn-select-item value="banana" disabled>Banana (out of stock)</flutter-shadcn-select-item>
 * ```
 */
interface FlutterShadcnSelectItemProperties {
  /**
   * Value of this option.
   */
  value: string;

  /**
   * Disable this specific option.
   */
  disabled?: boolean;
}

interface FlutterShadcnSelectItemEvents {}

/**
 * Properties for <flutter-shadcn-select-group>
 *
 * Group of select options with optional label.
 *
 * @example
 * ```html
 * <flutter-shadcn-select-group label="Fruits">
 *   <flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
 *   <flutter-shadcn-select-item value="banana">Banana</flutter-shadcn-select-item>
 * </flutter-shadcn-select-group>
 * ```
 */
interface FlutterShadcnSelectGroupProperties {
  /**
   * Label for this option group.
   */
  label?: string;
}

interface FlutterShadcnSelectGroupEvents {}

/**
 * Properties for <flutter-shadcn-select-label>
 *
 * A label/header for a section of options (not inside a group).
 *
 * @example
 * ```html
 * <flutter-shadcn-select-label>Fruits</flutter-shadcn-select-label>
 * <flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
 * ```
 */
interface FlutterShadcnSelectLabelProperties {}

interface FlutterShadcnSelectLabelEvents {}

/**
 * Properties for <flutter-shadcn-select-separator>
 *
 * Visual separator between options.
 *
 * @example
 * ```html
 * <flutter-shadcn-select-item value="1">Option 1</flutter-shadcn-select-item>
 * <flutter-shadcn-select-separator />
 * <flutter-shadcn-select-item value="2">Option 2</flutter-shadcn-select-item>
 * ```
 */
interface FlutterShadcnSelectSeparatorProperties {}

interface FlutterShadcnSelectSeparatorEvents {}
