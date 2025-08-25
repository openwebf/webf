import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterBottomSheetMethods {
  showBottomSheet(): void;
}
export interface FlutterBottomSheetProps {
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
 * const ref = useRef<FlutterBottomSheetElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterBottomSheetElement extends WebFElementWithMethods<{
  showBottomSheet(): void;
}> {}
/**
 * FlutterBottomSheet - WebF FlutterBottomSheet component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterBottomSheetElement>(null);
 * 
 * <FlutterBottomSheet
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterBottomSheet>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterBottomSheet = createWebFComponent<FlutterBottomSheetElement, FlutterBottomSheetProps>({
  tagName: 'flutter-bottom-sheet',
  displayName: 'FlutterBottomSheet',
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