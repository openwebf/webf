/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';

export interface AsyncStorage {
  getItem(key: number | string): Promise<string>;
  setItem(key: number | string, value: number | string): Promise<any>;
  removeItem(key: number | string): Promise<any>;
  clear(): Promise<any>;
  getAllKeys(): Promise<string[]>;
  length(): Promise<number>;
}

export const asyncStorage: AsyncStorage = {
  getItem(key: number | string) {
    return webf.invokeModuleAsync<string>('AsyncStorage', 'getItem', String(key));
  },
  setItem(key: number | string, value: number | string) {
    return webf.invokeModuleAsync('AsyncStorage', 'setItem', String(key), String(value));
  },
  removeItem(key: number | string) {
    return webf.invokeModuleAsync('AsyncStorage', 'removeItem', String(key));
  },
  clear() {
    return webf.invokeModuleAsync('AsyncStorage', 'clear', '');
  },
  getAllKeys() {
    return webf.invokeModuleAsync('AsyncStorage', 'getAllKeys', '');
  },
  length(): Promise<number> {
    return webf.invokeModuleAsync('AsyncStorage', 'length', '');
  }
}
