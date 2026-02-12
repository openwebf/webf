import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnImageProps {
  /**
   * Image source URL.
   */
  src?: string;
  /**
   * Alt text for accessibility.
   */
  alt?: string;
  /**
   * Image width in pixels.
   */
  width?: string;
  /**
   * Image height in pixels.
   */
  height?: string;
  /**
   * How to fit the image.
   * Options: 'contain', 'cover', 'fill', 'none', 'scaleDown'
   * Default: 'cover'
   */
  fit?: string;
  /**
   * Fired when image loads successfully.
   */
  onLoad?: (event: Event) => void;
  /**
   * Fired when image fails to load.
   */
  onError?: (event: Event) => void;
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
export interface FlutterShadcnImageElement extends WebFElementWithMethods<{
}> {
  /** Image source URL. */
  src?: string;
  /** Alt text for accessibility. */
  alt?: string;
  /** Image width in pixels. */
  width?: string;
  /** Image height in pixels. */
  height?: string;
  /** How to fit the image. */
  fit?: string;
}
/**
 * Properties for <flutter-shadcn-image>
An image component with loading and error states.
@example
```html
<flutter-shadcn-image
  src="https://example.com/image.jpg"
  alt="Example image"
  width="200"
  height="150"
/>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnImage
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnImage>
 * ```
 */
export const FlutterShadcnImage = createWebFComponent<FlutterShadcnImageElement, FlutterShadcnImageProps>({
  tagName: 'flutter-shadcn-image',
  displayName: 'FlutterShadcnImage',
  // Map props to attributes
  attributeProps: [
    'src',
    'alt',
    'width',
    'height',
    'fit',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onLoad',
      eventName: 'load',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
    {
      propName: 'onError',
      eventName: 'error',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});