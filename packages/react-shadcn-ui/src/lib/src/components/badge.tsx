import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnBadgeProps {
  /**
   * Visual variant of the badge.
   * - 'default': Primary filled badge
   * - 'secondary': Secondary muted badge
   * - 'destructive': Red destructive badge
   * - 'outline': Bordered outline badge
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
export interface FlutterShadcnBadgeElement extends WebFElementWithMethods<{
}> {
  /** Visual variant of the badge. */
  variant?: string;
}
/**
 * Properties for <flutter-shadcn-badge>
A small badge component for displaying labels or counts.
@example
```html
<flutter-shadcn-badge variant="default">New</flutter-shadcn-badge>
<flutter-shadcn-badge variant="destructive">Error</flutter-shadcn-badge>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnBadge
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnBadge>
 * ```
 */
export const FlutterShadcnBadge = createWebFComponent<FlutterShadcnBadgeElement, FlutterShadcnBadgeProps>({
  tagName: 'flutter-shadcn-badge',
  displayName: 'FlutterShadcnBadge',
  // Map props to attributes
  attributeProps: [
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