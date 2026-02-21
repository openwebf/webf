import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnDialogProps {
  /**
   * Whether the dialog is open.
   */
  open?: boolean;
  /**
   * Close when clicking outside the dialog.
   * Default: true
   */
  closeOnOutsideClick?: boolean;
  /**
   * Fired when dialog opens.
   */
  onOpen?: (event: Event) => void;
  /**
   * Fired when dialog closes.
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
export interface FlutterShadcnDialogElement extends WebFElementWithMethods<{
}> {
  /** Whether the dialog is open. */
  open?: boolean;
  /** Close when clicking outside the dialog. */
  closeOnOutsideClick?: boolean;
}
/**
 * Properties for <flutter-shadcn-dialog>
A modal dialog component.
@example
```html
<flutter-shadcn-dialog open>
  <flutter-shadcn-dialog-header>
    <flutter-shadcn-dialog-title>Are you sure?</flutter-shadcn-dialog-title>
    <flutter-shadcn-dialog-description>
      This action cannot be undone.
    </flutter-shadcn-dialog-description>
  </flutter-shadcn-dialog-header>
  <flutter-shadcn-dialog-content>
    Dialog content here.
  </flutter-shadcn-dialog-content>
  <flutter-shadcn-dialog-footer>
    <flutter-shadcn-button variant="outline">Cancel</flutter-shadcn-button>
    <flutter-shadcn-button>Continue</flutter-shadcn-button>
  </flutter-shadcn-dialog-footer>
</flutter-shadcn-dialog>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDialog
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDialog>
 * ```
 */
export const FlutterShadcnDialog = createWebFComponent<FlutterShadcnDialogElement, FlutterShadcnDialogProps>({
  tagName: 'flutter-shadcn-dialog',
  displayName: 'FlutterShadcnDialog',
  // Map props to attributes
  attributeProps: [
    'open',
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
export interface FlutterShadcnDialogHeaderProps {
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
export interface FlutterShadcnDialogHeaderElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-dialog-header>
Header slot for dialog.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDialogHeader
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDialogHeader>
 * ```
 */
export const FlutterShadcnDialogHeader = createWebFComponent<FlutterShadcnDialogHeaderElement, FlutterShadcnDialogHeaderProps>({
  tagName: 'flutter-shadcn-dialog-header',
  displayName: 'FlutterShadcnDialogHeader',
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
export interface FlutterShadcnDialogTitleProps {
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
export interface FlutterShadcnDialogTitleElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-dialog-title>
Title within dialog header.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDialogTitle
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDialogTitle>
 * ```
 */
export const FlutterShadcnDialogTitle = createWebFComponent<FlutterShadcnDialogTitleElement, FlutterShadcnDialogTitleProps>({
  tagName: 'flutter-shadcn-dialog-title',
  displayName: 'FlutterShadcnDialogTitle',
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
export interface FlutterShadcnDialogDescriptionProps {
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
export interface FlutterShadcnDialogDescriptionElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-dialog-description>
Description within dialog header.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDialogDescription
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDialogDescription>
 * ```
 */
export const FlutterShadcnDialogDescription = createWebFComponent<FlutterShadcnDialogDescriptionElement, FlutterShadcnDialogDescriptionProps>({
  tagName: 'flutter-shadcn-dialog-description',
  displayName: 'FlutterShadcnDialogDescription',
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
export interface FlutterShadcnDialogContentProps {
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
export interface FlutterShadcnDialogContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-dialog-content>
Main content slot for dialog.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDialogContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDialogContent>
 * ```
 */
export const FlutterShadcnDialogContent = createWebFComponent<FlutterShadcnDialogContentElement, FlutterShadcnDialogContentProps>({
  tagName: 'flutter-shadcn-dialog-content',
  displayName: 'FlutterShadcnDialogContent',
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
export interface FlutterShadcnDialogFooterProps {
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
export interface FlutterShadcnDialogFooterElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-dialog-footer>
Footer slot for dialog actions.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDialogFooter
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDialogFooter>
 * ```
 */
export const FlutterShadcnDialogFooter = createWebFComponent<FlutterShadcnDialogFooterElement, FlutterShadcnDialogFooterProps>({
  tagName: 'flutter-shadcn-dialog-footer',
  displayName: 'FlutterShadcnDialogFooter',
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