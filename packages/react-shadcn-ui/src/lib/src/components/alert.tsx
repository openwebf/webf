import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnAlertProps {
  /**
   * Visual variant of the alert.
   * - 'default': Standard informational alert
   * - 'destructive': Red destructive/error alert
   * Default: 'default'
   */
  variant?: string;
  /**
   * Icon name to display in the alert.
   */
  icon?: string;
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
export interface FlutterShadcnAlertElement extends WebFElementWithMethods<{
}> {
  /** Visual variant of the alert. */
  variant?: string;
  /** Icon name to display in the alert. */
  icon?: string;
}
/**
 * Properties for <flutter-shadcn-alert>
An alert component for displaying important messages.
@example
```html
<flutter-shadcn-alert variant="default">
  <flutter-shadcn-alert-title>Heads up!</flutter-shadcn-alert-title>
  <flutter-shadcn-alert-description>
    You can add components to your app using the CLI.
  </flutter-shadcn-alert-description>
</flutter-shadcn-alert>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnAlert
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnAlert>
 * ```
 */
export const FlutterShadcnAlert = createWebFComponent<FlutterShadcnAlertElement, FlutterShadcnAlertProps>({
  tagName: 'flutter-shadcn-alert',
  displayName: 'FlutterShadcnAlert',
  // Map props to attributes
  attributeProps: [
    'variant',
    'icon',
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
export interface FlutterShadcnAlertTitleProps {
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
export interface FlutterShadcnAlertTitleElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-alert-title>
Title slot for the alert.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnAlertTitle
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnAlertTitle>
 * ```
 */
export const FlutterShadcnAlertTitle = createWebFComponent<FlutterShadcnAlertTitleElement, FlutterShadcnAlertTitleProps>({
  tagName: 'flutter-shadcn-alert-title',
  displayName: 'FlutterShadcnAlertTitle',
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
export interface FlutterShadcnAlertDescriptionProps {
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
export interface FlutterShadcnAlertDescriptionElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-alert-description>
Description slot for the alert.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnAlertDescription
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnAlertDescription>
 * ```
 */
export const FlutterShadcnAlertDescription = createWebFComponent<FlutterShadcnAlertDescriptionElement, FlutterShadcnAlertDescriptionProps>({
  tagName: 'flutter-shadcn-alert-description',
  displayName: 'FlutterShadcnAlertDescription',
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