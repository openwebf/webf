export interface Cookie {
    get(): string;
    set(str: string): void;
}
export declare const cookie: Cookie;
