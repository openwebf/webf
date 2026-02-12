import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnAvatarProps {
  /**
   * URL of the avatar image.
   */
  src?: string;
  /**
   * Alt text for the image.
   */
  alt?: string;
  /**
   * Fallback text/initials when image fails to load or is not provided.
   */
  fallback?: string;
  /**
   * Size of the avatar in pixels.
   * Default: 40
   */
  size?: string;
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
export interface FlutterShadcnAvatarElement extends WebFElementWithMethods<{
}> {
  /** URL of the avatar image. */
  src?: string;
  /** Alt text for the image. */
  alt?: string;
  /** Fallback text/initials when image fails to load or is not provided. */
  fallback?: string;
  /** Size of the avatar in pixels. */
  size?: string;
}
/**
 * Properties for <flutter-shadcn-avatar>
An avatar component for displaying user images or initials.
@example
```html
<flutter-shadcn-avatar src="https://example.com/avatar.jpg" alt="John Doe" />
<flutter-shadcn-avatar fallback="JD" />
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnAvatar
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnAvatar>
 * ```
 */
export const FlutterShadcnAvatar = createWebFComponent<FlutterShadcnAvatarElement, FlutterShadcnAvatarProps>({
  tagName: 'flutter-shadcn-avatar',
  displayName: 'FlutterShadcnAvatar',
  // Map props to attributes
  attributeProps: [
    'src',
    'alt',
    'fallback',
    'size',
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