declare type MethodCallHandler = (args: any[]) => void;
export interface MethodChannelInterface {
    addMethodCallHandler(method: string, handler: MethodCallHandler): void;
    removeMethodCallHandler(method: string): void;
    clearMethodCallHandler(): void;
    invokeMethod(method: string, ...args: any[]): Promise<string>;
}
export declare const methodChannel: MethodChannelInterface;
export declare function triggerMethodCallHandler(method: string, args: any[]): void | null;
export {};
