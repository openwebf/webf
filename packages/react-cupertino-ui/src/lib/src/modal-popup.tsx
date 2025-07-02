import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoModalPopupMethods {
  show(): void;
  hide(): void;
}
export interface FlutterCupertinoModalPopupProps {
  /**
   * visible property
   * @default undefined
   */
  visible?: boolean;
  /**
   * height property
   * @default undefined
   */
  height?: number;
  /**
   * surfacePainted property
   * @default undefined
   */
  surfacePainted?: boolean;
  /**
   * maskClosable property
   * @default undefined
   */
  maskClosable?: boolean;
  /**
   * backgroundOpacity property
   * @default undefined
   */
  backgroundOpacity?: number;
  /**
   * close event handler
   */
  onClose?: (event: CustomEvent) => void;
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
 * const ref = useRef<FlutterCupertinoModalPopupElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterCupertinoModalPopupElement extends WebFElementWithMethods<{
  show(): void;
  hide(): void;
}> {}
/**
 * FlutterCupertinoModalPopup - WebF FlutterCupertinoModalPopup component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoModalPopupElement>(null);
 * 
 * <FlutterCupertinoModalPopup
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoModalPopup>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterCupertinoModalPopup = createWebFComponent<FlutterCupertinoModalPopupElement, FlutterCupertinoModalPopupProps>({
  tagName: 'flutter-cupertino-modal-popup',
  displayName: 'FlutterCupertinoModalPopup',
  // Map props to attributes
  attributeProps: [
    'visible',
    'height',
    'surfacePainted',
    'maskClosable',
    'backgroundOpacity',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    surfacePainted: 'surface-painted',
    maskClosable: 'mask-closable',
    backgroundOpacity: 'background-opacity',
  },
  // Event handlers
  events: [
    {
      propName: 'onClose',
      eventName: 'close',
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