/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

let html = document.createElement('html');
document.appendChild(html);

let head = document.createElement('head');
document.documentElement.appendChild(head);

let body = document.createElement('body');
document.documentElement.appendChild(body);

// @ts-ignore
class SVGElement extends Element {
  constructor() {
    super();
  }
}

Object.defineProperty(window, 'SVGElement', {
  value: SVGElement
});

// SVGMatrix are equal to DOMMatrix.
Object.defineProperty(window, 'SVGMatrix', {
  value: DOMMatrix
});