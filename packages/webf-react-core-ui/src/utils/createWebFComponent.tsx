import React, { useRef, useEffect, ReactNode, CSSProperties, ForwardedRef } from 'react';

/**
 * Configuration for creating a WebF custom element React component
 */
export interface WebFComponentConfig<TElement extends HTMLElement, TProps> {
  /**
   * The tag name of the custom element (e.g., 'webf-listview')
   */
  tagName: string;

  /**
   * Display name for the React component
   */
  displayName: string;

  /**
   * Map of prop names to their corresponding attribute names
   * @example { scrollDirection: 'scroll-direction' }
   */
  attributeMap?: Record<string, string>;

  /**
   * Event configurations for the component
   */
  events?: Array<{
    /**
     * The prop name for the event handler (e.g., 'onRefresh')
     */
    propName: string;
    
    /**
     * The actual event name to listen for (e.g., 'refresh')
     */
    eventName: string;
    
    /**
     * Optional event handler wrapper
     */
    handler?: (callback: any) => (event: Event) => void;
  }>;

  /**
   * Default values for props
   */
  defaultProps?: Partial<TProps>;

  /**
   * Props that should be passed as attributes (not React props)
   */
  attributeProps?: Array<keyof TProps>;

  /**
   * Props that should be excluded from being passed to the element
   */
  excludeProps?: Array<keyof TProps>;

  /**
   * Custom imperative handle setup
   */
  imperativeHandle?: (element: TElement | null, ref: ForwardedRef<TElement>) => void;
}

/**
 * Creates a React component wrapper for a WebF custom element
 * 
 * @template TElement - The type of the HTML element
 * @template TProps - The type of the component props
 * 
 * @param config - Configuration for the component
 * @returns A React component that wraps the WebF custom element
 * 
 * @example
 * ```tsx
 * const WebFButton = createWebFComponent<WebFButtonElement, WebFButtonProps>({
 *   tagName: 'webf-button',
 *   displayName: 'WebFButton',
 *   attributeMap: {
 *     isDisabled: 'disabled',
 *   },
 *   events: [
 *     { propName: 'onClick', eventName: 'click' }
 *   ],
 *   defaultProps: {
 *     variant: 'primary'
 *   }
 * });
 * ```
 */
export function createWebFComponent<
  TElement extends HTMLElement = HTMLElement,
  TProps extends Record<string, any> = {}
>(
  config: WebFComponentConfig<TElement, TProps>
): React.ForwardRefExoticComponent<TProps & { className?: string; style?: CSSProperties; children?: ReactNode } & React.RefAttributes<TElement>> {
  const {
    tagName,
    displayName,
    attributeMap = {},
    events = [],
    defaultProps = {},
    attributeProps = [],
    excludeProps = [],
    imperativeHandle
  } = config;

  type ComponentProps = TProps & { className?: string; style?: CSSProperties; children?: ReactNode };
  
  const Component = React.forwardRef<TElement, ComponentProps>(
    (props, ref) => {
      const elementRef = useRef<TElement>(null);
      const { className, style, children, ...restProps } = props;

      // Apply default props
      const mergedProps = { ...defaultProps, ...restProps };

      // Set up imperative handle
      React.useImperativeHandle(ref, () => elementRef.current!, []);
      
      // Custom imperative handle setup if provided
      useEffect(() => {
        if (imperativeHandle && elementRef.current) {
          imperativeHandle(elementRef.current, ref);
        }
      }, [ref]);

      // Set up event listeners
      useEffect(() => {
        const element = elementRef.current;
        if (!element) return;

        const eventHandlers: Array<{ event: string; handler: EventListener }> = [];

        events.forEach(({ propName, eventName, handler }) => {
          const callback = (mergedProps as any)[propName];
          if (callback) {
            const eventHandler = handler ? handler(callback) : () => {
              const result = callback();
              if (result instanceof Promise) {
                result.catch(console.error);
              }
            };
            
            element.addEventListener(eventName, eventHandler);
            eventHandlers.push({ event: eventName, handler: eventHandler });
          }
        });

        return () => {
          eventHandlers.forEach(({ event, handler }) => {
            element.removeEventListener(event, handler);
          });
        };
      }, [mergedProps, events]);

      // Build attributes object
      const attributes: Record<string, string> = {};

      // Convert props to attributes
      Object.entries(mergedProps).forEach(([key, value]) => {
        if (excludeProps.includes(key as keyof TProps)) {
          return;
        }

        // Check if this is an event prop
        const isEventProp = events.some(e => e.propName === key);
        if (isEventProp) {
          return;
        }

        // Check if this should be an attribute
        const attributeName = attributeMap[key] || key;
        if (attributeProps.includes(key as keyof TProps) || attributeMap[key]) {
          attributes[attributeName] = String(value);
        }
      });

      return React.createElement(
        tagName,
        {
          ref: elementRef,
          className,
          style,
          ...attributes,
        },
        children
      );
    }
  );

  Component.displayName = displayName;

  return Component as React.ForwardRefExoticComponent<TProps & { className?: string; style?: CSSProperties; children?: ReactNode } & React.RefAttributes<TElement>>;
}

/**
 * Helper to create event handler wrapper for custom events
 * @param extractor - Function to extract data from the event
 * @returns Event handler wrapper function
 */
export function customEventHandler<T = any>(
  extractor?: (event: CustomEvent) => T
): (callback: (data: T) => void) => (event: Event) => void {
  return (callback) => (event) => {
    const customEvent = event as CustomEvent;
    const data = extractor ? extractor(customEvent) : customEvent.detail;
    callback(data);
  };
}

/**
 * Type helper for WebF element with specific methods
 */
export type WebFElementWithMethods<T extends Record<string, Function>> = HTMLElement & T;