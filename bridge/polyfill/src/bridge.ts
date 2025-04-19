/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

export type WebfInvokeModule = (module: string, method: string, params?: any | null, fn?: (err: Error, data: any) => any) => any;
export type AddWebfModuleListener = (moduleName: string, fn: (event: Event, extra: any) => any) => void;
export type ClearWebfModuleListener = () => void;
export type RemoveWebfModuleListener = (name: string) => void;

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

export type RequestIdleCallback = (callback: IdleRequestCallback, options?: IdleRequestOptions) => number;

declare const __webf_invoke_module__: WebfInvokeModule;
export const webfInvokeModule = __webf_invoke_module__;

declare const __webf_add_module_listener__: AddWebfModuleListener;
export const addWebfModuleListener = __webf_add_module_listener__;

declare const __webf_clear_module_listener__: ClearWebfModuleListener;
export const clearWebfModuleListener = __webf_clear_module_listener__;

declare const __webf_remove_module_listener__: RemoveWebfModuleListener;
export const removeWebfModuleListener = __webf_remove_module_listener__;

declare const __webf_location_reload__: () => void;
export const webfLocationReload = __webf_location_reload__;

declare const __webf_print__: (log: string, level?: string) => void;
export const webfPrint = __webf_print__;

declare const __webf_is_proxy__: (obj: any) => boolean;
export const webfIsProxy = __webf_is_proxy__;

declare const ___requestIdleCallback__: RequestIdleCallback;
export const requestIdleCallback = ___requestIdleCallback__;