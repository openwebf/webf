import { computed, inject, ComputedRef } from 'vue';
import type { RouteContext } from '../types';

/**
 * Extended route context with isActive property
 */
export interface RouteContextWithActive extends RouteContext {
  isActive: boolean;
}

/**
 * Hook to get route context
 *
 * @returns Route context object with isActive property
 *
 * @example
 * ```ts
 * const route = useRouteContext();
 *
 * if (route.value.isActive) {
 *   console.log('This route is currently active');
 *   console.log('Route params:', route.value.routeParams);
 *   console.log('Route state:', route.value.params);
 * }
 * ```
 */
export function useRouteContext(): ComputedRef<RouteContextWithActive> {
  const routeContext = inject<RouteContext>('route-context');
  const routeSpecificContext = inject<ComputedRef<RouteContext>>('route-specific-context');
  
  return computed(() => {
    const context = routeSpecificContext?.value || routeContext;
    
    if (!context) {
      return {
        path: undefined,
        mountedPath: undefined,
        params: undefined,
        routeParams: undefined,
        activePath: undefined,
        routeEventKind: undefined,
        isActive: false
      };
    }
    
    const isActive = context.activePath !== undefined
      && context.mountedPath !== undefined
      && context.activePath === context.mountedPath;
    
    return {
      ...context,
      isActive
    };
  });
}
