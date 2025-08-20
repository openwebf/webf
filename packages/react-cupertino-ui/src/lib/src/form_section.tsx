import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoFormSectionProps {
  /**
   * insetGrouped property
   * @default undefined
   */
  insetGrouped?: string;
  /**
   * clipBehavior property
   * @default undefined
   */
  clipBehavior?: string;
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
export interface FlutterCupertinoFormSectionElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoFormSection - WebF FlutterCupertinoFormSection component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoFormSection
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoFormSection>
 * ```
 */
export const FlutterCupertinoFormSection = createWebFComponent<FlutterCupertinoFormSectionElement, FlutterCupertinoFormSectionProps>({
  tagName: 'flutter-cupertino-form-section',
  displayName: 'FlutterCupertinoFormSection',
  // Map props to attributes
  attributeProps: [
    'insetGrouped',
    'clipBehavior',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    insetGrouped: 'inset-grouped',
    clipBehavior: 'clip-behavior',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterCupertinoFormSectionHeaderProps {
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
export interface FlutterCupertinoFormSectionHeaderElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoFormSectionHeader - WebF FlutterCupertinoFormSectionHeader component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoFormSectionHeader
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoFormSectionHeader>
 * ```
 */
export const FlutterCupertinoFormSectionHeader = createWebFComponent<FlutterCupertinoFormSectionHeaderElement, FlutterCupertinoFormSectionHeaderProps>({
  tagName: 'flutter-cupertino-form-section-header',
  displayName: 'FlutterCupertinoFormSectionHeader',
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
export interface FlutterCupertinoFormSectionFooterProps {
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
export interface FlutterCupertinoFormSectionFooterElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoFormSectionFooter - WebF FlutterCupertinoFormSectionFooter component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoFormSectionFooter
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoFormSectionFooter>
 * ```
 */
export const FlutterCupertinoFormSectionFooter = createWebFComponent<FlutterCupertinoFormSectionFooterElement, FlutterCupertinoFormSectionFooterProps>({
  tagName: 'flutter-cupertino-form-section-footer',
  displayName: 'FlutterCupertinoFormSectionFooter',
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