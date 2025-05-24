export declare type HeadersInit = Headers | Record<string, string> | [string, string][];
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
declare type RequestMode = 'cors' | 'no-cors' | 'same-origin' | 'navigate';
declare type ResponseType = 'basic' | 'cors' | 'default' | 'error' | 'opaque' | 'opaqueredirect';
export declare type BodyInit = string | Blob | ArrayBuffer | FormData | URLSearchParams | null;
export declare class Headers implements Headers {
    map: Record<string, string>;
    constructor(headers?: HeadersInit);
    append(name: string, value: string): void;
    delete(name: string): void;
    forEach(callbackfn: (value: string, key: string, parent: Headers) => void, thisArg?: any): void;
    get(name: string): string | null;
    has(name: string): boolean;
    set(name: string, value: string): void;
}
declare class Body {
    _bodyInit: any;
    body: string | null | Blob | FormData;
    bodyUsed: boolean;
    headers: Headers;
    constructor();
    _initBody(body: BodyInit | null): void;
    arrayBuffer(): Promise<ArrayBuffer>;
    blob(): Promise<Blob>;
    formData(): Promise<FormData>;
    json(): Promise<any>;
    text(): Promise<string>;
}
export declare class Request extends Body {
    constructor(input: Request | string, init?: RequestInit);
    readonly signal: AbortSignal;
    readonly url: string;
    readonly method: string;
    readonly headers: Headers;
    readonly mode: RequestMode;
    clone(): Request;
}
export declare class Response extends Body {
    static error(): Response;
    static redirect(url: string, status?: number): Response;
    body: string | null;
    bodyUsed: boolean;
    headers: Headers;
    ok: boolean;
    redirected: boolean;
    status: number;
    statusText: string;
    type: ResponseType;
    url: string;
    constructor(body?: BodyInit | null, init?: ResponseInit);
    clone(): Response;
}
export declare type Fetch = (input: Request | string, init?: RequestInit) => Promise<Response>;
export declare const fetch: Fetch;
export {};
