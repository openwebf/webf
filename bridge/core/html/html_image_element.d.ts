import {HTMLElement} from "./html_element";

interface HTMLImageElement extends HTMLElement {
    alt: DartImpl<string>;
    // src: DartImpl<string>;
    src: SupportAsync<string>;
    // srcset: DartImpl<string>;
    sizes: SupportAsync<DartImpl<string>>;
    width: DartImpl<DependentsOnLayout<int64>>;
    height: DartImpl<DependentsOnLayout<int64>>;
    readonly naturalWidth: DartImpl<DependentsOnLayout<int64>>;
    readonly naturalHeight: DartImpl<DependentsOnLayout<int64>>;
    readonly complete: DartImpl<boolean>;
    readonly currentSrc: DartImpl<string>;
    decoding: DartImpl<string>;
    fetchPriority: DartImpl<string>;
    loading: DartImpl<string>;

    decode(): Promise<void>;
    new(): void;
}