import { AddWebfModuleListener, ClearWebfModuleListener, RemoveWebfModuleListener, RequestIdleCallback } from './bridge';
import { MethodChannelInterface } from './method-channel';
import { HybridHistoryInterface } from './hybrid-history';
/**
 * Main WebF interface providing access to native functionality
 * Contains methods for module invocation, method channel communication,
 * history management, and event handling
 */
export declare type Webf = {
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
};
/**
 * Asynchronously invoke a method on a native module
 * @param module The name of the module to invoke
 * @param method The name of the method to call
 * @param params Optional parameters to pass to the method
 * @returns Promise that resolves with the result of the method call
 */
declare function invokeModuleAsync<T>(module: string, method: string, ...params: any[]): Promise<T>;
/**
 * Synchronously invoke a method on a native module
 * @param module The name of the module to invoke
 * @param method The name of the method to call
 * @param params Optional parameters to pass to the method
 * @returns The result of the method call
 * @throws Error if the method is implemented asynchronously but called synchronously
 */
declare function invokeModuleSync(module: string, method: string, ...params: any[]): any;
/**
 * Global WebF instance providing access to all WebF functionality
 */
export declare const webf: Webf;
export {};
