import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnCardProps {
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
export interface FlutterShadcnCardElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-card>
A container card with optional header, content, and footer slots.
@example
```html
<flutter-shadcn-card>
  <flutter-shadcn-card-header>
    <flutter-shadcn-card-title>Card Title</flutter-shadcn-card-title>
    <flutter-shadcn-card-description>Card description here.</flutter-shadcn-card-description>
  </flutter-shadcn-card-header>
  <flutter-shadcn-card-content>
    <p>Card content goes here.</p>
  </flutter-shadcn-card-content>
  <flutter-shadcn-card-footer>
    <flutter-shadcn-button>Action</flutter-shadcn-button>
  </flutter-shadcn-card-footer>
</flutter-shadcn-card>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCard
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCard>
 * ```
 */
export const FlutterShadcnCard = createWebFComponent<FlutterShadcnCardElement, FlutterShadcnCardProps>({
  tagName: 'flutter-shadcn-card',
  displayName: 'FlutterShadcnCard',
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
export interface FlutterShadcnCardHeaderProps {
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
export interface FlutterShadcnCardHeaderElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-card-header>
Header slot for the card.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCardHeader
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCardHeader>
 * ```
 */
export const FlutterShadcnCardHeader = createWebFComponent<FlutterShadcnCardHeaderElement, FlutterShadcnCardHeaderProps>({
  tagName: 'flutter-shadcn-card-header',
  displayName: 'FlutterShadcnCardHeader',
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
export interface FlutterShadcnCardTitleProps {
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
export interface FlutterShadcnCardTitleElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-card-title>
Title slot within card header.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCardTitle
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCardTitle>
 * ```
 */
export const FlutterShadcnCardTitle = createWebFComponent<FlutterShadcnCardTitleElement, FlutterShadcnCardTitleProps>({
  tagName: 'flutter-shadcn-card-title',
  displayName: 'FlutterShadcnCardTitle',
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
export interface FlutterShadcnCardDescriptionProps {
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
export interface FlutterShadcnCardDescriptionElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-card-description>
Description slot within card header.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCardDescription
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCardDescription>
 * ```
 */
export const FlutterShadcnCardDescription = createWebFComponent<FlutterShadcnCardDescriptionElement, FlutterShadcnCardDescriptionProps>({
  tagName: 'flutter-shadcn-card-description',
  displayName: 'FlutterShadcnCardDescription',
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
export interface FlutterShadcnCardContentProps {
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
export interface FlutterShadcnCardContentElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-card-content>
Main content slot for the card.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCardContent
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCardContent>
 * ```
 */
export const FlutterShadcnCardContent = createWebFComponent<FlutterShadcnCardContentElement, FlutterShadcnCardContentProps>({
  tagName: 'flutter-shadcn-card-content',
  displayName: 'FlutterShadcnCardContent',
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
export interface FlutterShadcnCardFooterProps {
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
export interface FlutterShadcnCardFooterElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-card-footer>
Footer slot for the card.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCardFooter
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCardFooter>
 * ```
 */
export const FlutterShadcnCardFooter = createWebFComponent<FlutterShadcnCardFooterElement, FlutterShadcnCardFooterProps>({
  tagName: 'flutter-shadcn-card-footer',
  displayName: 'FlutterShadcnCardFooter',
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