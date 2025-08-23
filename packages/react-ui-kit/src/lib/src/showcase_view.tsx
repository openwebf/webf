import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterShowcaseViewMethods {
  start(): void;
  dismiss(): void;
}
export interface FlutterShowcaseViewProps {
  /**
   * disableBarrierInteraction property
   * @default undefined
   */
  disableBarrierInteraction?: boolean;
  /**
   * tooltipPosition property
   * @default undefined
   */
  tooltipPosition?: string;
  /**
   * finish event handler
   */
  onFinish?: (event: Event) => void;
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
 * const ref = useRef<FlutterShowcaseViewElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterShowcaseViewElement extends WebFElementWithMethods<{
  start(): void;
  dismiss(): void;
}> {}
/**
 * FlutterShowcaseView - WebF FlutterShowcaseView component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterShowcaseViewElement>(null);
 * 
 * <FlutterShowcaseView
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterShowcaseView>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterShowcaseView = createWebFComponent<FlutterShowcaseViewElement, FlutterShowcaseViewProps>({
  tagName: 'flutter-showcase-view',
  displayName: 'FlutterShowcaseView',
  // Map props to attributes
  attributeProps: [
    'disableBarrierInteraction',
    'tooltipPosition',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    disableBarrierInteraction: 'disable-barrier-interaction',
    tooltipPosition: 'tooltip-position',
  },
  // Event handlers
  events: [
    {
      propName: 'onFinish',
      eventName: 'finish',
      handler: (callback) => (event) => {
        callback((event as Event));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShowcaseItemProps {
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
export interface FlutterShowcaseItemElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterShowcaseItem - WebF FlutterShowcaseItem component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShowcaseItem
 *   // Add props here
 * >
 *   Content
 * </FlutterShowcaseItem>
 * ```
 */
export const FlutterShowcaseItem = createWebFComponent<FlutterShowcaseItemElement, FlutterShowcaseItemProps>({
  tagName: 'flutter-showcase-item',
  displayName: 'FlutterShowcaseItem',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShowcaseDescriptionProps {
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
export interface FlutterShowcaseDescriptionElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterShowcaseDescription - WebF FlutterShowcaseDescription component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShowcaseDescription
 *   // Add props here
 * >
 *   Content
 * </FlutterShowcaseDescription>
 * ```
 */
export const FlutterShowcaseDescription = createWebFComponent<FlutterShowcaseDescriptionElement, FlutterShowcaseDescriptionProps>({
  tagName: 'flutter-showcase-description',
  displayName: 'FlutterShowcaseDescription',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});