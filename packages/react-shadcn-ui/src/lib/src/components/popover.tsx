import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnPopoverProps {
  /**
   * Whether the popover is open.
   */
  open?: boolean;
  /**
   * Placement of the popover.
   * Options: 'top', 'bottom', 'left', 'right'
   * Default: 'bottom'
   */
  placement?: string;
  /**
   * Close when clicking outside.
   * Default: true
   */
  closeOnOutsideClick?: boolean;
  /**
   * Fired when popover opens.
   */
  onOpen?: (event: Event) => void;
  /**
   * Fired when popover closes.
   */
  onClose?: (event: Event) => void;
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
export interface FlutterShadcnPopoverElement extends WebFElementWithMethods<{
}> {
  /** Whether the popover is open. */
  open?: boolean;
  /** Placement of the popover. */
  placement?: string;
  /** Close when clicking outside. */
  closeOnOutsideClick?: boolean;
}
/**
 * Properties for <flutter-shadcn-popover>
A floating content container that appears on trigger.
@example
```html
<flutter-shadcn-popover placement="bottom">
  <flutter-shadcn-popover-trigger>
    <flutter-shadcn-button>Open</flutter-shadcn-button>
  </flutter-shadcn-popover-trigger>
  <flutter-shadcn-popover-content>
    Popover content here.
  </flutter-shadcn-popover-content>
</flutter-shadcn-popover>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnPopover
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnPopover>
 * ```
 */
export const FlutterShadcnPopover = createWebFComponent<FlutterShadcnPopoverElement, FlutterShadcnPopoverProps>({
  tagName: 'flutter-shadcn-popover',
  displayName: 'FlutterShadcnPopover',
  // Map props to attributes
  attributeProps: [
    'open',
    'placement',
    'closeOnOutsideClick',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    closeOnOutsideClick: 'close-on-outside-click',
  },
  // Event handlers
  events: [
    {
      propName: 'onOpen',
      eventName: 'open',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
    {
      propName: 'onClose',
      eventName: 'close',
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
export interface FlutterShadcnPopoverTriggerProps {
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
export interface FlutterShadcnPopoverTriggerElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-popover-trigger>
Trigger element for the popover.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnPopoverTrigger
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnPopoverTrigger>
 * ```
 */
export const FlutterShadcnPopoverTrigger = createWebFComponent<FlutterShadcnPopoverTriggerElement, FlutterShadcnPopoverTriggerProps>({
  tagName: 'flutter-shadcn-popover-trigger',
  displayName: 'FlutterShadcnPopoverTrigger',
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
export interface FlutterShadcnPopoverContentProps {
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
export interface FlutterShadcnPopoverContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-popover-content>
Content of the popover.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnPopoverContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnPopoverContent>
 * ```
 */
export const FlutterShadcnPopoverContent = createWebFComponent<FlutterShadcnPopoverContentElement, FlutterShadcnPopoverContentProps>({
  tagName: 'flutter-shadcn-popover-content',
  displayName: 'FlutterShadcnPopoverContent',
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