import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnSwitchProps {
  /**
   * Whether the switch is on.
   */
  checked?: boolean;
  /**
   * Disable the switch.
   */
  disabled?: boolean;
  /**
   * Fired when the switch state changes.
   */
  onChange?: (event: Event) => void;
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
export interface FlutterShadcnSwitchElement extends WebFElementWithMethods<{
}> {
  /** Whether the switch is on. */
  checked?: boolean;
  /** Disable the switch. */
  disabled?: boolean;
}
/**
 * Properties for <flutter-shadcn-switch>
A toggle switch control.
@example
```html
<flutter-shadcn-switch
  checked
  onchange="handleChange(event)"
>
  Enable notifications
</flutter-shadcn-switch>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSwitch
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSwitch>
 * ```
 */
export const FlutterShadcnSwitch = createWebFComponent<FlutterShadcnSwitchElement, FlutterShadcnSwitchProps>({
  tagName: 'flutter-shadcn-switch',
  displayName: 'FlutterShadcnSwitch',
  // Map props to attributes
  attributeProps: [
    'checked',
    'disabled',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});