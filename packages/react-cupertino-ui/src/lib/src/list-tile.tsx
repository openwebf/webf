import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoListTileProps {
  /**
   * notched property
   * @default undefined
   */
  notched?: string;
  /**
   * showChevron property
   * @default undefined
   */
  showChevron?: string;
  /**
   * click event handler
   */
  onClick?: (event: Event) => void;
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
export interface FlutterCupertinoListTileElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoListTile - WebF FlutterCupertinoListTile component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoListTile
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoListTile>
 * ```
 */
export const FlutterCupertinoListTile = createWebFComponent<FlutterCupertinoListTileElement, FlutterCupertinoListTileProps>({
  tagName: 'flutter-cupertino-list-tile',
  displayName: 'FlutterCupertinoListTile',
  // Map props to attributes
  attributeProps: [
    'notched',
    'showChevron',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    showChevron: 'show-chevron',
  },
  // Event handlers
  events: [
    {
      propName: 'onClick',
      eventName: 'click',
      handler: (callback) => (event) => {
        callback((event as Event));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});