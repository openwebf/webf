import './webf';
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 * Use of this source code is governed by a AGPL-3.0 license that can be
 * found in the LICENSE file.
 */

// Import core WebF types (namespace declaration)
/// <reference path="./webf.d.ts" />

import {PolyFillGlobal } from './polyfill';

// Global instances
declare global {
  const document: Document;
  const window: Window & typeof globalThis & PolyFillGlobal;
  const screen: Screen;
}

export * from './polyfill';