import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoListTileProps {
  /**
   * showChevron property
   * @default undefined
   */
  showChevron?: string;
  /**
   * click event handler
   */
  onClick?: (event: CustomEvent) => void;
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
        callback((event as CustomEvent));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterCupertinoListTileLeadingProps {
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
export interface FlutterCupertinoListTileLeadingElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoListTileLeading - WebF FlutterCupertinoListTileLeading component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoListTileLeading
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoListTileLeading>
 * ```
 */
export const FlutterCupertinoListTileLeading = createWebFComponent<FlutterCupertinoListTileLeadingElement, FlutterCupertinoListTileLeadingProps>({
  tagName: 'flutter-cupertino-list-tile-leading',
  displayName: 'FlutterCupertinoListTileLeading',
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
export interface FlutterCupertinoListTileSubtitleProps {
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
export interface FlutterCupertinoListTileSubtitleElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoListTileSubtitle - WebF FlutterCupertinoListTileSubtitle component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoListTileSubtitle
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoListTileSubtitle>
 * ```
 */
export const FlutterCupertinoListTileSubtitle = createWebFComponent<FlutterCupertinoListTileSubtitleElement, FlutterCupertinoListTileSubtitleProps>({
  tagName: 'flutter-cupertino-list-tile-subtitle',
  displayName: 'FlutterCupertinoListTileSubtitle',
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
export interface FlutterCupertinoListTileAdditionalInfoProps {
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
export interface FlutterCupertinoListTileAdditionalInfoElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoListTileAdditionalInfo - WebF FlutterCupertinoListTileAdditionalInfo component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoListTileAdditionalInfo
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoListTileAdditionalInfo>
 * ```
 */
export const FlutterCupertinoListTileAdditionalInfo = createWebFComponent<FlutterCupertinoListTileAdditionalInfoElement, FlutterCupertinoListTileAdditionalInfoProps>({
  tagName: 'flutter-cupertino-list-tile-additional-info',
  displayName: 'FlutterCupertinoListTileAdditionalInfo',
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
export interface FlutterCupertinoListTileTrailingProps {
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
export interface FlutterCupertinoListTileTrailingElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoListTileTrailing - WebF FlutterCupertinoListTileTrailing component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoListTileTrailing
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoListTileTrailing>
 * ```
 */
export const FlutterCupertinoListTileTrailing = createWebFComponent<FlutterCupertinoListTileTrailingElement, FlutterCupertinoListTileTrailingProps>({
  tagName: 'flutter-cupertino-list-tile-trailing',
  displayName: 'FlutterCupertinoListTileTrailing',
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