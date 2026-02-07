/**
 * Router management module
 *
 * Encapsulates routing navigation functionality with route guard mechanism for permission checks
 * Supports both WebF native environment and standard browser environment.
 */
import { getWebFHybridHistory, isWebF } from '../platform';
import { getBrowserHistory } from '../platform/browserHistory';

/**
 * Get the appropriate history object based on the current platform.
 * Returns WebF's hybridHistory in WebF environment, or BrowserHistoryAdapter in browser.
 */
function getHybridHistory(): any {
  const webfHistory = getWebFHybridHistory();
  if (webfHistory) {
    return webfHistory;
  }
  // Fallback to browser history adapter
  return getBrowserHistory();
}

type RoutePath = string;

type EnsureRouteMountedCallback = (pathname: string) => Promise<void> | void;
let ensureRouteMountedCallback: EnsureRouteMountedCallback | null = null;

export function __unstable_setEnsureRouteMountedCallback(callback: EnsureRouteMountedCallback | null) {
  ensureRouteMountedCallback = callback;
}

async function ensureRouteMounted(pathname: string) {
  if (!ensureRouteMountedCallback) return;
  await ensureRouteMountedCallback(pathname);
}

/**
 * Single entry in the hybrid router stack.
 * Mirrors the data returned from webf.hybridHistory.buildContextStack.
 */
export interface HybridRouteStackEntry {
  path: RoutePath;
  state: any;
}

/**
 * WebF Router object - provides comprehensive navigation APIs
 * Combines web-like history management with Flutter-like navigation patterns.
 * Works in both WebF native environment and standard browser environment.
 */
export const WebFRouter = {
  /**
   * Get the current state object associated with the history entry
   */
  get state() {
    return getHybridHistory()?.state;
  },

  /**
   * Get the full hybrid router build context stack.
   * The stack is ordered from root route (index 0) to the current top route (last element).
   */
  get stack(): HybridRouteStackEntry[] {
    return (getHybridHistory()?.buildContextStack as HybridRouteStackEntry[]) ?? [];
  },

  /**
   * Get the current route path
   */
  get path() {
    return (getHybridHistory()?.path as RoutePath) ?? '/'
  },

  /**
   * Navigate to a specified route
   * Applies route guards for permission checks before navigation
   */
  push: async <P extends RoutePath>(path: P, state?: any) => {
    const hybridHistory = getHybridHistory();
    await ensureRouteMounted(path);
    hybridHistory.pushNamed(path, { arguments: state })
  },

  /**
   * Replace the current route without adding to history
   * Applies route guards for permission checks before navigation
   */
  replace: async <P extends RoutePath>(path: P, state?: any) => {
    const hybridHistory = getHybridHistory();
    await ensureRouteMounted(path);
    hybridHistory.pushReplacementNamed(path, { arguments: state});
  },

  /**
   * Navigate back to the previous route
   */
  back: () => {
    const hybridHistory = getHybridHistory();
    hybridHistory.back();
  },

  /**
   * Close the current screen and return to the previous one
   * Flutter-style navigation method
   */
  pop: (result?: any) => {
    const hybridHistory = getHybridHistory();
    hybridHistory.pop(result);
  },

  /**
   * Pop routes until reaching a specific route
   */
  popUntil: (path: RoutePath) => {
    const hybridHistory = getHybridHistory();
    hybridHistory.popUntil(path)
  },

  /**
   * Pop the current route and push a new named route
   */
  popAndPushNamed: async <T extends RoutePath>(path: T, state?: any) => {
    const hybridHistory = getHybridHistory();
    await ensureRouteMounted(path);
    hybridHistory.popAndPushNamed(path, {arguments: state})
  },

  /**
   * Push a new route and remove routes until reaching a specific route
   */
  pushNamedAndRemoveUntil: async <T extends RoutePath>(path: T, state: any, untilPath: RoutePath) => {
    const hybridHistory = getHybridHistory();
    await ensureRouteMounted(path);
    hybridHistory.pushNamedAndRemoveUntil(state, path, untilPath)
  },

  /**
   * Push a new route and remove all routes until a specific route (Flutter-style)
   */
  pushNamedAndRemoveUntilRoute: async <T extends RoutePath>(newPath: T, untilPath: RoutePath, state?: any) => {
    const hybridHistory = getHybridHistory();
    await ensureRouteMounted(newPath);
    hybridHistory.pushNamedAndRemoveUntilRoute(newPath, untilPath, { arguments: state })
  },

  /**
   * Check if the navigator can go back
   */
  canPop: (): boolean => {
    const hybridHistory = getHybridHistory();
    return hybridHistory.canPop();
  },

  /**
   * Pop the current route if possible
   * Returns true if the pop was successful, false otherwise
   */
  maybePop: (result?: any): boolean => {
    const hybridHistory = getHybridHistory();
    return hybridHistory.maybePop(result);
  },

  /**
   * Push a new state to the history stack (web-style navigation)
   */
  pushState: (state: any, name: string) => {
    const hybridHistory = getHybridHistory();
    hybridHistory.pushState(state, name);
  },

  /**
   * Replace the current history entry with a new one (web-style navigation)
   */
  replaceState: (state: any, name: string) => {
    const hybridHistory = getHybridHistory();
    hybridHistory.replaceState(state, name);
  },

  /**
   * Pop and push with restoration capability
   * Returns a restoration ID string
   */
  restorablePopAndPushState: (state: any, name: string): string => {
    const hybridHistory = getHybridHistory();
    return hybridHistory.restorablePopAndPushState(state, name);
  },

  /**
   * Pop and push named route with restoration capability
   * Returns a restoration ID string
   */
  restorablePopAndPushNamed: async <T extends RoutePath>(path: T, state?: any): Promise<string> => {
    const hybridHistory = getHybridHistory();
    await ensureRouteMounted(path);
    return hybridHistory.restorablePopAndPushNamed(path, { arguments: state });
  }
}

