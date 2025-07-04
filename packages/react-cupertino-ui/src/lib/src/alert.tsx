import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoAlertMethods {
  show(options: FlutterCupertinoAlertOptions): void;
  hide(): void;
}
interface FlutterCupertinoAlertOptions {
  title?: string;
  message?: string;
}
export interface FlutterCupertinoAlertProps {
  /**
   * title property
   * @default undefined
   */
  title?: string;
  /**
   * message property
   * @default undefined
   */
  message?: string;
  /**
   * cancelText property
   * @default undefined
   */
  cancelText?: string;
  /**
   * cancelDestructive property
   * @default undefined
   */
  cancelDestructive?: string;
  /**
   * cancelDefault property
   * @default undefined
   */
  cancelDefault?: string;
  /**
   * cancelTextStyle property
   * @default undefined
   */
  cancelTextStyle?: string;
  /**
   * confirmText property
   * @default undefined
   */
  confirmText?: string;
  /**
   * confirmDefault property
   * @default undefined
   */
  confirmDefault?: string;
  /**
   * confirmDestructive property
   * @default undefined
   */
  confirmDestructive?: string;
  /**
   * confirmTextStyle property
   * @default undefined
   */
  confirmTextStyle?: string;
  /**
   * cancel event handler
   */
  onCancel?: (event: CustomEvent) => void;
  /**
   * confirm event handler
   */
  onConfirm?: (event: CustomEvent) => void;
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
 * const ref = useRef<FlutterCupertinoAlertElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterCupertinoAlertElement extends WebFElementWithMethods<{
  show(options: FlutterCupertinoAlertOptions): void;
  hide(): void;
}> {}
/**
 * FlutterCupertinoAlert - WebF FlutterCupertinoAlert component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoAlertElement>(null);
 * 
 * <FlutterCupertinoAlert
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoAlert>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterCupertinoAlert = createWebFComponent<FlutterCupertinoAlertElement, FlutterCupertinoAlertProps>({
  tagName: 'flutter-cupertino-alert',
  displayName: 'FlutterCupertinoAlert',
  // Map props to attributes
  attributeProps: [
    'title',
    'message',
    'cancelText',
    'cancelDestructive',
    'cancelDefault',
    'cancelTextStyle',
    'confirmText',
    'confirmDefault',
    'confirmDestructive',
    'confirmTextStyle',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    cancelText: 'cancel-text',
    cancelDestructive: 'cancel-destructive',
    cancelDefault: 'cancel-default',
    cancelTextStyle: 'cancel-text-style',
    confirmText: 'confirm-text',
    confirmDefault: 'confirm-default',
    confirmDestructive: 'confirm-destructive',
    confirmTextStyle: 'confirm-text-style',
  },
  // Event handlers
  events: [
    {
      propName: 'onCancel',
      eventName: 'cancel',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onConfirm',
      eventName: 'confirm',
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