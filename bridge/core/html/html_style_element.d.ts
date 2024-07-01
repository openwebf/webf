import {HTMLElement} from "./html_element";

interface HTMLStyleElement extends HTMLElement {
    rel: DartImpl<string>;
    type: DartImpl<string>;
    new(): void;
}