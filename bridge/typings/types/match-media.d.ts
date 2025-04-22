export interface Expression {
    modifier: string;
    feature: string;
    value: string;
}
export interface Query {
    inverse: boolean;
    type: string;
    expressions: Array<Expression>;
}
export interface MediaQueryListEvent {
    readonly matches: boolean;
    readonly media: string;
}
export interface MediaQueryList {
    readonly matches: boolean;
    readonly media: string;
    addListener(listener: ((ev: MediaQueryListEvent) => any) | null): void;
    removeListener(listener: ((ev: MediaQueryListEvent) => any) | null): void;
}
export declare type MatchMedia = (mediaQuery: string) => MediaQueryList;
export declare const matchMedia: MatchMedia;
