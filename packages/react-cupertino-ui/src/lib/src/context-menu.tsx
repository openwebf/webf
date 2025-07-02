import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoContextMenuMethods {
  setActions(actions: ContextMenuAction[]): void;
}
interface ContextMenuAction {
  text: string;
  icon?: string;
  destructive?: boolean;
  default?: boolean;
  event?: string;
}
export interface FlutterCupertinoContextMenuProps {
  /**
   * enableHapticFeedback property
   * @default undefined
   */
  enableHapticFeedback?: boolean;
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
 * const ref = useRef<FlutterCupertinoContextMenuElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterCupertinoContextMenuElement extends WebFElementWithMethods<{
  setActions(actions: ContextMenuAction[]): void;
}> {}
/**
 * FlutterCupertinoContextMenu - WebF FlutterCupertinoContextMenu component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoContextMenuElement>(null);
 * 
 * <FlutterCupertinoContextMenu
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoContextMenu>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterCupertinoContextMenu = createWebFComponent<FlutterCupertinoContextMenuElement, FlutterCupertinoContextMenuProps>({
  tagName: 'flutter-cupertino-context-menu',
  displayName: 'FlutterCupertinoContextMenu',
  // Map props to attributes
  attributeProps: [
    'enableHapticFeedback',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    enableHapticFeedback: 'enable-haptic-feedback',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});