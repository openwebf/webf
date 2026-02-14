import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnInputOtpProps {
  /**
   * Maximum number of characters (required).
   */
  maxlength: string;
  /**
   * Current OTP value.
   */
  value?: string;
  /**
   * Disable the input.
   */
  disabled?: boolean;
  /**
   * Fired when the OTP value changes.
   */
  onChange?: (event: Event) => void;
  /**
   * Fired when all slots are filled.
   */
  onComplete?: (event: Event) => void;
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
export interface FlutterShadcnInputOtpElement extends WebFElementWithMethods<{
}> {
  /** Maximum number of characters (required). */
  maxlength: string;
  /** Current OTP value. */
  value?: string;
  /** Disable the input. */
  disabled?: boolean;
}
/**
 * Properties for <flutter-shadcn-input-otp>
Accessible one-time password input with individual character slots.
@example
```html
<flutter-shadcn-input-otp maxlength="6" onchange="handleChange(event)">
  <flutter-shadcn-input-otp-group>
    <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
    <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
    <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
  </flutter-shadcn-input-otp-group>
  <flutter-shadcn-input-otp-separator></flutter-shadcn-input-otp-separator>
  <flutter-shadcn-input-otp-group>
    <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
    <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
    <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
  </flutter-shadcn-input-otp-group>
</flutter-shadcn-input-otp>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnInputOtp
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnInputOtp>
 * ```
 */
export const FlutterShadcnInputOtp = createWebFComponent<FlutterShadcnInputOtpElement, FlutterShadcnInputOtpProps>({
  tagName: 'flutter-shadcn-input-otp',
  displayName: 'FlutterShadcnInputOtp',
  // Map props to attributes
  attributeProps: [
    'maxlength',
    'value',
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
    {
      propName: 'onComplete',
      eventName: 'complete',
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
export interface FlutterShadcnInputOtpGroupProps {
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
export interface FlutterShadcnInputOtpGroupElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-input-otp-group>
Groups OTP slots together visually.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnInputOtpGroup
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnInputOtpGroup>
 * ```
 */
export const FlutterShadcnInputOtpGroup = createWebFComponent<FlutterShadcnInputOtpGroupElement, FlutterShadcnInputOtpGroupProps>({
  tagName: 'flutter-shadcn-input-otp-group',
  displayName: 'FlutterShadcnInputOtpGroup',
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
export interface FlutterShadcnInputOtpSlotProps {
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
export interface FlutterShadcnInputOtpSlotElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-input-otp-slot>
Individual character slot managed by the parent input.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnInputOtpSlot
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnInputOtpSlot>
 * ```
 */
export const FlutterShadcnInputOtpSlot = createWebFComponent<FlutterShadcnInputOtpSlotElement, FlutterShadcnInputOtpSlotProps>({
  tagName: 'flutter-shadcn-input-otp-slot',
  displayName: 'FlutterShadcnInputOtpSlot',
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
export interface FlutterShadcnInputOtpSeparatorProps {
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
export interface FlutterShadcnInputOtpSeparatorElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-input-otp-separator>
Visual separator between OTP groups.
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnInputOtpSeparator
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnInputOtpSeparator>
 * ```
 */
export const FlutterShadcnInputOtpSeparator = createWebFComponent<FlutterShadcnInputOtpSeparatorElement, FlutterShadcnInputOtpSeparatorProps>({
  tagName: 'flutter-shadcn-input-otp-separator',
  displayName: 'FlutterShadcnInputOtpSeparator',
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