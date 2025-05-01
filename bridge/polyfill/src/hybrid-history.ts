/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import {webf} from './webf';

/**
 * Interface for managing navigation history in hybrid applications
 * Provides both web-like history API and Flutter-like navigation methods
 */
export interface HybridHistoryInterface {
  // State management
  /** Current state object associated with the history entry */
  readonly state: any;
  /** Current path of the history entry */
  readonly path: string;

  // Original API methods
  /**
   * Navigate back to the previous history entry
   */
  back(): void;

  /**
   * Push a new state to the history stack
   * @param state State object to associate with the new history entry
   * @param name Route name for the new history entry
   */
  pushState(state: any, name: string): void;

  /**
   * Replace the current history entry with a new one
   * @param state State object to associate with the new history entry
   * @param name Route name for the new history entry
   */
  replaceState(state: any, name: string): void;

  /**
   * Pop the current route and push a new one, with ability to restore
   * @param state State object to associate with the new history entry
   * @param name Route name for the new history entry
   * @returns A restoration identifier that can be used to restore this state later
   */
  restorablePopAndPushState(state: any, name: string): string;

  // Flutter-like API methods
  /**
   * Close the current screen and return to the previous one
   * @param result Optional result to pass back to the previous screen
   */
  pop(result?: any): void;

  /**
   * Navigate to a named route
   * @param routeName Name of the route to navigate to
   * @param options Additional options like arguments to pass to the route
   */
  pushNamed(routeName: string, options?: { arguments?: any }): void;

  /**
   * Replace the current route with a new named route
   * @param routeName Name of the route to navigate to
   * @param options Additional options like arguments to pass to the route
   */
  pushReplacementNamed(routeName: string, options?: { arguments?: any }): void;

  /**
   * Pop the current route and push a new one, with ability to restore
   * @param routeName Name of the route to navigate to
   * @param options Additional options like arguments to pass to the route
   * @returns A restoration identifier that can be used to restore this state later
   */
  restorablePopAndPushNamed(routeName: string, options?: { arguments?: any }): string;

  // Utility methods
  /**
   * Check if the navigator can go back
   * @returns True if there are routes that can be popped, false otherwise
   */
  canPop(): boolean;

  /**
   * Pop the current route if possible
   * @param result Optional result to pass back to the previous screen
   * @returns True if the route was popped, false otherwise
   */
  maybePop(result?: any): boolean;

  /**
   * Pop the current route and push a new named route
   * @param routeName Name of the route to navigate to
   * @param options Additional options like arguments to pass to the route
   */
  popAndPushNamed(routeName: string, options?: { arguments?: any }): void;

  /**
   * Pop routes until reaching a specific route
   * @param routeName Name of the route to stop at
   */
  popUntil(routeName: string): void;

  /**
   * Push a new route and remove routes until reaching a specific route
   * @param state State object to associate with the new route
   * @param newRouteName Name of the new route to navigate to
   * @param untilRouteName Name of the route to stop removing at
   */
  pushNamedAndRemoveUntil(state: any, newRouteName: string, untilRouteName: string): void;

  /**
   * Flutter-style method to push a new route and remove routes until reaching a specific route
   * @param newRouteName Name of the new route to navigate to
   * @param untilRouteName Name of the route to stop removing at
   * @param options Additional options like arguments to pass to the route
   */
  pushNamedAndRemoveUntilRoute(newRouteName: string, untilRouteName: string, options?: { arguments?: any }): void;
}

/**
 * Implementation of HybridHistory providing both web-like and Flutter-like navigation APIs
 */
class HybridHistory implements HybridHistoryInterface {
  // State management
  /**
   * Get the current state object associated with the history entry
   * @returns Current state as a parsed JSON object
   */
  get state() {
    return JSON.parse(webf.invokeModule('HybridHistory', 'state'));
  }

  /**
   * Get the current path of the history entry
   * @returns Current path as a string
   */
  get path() {
    return webf.invokeModule('HybridHistory', 'path');
  }

  // Original API methods - kept for backward compatibility
  /**
   * Navigate back to the previous history entry
   */
  back() {
    webf.invokeModule('HybridHistory', 'back');
  }

