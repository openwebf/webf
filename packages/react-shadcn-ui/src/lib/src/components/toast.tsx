import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnToastProps {
  /**
   * Visual variant of the toast.
   * - 'default': Standard toast
   * - 'destructive': Red error toast
   * Default: 'default'
   */
  variant?: string;
  /**
   * Title of the toast.
   */
  title?: string;
  /**
   * Description text.
   */
  description?: string;
  /**
   * Duration in milliseconds before auto-dismiss.
   * Set to 0 to disable auto-dismiss.
   * Default: 5000
   */
  duration?: string;
  /**
   * Show close button.
   */
  closable?: boolean;
  /**
   * Fired when toast is dismissed.
   */
  onClose?: (event: Event) => void;
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
export interface FlutterShadcnToastElement extends WebFElementWithMethods<{
}> {
  /** Visual variant of the toast. */
  variant?: string;
  /** Title of the toast. */
  title?: string;
  /** Description text. */
  description?: string;
  /** Duration in milliseconds before auto-dismiss. */
  duration?: string;
  /** Show close button. */
  closable?: boolean;
}
/**
 * Properties for <flutter-shadcn-toast>
A toast notification component.
@example
```html
<flutter-shadcn-toast variant="default" title="Success" description="Your changes have been saved." />
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnToast
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnToast>
 * ```
 */
export const FlutterShadcnToast = createWebFComponent<FlutterShadcnToastElement, FlutterShadcnToastProps>({
  tagName: 'flutter-shadcn-toast',
  displayName: 'FlutterShadcnToast',
  // Map props to attributes
  attributeProps: [
    'variant',
    'title',
    'description',
    'duration',
    'closable',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onClose',
      eventName: 'close',
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