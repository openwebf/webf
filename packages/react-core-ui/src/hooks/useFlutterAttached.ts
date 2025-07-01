import { useEffect, useRef, useCallback } from 'react';

export type FlutterAttachedCallback = (event: Event) => void;
export type FlutterDetachedCallback = (event: Event) => void;

/**
 * Hook that returns a ref callback for listening to Flutter render attachment events.
 * 
 * The `onscreen` event fires when the DOM element has been fully rendered by Flutter
 * (layout and painting complete). The `offscreen` event fires when the element is
 * detached from Flutter's render tree.
 * 
 * @param onAttached - Callback when element is attached to Flutter's render tree
 * @param onDetached - Optional callback when element is detached from Flutter's render tree
 * @returns A ref callback to attach to the element you want to monitor
 * 
 * @example
 * ```tsx
 * function MyComponent() {
 *   const flutterRef = useFlutterAttached(
 *     () => {
 *       console.log('Component is now rendered by Flutter');
 *     },
 *     () => {
 *       console.log('Component is detached from Flutter render tree');
 *     }
 *   );
 * 
 *   return <div ref={flutterRef}>Content</div>;
 * }
 * ```
 */
export function useFlutterAttached(
  onAttached: FlutterAttachedCallback,
  onDetached?: FlutterDetachedCallback
) {
  const elementRef = useRef<HTMLElement | null>(null);
  const callbacksRef = useRef({ onAttached, onDetached });
  callbacksRef.current = { onAttached, onDetached };

  useEffect(() => {
    const element = elementRef.current;
    if (!element) return;

    const handleAttached = (event: Event) => {
      callbacksRef.current.onAttached(event);
    };

    const handleDetached = (event: Event) => {
      callbacksRef.current.onDetached?.(event);
    };

    element.addEventListener('onscreen', handleAttached);
    element.addEventListener('offscreen', handleDetached);

    return () => {
      element.removeEventListener('onscreen', handleAttached);
      element.removeEventListener('offscreen', handleDetached);
    };
  }, []);

  // Return a ref callback
  const refCallback = useCallback((node: HTMLElement | null) => {
    elementRef.current = node;
  }, []);

  return refCallback;
}

/**
 * Simplified version of useFlutterAttached that only listens for the attached event.
 * 
 * @param callback - Function to call when element is attached to Flutter's render tree
 * @returns A ref callback to attach to the element you want to monitor
 * 
 * @example
 * ```tsx
 * function MyComponent() {
 *   const flutterRef = useFlutterAttachedEffect(() => {
 *     console.log('Component is now rendered by Flutter');
 *   });
 * 
 *   return <div ref={flutterRef}>Content</div>;
 * }
 * ```
 */
export function useFlutterAttachedEffect(callback: FlutterAttachedCallback) {
  return useFlutterAttached(callback);
}