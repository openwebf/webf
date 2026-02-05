/**
 * Browser History Adapter
 *
 * Provides a unified history API that mimics WebF's hybridHistory
 * but uses the standard browser History API under the hood.
 *
 * Supports SSR/Node.js environments by providing memory-based fallback.
 */

export interface BrowserHistoryStackEntry {
  path: string;
  state: any;
  key: string;
}

interface BrowserHistoryState {
  path: string;
  state: any;
  key: string;
  index: number;
}

/**
 * Check if we're in a browser environment
 */
function hasWindow(): boolean {
  return typeof window !== 'undefined' && typeof window.history !== 'undefined';
}

/**
 * Generate a unique key for history entries
 */
function generateKey(): string {
  return Math.random().toString(36).substring(2, 10);
}

/**
 * Browser History implementation that provides WebF-like navigation APIs
 */
class BrowserHistoryAdapter {
  private _stack: BrowserHistoryStackEntry[] = [];
  private _currentIndex: number = -1;
  private _listeners: Set<(event: PopStateEvent) => void> = new Set();
  private _initialized: boolean = false;

  constructor() {
    this._initialize();
  }

  private _initialize() {
    if (this._initialized) return;
    this._initialized = true;

    // SSR/Node.js fallback - use memory-based history
    if (!hasWindow()) {
      const key = generateKey();
      this._stack = [{ path: '/', state: null, key }];
      this._currentIndex = 0;
      return;
    }

    // Initialize with current location
    const initialPath = window.location.pathname || '/';
    const initialState = window.history.state as BrowserHistoryState | null;

    if (initialState?.key) {
      // Restore from existing state
      this._stack = [{ path: initialState.path, state: initialState.state, key: initialState.key }];
      this._currentIndex = 0;
    } else {
      // Fresh start
      const key = generateKey();
      const entry: BrowserHistoryStackEntry = { path: initialPath, state: null, key };
      this._stack = [entry];
      this._currentIndex = 0;

      // Replace current state with our tracked state
      window.history.replaceState(
        { path: initialPath, state: null, key, index: 0 } as BrowserHistoryState,
        '',
        initialPath
      );
    }

    // Listen to popstate events
    window.addEventListener('popstate', this._handlePopState.bind(this));
  }

  private _handlePopState(event: PopStateEvent) {
    const state = event.state as BrowserHistoryState | null;
    if (state?.key) {
      // Find the entry in our stack
      const index = this._stack.findIndex((e) => e.key === state.key);
      if (index !== -1) {
        this._currentIndex = index;
      }
    }

    // Dispatch custom event for Routes component
    this._dispatchRouterChangeEvent(state?.path || window.location.pathname, state?.state, 'didPopNext');
  }

  private _dispatchRouterChangeEvent(path: string, state: any, kind: string) {
    if (typeof document === 'undefined') return;

    const event = new CustomEvent('hybridrouterchange', {
      bubbles: true,
      composed: true,
      detail: { path, state, kind },
    });
    (event as any).path = path;
    (event as any).state = state;
    (event as any).kind = kind;

    document.dispatchEvent(event);
  }

  /**
   * Get the current state
   */
  get state(): any {
    return this._stack[this._currentIndex]?.state ?? null;
  }

  /**
   * Get the current path
   */
  get path(): string {
    return this._stack[this._currentIndex]?.path ?? '/';
  }

  /**
   * Get the full navigation stack
   */
  get buildContextStack(): BrowserHistoryStackEntry[] {
    // Return entries up to current index (simulating WebF's stack behavior)
    return this._stack.slice(0, this._currentIndex + 1);
  }

  /**
   * Push a new named route (WebF-style)
   */
  pushNamed(path: string, options?: { arguments?: any }) {
    const key = generateKey();
    const state = options?.arguments ?? null;
    const newIndex = this._currentIndex + 1;

    // Truncate forward stack if we're in the middle
    this._stack = this._stack.slice(0, newIndex);

    const entry: BrowserHistoryStackEntry = { path, state, key };
    this._stack.push(entry);
    this._currentIndex = newIndex;

    if (hasWindow()) {
      window.history.pushState({ path, state, key, index: newIndex } as BrowserHistoryState, '', path);
    }

    this._dispatchRouterChangeEvent(path, state, 'didPush');
  }

  /**
   * Replace the current route (WebF-style)
   */
  pushReplacementNamed(path: string, options?: { arguments?: any }) {
    const key = generateKey();
    const state = options?.arguments ?? null;

    const entry: BrowserHistoryStackEntry = { path, state, key };
    this._stack[this._currentIndex] = entry;

    if (hasWindow()) {
      window.history.replaceState(
        { path, state, key, index: this._currentIndex } as BrowserHistoryState,
        '',
        path
      );
    }

    this._dispatchRouterChangeEvent(path, state, 'didPush');
  }

