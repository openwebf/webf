import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnRadioGroupProps {
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
export interface FlutterShadcnRadioGroupElement extends WebFElementWithMethods<{
}> {
  /** Currently selected value. */
  value?: string;
  /** Disable all radio items. */
  disabled?: boolean;
  /** Orientation of the radio group. */
  orientation?: string;
}
/**
 * Properties for <flutter-shadcn-radio-group>
 * Container for radio button groups.
 * @example
 * ```html
 * <flutter-shadcn-radio-group value="option1" onchange="handleChange(event)">
 *   <flutter-shadcn-radio-group-item value="option1">Option 1</flutter-shadcn-radio-group-item>
 *   <flutter-shadcn-radio-group-item value="option2">Option 2</flutter-shadcn-radio-group-item>
 * </flutter-shadcn-radio-group>
 * ```
 *
 * @example
 * ```tsx
 *
 * <FlutterShadcnRadioGroup
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnRadioGroup>
 * ```
 */
export const FlutterShadcnRadioGroup = createWebFComponent<FlutterShadcnRadioGroupElement, FlutterShadcnRadioGroupProps>({
  tagName: 'flutter-shadcn-radio-group',
  displayName: 'FlutterShadcnRadioGroup',
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
export interface FlutterShadcnRadioGroupItemProps {
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
export interface FlutterShadcnRadioGroupItemElement extends WebFElementWithMethods<{
}> {
  /** Value of this radio option. */
  value: string;
  /** Disable this specific radio item. */
  disabled?: boolean;
}
/**
 * Properties for <flutter-shadcn-radio-group-item>
 * Individual radio button option.
 *
 * @example
 * ```tsx
 *
 * <FlutterShadcnRadioGroupItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnRadioGroupItem>
 * ```
 */
export const FlutterShadcnRadioGroupItem = createWebFComponent<FlutterShadcnRadioGroupItemElement, FlutterShadcnRadioGroupItemProps>({
  tagName: 'flutter-shadcn-radio-group-item',
  displayName: 'FlutterShadcnRadioGroupItem',
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
