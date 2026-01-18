/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-combobox>
 *
 * A searchable dropdown with autocomplete functionality.
 *
 * @example
 * ```html
 * <flutter-shadcn-combobox
 *   value="react"
 *   placeholder="Select framework..."
 *   search-placeholder="Search frameworks..."
 *   onchange="handleChange(event)"
 * >
 *   <flutter-shadcn-combobox-item value="react">React</flutter-shadcn-combobox-item>
 *   <flutter-shadcn-combobox-item value="vue">Vue</flutter-shadcn-combobox-item>
 *   <flutter-shadcn-combobox-item value="angular">Angular</flutter-shadcn-combobox-item>
 * </flutter-shadcn-combobox>
 * ```
 */
interface FlutterShadcnComboboxProperties {
  /**
   * Currently selected value.
   */
  value?: string;

  /**
   * Placeholder text when no value is selected.
   */
  placeholder?: string;

  /**
   * Placeholder for the search input.
   */
  'search-placeholder'?: string;

  /**
   * Text shown when no results match the search.
   */
  'empty-text'?: string;

  /**
   * Disable the combobox.
   */
  disabled?: boolean;

  /**
   * Allow clearing the selection.
   */
  clearable?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-combobox>
 */
interface FlutterShadcnComboboxEvents {
  /** Fired when selection changes. */
  change: Event;

  /** Fired when search query changes. */
  search: Event;
}

/**
 * Properties for <flutter-shadcn-combobox-item>
 *
 * Individual combobox option.
 */
interface FlutterShadcnComboboxItemProperties {
  /**
   * Value of this option.
   */
  value: string;

  /**
   * Disable this specific option.
   */
  disabled?: boolean;
}

interface FlutterShadcnComboboxItemEvents {}
