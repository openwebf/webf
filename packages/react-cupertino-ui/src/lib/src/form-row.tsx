import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoFormRowProps {
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
export interface FlutterCupertinoFormRowElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoFormRow - WebF FlutterCupertinoFormRow component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoFormRow
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoFormRow>
 * ```
 */
export const FlutterCupertinoFormRow = createWebFComponent<FlutterCupertinoFormRowElement, FlutterCupertinoFormRowProps>({
  tagName: 'flutter-cupertino-form-row',
  displayName: 'FlutterCupertinoFormRow',
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