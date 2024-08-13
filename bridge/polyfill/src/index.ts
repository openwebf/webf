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

function defineGlobalProperty(key: string, value: any, isEnumerable: boolean = true) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: isEnumerable,
    writable: true,
    configurable: true
  });
}
