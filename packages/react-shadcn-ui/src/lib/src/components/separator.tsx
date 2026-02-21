import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnSeparatorProps {
  /**
   * Orientation of the separator.
   * Options: 'horizontal', 'vertical'
   * Default: 'horizontal'
   */
  orientation?: string;
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
export interface FlutterShadcnSeparatorElement extends WebFElementWithMethods<{
}> {
  /** Orientation of the separator. */
  orientation?: string;
}
/**
 * Properties for <flutter-shadcn-separator>
A visual separator/divider component.
@example
```html
<flutter-shadcn-separator orientation="horizontal" />
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSeparator
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSeparator>
 * ```
 */
export const FlutterShadcnSeparator = createWebFComponent<FlutterShadcnSeparatorElement, FlutterShadcnSeparatorProps>({
  tagName: 'flutter-shadcn-separator',
  displayName: 'FlutterShadcnSeparator',
  // Map props to attributes
  attributeProps: [
    'orientation',
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