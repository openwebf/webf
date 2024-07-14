import {HTMLElement} from "./html_element";

interface HTMLStyleElement extends HTMLElement {
    readonly type: string;
    new(): void;
}