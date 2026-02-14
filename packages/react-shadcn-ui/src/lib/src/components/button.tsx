import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnButtonProps {
  /**
   * Visual variant of the button.
   * - 'default': Primary filled button
   * - 'secondary': Secondary muted button
   * - 'destructive': Red destructive action button
   * - 'outline': Bordered outline button
   * - 'ghost': Transparent with hover effect
   * - 'link': Text link style button
   * Default: 'default'
   */
  variant?: string;
  /**
   * Size of the button.
   * - 'default': Standard size
   * - 'sm': Small size
   * - 'lg': Large size
   * - 'icon': Square icon-only button
   * Default: 'default'
   */
  size?: string;
  /**
   * Disable button interactions.
   */
  disabled?: boolean;
  /**
   * Show loading spinner and disable interactions.
   */
  loading?: boolean;
  /**
   * Icon name to show before the button text.
   */
  icon?: string;
  /**
   * Fired when the button is pressed (not emitted when disabled or loading).
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
export interface FlutterShadcnButtonElement extends WebFElementWithMethods<{
}> {
  /** Visual variant of the button. */
  variant?: string;
  /** Size of the button. */
  size?: string;
  /** Disable button interactions. */
  disabled?: boolean;
  /** Show loading spinner and disable interactions. */
  loading?: boolean;
  /** Icon name to show before the button text. */
  icon?: string;
}
/**
 * Properties for <flutter-shadcn-button>
A versatile button component with multiple variants and sizes.
@example
```html
<flutter-shadcn-button variant="default" size="default">
  Click me
</flutter-shadcn-button>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnButton
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnButton>
 * ```
 */
export const FlutterShadcnButton = createWebFComponent<FlutterShadcnButtonElement, FlutterShadcnButtonProps>({
  tagName: 'flutter-shadcn-button',
  displayName: 'FlutterShadcnButton',
  // Map props to attributes
  attributeProps: [
    'variant',
    'size',
    'disabled',
    'loading',
    'icon',
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