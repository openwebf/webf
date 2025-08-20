import { computed, inject, ComputedRef } from 'vue';
import { WebFRouter } from '../router/WebFRouter';
import type { Location, RouteContext } from '../types';

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
  const routeContext = inject<RouteContext>('route-context');
  const routeSpecificContext = inject<ComputedRef<RouteContext>>('route-specific-context');
  
  return computed(() => {
    const context = routeSpecificContext?.value || routeContext;
    
    if (!context) {
      // Fallback to WebFRouter if no context is provided
      return {
        pathname: WebFRouter.path,
        state: WebFRouter.state,
        isActive: true,
        key: `${WebFRouter.path}-${Date.now()}`
      };
    }
    
    const currentPath = context.path || context.activePath || WebFRouter.path;
    const pathname = currentPath;
    
    // Check if the current component's route matches the active path
    const isCurrentRoute = context.path === context.activePath;
    const isActive = (context.routeEventKind === 'didPush' || context.routeEventKind === 'didPushNext')
      && context.path === context.activePath;
    
    // Get state - prioritize context params, fallback to WebFRouter.state
    const state = (isActive || isCurrentRoute) 
      ? (context.params || WebFRouter.state)
      : WebFRouter.state;
    
    return {
      pathname,
      state,
      isActive,
      key: `${pathname}-${Date.now()}`
    };
  });
}