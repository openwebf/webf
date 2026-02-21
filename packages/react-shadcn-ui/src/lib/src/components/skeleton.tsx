import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnSkeletonProps {
  /**
   * Width of the skeleton in pixels.
   */
  width?: string;
  /**
   * Height of the skeleton in pixels.
   */
  height?: string;
  /**
   * Whether the skeleton is circular.
   */
  circle?: boolean;
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
export interface FlutterShadcnSkeletonElement extends WebFElementWithMethods<{
}> {
  /** Width of the skeleton in pixels. */
  width?: string;
  /** Height of the skeleton in pixels. */
  height?: string;
  /** Whether the skeleton is circular. */
  circle?: boolean;
}
/**
 * Properties for <flutter-shadcn-skeleton>
A skeleton loading placeholder.
@example
```html
<flutter-shadcn-skeleton width="100" height="20" />
<flutter-shadcn-skeleton circle width="40" height="40" />
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSkeleton
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSkeleton>
 * ```
 */
export const FlutterShadcnSkeleton = createWebFComponent<FlutterShadcnSkeletonElement, FlutterShadcnSkeletonProps>({
  tagName: 'flutter-shadcn-skeleton',
  displayName: 'FlutterShadcnSkeleton',
  // Map props to attributes
  attributeProps: [
    'width',
    'height',
    'circle',
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