/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

// SVGMatrix are equal to DOMMatrix.
Object.defineProperty(window, 'SVGMatrix', {
  value: DOMMatrix
});