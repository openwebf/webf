import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnSheetProps {
  /**
   * Whether the sheet is open.
   */
  open?: boolean;
  /**
   * Side from which the sheet appears.
   * Options: 'top', 'bottom', 'left', 'right'
   * Default: 'right'
   */
  side?: string;
  /**
   * Close when clicking outside.
   * Default: true
   */
  closeOnOutsideClick?: boolean;
  /**
   * Fired when sheet opens.
   */
  onOpen?: (event: Event) => void;
  /**
   * Fired when sheet closes.
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
export interface FlutterShadcnSheetElement extends WebFElementWithMethods<{
}> {
  /** Whether the sheet is open. */
  open?: boolean;
  /** Side from which the sheet appears. */
  side?: string;
  /** Close when clicking outside. */
  closeOnOutsideClick?: boolean;
}
/**
 * Properties for <flutter-shadcn-sheet>
A slide-out panel component.
@example
```html
<flutter-shadcn-sheet side="right" open>
  <flutter-shadcn-sheet-header>
    <flutter-shadcn-sheet-title>Settings</flutter-shadcn-sheet-title>
  </flutter-shadcn-sheet-header>
  <flutter-shadcn-sheet-content>
    Sheet content here.
  </flutter-shadcn-sheet-content>
</flutter-shadcn-sheet>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSheet
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSheet>
 * ```
 */
export const FlutterShadcnSheet = createWebFComponent<FlutterShadcnSheetElement, FlutterShadcnSheetProps>({
  tagName: 'flutter-shadcn-sheet',
  displayName: 'FlutterShadcnSheet',
  // Map props to attributes
  attributeProps: [
    'open',
    'side',
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
export interface FlutterShadcnSheetHeaderProps {
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
export interface FlutterShadcnSheetHeaderElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-sheet-header>
Header slot for sheet.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSheetHeader
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSheetHeader>
 * ```
 */
export const FlutterShadcnSheetHeader = createWebFComponent<FlutterShadcnSheetHeaderElement, FlutterShadcnSheetHeaderProps>({
  tagName: 'flutter-shadcn-sheet-header',
  displayName: 'FlutterShadcnSheetHeader',
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
export interface FlutterShadcnSheetTitleProps {
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
export interface FlutterShadcnSheetTitleElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-sheet-title>
Title within sheet header.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSheetTitle
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSheetTitle>
 * ```
 */
export const FlutterShadcnSheetTitle = createWebFComponent<FlutterShadcnSheetTitleElement, FlutterShadcnSheetTitleProps>({
  tagName: 'flutter-shadcn-sheet-title',
  displayName: 'FlutterShadcnSheetTitle',
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
export interface FlutterShadcnSheetDescriptionProps {
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
export interface FlutterShadcnSheetDescriptionElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-sheet-description>
Description within sheet header.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSheetDescription
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSheetDescription>
 * ```
 */
export const FlutterShadcnSheetDescription = createWebFComponent<FlutterShadcnSheetDescriptionElement, FlutterShadcnSheetDescriptionProps>({
  tagName: 'flutter-shadcn-sheet-description',
  displayName: 'FlutterShadcnSheetDescription',
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
export interface FlutterShadcnSheetContentProps {
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
export interface FlutterShadcnSheetContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-sheet-content>
Main content slot for sheet.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSheetContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSheetContent>
 * ```
 */
export const FlutterShadcnSheetContent = createWebFComponent<FlutterShadcnSheetContentElement, FlutterShadcnSheetContentProps>({
  tagName: 'flutter-shadcn-sheet-content',
  displayName: 'FlutterShadcnSheetContent',
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
export interface FlutterShadcnSheetFooterProps {
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
export interface FlutterShadcnSheetFooterElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-sheet-footer>
Footer slot for sheet.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSheetFooter
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSheetFooter>
 * ```
 */
export const FlutterShadcnSheetFooter = createWebFComponent<FlutterShadcnSheetFooterElement, FlutterShadcnSheetFooterProps>({
  tagName: 'flutter-shadcn-sheet-footer',
  displayName: 'FlutterShadcnSheetFooter',
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