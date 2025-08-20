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
 * const { params, path, isActive, routeParams } = useRouteContext();
 * 
 * if (isActive.value) {
 *   console.log('This route is currently active');
 *   console.log('Route params:', routeParams.value);
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
        params: undefined,
        routeParams: undefined,
        activePath: undefined,
        routeEventKind: undefined,
        isActive: false
      };
    }
    
    // isActive is true only for push events with matching path
    const isActive = (context.routeEventKind === 'didPush' || context.routeEventKind === 'didPushNext')
      && context.path === context.activePath;
    
    return {
      ...context,
      isActive
    };
  });
}