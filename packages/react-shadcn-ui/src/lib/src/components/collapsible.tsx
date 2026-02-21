import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnCollapsibleProps {
  /**
   * Whether the section is expanded.
   */
  open?: boolean;
  /**
   * Disable the collapsible.
   */
  disabled?: boolean;
  /**
   * Fired when open state changes.
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
export interface FlutterShadcnCollapsibleElement extends WebFElementWithMethods<{
}> {
  /** Whether the section is expanded. */
  open?: boolean;
  /** Disable the collapsible. */
  disabled?: boolean;
}
/**
 * Properties for <flutter-shadcn-collapsible>
A collapsible section.
@example
```html
<flutter-shadcn-collapsible open>
  <flutter-shadcn-collapsible-trigger>
    <span>Toggle</span>
  </flutter-shadcn-collapsible-trigger>
  <flutter-shadcn-collapsible-content>
    Hidden content here
  </flutter-shadcn-collapsible-content>
</flutter-shadcn-collapsible>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCollapsible
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCollapsible>
 * ```
 */
export const FlutterShadcnCollapsible = createWebFComponent<FlutterShadcnCollapsibleElement, FlutterShadcnCollapsibleProps>({
  tagName: 'flutter-shadcn-collapsible',
  displayName: 'FlutterShadcnCollapsible',
  // Map props to attributes
  attributeProps: [
    'open',
    'disabled',
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
export interface FlutterShadcnCollapsibleTriggerProps {
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
export interface FlutterShadcnCollapsibleTriggerElement extends WebFElementWithMethods<{
}> {
}
/**
 * FlutterShadcnCollapsibleTrigger - WebF FlutterShadcnCollapsibleTrigger component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCollapsibleTrigger
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCollapsibleTrigger>
 * ```
 */
export const FlutterShadcnCollapsibleTrigger = createWebFComponent<FlutterShadcnCollapsibleTriggerElement, FlutterShadcnCollapsibleTriggerProps>({
  tagName: 'flutter-shadcn-collapsible-trigger',
  displayName: 'FlutterShadcnCollapsibleTrigger',
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
export interface FlutterShadcnCollapsibleContentProps {
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
export interface FlutterShadcnCollapsibleContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * FlutterShadcnCollapsibleContent - WebF FlutterShadcnCollapsibleContent component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCollapsibleContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCollapsibleContent>
 * ```
 */
export const FlutterShadcnCollapsibleContent = createWebFComponent<FlutterShadcnCollapsibleContentElement, FlutterShadcnCollapsibleContentProps>({
  tagName: 'flutter-shadcn-collapsible-content',
  displayName: 'FlutterShadcnCollapsibleContent',
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