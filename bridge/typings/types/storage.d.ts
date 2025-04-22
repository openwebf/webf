export interface StorageInterface {
    readonly length: number;
    getItem(key: string): string | null;
    setItem(key: string, value: string): void;
    removeItem(key: string): void;
    clear(): void;
    key(index: number): string | null;
    getAllKeys(): string[];
}
export declare class Storage implements StorageInterface {
    moduleName: string;
    constructor(moduleName: string);
    getItem(key: number | string): any;
    setItem(key: number | string, value: number | string): any;
    removeItem(key: number | string): any;
    clear(): any;
    key(index: number): any;
    getAllKeys(): any;
    get length(): number;
}
export declare const storageProxyHandler: {
    get(target: Storage, p: string | symbol, receiver: any): any;
    set(target: Storage, p: string | symbol, newValue: any, receiver: any): boolean;
    has(target: Storage, p: string | symbol): boolean;
    ownKeys(target: Storage): ArrayLike<string | symbol>;
    deleteProperty(target: Storage, p: string | symbol): boolean;
    defineProperty(target: Storage, property: string | symbol, attributes: PropertyDescriptor): boolean;
    getOwnPropertyDescriptor(target: Storage, p: string | symbol): PropertyDescriptor | undefined;
};
