export interface Console {
    log(...args: any[]): void;
    inspect(...args: any[]): void;
    info(...args: any[]): void;
    warn(...args: any[]): void;
    debug(...args: any[]): void;
    error(...args: any[]): void;
    dirxml(...args: any[]): void;
    dir(...args: any[]): void;
    table(data: Array<any>, filterColumns: Array<string>): void;
    trace(...args: any[]): void;
    count(label?: string): void;
    countReset(label?: string): void;
    assert(expression: boolean, ...args: Array<any>): void;
    time(label?: string): void;
    timeLog(label?: string, ...args: Array<any>): void;
    timeEnd(label?: string): void;
    group(...data: Array<any>): void;
    groupCollapsed(...data: Array<any>): void;
    groupEnd(): void;
    clear(): void;
}
export declare const console: Console;
