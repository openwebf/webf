import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnSelectProps {
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
  /**
   * Fired when selection changes.
   * Event detail contains { value: string }.
   */
  onChange?: (event: CustomEvent<{ value: string }>) => void;
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
export interface FlutterShadcnSelectElement extends WebFElementWithMethods<{
}> {
  /** Currently selected value. */
  value?: string;
  /** Placeholder text when no value is selected. */
  placeholder?: string;
  /** Disable the select. */
  disabled?: boolean;
  /** Allow multiple selection. */
  multiple?: boolean;
  /** Allow searching/filtering options. */
  searchable?: boolean;
  /** Placeholder for search input when searchable. */
  searchPlaceholder?: string;
  /** Allow deselecting the current selection. */
  allowDeselection?: boolean;
  /** Whether to close the popover after selecting an option. */
  closeOnSelect?: boolean;
}
/**
 * Properties for <flutter-shadcn-select>
A dropdown select component with support for single/multiple selection and search.
@example
```html
<!-- Simple usage -->
<flutter-shadcn-select placeholder="Select a fruit" onchange="handleChange(event)">
  <flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
  <flutter-shadcn-select-item value="banana">Banana</flutter-shadcn-select-item>
  <flutter-shadcn-select-item value="orange">Orange</flutter-shadcn-select-item>
</flutter-shadcn-select>
<!-- With trigger and content (web shadcn/ui pattern) -->
<flutter-shadcn-select>
  <flutter-shadcn-select-trigger placeholder="Select a fruit" />
  <flutter-shadcn-select-content>
    <flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
    <flutter-shadcn-select-item value="banana">Banana</flutter-shadcn-select-item>
  </flutter-shadcn-select-content>
</flutter-shadcn-select>
<!-- With groups -->
<flutter-shadcn-select placeholder="Select a timezone">
  <flutter-shadcn-select-group label="North America">
    <flutter-shadcn-select-item value="est">Eastern Standard Time</flutter-shadcn-select-item>
    <flutter-shadcn-select-item value="cst">Central Standard Time</flutter-shadcn-select-item>
  </flutter-shadcn-select-group>
  <flutter-shadcn-select-group label="Europe">
    <flutter-shadcn-select-item value="gmt">Greenwich Mean Time</flutter-shadcn-select-item>
    <flutter-shadcn-select-item value="cet">Central European Time</flutter-shadcn-select-item>
  </flutter-shadcn-select-group>
</flutter-shadcn-select>
<!-- With search -->
<flutter-shadcn-select searchable search-placeholder="Search frameworks...">
  <flutter-shadcn-select-item value="react">React</flutter-shadcn-select-item>
  <flutter-shadcn-select-item value="vue">Vue</flutter-shadcn-select-item>
  <flutter-shadcn-select-item value="angular">Angular</flutter-shadcn-select-item>
</flutter-shadcn-select>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSelect
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSelect>
 * ```
 */
export const FlutterShadcnSelect = createWebFComponent<FlutterShadcnSelectElement, FlutterShadcnSelectProps>({
  tagName: 'flutter-shadcn-select',
  displayName: 'FlutterShadcnSelect',
  // Map props to attributes
  attributeProps: [
    'value',
    'placeholder',
    'disabled',
    'multiple',
    'searchable',
    'searchPlaceholder',
    'allowDeselection',
    'closeOnSelect',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    searchPlaceholder: 'search-placeholder',
    allowDeselection: 'allow-deselection',
    closeOnSelect: 'close-on-select',
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: CustomEvent<{ value: string }>) => void) => (event: Event) => {
        callback(event as CustomEvent<{ value: string }>);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnSelectTriggerProps {
  /**
   * Placeholder text when no value is selected.
   */
  placeholder?: string;
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
export interface FlutterShadcnSelectTriggerElement extends WebFElementWithMethods<{
}> {
  /** Placeholder text when no value is selected. */
  placeholder?: string;
}
/**
 * Properties for <flutter-shadcn-select-trigger>
The trigger element that displays the selected value and opens the dropdown.
@example
```html
<flutter-shadcn-select>
  <flutter-shadcn-select-trigger placeholder="Select an option" />
  <flutter-shadcn-select-content>
    ...
  </flutter-shadcn-select-content>
</flutter-shadcn-select>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSelectTrigger
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSelectTrigger>
 * ```
 */
export const FlutterShadcnSelectTrigger = createWebFComponent<FlutterShadcnSelectTriggerElement, FlutterShadcnSelectTriggerProps>({
  tagName: 'flutter-shadcn-select-trigger',
  displayName: 'FlutterShadcnSelectTrigger',
  // Map props to attributes
  attributeProps: [
    'placeholder',
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
export interface FlutterShadcnSelectContentProps {
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
export interface FlutterShadcnSelectContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-select-content>
Container for the dropdown content/options.
@example
```html
<flutter-shadcn-select-content>
  <flutter-shadcn-select-item value="1">Option 1</flutter-shadcn-select-item>
  <flutter-shadcn-select-item value="2">Option 2</flutter-shadcn-select-item>
</flutter-shadcn-select-content>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSelectContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSelectContent>
 * ```
 */
export const FlutterShadcnSelectContent = createWebFComponent<FlutterShadcnSelectContentElement, FlutterShadcnSelectContentProps>({
  tagName: 'flutter-shadcn-select-content',
  displayName: 'FlutterShadcnSelectContent',
  // Map props to attributes
  attributeProps: [
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
export interface FlutterShadcnSelectItemProps {
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
export interface FlutterShadcnSelectItemElement extends WebFElementWithMethods<{
}> {
  /** Value of this option. */
  value: string;
  /** Disable this specific option. */
  disabled?: boolean;
}
/**
 * Properties for <flutter-shadcn-select-item>
Individual select option.
@example
```html
<flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
<flutter-shadcn-select-item value="banana" disabled>Banana (out of stock)</flutter-shadcn-select-item>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSelectItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSelectItem>
 * ```
 */
export const FlutterShadcnSelectItem = createWebFComponent<FlutterShadcnSelectItemElement, FlutterShadcnSelectItemProps>({
  tagName: 'flutter-shadcn-select-item',
  displayName: 'FlutterShadcnSelectItem',
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
export interface FlutterShadcnSelectGroupProps {
  /**
   * Label for this option group.
   */
  label?: string;
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
export interface FlutterShadcnSelectGroupElement extends WebFElementWithMethods<{
}> {
  /** Label for this option group. */
  label?: string;
}
/**
 * Properties for <flutter-shadcn-select-group>
Group of select options with optional label.
@example
```html
<flutter-shadcn-select-group label="Fruits">
  <flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
  <flutter-shadcn-select-item value="banana">Banana</flutter-shadcn-select-item>
</flutter-shadcn-select-group>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSelectGroup
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSelectGroup>
 * ```
 */
export const FlutterShadcnSelectGroup = createWebFComponent<FlutterShadcnSelectGroupElement, FlutterShadcnSelectGroupProps>({
  tagName: 'flutter-shadcn-select-group',
  displayName: 'FlutterShadcnSelectGroup',
  // Map props to attributes
  attributeProps: [
    'label',
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
export interface FlutterShadcnSelectLabelProps {
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
export interface FlutterShadcnSelectLabelElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-select-label>
A label/header for a section of options (not inside a group).
@example
```html
<flutter-shadcn-select-label>Fruits</flutter-shadcn-select-label>
<flutter-shadcn-select-item value="apple">Apple</flutter-shadcn-select-item>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSelectLabel
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSelectLabel>
 * ```
 */
export const FlutterShadcnSelectLabel = createWebFComponent<FlutterShadcnSelectLabelElement, FlutterShadcnSelectLabelProps>({
  tagName: 'flutter-shadcn-select-label',
  displayName: 'FlutterShadcnSelectLabel',
  // Map props to attributes
  attributeProps: [
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
export interface FlutterShadcnSelectSeparatorProps {
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
export interface FlutterShadcnSelectSeparatorElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-select-separator>
Visual separator between options.
@example
```html
<flutter-shadcn-select-item value="1">Option 1</flutter-shadcn-select-item>
<flutter-shadcn-select-separator />
<flutter-shadcn-select-item value="2">Option 2</flutter-shadcn-select-item>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSelectSeparator
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSelectSeparator>
 * ```
 */
export const FlutterShadcnSelectSeparator = createWebFComponent<FlutterShadcnSelectSeparatorElement, FlutterShadcnSelectSeparatorProps>({
  tagName: 'flutter-shadcn-select-separator',
  displayName: 'FlutterShadcnSelectSeparator',
  // Map props to attributes
  attributeProps: [
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