/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import './dom';
import { console, Console } from './console';
import { fetch, Request, Response, Headers } from './fetch';
import {matchMedia, MediaQueryList} from './match-media';
import {Location, location, LocationInterface} from './location';
import {History, history} from './history';
import {navigator, NavigatorInterface} from './navigator';
import { XMLHttpRequest } from './xhr';
import { asyncStorage } from './async-storage';
import { URLSearchParams } from './url-search-params';
import { localStorage } from './local-storage';
import { sessionStorage } from './session-storage';
import { DOMException } from './dom-exception';
import {Storage, StorageInterface} from './storage';
import { URL } from './url';
import {Webf, webf} from './webf';
import { WebSocket } from './websocket'
import { ResizeObserver } from './resize-observer';
import { _AbortController, _AbortSignal } from './abort-signal';
import { BroadcastChannel } from './broadcast-channel';
import { TextDecoder, TextEncoder } from './text-codec';
import { ReadableStream, WritableStream, TransformStream } from './streams';

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
defineGlobalProperty('BroadcastChannel', BroadcastChannel);
defineGlobalProperty('TextDecoder', TextDecoder);
defineGlobalProperty('TextEncoder', TextEncoder);
defineGlobalProperty('ReadableStream', ReadableStream);
defineGlobalProperty('WritableStream', WritableStream);
defineGlobalProperty('TransformStream', TransformStream);

// @ts-expect-error
globalThis.Element.prototype.attachShadow = function (init) {
  return document.createElement('shadow-root');
}

globalThis.Element.prototype.getRootNode = function (init) {
  return document;
}

// @ts-expect-error
document.activeElement = document.body;

document.hasFocus = function () {
  return true;
}

globalThis.HTMLElement.prototype.focus = function () {
  // No-op for now.
}

globalThis.HTMLElement.prototype.blur = function () {
  // No-op for now.
}

class ShadowRoot {
  constructor() {
    throw new Error('ShadowRoot is not supported in WebF.');
  }
}

defineGlobalProperty('ShadowRoot', ShadowRoot, false);

globalThis.HTMLImageElement.prototype.decode = function () {
  return new Promise((resolve, reject) => {
    // No-op for now.
    resolve();
  });
}

export type PolyFillGlobal = {
  console: Console,
  webf: Webf,
  Request: Request,
  Response: Response,
  Headers: Headers,
  fetch: typeof fetch,
  matchMedia: typeof matchMedia,
  location: Location,
  navigator: typeof navigator,
  XMLHttpRequest: XMLHttpRequest,
  localStorage: typeof localStorage,
  sessionStorage: typeof sessionStorage,
  DOMException: DOMException,
  URL: URL,
  WebSocket: WebSocket,
  ResizeObserver: ResizeObserver,
  AbortSignal: _AbortSignal,
  AbortController: _AbortController,
  TextDecoder: TextDecoder,
  TextEncoder: TextEncoder,
  ReadableStream: ReadableStream,
  WritableStream: WritableStream,
  TransformStream: TransformStream
};

export {
  console,
  Console,
  Request,
  Response,
  Headers,
  fetch,
  matchMedia,
  location,
  history,
  navigator,
  XMLHttpRequest,
  asyncStorage,
  localStorage,
  URLSearchParams,
  sessionStorage,
  DOMException,
  URL,
  webf,
  Webf,
  WebSocket,
  ResizeObserver,
  TextDecoder,
  TextEncoder,
  ReadableStream,
  WritableStream,
  TransformStream
}

function defineGlobalProperty(key: string, value: any, isEnumerable: boolean = true) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: isEnumerable,
    writable: true,
    configurable: true
  });
}
