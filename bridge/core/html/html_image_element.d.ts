import {HTMLElement} from "./html_element";

interface HTMLImageElement extends HTMLElement {
    alt: DartImpl<string>;
    src: DartImpl<string>;
    srcset: DartImpl<string>;
    sizes: DartImpl<string>;
    width: DartImpl<double>;
    height: DartImpl<double>;
    readonly naturalWidth: DartImpl<double>;
    readonly naturalHeight: DartImpl<double>;
    readonly complete: DartImpl<boolean>;
    readonly currentSrc: DartImpl<boolean>;
    decoding: DartImpl<string>;
    fetchPriority: DartImpl<string>;
    loading: DartImpl<string>;

    decode(): Promise<void>;
    new(): void;
}