import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoSegmentedTabProps {
  /**
   * change event handler
   */
  onChange?: (event: CustomEvent) => void;
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
export interface FlutterCupertinoSegmentedTabElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoSegmentedTab - WebF FlutterCupertinoSegmentedTab component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoSegmentedTab
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoSegmentedTab>
 * ```
 */
export const FlutterCupertinoSegmentedTab = createWebFComponent<FlutterCupertinoSegmentedTabElement, FlutterCupertinoSegmentedTabProps>({
  tagName: 'flutter-cupertino-segmented-tab',
  displayName: 'FlutterCupertinoSegmentedTab',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});