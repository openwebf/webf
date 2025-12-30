import { computed, ComputedRef } from 'vue';
import { WebFRouter } from '../router/WebFRouter';
import type { Location } from '../types';
import { useRouteContext } from './useRouteContext';

/**
 * Hook to get the current location
 * 
 * @returns Current location object with pathname and state
 * 
 * @example
 * ```ts
 * const location = useLocation();
 * 
 * console.log('Current path:', location.value.pathname);
 * console.log('Location state:', location.value.state);
 * console.log('Is active:', location.value.isActive);
 * ```
 */
export function useLocation(): ComputedRef<Location> {
  const context = useRouteContext();

  return computed(() => {
    const pathname = context.value.activePath || WebFRouter.path;
    const state = context.value.isActive
      ? (context.value.params || WebFRouter.state)
      : WebFRouter.state;

    return {
      pathname,
      state,
      isActive: context.value.isActive,
      key: `${pathname}-${Date.now()}`
    };
  });
}
