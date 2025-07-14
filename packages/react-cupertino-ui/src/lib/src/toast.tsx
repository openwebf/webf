import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoToastMethods {
  show(options: FlutterCupertinoToastOptions): void;
  close(): void;
}
interface FlutterCupertinoToastOptions {
  content: string;
  type?: 'normal' | 'success' | 'warning' | 'error' | 'loading';
  duration?: number;
}
export interface FlutterCupertinoToastProps {
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
/**
 * Element interface with methods accessible via ref
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoToastElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterCupertinoToastElement extends WebFElementWithMethods<{
  show(options: FlutterCupertinoToastOptions): void;
  close(): void;
}> {}
/**
 * FlutterCupertinoToast - WebF FlutterCupertinoToast component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoToastElement>(null);
 * 
 * <FlutterCupertinoToast
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoToast>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterCupertinoToast = createWebFComponent<FlutterCupertinoToastElement, FlutterCupertinoToastProps>({
  tagName: 'flutter-cupertino-toast',
  displayName: 'FlutterCupertinoToast',
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