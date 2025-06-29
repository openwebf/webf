import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
export interface WebFTextProps {
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
export interface WebFTextElement extends WebFElementWithMethods<{
}> {}
/**
 * WebFText - WebF WebFText component
 * 
 * @example
 * ```tsx
 * <WebFText
 *   // Add example props here
 * >
 *   Content
 * </WebFText>
 * ```
 */
export const WebFText = createWebFComponent<WebFTextElement, WebFTextProps>({
  tagName: 'webf-text',
  displayName: 'WebFText',
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