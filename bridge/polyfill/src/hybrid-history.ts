/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';

export interface HybridHistoryInterface {
  // State management
  readonly state: any;
  readonly path: string;
  
  // Original API methods
  back(): void;
  pushState(state: any, name: string): void;
  replaceState(state: any, name: string): void;
  restorablePopAndPushState(state: any, name: string): string;
  
  // Flutter-like API methods
  pop(result?: any): void;
  pushNamed(routeName: string, options?: { arguments?: any }): void;
  pushReplacementNamed(routeName: string, options?: { arguments?: any }): void;
  restorablePopAndPushNamed(routeName: string, options?: { arguments?: any }): string;
  
  // Utility methods
  canPop(): boolean;
  maybePop(result?: any): boolean;
  popAndPushNamed(routeName: string, options?: { arguments?: any }): void;
  popUntil(routeName: string): void;
  pushNamedAndRemoveUntil(state: any, newRouteName: string, untilRouteName: string): void;
  pushNamedAndRemoveUntilRoute(newRouteName: string, untilRouteName: string, options?: { arguments?: any }): void;
}

class HybridHistory implements HybridHistoryInterface {
  // State management
  get state() {
    return JSON.parse(webf.invokeModule('HybridHistory', 'state'));
  }

  get path() {
    return webf.invokeModule('HybridHistory', 'path');
  }
  
  // Original API methods - kept for backward compatibility
  back() {
    webf.invokeModule('HybridHistory', 'back');
  }
  
  pushState(state: any, name: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'pushState', [state, name]);
  }

  replaceState(state: any, name: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'replaceState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'replaceState', [state, name]);
  }
  
  restorablePopAndPushState(state: any, name: string): string {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'restorablePopAndPushState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }
    return webf.invokeModule('HybridHistory', 'restorablePopAndPushState', [state, name]);
  }
  
  // New Flutter-like API methods
  pop(result?: any) {
    webf.invokeModule('HybridHistory', 'pop', result !== undefined ? [result] : []);
  }
  
  pushNamed(routeName: string, options: { arguments?: any } = {}) {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'pushNamed' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'pushNamed', 
      options.arguments !== undefined ? [routeName, options.arguments] : [routeName]);
  }
  
  pushReplacementNamed(routeName: string, options: { arguments?: any } = {}) {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'pushReplacementNamed' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'pushReplacementNamed', 
      options.arguments !== undefined ? [routeName, options.arguments] : [routeName]);
  }
  
  restorablePopAndPushNamed(routeName: string, options: { arguments?: any } = {}): string {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'restorablePopAndPushNamed' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    return webf.invokeModule('HybridHistory', 'restorablePopAndPushNamed', 
      options.arguments !== undefined ? [routeName, options.arguments] : [routeName]);
  }
  
  // Utility methods
  canPop(): boolean {
    return webf.invokeModule('HybridHistory', 'canPop') === 'true';
  }
  
  maybePop(result?: any): boolean {
    return webf.invokeModule('HybridHistory', 'maybePop', result !== undefined ? [result] : []) === 'true';
  }
  
  popAndPushNamed(routeName: string, options: { arguments?: any } = {}) {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'popAndPushNamed' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'popAndPushNamed', 
      options.arguments !== undefined ? [routeName, options.arguments] : [routeName]);
  }
  
  popUntil(routeName: string) {
    if (arguments.length < 1) {
      throw TypeError("Failed to execute 'popUntil' on 'HybridHistory': 1 argument required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'popUntil', [routeName]);
  }
  
  // Original style with 3 parameters (state, newRouteName, untilRouteName)
  pushNamedAndRemoveUntil(state: any, newRouteName: string, untilRouteName: string) {
    if (arguments.length < 3) {
      throw TypeError("Failed to execute 'pushNamedAndRemoveUntil' on 'HybridHistory': 3 arguments required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'pushNamedAndRemoveUntil', [state, newRouteName, untilRouteName]);
  }
  
  // New Flutter-like API with options
  pushNamedAndRemoveUntilRoute(newRouteName: string, untilRouteName: string, options: { arguments?: any } = {}) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushNamedAndRemoveUntilRoute' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'pushNamedAndRemoveUntil', 
      options.arguments !== undefined ? 
        [newRouteName, untilRouteName, options.arguments] : 
        [newRouteName, untilRouteName]);
  }
}

export const hybridHistory = new HybridHistory();
