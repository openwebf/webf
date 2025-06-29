import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoSearchInputMethods {
  getValue(): string;
  setValue(value: string): void;
  focus(): void;
  blur(): void;
  clear(): void;
}
export interface FlutterCupertinoSearchInputProps {
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
   * disabled property
   * @default undefined
   */
  disabled?: boolean;
  /**
   * type property
   * @default undefined
   */
  type?: string;
  /**
   * prefixIcon property
   * @default undefined
   */
  prefixIcon?: string;
  /**
   * suffixIcon property
   * @default undefined
   */
  suffixIcon?: string;
  /**
   * suffixModel property
   * @default undefined
   */
  suffixModel?: string;
  /**
   * itemColor property
   * @default undefined
   */
  itemColor?: string;
  /**
   * itemSize property
   * @default undefined
   */
  itemSize?: number;
  /**
   * autofocus property
   */
  autofocus: boolean;
  /**
   * input event handler
   */
  onInput?: (event: CustomEvent) => void;
  /**
   * search event handler
   */
  onSearch?: (event: CustomEvent) => void;
  /**
   * clear event handler
   */
  onClear?: (event: CustomEvent) => void;
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
 * const ref = useRef<FlutterCupertinoSearchInputElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterCupertinoSearchInputElement extends WebFElementWithMethods<{
  getValue(): string;
  setValue(value: string): void;
  focus(): void;
  blur(): void;
  clear(): void;
}> {}
/**
 * FlutterCupertinoSearchInput - WebF FlutterCupertinoSearchInput component
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterCupertinoSearchInputElement>(null);
 * 
 * <FlutterCupertinoSearchInput
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoSearchInput>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterCupertinoSearchInput = createWebFComponent<FlutterCupertinoSearchInputElement, FlutterCupertinoSearchInputProps>({
  tagName: 'flutter-cupertino-search-input',
  displayName: 'FlutterCupertinoSearchInput',
  // Map props to attributes
  attributeProps: [
    'val',
    'placeholder',
    'disabled',
    'type',
    'prefixIcon',
    'suffixIcon',
    'suffixModel',
    'itemColor',
    'itemSize',
    'autofocus',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    prefixIcon: 'prefix-icon',
    suffixIcon: 'suffix-icon',
    suffixModel: 'suffix-model',
    itemColor: 'item-color',
    itemSize: 'item-size',
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
      propName: 'onSearch',
      eventName: 'search',
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