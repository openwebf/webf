import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoActionSheetMethods {
  show(options: FlutterCupertinoActionSheetOptions): void;
}
interface FlutterCupertinoActionSheetAction {
  text: string;
  isDefault?: boolean;
  isDestructive?: boolean;
  event?: string;
}
interface FlutterCupertinoActionSheetOptions {
  title?: string;
  message?: string;
  actions?: FlutterCupertinoActionSheetAction[];
  cancelButton?: FlutterCupertinoActionSheetAction;
}
export interface FlutterCupertinoActionSheetProps {
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
 * const ref = useRef<FlutterCupertinoActionSheetElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterCupertinoActionSheetElement extends WebFElementWithMethods<{
  show(options: FlutterCupertinoActionSheetOptions): void;
}> {}
/**
 * FlutterCupertinoActionSheet - WebF FlutterCupertinoActionSheet component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoActionSheetElement>(null);
 * 
 * <FlutterCupertinoActionSheet
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoActionSheet>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterCupertinoActionSheet = createWebFComponent<FlutterCupertinoActionSheetElement, FlutterCupertinoActionSheetProps>({
  tagName: 'flutter-cupertino-action-sheet',
  displayName: 'FlutterCupertinoActionSheet',
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