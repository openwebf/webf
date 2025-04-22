export interface BoxSize {
    blockSize: number;
    inlineSize: number;
}
export interface ResizeObserverEntry {
    readonly target: EventTarget;
    readonly borderBoxSize: BoxSize;
    readonly contentBoxSize: BoxSize;
    readonly contentRect: {
        width: number;
        height: number;
    };
}
export interface ResizeObserverInterface {
    observe(target: HTMLElement): void;
    unobserve(target: HTMLElement): void;
    disconnect?(): void;
}
export declare class ResizeObserver implements ResizeObserverInterface {
    private resizeChangeListener;
    private targets;
    private cacheEvents;
    private dispatchEvent;
    private pending;
    constructor(callBack: (entries: Array<ResizeObserverEntry>) => void);
    observe(target: HTMLElement): void;
    handleResizeEvent(event: any): void;
    sendEventToElement(): void;
    unobserve(target: HTMLElement): void;
    disconnect(): void;
}
