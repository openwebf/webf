import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoListSectionProps {
  /**
   * insetGrouped property
   * @default undefined
   */
  insetGrouped?: string;
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
export interface FlutterCupertinoListSectionElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoListSection - WebF FlutterCupertinoListSection component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoListSection
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoListSection>
 * ```
 */
export const FlutterCupertinoListSection = createWebFComponent<FlutterCupertinoListSectionElement, FlutterCupertinoListSectionProps>({
  tagName: 'flutter-cupertino-list-section',
  displayName: 'FlutterCupertinoListSection',
  // Map props to attributes
  attributeProps: [
    'insetGrouped',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    insetGrouped: 'inset-grouped',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterCupertinoListSectionHeaderProps {
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
export interface FlutterCupertinoListSectionHeaderElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoListSectionHeader - WebF FlutterCupertinoListSectionHeader component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoListSectionHeader
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoListSectionHeader>
 * ```
 */
export const FlutterCupertinoListSectionHeader = createWebFComponent<FlutterCupertinoListSectionHeaderElement, FlutterCupertinoListSectionHeaderProps>({
  tagName: 'flutter-cupertino-list-section-header',
  displayName: 'FlutterCupertinoListSectionHeader',
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
export interface FlutterCupertinoListSectionFooterProps {
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
export interface FlutterCupertinoListSectionFooterElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoListSectionFooter - WebF FlutterCupertinoListSectionFooter component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoListSectionFooter
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoListSectionFooter>
 * ```
 */
export const FlutterCupertinoListSectionFooter = createWebFComponent<FlutterCupertinoListSectionFooterElement, FlutterCupertinoListSectionFooterProps>({
  tagName: 'flutter-cupertino-list-section-footer',
  displayName: 'FlutterCupertinoListSectionFooter',
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