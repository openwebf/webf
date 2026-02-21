import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnComboboxProps {
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
  searchPlaceholder?: string;
  /**
   * Text shown when no results match the search.
   */
  emptyText?: string;
  /**
   * Disable the combobox.
   */
  disabled?: boolean;
  /**
   * Allow clearing the selection.
   */
  clearable?: boolean;
  /**
   * Fired when selection changes.
   */
  onChange?: (event: Event) => void;
  /**
   * Fired when search query changes.
   */
  onSearch?: (event: Event) => void;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnComboboxElement extends WebFElementWithMethods<{
}> {
  /** Currently selected value. */
  value?: string;
  /** Placeholder text when no value is selected. */
  placeholder?: string;
  /** Placeholder for the search input. */
  searchPlaceholder?: string;
  /** Text shown when no results match the search. */
  emptyText?: string;
  /** Disable the combobox. */
  disabled?: boolean;
  /** Allow clearing the selection. */
  clearable?: boolean;
}
/**
 * Properties for <flutter-shadcn-combobox>
A searchable dropdown with autocomplete functionality.
@example
```html
<flutter-shadcn-combobox
  value="react"
  placeholder="Select framework..."
  search-placeholder="Search frameworks..."
  onchange="handleChange(event)"
>
  <flutter-shadcn-combobox-item value="react">React</flutter-shadcn-combobox-item>
  <flutter-shadcn-combobox-item value="vue">Vue</flutter-shadcn-combobox-item>
  <flutter-shadcn-combobox-item value="angular">Angular</flutter-shadcn-combobox-item>
</flutter-shadcn-combobox>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCombobox
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCombobox>
 * ```
 */
export const FlutterShadcnCombobox = createWebFComponent<FlutterShadcnComboboxElement, FlutterShadcnComboboxProps>({
  tagName: 'flutter-shadcn-combobox',
  displayName: 'FlutterShadcnCombobox',
  // Map props to attributes
  attributeProps: [
    'value',
    'placeholder',
    'searchPlaceholder',
    'emptyText',
    'disabled',
    'clearable',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    searchPlaceholder: 'search-placeholder',
    emptyText: 'empty-text',
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
    {
      propName: 'onSearch',
      eventName: 'search',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnComboboxItemProps {
  /**
   * Value of this option.
   */
  value: string;
  /**
   * Disable this specific option.
   */
  disabled?: boolean;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnComboboxItemElement extends WebFElementWithMethods<{
}> {
  /** Value of this option. */
  value: string;
  /** Disable this specific option. */
  disabled?: boolean;
}
/**
 * Properties for <flutter-shadcn-combobox-item>
Individual combobox option.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnComboboxItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnComboboxItem>
 * ```
 */
export const FlutterShadcnComboboxItem = createWebFComponent<FlutterShadcnComboboxItemElement, FlutterShadcnComboboxItemProps>({
  tagName: 'flutter-shadcn-combobox-item',
  displayName: 'FlutterShadcnComboboxItem',
  // Map props to attributes
  attributeProps: [
    'value',
    'disabled',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});