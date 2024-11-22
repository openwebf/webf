import {HTMLElement} from "./html_element";

interface HTMLImageElement extends HTMLElement {
    alt: DartImpl<string>;
    src: SupportAsync<string>;
    sizes: DartImpl<string>;
    width: SupportAsync<DartImpl<DependentsOnLayout<int64>>>;
    height: SupportAsync<DartImpl<DependentsOnLayout<int64>>>;
    readonly naturalWidth: SupportAsync<DartImpl<DependentsOnLayout<int64>>>;
    readonly naturalHeight: SupportAsync<DartImpl<DependentsOnLayout<int64>>>;
    readonly complete: SupportAsync<DartImpl<boolean>>;
    readonly currentSrc: DartImpl<string>;
    decoding: DartImpl<string>;
    fetchPriority: DartImpl<string>;
    loading: SupportAsync<DartImpl<string>>;

    decode(): Promise<void>;
    new(): void;
}