/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';

class HybridHistory {
  get state() {
    return JSON.parse(webf.invokeModule('HybridHistory', 'state'));
  }
  back() {
     webf.invokeModule('HybridHistory', 'back');
  }
  pushState(state: any, name: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }

    webf.invokeModule('HybridHistory', 'pushState', [state, name]);
  }

  replaceState(state: any, name: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'replaceState' on 'HybridHistory': 2 arguments required, but only " + arguments.length + " present");
    }
    webf.invokeModule('HybridHistory', 'replaceState', [state, name]);
  }

  get path() {
    return webf.invokeModule('HybridHistory', 'path');
  }
}

export const hybridHistory = new HybridHistory();
