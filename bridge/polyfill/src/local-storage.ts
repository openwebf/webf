/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import {Storage, storageProxyHandler } from "./storage";

// @ts-ignore
export const localStorage = new Proxy(new Storage('LocalStorage'), storageProxyHandler);
