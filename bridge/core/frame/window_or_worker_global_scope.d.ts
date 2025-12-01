/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// @ts-ignore
declare const queueMicrotask: (callback: Function) => void;

// @ts-ignore
declare const setTimeout: (callback: Function, timeout?: double) => int64;

// @ts-ignore
declare const setInterval: (callback: Function, timeout?: double) => int64;

// @ts-ignore
declare const clearTimeout: (handle: double) => void;

// @ts-ignore
declare const clearInterval: (handle: double) => void;

// @ts-ignore
declare const requestAnimationFrame: (callback: Function) => double;

// @ts-ignore
declare const cancelAnimationFrame: (request_id: int64) => void;

// @ts-ignore
declare const createImageBitmap: (image: any, sx?: double, sy?: double, sw?: double, sh?: double) => Promise<ImageBitmap>;

// @ts-ignore

declare const __gc__: () => void;

// @ts-ignore
declare const __memory_usage__: () => any;
