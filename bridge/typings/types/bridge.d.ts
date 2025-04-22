export declare type WebfInvokeModule = (module: string, method: string, params?: any | null, fn?: (err: Error, data: any) => any) => any;
export declare type AddWebfModuleListener = (moduleName: string, fn: (event: Event, extra: any) => any) => void;
export declare type ClearWebfModuleListener = () => void;
export declare type RemoveWebfModuleListener = (name: string) => void;
export interface IdleRequestOptions {
    timeout?: number;
}
export interface IdleRequestCallback {
    (deadline: IdleDeadline): void;
}
export interface IdleDeadline {
    timeRemaining(): number;
    readonly didTimeout: boolean;
}
export declare type RequestIdleCallback = (callback: IdleRequestCallback, options?: IdleRequestOptions) => number;
export declare const webfInvokeModule: WebfInvokeModule;
export declare const addWebfModuleListener: AddWebfModuleListener;
export declare const clearWebfModuleListener: ClearWebfModuleListener;
export declare const removeWebfModuleListener: RemoveWebfModuleListener;
export declare const webfLocationReload: () => void;
export declare const webfPrint: (log: string, level?: string) => void;
export declare const webfIsProxy: (obj: any) => boolean;
export declare const requestIdleCallback: RequestIdleCallback;
