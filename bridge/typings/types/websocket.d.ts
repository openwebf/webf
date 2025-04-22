export interface WebSocketInterface extends EventTarget {
    readonly CONNECTING: number;
    readonly OPEN: number;
    readonly CLOSING: number;
    readonly CLOSED: number;
    readonly extensions: string;
    readonly protocol: string;
    binaryType: string;
    readonly url: string;
    readonly readyState: number;
    addEventListener(type: string, callback: EventListener | EventListenerObject): void;
    removeEventListener(type: string, callback: EventListener | EventListenerObject): void;
    dispatchEvent(event: Event): boolean;
    send(data: string | ArrayBufferLike | Blob | ArrayBufferView): void;
    close(code?: number, reason?: string): void;
}
export declare class WebSocket extends EventTarget implements WebSocketInterface {
    CONNECTING: number;
    OPEN: number;
    CLOSING: number;
    CLOSED: number;
    extensions: string;
    protocol: string;
    binaryType: string;
    url: string;
    readyState: number;
    id: string;
    constructor(url: string, protocol: string);
    addEventListener(type: string, callback: EventListener | EventListenerObject): void;
    send(message: string): void;
    close(code?: number, reason?: string): void;
}
