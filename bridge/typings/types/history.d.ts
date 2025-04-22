export interface HistoryInterface {
    readonly length: number;
    readonly state: any;
    back(): void;
    forward(): void;
    go(delta?: number): void;
    pushState(state: any, title: string, url?: string): void;
    replaceState(state: any, title: string, url?: string): void;
}
declare class History implements HistoryInterface {
    constructor();
    get length(): number;
    get state(): any;
    back(): void;
    forward(): void;
    go(delta?: number): void;
    pushState(state: any, title: string, url?: string): void;
    replaceState(state: any, title: string, url?: string): void;
}
export declare const history: History;
export {};
