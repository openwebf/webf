export interface LocationInterface {
    href: string;
    origin: string;
    protocol: string;
    host: string;
    hostname: string;
    port: string;
    pathname: string;
    search: string;
    hash: string;
    assign(url: string): void;
    reload(): void;
    replace(url: string): void;
    toString(): string;
}
declare class Location implements LocationInterface {
    get href(): string;
    set href(url: string);
    get origin(): any;
    get protocol(): any;
    get host(): any;
    get hostname(): any;
    get port(): any;
    get pathname(): any;
    get search(): any;
    get hash(): any;
    get assign(): (assignURL: string) => void;
    get reload(): any;
    get replace(): (replaceURL: string) => void;
    get toString(): () => string;
}
export declare const location: Location;
export {};
