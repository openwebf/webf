import './webf';
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 * Use of this source code is governed by a AGPL-3.0 license that can be
 * found in the LICENSE file.
 */

// Import core WebF types (namespace declaration)
/// <reference path="./webf.d.ts" />

// Import polyfill module
/// <reference path="./polyfill.d.ts" />

// Re-export polyfill module exports
export * from './polyfill';

// Ensure this is treated as a module
export {};