  /**
   * Push a new state to the history stack
   * @param state State object to associate with the new history entry
   * @param name Route name for the new history entry
   * @throws TypeError if arguments are missing
   */
  pushState(state: any, name: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'pushState', state, name);
  }

  /**
   * Replace the current history entry with a new one
   * @param state State object to associate with the new history entry
   * @param name Route name for the new history entry
   * @throws TypeError if arguments are missing
   */
  replaceState(state: any, name: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'replaceState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'replaceState', state, name);
  }

  /**
   * Pop the current route and push a new one, with ability to restore
   * @param state State object to associate with the new history entry
   * @param name Route name for the new history entry
   * @returns A restoration identifier that can be used to restore this state later
   * @throws TypeError if arguments are missing
   */
  restorablePopAndPushState(state: any, name: string): string {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'restorablePopAndPushState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }
    return webf.invokeModule('HybridHistory', 'restorablePopAndPushState', state, name);
  }

  // New Flutter-like API methods
  /**
   * Close the current screen and return to the previous one
   * @param result Optional result to pass back to the previous screen
   */
  pop(result?: any) {
    webf.invokeModule('HybridHistory', 'pop', result !== undefined ? result : null);
  }

  /**
   * Navigate to a named route
   * @param routeName Name of the route to navigate to
   * @param options Additional options like arguments to pass to the route
   * @throws TypeError if arguments are missing
   */
  pushNamed(routeName: string, options: { arguments?: any } = {}) {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'pushNamed' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    if (options.arguments !== undefined) {
      webf.invokeModule('HybridHistory', 'pushNamed', routeName, options.arguments);
    } else {
      webf.invokeModule('HybridHistory', 'pushNamed', routeName);
    }
  }

  /**
   * Replace the current route with a new named route
   * @param routeName Name of the route to navigate to
   * @param options Additional options like arguments to pass to the route
   * @throws TypeError if arguments are missing
   */
  pushReplacementNamed(routeName: string, options: { arguments?: any } = {}) {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'pushReplacementNamed' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'pushReplacementNamed', routeName, options.arguments !== undefined ? options.arguments : null);
  }

  /**
   * Pop the current route and push a new one, with ability to restore
   * @param routeName Name of the route to navigate to
   * @param options Additional options like arguments to pass to the route
   * @returns A restoration identifier that can be used to restore this state later
   * @throws TypeError if arguments are missing
   */
  restorablePopAndPushNamed(routeName: string, options: { arguments?: any } = {}): string {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'restorablePopAndPushNamed' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    return webf.invokeModule('HybridHistory', 'restorablePopAndPushNamed', routeName, options.arguments !== undefined ? options.arguments : null);
  }

  // Utility methods
  /**
   * Check if the navigator can go back
   * @returns True if there are routes that can be popped, false otherwise
   */
  canPop(): boolean {
    return webf.invokeModule('HybridHistory', 'canPop') === 'true';
  }

  /**
   * Pop the current route if possible
   * @param result Optional result to pass back to the previous screen
   * @returns True if the route was popped, false otherwise
   */
  maybePop(result?: any): boolean {
    return webf.invokeModule('HybridHistory', 'maybePop', result !== undefined ? result : null) === 'true';
  }

  /**
   * Pop the current route and push a new named route
   * @param routeName Name of the route to navigate to
   * @param options Additional options like arguments to pass to the route
   * @throws TypeError if arguments are missing
   */
  popAndPushNamed(routeName: string, options: { arguments?: any } = {}) {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'popAndPushNamed' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'popAndPushNamed', routeName, options.arguments !== undefined ? options.arguments : null);
  }

  /**
   * Pop routes until reaching a specific route
   * @param routeName Name of the route to stop at
   * @throws TypeError if arguments are missing
   */
  popUntil(routeName: string) {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'popUntil' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'popUntil', routeName);
  }

  /**
   * Push a new route and remove routes until reaching a specific route
   * @param state State object to associate with the new route
   * @param newRouteName Name of the new route to navigate to
   * @param untilRouteName Name of the route to stop removing at
   * @throws TypeError if arguments are missing
   */
  pushNamedAndRemoveUntil(state: any, newRouteName: string, untilRouteName: string) {
    if (arguments.length < 3) {
      throw TypeError("Failed to execute 'pushNamedAndRemoveUntil' on 'HybridHistory': 3 arguments required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'pushNamedAndRemoveUntil', state, newRouteName, untilRouteName);
  }

  /**
   * Flutter-style method to push a new route and remove routes until reaching a specific route
   * @param newRouteName Name of the new route to navigate to
   * @param untilRouteName Name of the route to stop removing at
   * @param options Additional options like arguments to pass to the route
   * @throws TypeError if arguments are missing
   */
  pushNamedAndRemoveUntilRoute(newRouteName: string, untilRouteName: string, options: { arguments?: any } = {}) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushNamedAndRemoveUntilRoute' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'pushNamedAndRemoveUntil',
      newRouteName, untilRouteName, options.arguments !== undefined ? options.arguments : null);
  }
}

/**
 * Global instance of HybridHistory for managing navigation
 */
export const hybridHistory = new HybridHistory();
