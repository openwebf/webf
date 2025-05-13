export interface XMLHttpRequestInterface extends EventTarget {
    readonly UNSENT: number;
    readonly OPENED: number;
    readonly HEADERS_RECEIVED: number;
    readonly LOADING: number;
    readonly DONE: number;
    readyState: number;
    onreadystatechange: ((this: XMLHttpRequest, ev: Event) => any) | null;
    responseType: string;
    responseText: string;
    responseXML: any;
    status: number;
    statusText: string | null;
    withCredentials: boolean;
    open(method: string, url: string, async?: boolean, user?: string, password?: string): void;
    setRequestHeader(header: string, value: string): void;
    getResponseHeader(header: string): string | null;
    getAllResponseHeaders(): string;
    send(data?: string): void;
    abort(): void;
}
export declare class XMLHttpRequest extends EventTarget implements XMLHttpRequestInterface {
    /**
     * XHR readyState
     */
    UNSENT: number;
    OPENED: number;
    HEADERS_RECEIVED: number;
    LOADING: number;
    DONE: number;
    readyState: number;
    onreadystatechange: null;
    responseType: string;
    responseText: string;
    responseXML: string;
    status: number;
    statusText: null;
    withCredentials: boolean;
    private response;
    private settings;
    private headers;
    private headersCache;
    private sendFlag;
    private errorFlag;
    constructor();
    /**
     * Open the connection.
     *
     * @param string method Connection method (eg GET, POST)
     * @param string url URL for the connection.
     * @param boolean async Asynchronous connection. Default is true.
     * @param string user Username for basic authentication (optional)
     * @param string password Password for basic authentication (optional)
     */
    open(method: string, url: string, async: boolean, user: string, password: string): void;
    /**
     * Sets a header for the request or appends the value if one is already set.
     *
     * @param string header Header name
     * @param string value Header value
     */
    setRequestHeader(header: string, value: string): void;
    /**
     * Gets a header from the server response.
     *
     * @param string header Name of header to get.
     * @return string Text of the header or null if it doesn't exist.
     */
    getResponseHeader(header: string): any;
    /**
     * Gets all the response headers.
     *
     * @return string A string with all response headers separated by CR+LF
     */
    getAllResponseHeaders(): string;
    /**
     * Sends the request to the server.
     *
     * @param string data Optional data to send as request body.
     */
    send(data: string): void;
    /**
     * Aborts a request.
     */
    abort(): void;
    /**
     * Check if the specified method is allowed.
     *
     * @param string method Request method to validate
     * @return boolean False if not allowed, otherwise true
     */
    private isAllowedHttpMethod;
    /**
     * Gets a request header
     *
     * @param string name Name of header to get
     * @return string Returns the request header or empty string if not set
     */
    private getRequestHeader;
    /**
     * Called when an error is encountered to deal with it.
     */
    private handleError;
    /**
     * Changes readyState and calls onreadystatechange.
     *
     * @param int state New state
     */
    private setState;
}