  /**
   * Go back in history
   */
  back() {
    if (hasWindow()) {
      window.history.back();
    } else if (this._currentIndex > 0) {
      // Memory-based fallback for SSR
      this._currentIndex--;
      const entry = this._stack[this._currentIndex];
      this._dispatchRouterChangeEvent(entry?.path ?? '/', entry?.state, 'didPopNext');
    }
  }

  /**
   * Pop the current route (Flutter-style)
   */
  pop(result?: any) {
    if (this._currentIndex > 0) {
      if (hasWindow()) {
        window.history.back();
      } else {
        // Memory-based fallback for SSR
        this._currentIndex--;
        const entry = this._stack[this._currentIndex];
        this._dispatchRouterChangeEvent(entry?.path ?? '/', entry?.state, 'didPopNext');
      }
    }
  }

  /**
   * Pop routes until reaching a specific route
   */
  popUntil(targetPath: string) {
    const targetIndex = this._stack.findIndex((e) => e.path === targetPath);
    if (targetIndex !== -1 && targetIndex < this._currentIndex) {
      if (hasWindow()) {
        const delta = targetIndex - this._currentIndex;
        window.history.go(delta);
      } else {
        // Memory-based fallback for SSR
        this._currentIndex = targetIndex;
        const entry = this._stack[this._currentIndex];
        this._dispatchRouterChangeEvent(entry?.path ?? '/', entry?.state, 'didPopNext');
      }
    }
  }

  /**
   * Pop the current route and push a new route
   */
  popAndPushNamed(path: string, options?: { arguments?: any }) {
    const key = generateKey();
    const state = options?.arguments ?? null;

    // Replace current entry
    const entry: BrowserHistoryStackEntry = { path, state, key };
    this._stack[this._currentIndex] = entry;

    if (hasWindow()) {
      window.history.replaceState(
        { path, state, key, index: this._currentIndex } as BrowserHistoryState,
        '',
        path
      );
    }

    this._dispatchRouterChangeEvent(path, state, 'didPush');
  }

  /**
   * Push a new route and remove routes until a specific route
   */
  pushNamedAndRemoveUntil(state: any, path: string, untilPath: string) {
    const targetIndex = this._stack.findIndex((e) => e.path === untilPath);
    if (targetIndex !== -1) {
      // Truncate stack to target and add new entry
      this._stack = this._stack.slice(0, targetIndex + 1);
      this._currentIndex = targetIndex;
    }

    this.pushNamed(path, { arguments: state });
  }

  /**
   * Push a new route and remove all routes until a specific route (Flutter-style)
   */
  pushNamedAndRemoveUntilRoute(newPath: string, untilPath: string, options?: { arguments?: any }) {
    this.pushNamedAndRemoveUntil(options?.arguments, newPath, untilPath);
  }

  /**
   * Check if we can go back
   */
  canPop(): boolean {
    return this._currentIndex > 0;
  }

  /**
   * Pop if possible, return success status
   */
  maybePop(result?: any): boolean {
    if (this.canPop()) {
      this.pop(result);
      return true;
    }
    return false;
  }

  /**
   * Push state (web-style)
   */
  pushState(state: any, name: string) {
    this.pushNamed(name, { arguments: state });
  }

  /**
   * Replace state (web-style)
   */
  replaceState(state: any, name: string) {
    this.pushReplacementNamed(name, { arguments: state });
  }

  /**
   * Pop and push with restoration capability
   */
  restorablePopAndPushState(state: any, name: string): string {
    const key = generateKey();
    this.popAndPushNamed(name, { arguments: state });
    return key;
  }

  /**
   * Pop and push named route with restoration capability
   */
  restorablePopAndPushNamed(path: string, options?: { arguments?: any }): string {
    const key = generateKey();
    this.popAndPushNamed(path, options);
    return key;
  }
}

// Singleton instance
let browserHistoryInstance: BrowserHistoryAdapter | null = null;

/**
 * Get the browser history adapter instance
 */
export function getBrowserHistory(): BrowserHistoryAdapter {
  if (!browserHistoryInstance) {
    browserHistoryInstance = new BrowserHistoryAdapter();
  }
  return browserHistoryInstance;
}

/**
 * Reset the browser history adapter (for testing)
 */
export function resetBrowserHistory(): void {
  browserHistoryInstance = null;
}
