import React, { createContext, useContext, useMemo, Children, isValidElement, useState, useEffect } from 'react';
import { Route } from './Route';
import { WebFRouter } from './utils';
import { HybridRouterChangeEvent } from '../utils/RouterLink';

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
   * Page state
   * State data passed during route navigation
   */
  params: S | undefined
  /**
   * Current active path from router
   */
  activePath: string | undefined
  /**
   * Route event kind
   */
  routeEventKind?: 'didPushNext' | 'didPush' | 'didPop' | 'didPupNext'
}

/**
 * Route context default value
 */
const RouteContext = createContext<RouteContext>({
  path: undefined,
  params: undefined,
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
  
  // isActive is true only for push events with matching path
  const isActive = (context.routeEventKind === 'didPush' || context.routeEventKind === 'didPushNext') 
    && context.path === context.activePath;
  
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
    // For active routes, return the current location with state
    if (context.isActive) {
      return {
        pathname: context.path || context.activePath || WebFRouter.path,
        state: context.params,
        isActive: true,
        key: `${context.path}-active-${Date.now()}`
      };
    }
    
    // For inactive routes, return the global location without state
    return {
      pathname: context.activePath || WebFRouter.path,
      state: undefined,
      isActive: false,
      key: `${context.activePath}-inactive`
    };
  }, [context.isActive, context.path, context.activePath, context.params]);
  
  return location;
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
function RouteContextProvider({ path, children }: { path: string, children: React.ReactNode }) {
  const globalContext = useContext(RouteContext);
  
  // Create a route-specific context that only updates when this route is active
  const routeSpecificContext = useMemo(() => {
    // Only update if this route is the active one
    if (globalContext.activePath === path) {
      return {
        path,
        params: globalContext.params,
        activePath: globalContext.activePath,
        routeEventKind: globalContext.routeEventKind
      };
    }
    // Return previous values if not active
    return {
      path,
      params: undefined,
      activePath: globalContext.activePath,
      routeEventKind: undefined
    };
  }, [path, globalContext.activePath, globalContext.params, globalContext.routeEventKind]);

  return (
    <RouteContext.Provider value={routeSpecificContext}>
      {children}
    </RouteContext.Provider>
  );
}

export function Routes({ children }: RoutesProps) {
  // State to track current route information
  const [routeState, setRouteState] = useState({
    activePath: WebFRouter.path,
    params: WebFRouter.state,
    routeEventKind: undefined as 'didPushNext' | 'didPush' | 'didPop' | 'didPupNext' | undefined
  });

  // Listen to hybridrouterchange event
  useEffect(() => {
    const handleRouteChange = (event: Event) => {
      const routeEvent = event as unknown as HybridRouterChangeEvent;
      console.log(routeEvent);
      
      // Only update activePath for push events
      const newActivePath = (routeEvent.kind === 'didPushNext' || routeEvent.kind === 'didPush') 
        ? routeEvent.path 
        : routeState.activePath;
      
      // Update state based on event kind
      setRouteState({
        activePath: newActivePath,
        params: routeEvent.state,
        routeEventKind: routeEvent.kind
      });
    };

    // Add event listener
    document.addEventListener('hybridrouterchange', handleRouteChange);

    // Cleanup on unmount
    return () => {
      document.removeEventListener('hybridrouterchange', handleRouteChange);
    };
  }, [routeState.activePath]);

  // Global context value
  const globalContextValue = useMemo(() => ({
    path: undefined,
    params: routeState.params,
    activePath: routeState.activePath,
    routeEventKind: routeState.routeEventKind
  }), [routeState.activePath, routeState.params, routeState.routeEventKind]);

  // Wrap each Route component with its own context provider
  const wrappedChildren = useMemo(() => {
    return Children.map(children, (child: React.ReactNode) => {
      if (!isValidElement(child)) {
        return child;
      }

      // Ensure only Route components are direct children
      if (child.type !== Route) {
        console.warn('Routes component should only contain Route components as direct children');
        return child;
      }

      // Wrap each Route with its own context provider
      const routePath = child.props.path;
      return (
        <RouteContextProvider key={routePath} path={routePath}>
          {child}
        </RouteContextProvider>
      );
    });
  }, [children]);

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