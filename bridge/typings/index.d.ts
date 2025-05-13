import type { Console } from './types/console';
import type { 
    Fetch, 
    HeadersInit, 
    RequestInit, 
    BodyInit,
    ResponseInit,
    Headers as HeaderClass, 
    Request as RequestClass, 
    Response as ResponseClass } from './types/fetch';
import type { MatchMedia } from './types/match-media';
import type { LocationInterface } from './types/location'
import type { HistoryInterface } from './types/history';
import type { NavigatorInterface } from './types/navigator';
import type { XMLHttpRequestInterface } from './types/xhr';
import type { AsyncStorage } from './types/async-storage';
import type { StorageInterface } from './types/storage';
import type { URLSearchParamsInterface } from './types/url-search-params';
import type { URLInterface } from './types/url';
import type { DOMException as DOMExceptionInterface } from './types/dom-exception';
import type { WebSocketInterface } from './types/websocket';
import type { ResizeObserverInterface } from './types/resize-observer';
import type { AbortSignalInterface, AbortControllerInterface } from './types/abort-signal';
import type { Webf } from './types/webf';


declare global {
    // Window interface
    interface Window {
        // Console
        console: Console;

        // Fetch API
        fetch: Fetch;
        Headers: {
            new(init?: HeadersInit): HeaderClass;
            prototype: HeaderClass;
        };
        Request: {
            new(input: RequestClass | string, init?: RequestInit): RequestClass;
            prototype: RequestClass;
        };
        Response: {
            new(body?: BodyInit | null, init?: ResponseInit): ResponseClass;
            prototype: ResponseClass;
        };

        // DOM & BOM
        matchMedia: MatchMedia;
        location: LocationInterface;
        history: HistoryInterface;
        navigator: NavigatorInterface;

        // XHR
        XMLHttpRequest: {
            new(): XMLHttpRequestInterface;
            prototype: XMLHttpRequestInterface;
        };

        // Storage
        asyncStorage: AsyncStorage;
        localStorage: StorageInterface;
        sessionStorage: StorageInterface;
        Storage: {
            new(): StorageInterface;
            prototype: StorageInterface;
        };

        // URL
        URLSearchParams: {
            new(init?: string | string[][] | Record<string, string> | URLSearchParams): URLSearchParamsInterface;
            prototype: URLSearchParamsInterface;
        };
        URL: {
            new(url: string, base?: string): URLInterface;
            prototype: URLInterface;
        };

        // Exception
        DOMException: {
            new(message?: string, name?: string): DOMExceptionInterface;
            prototype: DOMExceptionInterface;
        };

        // WebF
        webf: Webf;

        // WebSocket
        WebSocket: {
            new(url: string, protocols?: string | string[]): WebSocketInterface;
            prototype: WebSocketInterface;
        };

        // ResizeObserver
        ResizeObserver: {
            new(callback: Function): ResizeObserverInterface;
            prototype: ResizeObserverInterface;
        };

        // Abort API
        AbortController: {
            new(): AbortControllerInterface;
            prototype: AbortControllerInterface;
        };
        AbortSignal: {
            new(): AbortSignalInterface;
            prototype: AbortSignalInterface;
        };
    }

    // Global window object
    const window: Window & typeof globalThis;

    // Console
    const console: Console;

    // Fetch API
    const fetch: Fetch;
    const Headers: {
        new(init?: HeadersInit): HeaderClass;
        prototype: HeaderClass;
    };
    const Request: {
        new(input: RequestInfo, init?: RequestInit): RequestClass;
        prototype: RequestClass;
    };
    const Response: {
        new(body?: BodyInit | null, init?: ResponseInit): ResponseClass;
        prototype: ResponseClass;
    };

    // DOM & BOM
    const matchMedia: MatchMedia;
    const location: LocationInterface;
    const history: HistoryInterface;
    const navigator: NavigatorInterface;
    // XHR
    const XMLHttpRequest: {
        new(): XMLHttpRequestInterface;
        prototype: XMLHttpRequestInterface;
    };

    // Storage
    const asyncStorage: AsyncStorage;
    const localStorage: StorageInterface;
    const sessionStorage: StorageInterface;
    const Storage: {
        new(): StorageInterface;
        prototype: StorageInterface;
    };

    // URL
    const URLSearchParams: {
        new(init?: string | string[][] | Record<string, string> | URLSearchParams): URLSearchParamsInterface;
        prototype: URLSearchParamsInterface;
    };
    const URL: {
        new(url: string, base?: string): URLInterface;
        prototype: URLInterface;
    };        

    // Exception
    const DOMException: {
        new(message?: string, name?: string): DOMExceptionInterface;
        prototype: DOMExceptionInterface;
    };

    // WebF
    const webf: Webf;

    // WebSocket
    const WebSocket: {
        new(url: string, protocols?: string | string[]): WebSocketInterface;
        prototype: WebSocketInterface;
    };

    // ResizeObserver
    const ResizeObserver: {
        new(callback: Function): ResizeObserverInterface;
        prototype: ResizeObserverInterface;
    };

    // Abort API
    const AbortController: {
        new(): AbortControllerInterface;
        prototype: AbortControllerInterface;
    };
    const AbortSignal: {
        new(): AbortSignalInterface;
        prototype: AbortSignalInterface;
    };
}

export { };