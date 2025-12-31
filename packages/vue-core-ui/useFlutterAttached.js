import { onBeforeUnmount, shallowRef, watch } from 'vue';

/**
 * Vue composable to watch WebF Flutter attachment lifecycle events.
 *
 * Usage:
 *   const el = useFlutterAttached(onAttached, onDetached)
 *   <div :ref="el" />
 */
export function useFlutterAttached(onAttached, onDetached) {
  const elementRef = shallowRef(null);

  watch(
    elementRef,
    (element, _prev, onCleanup) => {
      if (!element) return;

      const handleAttached = (event) => onAttached?.(event);
      const handleDetached = (event) => onDetached?.(event);

      element.addEventListener('onscreen', handleAttached);
      element.addEventListener('offscreen', handleDetached);

      onCleanup(() => {
        element.removeEventListener('onscreen', handleAttached);
        element.removeEventListener('offscreen', handleDetached);
      });
    },
    { flush: 'post' },
  );

  onBeforeUnmount(() => {
    elementRef.value = null;
  });

  return elementRef;
}

export function useFlutterAttachedEffect(callback) {
  return useFlutterAttached(callback);
}

