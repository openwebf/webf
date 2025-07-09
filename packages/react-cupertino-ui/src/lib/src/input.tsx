import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoInputMethods {
  getValue(): string;
  setValue(value: string): void;
  focus(): void;
  blur(): void;
  clear(): void;
}
export interface FlutterCupertinoInputProps {
  /**
   * val property
   * @default undefined
   */
  val?: string;
  /**
   * placeholder property
   * @default undefined
   */
  placeholder?: string;
  /**
   * type property
   * @default undefined
   */
  type?: string;
  /**
   * disabled property
   * @default undefined
   */
  disabled?: boolean;
  /**
   * autofocus property
   */
  autofocus: boolean;
  /**
   * clearable property
   * @default undefined
   */
  clearable?: boolean;
  /**
   * maxlength property
   * @default undefined
   */
  maxlength?: number;
  /**
   * readonly property
   * @default undefined
   */
  readonly?: boolean;
  /**
   * input event handler
   */
  onInput?: (event: CustomEvent<string>) => void;
  /**
   * submit event handler
   */
  onSubmit?: (event: CustomEvent<string>) => void;
  /**
   * focus event handler
   */
  onFocus?: (event: CustomEvent) => void;
  /**
   * blur event handler
   */
  onBlur?: (event: CustomEvent) => void;
  /**
   * clear event handler
   */
  onClear?: (event: CustomEvent) => void;
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
 * const ref = useRef<FlutterCupertinoInputElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterCupertinoInputElement extends WebFElementWithMethods<{
  getValue(): string;
  setValue(value: string): void;
  focus(): void;
  blur(): void;
  clear(): void;
}> {}
/**
 * FlutterCupertinoInput - WebF FlutterCupertinoInput component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoInputElement>(null);
 * 
 * <FlutterCupertinoInput
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoInput>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterCupertinoInput = createWebFComponent<FlutterCupertinoInputElement, FlutterCupertinoInputProps>({
  tagName: 'flutter-cupertino-input',
  displayName: 'FlutterCupertinoInput',
  // Map props to attributes
  attributeProps: [
    'val',
    'placeholder',
    'type',
    'disabled',
    'autofocus',
    'clearable',
    'maxlength',
    'readonly',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onInput',
      eventName: 'input',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<string>));
      },
    },
    {
      propName: 'onSubmit',
      eventName: 'submit',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<string>));
      },
    },
    {
      propName: 'onFocus',
      eventName: 'focus',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onBlur',
      eventName: 'blur',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onClear',
      eventName: 'clear',
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
export interface FlutterCupertinoInputPrefixProps {
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
export interface FlutterCupertinoInputPrefixElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoInputPrefix - WebF FlutterCupertinoInputPrefix component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoInputPrefix
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoInputPrefix>
 * ```
 */
export const FlutterCupertinoInputPrefix = createWebFComponent<FlutterCupertinoInputPrefixElement, FlutterCupertinoInputPrefixProps>({
  tagName: 'flutter-cupertino-input-prefix',
  displayName: 'FlutterCupertinoInputPrefix',
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
export interface FlutterCupertinoInputSuffixProps {
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
export interface FlutterCupertinoInputSuffixElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoInputSuffix - WebF FlutterCupertinoInputSuffix component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoInputSuffix
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoInputSuffix>
 * ```
 */
export const FlutterCupertinoInputSuffix = createWebFComponent<FlutterCupertinoInputSuffixElement, FlutterCupertinoInputSuffixProps>({
  tagName: 'flutter-cupertino-input-suffix',
  displayName: 'FlutterCupertinoInputSuffix',
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