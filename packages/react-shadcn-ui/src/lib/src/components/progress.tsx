import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnProgressProps {
  /**
   * Current progress value.
   */
  value?: string;
  /**
   * Maximum value.
   * Default: 100
   */
  max?: string;
  /**
   * Visual variant.
   * Options: 'default', 'indeterminate'
   * Default: 'default'
   */
  variant?: string;
  /**
   * Background color of the progress track.
   * Accepts hex color string (e.g. '#e0e0e0', '#FF808080').
   */
  backgroundColor?: string;
  /**
   * Color of the progress indicator.
   * Accepts hex color string (e.g. '#3b82f6', '#FF0000FF').
   */
  color?: string;
  /**
   * Minimum height of the progress bar in logical pixels.
   * Default: 16
   */
  minHeight?: string;
  /**
   * Border radius of the progress bar in logical pixels.
   * Applied uniformly to all corners.
   * Default: 16
   */
  borderRadius?: string;
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
export interface FlutterShadcnProgressElement extends WebFElementWithMethods<{
}> {
  /** Current progress value. */
  value?: string;
  /** Maximum value. */
  max?: string;
  /** Visual variant. */
  variant?: string;
  /** Background color of the progress track. */
  backgroundColor?: string;
  /** Color of the progress indicator. */
  color?: string;
  /** Minimum height of the progress bar in logical pixels. */
  minHeight?: string;
  /** Border radius of the progress bar in logical pixels. */
  borderRadius?: string;
}
/**
 * Properties for <flutter-shadcn-progress>
A progress indicator component.
@example
```html
<flutter-shadcn-progress value="60" max="100" />
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnProgress
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnProgress>
 * ```
 */
export const FlutterShadcnProgress = createWebFComponent<FlutterShadcnProgressElement, FlutterShadcnProgressProps>({
  tagName: 'flutter-shadcn-progress',
  displayName: 'FlutterShadcnProgress',
  // Map props to attributes
  attributeProps: [
    'value',
    'max',
    'variant',
    'backgroundColor',
    'color',
    'minHeight',
    'borderRadius',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    backgroundColor: 'background-color',
    minHeight: 'min-height',
    borderRadius: 'border-radius',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});