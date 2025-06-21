/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import './dom';
import { console, Console } from './console';
import { fetch, Request, Response, Headers } from './fetch';
import {matchMedia, MediaQueryList} from './match-media';
import {location, LocationInterface} from './location';
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


declare global {
  // @ts-ignore
  const console: Console;
  // @ts-ignore
  const localStorage: StorageInterface;
  // @ts-ignore
  const sessionStorage: StorageInterface;
  // @ts-ignore
  const history: History;
  // @ts-ignore
  const location: LocationInterface;
  // @ts-ignore
  const navigator: NavigatorInterface;
  // @ts-ignore
  const webf: Webf;


  function fetch(input: RequestInfo, init?: RequestInit): Promise<Response>;
  function matchMedia(query: string): MediaQueryList;

  // @ts-ignore
  var Headers: {
    prototype: Headers;
    new(headers?: HeadersInit): Headers;
  };

  // @ts-ignore
  var Request: {
    prototype: Request;
    new(input: RequestInfo, init?: RequestInit): Request;
  };

  // @ts-ignore
  var Response: {
    prototype: Response;
    new(body?: BodyInit | null, init?: ResponseInit): Response;
  };

  // @ts-ignore
  var URL: {
    prototype: URL;
    new(url: string, base?: string | URL): URL;
  };

  // @ts-ignore
  var URLSearchParams: {
    prototype: URLSearchParams;
    new(query?: any): URLSearchParams;
  };

  // @ts-ignore
  var XMLHttpRequest: {
    prototype: XMLHttpRequest;
    new(): XMLHttpRequest;
  };

  // @ts-ignore
  var WebSocket: {
    prototype: WebSocket;
    new(url: string, protocols?: string | string[]): WebSocket;
  };

  // @ts-ignore
  var DOMException: {
    prototype: DOMException;
    new(message?: string, name?: string): DOMException;
  };

  // @ts-ignore
  var ResizeObserver: {
    prototype: ResizeObserver;
    new(callback: (entries: ResizeObserverEntry[]) => void): ResizeObserver;
  };
}

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
  WebSocket,
  ResizeObserver
}

function defineGlobalProperty(key: string, value: any, isEnumerable: boolean = true) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: isEnumerable,
    writable: true,
    configurable: true
  });
}
