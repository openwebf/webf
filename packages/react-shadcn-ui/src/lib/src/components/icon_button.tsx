import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnIconButtonProps {
  /**
   * Visual variant of the icon button.
   * - 'primary': Primary filled button (default)
   * - 'secondary': Secondary muted button
   * - 'destructive': Red destructive action button
   * - 'outline': Bordered outline button
   * - 'ghost': Transparent with hover effect
   * 
   * Note: Unlike regular buttons, icon buttons do not support the 'link' variant.
   * 
   * Default: 'primary'
   */
  variant?: 'primary' | 'secondary' | 'destructive' | 'outline' | 'ghost';
  /**
   * Name of the Lucide icon to display.
   * 
   * Common icons include:
   * - Navigation: 'chevron-right', 'chevron-left', 'arrow-right', 'arrow-left'
   * - Actions: 'plus', 'minus', 'x', 'check', 'search', 'edit', 'trash', 'copy', 'share'
   * - Objects: 'rocket', 'heart', 'star', 'home', 'user', 'mail', 'calendar', 'file'
   * - UI: 'menu', 'ellipsis', 'more-vertical', 'grid', 'list', 'filter'
   * - Status: 'info', 'alert-circle', 'help', 'check-circle', 'x-circle'
   * - Formatting: 'bold', 'italic', 'underline', 'align-left', 'align-center', 'align-right'
   * 
   * @example "rocket"
   * @example "plus"
   * @example "chevron-right"
   */
  icon?: string;
  /**
   * Size of the icon in pixels.
   * 
   * Default: 16
   */
  iconSize?: number;
  /**
   * Disable button interactions.
   * 
   * When disabled, the button will not respond to clicks and will have a muted appearance.
   */
  disabled?: boolean;
  /**
   * Show loading spinner and disable interactions.
   * 
   * When loading, the icon is replaced with a circular progress indicator.
   */
  loading?: boolean;
  /**
   * Fired when the button is pressed.
   * Not emitted when disabled or loading.
   */
  onClick?: (event: Event) => void;
  /**
   * Fired when the button is long-pressed.
   * Not emitted when disabled or loading.
   */
  onLongpress?: (event: Event) => void;
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
export interface FlutterShadcnIconButtonElement extends WebFElementWithMethods<{
}> {
  /** Visual variant of the icon button. */
  variant?: 'primary' | 'secondary' | 'destructive' | 'outline' | 'ghost';
  /** Name of the Lucide icon to display. */
  icon?: string;
  /** Size of the icon in pixels. */
  iconSize?: number;
  /** Disable button interactions. */
  disabled?: boolean;
  /** Show loading spinner and disable interactions. */
  loading?: boolean;
}
/**
 * Properties for <flutter-shadcn-icon-button>
An icon-only button component with multiple variants.
Unlike the regular button, this is specifically designed for icon-only use cases.
@example
```html
<flutter-shadcn-icon-button icon="rocket" variant="primary" />
```
@example With gradient and shadow (via CSS)
```html
<flutter-shadcn-icon-button
  icon="star"
  style="background-image: linear-gradient(to right, cyan, indigo); box-shadow: 0 2px 10px rgba(0,0,255,0.4);"
/>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnIconButton
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnIconButton>
 * ```
 */
export const FlutterShadcnIconButton = createWebFComponent<FlutterShadcnIconButtonElement, FlutterShadcnIconButtonProps>({
  tagName: 'flutter-shadcn-icon-button',
  displayName: 'FlutterShadcnIconButton',
  // Map props to attributes
  attributeProps: [
    'variant',
    'icon',
    'iconSize',
    'disabled',
    'loading',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    iconSize: 'icon-size',
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
    {
      propName: 'onLongpress',
      eventName: 'longpress',
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