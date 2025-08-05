import { computed, inject, ComputedRef } from 'vue';
import type { RouteContext } from '../types';
import { RouteParams } from '../utils/pathMatcher';

/**
 * Hook to get route parameters from dynamic routes
 * 
 * @returns Route parameters object with parameter names as keys and values as strings
 * 
 * @example
 * ```ts
 * // For route pattern "/user/:userId" and actual path "/user/123"
 * const params = useParams();
 * 
 * console.log(params.value.userId); // "123"
 * ```
 */
export function useParams(): ComputedRef<RouteParams> {
  const routeContext = inject<RouteContext>('route-context');
  const routeSpecificContext = inject<ComputedRef<RouteContext>>('route-specific-context');
  
  return computed(() => {
    const context = routeSpecificContext?.value || routeContext;
    return context?.routeParams || {};
  });
}