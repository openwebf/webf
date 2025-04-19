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
import { methodChannel, MethodChannelInterface, triggerMethodCallHandler } from './method-channel';
import { hybridHistory, HybridHistoryInterface } from './hybrid-history';

addWebfModuleListener('MethodChannel', (event, data) => triggerMethodCallHandler(data[0], data[1]));

export type Webf = {
  methodChannel: MethodChannelInterface;
  invokeModule: WebfInvokeModule;
  hybridHistory: HybridHistoryInterface;
  addWebfModuleListener: AddWebfModuleListener;
  clearWebfModuleListener: ClearWebfModuleListener;
  removeWebfModuleListener: RemoveWebfModuleListener;
  requestIdleCallback: RequestIdleCallback;
}

export const webf: Webf = {
  methodChannel,
  invokeModule: webfInvokeModule,
  hybridHistory: hybridHistory,
  addWebfModuleListener: addWebfModuleListener,
  clearWebfModuleListener: clearWebfModuleListener,
  removeWebfModuleListener: removeWebfModuleListener,
  requestIdleCallback: requestIdleCallback.bind(globalThis)
};
