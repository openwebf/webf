export interface AsyncStorage {
    getItem(key: number | string): Promise<string>;
    setItem(key: number | string, value: number | string): Promise<any>;
    removeItem(key: number | string): Promise<any>;
    clear(): Promise<any>;
    getAllKeys(): Promise<string[]>;
    length(): Promise<number>;
}
export declare const asyncStorage: AsyncStorage;
