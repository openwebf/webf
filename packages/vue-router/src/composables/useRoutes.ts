import { h, VNode } from 'vue';
import { Route } from '../components/Route';
import { Routes } from '../components/Routes';
import type { RouteObject } from '../types';

/**
 * Hook to create routes from a configuration object
 * 
 * @param routes Array of route configuration objects
 * @returns Vue VNode tree of Routes and Route components
 * 
 * @example
 * ```ts
 * import HomePage from './pages/HomePage.vue';
 * import AboutPage from './pages/AboutPage.vue';
 * 
 * const routes = useRoutes([
 *   { path: '/', element: HomePage, title: 'Home' },
 *   { path: '/about', element: AboutPage, title: 'About' },
 *   { path: '/users', element: 'UsersPage', title: 'Users' }, // String for lazy loading
 *   { path: '/contact', element: ContactPage, prerender: true }
 * ]);
 * ```
 */
export function useRoutes(routes: RouteObject[]): VNode | null {
  if (!routes || routes.length === 0) {
    return null;
  }
  
  const routeElements = routes.map((route) => {
    if (route.children && route.children.length > 0) {
      console.warn('Nested routes are not supported yet');
    }

    return h(Route, {
      key: route.path,
      path: route.path,
      title: route.title,
      element: route.element,
      prerender: route.prerender,
      theme: route.theme,
    });
  });

  return h(Routes, null, { default: () => routeElements });
}
