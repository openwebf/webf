/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import {
  addWebfModuleListener,
  webfInvokeModule,
  clearWebfModuleListener,
  removeWebfModuleListener,
  requestIdleCallback
} from './bridge';
import {methodChannel, triggerMethodCallHandler} from './method-channel';
import {hybridHistory} from './hybrid-history';

addWebfModuleListener('MethodChannel', (event, data) => triggerMethodCallHandler(data[0], data[1]));

export const webf = {
  methodChannel,
  invokeModule: webfInvokeModule,
  hybridHistory: hybridHistory,
  addWebfModuleListener: addWebfModuleListener,
  clearWebfModuleListener: clearWebfModuleListener,
  removeWebfModuleListener: removeWebfModuleListener,
  requestIdleCallback: requestIdleCallback.bind(globalThis)
};
