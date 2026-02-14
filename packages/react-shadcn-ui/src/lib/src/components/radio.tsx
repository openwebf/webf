import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnRadioProps {
  /**
   * Currently selected value.
   */
  value?: string;
  /**
   * Disable all radio items.
   */
  disabled?: boolean;
  /**
   * Orientation of the radio group.
   * Options: 'horizontal', 'vertical'
   * Default: 'vertical'
   */
  orientation?: string;
  /**
   * Fired when selection changes.
   */
  onChange?: (event: Event) => void;
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
export interface FlutterShadcnRadioElement extends WebFElementWithMethods<{
}> {
  /** Currently selected value. */
  value?: string;
  /** Disable all radio items. */
  disabled?: boolean;
  /** Orientation of the radio group. */
  orientation?: string;
}
/**
 * Properties for <flutter-shadcn-radio>
Container for radio button groups.
@example
```html
<flutter-shadcn-radio value="option1" onchange="handleChange(event)">
  <flutter-shadcn-radio-item value="option1">Option 1</flutter-shadcn-radio-item>
  <flutter-shadcn-radio-item value="option2">Option 2</flutter-shadcn-radio-item>
</flutter-shadcn-radio>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnRadio
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnRadio>
 * ```
 */
export const FlutterShadcnRadio = createWebFComponent<FlutterShadcnRadioElement, FlutterShadcnRadioProps>({
  tagName: 'flutter-shadcn-radio',
  displayName: 'FlutterShadcnRadio',
  // Map props to attributes
  attributeProps: [
    'value',
    'disabled',
    'orientation',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
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
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnRadioItemProps {
  /**
   * Value of this radio option.
   */
  value: string;
  /**
   * Disable this specific radio item.
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
export interface FlutterShadcnRadioItemElement extends WebFElementWithMethods<{
}> {
  /** Value of this radio option. */
  value: string;
  /** Disable this specific radio item. */
  disabled?: boolean;
}
/**
 * Properties for <flutter-shadcn-radio-item>
Individual radio button option.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnRadioItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnRadioItem>
 * ```
 */
export const FlutterShadcnRadioItem = createWebFComponent<FlutterShadcnRadioItemElement, FlutterShadcnRadioItemProps>({
  tagName: 'flutter-shadcn-radio-item',
  displayName: 'FlutterShadcnRadioItem',
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