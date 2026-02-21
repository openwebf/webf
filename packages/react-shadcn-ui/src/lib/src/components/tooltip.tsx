import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnTooltipProps {
  /**
   * Text content of the tooltip.
   */
  content?: string;
  /**
   * Delay before showing tooltip in milliseconds.
   * Default: 200
   */
  showDelay?: string;
  /**
   * Delay before hiding tooltip in milliseconds.
   * Default: 0
   */
  hideDelay?: string;
  /**
   * Placement of the tooltip relative to the trigger.
   * Options: 'top', 'bottom', 'left', 'right'
   * Default: 'top'
   */
  placement?: string;
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
export interface FlutterShadcnTooltipElement extends WebFElementWithMethods<{
}> {
  /** Text content of the tooltip. */
  content?: string;
  /** Delay before showing tooltip in milliseconds. */
  showDelay?: string;
  /** Delay before hiding tooltip in milliseconds. */
  hideDelay?: string;
  /** Placement of the tooltip relative to the trigger. */
  placement?: string;
}
/**
 * Properties for <flutter-shadcn-tooltip>
A tooltip component that shows additional information on hover.
@example
```html
<flutter-shadcn-tooltip content="This is a tooltip">
  <flutter-shadcn-button>Hover me</flutter-shadcn-button>
</flutter-shadcn-tooltip>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnTooltip
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnTooltip>
 * ```
 */
export const FlutterShadcnTooltip = createWebFComponent<FlutterShadcnTooltipElement, FlutterShadcnTooltipProps>({
  tagName: 'flutter-shadcn-tooltip',
  displayName: 'FlutterShadcnTooltip',
  // Map props to attributes
  attributeProps: [
    'content',
    'showDelay',
    'hideDelay',
    'placement',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    showDelay: 'show-delay',
    hideDelay: 'hide-delay',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});