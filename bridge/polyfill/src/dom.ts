/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

let htmlElement = document.createElement('html');
document.appendChild(htmlElement);

let headElement = document.createElement('head');
document.documentElement.appendChild(headElement);

let bodyElement = document.createElement('body');
document.documentElement.appendChild(bodyElement);


// SVGMatrix are equal to DOMMatrix.
Object.defineProperty(window, 'SVGMatrix', {
  value: DOMMatrix
});