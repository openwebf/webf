import { computed, ComputedRef } from 'vue';
import { RouteParams } from '../utils/pathMatcher';
import { useRouteContext } from './useRouteContext';

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
  const context = useRouteContext();

  return computed(() => {
    return context.value.routeParams || {};
  });
}
