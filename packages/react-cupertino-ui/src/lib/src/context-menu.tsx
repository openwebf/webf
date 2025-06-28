import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/webf-react-core-ui";
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
export interface FlutterCupertinoContextMenuElement extends WebFElementWithMethods<{
  setActions(actions: ContextMenuAction[]): void;
}> {}
/**
 * FlutterCupertinoContextMenu - WebF FlutterCupertinoContextMenu component
 * 
 * @example
 * ```tsx
 * <FlutterCupertinoContextMenu
 *   // Add example props here
 * >
 *   Content
 * </FlutterCupertinoContextMenu>
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