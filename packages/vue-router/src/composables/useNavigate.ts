import { WebFRouter } from '../router/WebFRouter';
import type { NavigationMethods, NavigateFunction, NavigateOptions } from '../types';

/**
 * Hook to navigate between routes programmatically
 * 
 * @example
 * ```ts
 * const { navigate, pop, canPop } = useNavigate();
 * 
 * // Simple navigation
 * navigate('/home');
 * 
 * // Navigate with state
 * navigate('/profile', { state: { from: 'login' } });
 * 
 * // Replace current route
 * navigate('/login', { replace: true });
 * 
 * // Go back
 * navigate(-1);
 * 
 * // Conditional navigation
 * if (canPop()) {
 *   pop();
 * } else {
 *   navigate('/');
 * }
 * ```
 */
export function useNavigate(): NavigationMethods {
  function navigate(to: string | number, options?: NavigateOptions): void {
    if (typeof to === 'number') {
      // Handle relative navigation (e.g., -1 for back)
      if (to === -1) {
        WebFRouter.back();
      } else {
        console.warn('Relative navigation other than -1 is not supported yet');
      }
      return;
    }

    // Handle absolute navigation
    if (options?.replace) {
      WebFRouter.replace(to, options.state);
    } else {
      WebFRouter.push(to, options?.state);
    }
  }

  return {
    navigate: navigate as NavigateFunction,
    pop: WebFRouter.pop,
    popUntil: WebFRouter.popUntil,
    popAndPush: WebFRouter.popAndPushNamed,
    pushAndRemoveUntil: WebFRouter.pushNamedAndRemoveUntilRoute,
    canPop: WebFRouter.canPop,
    maybePop: WebFRouter.maybePop
  };
}