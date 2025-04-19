/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';

export type HeadersInit = Headers | Record<string, string> | [string, string][];

export interface RequestInit {
  body?: BodyInit | null;
  headers?: HeadersInit;
  method?: string;
  mode?: RequestMode;
  signal?: AbortSignal;
}

export interface ResponseInit {
  headers?: HeadersInit;
  status?: number;
  statusText?: string;
}

type RequestMode = 'cors' | 'no-cors' | 'same-origin' | 'navigate';
type ResponseType = 'basic' | 'cors' | 'default' | 'error' | 'opaque' | 'opaqueredirect';
export type BodyInit = string | Blob | ArrayBuffer | FormData | URLSearchParams | null;

function normalizeName(name: any) {
  if (typeof name !== 'string') {
    name = String(name);
  }
  if (/[^a-z0-9\-#$%&'*+.^_`|~]/i.test(name) || name === '') {
    throw new TypeError('Invalid character in header field name');
  }
  return name.toLowerCase();
}

function normalizeValue(value: any) {
  if (typeof value !== 'string') {
    value = String(value);
  }
  return value;
}

function consumed(body: Body) {
  if (body.bodyUsed) {
    return Promise.reject(new TypeError('Already read'))
  }
  body.bodyUsed = true;
  return null;
}

export class Headers implements Headers {
  public map: Record<string, string> = {};

  constructor(headers?: HeadersInit) {
    if (headers instanceof Headers) {
      headers.forEach((value, name) => {
        this.append(name, value);
      }, this);
    } else if (Array.isArray(headers)) {
      headers.forEach((header) => {
        this.append(header[0], header[1])
      }, this);
    } else if (headers) {
      Object.getOwnPropertyNames(headers).forEach((name) => {
        // Type assertion to Record<string, string> since we know headers is a plain object here
        const headerObj = headers as Record<string, string>;
        this.append(name, headerObj[name]);
      }, this);
    }
  }

  append(name: string, value: string): void {
    name = normalizeName(name);
    value = normalizeValue(value);
    let oldValue = this.map[name];
    this.map[name] = oldValue ? oldValue + ', ' + value : value;
  }

  delete(name: string): void {
    delete this.map[normalizeName(name)];
  }

  forEach(callbackfn: (value: string, key: string, parent: Headers) => void, thisArg?: any): void {
    for (let name in this.map) {
      if (this.map.hasOwnProperty(name)) {
        callbackfn.call(thisArg, this.map[name], name, this);
      }
    }
  }

  get(name: string): string | null {
    name = normalizeName(name);
    return this.has(name) ? this.map[name] : null;
  }

  has(name: string): boolean {
    return this.map.hasOwnProperty(normalizeName(name));
  }

  set(name: string, value: string): void {
    this.map[normalizeName(name)] = normalizeValue(value);
  }
}

class Body {
  // TODO support readableStream
  _bodyInit: any;
  body: string | null | Blob;
  bodyUsed: boolean;
  headers: Headers;

  constructor() {
    this.bodyUsed = false;
  }

  _initBody(body: BodyInit | null) {
    this._bodyInit = body;
    // only support string from now
    if (!body) {
      this.body = '';
    } else if (typeof body === 'string') {
      this.body = body;
    } else if (Object.prototype.toString.call(body) == '[object ArrayBuffer]') {
      this.body = new Blob([body as ArrayBuffer]);
    } else {
      this.body = body = Object.prototype.toString.call(body);
    }

    if (!this.headers.get('content-type')) {
      if (typeof body === 'string') {
        this.headers.set('content-type', 'text/plain;charset=UTF-8')
      }
    }
  }

  arrayBuffer(): Promise<ArrayBuffer> {
    if (!this.body) return Promise.resolve(new ArrayBuffer(0));

    if (typeof this.body === 'string') {
      return new Blob([this.body]).arrayBuffer();
    }
    return this.body.arrayBuffer();
  }

  async blob(): Promise<Blob> {
    if (!this.body) new Blob([]);

    if (typeof this.body === 'string') {
      return new Blob([this.body]);
    }
    return this.body as Blob;
  }

  formData(): Promise<FormData> {
    throw new Error('not supported');
  }

  async json(): Promise<any> {
    if (!this.body) {
      return {};
    }

    this.bodyUsed = true;

    if (typeof this.body === 'string') {
      return JSON.parse(this.body);
    }

    const txt = await this.body.text();
    return JSON.parse(txt);
  }

  async text(): Promise<string> {
    let rejected = consumed(this);
    if (rejected) {
      return rejected;
    }
    this.bodyUsed = true;

    if (!this.body) return '';

    if (typeof this.body === 'string') {
      return this.body || '';
    }

    return this.body.text();
  }
}

let methods = ['DELETE', 'GET', 'HEAD', 'OPTIONS', 'POST', 'PUT'];

function normalizeMethod(method: string) {
  let upcased = method.toUpperCase();
  return methods.indexOf(upcased) > -1 ? upcased : method;
}

export class Request extends Body {
  constructor(input: Request | string, init?: RequestInit) {
    super();
    if (!init) {
      init = {};
    }
    let body = init.body;

    if (input instanceof Request) {
      if (input.bodyUsed) {
        throw new TypeError('Already read');
      }
      this.url = input.url;
      if (!init.headers) {
        this.headers = new Headers(input.headers as unknown as HeadersInit);
      }
      this.method = input.method;
      this.mode = input.mode;
      if (!body && input._bodyInit != null) {
        body = input._bodyInit;
        input.bodyUsed = true;
      }
    } else {
      this.url = String(input);
    }

    if (init.headers || !this.headers) {
      this.headers = new Headers(init.headers);
    }
    this.method = normalizeMethod(init.method || this.method || 'GET');
    this.mode = init.mode || this.mode || null;
    this.signal = init.signal || this.signal || (function () {
      if ('AbortController' in window) {
        let ctrl = new AbortController();
        return ctrl.signal;
      }
      return undefined;
    }());

    if ((this.method === 'GET' || this.method === 'HEAD') && body) {
      throw new TypeError('Body not allowed for GET or HEAD requests')
    }

    this._initBody(body || null);
  }

  // readonly cache: RequestCache; // not supported
  // readonly credentials: RequestCredentials; // not supported;
  // readonly destination: RequestDestination; // not supported
  // readonly integrity: string; // not supported
  // readonly isHistoryNavigation: boolean; // not supported
  // readonly isReloadNavigation: boolean; // not supported
  // readonly keepalive: boolean; // not supported
  // readonly redirect: RequestRedirect; // not supported
  // readonly referrer: string; // not supported
  // readonly referrerPolicy: ReferrerPolicy;
  readonly signal: AbortSignal; // not supported

  readonly url: string;
  readonly method: string;
  readonly headers: Headers;
  readonly mode: RequestMode;

  clone(): Request {
    return new Request(this, { body: this._bodyInit });
  }
}

let redirectStatuses = [301, 302, 303, 307, 308];

export class Response extends Body {
  static error(): Response {
    let response = new Response(null, { status: 0, statusText: '' });
    response.type = 'error';
    return response;
  };

  static redirect(url: string, status?: number): Response {
    if (!status || redirectStatuses.indexOf(status) === -1) {
      throw new RangeError('Invalid status code')
    }

    let response = new Response(null, { status: status, headers: { location: url } });
    response.redirected = true;
    return response;
  };

  // TODO support readableStream
  // readonly body: ReadableStream<Uint8Array> | null;
  // @ts-ignore
  body: string | null;
  // @ts-ignore
  bodyUsed: boolean;
  headers: Headers;
  ok: boolean;
  redirected: boolean;
  status: number;
  statusText: string;
  type: ResponseType;
  url: string;

  constructor(body?: BodyInit | null, init?: ResponseInit) {
    super();
    if (!init) {
      init = {};
    }
    this.bodyUsed = false;
    this.type = 'default';
    this.status = init.status === undefined ? 200 : init.status;
    this.ok = this.status >= 200 && this.status < 300;
    this.statusText = 'statusText' in init ? (init.statusText || '') : 'OK';
    this.headers = new Headers(init.headers);

    this._initBody(body || null);
  }

  clone(): Response {
    const headers = new Headers(this.headers as unknown as HeadersInit);
    return new Response(this._bodyInit, {
      status: this.status,
      statusText: this.statusText,
      headers: headers as unknown as HeadersInit
    })
  }
}

export type Fetch = (input: Request | string, init?: RequestInit) => Promise<Response>;

export const fetch: Fetch = (input: Request | string, init?: RequestInit): Promise<Response> => {
  return new Promise((resolve, reject) => {
    let request = new Request(input, init);

    if (request.signal && request.signal.aborted) {
      return reject(new DOMException('Aborted', 'AbortError'))
    }
    let headers = request.headers || new Headers();

    function abortRequest() {
      webf.invokeModule('Fetch', 'abortRequest');
    }

    webf.invokeModule('Fetch', request.url, ({
      ...init,
      headers: (headers as Headers).map
    }), (e, data) => {
      request.signal.removeEventListener('abort', abortRequest);
      if (e) return reject(e);
      let [err, statusCode, body] = data;
      // network error didn't have statusCode
      if (err && !statusCode) {
        reject(new Error(err));
        return;
      }

      let res = new Response(body, {
        status: statusCode
      });

      res.url = request.url;

      return resolve(res);
    });

    if (request.signal) {
      request.signal.addEventListener('abort', abortRequest)
    }
  });
}
