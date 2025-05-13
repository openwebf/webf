/**
 * Function signature for handling method calls from the native platform
 * @param args Arguments passed from the native platform
 */
declare type MethodCallHandler = (args: any[]) => void;
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
/**
 * Implementation of the MethodChannel for communicating with native platform
 * Similar to Flutter's platform channels
 */
export declare const methodChannel: MethodChannelInterface;
/**
 * Executes a registered method handler with the provided arguments
 * @param method The name of the method to trigger
 * @param args Arguments to pass to the method handler
 * @returns Result of the method handler, or null if no handler is registered
 */
export declare function triggerMethodCallHandler(method: string, args: any[]): void | null;
export {};
