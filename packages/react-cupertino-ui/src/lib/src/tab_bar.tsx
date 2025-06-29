import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
type CupertinoTabBarIcon = "home" | "house" | "house_fill" | "search" | "search_circle" | "search_circle_fill" | "add" | "add_circled" | "add_circled_solid" | "plus" | "plus_circle" | "plus_circle_fill" | "person" | "person_fill" | "person_circle" | "person_circle_fill" | "profile_circled" | "bell" | "bell_fill" | "bell_circle" | "bell_circle_fill" | "chat_bubble" | "chat_bubble_fill" | "chat_bubble_2" | "chat_bubble_2_fill" | "mail" | "mail_solid" | "envelope" | "envelope_fill" | "phone" | "phone_fill" | "compass" | "compass_fill" | "location" | "location_fill" | "map" | "map_fill" | "photo" | "photo_fill" | "camera" | "camera_fill" | "video_camera" | "video_camera_solid" | "play" | "play_fill" | "play_circle" | "play_circle_fill" | "gear" | "gear_solid" | "settings" | "settings_solid" | "ellipsis" | "ellipsis_circle" | "ellipsis_circle_fill" | "creditcard" | "creditcard_fill" | "cart" | "cart_fill" | "bag" | "bag_fill" | "doc" | "doc_fill" | "doc_text" | "doc_text_fill" | "folder" | "folder_fill" | "book" | "book_fill" | "heart" | "heart_fill" | "star" | "star_fill" | "hand_thumbsup" | "hand_thumbsup_fill" | "bookmark" | "bookmark_fill" | "money_dollar" | "money_dollar_circle" | "money_dollar_circle_fill" | "info" | "info_circle" | "info_circle_fill" | "question" | "question_circle" | "question_circle_fill" | "exclamationmark" | "exclamationmark_circle" | "exclamationmark_circle_fill";
type int = number;
interface FlutterCupertinoTabBarMethods {
  switchTab(path: string): void;
}
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
/**
 * Element interface with methods accessible via ref
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoTabBarElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterCupertinoTabBarElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoTabBar - WebF FlutterCupertinoTabBar component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoTabBarElement>(null);
 * 
 * <FlutterCupertinoTabBar
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoTabBar>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
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
  icon?: CupertinoTabBarIcon;
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
 * 
 * <FlutterCupertinoTabBarItem
 *   // Add props here
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