/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import {Storage, StorageInterface, storageProxyHandler } from "./storage";

export const localStorage: StorageInterface = new Proxy(new Storage('LocalStorage'), storageProxyHandler);
