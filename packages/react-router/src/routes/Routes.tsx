import React, { createContext, useContext, useMemo, Children, isValidElement, useState, useEffect, useRef } from 'react';
import { Route } from './Route';
import { __unstable_setEnsureRouteMountedCallback, WebFRouter, matchPath } from './utils';
import type { HybridRouteStackEntry, RouteMatch, RouteParams } from './utils';
import type { HybridRouterChangeEvent } from '../utils/RouterLink';

/**
 * Route context interface
 *
 * Provides page route related state and methods, accessed through the useRouteContext hook
 *
 * @template S - Page state type, defaults to undefined
 */
interface RouteContext<S = any> {
  /**
   * Page path
   * Current route path, corresponds to RoutePath enum
   */
  path: string | undefined
  /**
   * The concrete mounted path for this route instance (e.g. `/users/123`).
   */
  mountedPath: string | undefined
  /**
   * Page state
   * State data passed during route navigation
   */
  params: S | undefined
  /**
   * Route parameters extracted from dynamic routes (e.g., :userId in /user/:userId)
   */
  routeParams: RouteParams | undefined
  /**
   * Current active path from router
   */
  activePath: string | undefined
  /**
   * Route event kind
   */
  routeEventKind?: 'didPushNext' | 'didPush' | 'didPop' | 'didPopNext'
}

/**
 * Route context default value
 */
const RouteContext = createContext<RouteContext>({
  path: undefined,
  mountedPath: undefined,
  params: undefined,
  routeParams: undefined,
  activePath: undefined,
  routeEventKind: undefined
});

/**
 * Hook to get route context
 *
 * Use generic parameters to specify the route path and automatically infer the corresponding state type
 *
 * @template T - Route path type, must be a member of the RoutePath enum
 * @returns Type-safe route context object
 *
 * @example
 * ```tsx
 * const { params, path, isActive } = useRouteContext();
 * ```
 */
export function useRouteContext() {
  const context = useContext<RouteContext>(RouteContext);

  const isActive = context.activePath !== undefined
    && context.mountedPath !== undefined
    && context.activePath === context.mountedPath;

  return {
    ...context,
    isActive
  };
}

/**
 * Location object interface
 */
export interface Location {
  /**
   * The path of the current location
   */
  pathname: string;
  /**
   * The state object associated with this location
   */
  state: any;
  /**
   * A unique key for this location
   */
  key?: string;
}

/**
 * Hook to get the current location
 * 
 * @returns Current location object with pathname and state
 * 
 * @example
 * ```tsx
 * function MyComponent() {
 *   const location = useLocation();
 *   
 *   console.log('Current path:', location.pathname);

 *   console.log('Location state:', location.state);
 *   console.log('Is active:', location.isActive);
 *   
 *   return <div>Current path: {location.pathname}</div>;
 * }
 * ```
 */
export function useLocation(): Location & { isActive: boolean } {
  const context = useRouteContext();

  // Create location object from context
  const location = useMemo(() => {
    const pathname = context.activePath || WebFRouter.path;
    
    // Get state - prioritize context params, fallback to WebFRouter.state
    const state = context.isActive
      ? (context.params || WebFRouter.state)
      : WebFRouter.state;
    
    return {
      pathname,
      state,
      isActive: context.isActive,
      key: `${pathname}-${Date.now()}`
    };
  }, [context.isActive, context.activePath, context.params]);

  return location;
}

/**
 * Hook to get route parameters from dynamic routes
 * 
 * @returns Route parameters object with parameter names as keys and values as strings
 * 
 * @example
 * ```tsx
 * // For route pattern "/user/:userId" and actual path "/user/123"
 * function UserPage() {
 *   const params = useParams();
 *   
 *   console.log(params.userId); // "123"
 *   
 *   return <div>User ID: {params.userId}</div>;
 * }
 * ```
 */
export function useParams(): RouteParams {
  const context = useRouteContext();
  
  return useMemo(() => {
    return context.routeParams || {};
  }, [context.routeParams]);
}

/**
 * Route configuration object
 */