/**
 * Route parameters extracted from dynamic routes
 */
export interface RouteParams {
  [key: string]: string;
}

/**
 * Route match result
 */
export interface RouteMatch {
  path: string;
  params: RouteParams;
  isExact: boolean;
}

/**
 * Convert a route pattern to a regular expression
 * @param pattern Route pattern like "/user/:userId" or "/category/:catId/product/:prodId"
 * @returns Object with regex and parameter names
 */
export function pathToRegex(pattern: string): { regex: RegExp; paramNames: string[] } {
  const paramNames: string[] = [];
  
  if (pattern === '*') {
    paramNames.push('*');
    return { regex: /^(.*)$/, paramNames };
  }

  // Escape special regex characters except : and *
  let regexPattern = pattern.replace(/[.+?^${}()|[\]\\]/g, '\\$&');
  
  // Replace :param with named capture groups
  regexPattern = regexPattern.replace(/:([^\/]+)/g, (_, paramName) => {
    paramNames.push(paramName);
    return '([^/]+)';
  });

  // Replace * with a splat capture group (matches across segments)
  regexPattern = regexPattern.replace(/\*/g, () => {
    paramNames.push('*');
    return '(.*)';
  });
  
  // Add anchors for exact matching
  regexPattern = `^${regexPattern}$`;
  
  return {
    regex: new RegExp(regexPattern),
    paramNames
  };
}

/**
 * Match a pathname against a route pattern and extract parameters
 * @param pattern Route pattern like "/user/:userId"
 * @param pathname Actual pathname like "/user/123"
 * @returns Match result with extracted parameters or null if no match
 */
export function matchPath(pattern: string, pathname: string): RouteMatch | null {
  const { regex, paramNames } = pathToRegex(pattern);
  const match = pathname.match(regex);
  
  if (!match) {
    return null;
  }
  
  // Extract parameters from capture groups
  const params: RouteParams = {};
  paramNames.forEach((paramName, index) => {
    params[paramName] = match[index + 1]; // +1 because match[0] is the full match
  });
  
  return {
    path: pattern,
    params,
    isExact: true
  };
}

/**
 * Find the best matching route from a list of route patterns
 * @param routes Array of route patterns
 * @param pathname Current pathname
 * @returns Best match or null if no routes match
 */
export function matchRoutes(routes: string[], pathname: string): RouteMatch | null {
  for (const route of routes) {
    const match = matchPath(route, pathname);
    if (match) {
      return match;
    }
  }
  return null;
}
