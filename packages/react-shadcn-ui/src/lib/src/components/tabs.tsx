import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnTabsProps {
  /**
   * Currently active tab value.
   */
  value?: string;
  /**
   * Default tab value (uncontrolled mode).
   */
  defaultValue?: string;
  /**
   * Fired when active tab changes.
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
export interface FlutterShadcnTabsElement extends WebFElementWithMethods<{
}> {
  /** Currently active tab value. */
  value?: string;
  /** Default tab value (uncontrolled mode). */
  defaultValue?: string;
}
/**
 * Properties for <flutter-shadcn-tabs>
A tabbed interface component.
@example
```html
<flutter-shadcn-tabs value="account">
  <flutter-shadcn-tabs-list>
    <flutter-shadcn-tabs-trigger value="account">Account</flutter-shadcn-tabs-trigger>
    <flutter-shadcn-tabs-trigger value="password">Password</flutter-shadcn-tabs-trigger>
  </flutter-shadcn-tabs-list>
  <flutter-shadcn-tabs-content value="account">Account content here.</flutter-shadcn-tabs-content>
  <flutter-shadcn-tabs-content value="password">Password content here.</flutter-shadcn-tabs-content>
</flutter-shadcn-tabs>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnTabs
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnTabs>
 * ```
 */
export const FlutterShadcnTabs = createWebFComponent<FlutterShadcnTabsElement, FlutterShadcnTabsProps>({
  tagName: 'flutter-shadcn-tabs',
  displayName: 'FlutterShadcnTabs',
  // Map props to attributes
  attributeProps: [
    'value',
    'defaultValue',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    defaultValue: 'default-value',
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
export interface FlutterShadcnTabsListProps {
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
export interface FlutterShadcnTabsListElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-tabs-list>
Container for tab triggers.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnTabsList
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnTabsList>
 * ```
 */
export const FlutterShadcnTabsList = createWebFComponent<FlutterShadcnTabsListElement, FlutterShadcnTabsListProps>({
  tagName: 'flutter-shadcn-tabs-list',
  displayName: 'FlutterShadcnTabsList',
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
export interface FlutterShadcnTabsTriggerProps {
  /**
   * Value identifier for this tab.
   */
  value: string;
  /**
   * Disable this tab.
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
export interface FlutterShadcnTabsTriggerElement extends WebFElementWithMethods<{
}> {
  /** Value identifier for this tab. */
  value: string;
  /** Disable this tab. */
  disabled?: boolean;
}
/**
 * Properties for <flutter-shadcn-tabs-trigger>
Individual tab trigger button.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnTabsTrigger
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnTabsTrigger>
 * ```
 */
export const FlutterShadcnTabsTrigger = createWebFComponent<FlutterShadcnTabsTriggerElement, FlutterShadcnTabsTriggerProps>({
  tagName: 'flutter-shadcn-tabs-trigger',
  displayName: 'FlutterShadcnTabsTrigger',
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
export interface FlutterShadcnTabsContentProps {
  /**
   * Value identifier matching a trigger.
   */
  value: string;
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
export interface FlutterShadcnTabsContentElement extends WebFElementWithMethods<{
}> {
  /** Value identifier matching a trigger. */
  value: string;
}
/**
 * Properties for <flutter-shadcn-tabs-content>
Content panel for a tab.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnTabsContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnTabsContent>
 * ```
 */
export const FlutterShadcnTabsContent = createWebFComponent<FlutterShadcnTabsContentElement, FlutterShadcnTabsContentProps>({
  tagName: 'flutter-shadcn-tabs-content',
  displayName: 'FlutterShadcnTabsContent',
  // Map props to attributes
  attributeProps: [
    'value',
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