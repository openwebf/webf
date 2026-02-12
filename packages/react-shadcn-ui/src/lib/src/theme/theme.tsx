import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnThemeProps {
  /**
   * The color scheme to use for theming.
   * Available options: 'blue', 'gray', 'green', 'neutral', 'orange',
   * 'red', 'rose', 'slate', 'stone', 'violet', 'yellow', 'zinc'.
   * Default: 'zinc'
   */
  colorScheme?: string;
  /**
   * The brightness mode for the theme.
   * - 'light': Light mode
   * - 'dark': Dark mode
   * - 'system': Follow system preference
   * Default: 'system'
   */
  brightness?: string;
  /**
   * Radius multiplier for border radius values.
   * Default: 0.5
   */
  radius?: string;
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
export interface FlutterShadcnThemeElement extends WebFElementWithMethods<{
}> {
  /** The color scheme to use for theming. */
  colorScheme?: string;
  /** The brightness mode for the theme. */
  brightness?: string;
  /** Radius multiplier for border radius values. */
  radius?: string;
}
/**
 * Properties for <flutter-shadcn-theme>
Theme provider element that wraps content with shadcn_ui theming.
Use this as a root element to provide consistent theming to all
shadcn components within.
@example
```html
<flutter-shadcn-theme color-scheme="blue" brightness="light">
  <flutter-shadcn-button variant="default">Click me</flutter-shadcn-button>
</flutter-shadcn-theme>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnTheme
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnTheme>
 * ```
 */
export const FlutterShadcnTheme = createWebFComponent<FlutterShadcnThemeElement, FlutterShadcnThemeProps>({
  tagName: 'flutter-shadcn-theme',
  displayName: 'FlutterShadcnTheme',
  // Map props to attributes
  attributeProps: [
    'colorScheme',
    'brightness',
    'radius',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    colorScheme: 'color-scheme',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});