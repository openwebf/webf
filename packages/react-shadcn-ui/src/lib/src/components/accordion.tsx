import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnAccordionProps {
  /**
   * Selection type.
   * - 'single': Only one item can be expanded
   * - 'multiple': Multiple items can be expanded
   * Default: 'single'
   */
  type?: string;
  /**
   * Currently expanded item(s) value(s).
   * For single type: string, for multiple type: comma-separated string
   */
  value?: string;
  /**
   * Allow collapsing all items in single mode.
   * Default: true
   */
  collapsible?: boolean;
  /**
   * change event handler
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
export interface FlutterShadcnAccordionElement extends WebFElementWithMethods<{
}> {
  /** Selection type. */
  type?: string;
  /** Currently expanded item(s) value(s). */
  value?: string;
  /** Allow collapsing all items in single mode. */
  collapsible?: boolean;
}
/**
 * Properties for <flutter-shadcn-accordion>
A collapsible accordion component.
@example
```html
<flutter-shadcn-accordion type="single">
  <flutter-shadcn-accordion-item value="item-1">
    <flutter-shadcn-accordion-trigger>Is it accessible?</flutter-shadcn-accordion-trigger>
    <flutter-shadcn-accordion-content>Yes. It adheres to the WAI-ARIA design pattern.</flutter-shadcn-accordion-content>
  </flutter-shadcn-accordion-item>
</flutter-shadcn-accordion>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnAccordion
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnAccordion>
 * ```
 */
export const FlutterShadcnAccordion = createWebFComponent<FlutterShadcnAccordionElement, FlutterShadcnAccordionProps>({
  tagName: 'flutter-shadcn-accordion',
  displayName: 'FlutterShadcnAccordion',
  // Map props to attributes
  attributeProps: [
    'type',
    'value',
    'collapsible',
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
export interface FlutterShadcnAccordionItemProps {
  /**
   * value property
   */
  value: string;
  /**
   * disabled property
   * @default undefined
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
export interface FlutterShadcnAccordionItemElement extends WebFElementWithMethods<{
}> {
  value: string;
  disabled?: boolean;
}
/**
 * FlutterShadcnAccordionItem - WebF FlutterShadcnAccordionItem component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnAccordionItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnAccordionItem>
 * ```
 */
export const FlutterShadcnAccordionItem = createWebFComponent<FlutterShadcnAccordionItemElement, FlutterShadcnAccordionItemProps>({
  tagName: 'flutter-shadcn-accordion-item',
  displayName: 'FlutterShadcnAccordionItem',
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
export interface FlutterShadcnAccordionTriggerProps {
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
export interface FlutterShadcnAccordionTriggerElement extends WebFElementWithMethods<{
}> {
}
/**
 * FlutterShadcnAccordionTrigger - WebF FlutterShadcnAccordionTrigger component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnAccordionTrigger
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnAccordionTrigger>
 * ```
 */
export const FlutterShadcnAccordionTrigger = createWebFComponent<FlutterShadcnAccordionTriggerElement, FlutterShadcnAccordionTriggerProps>({
  tagName: 'flutter-shadcn-accordion-trigger',
  displayName: 'FlutterShadcnAccordionTrigger',
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
export interface FlutterShadcnAccordionContentProps {
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
export interface FlutterShadcnAccordionContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * FlutterShadcnAccordionContent - WebF FlutterShadcnAccordionContent component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnAccordionContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnAccordionContent>
 * ```
 */
export const FlutterShadcnAccordionContent = createWebFComponent<FlutterShadcnAccordionContentElement, FlutterShadcnAccordionContentProps>({
  tagName: 'flutter-shadcn-accordion-content',
  displayName: 'FlutterShadcnAccordionContent',
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