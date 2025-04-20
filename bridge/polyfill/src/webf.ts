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

export type Webf = {
  methodChannel: MethodChannelInterface;
  invokeModule: typeof invokeModuleSync;
  invokeModuleAsync: typeof invokeModuleAsync;
  hybridHistory: HybridHistoryInterface;
  addWebfModuleListener: AddWebfModuleListener;
  clearWebfModuleListener: ClearWebfModuleListener;
  removeWebfModuleListener: RemoveWebfModuleListener;
  requestIdleCallback: RequestIdleCallback;
}

const MAGIC_RESULT_FOR_ASYNC = 0x01fa2f << 4;

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

function invokeModuleSync(module: string, method: string, ...params: any[]) {
  const result = webfInvokeModule(module, method, params);
  if (result == MAGIC_RESULT_FOR_ASYNC) {
    throw new Error(`webf.invokeModule: The method ${method} from module ${module} was implemented asynchronously in Dart,
but was invoked synchronously. Please use webf.invokeModuleAsync instead`);
  }
  return result;
}

export const webf: Webf = {
  methodChannel,
  invokeModule: invokeModuleSync,
  invokeModuleAsync: invokeModuleAsync,
  hybridHistory: hybridHistory,
  addWebfModuleListener: addWebfModuleListener,
  clearWebfModuleListener: clearWebfModuleListener,
  removeWebfModuleListener: removeWebfModuleListener,
  requestIdleCallback: requestIdleCallback.bind(globalThis)
};
