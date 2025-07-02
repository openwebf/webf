import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoInputMethods {
  getValue(): string;
  setValue(value: string): void;
  focus(): void;
  blur(): void;
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
  onInput?: (event: CustomEvent) => void;
  /**
   * submit event handler
   */
  onSubmit?: (event: CustomEvent) => void;
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
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onSubmit',
      eventName: 'submit',
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