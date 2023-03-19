import {HTMLElement} from "./html_element";

interface HTMLImageElement extends HTMLElement {
    alt: DartImpl<string>;
    src: DartImpl<string>;
    srcset: DartImpl<string>;
    sizes: DartImpl<string>;
    width: DartImpl<int64>;
    height: DartImpl<int64>;
    readonly naturalWidth: DartImpl<int64>;
    readonly naturalHeight: DartImpl<int64>;
    readonly complete: DartImpl<boolean>;
    readonly currentSrc: DartImpl<boolean>;
    decoding: DartImpl<string>;
    fetchPriority: DartImpl<string>;
    loading: DartImpl<string>;

    new(): void;
}