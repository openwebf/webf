/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webfInvokeModule } from './bridge';

/**
 * Function signature for handling method calls from the native platform
 * @param args Arguments passed from the native platform
 */
type MethodCallHandler = (args: any[]) => void;

/**
 * Interface for communicating with the native platform via method channels
 * Similar to Flutter's MethodChannel for platform-specific communication
 */
export interface MethodChannelInterface {
  /**
   * Registers a handler function for a specific method
   * @param method The name of the method to handle
   * @param handler The function to execute when the method is called
   */
  addMethodCallHandler(method: string, handler: MethodCallHandler): void;
  
  /**
   * Removes a previously registered method handler
   * @param method The name of the method handler to remove
   */
  removeMethodCallHandler(method: string): void;
  
  /**
   * Removes all registered method handlers
   */
  clearMethodCallHandler(): void;
  
  /**
   * Invokes a method on the native platform
   * @param method The name of the method to call
   * @param args Arguments to pass to the method
   * @returns Promise that resolves with the result of the method call
   */
  invokeMethod(method: string, ...args: any[]): Promise<string>;
}

let methodCallHandlers: {[key: string]: MethodCallHandler} = {};

/**
 * Implementation of the MethodChannel for communicating with native platform
 * Similar to Flutter's platform channels
 */
export const methodChannel: MethodChannelInterface = {
  addMethodCallHandler(method: string, handler: MethodCallHandler) {
    if (typeof handler !== 'function') {
      throw new Error('webf.addMethodCallHandler: handler should be an function.');
    }
    methodCallHandlers[method] = handler;
  },
  removeMethodCallHandler(method: string) {
    delete methodCallHandlers[method];
  },
  clearMethodCallHandler() {
    methodCallHandlers = {};
  },
  invokeMethod(method: string, ...args: any[]): Promise<string> {
    return new Promise((resolve, reject) => {
      webfInvokeModule('MethodChannel', 'invokeMethod', [method, args], (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
};

/**
 * Executes a registered method handler with the provided arguments
 * @param method The name of the method to trigger
 * @param args Arguments to pass to the method handler
 * @returns Result of the method handler, or null if no handler is registered
 */
export function triggerMethodCallHandler(method: string, args: any[]) {
  if (!methodCallHandlers.hasOwnProperty(method)) {
    return null;
  }

  return methodCallHandlers[method](args);
}
