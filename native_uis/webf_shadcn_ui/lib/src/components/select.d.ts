/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-select>
 *
 * A dropdown select component.
 *
 * @example
 * ```html
 * <flutter-shadcn-select value="apple" placeholder="Select a fruit" onchange="handleChange(event)">
 *   <flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
 *   <flutter-shadcn-select-item value="banana">Banana</flutter-shadcn-select-item>
 *   <flutter-shadcn-select-item value="orange">Orange</flutter-shadcn-select-item>
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
  'search-placeholder'?: string;
}

/**
 * Events emitted by <flutter-shadcn-select>
 */
interface FlutterShadcnSelectEvents {
  /** Fired when selection changes. */
  change: Event;
}

/**
 * Properties for <flutter-shadcn-select-item>
 *
 * Individual select option.
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
 */
interface FlutterShadcnSelectGroupProperties {
  /**
   * Label for this option group.
   */
  label?: string;
}

interface FlutterShadcnSelectGroupEvents {}

/**
 * Properties for <flutter-shadcn-select-separator>
 *
 * Visual separator between options.
 */
interface FlutterShadcnSelectSeparatorProperties {}

interface FlutterShadcnSelectSeparatorEvents {}
