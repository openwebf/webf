import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnDropdownMenuProps {
  /**
   * Whether the menu is open.
   */
  open?: boolean;
  /**
   * Fired when menu opens.
   */
  onOpen?: (event: Event) => void;
  /**
   * Fired when menu closes.
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
export interface FlutterShadcnDropdownMenuElement extends WebFElementWithMethods<{
}> {
  /** Whether the menu is open. */
  open?: boolean;
}
/**
 * Properties for <flutter-shadcn-dropdown-menu>
A dropdown menu component.
@example
```html
<flutter-shadcn-dropdown-menu>
  <flutter-shadcn-dropdown-menu-trigger>
    <flutter-shadcn-button>Open Menu</flutter-shadcn-button>
  </flutter-shadcn-dropdown-menu-trigger>
  <flutter-shadcn-dropdown-menu-content>
    <flutter-shadcn-dropdown-menu-item>Profile</flutter-shadcn-dropdown-menu-item>
    <flutter-shadcn-dropdown-menu-item>Settings</flutter-shadcn-dropdown-menu-item>
    <flutter-shadcn-dropdown-menu-separator />
    <flutter-shadcn-dropdown-menu-item>Logout</flutter-shadcn-dropdown-menu-item>
  </flutter-shadcn-dropdown-menu-content>
</flutter-shadcn-dropdown-menu>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDropdownMenu
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDropdownMenu>
 * ```
 */
export const FlutterShadcnDropdownMenu = createWebFComponent<FlutterShadcnDropdownMenuElement, FlutterShadcnDropdownMenuProps>({
  tagName: 'flutter-shadcn-dropdown-menu',
  displayName: 'FlutterShadcnDropdownMenu',
  // Map props to attributes
  attributeProps: [
    'open',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
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
export interface FlutterShadcnDropdownMenuTriggerProps {
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
export interface FlutterShadcnDropdownMenuTriggerElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-dropdown-menu-trigger>
Trigger element for the menu.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDropdownMenuTrigger
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDropdownMenuTrigger>
 * ```
 */
export const FlutterShadcnDropdownMenuTrigger = createWebFComponent<FlutterShadcnDropdownMenuTriggerElement, FlutterShadcnDropdownMenuTriggerProps>({
  tagName: 'flutter-shadcn-dropdown-menu-trigger',
  displayName: 'FlutterShadcnDropdownMenuTrigger',
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
export interface FlutterShadcnDropdownMenuContentProps {
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
export interface FlutterShadcnDropdownMenuContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-dropdown-menu-content>
Container for menu items.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDropdownMenuContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDropdownMenuContent>
 * ```
 */
export const FlutterShadcnDropdownMenuContent = createWebFComponent<FlutterShadcnDropdownMenuContentElement, FlutterShadcnDropdownMenuContentProps>({
  tagName: 'flutter-shadcn-dropdown-menu-content',
  displayName: 'FlutterShadcnDropdownMenuContent',
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
export interface FlutterShadcnDropdownMenuItemProps {
  /**
   * Disable this menu item.
   */
  disabled?: boolean;
  /**
   * Fired when item is selected.
   */
  onSelect?: (event: Event) => void;
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
export interface FlutterShadcnDropdownMenuItemElement extends WebFElementWithMethods<{
}> {
  /** Disable this menu item. */
  disabled?: boolean;
}
/**
 * Properties for <flutter-shadcn-dropdown-menu-item>
Individual menu item.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDropdownMenuItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDropdownMenuItem>
 * ```
 */
export const FlutterShadcnDropdownMenuItem = createWebFComponent<FlutterShadcnDropdownMenuItemElement, FlutterShadcnDropdownMenuItemProps>({
  tagName: 'flutter-shadcn-dropdown-menu-item',
  displayName: 'FlutterShadcnDropdownMenuItem',
  // Map props to attributes
  attributeProps: [
    'disabled',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onSelect',
      eventName: 'select',
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
export interface FlutterShadcnDropdownMenuSeparatorProps {
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
export interface FlutterShadcnDropdownMenuSeparatorElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-dropdown-menu-separator>
Visual separator between items.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDropdownMenuSeparator
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDropdownMenuSeparator>
 * ```
 */
export const FlutterShadcnDropdownMenuSeparator = createWebFComponent<FlutterShadcnDropdownMenuSeparatorElement, FlutterShadcnDropdownMenuSeparatorProps>({
  tagName: 'flutter-shadcn-dropdown-menu-separator',
  displayName: 'FlutterShadcnDropdownMenuSeparator',
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
export interface FlutterShadcnDropdownMenuLabelProps {
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
export interface FlutterShadcnDropdownMenuLabelElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-dropdown-menu-label>
Label/header for a group of items.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDropdownMenuLabel
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDropdownMenuLabel>
 * ```
 */
export const FlutterShadcnDropdownMenuLabel = createWebFComponent<FlutterShadcnDropdownMenuLabelElement, FlutterShadcnDropdownMenuLabelProps>({
  tagName: 'flutter-shadcn-dropdown-menu-label',
  displayName: 'FlutterShadcnDropdownMenuLabel',
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