export interface RouteObject {
  /**
   * Path for the route
   */
  path: string;
  /**
   * Element to render for this route
   */
  element: React.ReactNode;
  /**
   * Whether to pre-render this route
   */
  prerender?: boolean;
  /**
   * Theme for this route
   *
   * @default "material"
   */
  theme?: 'material' | 'cupertino';
  /**
   * Child routes (not supported yet)
   */
  children?: RouteObject[];
}

/**
 * Props for the Routes component
 */
export interface RoutesProps {
  /**
   * Route components as children
   */
  children: React.ReactNode;
}

/**
 * Routes component that wraps multiple Route components and provides shared context
 * 
 * @example
 * ```tsx
 * <Routes sharedData={{ user: currentUser, theme: 'dark' }}>
 *   <Route path="/" element={<Home />} />
 *   <Route path="/about" element={<About />} />
 *   <Route path="/profile" element={<Profile />} />
 * </Routes>
 * ```
 */
/**
 * Route-specific context provider that only updates when the route is active
 */
function RouteContextProvider({
  patternPath,
  mountedPath,
  children,
}: {
  patternPath: string;
  mountedPath: string;
  children: React.ReactNode;
}) {
  const globalContext = useContext(RouteContext);

  // Create a route-specific context that only updates when this route is active
  const routeSpecificContext = useMemo(() => {
    const isActive = globalContext.activePath !== undefined && globalContext.activePath === mountedPath;
    const match = isActive ? matchPath(patternPath, mountedPath) : null;

    if (isActive && match) {
      const effectiveParams = globalContext.params !== undefined ? globalContext.params : WebFRouter.state;

      return {
        path: patternPath,
        mountedPath,
        params: effectiveParams,
        routeParams: match.params,
        activePath: globalContext.activePath,
        routeEventKind: globalContext.routeEventKind
      };
    }

    return {
      path: patternPath,
      mountedPath,
      params: undefined,
      routeParams: undefined,
      activePath: globalContext.activePath,
      routeEventKind: undefined
    };
  }, [patternPath, mountedPath, globalContext.activePath, globalContext.params, globalContext.routeEventKind]);

  return (
    <RouteContext.Provider value={routeSpecificContext}>
      {children}
    </RouteContext.Provider>
  );
}

function patternScore(pattern: string): number {
  if (pattern === '*') return 0;
  const segments = pattern.split('/').filter(Boolean);
  let score = 0;
  for (const segment of segments) {
    if (segment === '*') score += 1;
    else if (segment.startsWith(':')) score += 2;
    else score += 3;
  }
  return score * 100 + segments.length;
}

function findBestMatch(patterns: string[], pathname: string): RouteMatch | null {
  let best: { match: RouteMatch; score: number } | null = null;
  for (const pattern of patterns) {
    const match = matchPath(pattern, pathname);
    if (!match) continue;
    const score = patternScore(pattern);
    if (!best || score > best.score) best = { match, score };
  }
  return best?.match ?? null;
}

