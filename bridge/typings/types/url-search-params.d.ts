export interface URLSearchParamsInterface {
    append(name: string, value: string): void;
    delete(name: string): void;
    get(name: string): string | null;
    getAll(name: string): string[];
    has(name: string): boolean;
    set(name: string, value: string): void;
    forEach(callback: (value: string, key: string, parent: URLSearchParams) => void, thisArg?: any): void;
    toString(): string;
}
export declare class URLSearchParams implements URLSearchParamsInterface {
    private _dict;
    constructor(query: any);
    _reset(): void;
    _fromString(query: string): void;
    /**
     * Appends a specified key/value pair as a new search parameter.
     */
    append(name: string, value: string): void;
    /**
     * Deletes the given search parameter, and its associated value, from the list of all search parameters.
     */
    delete(name: string): void;
    /**
     * Returns the first value associated to the given search parameter.
     */
    get(name: string): string | null;
    /**
     * Returns all the values association with a given search parameter.
     */
    getAll(name: string): string[];
    /**
     * Returns a Boolean indicating if such a search parameter exists.
     */
    has(name: string): boolean;
    /**
     * Sets the value associated to a given search parameter to the given value. If there were several values, delete the others.
     */
    set(name: string, value: string): void;
    /**
     * Allows iteration through all values contained in this object via a callback function.
     * @param callback A callback function that is executed against each parameter, with the param value provided as its parameter.
     * @param thisArg
     */
    forEach(callback: (value: string, key: string, parent: URLSearchParams) => void, thisArg?: any): void;
    /**
     * Returns a string containing a query string suitable for use in a URL. Does not include the question mark.
     */
    toString(): string;
}
