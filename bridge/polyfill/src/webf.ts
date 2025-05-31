/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import {
  addWebfModuleListener,
  webfInvokeModule,
  clearWebfModuleListener,
  removeWebfModuleListener,
  requestIdleCallback,
  WebfInvokeModule,
  AddWebfModuleListener,
  ClearWebfModuleListener,
  RemoveWebfModuleListener,
  RequestIdleCallback
} from './bridge';
import {methodChannel, MethodChannelInterface, triggerMethodCallHandler} from './method-channel';
import {hybridHistory, HybridHistoryInterface} from './hybrid-history';

addWebfModuleListener('MethodChannel', (event, data) => triggerMethodCallHandler(data[0], data[1]));

/**
 * Main WebF interface providing access to native functionality
 * Contains methods for module invocation, method channel communication,
 * history management, and event handling
 */
export type Webf = {
  /** Interface for communicating with native platform via method channel */
  methodChannel: MethodChannelInterface;
  /** Synchronously invoke a native module method */
  invokeModule: typeof invokeModuleSync;
  /** Asynchronously invoke a native module method */
  invokeModuleAsync: typeof invokeModuleAsync;
  /** Interface for managing navigation history in webf applications */
  hybridHistory: HybridHistoryInterface;
  /** Register a listener for a specific module's events */
  addWebfModuleListener: AddWebfModuleListener;
  /** Clear all module event listeners */
  clearWebfModuleListener: ClearWebfModuleListener;
  /** Remove a specific module event listener */
  removeWebfModuleListener: RemoveWebfModuleListener;
  /** Schedule a callback to be executed during idle periods */
  requestIdleCallback: RequestIdleCallback;
  document: Document;
  window: Window & typeof globalThis;
};

const MAGIC_RESULT_FOR_ASYNC = 0x01fa2f << 4;

/**
 * Asynchronously invoke a method on a native module
 * @param module The name of the module to invoke
 * @param method The name of the method to call
 * @param params Optional parameters to pass to the method
 * @returns Promise that resolves with the result of the method call
 */
function invokeModuleAsync<T>(module: string, method: string, ...params: any[]): Promise<T> {
  return new Promise((resolve, reject) => {
    try {
      let isResolved = false;
      const result = webfInvokeModule(module, method, params, (err, data) => {
        if (isResolved) return;
        if (err) {
          return reject(err);
        }
        return resolve(data);
      });

      if (result != MAGIC_RESULT_FOR_ASYNC) {
        resolve(result);
        isResolved = true;
      }
    } catch (e) {
      reject(e);
    }
  });
}

/**
 * Synchronously invoke a method on a native module
 * @param module The name of the module to invoke
 * @param method The name of the method to call
 * @param params Optional parameters to pass to the method
 * @returns The result of the method call
 * @throws Error if the method is implemented asynchronously but called synchronously
 */
function invokeModuleSync(module: string, method: string, ...params: any[]) {
  const result = webfInvokeModule(module, method, params);
  if (result == MAGIC_RESULT_FOR_ASYNC) {
    throw new Error(`webf.invokeModule: The method ${method} from module ${module} was implemented asynchronously in Dart,
but was invoked synchronously. Please use webf.invokeModuleAsync instead`);
  }
  return result;
}

declare var window: Window & typeof globalThis;
declare var document: Document;

/**
 * Global WebF instance providing access to all WebF functionality
 */
export const webf: Webf = {
  methodChannel,
  document: document,
  window: window,
  invokeModule: invokeModuleSync,
  invokeModuleAsync: invokeModuleAsync,
  hybridHistory: hybridHistory,
  addWebfModuleListener: addWebfModuleListener,
  clearWebfModuleListener: clearWebfModuleListener,
  removeWebfModuleListener: removeWebfModuleListener,
  requestIdleCallback: requestIdleCallback.bind(globalThis)
};
