import { RouteParams, RouteMatch } from '../utils/pathMatcher';

// Re-export path matcher types
export type { RouteParams, RouteMatch };

/**
 * Route context interface
 */
export interface RouteContext {
  /**
   * Page path
   */
  path: string | undefined;
  /**
   * Page state
   */
  params: any | undefined;
  /**
   * Route parameters extracted from dynamic routes
   */
  routeParams: RouteParams | undefined;
  /**
   * Current active path from router
   */
  activePath: string | undefined;
  /**
   * Route event kind
   */
  routeEventKind?: 'didPushNext' | 'didPush' | 'didPop' | 'didPopNext';
}

/**
 * Hybrid router change event
 */
export interface HybridRouterChangeEvent {
  kind: 'didPushNext' | 'didPush' | 'didPop' | 'didPopNext';
  path: string;
  state?: any;
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
   * Whether this location is active
   */
  isActive: boolean;
  /**
   * A unique key for this location
   */
  key?: string;
}

/**
 * Navigation options
 */
export interface NavigateOptions {
  replace?: boolean;
  state?: any;
}

/**
 * Navigation function type
 */
export interface NavigateFunction {
  (to: string, options?: NavigateOptions): void;
  (delta: number): void;
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
  element: any;
  /**
   * Title for the route
   */
  title?: string;
  /**
   * Whether to pre-render this route
   */
  prerender?: boolean;
}