/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';

class HybridHistory {
  constructor() {
  }

  get length() {
    return Number(webf.invokeModule('HybridHistory', 'length'));
  }

  get state() {
    return JSON.parse(webf.invokeModule('HybridHistory', 'state'));
  }

  back() {
     webf.invokeModule('HybridHistory', 'back');
  }

  forward() {
    webf.invokeModule('HybridHistory', 'forward');
  }

  go(delta?: number) {
    webf.invokeModule('HybridHistory', 'go', delta ? Number(delta) : null);
  }

  pushState(state: any, title: string, url?: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }

    webf.invokeModule('HybridHistory', 'pushState', [state, title, url]);
  }

  replaceState(state: any, title: string, url?: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }

    webf.invokeModule('HybridHistory', 'replaceState', [state, title, url]);
  }
}

export const hybridHistory = new HybridHistory();
