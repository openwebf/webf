import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnScrollAreaProps {
  /**
   * Orientation of the scroll area.
   * Options: 'vertical', 'horizontal', 'both'
   * Default: 'vertical'
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
export interface FlutterShadcnScrollAreaElement extends WebFElementWithMethods<{
}> {
  /** Orientation of the scroll area. */
  orientation?: string;
}
/**
 * Properties for <flutter-shadcn-scroll-area>
A scrollable area with styled scrollbars.
@example
```html
<flutter-shadcn-scroll-area style="height: 200px">
  <div>Scrollable content...</div>
</flutter-shadcn-scroll-area>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnScrollArea
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnScrollArea>
 * ```
 */
export const FlutterShadcnScrollArea = createWebFComponent<FlutterShadcnScrollAreaElement, FlutterShadcnScrollAreaProps>({
  tagName: 'flutter-shadcn-scroll-area',
  displayName: 'FlutterShadcnScrollArea',
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