/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import {Storage, storageProxyHandler } from "./storage";

export const sessionStorage = new Proxy(new Storage('SessionStorage'), storageProxyHandler);