function escapeAttributeValue(value: string): string {
  return value.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

export function Routes({ children }: RoutesProps) {
  // State to track current route information
  const [routeState, setRouteState] = useState<RouteContext>({
    path: undefined,
    mountedPath: undefined,
    activePath: WebFRouter.path, // Initialize with current path
    params: undefined,
    routeParams: undefined,
    routeEventKind: undefined
  });

  const [stack, setStack] = useState<HybridRouteStackEntry[]>(() => WebFRouter.stack);
  const [preMountedPaths, setPreMountedPaths] = useState<string[]>([]);

  const routePatternsRef = useRef<string[]>([]);
  const pendingEnsureResolversRef = useRef<Map<string, Array<() => void>>>(new Map());

  // Keep a stable view of declared route patterns for event handlers.
  useEffect(() => {
    const patterns: string[] = [];
    Children.forEach(children, (child: React.ReactNode) => {
      if (!isValidElement(child)) return;
      if (child.type !== Route) return;
      patterns.push(child.props.path);
    });
    routePatternsRef.current = patterns;
  }, [children]);
  
  // Listen to hybridrouterchange event
  useEffect(() => {
    const handleRouteChange = (event: Event) => {
      const routeEvent = event as unknown as HybridRouterChangeEvent;
      
      // Check for new event detail structure with params
      const eventDetail = (event as any).detail;

      const newActivePath = WebFRouter.path;
      const newStack = WebFRouter.stack;
      setStack(newStack);
      setPreMountedPaths((prev) => prev.filter((p) => newStack.some((entry) => entry.path === p)));

      const bestMatch = newActivePath ? findBestMatch(routePatternsRef.current, newActivePath) : null;
      const routeParams = eventDetail?.params || bestMatch?.params || undefined;

      const activeEntry = [...newStack].reverse().find((entry) => entry.path === newActivePath);
      const eventState = activeEntry?.state ?? eventDetail?.state ?? routeEvent.state ?? WebFRouter.state;

      // Update state based on event kind
      setRouteState({
        path: routeEvent.path,
        mountedPath: routeEvent.path,
        activePath: newActivePath,
        params: eventState,
        routeParams: routeParams, // Use params from Flutter if available
        routeEventKind: routeEvent.kind
      });
    };

    // Add event listener
    document.addEventListener('hybridrouterchange', handleRouteChange);

    // Cleanup on unmount
    return () => {
      document.removeEventListener('hybridrouterchange', handleRouteChange);
    };
  }, []);

  useEffect(() => {
    __unstable_setEnsureRouteMountedCallback((pathname: string) => {
      if (!pathname) return;

      const bestMatch = findBestMatch(routePatternsRef.current, pathname);
      if (!bestMatch) return;

      const selector = `webf-router-link[path="${escapeAttributeValue(pathname)}"]`;
      if (document.querySelector(selector)) return;

      let resolveFn: (() => void) | undefined;
      const promise = new Promise<void>((resolve) => {
        resolveFn = resolve;
      });

      pendingEnsureResolversRef.current.set(pathname, [
        ...(pendingEnsureResolversRef.current.get(pathname) ?? []),
        resolveFn!,
      ]);

      setPreMountedPaths((prev) => (prev.includes(pathname) ? prev : [...prev, pathname]));

      return promise;
    });

    return () => {
      __unstable_setEnsureRouteMountedCallback(null);
    };
  }, []);

  useEffect(() => {
    const pending = pendingEnsureResolversRef.current;
    for (const [pathname, resolvers] of pending.entries()) {
      const selector = `webf-router-link[path="${escapeAttributeValue(pathname)}"]`;
      if (!document.querySelector(selector)) continue;
      for (const resolve of resolvers) resolve();
      pending.delete(pathname);
    }
  }, [children, stack, preMountedPaths, routeState.activePath]);

  // Global context value
  const globalContextValue = useMemo(() => ({
    path: undefined,
    mountedPath: undefined,
    params: routeState.params,
    routeParams: routeState.routeParams, // Pass through route params from Flutter
    activePath: routeState.activePath,
    routeEventKind: routeState.routeEventKind
  }), [routeState.activePath, routeState.params, routeState.routeParams, routeState.routeEventKind]);

  const wrappedChildren = useMemo(() => {
    const declaredRoutes: React.ReactElement[] = [];
    const patterns: string[] = [];
    const declaredPaths = new Set<string>();

    Children.forEach(children, (child: React.ReactNode) => {
      if (!isValidElement(child)) {
        declaredRoutes.push(child as any);
        return;
      }

      if (child.type !== Route) {
        console.warn('Routes component should only contain Route components as direct children');
        declaredRoutes.push(child);
        return;
      }

      const patternPath: string = child.props.path;
      patterns.push(patternPath);
      declaredPaths.add(patternPath);
      const mountedPath: string = child.props.mountedPath ?? patternPath;

      declaredRoutes.push(
        <RouteContextProvider key={`declared:${patternPath}`} patternPath={patternPath} mountedPath={mountedPath}>
          {child}
        </RouteContextProvider>
      );
    });

    const mountedPaths: string[] = [];
    for (const entry of stack) mountedPaths.push(entry.path);
    for (const path of preMountedPaths) mountedPaths.push(path);
    if (routeState.activePath && !mountedPaths.includes(routeState.activePath)) mountedPaths.push(routeState.activePath);

    const dynamicRoutes: React.ReactElement[] = [];
    const seenMountedPaths = new Set<string>();
    for (const mountedPath of mountedPaths) {
      if (seenMountedPaths.has(mountedPath)) continue;
      seenMountedPaths.add(mountedPath);
      if (declaredPaths.has(mountedPath)) continue;

      const bestMatch = findBestMatch(patterns, mountedPath);
      if (!bestMatch) continue;

      const matchingRouteElement = Children.toArray(children).find((node) => {
        if (!isValidElement(node)) return false;
        if (node.type !== Route) return false;
        return node.props.path === bestMatch.path;
      }) as React.ReactElement | undefined;

      if (!matchingRouteElement) continue;

      const routeInstance = React.cloneElement(matchingRouteElement, {
        mountedPath,
      });

      dynamicRoutes.push(
        <RouteContextProvider key={`dynamic:${mountedPath}`} patternPath={bestMatch.path} mountedPath={mountedPath}>
          {routeInstance}
        </RouteContextProvider>
      );
    }

    return [...declaredRoutes, ...dynamicRoutes];
  }, [children, stack, preMountedPaths, routeState.activePath]);

  return (
    <RouteContext.Provider value={globalContextValue}>
      {wrappedChildren}
    </RouteContext.Provider>
  );
}

/**
 * Hook to create routes from a configuration object
 * 
 * @param routes Array of route configuration objects
 * @returns React element tree of Routes and Route components
 * 
 * @example
 * ```tsx
 * function App() {
 *   const routes = useRoutes([
 *     { path: '/', element: <Home /> },
 *     { path: '/about', element: <About /> },
 *     { path: '/users', element: <Users /> },
 *     { path: '/contact', element: <Contact /> }
 *   ]);
 *   
 *   return routes;
 * }
 * ```
 */
export function useRoutes(routes: RouteObject[]): React.ReactElement | null {
  // Convert route objects to Route components
  const routeElements = useMemo(() => {
    return routes.map((route) => {
      if (route.children && route.children.length > 0) {
        console.warn('Nested routes are not supported yet');
      }

      return (
        <Route
          key={route.path}
          path={route.path}
          element={route.element}
          prerender={route.prerender}
          theme={route.theme}
        />
      );
    });
  }, [routes]);

  // Return Routes component with Route children
  return <Routes>{routeElements}</Routes>;
}


/**
 * Navigation function type
 */
export interface NavigateFunction {
  (to: string, options?: NavigateOptions): void;
  (delta: number): void;
}

/**
 * Navigation options
 */
export interface NavigateOptions {
  replace?: boolean;
  state?: any;
}

/**
 * Extended navigation object with additional methods
 */
export interface NavigationMethods {
  /**
   * Navigate to a route or go back
   */
  navigate: NavigateFunction;

  /**
   * Close the current screen and return to the previous one
   */
  pop: (result?: any) => void;

  /**
   * Pop routes until reaching a specific route
   */
  popUntil: (path: string) => void;

  /**
   * Pop the current route and push a new route
   */
  popAndPush: (path: string, state?: any) => Promise<void>;

  /**
   * Push a new route and remove all routes until a specific route
   */
  pushAndRemoveUntil: (newPath: string, untilPath: string, state?: any) => Promise<void>;

  /**
   * Check if the navigator can go back
   */
  canPop: () => boolean;

  /**
   * Pop the current route if possible
   */
  maybePop: (result?: any) => boolean;
}

/**
 * Hook to navigate between routes programmatically
 * 
 * @example
 * ```tsx
 * function LoginPage() {
 *   const { navigate, pop, canPop } = useNavigate();
 *   
 *   const handleLogin = async () => {
 *     await login();
 *     navigate('/dashboard');
 *   };
 *   
 *   const handleReplace = () => {
 *     navigate('/home', { replace: true });
 *   };
 *   
 *   const handleWithState = () => {
 *     navigate('/profile', { state: { from: 'login' } });
 *   };
 *   
 *   const goBack = () => {
 *     if (canPop()) {
 *       pop();
 *     } else {
 *       navigate('/');
 *     }
 *   };
 * }
 * ```
 */
export function useNavigate(): NavigationMethods {
  return useMemo(() => {
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
  }, []);
}
