export interface AbortSignalInterface extends EventTarget {
    readonly aborted: boolean;
    onabort: ((this: AbortSignalInterface, ev: Event) => any) | null;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
    dispatchEvent(event: Event): boolean;
}
export interface AbortControllerInterface {
    readonly signal: AbortSignalInterface;
    abort(): void;
}
export declare class _AbortSignal extends EventTarget {
    _aborted: boolean;
    get aborted(): boolean;
    constructor(secret: any);
    private _onabort;
    get onabort(): any;
    set onabort(callback: any);
}
export declare class _AbortController {
    _signal: _AbortSignal;
    constructor();
    get signal(): _AbortSignal;
    abort(): void;
}
