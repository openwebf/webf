/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import './dom';
import { console } from './console';
import { fetch, Request, Response, Headers } from './fetch';
import { matchMedia } from './match-media';
import { location } from './location';
import { history } from './history';
import { navigator } from './navigator';
import { XMLHttpRequest } from './xhr';
import { asyncStorage } from './async-storage';
import { URLSearchParams } from './url-search-params';
import { localStorage } from './local-storage';
import { sessionStorage } from './session-storage';
import { DOMException } from './dom-exception';
import { Storage } from './storage';
import { URL } from './url';
import { webf } from './webf';
import { WebSocket } from './websocket'
import { ResizeObserver } from './resize-observer';
import { _AbortController, _AbortSignal } from './abort-signal';
// import { FormData } from './formdata'
// import { ArrayBuffer } from './array-buffer';

defineGlobalProperty('console', console);
defineGlobalProperty('Request', Request);
defineGlobalProperty('Response', Response);
defineGlobalProperty('Headers', Headers);
defineGlobalProperty('fetch', fetch);
defineGlobalProperty('matchMedia', matchMedia);
defineGlobalProperty('location', location);
defineGlobalProperty('history', history);
defineGlobalProperty('navigator', navigator);
defineGlobalProperty('XMLHttpRequest', XMLHttpRequest);
defineGlobalProperty('asyncStorage', asyncStorage);
defineGlobalProperty('localStorage', localStorage);
defineGlobalProperty('sessionStorage', sessionStorage);
defineGlobalProperty('Storage', Storage);
defineGlobalProperty('URLSearchParams', URLSearchParams);
defineGlobalProperty('DOMException', DOMException);
defineGlobalProperty('URL', URL);
defineGlobalProperty('webf', webf);
defineGlobalProperty('WebSocket', WebSocket);
defineGlobalProperty('ResizeObserver', ResizeObserver);
defineGlobalProperty('AbortSignal', _AbortSignal);
defineGlobalProperty('AbortController', _AbortController);
// defineGlobalProperty('ArrayBuffer', ArrayBuffer);
// defineGlobalProperty('Blob', Blob);
// defineGlobalProperty('FormData', FormData);
function defineGlobalProperty(key: string, value: any, isEnumerable: boolean = true) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: isEnumerable,
    writable: true,
    configurable: true
  });
}
// // 定义一个函数来覆盖 getOwnPropertyDescriptor
// const getOwnPropertyDescriptorOverride = (key: string): PropertyDescriptor | undefined => {
  
//   // 返回原生的 getOwnPropertyDescriptor 方法的结果
//   const obj= Reflect.getOwnPropertyDescriptor(globalThis, key);
//   if(obj===undefined){
//     if (key !== 'prototype' && key !== 'constructor') {
//       // 尝试获取元素
//       const element = document.getElementById(key);
//       if (element !== null) {
//         // 如果找到了元素，则返回一个新的属性描述符
//         return {
//           get: ()=>document.getElementById(key),
//           enumerable: true,
//           writable: false,
//           configurable: true,
//         };
//       }
//     }
//   }
//   return obj;
// };

// // 覆盖 globalThis 的 getOwnPropertyDescriptor 方法
// Object.defineProperty(globalThis, 'getOwnPropertyDescriptor', {
//   value: getOwnPropertyDescriptorOverride,
//   enumerable: false, // 通常不希望这个方法是可枚举的
//   writable: true,
//   configurable: true,
// });
