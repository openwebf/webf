import {HTMLElement} from "./html_element";

interface HTMLScriptElement extends HTMLElement {
    src: DartImpl<string>;
    type: DartImpl<string>;
    noModule: DartImpl<boolean>;
    async: DartImpl<boolean>;
    text: DartImpl<string>;
    readonly readyState: DartImpl<string>;
    supports(type: string): StaticMember<boolean>;
    new(): void;
}
