import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/webf-react-core-ui";
export interface FlutterCupertinoTabBarProps {
  /**
   * currentIndex property
   * @default undefined
   */
  currentIndex?: string;
  /**
   * backgroundColor property
   * @default undefined
   */
  backgroundColor?: string;
  /**
   * activeColor property
   * @default undefined
   */
  activeColor?: string;
  /**
   * inactiveColor property
   * @default undefined
   */
  inactiveColor?: string;
  /**
   * iconSize property
   * @default undefined
   */
  iconSize?: string;
  /**
   * height property
   * @default undefined
   */
  height?: string;
  /**
   * tabchange event handler
   */
  onTabchange?: (event: CustomEvent) => void;
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
export interface FlutterCupertinoTabBarElement extends WebFElementWithMethods<{
  switchTab(path: string): void;
}> {}
/**
 * FlutterCupertinoTabBar - WebF FlutterCupertinoTabBar component
 * 
 * @example
 * ```tsx
 * <FlutterCupertinoTabBar
 *   // Add example props here
 * >
 *   Content
 * </FlutterCupertinoTabBar>
 * ```
 */
export const FlutterCupertinoTabBar = createWebFComponent<FlutterCupertinoTabBarElement, FlutterCupertinoTabBarProps>({
  tagName: 'flutter-cupertino-tab-bar',
  displayName: 'FlutterCupertinoTabBar',
  // Map props to attributes
  attributeProps: [
    'currentIndex',
    'backgroundColor',
    'activeColor',
    'inactiveColor',
    'iconSize',
    'height',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    currentIndex: 'current-index',
    backgroundColor: 'background-color',
    activeColor: 'active-color',
    inactiveColor: 'inactive-color',
    iconSize: 'icon-size',
  },
  // Event handlers
  events: [
    {
      propName: 'onTabchange',
      eventName: 'tabchange',
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
export interface FlutterCupertinoTabBarItemProps {
  /**
   * title property
   * @default undefined
   */
  title?: string;
  /**
   * icon property
   * @default undefined
   */
  icon?: string;
  /**
   * path property
   * @default undefined
   */
  path?: string;
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
export interface FlutterCupertinoTabBarItemElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoTabBarItem - WebF FlutterCupertinoTabBarItem component
 * 
 * @example
 * ```tsx
 * <FlutterCupertinoTabBarItem
 *   // Add example props here
 * >
 *   Content
 * </FlutterCupertinoTabBarItem>
 * ```
 */
export const FlutterCupertinoTabBarItem = createWebFComponent<FlutterCupertinoTabBarItemElement, FlutterCupertinoTabBarItemProps>({
  tagName: 'flutter-cupertino-tab-bar-item',
  displayName: 'FlutterCupertinoTabBarItem',
  // Map props to attributes
  attributeProps: [
    'title',
    'icon',
    'path',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});