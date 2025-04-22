import { AddWebfModuleListener, ClearWebfModuleListener, RemoveWebfModuleListener, RequestIdleCallback } from './bridge';
import { MethodChannelInterface } from './method-channel';
import { HybridHistoryInterface } from './hybrid-history';
export declare type Webf = {
    methodChannel: MethodChannelInterface;
    invokeModule: typeof invokeModuleSync;
    invokeModuleAsync: typeof invokeModuleAsync;
    hybridHistory: HybridHistoryInterface;
    addWebfModuleListener: AddWebfModuleListener;
    clearWebfModuleListener: ClearWebfModuleListener;
    removeWebfModuleListener: RemoveWebfModuleListener;
    requestIdleCallback: RequestIdleCallback;
};
declare function invokeModuleAsync<T>(module: string, method: string, ...params: any[]): Promise<T>;
declare function invokeModuleSync(module: string, method: string, ...params: any[]): any;
export declare const webf: Webf;
export {};
