/**
 * Function to invoke a method on a native module
 * @param module The name of the module to invoke
 * @param method The name of the method to call
 * @param params Optional parameters to pass to the method
 * @param fn Optional callback function for asynchronous calls
 * @returns Result of the method call (or magic value for async calls)
 */
export declare type WebfInvokeModule = (module: string, method: string, params?: any | null, fn?: (err: Error, data: any) => any) => any;
/**
 * Function to add a listener for events from a specific module
 * @param moduleName The name of the module to listen to
 * @param fn Callback function that will be called when the module emits an event
 */
export declare type AddWebfModuleListener = (moduleName: string, fn: (event: Event, extra: any) => any) => void;
/**
 * Function to clear all module event listeners
 */
export declare type ClearWebfModuleListener = () => void;
/**
 * Function to remove a specific module event listener
 * @param name The name of the module listener to remove
 */
export declare type RemoveWebfModuleListener = (name: string) => void;
/**
 * Options for the requestIdleCallback function
 */
export interface IdleRequestOptions {
    /** Timeout in milliseconds. If callback has not been called before timeout, it will be called regardless of idle status */
    timeout?: number;
}
/**
 * Callback function that will be called during idle periods
 * @param deadline Object containing information about the deadline
 */
export interface IdleRequestCallback {
    (deadline: IdleDeadline): void;
}
/**
 * Interface with information about the current idle deadline
 */
export interface IdleDeadline {
    /** Returns the number of milliseconds remaining in the current idle period */
    timeRemaining(): number;
    /** Returns true if the callback was called because the timeout expired */
    readonly didTimeout: boolean;
}
/**
 * Schedules a callback to be executed during a browser idle period
 * @param callback The function to call when the browser is idle
 * @param options Optional configuration for the idle request
 * @returns A handle that can be used to cancel the callback
 */
export declare type RequestIdleCallback = (callback: IdleRequestCallback, options?: IdleRequestOptions) => number;
/**
 * Invokes a method on a native module
 */
export declare const webfInvokeModule: WebfInvokeModule;
/**
 * Adds a listener for events from a specific module
 */
export declare const addWebfModuleListener: AddWebfModuleListener;
/**
 * Clears all module event listeners
 */
export declare const clearWebfModuleListener: ClearWebfModuleListener;
/**
 * Removes a specific module event listener
 */
export declare const removeWebfModuleListener: RemoveWebfModuleListener;
/**
 * Reloads the current location/page
 */
export declare const webfLocationReload: () => void;
/**
 * Prints a log message to the native console
 * @param log The message to print
 * @param level Optional log level (debug, info, warn, error)
 */
export declare const webfPrint: (log: string, level?: string) => void;
/**
 * Checks if an object is a WebF proxy object
 * @param obj The object to check
 * @returns True if the object is a proxy, false otherwise
 */
export declare const webfIsProxy: (obj: any) => boolean;
/**
 * Schedules a callback to be executed during a browser idle period
 */
export declare const requestIdleCallback: RequestIdleCallback;
