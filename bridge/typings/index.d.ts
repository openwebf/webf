/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 * Use of this source code is governed by a AGPL-3.0 license that can be
 * found in the LICENSE file.
 */

// Import core WebF types (namespace declaration)
/// <reference path="./webf.d.ts" />

// Import polyfill module
/// <reference path="./polyfill.d.ts" />

// Re-export polyfill module exports
export * from './polyfill';

// Declare additional types that should be available
export interface WebfInstance {
  methodChannel: any;
  invokeModule: (module: string, method: string, params?: any, fn?: Function) => any;
  invokeModuleAsync: (module: string, method: string, params?: any) => Promise<any>;
  hybridHistory: any;
  addWebfModuleListener: (moduleName: string, callback: Function) => void;
  clearWebfModuleListener: () => void;
  removeWebfModuleListener: (moduleName: string) => void;
  requestIdleCallback: (callback: (deadline: any) => void, options?: { timeout: number }) => number;
  document: Document;
  window: Window & typeof globalThis;
}

// Merge with global scope
declare global {
  // WebF instance
  const webf: WebfInstance;
  
  // Add webf to Window
  interface Window {
    webf: WebfInstance;
  }
  
  // Make webf namespace types available globally
  // The webf namespace is already declared in webf.d.ts
  
  // Extend webf namespace with additional polyfill types
  namespace webf {
    // Main WebF interface
    export interface Webf extends WebfInstance {}
    
    // Re-export important types for convenience
    export type Console = globalThis.Console;
    export type Headers = globalThis.Headers;
    export type Request = globalThis.Request;
    export type Response = globalThis.Response;
    export type URL = globalThis.URL;
    export type URLSearchParams = globalThis.URLSearchParams;
    export type XMLHttpRequest = globalThis.XMLHttpRequest;
    export type WebSocket = globalThis.WebSocket;
    export type ResizeObserver = globalThis.ResizeObserver;
    export type DOMException = globalThis.DOMException;
  }
}

// Ensure this is treated as a module
export {};