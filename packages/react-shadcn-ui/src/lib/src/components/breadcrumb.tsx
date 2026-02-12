import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnBreadcrumbProps {
  /**
   * Spacing between breadcrumb items.
   * @default 10
   */
  spacing?: number;
  /**
   * Custom separator between items.
   * Predefined values: 'slash', '/', 'arrow', '>', 'dash', '-', 'dot', '.', 'chevron'
   * Or any custom string to use as separator text.
   * @default chevron icon
   */
  separator?: 'slash' | 'arrow' | 'dash' | 'dot' | 'chevron' | any;
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
export interface FlutterShadcnBreadcrumbElement extends WebFElementWithMethods<{
}> {
  /** Spacing between breadcrumb items. */
  spacing?: number;
  /** Custom separator between items. */
  separator?: 'slash' | 'arrow' | 'dash' | 'dot' | 'chevron' | any;
}
/**
 * Properties for <flutter-shadcn-breadcrumb>
A breadcrumb navigation component that displays the current page location
within a navigational hierarchy.
@example
```html
<flutter-shadcn-breadcrumb>
  <flutter-shadcn-breadcrumb-item>
    <flutter-shadcn-breadcrumb-link>Home</flutter-shadcn-breadcrumb-link>
  </flutter-shadcn-breadcrumb-item>
  <flutter-shadcn-breadcrumb-item>
    <flutter-shadcn-breadcrumb-link>Components</flutter-shadcn-breadcrumb-link>
  </flutter-shadcn-breadcrumb-item>
  <flutter-shadcn-breadcrumb-item>
    <flutter-shadcn-breadcrumb-page>Breadcrumb</flutter-shadcn-breadcrumb-page>
  </flutter-shadcn-breadcrumb-item>
</flutter-shadcn-breadcrumb>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBreadcrumb
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBreadcrumb>
 * ```
 */
export const FlutterShadcnBreadcrumb = createWebFComponent<FlutterShadcnBreadcrumbElement, FlutterShadcnBreadcrumbProps>({
  tagName: 'flutter-shadcn-breadcrumb',
  displayName: 'FlutterShadcnBreadcrumb',
  // Map props to attributes
  attributeProps: [
    'spacing',
    'separator',
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
export interface FlutterShadcnBreadcrumbListProps {
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
export interface FlutterShadcnBreadcrumbListElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-breadcrumb-list>
Container for breadcrumb items (for backwards compatibility).
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBreadcrumbList
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBreadcrumbList>
 * ```
 */
export const FlutterShadcnBreadcrumbList = createWebFComponent<FlutterShadcnBreadcrumbListElement, FlutterShadcnBreadcrumbListProps>({
  tagName: 'flutter-shadcn-breadcrumb-list',
  displayName: 'FlutterShadcnBreadcrumbList',
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
export interface FlutterShadcnBreadcrumbItemProps {
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
export interface FlutterShadcnBreadcrumbItemElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-breadcrumb-item>
Individual breadcrumb item container.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBreadcrumbItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBreadcrumbItem>
 * ```
 */
export const FlutterShadcnBreadcrumbItem = createWebFComponent<FlutterShadcnBreadcrumbItemElement, FlutterShadcnBreadcrumbItemProps>({
  tagName: 'flutter-shadcn-breadcrumb-item',
  displayName: 'FlutterShadcnBreadcrumbItem',
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
export interface FlutterShadcnBreadcrumbLinkProps {
  /**
   * Link destination URL.
   */
  href?: string;
  /**
   * Fired when link is clicked.
   */
  onClick?: (event: Event) => void;
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
export interface FlutterShadcnBreadcrumbLinkElement extends WebFElementWithMethods<{
}> {
  /** Link destination URL. */
  href?: string;
}
/**
 * Properties for <flutter-shadcn-breadcrumb-link>
Clickable breadcrumb link with hover effects.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBreadcrumbLink
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBreadcrumbLink>
 * ```
 */
export const FlutterShadcnBreadcrumbLink = createWebFComponent<FlutterShadcnBreadcrumbLinkElement, FlutterShadcnBreadcrumbLinkProps>({
  tagName: 'flutter-shadcn-breadcrumb-link',
  displayName: 'FlutterShadcnBreadcrumbLink',
  // Map props to attributes
  attributeProps: [
    'href',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onClick',
      eventName: 'click',
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
export interface FlutterShadcnBreadcrumbPageProps {
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
export interface FlutterShadcnBreadcrumbPageElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-breadcrumb-page>
Current page indicator (non-clickable, highlighted text).
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBreadcrumbPage
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBreadcrumbPage>
 * ```
 */
export const FlutterShadcnBreadcrumbPage = createWebFComponent<FlutterShadcnBreadcrumbPageElement, FlutterShadcnBreadcrumbPageProps>({
  tagName: 'flutter-shadcn-breadcrumb-page',
  displayName: 'FlutterShadcnBreadcrumbPage',
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
export interface FlutterShadcnBreadcrumbSeparatorProps {
  /**
   * Size of the separator icon.
   * @default 14
   */
  size?: number;
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
export interface FlutterShadcnBreadcrumbSeparatorElement extends WebFElementWithMethods<{
}> {
  /** Size of the separator icon. */
  size?: number;
}
/**
 * Properties for <flutter-shadcn-breadcrumb-separator>
Separator between breadcrumb items (chevron icon by default).
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBreadcrumbSeparator
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBreadcrumbSeparator>
 * ```
 */
export const FlutterShadcnBreadcrumbSeparator = createWebFComponent<FlutterShadcnBreadcrumbSeparatorElement, FlutterShadcnBreadcrumbSeparatorProps>({
  tagName: 'flutter-shadcn-breadcrumb-separator',
  displayName: 'FlutterShadcnBreadcrumbSeparator',
  // Map props to attributes
  attributeProps: [
    'size',
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
export interface FlutterShadcnBreadcrumbEllipsisProps {
  /**
   * Size of the ellipsis icon.
   * @default 16
   */
  size?: number;
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
export interface FlutterShadcnBreadcrumbEllipsisElement extends WebFElementWithMethods<{
}> {
  /** Size of the ellipsis icon. */
  size?: number;
}
/**
 * Properties for <flutter-shadcn-breadcrumb-ellipsis>
Ellipsis indicator for collapsed/hidden breadcrumb sections.
@example
```html
<flutter-shadcn-breadcrumb-item>
  <flutter-shadcn-breadcrumb-ellipsis />
</flutter-shadcn-breadcrumb-item>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBreadcrumbEllipsis
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBreadcrumbEllipsis>
 * ```
 */
export const FlutterShadcnBreadcrumbEllipsis = createWebFComponent<FlutterShadcnBreadcrumbEllipsisElement, FlutterShadcnBreadcrumbEllipsisProps>({
  tagName: 'flutter-shadcn-breadcrumb-ellipsis',
  displayName: 'FlutterShadcnBreadcrumbEllipsis',
  // Map props to attributes
  attributeProps: [
    'size',
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
export interface FlutterShadcnBreadcrumbDropdownProps {
  /**
   * Whether to show the dropdown arrow icon.
   * @default true
   */
  showArrow?: boolean;
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
export interface FlutterShadcnBreadcrumbDropdownElement extends WebFElementWithMethods<{
}> {
  /** Whether to show the dropdown arrow icon. */
  showArrow?: boolean;
}
/**
 * Properties for <flutter-shadcn-breadcrumb-dropdown>
Dropdown menu for showing collapsed breadcrumb items.
@example
```html
<flutter-shadcn-breadcrumb-dropdown>
  <flutter-shadcn-breadcrumb-ellipsis />
  <flutter-shadcn-breadcrumb-dropdown-item>Documentation</flutter-shadcn-breadcrumb-dropdown-item>
  <flutter-shadcn-breadcrumb-dropdown-item>Themes</flutter-shadcn-breadcrumb-dropdown-item>
</flutter-shadcn-breadcrumb-dropdown>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBreadcrumbDropdown
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBreadcrumbDropdown>
 * ```
 */
export const FlutterShadcnBreadcrumbDropdown = createWebFComponent<FlutterShadcnBreadcrumbDropdownElement, FlutterShadcnBreadcrumbDropdownProps>({
  tagName: 'flutter-shadcn-breadcrumb-dropdown',
  displayName: 'FlutterShadcnBreadcrumbDropdown',
  // Map props to attributes
  attributeProps: [
    'showArrow',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    showArrow: 'show-arrow',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnBreadcrumbDropdownItemProps {
  /**
   * Fired when dropdown item is clicked.
   */
  onClick?: (event: Event) => void;
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
export interface FlutterShadcnBreadcrumbDropdownItemElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-breadcrumb-dropdown-item>
Individual item in a breadcrumb dropdown menu.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBreadcrumbDropdownItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBreadcrumbDropdownItem>
 * ```
 */
export const FlutterShadcnBreadcrumbDropdownItem = createWebFComponent<FlutterShadcnBreadcrumbDropdownItemElement, FlutterShadcnBreadcrumbDropdownItemProps>({
  tagName: 'flutter-shadcn-breadcrumb-dropdown-item',
  displayName: 'FlutterShadcnBreadcrumbDropdownItem',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onClick',
      eventName: 'click',
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