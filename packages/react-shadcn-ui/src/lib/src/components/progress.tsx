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