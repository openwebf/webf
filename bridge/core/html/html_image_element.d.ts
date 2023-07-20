import {HTMLElement} from "./html_element";

interface HTMLImageElement extends HTMLElement {
    alt: DartImpl<string>;
    // src: DartImpl<string>;
    src: string;
    // srcset: DartImpl<string>;
    sizes: DartImpl<string>;
    width: DartImpl<int64>;
    height: DartImpl<int64>;
    readonly naturalWidth: DartImpl<int64>;
    readonly naturalHeight: DartImpl<int64>;
    readonly complete: DartImpl<boolean>;
    readonly currentSrc: DartImpl<string>;
    decoding: DartImpl<string>;
    fetchPriority: DartImpl<string>;
    loading: DartImpl<string>;

    decode(): Promise<void>;
    new(): void;
}