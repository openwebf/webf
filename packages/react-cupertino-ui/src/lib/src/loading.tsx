import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoLoadingMethods {
  show(options: FlutterCupertinoLoadingOptions): void;
  hide(): void;
}
interface FlutterCupertinoLoadingOptions {
  text?: string;
}
export interface FlutterCupertinoLoadingProps {
  /**
   * maskClosable property
   * @default undefined
   */
  maskClosable?: boolean;
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
 * const ref = useRef<FlutterCupertinoLoadingElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterCupertinoLoadingElement extends WebFElementWithMethods<{
  show(options: FlutterCupertinoLoadingOptions): void;
  hide(): void;
}> {}
/**
 * FlutterCupertinoLoading - WebF FlutterCupertinoLoading component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoLoadingElement>(null);
 * 
 * <FlutterCupertinoLoading
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoLoading>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterCupertinoLoading = createWebFComponent<FlutterCupertinoLoadingElement, FlutterCupertinoLoadingProps>({
  tagName: 'flutter-cupertino-loading',
  displayName: 'FlutterCupertinoLoading',
  // Map props to attributes
  attributeProps: [
    'maskClosable',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    maskClosable: 'mask-closable',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});