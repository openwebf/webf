/**
 * Router management module
 *
 * Encapsulates routing navigation functionality with route pre-mount mechanism.
 * Supports both WebF and browser environments through platform abstraction.
 *
 * In WebF: Uses hybridHistory API from @openwebf/webf-enterprise-typings
 * In Browser: Uses standard History API with WebF-compatible adapter
 */
import { isWebF, getWebFHybridHistory } from '../platform';
import { getBrowserHistory } from '../platform/browserHistory';

type RoutePath = string;

/**
 * Get the appropriate history implementation based on platform.
 * Returns WebF's hybridHistory in WebF environment, or browser adapter otherwise.
 */
function getHybridHistory(): any {
  if (isWebF()) {
    return getWebFHybridHistory();
  }
  return getBrowserHistory();
}

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
 * Combines web-like history management with Flutter-like navigation patterns
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
    return (getHybridHistory()?.path as RoutePath) ?? '/';
  },

  /**
   * Navigate to a specified route
   */
  push: async <P extends RoutePath>(path: P, state?: any) => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    await ensureRouteMounted(path);
    hybridHistory.pushNamed(path, { arguments: state });
  },

  /**
   * Replace the current route without adding to history
   */
  replace: async <P extends RoutePath>(path: P, state?: any) => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    await ensureRouteMounted(path);
    hybridHistory.pushReplacementNamed(path, { arguments: state });
  },

  /**
   * Navigate back to the previous route
   */
  back: () => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    hybridHistory.back();
  },

  /**
   * Close the current screen and return to the previous one
   * Flutter-style navigation method
   */
  pop: (result?: any) => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    hybridHistory.pop(result);
  },

  /**
   * Pop routes until reaching a specific route
   */
  popUntil: (path: RoutePath) => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    hybridHistory.popUntil(path);
  },

  /**
   * Pop the current route and push a new named route
   */
  popAndPushNamed: async <T extends RoutePath>(path: T, state?: any) => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    await ensureRouteMounted(path);
    hybridHistory.popAndPushNamed(path, { arguments: state });
  },

  /**
   * Push a new route and remove routes until reaching a specific route
   */
  pushNamedAndRemoveUntil: async <T extends RoutePath>(path: T, state: any, untilPath: RoutePath) => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    await ensureRouteMounted(path);
    hybridHistory.pushNamedAndRemoveUntil(state, path, untilPath);
  },

  /**
   * Push a new route and remove all routes until a specific route (Flutter-style)
   */
  pushNamedAndRemoveUntilRoute: async <T extends RoutePath>(newPath: T, untilPath: RoutePath, state?: any) => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    await ensureRouteMounted(newPath);
    hybridHistory.pushNamedAndRemoveUntilRoute(newPath, untilPath, { arguments: state });
  },

  /**
   * Check if the navigator can go back
   */
  canPop: (): boolean => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) return false;
    return hybridHistory.canPop();
  },

  /**
   * Pop the current route if possible
   * Returns true if the pop was successful, false otherwise
   */
  maybePop: (result?: any): boolean => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) return false;
    return hybridHistory.maybePop(result);
  },

  /**
   * Push a new state to the history stack (web-style navigation)
   */
  pushState: (state: any, name: string) => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    hybridHistory.pushState(state, name);
  },

  /**
   * Replace the current history entry with a new one (web-style navigation)
   */
  replaceState: (state: any, name: string) => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    hybridHistory.replaceState(state, name);
  },

  /**
   * Pop and push with restoration capability
   * Returns a restoration ID string
   */
  restorablePopAndPushState: (state: any, name: string): string => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    return hybridHistory.restorablePopAndPushState(state, name);
  },

  /**
   * Pop and push named route with restoration capability
   * Returns a restoration ID string
   */
  restorablePopAndPushNamed: async <T extends RoutePath>(path: T, state?: any): Promise<string> => {
    const hybridHistory = getHybridHistory();
    if (!hybridHistory) throw new Error('WebF hybridHistory is not available');
    await ensureRouteMounted(path);
    return hybridHistory.restorablePopAndPushNamed(path, { arguments: state });
  }
};
